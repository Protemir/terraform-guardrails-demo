#!/usr/bin/env node
// Сводит результаты всех проверок в один комментарий к pull request и решает, блокировать ли слияние.
//
// Вход (каталог --in, все файлы необязательны):
//   conftest.json   — conftest test -o json по JSON-плану (наши правила Rego)
//   checkov.json    — checkov -o json
//   trivy.json      — trivy config -f json
//   tflint.json     — tflint --format json
//   steps.json      — {"fmt": "success|failure", "validate": "...", "plan": "...", "tests": "..."}
//   plan.txt        — terraform show plan.out (текст плана)
//   exceptions.json — policies/exceptions.yaml, переведённый в JSON
// Выход: --out comment.md; код 1, если есть блокирующие нарушения.
//
// Блокируют слияние: deny из conftest (уровень critical), CRITICAL из Trivy,
// проверки Checkov из ci/checkov-critical.txt, ошибки fmt/validate/plan и TFLint уровня error.
import fs from "node:fs";
import path from "node:path";

const args = Object.fromEntries(process.argv.slice(2).reduce((a, x, i, all) => (x.startsWith("--") ? [...a, [x.slice(2), all[i + 1]]] : a), []));
const inDir = args.in || "results";
const outFile = args.out || "comment.md";
const root = args.root || "live/stand";
const repo = process.env.GITHUB_REPOSITORY || "";
const sha = process.env.PR_HEAD_SHA || process.env.GITHUB_SHA || "main";

const read = (f, d = null) => {
  const p = path.join(inDir, f);
  if (!fs.existsSync(p)) return d;
  const t = fs.readFileSync(p, "utf8").trim();
  if (!t) return d;
  try { return f.endsWith(".json") ? JSON.parse(t) : t; } catch { return d; }
};

const sevOrder = { critical: 0, high: 1, medium: 2, low: 3, info: 4 };
const sevIcon = { critical: "🛑", high: "🟠", medium: "🟡", low: "⚪", info: "⚪" };

// ---------- исключения ----------
const today = new Date().toISOString().slice(0, 10);
const exceptions = (read("exceptions.json", {})?.exceptions || []).map((e, i) => ({ ...e, index: i }));
const globToRe = (g) => new RegExp("^" + String(g).replace(/[.+^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*").replace(/\?/g, ".") + "$");
const validException = (e) => {
  const exp = String(e.expires || "").slice(0, 10);
  const days = (Date.parse(exp) - Date.now()) / 86400000;
  return String(e.reason || "").trim().length >= 15 && e.owner && /^\d{4}-\d{2}-\d{2}$/.test(exp) && exp >= today && days <= 180;
};
const findException = (rule, ...targets) =>
  exceptions.find((e) => e.rule === rule && validException(e) && targets.some((t) => t && globToRe(e.resource).test(t)));

// ---------- поиск файла и строки ----------
const tfFiles = (dir) => {
  if (!fs.existsSync(dir)) return [];
  return fs.readdirSync(dir).filter((f) => f.endsWith(".tf")).map((f) => path.join(dir, f).replace(/\\/g, "/"));
};
const fileCache = new Map();
const lines = (f) => {
  if (!fileCache.has(f)) fileCache.set(f, fs.readFileSync(f, "utf8").split(/\r?\n/));
  return fileCache.get(f);
};
function findBlock(dir, header) {
  for (const f of tfFiles(dir)) {
    const ls = lines(f);
    const i = ls.findIndex((l) => header.test(l));
    if (i >= 0) return { file: f, line: i + 1, ls, start: i };
  }
  return null;
}
function locate(address, attr) {
  const clean = address.replace(/\[[^\]]*\]/g, "");
  if (clean.startsWith("exceptions")) {
    const f = "policies/exceptions.yaml";
    if (!fs.existsSync(f)) return null;
    const idx = Number((address.match(/\[(\d+)\]/) || [])[1] || 0);
    const ls = lines(f);
    let n = -1;
    for (let i = 0; i < ls.length; i++) if (/^\s*-\s*rule:/.test(ls[i]) && ++n === idx) return { file: f, line: i + 1 };
    return { file: f, line: 1 };
  }
  const parts = clean.split(".");
  let hit = null;
  if (parts[0] === "module") hit = findBlock(root, new RegExp(`^\\s*module\\s+"${parts[1]}"`));
  else if (parts[0] === "provider") hit = findBlock(root, new RegExp(`^\\s*${parts[1]}\\s*=\\s*\\{`));
  else if (parts.length >= 2) hit = findBlock(root, new RegExp(`^\\s*resource\\s+"${parts[0]}"\\s+"${parts[1]}"`));
  if (!hit) return null;
  if (attr && hit.ls && parts[0] !== "module") {
    // Ищем атрибут внутри блока ресурса (до закрывающей скобки в начале строки).
    for (let i = hit.start + 1; i < hit.ls.length && !/^}/.test(hit.ls[i]); i++) {
      if (new RegExp(`\\b${attr}\\b`).test(hit.ls[i])) return { file: hit.file, line: i + 1 };
    }
  }
  return { file: hit.file, line: hit.line };
}
const link = (loc) => {
  if (!loc) return "—";
  const label = `${loc.file}:${loc.line}`;
  return repo ? `[${label}](https://github.com/${repo}/blob/${sha}/${loc.file}#L${loc.line})` : label;
};

// ---------- сбор находок ----------
const findings = [];
const suppressed = [];
const add = (f) => {
  const ex = findException(f.rule, f.address, f.file);
  if (ex) suppressed.push({ ...f, exception: ex });
  else findings.push(f);
};

// conftest: deny — critical, warn — по metadata.severity
for (const r of read("conftest.json", []) || []) {
  for (const kind of ["failures", "warnings"]) {
    for (const x of r[kind] || []) {
      const m = x.metadata || {};
      const loc = locate(m.address || "", m.attr);
      findings.push({
        tool: "OPA", rule: m.rule || "?", severity: kind === "failures" ? "critical" : m.severity || "medium",
        title: m.title || "", address: m.address || "", msg: x.msg.replace(/^\[[^\]]+\]\s*/, ""), loc,
        blocking: kind === "failures",
      });
    }
  }
}

// Checkov
const checkovCritical = new Set(
  (fs.existsSync(new URL("./checkov-critical.txt", import.meta.url)) ? fs.readFileSync(new URL("./checkov-critical.txt", import.meta.url), "utf8") : "")
    .split(/\r?\n/).map((l) => l.replace(/#.*/, "").trim()).filter(Boolean),
);
const checkovRaw = read("checkov.json", []);
for (const block of Array.isArray(checkovRaw) ? checkovRaw : [checkovRaw]) {
  for (const c of block?.results?.failed_checks || []) {
    const crit = checkovCritical.has(c.check_id);
    const file = String(c.file_path || "").replace(/^\//, "");
    add({
      tool: "Checkov", rule: c.check_id, severity: crit ? "critical" : (c.severity || "medium").toLowerCase(),
      title: c.check_name, address: c.resource, msg: c.check_name, loc: { file, line: c.file_line_range?.[0] || 1 },
      blocking: crit, file,
    });
  }
}

// Trivy: CRITICAL блокирует, кроме проверок из ci/trivy-noncritical.txt (там — с причиной).
const trivyDowngrade = new Set(
  (fs.existsSync(new URL("./trivy-noncritical.txt", import.meta.url)) ? fs.readFileSync(new URL("./trivy-noncritical.txt", import.meta.url), "utf8") : "")
    .split(/\r?\n/).map((l) => l.replace(/#.*/, "").trim()).filter(Boolean),
);
for (const res of read("trivy.json", {})?.Results || []) {
  for (const m of res.Misconfigurations || []) {
    if (m.Status && m.Status !== "FAIL") continue;
    let sev = (m.Severity || "MEDIUM").toLowerCase();
    if (sev === "critical" && (trivyDowngrade.has(m.AVDID) || trivyDowngrade.has(m.ID))) sev = "high";
    add({
      tool: "Trivy", rule: m.AVDID || m.ID, severity: sev, title: m.Title, address: m.CauseMetadata?.Resource || "",
      msg: m.Message || m.Title, loc: { file: res.Target, line: m.CauseMetadata?.StartLine || 1 }, blocking: sev === "critical", file: res.Target,
    });
  }
}

// TFLint
for (const i of read("tflint.json", {})?.issues || []) {
  const sev = i.rule?.severity === "error" ? "high" : "low";
  add({
    tool: "TFLint", rule: i.rule?.name, severity: sev, title: i.message, address: "", msg: i.message,
    loc: { file: i.range?.filename, line: i.range?.start?.line || 1 }, blocking: i.rule?.severity === "error", file: i.range?.filename,
  });
}

// ---------- шаги конвейера ----------
const steps = read("steps.json", {}) || {};
const stepNames = { fmt: "terraform fmt", validate: "validate", tflint: "TFLint", checkov: "Checkov", trivy: "Trivy", plan: "plan", conftest: "Conftest", tests: "terraform test" };
const failedSteps = Object.entries(steps).filter(([, v]) => v === "failure").map(([k]) => k);

const blocking = findings.filter((f) => f.blocking);
const verdict = blocking.length === 0 && failedSteps.length === 0;

// ---------- комментарий ----------
const md = [];
md.push("<!-- iac-guardrails -->");
md.push(verdict ? "## ✅ Проверка инфраструктуры пройдена" : "## ❌ Слияние заблокировано");
md.push("");
md.push(
  Object.entries(stepNames).filter(([k]) => steps[k]).map(([k, n]) => `${steps[k] === "success" ? "✅" : steps[k] === "skipped" ? "⏭️" : "❌"} ${n}`).join(" · "),
);
md.push("");

const bySev = (s) => findings.filter((f) => f.severity === s).length;
md.push(`Нарушения: **${bySev("critical")}** критичных, ${bySev("high")} высоких, ${bySev("medium")} средних, ${bySev("low")} низких. Исключений применено: ${suppressed.length}.`);
md.push("");

const row = (f) => `| ${sevIcon[f.severity] || ""} ${f.severity} | \`${f.rule}\` | ${f.tool} | ${f.msg.replace(/\|/g, "\\|")} | ${link(f.loc)} |`;
const head = "| Уровень | Правило | Инструмент | Что не так | Где |\n|---|---|---|---|---|";

if (blocking.length) {
  md.push("### Блокирующие нарушения");
  md.push(head);
  for (const f of blocking.sort((a, b) => a.rule.localeCompare(b.rule))) md.push(row(f));
  md.push("");
  md.push("Исправьте код или оформите исключение в `policies/exceptions.yaml` (правило, ресурс, обоснование, владелец, срок до 180 дней).");
  md.push("");
}
if (failedSteps.length) {
  md.push(`Шаги с ошибкой: ${failedSteps.map((s) => stepNames[s] || s).join(", ")} — подробности в журнале CI.`);
  md.push("");
}

const rest = findings.filter((f) => !f.blocking).sort((a, b) => sevOrder[a.severity] - sevOrder[b.severity] || a.rule.localeCompare(b.rule));
if (rest.length) {
  const ours = rest.filter((f) => f.tool === "OPA");
  const others = rest.filter((f) => f.tool !== "OPA");
  md.push(`<details><summary>Не блокируют: ${rest.length} (наши правила: ${ours.length}, Checkov/Trivy/TFLint: ${others.length})</summary>\n`);
  md.push(head);
  for (const f of rest.slice(0, 150)) md.push(row(f));
  if (rest.length > 150) md.push(`\n…и ещё ${rest.length - 150}, полный список — в артефакте iac-results.`);
  md.push("\n</details>\n");
}

if (suppressed.length) {
  md.push(`<details><summary>Применённые исключения: ${suppressed.length}</summary>\n`);
  md.push("| Правило | Ресурс | Обоснование | Владелец | До |\n|---|---|---|---|---|");
  for (const s of suppressed) md.push(`| \`${s.rule}\` | ${s.address || s.file} | ${s.exception.reason} | ${s.exception.owner} | ${s.exception.expires} |`);
  md.push("\n</details>\n");
}

const plan = read("plan.txt", "");
if (plan) {
  const summary = (plan.match(/^(Plan:.*|No changes\..*)$/m) || [""])[0];
  md.push(`<details><summary>План изменений: ${summary || "см. журнал"}</summary>\n\n\`\`\`diff`);
  const body = plan.split("\n").map((l) => l.replace(/^(\s*)([+~-]|-\/\+)\s/, (m, sp, s) => `${s === "~" ? "!" : s[0]}${sp} `));
  md.push(body.slice(0, 400).join("\n"));
  if (body.length > 400) md.push(`… план обрезан (${body.length} строк), полный — в артефакте`);
  md.push("```\n</details>\n");
}

const dur = process.env.PIPELINE_SECONDS ? ` · проверка заняла ${Math.round(process.env.PIPELINE_SECONDS)} с` : "";
md.push(`<sub>Правила: OPA/Conftest (\`policies/\`), Checkov, Trivy, TFLint · коммит ${sha.slice(0, 7)}${dur}</sub>`);

fs.writeFileSync(outFile, md.join("\n"));
fs.writeFileSync(path.join(inDir, "summary.json"), JSON.stringify({ verdict, blocking: blocking.length, findings: findings.length, suppressed: suppressed.length, failedSteps }, null, 2));
console.log(`${verdict ? "PASS" : "BLOCK"}: блокирующих ${blocking.length}, всего ${findings.length}, исключений ${suppressed.length}, шагов с ошибкой ${failedSteps.length}`);
process.exit(verdict ? 0 : 1);
