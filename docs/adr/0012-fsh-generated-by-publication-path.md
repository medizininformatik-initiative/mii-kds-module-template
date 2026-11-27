# 0012. fsh-generated is committed only where Simplifier builds the package

- Status: Accepted (transitional)
- Date: 2026-11-27

## Context

`ci_dotnet_validation.yml` committed `fsh-generated/resources` to every pull-request branch. Simplifier Bake modules need that, because Simplifier builds from the repository; IG Publisher modules do not, and carried up to 641 generated files with merge conflicts and unverified commits. Their Simplifier projects are used historically.

## Decision

- The commit is switchable: input `COMMIT_GENERATED`, repo variable `COMMIT_FSH_GENERATED` (default on).
- The rollout sets the variable explicitly in every module: `true` for Bake modules, `false` for IG Publisher modules, which also drop `fsh-generated/` from their working branches. A later release may then switch the default off without affecting anyone.
- IG Publisher modules get **no mirror**. Their Simplifier projects stay frozen as historical state with a notice: current versions are built with the IG Publisher and temporarily published on GitHub Pages; the package source sentence `{{PAKETQUELLE}}` is filled per module from its publication path; the permanent location is still to be decided.
- A module that keeps using its Simplifier project may adopt the `kerndatensatz-meta` pattern (orphan branch `fsh-generated`), as its own decision.

## Consequences

- No auto-commits and fewer conflicts in IG Publisher modules.
- Module owners add the notice in their Simplifier projects by hand.

## Evidence

[#72](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/72), [#76](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/76); `kerndatensatz-meta` `publish-fsh-generated.yml` (orphan branch, transitional).

## Revisit when

The permanent publication location is decided (update the notices), or the last Bake module switches (switch the default off).
