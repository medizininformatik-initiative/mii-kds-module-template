// qa-tx-summary.mjs condenses the IG Publisher's terminology log; the build
// workflows embed it verbatim. Run with: node --test scripts/qa-tx-summary.test.mjs
import { test } from "node:test";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { existsSync, mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const repository = fileURLToPath(new URL("../", import.meta.url));
const script = join(repository, "scripts/qa-tx-summary.mjs");

const call = (n, request, status, response) =>
  `<hr/><a name="l${n}"> </a>\n<p>#${n}</p>\n<pre>\n${request}\n</pre>\n<pre>\n${status}\nserver:nginx\n\n${response}\n</pre>\n`;
const q = (o) => JSON.stringify(o).replace(/"/g, "&quot;");

const FIXTURE = [
  call(1, "GET http://127.0.0.1:8090/fhir/metadata HTTP/1.1\nAccept: application/fhir+json", 200, q({ resourceType: "CapabilityStatement" })),
  call(
    2,
    "POST http://127.0.0.1:8090/fhir/CodeSystem/$validate-code? HTTP/1.1\nContent-Type: application/fhir+json\n\n" +
      q({ resourceType: "Parameters", parameter: [{ name: "coding", valueCoding: { system: "http://unitsofmeasure.org", code: "mg" } }] }),
    200,
    q({
      resourceType: "Parameters",
      parameter: [
        { name: "result", valueBoolean: false },
        { name: "message", valueString: "A definition for CodeSystem 'http://unitsofmeasure.org' could not be found" },
      ],
    }),
  ),
  call(
    3,
    "POST http://127.0.0.1:8090/fhir/ValueSet/$expand HTTP/1.1\n\n" +
      q({ resourceType: "Parameters", parameter: [{ name: "url", valueUri: "http://example.org/ValueSet/x" }] }),
    200,
    q({ resourceType: "ValueSet", expansion: { total: 2, contains: [{ code: "a" }, { code: "b" }] } }),
  ),
  call(4, "GET http://127.0.0.1:8090/fhir/ValueSet/missing HTTP/1.1", 404, q({ resourceType: "OperationOutcome", issue: [{ severity: "error", code: "not-found", diagnostics: "gone" }] })),
].join("");

test("condenses the log: counts, failures per system, one entry per call", () => {
  const dir = mkdtempSync(join(tmpdir(), "qa-tx-"));
  writeFileSync(join(dir, "qa-tx.html"), FIXTURE);
  execFileSync(process.execPath, [script, join(dir, "qa-tx.html")], { stdio: "pipe" });
  const out = JSON.parse(readFileSync(join(dir, "qa-tx.json"), "utf8"));

  assert.equal(out.calls, 4);
  assert.deepEqual(out.byOperation, { "GET metadata": 1, "$validate-code": 1, "$expand": 1, "GET ValueSet": 1 });
  assert.deepEqual(out.byStatus, { 200: 3, 404: 1 });
  assert.equal(out.failed, 2);
  assert.deepEqual(out.failedBySystem, { "http://unitsofmeasure.org": 1, "(none)": 1 });

  const [, validate, expand, missing] = out.entries;
  assert.deepEqual(validate.in, { system: "http://unitsofmeasure.org", code: "mg" });
  assert.equal(validate.out.result, false);
  assert.deepEqual(expand.out, { total: 2, contains: 2 }, "expansion contents are not copied");
  assert.deepEqual(missing.in, { resource: "ValueSet/missing" });
  assert.equal(missing.out.issues[0].text, "gone");
  assert.ok(!JSON.stringify(out).includes("nginx"), "HTTP headers are dropped");
});

// The build workflows embed the script in a heredoc; a module has no copy of
// the template's scripts/. Every embedded copy must equal the file.
for (const file of [".github/workflows/ci_build.yml", ".github/workflows/ig-publisher.yml"]) {
  test(`${file} embeds scripts/qa-tx-summary.mjs verbatim`, (t) => {
    const path = join(repository, file);
    if (!existsSync(path)) return t.skip("workflow not present");
    const lines = readFileSync(path, "utf8").split("\n");
    const start = lines.findIndex((l) => l.includes("<<'QA_TX_SUMMARY'"));
    if (start < 0) return t.skip("no embedded copy (thin caller)");
    const end = lines.findIndex((l, i) => i > start && l.trim() === "QA_TX_SUMMARY");
    const indent = lines[end].match(/^ */)[0].length;
    const embedded = lines.slice(start + 1, end).map((l) => l.slice(indent)).join("\n") + "\n";
    assert.equal(embedded, readFileSync(script, "utf8"), `${file} drifted from scripts/qa-tx-summary.mjs`);
  });
}
