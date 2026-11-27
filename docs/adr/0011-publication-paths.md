# 0011. Publication paths are detected from the package

- Status: Accepted
- Date: 2026-11-27

## Context

Modules publish in three ways: (1) IG Publisher package through a feed registered in the FHIR registry, (2) Simplifier builds the package (Bake), (3) IG Publisher package uploaded to Simplifier. Only one MII feed is registered in `FHIR/ig-registry`: the basis feed, which also lists soziodemographie; no MII guide is in `fhir-ig-list.json`. Other modules' feeds exist on GitHub Pages but are not registered.

## Decision

- The path is read from the pinned package itself (`.index.json` index-version 2 / `tools-version: 3` = IG Publisher) and from the registered feeds; `kerndatensatz-complete` records it at each BOM update.
- **Direction:** the IG Publisher builds the package (path 1 or 3). The Simplifier Bake is a phase-out path without a fixed date; Bake modules switch when they are touched anyway.
- **Open, for TF KDS / NUM-DIZ:** path 1 or 3, and whether there is one shared MII feed or one per module; whether the basis feed should keep carrying other modules.

## Consequences

- The pipeline supports all three paths for now (`COMMIT_FSH_GENERATED`, `publish-simplifier.yml`, `go-publish.yml`).
- Six of seven Bake modules currently build their guide and their package from two different sources.

## Evidence

[kerndatensatz-complete#4](https://github.com/medizininformatik-initiative/kerndatensatz-complete/pull/4); BOM 2027.0.0-ballot.19: 2 via feed, 12 uploaded, 7 Bake.

## Revisit when

TF KDS / NUM-DIZ decide on registration and the feed model.
