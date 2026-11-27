// sync-scripts.test.mjs — the template tooling sync must detect drift, repair
// it, leave template-only and module-local files alone, and be a no-op inside
// the template repository itself.
import { test } from "node:test";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, existsSync, cpSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(here, "..");
const sh = (args, cwd, env = {}) =>
  execFileSync("bash", [join(cwd, "scripts/sync-scripts.sh"), ...args], {
    cwd, env: { ...process.env, ...env }, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"],
  });
const git = (args, cwd) => execFileSync("git", args, { cwd, encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] });

// A throw-away "template" (this repo's scripts/ as a bare-ish git source) and a
// "module" that holds a copy of it. Nothing touches the real repository.
function fixture() {
  const root = mkdtempSync(join(tmpdir(), "sync-scripts-"));
  const src = join(root, "template"); mkdirSync(src);
  cpSync(join(repoRoot, "scripts"), join(src, "scripts"), { recursive: true });
  git(["init", "-q", "-b", "main"], src);
  git(["-c", "user.name=t", "-c", "user.email=t@t", "add", "."], src);
  git(["-c", "user.name=t", "-c", "user.email=t@t", "commit", "-q", "-m", "seed"], src);
  const mod = join(root, "module"); mkdirSync(mod);
  cpSync(join(src, "scripts"), join(mod, "scripts"), { recursive: true });
  git(["init", "-q"], mod); // a module without the template's remote → sync runs
  return { root, src, mod };
}

test("a module whose scripts/ equals the template passes --check", () => {
  const { root, src, mod } = fixture();
  const out = sh(["--check"], mod, { SRC_REPO: src });
  assert.match(out, /in sync/);
  rmSync(root, { recursive: true, force: true });
});

test("drift in a propagated script fails --check and is repaired by a write run", () => {
  const { root, src, mod } = fixture();
  const target = join(mod, "scripts/convention-check.mjs");
  writeFileSync(target, readFileSync(target, "utf8") + "\n// local edit\n");
  assert.throws(() => sh(["--check"], mod, { SRC_REPO: src }), (e) => /DRIFTED.*1 file/.test(String(e.stdout)) && /differs: scripts\/convention-check\.mjs/.test(String(e.stdout)));
  const out = sh([], mod, { SRC_REPO: src });
  assert.match(out, /updated: scripts\/convention-check\.mjs/);
  assert.equal(readFileSync(target, "utf8"), readFileSync(join(src, "scripts/convention-check.mjs"), "utf8"));
  assert.ok(existsSync(join(mod, "scripts/.template-sync")));
  assert.match(readFileSync(join(mod, "scripts/.template-sync"), "utf8"), /^source: .*\nref: main\ncommit: [0-9a-f]{40}\n/);
  sh(["--check"], mod, { SRC_REPO: src });
  rmSync(root, { recursive: true, force: true });
});

test("template-only tooling and module-local files are neither checked nor deleted", () => {
  const { root, src, mod } = fixture();
  const selfCheck = join(mod, "scripts/self-check-substitute.sh");
  if (existsSync(selfCheck)) writeFileSync(selfCheck, "# diverged on purpose\n");
  writeFileSync(join(mod, "scripts/module-local-helper.sh"), "#!/usr/bin/env bash\n");
  const out = sh(["--check"], mod, { SRC_REPO: src });
  assert.match(out, /in sync/);
  assert.match(out, /Present locally but not in the template.*module-local-helper\.sh/);
  sh([], mod, { SRC_REPO: src });
  assert.ok(existsSync(join(mod, "scripts/module-local-helper.sh")));
  rmSync(root, { recursive: true, force: true });
});

test("inside the template repository the script is a no-op", () => {
  const { root, src, mod } = fixture();
  git(["remote", "add", "origin", "https://github.com/medizininformatik-initiative/mii-kds-module-template.git"], mod);
  const out = sh(["--check"], mod, { SRC_REPO: src });
  assert.match(out, /template repository itself/);
  rmSync(root, { recursive: true, force: true });
});
