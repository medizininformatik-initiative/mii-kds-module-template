// IG Publisher 3.0.5+ stops a local (non-ci-build) run when the IG template
// runs scripts and is not trusted. The MII IG template does (it ships .js
// assets and a scripts/ folder), so the FHIR settings file the build workflows
// pass (.github/fhir-settings.json) lists it under trustedTemplates.
//
// The publisher trusts a template by what ig.ini's `template =` names, without
// a #version (TemplateManager.trustId): the repository URL, `#ig-template`,
// or the package id. This test keeps that list matching ig.ini, so switching
// the template form (docs/recipes/switch-template-to-published.md) cannot
// silently break the build. Older publishers ignore the key.
//
// Run with:  node --test scripts/template-trust.test.mjs
import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const repository = fileURLToPath(new URL("../", import.meta.url));
const read = (relativePath) => readFileSync(`${repository}${relativePath}`, "utf8");

/** The id the IG Publisher trusts a template by: its reference without #version. */
export function trustId(template) {
  if (template.startsWith("#") || !template.includes("#")) return template;
  return template.slice(0, template.indexOf("#"));
}

/** The `template =` value of an ig.ini (comment lines start with `;`). */
export function igIniTemplate(text) {
  const match = text.match(/^[ \t]*template[ \t]*=[ \t]*(\S+)[ \t]*$/m);
  return match ? match[1] : null;
}

test("trustId drops the version of a package reference only", () => {
  assert.equal(trustId("https://github.com/medizininformatik-initiative/ig-template-mii-kds"), "https://github.com/medizininformatik-initiative/ig-template-mii-kds");
  assert.equal(trustId("#ig-template"), "#ig-template");
  assert.equal(trustId("de.medizininformatikinitiative.template#0.1.0"), "de.medizininformatikinitiative.template");
});

test("the template ig.ini names is trusted in .github/fhir-settings.json", () => {
  const template = igIniTemplate(read("ig.ini"));
  assert.ok(template, "ig.ini has no `template =` line");
  const settings = JSON.parse(read(".github/fhir-settings.json"));
  const trusted = settings.trustedTemplates ?? [];
  assert.ok(Array.isArray(trusted), "trustedTemplates must be an array");
  assert.ok(
    trusted.includes(trustId(template)),
    `ig.ini uses template = ${template}; add "${trustId(template)}" to trustedTemplates in .github/fhir-settings.json`,
  );
});

test("fhir-settings.json does not trust every template", () => {
  const settings = JSON.parse(read(".github/fhir-settings.json"));
  assert.ok(!(settings.trustedTemplates ?? []).includes("all"), 'trust the MII template by name, never "all"');
});
