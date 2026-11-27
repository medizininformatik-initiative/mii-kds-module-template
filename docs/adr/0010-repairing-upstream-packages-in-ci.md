# 0010. Upstream packages that are unusable as published are repaired in CI

- Status: Accepted (transitional)
- Date: 2026-11-27

## Context

Some dependency packages cannot be used as published, and the fix is someone else's release. ISiK ships differential-only profiles that SUSHI and the validator cannot load; `de.ihe-d.terminology#3.0.1` contains a packed `.git` directory with duplicate tarball entries, which IG Publisher 3.0.x refuses; through `kerndatensatz.medikation` and `.dokument` it reaches seven BOM modules.

## Decision

- Foreign packages are never changed in a registry. They are repaired only in the CI package cache, explicitly and by name, preferably from the MII `fhir-package-store`.
- Each repair is listed here with its problem, mechanism and exit event:

| Repair | Problem | Mechanism | Remove when |
|---|---|---|---|
| ISiK snapshots | differential-only profiles | `fhir-pkg-tool` before SUSHI (`SNAPSHOT_DEPENDENCIES`); `fhir-package-store` cache for ICU and kardiologie | gematik ships ISiK packages with snapshots |
| IHE-D duplicates | `de.ihe-d.terminology#3.0.1` with duplicate entries and `.git` | pre-install the cleaned copy from `fhir-package-store` (`FHIR_PACKAGES_PREINSTALL`) | IHE-D 4.0.0 is in a registry, medikation and dokument have switched, **and** an ISiK release no longer depends on 3.0.1 |

- A new repair is an amendment to this ADR, not a new ADR.

## Consequences

- Builds keep working while upstream fixes are pending.
- `kerndatensatz-complete` can detect at each BOM update whether a repair is still needed.

## Evidence

[#46](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/46), [#52](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/52), [#80](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/80); IHE-D 4.x assessment of 2026-11-27 (same canonicals, but not in a registry; ISiK 6.0.0 still pulls 3.0.1).

## Revisit when

The exit event of a listed repair has happened.
