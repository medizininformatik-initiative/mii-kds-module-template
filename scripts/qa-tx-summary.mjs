// Condense the IG Publisher's qa-tx.html (the raw log of every
// terminology-server call: request, HTTP headers, full FHIR response) into
// qa-tx.json: one compact entry per call (operation, inputs, result, issues)
// plus counts, without headers and without expansion contents. A 94 MB log
// becomes about 3 MB, small enough for every branch preview.
//
// Usage: node scripts/qa-tx-summary.mjs <qa-tx.html> [qa-tx.json]
//
// ci_build.yml and ig-publisher.yml embed this file verbatim (a module has no
// copy of the template's scripts/); scripts/qa-tx-summary.test.mjs fails when
// an embedded copy drifts from this file.
import { readFileSync, writeFileSync } from "node:fs";
import { argv } from "node:process";

const [input, output = input.replace(/\.html$/, "") + ".json"] = argv.slice(2);
const html = readFileSync(input, "utf8");

const unescape = (s) =>
  s.replace(/&quot;/g, '"').replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&#39;/g, "'").replace(/&amp;/g, "&");

function parseJson(text) {
  const start = text.indexOf("{");
  if (start < 0) return null;
  try {
    return JSON.parse(text.slice(start));
  } catch {
    return null;
  }
}

function params(p) {
  const out = {};
  for (const x of p?.parameter ?? []) {
    const key = Object.keys(x).find((k) => k.startsWith("value"));
    if (key) out[x.name] = x[key];
    else if (x.resource) out[x.name] = x.resource;
  }
  return out;
}

function inputs(req) {
  const p = params(req);
  const i = {};
  const coding = p.coding ?? p.codeableConcept?.coding?.[0];
  if (coding) {
    i.system = coding.system;
    i.code = coding.code;
    if (coding.version) i.version = coding.version;
    if (coding.display) i.display = coding.display;
  }
  for (const k of ["url", "system", "code", "display", "version", "displayLanguage", "filter", "count"]) {
    if (p[k] !== undefined && typeof p[k] !== "object") i[k === "url" ? "valueSet" : k] ??= p[k];
  }
  if (p.valueSet?.url) i.valueSet = p.valueSet.url + (p.valueSet.version ? `|${p.valueSet.version}` : "");
  else if (p.valueSet) i.valueSet = "(inline ValueSet)";
  return i;
}

function issuesOf(oo) {
  return (oo?.issue ?? []).map((x) => ({
    severity: x.severity,
    code: x.code,
    type: x.details?.coding?.[0]?.code,
    text: (x.details?.text ?? x.diagnostics ?? "").slice(0, 300),
  }));
}

function result(res) {
  if (!res) return {};
  if (res.resourceType === "OperationOutcome") return { issues: issuesOf(res) };
  if (res.resourceType === "ValueSet") {
    const e = res.expansion;
    return e ? { total: e.total, contains: e.contains?.length ?? 0 } : { valueSet: res.url };
  }
  if (res.resourceType === "Bundle") return { entries: res.total ?? res.entry?.length ?? 0 };
  if (res.resourceType === "Parameters") {
    const p = params(res);
    const r = {};
    if (p.result !== undefined) r.result = p.result;
    if (p.message) r.message = String(p.message).slice(0, 300);
    if (p.display) r.display = p.display;
    if (p.version) r.version = p.version;
    if (p.issues) r.issues = issuesOf(p.issues);
    const nested = (res.parameter ?? []).filter((x) => x.name === "validation" && x.resource);
    if (nested.length) r.validations = nested.map((n) => result(n.resource));
    return r;
  }
  return { resourceType: res.resourceType };
}

const entries = [];
for (const block of html.split(/<hr\/><a name="l\d+"> <\/a>/).slice(1)) {
  const n = Number(block.match(/<p>#(\d+)<\/p>/)?.[1]);
  const [reqText = "", resText = ""] = [...block.matchAll(/<pre>\n?([\s\S]*?)<\/pre>/g)].map((m) => unescape(m[1]));
  const [, method, url] = reqText.split("\n")[0].match(/^(\w+) (\S+)/) ?? [];
  if (!method) continue;
  let u;
  try {
    u = new URL(url);
  } catch {
    continue;
  }
  const path = u.pathname.replace(/^\/fhir\//, "");
  const op = path.match(/\$[\w-]+/)?.[0] ?? `${method} ${path.split("/")[0]}`;
  const entry = { n, op, status: Number(resText.split("\n")[0]) || null };
  if (method === "GET" && u.search.length > 1) entry.query = decodeURIComponent(u.search.slice(1)).slice(0, 300);
  const req = parseJson(reqText);
  if (req) entry.in = inputs(req);
  else if (method === "GET" && path.includes("/")) entry.in = { resource: path };
  const out = result(parseJson(resText));
  if (Object.keys(out).length) entry.out = out;
  entries.push(entry);
}

const failed = (c) =>
  (c.status ?? 0) >= 400 ||
  c.out?.result === false ||
  (c.out?.issues ?? []).some((i) => i.severity === "error" || i.severity === "fatal");
const count = (xs, key) => xs.reduce((m, x) => ((m[key(x)] = (m[key(x)] ?? 0) + 1), m), {});
const failures = entries.filter(failed);

const head = {
  source: input.split("/").pop(),
  calls: entries.length,
  byOperation: count(entries, (c) => c.op),
  byStatus: count(entries, (c) => String(c.status)),
  failed: failures.length,
  failedBySystem: Object.fromEntries(
    Object.entries(count(failures, (c) => c.in?.system ?? c.in?.valueSet ?? "(none)")).sort((a, b) => b[1] - a[1]),
  ),
};
// One call per line: greppable, diffable, still valid JSON.
const lines = entries.map((e) => JSON.stringify(e)).join(",\n");
writeFileSync(output, `${JSON.stringify(head, null, 2).slice(0, -2)},\n  "entries": [\n${lines}\n]}\n`);
console.log(`qa-tx: ${head.calls} terminology calls, ${head.failed} failed`);
for (const [system, n] of Object.entries(head.failedBySystem).slice(0, 10)) console.log(`  ${String(n).padStart(6)}  ${system}`);
