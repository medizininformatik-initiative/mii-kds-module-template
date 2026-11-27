# 0005. Reusable validation workflows live in the module template

- Status: Accepted
- Date: 2026-11-02

## Context

`ci_java_validation.yml` and `ci_dotnet_validation.yml` lived in `kerndatensatz-meta` and were called from modules, often as `@master`, a moving target. Fixes for IG-Publisher-based modules (ISiK snapshots, SUSHI in the job, ZTS packages) needed a home that releases.

## Decision

- The reusable validation workflows live here; modules call them pinned to a commit SHA of a release. The inputs and secrets contract stayed unchanged.
- **Now:** the originals in `kerndatensatz-meta` are frozen (header "moved to mii-kds-module-template — do not change"); meta#251 closes with a link to this ADR.
- **After the rollout:** the meta originals are deleted once no module calls them (the module status in `kerndatensatz-complete` shows when).
- **Then:** `ci_java_validation.yml` renames its secret inputs to `SU_TERMSERV_CLIENT_*`, the mapping in `validation.yml` goes, and the org secrets `CDS_DEV_CLIENT_*` are deleted. This is a breaking change and ships in its own release.

## Consequences

- One copy of the validation, released and pinnable.
- Until the cleanup, two names exist for one certificate.

## Evidence

[#44](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/44), [#46](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/46), [#49](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/49), [#52](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/52), [#56](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/56)–[#58](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/58); meta#251.

## Revisit when

All modules call the template copy (then delete the meta originals), and later all modules use thin callers (then rename the secrets).
