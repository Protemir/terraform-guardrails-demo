#!/usr/bin/env node
// Обновляет таблицы входов и выходов в modules/*/README.md (между маркерами BEGIN_TF_DOCS / END_TF_DOCS).
import fs from "node:fs";

const blocks = (src, kind) => {
  const out = [];
  const re = new RegExp(`^${kind} "([^"]+)" \\{`, "gm");
  let m;
  while ((m = re.exec(src))) {
    let depth = 0, i = m.index;
    for (; i < src.length; i++) {
      if (src[i] === "{") depth++;
      else if (src[i] === "}" && --depth === 0) break;
    }
    const body = src.slice(m.index, i + 1);
    const desc = (body.match(/description\s*=\s*"((?:[^"\\]|\\.)*)"/) || [])[1] || "";
    const typeM = body.match(/\n  type\s*=\s*([\s\S]*?)\n(?:  (?:default|description|sensitive|ephemeral|validation|nullable)|\})/);
    const type = typeM ? typeM[1].trim().replace(/\s+/g, " ") : "";
    const defM = body.match(/\n  default\s*=\s*([\s\S]*?)\n  (?:[a-z_]+\s*=|validation|\})/) || body.match(/\n  default\s*=\s*(.*)\n/);
    const sensitive = /\n  (sensitive|ephemeral)\s*=\s*true/.test(body);
    out.push({ name: m[1], desc, type, def: defM ? defM[1].trim().replace(/\s+/g, " ") : null, sensitive });
  }
  return out;
};

for (const mod of fs.readdirSync("modules")) {
  const dir = `modules/${mod}`;
  const readme = `${dir}/README.md`;
  if (!fs.existsSync(readme)) continue;
  const vars = blocks(fs.readFileSync(`${dir}/variables.tf`, "utf8"), "variable");
  const outs = blocks(fs.readFileSync(`${dir}/outputs.tf`, "utf8"), "output");
  const esc = (s) => String(s).replace(/\|/g, "\\|").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  const t = [];
  t.push("### Входы\n");
  t.push("| Имя | Описание | Тип | По умолчанию |\n|---|---|---|---|");
  for (const v of vars) {
    const def = v.def === null ? "**обязательный**" : `\`${esc(v.def.length > 60 ? v.def.slice(0, 57) + "…" : v.def)}\``;
    t.push(`| \`${v.name}\` | ${esc(v.desc)}${v.sensitive ? " 🔒" : ""} | \`${esc(v.type.length > 50 ? v.type.split("(")[0] + "(…)" : v.type)}\` | ${def} |`);
  }
  t.push("\n### Выходы\n");
  t.push("| Имя | Описание |\n|---|---|");
  for (const o of outs) t.push(`| \`${o.name}\` | ${esc(o.desc)} |`);
  const src = fs.readFileSync(readme, "utf8");
  const next = src.replace(/<!-- BEGIN_TF_DOCS -->[\s\S]*<!-- END_TF_DOCS -->/, `<!-- BEGIN_TF_DOCS -->\n${t.join("\n")}\n<!-- END_TF_DOCS -->`);
  fs.writeFileSync(readme, next);
  console.log(`${readme}: ${vars.length} входов, ${outs.length} выходов`);
}
