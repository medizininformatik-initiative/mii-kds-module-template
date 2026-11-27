# 0007. Fixed toolchain pins; org variables only as a visible switch

- Status: Accepted (transitional)
- Date: 2026-11-27

## Context

The template pins IG Publisher, SUSHI and the Java validator. Org variables (`SUSHI_VERSION`, `JAVA_VALIDATOR_VERSION`) override the template's fallbacks, invisibly: the template promised validator 6.10.4 while every module ran 6.9.11. Org variables are not visible outside the organisation.

## Decision

- The template pins fixed versions (IG Publisher 3.0.7, SUSHI 3.21.1, validator fallback 7.0.8 as of v0.14.0).
- Org variables remain only as a **deliberate switch**, e.g. to move all modules to a new validator at once and back. Every run writes to its job summary which version it used and where it came from (template default or variable). The variables currently set are listed in `docs/workflows.md`.
- The validator moves to 7.x only after a comparison run (6.10.4 vs 7.0.8 per module) and the modules' review of new findings, planned for January 2027; until then `JAVA_VALIDATOR_VERSION` stays at 6.10.4.

## Consequences

- No hidden divergence between what the template says and what runs.
- Changing an org variable needs the documentation updated in the same step.

## Evidence

[#70](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/70); org variables inspected on 2026-11-27.

## Revisit when

After the validator switch: check whether the version variables are still needed; delete them if not.
