# 0004. Modules reference the IG template by URL, with a vendored fallback

- Status: Accepted (transitional)
- Date: 2026-08-28

## Context

Modules need the MII IG template (`ig-template-mii-kds`). Publishing it as a FHIR package and registering it is a public commitment that is hard to retract and implies an owner; ownership moves from the MII to NUM-DIZ on 2027-01-01 (`docs/org-move.md`).

## Decision

- `ig.ini` references the template **by repository URL** (`template = https://github.com/medizininformatik-initiative/ig-template-mii-kds`); the IG Publisher fetches the released `main` at build time. This is the one sanctioned exception to "fixed versions only".
- The vendored `ig-template/` (`template = #ig-template`) stays as offline/reproducibility fallback, synced by `scripts/sync-ig-template.sh`, which copies `package/`, `includes/`, `content/`, `translations/` and `layouts/`.
- Publishing the template as a package (`de.medizininformatikinitiative.template#<version>`) is deferred (issue #1, #2).

## Consequences

- A template release reaches every URL-referencing module on its next build: fast (1.4.0 reached 15 guides at once), but a broken release breaks them all at once.
- Follow-up: test template releases against **all** modules before release (testing against one module alone is not enough).

## Evidence

URL default since [#14](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/14); `layouts/` in the sync since [#71](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/71); trust entries [#61](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/61).

## Revisit when

NUM-DIZ ownership is settled (at the latest January 2027), or a template release breaks module builds for the first time.
