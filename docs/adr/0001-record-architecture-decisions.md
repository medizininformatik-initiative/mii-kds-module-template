# 0001. Record architecture decisions

- Status: Accepted
- Date: 2026-11-27

## Context

Decisions about this template and the module pipeline were spread over `docs/maintenance.md` ("decided non-fixes"), `docs/org-move.md` ("Decisions that survive the move"), workflow comments and pull-request descriptions. A maintainer could find *what* the pipeline does, but rarely *why*, or what was rejected.

## Decision

- Architecture decisions are recorded as ADRs in `docs/adr/` of this repository, one decision per file, numbered `NNNN-title.md`, in English.
- Format: Status, Date, Context, Decision, Consequences, **Evidence** (pull requests, issues, runs, measurements) and **Revisit when** (the event that makes the decision worth re-examining).
- ADRs written after the fact carry the date of the original decision and link the change that made it.
- **Lifecycle.** The pull request is the proposal; an ADR is *Accepted* when it is merged after the usual human review. A stop-gap is *Accepted (transitional)* and must have a *Revisit when*. A decision that changes gets a **new** ADR; the old one stays unchanged and is marked *Superseded by NNNN*. Small corrections that do not change the decision are dated entries in an *Amendments* section, with *Last amended* in the header. ADRs carry no version numbers; git history and release tags (`vX.Y.Z:docs/adr/...`) are the versions.
- ADRs stay in this repository only. The first-run bootstrap removes `docs/adr/` from a created module; module documentation links here instead of carrying copies that drift.

## Consequences

- Every decision in this set is findable in one place, with its reasons and its exit condition.
- New decisions about the template or the module pipeline arrive as ADR pull requests against `dev`.
- Decisions about the IG template's design belong to `ig-template-mii-kds` and get their own ADRs there when needed.

## Evidence

Decided in the ADR review of 2026-11-27 (this pull request).

## Revisit when

The team adopts a different decision-record practice.
