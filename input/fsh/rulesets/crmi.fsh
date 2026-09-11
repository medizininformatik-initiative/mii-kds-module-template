// ─────────────────────────────────────────────────────────────────────────────
// Ported from kerndatensatz-basis (main): input/fsh/rulesets/crmi.fsh
//
// CRMI (Canonical Resource Management Infrastructure) metadata rulesets. The IG
// itself claims the CRMI shareable/publishable/computable ImplementationGuide
// profiles in sushi-config.yaml (`meta.profile`); these rulesets make the
// individual artifacts claim the matching CRMI profiles and carry the same
// metadata. The hl7.fhir.uv.crmi dependency in sushi-config.yaml is what makes
// them resolvable.
//
// Use CARET paths (`^…`) for resources declared with a FSH keyword — Profile,
// Extension, Logical, ValueSet, CodeSystem. Use INSTANCE paths for `InstanceOf:`
// resources such as CapabilityStatement or Parameters; those RuleSets carry the
// `…Instance` suffix.
//
// basis literals replaced by this repository's placeholders:
//   "2019+ Medical Informatics Initiative (MII)" → "{{COPYRIGHT_START_YEAR}}+ …"
//   the basis artifact-author contact email      → {{MODULE_AUTHOR_EMAIL}}
// The approval date and the artifact topic stay RuleSet PARAMETERS (as in
// basis); pass {{APPROVAL_DATE}} / {{TOPIC_NCI_CODE}} at the call site.
// ─────────────────────────────────────────────────────────────────────────────

// ── Resource-independent version policy ──────────────────────────────────────

RuleSet: CRMIVersionPolicyStrict
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/artifact-versionPolicy"
* ^extension[=].valueCodeableConcept = http://terminology.hl7.org/CodeSystem/artifact-version-policy-codes#package "Package"

RuleSet: CRMIVersionPolicyStrictInstance
* extension[+].url = "http://hl7.org/fhir/StructureDefinition/artifact-versionPolicy"
* extension[=].valueCodeableConcept = http://terminology.hl7.org/CodeSystem/artifact-version-policy-codes#package "Package"

// ── Copyright label ──────────────────────────────────────────────────────────
// basis notes that there is currently no resource type in the module where
// artifact-copyrightLabel is useful (and that the R5 cross-version extension is
// preferable where applicable) — the RuleSets are kept so a module that needs
// them does not re-invent the wording.

RuleSet: CRMICopyrightLabel
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/artifact-copyrightLabel"
* ^extension[=].valueString = "{{COPYRIGHT_START_YEAR}}+ Medical Informatics Initiative (MII)"

RuleSet: CRMICopyrightLabelInstance
* extension[+].url = "http://hl7.org/fhir/StructureDefinition/artifact-copyrightLabel"
* extension[=].valueString = "{{COPYRIGHT_START_YEAR}}+ Medical Informatics Initiative (MII)"

// ── Approval date (StructureDefinition, CapabilityStatement, IG) ─────────────
// Call with the module's approval date, e.g. `insert CRMIApprovalDate({{APPROVAL_DATE}})`.

RuleSet: CRMIApprovalDate(approvalDate)
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/resource-approvalDate"
* ^extension[=].valueDate = "{approvalDate}"

RuleSet: CRMIApprovalDateInstance(approvalDate)
* extension[+].url = "http://hl7.org/fhir/StructureDefinition/resource-approvalDate"
* extension[=].valueDate = "{approvalDate}"

// ── Artifact topic (StructureDefinition, CapabilityStatement, IG, CS, VS) ────
// MII codes module topics with the NCI Thesaurus. Call with the system and the
// module's topic code, e.g.
//   insert CRMIArtifactTopic(http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl, {{TOPIC_NCI_CODE}})
// Repeat the insert for each topic of the module.

// ADDRESSED BY URL, not by `^extension[+]`, so that these rule sets also work on
// a profile whose PARENT already carries CRMI metadata on its own root. SUSHI
// copies a parent StructureDefinition's root extensions into the child, so
// `^extension[+]` — which counts against the child's empty DIFFERENTIAL — lands on
// index 0, hits an inherited extension with a different value[x], and fails with
// "contains multiple choice value assignments for choice element
// StructureDefinition.extension.value[x]". Measured on 2026-09-11 against
// de.medizininformatikinitiative.kerndatensatz.laborbefund: a rule-free child of
// mii-pr-labor-laboruntersuchung inherits 14 root extensions, and one insert of
// the old CRMIArtifactTopic broke all 21 profiles of the derived module.
//
// `^extension[<url>][+]` addresses the group of extensions sharing that url, and
// the soft index carries across successive inserts. Measured with identical FSH:
// against a parent WITH two inherited topics it replaces them, against a parent
// WITHOUT topics it creates them — no errors and no null gaps in the array in
// either case. An absolute index is no alternative: it depends on the number of
// inherited entries, which is not readable anywhere (the parent package declares
// 17 where the child shows 14), and too high an index pads the array with nulls.
RuleSet: CRMIArtifactTopic(system, code)
* ^extension[$artifact-topic][+].valueCodeableConcept.coding[0] = {system}#{code}

RuleSet: CRMIArtifactTopicInstance(system, code)
* extension[$artifact-topic][+].valueCodeableConcept.coding[0] = {system}#{code}

// ── Artifact contributors ────────────────────────────────────────────────────
// Author = the module author ({{MODULE_AUTHOR_EMAIL}}). Editor / reviewer /
// endorser are the MII-wide governance bodies and apply to every KDS module —
// the same values sushi-config.yaml sets on the IG resource. Adjust only if your
// module's governance differs.

RuleSet: CRMIArtifactContributors
* ^extension[$artifact-author][+].valueContactDetail.telecom[0].system = #email
* ^extension[$artifact-author][=].valueContactDetail.telecom[0].value = "{{MODULE_AUTHOR_EMAIL}}"
* ^extension[$artifact-editor][+].valueContactDetail.name = "Taskforce Core Data Set"
* ^extension[$artifact-reviewer][+].valueContactDetail.name = "Interoperability Working Group"
* ^extension[$artifact-reviewer][=].valueContactDetail.telecom[0].system = #url
* ^extension[$artifact-reviewer][=].valueContactDetail.telecom[0].value = "https://www.medizininformatik-initiative.de/en/collaboration/interoperability-working-group"
* ^extension[$artifact-reviewer][+].valueContactDetail.name = "National Steering Committee"
* ^extension[$artifact-reviewer][=].valueContactDetail.telecom[0].system = #url
* ^extension[$artifact-reviewer][=].valueContactDetail.telecom[0].value = "https://www.medizininformatik-initiative.de/en/collaboration/national-steering-committee"
* ^extension[$artifact-endorser][+].valueContactDetail.name = "Interoperability Working Group"
* ^extension[$artifact-endorser][=].valueContactDetail.telecom[0].system = #url
* ^extension[$artifact-endorser][=].valueContactDetail.telecom[0].value = "https://www.medizininformatik-initiative.de/en/collaboration/interoperability-working-group"
* ^extension[$artifact-endorser][+].valueContactDetail.name = "National Steering Committee"
* ^extension[$artifact-endorser][=].valueContactDetail.telecom[0].system = #url
* ^extension[$artifact-endorser][=].valueContactDetail.telecom[0].value = "https://www.medizininformatik-initiative.de/en/collaboration/national-steering-committee"

RuleSet: CRMIArtifactContributorsInstance
* extension[$artifact-author][+].valueContactDetail.telecom[0].system = #email
* extension[$artifact-author][=].valueContactDetail.telecom[0].value = "{{MODULE_AUTHOR_EMAIL}}"
* extension[$artifact-editor][+].valueContactDetail.name = "Taskforce Core Data Set"
* extension[$artifact-reviewer][+].valueContactDetail.name = "Interoperability Working Group"
* extension[$artifact-reviewer][=].valueContactDetail.telecom[0].system = #url
* extension[$artifact-reviewer][=].valueContactDetail.telecom[0].value = "https://www.medizininformatik-initiative.de/en/collaboration/interoperability-working-group"
* extension[$artifact-reviewer][+].valueContactDetail.name = "National Steering Committee"
* extension[$artifact-reviewer][=].valueContactDetail.telecom[0].system = #url
* extension[$artifact-reviewer][=].valueContactDetail.telecom[0].value = "https://www.medizininformatik-initiative.de/en/collaboration/national-steering-committee"
* extension[$artifact-endorser][+].valueContactDetail.name = "Interoperability Working Group"
* extension[$artifact-endorser][=].valueContactDetail.telecom[0].system = #url
* extension[$artifact-endorser][=].valueContactDetail.telecom[0].value = "https://www.medizininformatik-initiative.de/en/collaboration/interoperability-working-group"
* extension[$artifact-endorser][+].valueContactDetail.name = "National Steering Committee"
* extension[$artifact-endorser][=].valueContactDetail.telecom[0].system = #url
* extension[$artifact-endorser][=].valueContactDetail.telecom[0].value = "https://www.medizininformatik-initiative.de/en/collaboration/national-steering-committee"

// ── StructureDefinition ──────────────────────────────────────────────────────

RuleSet: CRMIShareableStructureDefinition
* ^meta.profile[+] = "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-shareablestructuredefinition"

RuleSet: CRMIPublishableStructureDefinition
* ^meta.profile[+] = "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-publishablestructuredefinition"

RuleSet: CRMIKnowledgeCapabilitiesStructureDefinition
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/cqf-knowledgeCapability"
* ^extension[=].valueCode = #shareable
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/cqf-knowledgeCapability"
* ^extension[=].valueCode = #publishable

RuleSet: CRMIArtifactUsageLogicalModel
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/artifact-usage"
* ^extension[=].valueMarkdown = "Use this logical model as the module-specific information model for the Medical Informatics Initiative core dataset. The model describes clinically or administratively relevant information in a domain-oriented form and provides a bridge between the conceptual content specification and the corresponding technical FHIR profiles. It is a pattern for describing the intended content model and is not intended to be exchanged as a concrete FHIR resource instance. Implementers should use it to understand the scope, semantics, and structure of the module before applying the related FHIR profiles and mappings."

RuleSet: CRMIArtifactUsageProfile
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/artifact-usage"
* ^extension[=].valueMarkdown = "Use this profile as the technical FHIR representation of the corresponding Medical Informatics Initiative logical model. The profile constrains a base FHIR resource for the MII module context by specifying how elements are used, which elements are required or not used, which extensions and terminology bindings apply, and how the resource maps to the module-specific content model. Implementers should produce and consume resource instances that conform to this profile when exchanging data for the corresponding MII module."

RuleSet: CRMIArtifactUsageExtension
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/artifact-usage"
* ^extension[=].valueMarkdown = "Use this extension to exchange data for content of the corresponding Medical Informatics Initiative logical model that is not represented in the FHIR core resource structure."

// ── CapabilityStatement ──────────────────────────────────────────────────────

RuleSet: CRMIShareableCapabilityStatement
* meta.profile[+] = "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-shareablecapabilitystatement"

RuleSet: CRMIPublishableCapabilityStatement
* meta.profile[+] = "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-publishablecapabilitystatement"

RuleSet: CRMIKnowledgeCapabilitiesCapabilityStatement
* extension[+].url = "http://hl7.org/fhir/StructureDefinition/cqf-knowledgeCapability"
* extension[=].valueCode = #shareable
* extension[+].url = "http://hl7.org/fhir/StructureDefinition/cqf-knowledgeCapability"
* extension[=].valueCode = #publishable

RuleSet: CRMIArtifactUsageCapabilityStatement
* extension[+].url = "http://hl7.org/fhir/StructureDefinition/artifact-usage"
* extension[=].valueMarkdown = "Use this CapabilityStatement to determine the minimum RESTful server capabilities required for a system that implements the corresponding module of the Medical Informatics Initiative core dataset. It lists the FHIR resource types and MII profiles that SHALL be supported, together with required interactions, supported formats, and search parameters for read and search access. Systems claiming conformance to the module are expected to implement the listed capabilities according to the stated conformance expectations."

// ── CodeSystem ───────────────────────────────────────────────────────────────

RuleSet: CRMIShareableCodeSystem
* ^meta.profile[+] = "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-shareablecodesystem"

RuleSet: CRMIPublishableCodeSystem
* ^meta.profile[+] = "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-publishablecodesystem"

RuleSet: CRMIKnowledgeCapabilitiesCodeSystem
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/cqf-knowledgeCapability"
* ^extension[=].valueCode = #shareable
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/cqf-knowledgeCapability"
* ^extension[=].valueCode = #publishable

RuleSet: CRMIKnowledgeCapabilitiesCodeSystemPublishable
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/cqf-knowledgeCapability"
* ^extension[=].valueCode = #publishable

// ── ValueSet ─────────────────────────────────────────────────────────────────

RuleSet: CRMIShareableValueSet
* ^meta.profile[+] = "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-shareablevalueset"

RuleSet: CRMIPublishableValueSet
* ^meta.profile[+] = "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-publishablevalueset"

RuleSet: CRMIComputableValueSet
* ^meta.profile[+] = "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-computablevalueset"

RuleSet: CRMIKnowledgeCapabilitiesValueSet
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/cqf-knowledgeCapability"
* ^extension[=].valueCode = #shareable
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/cqf-knowledgeCapability"
* ^extension[=].valueCode = #publishable
* ^extension[+].url = "http://hl7.org/fhir/StructureDefinition/cqf-knowledgeCapability"
* ^extension[=].valueCode = #computable
