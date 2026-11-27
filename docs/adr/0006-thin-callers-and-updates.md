# 0006. Modules use thin callers of reusable workflows

- Status: Accepted
- Date: 2026-11-27

## Context

Build, release and publication workflows were copied into each module once and drifted: `ig-publisher.yml` differed by up to 149 lines, `go-publish.yml` by 25–65 lines in every module, and template fixes never reached modules. Copy-and-sync was considered and rejected: every local edit becomes a sync conflict.

## Decision

- The template offers the build as a reusable workflow (`ci_build.yml`); release and publication follow. A module keeps only short callers pinned to a commit SHA **of a release tag**, with the version as trailing comment.
- Module specifics enter through inputs (`pre-sushi-command`, `pre-publisher-command`, `post-build-command`, an optional FHIR package cache); module-specific workflows stay in the module.
- **Updates through Dependabot** (`github-actions` ecosystem) with an **own group** for `medizininformatik-initiative/mii-kds-module-template*`, so each template release becomes one pull request per module, carrying its release notes, separate from other action updates. Dependabot keeps one open pull request per group and replaces it when a newer release appears.
- **Complete release notes:** `release-please-config.json` lists `changelog-sections` so that `chore(deps)`, `ci` and `docs` appear (v0.14.0 dropped 10 of 27 changes, including the IG Publisher 3.0.7 bump); pull-request titles in this repository are checked for Conventional Commits; changes that require action in a module carry a `BREAKING CHANGE:` footer with the instruction.
- **Visibility:** `kerndatensatz-complete` shows each module's template pin and flags modules that are behind; modules show a template-status badge and workflow-status badges.

## Consequences

- An update is a reviewed one-line pin bump instead of a merge of hundreds of lines.
- Dependabot pauses in repositories whose update pull requests are ignored for long; the status in complete makes such modules visible.
- Large jumps across several releases bring all breaking changes at once; the release notes and a Zulip announcement cover them.

## Evidence

[#80](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/80); Phase-1 test on `kerndatensatzmodul-seltene-erkrankungen` (ig-publisher.yml 531 → 41 lines, build green with IG Publisher 3.0.7); v0.14.0 release notes amended on 2026-11-27.

## Revisit when

The reusable workflows cannot express a module's needs without many inputs, or GitHub changes how reusable workflows and Dependabot interact.
