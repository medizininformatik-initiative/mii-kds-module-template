# 0009. SU-TermServ access: strict, with a switchable host

- Status: Accepted
- Date: 2026-11-27

## Context

SU-TermServ requires a client certificate (mTLS); the IG Publisher and the validator reach it through a local nginx proxy. In November 2026 the production server was being reloaded and returned incomplete data: German language codes failed validation and IG Publisher 3.0.7 crashed on value-set expansions. The staging server had the complete 2026 resources.

## Decision

- With a certificate, terminology goes through the proxy; without one, the build falls back to `tx.fhir.org` and the Java validation is skipped.
- **No automatic fallback** when a certificate is present but SU-TermServ fails: a silent switch to `tx.fhir.org` would change QA results without anyone noticing. The proxy step checks `/fhir/metadata` upstream at start and fails within seconds, with the nginx log.
- The upstream host is the variable **`SU_TERMSERV_HOST`** (default `ontoserver.mii-termserv.de`), set at org level and overridable per repository; only a plain host name is accepted. Switching servers is a human decision.

## Consequences

- Failures are visible early instead of as hundreds of QA errors.
- Only workflows that read the variable (`ci_build.yml`, `ci_java_validation.yml` from the rollout on) follow the switch.

## Evidence

[#80](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/80); seltene against staging on 2026-11-27: 126 instead of 828 errors, no expansion crash, certificate accepted; readiness check from [#51](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/51).

## Revisit when

SU-TermServ offers its own health endpoint or the production server is stable again (then reset the variable).
