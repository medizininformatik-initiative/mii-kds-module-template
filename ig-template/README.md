# `ig-template/` — vendored IG template (development mirror)

A **vendored mirror** of the MII IG-Publisher template package
`de.medizininformatikinitiative.template` (version `1.3.4`), copied from
<file:///private/tmp/claude-503/-Users-marcel-Development-cross-hub-patientportal/e2e22580-543a-4bf5-88cc-83677866f38a/scratchpad/mii-igtpl>
at commit `1aeb9d161d003bf11ae0496f73d10ff2218f8f12`.

**Do not edit these files here.** The single source of truth is the
`ig-template-mii-kds` repository; local edits would silently drift and be
overwritten by the next sync.

## Why a mirror, and how it stays current

The template package is not published to a FHIR package registry yet, so
`ig.ini` defaults to the template repository's URL (fetched at build time)
and this folder is the OFFLINE/REPRODUCIBILITY FALLBACK, referenced as
`template = #ig-template`. To keep the fallback in step with the CURRENT
template, the mirror is refreshed by `scripts/sync-ig-template.sh`:

- `scripts/sync-ig-template.sh` — re-vendor from `dev` (default).
- `scripts/sync-ig-template.sh --check` — fail if the mirror has drifted (run in CI).
- `.github/workflows/sync-ig-template.yml` — scheduled + manual; opens a PR when
  the template repo has moved on.

Once the package is published to a registry, switch `ig.ini` to the pinned
package and delete this folder — see
[`docs/recipes/switch-template-to-published.md`](../docs/recipes/switch-template-to-published.md).

<!-- PREVIEW-ONLY: revert before merge — this mirror was vendored from the
     local feat/instance-validation branch of ig-template-mii-kds (not `dev`)
     so the branch preview shows the integrated Validate-an-instance page;
     re-sync from `dev` (scripts/sync-ig-template.sh) once that branch is
     merged. -->
