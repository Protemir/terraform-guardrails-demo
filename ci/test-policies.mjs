#!/usr/bin/env node
// Проверяет каждое правило на его примере policies/examples/<ID>.tf:
//   — каждый ресурс bad_* должен дать находку этого правила;
//   — ни один ресурс good_* не должен её дать.
// Запуск из корня репозитория: node ci/test-policies.mjs
// Без локального conftest: CONFTEST="docker run --rm -v $PWD:/w -w /w openpolicyagent/conftest:v0.71.1" node ci/test-policies.mjs
import fs from "node:fs";
import path from "node:path";
import { execSync } from "node:child_process";

const conftest = process.env.CONFTEST || "conftest";
const dir = "policies/examples";
const tmp = ".tmp";
fs.mkdirSync(tmp, { recursive: true });

const day = 24 * 3600 * 1000;
const relDates = (text) =>
  text.replace(/"([+-]\d+)d"/g, (_, n) => `"${new Date(Date.now() + Number(n) * day).toISOString().slice(0, 10)}"`);

const ids = fs.readdirSync(dir).filter((f) => f.endsWith(".tf")).map((f) => f.slice(0, -3)).sort();
let failed = 0;
const rows = [];

for (const id of ids) {
  const tf = `${dir}/${id}.tf`;
  const excFile = `${dir}/${id}.exceptions.yaml`;
  const args = ["test", "--parser", "hcl2", "-p", "policies", "--data", "policies/config.yaml", "-o", "json", "--no-fail"];
  let source = fs.readFileSync(tf, "utf8");
  if (fs.existsSync(excFile)) {
    const y = relDates(fs.readFileSync(excFile, "utf8"));
    source += y;
    const t = `${tmp}/${id}.exceptions.yaml`;
    fs.writeFileSync(t, y);
    args.push("--data", t);
  }
  args.push(tf);
  const out = execSync(`${conftest} ${args.join(" ")}`, { encoding: "utf8" });
  const results = JSON.parse(out).flatMap((r) => [...(r.failures || []), ...(r.warnings || [])]);
  const mine = results.filter((r) => r.metadata?.rule === id).map((r) => r.msg);

  const bad = [...new Set(source.match(/\bbad_[a-z0-9_]+/g) || [])];
  const good = [...new Set(source.match(/\bgood_[a-z0-9_]+/g) || [])];
  const missed = bad.filter((b) => !mine.some((m) => new RegExp(`\\b${b}\\b`).test(m)));
  const falsePos = good.filter((g) => mine.some((m) => new RegExp(`\\b${g}\\b`).test(m)));
  const ok = missed.length === 0 && falsePos.length === 0 && bad.length > 0;
  if (!ok) failed++;
  rows.push({ id, ok, bad: bad.length, good: good.length, missed, falsePos });
}

for (const r of rows) {
  const extra = r.ok ? "" : `  пропущены: ${r.missed.join(", ") || "—"}; ложные: ${r.falsePos.join(", ") || "—"}`;
  console.log(`${r.ok ? "ok  " : "FAIL"} ${r.id.padEnd(9)} bad=${r.bad} good=${r.good}${extra}`);
}
console.log(`\n${rows.length - failed}/${rows.length} правил прошли проверку на примерах`);
fs.writeFileSync(path.join(tmp, "policy-tests.json"), JSON.stringify(rows, null, 2));
process.exit(failed ? 1 : 0);
