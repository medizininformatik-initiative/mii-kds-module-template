# 0008. FHIR settings are completed at run time

- Status: Accepted
- Date: 2026-11-27

## Context

`fhir-settings.json` is the settings file of the HL7 Java tools (IG Publisher, validator), not a FHIR standard; SUSHI and Firely ignore it. IG Publisher 2.3.1+ refuses the plain-HTTP local SU-TermServ proxy unless allowed, and 3.0.5+ refuses a template with scripts unless it is listed under `trustedTemplates`. Each module's `.github/fhir-settings.json` was copied once: all 22 modules have the proxy entry, only one has `trustedTemplates`.

## Decision

- In CI, a step before each IG Publisher run takes the module's `.github/fhir-settings.json`, **adds** the proxy entry and the two trusted template names (repository URL, `#ig-template`) when missing, keeps everything else, never adds `"all"`, and passes the result from `$RUNNER_TEMP`. Invalid JSON fails the step.
- The future template package id is **not** trusted in advance; a module switching to it adds the entry itself (see ADR 0004).
- For local builds, which pass the repository file directly, the rollout brings the complete file into every module; `scripts/template-trust.test.mjs` keeps it matching `ig.ini`.

## Consequences

- A module with an old, incomplete or missing settings file still builds in CI.
- A module cannot remove the template trust or the proxy entry; it can only add.

## Evidence

[#61](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/61), [#70](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/70); local test with five cases (old, complete, missing, extra entries, invalid JSON).

## Revisit when

Every major IG Publisher version: check the settings keys (new mandatory entries like `trustedTemplates`).
