# Architecture decision records

Why the template and the module pipeline work the way they do. Format and lifecycle: [ADR 0001](0001-record-architecture-decisions.md). New decisions arrive as pull requests against `dev`.

| ADR | Decision | Status |
|---|---|---|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | Accepted |
| [0002](0002-release-systems-semver-and-calver.md) | Two release systems: SemVer for the templates, CalVer for the modules | Accepted |
| [0003](0003-release-gate-and-back-merge.md) | Release gate dev → main and back-merge (template repositories) | Accepted |
| [0004](0004-ig-template-by-url-with-vendored-fallback.md) | Modules reference the IG template by URL, with a vendored fallback | Accepted (transitional) |
| [0005](0005-reusable-validation-hosted-here.md) | Reusable validation workflows live in the module template | Accepted |
| [0006](0006-thin-callers-and-updates.md) | Modules use thin callers of reusable workflows | Accepted |
| [0007](0007-toolchain-pins-and-org-overrides.md) | Fixed toolchain pins; org variables only as a visible switch | Accepted (transitional) |
| [0008](0008-fhir-settings-completed-at-run-time.md) | FHIR settings are completed at run time | Accepted |
| [0009](0009-su-termserv-access.md) | SU-TermServ access: strict, with a switchable host | Accepted |
| [0010](0010-repairing-upstream-packages-in-ci.md) | Upstream packages that are unusable as published are repaired in CI | Accepted (transitional) |
| [0011](0011-publication-paths.md) | Publication paths are detected from the package | Accepted |
| [0012](0012-fsh-generated-by-publication-path.md) | fsh-generated is committed only where Simplifier builds the package | Accepted (transitional) |
| [0013](0013-terminologies-and-zts-packages.md) | Terminologies come from SU-TermServ; ZTS packages only as dependencies | Accepted |
| [0014](0014-ai-assistance-is-disclosed.md) | AI assistance is disclosed | Accepted (templates); open (modules) |
