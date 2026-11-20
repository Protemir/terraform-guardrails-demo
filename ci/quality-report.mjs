#!/usr/bin/env node
// Строит docs/quality-report.md из results/corpus/* (ci/scan-corpus.sh).
import fs from "node:fs";
import path from "node:path";

const dir = "results/corpus";
const work = ".tmp/corpus";
const read = (f, d) => { try { return JSON.parse(fs.readFileSync(path.join(dir, f), "utf8")); } catch { return d; } };
const checkovCritical = new Set(fs.readFileSync("ci/checkov-critical.txt", "utf8").split(/\r?\n/).map((l) => l.replace(/#.*/, "").trim()).filter(Boolean));
const labels = [...new Set(fs.readdirSync(dir).filter((f) => f.endsWith(".meta.json")).map((f) => f.replace(".meta.json", "")))].sort();
const norm = (p) => String(p).replace(/\\/g, "/").replace(/^\/?w\//, "").replace(/^\//, "");

function collect(label) {
  const perFile = new Map();
  const bump = (file, tool, crit, id) => {
    const k = path.basename(norm(file));
    if (!perFile.has(k)) perFile.set(k, { opa: 0, opaCrit: 0, checkov: 0, checkovCrit: 0, trivy: 0, trivyCrit: 0, critIds: [] });
    const r = perFile.get(k);
    r[tool]++;
    if (crit) { r[tool + "Crit"]++; r.critIds.push(`${tool === "opa" ? "" : tool + ":"}${id}`); }
  };
  for (const r of read(`${label}.conftest.json`, [])) {
    for (const x of r.failures || []) bump(r.filename, "opa", true, x.metadata?.rule);
    for (const x of r.warnings || []) bump(r.filename, "opa", false, x.metadata?.rule);
  }
  const ck = read(`${label}.checkov.json`, {});
  for (const b of Array.isArray(ck) ? ck : [ck]) for (const c of b?.results?.failed_checks || []) bump(c.file_path, "checkov", checkovCritical.has(c.check_id), c.check_id);
  for (const res of read(`${label}.trivy.json`, {}).Results || []) {
    for (const m of res.Misconfigurations || []) if (m.Status === "FAIL") bump(res.Target, "trivy", m.Severity === "CRITICAL", m.AVDID || m.ID);
  }
  return { perFile, meta: read(`${label}.meta.json`, {}) };
}

const out = [];
const now = new Date().toISOString().slice(0, 10);
out.push("# Отчёт о качестве пакета политик");
out.push("");
out.push(`Дата прогона: ${now}. Команда: \`./ci/scan-corpus.sh\` (её же запускает workflow **corpus**). Инструменты: наши правила Rego через Conftest (OPA), Checkov 3.4.6, Trivy 0.76.2.`);
out.push("");

// ---------- TerraGoat ----------
out.push("## TerraGoat: все ли файлы с намеренными ошибками найдены");
out.push("");
out.push("Критерий ТЗ: «найдены нарушения во всех файлах с намеренными ошибками для AWS, Azure и GCP». Файлом с ошибками считаем каждый `.tf`, где объявлен хотя бы один ресурс (провайдеры, переменные и выходы не в счёт).");
out.push("");
out.push("| Облако | Файлов с ресурсами | Найдено хоть одним инструментом | Нашли наши правила (OPA) | Нарушений OPA (из них критичных) | Checkov | Trivy | Время OPA, с |\n|---|---|---|---|---|---|---|---|");
const misses = [];
const goatRows = [];
for (const cloud of ["aws", "azure", "gcp"]) {
  const label = `terragoat-${cloud}`;
  if (!labels.includes(label)) continue;
  const { perFile, meta } = collect(label);
  const cdir = `${work}/terragoat/terraform/${cloud}`;
  const withRes = fs.readdirSync(cdir).filter((f) => f.endsWith(".tf") && /^resource\s+"/m.test(fs.readFileSync(`${cdir}/${f}`, "utf8")));
  const found = withRes.filter((f) => { const r = perFile.get(f); return r && r.opa + r.checkov + r.trivy > 0; });
  const foundOpa = withRes.filter((f) => perFile.get(f)?.opa > 0);
  const sum = (k) => [...perFile.values()].reduce((a, r) => a + r[k], 0);
  out.push(`| ${cloud.toUpperCase()} | ${withRes.length} | **${found.length}** | ${foundOpa.length} | ${sum("opa")} (${sum("opaCrit")}) | ${sum("checkov")} | ${sum("trivy")} | ${meta.conftest_seconds ?? "?"} |`);
  for (const f of withRes) if (!found.includes(f)) misses.push(`${cloud}/${f}`);
  for (const f of withRes) { const r = perFile.get(f) || {}; goatRows.push(`| ${cloud}/${f} | ${r.opa || 0} | ${r.checkov || 0} | ${r.trivy || 0} |`); }
}
out.push("");
out.push(misses.length ? `Не найдено ни одним инструментом: ${misses.join(", ")}.` : "Нарушения найдены в **каждом** файле с ресурсами.");
out.push("");
out.push("<details><summary>По файлам</summary>\n\n| Файл | OPA | Checkov | Trivy |\n|---|---|---|---|");
out.push(...goatRows);
out.push("\n</details>\n");

// ---------- реестр ----------
out.push("## Модули реестра: ложные срабатывания уровня «критично»");
out.push("");
out.push("Критерий ТЗ: «не более 1 ложного нарушения уровня „критично“ на весь набор». Модули взяты из registry.terraform.io без изменений ([tests/registry/main.tf](../tests/registry/main.tf)); код модулей параметризован, поэтому значения, заданные выражениями, правила пропускают, а не угадывают.");
out.push("");
out.push("| Модуль | Файлов | Критичных OPA | Критичных Checkov* | Критичных Trivy | Всего замечаний (OPA / Checkov / Trivy) |\n|---|---|---|---|---|---|");
const critList = [];
for (const label of labels.filter((l) => l.startsWith("registry-"))) {
  const { perFile, meta } = collect(label);
  const sum = (k) => [...perFile.values()].reduce((a, r) => a + r[k], 0);
  out.push(`| ${label.replace("registry-", "")} | ${meta.files ?? "?"} | ${sum("opaCrit")} | ${sum("checkovCrit")} | ${sum("trivyCrit")} | ${sum("opa")} / ${sum("checkov")} / ${sum("trivy")} |`);
  for (const [f, r] of perFile) for (const id of r.critIds) critList.push(`${label.replace("registry-", "")}/${f}: ${id}`);
}
out.push("");
out.push("\\* критичными у Checkov считаются проверки из [ci/checkov-critical.txt](../ci/checkov-critical.txt), у Trivy — уровень CRITICAL.");
out.push("");
out.push(critList.length ? "Критичные срабатывания для ручного разбора:\n\n" + critList.map((c) => `- ${c}`).join("\n") : "Критичных срабатываний нет.");
out.push("");

fs.mkdirSync("docs", { recursive: true });
fs.writeFileSync("docs/quality-report.md", out.join("\n"));
console.log(out.join("\n"));
