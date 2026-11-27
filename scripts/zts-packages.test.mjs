// Tests for .github/actions/zts-packages/zts-packages.sh (issue #55), the
// script behind the ZTS packages action. It runs against a local stand-in for
// the BfArM ZTS and packages.fhir.org, so the tests stay offline and never
// request a real download token (which would accept BfArM's download
// conditions).
//
// Runs via `node --test scripts/*.test.mjs` (convention-check.yml). Needs
// bash, curl, jq, yq and tar, which the ubuntu runners have. A created module
// does not keep the action (first-run-bootstrap.sh removes it), so the tests
// skip there.
import assert from "node:assert/strict";
import { execFile, execFileSync } from "node:child_process";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { createServer } from "node:http";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import test, { after, before } from "node:test";

const repository = fileURLToPath(new URL("../", import.meta.url));
const SCRIPT = join(repository, ".github/actions/zts-packages/zts-packages.sh");
const present = existsSync(SCRIPT);
const skip = present ? false : "the ZTS action is not in this repository (created module)";

const TOKEN = "zts-test-token-6f1c9e";
const KBV = "kbv.all.terminology.allergyintolerance";

const catalog = [
  { name: KBV, packageVersions: ["1.0.0"] },
  { name: "dvmd.kdl.r4", packageVersions: ["2026.0.0"] },
];
// Packages the fake registry knows (dvmd.kdl.r4 is on both, as in reality).
const registry = { "dvmd.kdl.r4": { versions: { "2026.0.0": {} } } };

let server;
let base;
let fixtureDir;
let requests;
const tarballs = {};

function makeTarball(name, version) {
  const dir = mkdtempSync(join(fixtureDir, "pkg-"));
  mkdirSync(join(dir, "package"));
  writeFileSync(join(dir, "package", "package.json"), JSON.stringify({ name, version }));
  const file = join(fixtureDir, `${name}-${version}.tgz`);
  execFileSync("tar", ["-czf", file, "-C", dir, "package"]);
  return readFileSync(file);
}

before(async () => {
  if (!present) return;
  fixtureDir = mkdtempSync(join(tmpdir(), "zts-fixture-"));
  tarballs[`${KBV}/1.0.0`] = makeTarball(KBV, "1.0.0");
  server = createServer((req, res) => {
    let body = "";
    req.on("data", (chunk) => (body += chunk));
    req.on("end", () => {
      requests.push({ method: req.method, url: req.url, body, auth: req.headers.authorization });
      const send = (status, data, type = "application/json") => {
        res.writeHead(status, { "Content-Type": type });
        res.end(data);
      };
      if (req.url === "/zts/packages/catalog") return send(200, JSON.stringify(catalog));
      if (req.method === "POST" && req.url === "/zts/api/generate-token") return send(200, JSON.stringify({ token: TOKEN }));
      const download = req.url.match(/^\/zts\/packages\/([^/]+)\/([^/]+)$/);
      if (download) {
        if (req.headers.authorization !== `Bearer ${TOKEN}`) return send(401, "{}");
        const tgz = tarballs[`${download[1]}/${download[2]}`];
        return tgz ? send(200, tgz, "application/gzip") : send(404, "{}");
      }
      const reg = req.url.match(/^\/registry\/([^/]+)$/);
      if (reg) return registry[reg[1]] ? send(200, JSON.stringify(registry[reg[1]])) : send(404, "{}");
      send(404, "{}");
    });
  });
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  base = `http://127.0.0.1:${server.address().port}`;
});

after(() => {
  server?.close();
  if (fixtureDir) rmSync(fixtureDir, { recursive: true, force: true });
});

// Runs the script in a fresh directory; returns exit code, output and state.
function run({ sushiConfig, accepted = "", packages = "", zts = `${base}/zts`, preinstall = [] } = {}) {
  requests = [];
  const cwd = mkdtempSync(join(tmpdir(), "zts-run-"));
  const cache = join(cwd, "fhir-packages");
  for (const coordinate of preinstall) {
    mkdirSync(join(cache, coordinate, "package"), { recursive: true });
    writeFileSync(join(cache, coordinate, "package", "package.json"), "{}");
  }
  if (sushiConfig !== undefined) writeFileSync(join(cwd, "sushi-config.yaml"), sushiConfig);
  const outputFile = join(cwd, "github-output");
  writeFileSync(outputFile, "");
  const env = {
    PATH: process.env.PATH,
    HOME: cwd,
    TMPDIR: tmpdir(),
    FHIR_PACKAGES_DIR: cache,
    ZTS_BASE_URL: zts,
    ZTS_REGISTRY_URL: `${base}/registry`,
    ZTS_ACCEPTED_DOWNLOAD_CONDITIONS: accepted,
    ZTS_PACKAGES: packages,
    GITHUB_OUTPUT: outputFile,
  };
  return new Promise((resolve) => {
    execFile("bash", [SCRIPT], { cwd, env }, (error, stdout, stderr) => {
      resolve({
        code: error ? error.code : 0,
        out: stdout + stderr,
        installed: (readFileSync(outputFile, "utf8").match(/^installed=(.*)$/m) || [])[1],
        cache,
        requests,
      });
      rmSync(cwd, { recursive: true, force: true, maxRetries: 2 });
    });
  });
}

const deps = (lines) => `id: test\ndependencies:\n${lines.map((l) => `  ${l}`).join("\n")}\n`;

test("no dependencies: no-op without contacting the ZTS", { skip }, async () => {
  const r = await run();
  assert.equal(r.code, 0, r.out);
  assert.equal(r.installed, "");
  assert.equal(r.requests.length, 0);
});

test("registry packages are left alone, even when they are also on the ZTS", { skip }, async () => {
  const r = await run({ sushiConfig: deps(["de.basisprofil.r4: 1.6.0", "dvmd.kdl.r4: 2026.0.0"]) });
  assert.equal(r.code, 0, r.out);
  assert.equal(r.installed, "");
  assert.ok(!r.requests.some((q) => q.url.includes("generate-token")), "no token for registry packages");
});

test("a ZTS-only dependency without accepted conditions fails with a clear message", { skip }, async () => {
  const r = await run({ sushiConfig: deps([`${KBV}: 1.0.0`]) });
  assert.equal(r.code, 1);
  assert.match(r.out, new RegExp(`::error::${KBV}#1\\.0\\.0 is available only on the BfArM ZTS`));
  assert.match(r.out, /ZTS_ACCEPTED_DOWNLOAD_CONDITIONS/);
  assert.ok(!r.requests.some((q) => q.url.includes("generate-token")), "no token without acceptance");
});

test("a version the ZTS does not have fails", { skip }, async () => {
  const r = await run({ sushiConfig: deps([`${KBV}: 9.9.9`]), accepted: KBV });
  assert.equal(r.code, 1);
  assert.match(r.out, /only in version\(s\): 1\.0\.0/);
});

test("an accepted ZTS-only dependency is installed into the package cache", { skip }, async () => {
  const r = await run({ sushiConfig: deps(["dvmd.kdl.r4: 2026.0.0", `${KBV}:`, "  version: 1.0.0"]), accepted: `dvmd.kdl.r4, ${KBV}` });
  assert.equal(r.code, 0, r.out);
  assert.equal(r.installed, `${KBV}#1.0.0`);
  const token = r.requests.find((q) => q.url === "/zts/api/generate-token");
  assert.deepEqual(JSON.parse(token.body), { packages: [KBV] }, "token only for the ZTS-only package");
  assert.ok(r.requests.some((q) => q.url === `/zts/packages/${KBV}/1.0.0` && q.auth === `Bearer ${TOKEN}`));
  assert.ok(!r.out.includes(TOKEN), "the token must never be printed");
});

test("transitive packages come from ZTS_PACKAGES without a sushi-config.yaml", { skip }, async () => {
  const r = await run({ packages: `${KBV}#1.0.0`, accepted: KBV });
  assert.equal(r.code, 0, r.out);
  assert.equal(r.installed, `${KBV}#1.0.0`);
});

test("a package that is already cached is not downloaded again", { skip }, async () => {
  const r = await run({ packages: `${KBV}#1.0.0`, accepted: KBV, preinstall: [`${KBV}#1.0.0`] });
  assert.equal(r.code, 0, r.out);
  assert.equal(r.installed, "");
  assert.ok(!r.requests.some((q) => q.url.includes("generate-token")));
});

test("malformed ZTS_PACKAGES entries fail", { skip }, async () => {
  const r = await run({ packages: KBV, accepted: KBV });
  assert.equal(r.code, 1);
  assert.match(r.out, /is not of the form name#version/);
});

test("an unreachable ZTS is a warning without accepted conditions, an error with them", { skip }, async () => {
  const down = "http://127.0.0.1:9/zts";
  const quiet = await run({ sushiConfig: deps([`${KBV}: 1.0.0`]), zts: down });
  assert.equal(quiet.code, 0, quiet.out);
  assert.match(quiet.out, /::warning::The BfArM ZTS catalog could not be fetched/);
  const loud = await run({ sushiConfig: deps([`${KBV}: 1.0.0`]), zts: down, accepted: KBV });
  assert.equal(loud.code, 1);
  assert.match(loud.out, /::error::The BfArM ZTS catalog/);
});
