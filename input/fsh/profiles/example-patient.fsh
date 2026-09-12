// ─────────────────────────────────────────────────────────────────────────────
// STARTER EXAMPLE — replace this with your module's real profiles.
//
// This is the one worked example the template ships so that a newly created
// module builds a non-empty, rendered IG on the very first run. It is a
// deliberately minimal FHIR profile: it only constrains cardinalities and marks
// a few elements as Must-Support, and it binds to NO external value set, so it
// validates without a terminology server and builds cleanly on the tx.fhir.org
// fallback. Delete it once your own profiles exist.
//
// Naming: the MII convention is MII_PR_<Module>_<Name> (see input/fsh/README.md
// and the meta-wiki page "Namenskonventionen für FHIR-Ressourcen in der MII").
// This starter uses a neutral `Example…` name on purpose — rename it to the MII
// pattern for a real module (e.g. `MII_PR_Person_Patient`). The template's CI
// self-check does NOT rewrite FSH, so the names here are literal.
//
// Language: Title and Description are authored in ENGLISH, the IG's default
// language (`i18n-default-lang: en` in sushi-config.yaml). German is supplied
// additively as a de-DE `translation` extension via the `Translation` RuleSet —
// the same mechanism kerndatensatz-basis uses for conformance-resource content.
// (The narrative PAGES are translated differently, under input/translations/de/.)
//
// What that actually RENDERS (observed on the built /de/ tree, publisher 2.2.11):
// the German `^description` appears only on the artifact's OWN page; the German
// `^title` does not appear anywhere, and the artifacts index and table of
// contents keep the English title and description. The extension is still worth
// carrying — it ships the German text inside the package for consumers — but do
// not expect the German site to be fully German. See
// docs/recipes/add-translation.md §4.
//
// The `insert` block below is the shared metadata every MII conformance resource
// carries — see input/fsh/rulesets/README.md. Copy it verbatim onto each new
// profile; that is what keeps a module's artifacts consistent with each other and
// with the rest of the MII core data set.
// ─────────────────────────────────────────────────────────────────────────────
Profile: ExamplePatient
Parent: Patient
Id: example-patient
Title: "Example Patient — template starter"
Description: "Minimal example profile shipped with the template so that a newly created module renders a complete IG immediately. Not an MII artifact — replace it with your module's profiles."
* insert Translation(^title, de-DE, Beispiel-Patient — Vorlagenbeispiel)
* insert Translation(^description, de-DE, Minimales Beispielprofil\, das nur mit der Vorlage ausgeliefert wird\, damit ein neu erstelltes Modul sofort eine gerenderte IG erzeugt. Kein MII-Artefakt — ersetzen Sie es durch die Profile Ihres Moduls.)
// ── Shared MII metadata (input/fsh/rulesets/) ────────────────────────────────
* insert PR_CS_VS_Version
* insert Publisher
* insert LicenseCodeableCCBY40
* insert CRMIShareableStructureDefinition
* insert CRMIPublishableStructureDefinition
* insert CRMIKnowledgeCapabilitiesStructureDefinition
* insert CRMIVersionPolicyStrict
* insert CRMIPackageSourceDefinitionalResource
* insert CRMIArtifactUsageProfile
* insert CRMIApprovalDate({{APPROVAL_DATE}})
* insert CRMIResourceEffectivePeriod
* insert CRMIArtifactTopic(0, http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl, {{TOPIC_NCI_CODE}})
* insert CRMIArtifactContributors
* ^status = #active
* ^experimental = false
// Keep at least one identifying element required + Must-Support so the profile
// is meaningful; add your module's real constraints below.
* name 1..* MS
* name.family 1..1 MS
* birthDate 0..1 MS
* gender 0..1 MS
