# 0002. Two release systems: SemVer for the templates, CalVer for the modules

- Status: Accepted
- Date: 2026-07-21

## Context

The template repositories are tooling; the KDS modules are specifications released on the MII release plan: the `YYYY` generation is finalised between October and December and decided in December. Pre-release labels in published module versions have grown inconsistent (`ballot`, `ballot.1`, `ballot2`, `ballot.rc1`, `rc.1`, `rc-1`, `ci`, `alpha.5`). Package registries and tools order pre-releases by SemVer precedence, which several of these forms violate.

## Decision

- **Templates** (`mii-kds-module-template`, `ig-template-mii-kds`) release with **SemVer** through Release Please on `main`.
- **Modules** release with **CalVer `YYYY.MINOR.PATCH`** through the MII Module Release Workflow, following the MII release plan and the MII guidelines. The first-run bootstrap removes the Release Please files from a created module; the two systems never mix.
- **Pre-release suffixes for modules:** `-alpha.N` → `-ballot.N` → `-rc.N` → no suffix, each numbered `.N` from 1, no combinations.
  - `alpha` covers working versions, including candidates before the ballot (formerly `ballot.rc…`); `ballot` is the version under comment; `rc` is the release candidate for the December decision.
  - This order is also their SemVer order, so registries sort them chronologically. Measured counter-examples: `ballot.rc1` sorts after `ballot`; `ballot.rc.1` after `ballot.1`; `ballot10` before `ballot2`; `rc.2` before `rc-1`.
- Convention check M6 keeps accepting any suffix (published versions cannot be renamed); a later version may warn on suffixes outside the recommended form.

## Consequences

- New module versions sort correctly everywhere; old ones stay as published.
- The suffix rule also belongs in the MII guidelines (follow-up).

## Evidence

Release Please since [#2](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/2); M6 since [#39](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/39), prerelease suffixes since [#25](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/25); ordering measured on 2026-11-27 with the SemVer 2.0 precedence rules.

## Revisit when

The MII guidelines define a different suffix scheme, or the release plan changes.
