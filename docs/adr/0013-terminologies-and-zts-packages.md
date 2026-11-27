# 0013. Terminologies come from SU-TermServ; ZTS packages only as dependencies

- Status: Accepted
- Date: 2026-11-13

## Context

Some FHIR packages exist only on the BfArM ZTS and are downloaded only after accepting BfArM's conditions, which forbid redistribution. The org variable `ZTS_ACCEPTED_DOWNLOAD_CONDITIONS` already lists `kbv.all.terminology.allergyintolerance` (needed by kerndatensatz-basis), without a record of who accepted.

## Decision

- Terminologies, licence-restricted ones in particular, are provided centrally by **SU-TermServ**. Modules and the pipeline do not fetch them as packages and never redistribute them (not in `fhir-package-store`, artifacts or caches).
- The ZTS action installs a package only when a module needs it as a **FHIR dependency** and it exists only on the ZTS.
- Every package in `ZTS_ACCEPTED_DOWNLOAD_CONDITIONS` is an acceptance of BfArM's conditions for the organisation and requires a **decision of the TF KDS**, recorded in a GitHub issue (package, version, reason, date, decision). The existing entry is recorded retroactively.

## Consequences

- Licence obligations stay with one provider.
- Adding a ZTS dependency needs lead time for the TF KDS decision.

## Evidence

[#56](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/56)–[#58](https://github.com/medizininformatik-initiative/mii-kds-module-template/pull/58).

## Revisit when

Comparable structures are established in the NUM (move the decision there).
