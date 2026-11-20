#!/usr/bin/env node
// Собирает docs/RULES.md из метаданных правил (policies/rules/*.rego) и примеров (policies/examples).
import fs from "node:fs";

const rulesDir = "policies/rules";
const exDir = "policies/examples";
const sevRu = { critical: "критично", high: "высокий", medium: "средний", low: "низкий" };

const rules = fs.readdirSync(rulesDir).filter((f) => f.endsWith(".rego")).sort().map((f) => {
  const src = fs.readFileSync(`${rulesDir}/${f}`, "utf8");
  const meta = src.match(/meta := \{([\s\S]*?)\n\}/)[1];
  const get = (k) => (meta.match(new RegExp(`"${k}":\\s*"((?:[^"\\\\]|\\\\.)*)"`)) || [])[1]?.replace(/\\"/g, '"') || "";
  return { file: f, id: get("id"), severity: get("severity"), cls: get("class"), title: get("title"), description: get("description"), fix: get("fix") };
});

// Первый блок bad_* из примера — как «пример нарушения».
function badExample(id) {
  const tf = `${exDir}/${id}.tf`;
  const yml = `${exDir}/${id}.exceptions.yaml`;
  if (fs.existsSync(yml)) {
    const t = fs.readFileSync(yml, "utf8").split("\n");
    const start = t.findIndex((l) => /bad_/.test(l)) - 2;
    return { lang: "yaml", code: ["exceptions:", ...t.slice(Math.max(start, 1), start + 6)].join("\n") };
  }
  const lines = fs.readFileSync(tf, "utf8").split("\n");
  const start = lines.findIndex((l) => /^(resource|module) "[^"]*" ?"?bad_|^terraform \{/.test(l));
  if (start < 0) return null;
  let end = start;
  while (end < lines.length && lines[end] !== "}") end++;
  return { lang: "hcl", code: lines.slice(start, end + 1).join("\n") };
}

const order = ["Публичный доступ", "Шифрование", "Избыточные права", "Журналирование", "Ограничения ресурсов", "Обязательные метки", "Именование", "Версии и источники модулей", "Резервное копирование", "Исключения"];
const classes = [...new Set(rules.map((r) => r.cls))].sort((a, b) => (order.indexOf(a) + 1 || 99) - (order.indexOf(b) + 1 || 99));
const out = [];
out.push("# Каталог правил");
out.push("");
out.push(`Пакет: **${rules.length} правил** на Rego (OPA/Conftest) поверх JSON-плана Terraform/OpenTofu и HCL. Файл генерируется командой \`node ci/gen-rules-doc.mjs\`, CI проверяет, что он актуален.`);
out.push("");
out.push("Уровень **критично** блокирует слияние pull request. Остальные уровни попадают в комментарий и не блокируют. Дополнительно работают встроенные проверки Checkov и Trivy (блокирующие из них — в `ci/checkov-critical.txt` и уровень CRITICAL у Trivy).");
out.push("");
out.push("| Класс | Правил | Критичных |\n|---|---|---|");
for (const c of classes) {
  const rs = rules.filter((r) => r.cls === c);
  out.push(`| ${c} | ${rs.length} | ${rs.filter((r) => r.severity === "critical").length} |`);
}
out.push("");
out.push("| ID | Уровень | Правило |\n|---|---|---|");
for (const r of classes.flatMap((c) => rules.filter((x) => x.cls === c))) out.push(`| [${r.id}](#${r.id.toLowerCase()}) | ${sevRu[r.severity] || r.severity} | ${r.title} |`);
out.push("");

for (const c of classes) {
  out.push(`## ${c}`);
  out.push("");
  for (const r of rules.filter((x) => x.cls === c)) {
    out.push(`### ${r.id}`);
    out.push("");
    out.push(`**${r.title}** · уровень: ${sevRu[r.severity] || r.severity} · [policies/rules/${r.file}](../policies/rules/${r.file})`);
    out.push("");
    out.push(r.description);
    out.push("");
    out.push(`Как исправить: ${r.fix}`);
    out.push("");
    const ex = badExample(r.id);
    if (ex) {
      out.push(`Пример нарушения ([все примеры](../policies/examples/${r.id}.tf)):`);
      out.push("");
      out.push("```" + ex.lang);
      out.push(ex.code);
      out.push("```");
      out.push("");
    }
  }
}

fs.mkdirSync("docs", { recursive: true });
fs.writeFileSync("docs/RULES.md", out.join("\n"));
console.log(`docs/RULES.md: ${rules.length} правил, ${classes.length} классов`);
