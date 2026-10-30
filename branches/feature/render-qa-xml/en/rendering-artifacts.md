# Rendering Artifacts (demo) - MII Implementation Guide Module Template v2027.0.0-draft.1

* [**Table of Contents**](toc.md)
* **Rendering Artifacts (demo)**

## Rendering Artifacts (demo)

The IG Publisher generates a page for every profile, extension, value set and example in this guide. You do not have to link readers away to them — you can render the parts that matter **inside** a narrative page, next to the prose that explains them.

This page shows a working example of **every directive that runs without error in this scaffold**. Each block gives the source line first, then what it produces. Copy the line, change the artifact name, delete the page.

##### What this page is
A live demonstration shipped with the module scaffold. Read the source of this page next to the rendering, copy what you need, then delete the page.
**The step-by-step version is**
[`docs/recipes/render-existing-artifacts.md`](https://github.com/medizininformatik-initiative/mii-kds-module-template/blob/main/docs/recipes/render-existing-artifacts.md)in this repository. It lists every file to remove when you delete this page.

### 1. Include a generated fragment

During the build the Publisher writes a set of small HTML files — **fragments** — for every artifact in the guide. The artifact pages you already see are built from them, and any narrative page can include the same ones.

The name is always `<ResourceType>-<Id>-<code>.xhtml`, built from the artifact's `Id:`, not from its FSH `Profile:` name. This scaffold's example profile has `Id: example-patient`, so its element dictionary is:

```
{% include StructureDefinition-example-patient-dict-key.xhtml %}
```

Guidance on how to interpret the contents of this table can be found[here](https://build.fhir.org/ig/FHIR/ig-guidance/readingIgs.html#data-dictionaries)

**This build emits 96 fragment codes for this scaffold's two artifacts.** There is no published list that matches — the [IG Publisher documentation](https://confluence.hl7.org/spaces/FHIR/pages/35718627/IG+Publisher+Documentation) says so itself, above its own list: **"Note: as of July 2023, this list is not comprehensive."** The catalogue below was taken from the build, not from a document, and each entry is live. Open one to see its include line and its rendering.

Some are deliberately empty — `history` has nothing to show without Provenance resources, `experimental-warning` nothing unless the artifact is experimental. An empty fragment is not an error.

Four of the 96 are listed with their include line but **without** their rendering. `search-params`, `span`, `spanall` and `pseudo-json` link to targets that only exist in the artifact-page context — the base-spec pages, `formats.html`, or anchors the artifact page defines for itself. Embedded in a narrative page those do not resolve, and the build reports each as a broken link. This is worth knowing generally: a fragment being generated does not guarantee it can be embedded anywhere. If your QA report gains broken links after you include one, this is why.

#### The example profile — 78 codes

#### The example instance — 10 codes

Instances get a much smaller set: the views that only make sense for a **definition** (snapshot, differential, dictionary, invariants) do not exist here.

#### Cross-artifact lists — 8 forms

These are generated per profile rather than per view, and list the examples, test plans and test scripts attached to it.

### 2. Embed part of an example instance

The `{% fragment %}` tag renders an instance held in this guide and can narrow it with FHIRPath, so the reader sees only the element under discussion — useful when an example is long and one field is the point.

The syntax is `[ResourceType]/[id] [format] [filters]`. The format must be one of `json`, `xml`, `ttl` or `fml`; anything else is an error. The id is the instance id, and the resource must exist in this guide.

```
{% fragment Patient/ExamplePatientInstance JSON BASE:name %}
```

The same subtree as XML:

```
{% fragment Patient/ExamplePatientInstance XML BASE:name %}
```

`ttl` and `fml` are accepted by the same check, but neither is demonstrated here. `ttl` parses and then does not render: the Publisher writes its internal object into the page —

```
org.hl7.fhir.utilities.turtle.Turtle@7d4f6072

```

— with no error, no warning and no broken link, so nothing but reading the page catches it. `fml` applies to StructureMaps, and this scaffold has none. Use `json` or `xml`.

Without a filter you get the whole instance. `ELIDE:` replaces a named element with `...` instead of removing it, which keeps the shape of the resource visible while hiding detail:

```
{% fragment Patient/ExamplePatientInstance JSON ELIDE:meta %}
```

There are three filters in total. `BASE:` selects the subtree to show — only one per fragment. `ELIDE:` replaces an element with `...`, and may be repeated. `EXCEPT:` keeps a named element inside something otherwise elided, and may carry its own `BASE:`.

### 3. Query this guide's own artifacts

During the build the Publisher writes `package.db`, a SQLite database of the guide's own content. Any page can query it and render the result as a table — this is the IG-Publisher answer to a cross-artifact query:

```
{% sql select Name, Description from Resources order by Name %}
```

| | |
| :--- | :--- |
| Name | Description |
| Example: Max Mustermann-Testpatient | Synthetic example for the Example Patient profile. Entirely artificial data. |
| ExamplePatient | Minimal example profile shipped with the template so that a newly created module renders a complete IG immediately. Not an MII artifact — replace it with your module's profiles. |
| MII_IG_Template | Self-check build of the mii-kds-module-template scaffold. This repository is a template for creating a new MII KDS module Implementation Guide, or a migration target for an existing Simplifier MII IG. Every value here is a placeholder — replace them all when you create a real module. |
| mii-param-template-manifest |  |

`Resources` is the table you will use most. Its columns include `Key`, `Type`, `Id`, `Web`, `Url`, `Version`, `Status`, `Date`, `Name`, `Title`, `Description`, `Purpose`, `Copyright`, `Realm`, `derivation` and `kind`. Other tables hold concepts, designations, extension usage and package metadata. The schema is not stable between Publisher releases, so open `package.db` from your own build with any SQLite client and look before relying on a column.

A JSON form of the same tag controls the column titles, the CSS class and how each column is rendered — `link`, `markdown`, `canonical`, `resource` and others:

```
{% sql {
  "query" : "select Name, Description, Web from Resources order by Name",
  "class" : "lines",
  "columns" : [
    { "name" : "Name", "type" : "link", "source" : "Name", "target" : "Web" },
    { "name" : "Description", "type" : "markdown", "source" : "Description" }
  ]
} %}
```

| | |
| :--- | :--- |
| Name | Description |
| [Example: Max Mustermann-Testpatient](Patient-ExamplePatientInstance.md) | Synthetic example for the Example Patient profile. Entirely artificial data. |
| [ExamplePatient](StructureDefinition-example-patient.md) | Minimal example profile shipped with the template so that a newly created module renders a complete IG immediately. Not an MII artifact — replace it with your module's profiles. |
| [MII_IG_Template](index.md) | Self-check build of the mii-kds-module-template scaffold. This repository is a template for creating a new MII KDS module Implementation Guide, or a migration target for an existing Simplifier MII IG. Every value here is a placeholder — replace them all when you create a real module. |
| [mii-param-template-manifest](Parameters-mii-param-template-manifest.md) |  |

### 4. Query into a variable instead of a table

`sqlToData` runs the same query but hands you the rows instead of rendering them, so you can lay them out yourself. The first argument names the variable — the rows also land in `_data/<name>.json` and are reachable as `site.data.<name>`:

```
{% sqlToData artifactCount
  select count(*) as n from Resources
%}
```

This guide contains 4 resources. That number came from the query above, written as `{{ artifactCount[0].n }}`.

Because the result is an ordinary Liquid array, you can loop over it:

```
{% sqlToData profileList
  select Name, Web from Resources where Type = 'StructureDefinition' order by Name
%}
```

* [ExamplePatient](StructureDefinition-example-patient.md)

### 5. Render a JSON file through a template

The `{% json %}` tag reads any JSON file in the repository and renders it through a Liquid template you write. Both paths are relative to the repository root — the directory holding `ig.ini`. It was built for documenting test cases, but it works for any JSON you keep alongside the guide.

Here it renders this repository's own `publication-request.json`, the file that drives formal publication:

```
{% json publication-request.json demo/rendering-artifacts.liquid %}
```

* **Package**: 
* **Version**: {{CALVER_VERSION}} (release, milestone)
* **Path**: [https://{{GITHUB_ORG}}.github.io/{{REPO_NAME}}/{{CALVER_VERSION}}](https://{{GITHUB_ORG}}.github.io/{{REPO_NAME}}/{{CALVER_VERSION}})

The template is five lines and lives at `demo/rendering-artifacts.liquid`. Delete it together with this page.

### 6. Include the reader's own language

This scaffold is bilingual, and the Publisher writes a `-en` and a `-de` variant of every fragment. `{% lang-fragment %}` picks the one matching the page being rendered, so a single line serves both languages:

```
{% lang-fragment StructureDefinition-example-patient-summary.xhtml %}
```

** Summary **

Mandatory: 2 elements
 Must-Support: 4 elements

On the English page that resolves to `StructureDefinition-example-patient-summary-en.xhtml`, on the German page to `-de`. Use this rather than a plain `include` whenever the fragment contains prose, otherwise a German reader gets English tables.

### 7. Link to an artifact by name

Triple brackets auto-link an artifact without you writing the URL. Inside go a resource **name**, a canonical URL, or a FHIR type name:

```
The profile Example Patient — template starter constrains Patient.
```

The profile [Example Patient — template starter](StructureDefinition-example-patient.md) constrains [Patient](http://hl7.org/fhir/R4/patient.html).

The match is on the artifact's `name`, case-insensitively — `ExamplePatient` here, which is the FSH `Profile:` name, **not** the `Id:` used for fragments. A name that resolves to nothing is left in the page as `[[[…]]]`, which is easy to grep for and does not fail the build.

### 8. Directives with no example here

Four of the Publisher's keywords are not demonstrated above, for reasons worth knowing before you reach for them.

| | | |
| :--- | :--- | :--- |
| `{% uml %}` | **It is broken.**The keyword is registered but has no implementation behind it, so it writes`Error processing command: Internal Error - unknown keyword uml`into your page while the build still reports success | Use`class-diagram`instead |
| `{% class-diagram %}` | Needs an`input/diagrams/`directory and a logical model to draw; this scaffold has neither | A logical model, plus Graphviz on the build machine |
| `{% multi-map %}` | Needs a source ValueSet and ConceptMaps to scan; this scaffold defines no terminology | A ValueSet and at least one ConceptMap |
| `{% dataset %}` | Needs a dataset registered through an IG parameter; without one it throws`Unable to find dataset` | A dataset declared in`sushi-config.yaml` |

Add the artifact each one needs and the directive starts working — none of them is deprecated. The recipe explains where each is documented, and which are documented at all.

##### Showing a directive without running it
Two escapes appear above, because two engines run in sequence. The Publisher's own Liquid pass runs
**before**Jekyll and claims eight keywords:
`sql`,
`fragment`,
`json`,
`class-diagram`,
`uml`,
`multi-map`,
`lang-fragment`and
`dataset`. To show one of those without running it, add an exclamation mark —
`{% sql … %}`. The Publisher turns that into a literal itself. Wrapping it in
`{% raw %}`does
**not**work, because the Publisher's pass runs first and does not know what
`raw`means; the directive executes and its error is written into the page while the build still reports success.

For a plain Jekyll tag such as
`{% include %}`it is the other way round: the Publisher never looks at it, so
`{% raw %}`is the correct escape — and the exclamation mark is a build error, because the Publisher leaves it alone and Jekyll cannot parse it.

##### Before you rely on any of this
The three families in sections 1 to 3 are documented and stable. Several neighbouring mechanisms are not — some are implemented but appear in no documentation, and one is documented but does not run. The recipe lists which is which, with the primary source for each.

