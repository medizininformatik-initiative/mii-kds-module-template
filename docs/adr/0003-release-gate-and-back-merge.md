# 0003. Release gate dev → main and back-merge (template repositories)

- Status: Accepted
- Date: 2026-08-05

## Context

Both template repositories release from `main` and integrate on `dev`. Release Please commits its release on `main`, so `main` gets ahead of `dev` after every release.

## Decision

- Work happens on short-lived `fix/*`, `feature/*`, `change/*` branches off `dev`, squash-merged into `dev` after green CI and human review.
- `dev` → `main` is the release gate: a human decision, merged as a **merge commit**.
- **Back-merge:** anything on `main` that is not on `dev` (at least the release commit) is merged back into `dev` before the next release.
- This applies to the **template repositories only**. The KDS modules keep their own development strategies (`main`/`master`/`develop`/`dev/v2027`, release branches); the pipeline works with any of them.

## Consequences

- `dev` carries the released version numbers, so vendored mirrors and Release Please see the right state.
- A branching model for modules would be a separate decision, if ever.

## Evidence

Back-merge rule since [#76](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/76); applied for 1.4.0 ([#42](https://github.com/medizininformatik-initiative/ig-template-mii-kds/pull/42)) and 0.14.0 ([#79](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/79)).

## Revisit when

The template moves to a different release mechanism.
