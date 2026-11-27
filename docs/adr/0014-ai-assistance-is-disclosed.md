# 0014. AI assistance is disclosed

- Status: Accepted (templates); open (modules)
- Date: 2026-11-26

## Context

The earlier rule required commits, pull requests and files to carry no trace of AI assistance. Reviewers and later maintainers then cannot tell which changes an agent produced.

## Decision

- In both template repositories, commits made with substantial AI assistance carry a trailer naming tool and model, pull requests state it in one line, and the human committer stays author and accountable. Specification content stays free of tool names.
- **Modules: open, to be discussed.** Many module AGENTS.md files still carry the old rule. The maintainers favour disclosure. Until decided, pull requests made by the template team (e.g. the rollout) disclose their own AI assistance and do not change a module's AGENTS.md unasked.

## Consequences

- Provenance is visible in git history.

## Evidence

[#68](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/68), [ig-template-mii-kds#36](https://github.com/medizininformatik-initiative/ig-template-mii-kds/pull/36).

## Revisit when

The module rule is decided.
