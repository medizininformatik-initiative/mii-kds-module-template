# Recipe: let implementers validate their own instances against your module

**Goal.** Your rendered guide carries a working *Validate an instance* /
*Instanz validieren* page, you know the four ways an implementer can validate
an instance against your module's package, and — if your institution must
validate anything beyond synthetic examples — the page points at a validator
you host yourself.

**Prerequisites.** The module builds (the IG template is referenced in
`ig.ini`, any of its three forms). For route D: Docker on a host inside your
institution; for MII value sets: access to the SU-TermServ or a DIZ Ontoserver
(see [../secrets.md](../secrets.md)).

## Background — what the page is and where it comes from

Simplifier used to offer ad-hoc validation of an arbitrary instance against a
package. This scaffold's substitute is a page the **IG template** contributes
to every guide it renders: `validate.html` (NUM-DIZ request, decided
2026-08-31). It fills in **your** module's package `id#version`, canonical and
FHIR version from the build, carries English and German, and offers four
routes plus a live box. The module side is tiny: the menu entry (already in
both menu files, under *Conformance*), an optional data file, and this recipe.
There is no `validate.md` in `input/pagecontent/`, no `pages:` entry and no
`.po` msgid — see [../page-structure.md](../page-structure.md).

| Route | What it is | Sends the instance where |
| --- | --- | --- |
| **A. Online** | <https://validator.fhir.org/> — pick the FHIR version, type your package id under *Implementation Guides* and pick the version, optionally paste a profile canonical, paste or upload the instance | HL7's public service (outside the EU) |
| **B. Command line** | `validator_cli.jar` with `-ig <packageId>#<version>` — works offline with `-tx n/a` or against a package file | nowhere (terminology lookups go to the `-tx` server you name) |
| **C. API** | `POST /validate` on a validator wrapper — the same call the page's live box makes; documented at <https://validator.fhir.org/swagger-ui/index.html> | whatever base URL you call |
| **D. Self-hosted** | the wrapper as a container in your own institution | your host only |

> **The data-protection rule is not negotiable.** The public validator is a
> best-effort service hosted by HL7 International outside the EU. Send it
> **synthetic instances only** — the module's own examples, or test data with
> obviously artificial names. Real or realistic patient data (pseudonymised
> records and test data derived from real cases included) may **only** be
> validated against a self-hosted instance (route D). The page says so in
> red, in both languages, and there is no switch to hide the box — a module
> that wants readers to validate more than synthetic data sets the override
> in step 4 and says so in its own guidance.

## Steps

### 1. Check the page in your preview

Build (or push and open the branch preview, [../workflows.md](../workflows.md))
and open *Conformance → Validate an instance* — or the footer link. Confirm
the table at the top shows **your** package (`de.medizininformatikinitiative.kerndatensatz.<slug>#<version>`),
canonical and FHIR version. Switch the language: `de/validate.html` renders
German, `en/validate.html` English.

### 2. Pick one of your profiles in the live box

The live box's **profile picker** lists **your** guide's own resource
profiles: the template builds the list from what the publisher writes about
this build, so it needs no lookup and no configuration. What it shows follows
from that, and is worth knowing before you wonder why an entry is missing:

- **only this guide's profiles.** A profile from a dependency — a MII
  Basismodul profile, say — is not part of your build's own artifact list and
  therefore not in the picker. Paste its canonical into the box below the
  picker instead; that box always wins, and the request is built from it.
- **only profiles an instance can be validated against**, that is
  `kind = resource`. Logical models, extensions and datatype profiles are
  left out: handing one to the validator answers *"Specified profile type was
  Extension, but found type Patient"*.
- **no picker at all** when your guide has no resource profile yet — a module
  that so far ships only a logical model sees just the free-text box.
- the label is the profile's **title in the page's language**, so a German
  title needs the usual translation, and the entries are sorted by it.

Leaving the picker on *none* validates against the instance's own
`meta.profile`, which is what most examples carry.

Two failures of the live box are worth recognising, because the validator
reports neither as a validation issue:

| What you see | What it means |
| --- | --- |
| *The validator could not load this guide's package* | the package is not on a FHIR package registry — a branch preview or an unreleased version never is. Validate with route B against the package file from your *Downloads* page. |
| *The validator could not resolve that profile canonical* | the canonical you pasted is in no package the validator loaded. Check it, or validate without a profile. |

### 3. Validate an instance — the four routes

**A. Online (synthetic data only).** Open <https://validator.fhir.org/>, keep
the FHIR version at `4.0.1`, type your package id under *Implementation
Guides* and pick your version, paste the profile's *Defining URL* under
*Profiles* (or leave it empty to use `meta.profile`), paste the instance,
*Validate*. A version that is not listed is not on the registry the validator
reads (CI builds are not) — use route B with the package file.

**B. Command line.** Download `validator_cli.jar` from the
[HL7 FHIR core releases](https://github.com/hapifhir/org.hl7.fhir.core/releases/latest)
(Java 11 or newer):

```bash
java -jar validator_cli.jar -version 4.0.1 \
  -ig de.medizininformatikinitiative.kerndatensatz.<slug>#<version> \
  -tx https://tx.fhir.org \
  instance.json
```

`-profile <canonical>` forces a profile; `-ig path/to/package.tgz` (the file
from your guide's *Downloads* page) validates against a build that is not on
the registry; `-tx n/a` switches terminology checks off. The page prints this
line with your values filled in.

**C. API.** `POST <base>/validate` with
`{ "cliContext": { "sv": "4.0.1", "igs": ["<packageId>#<version>"], "txServer": "<tx>" }, "filesToValidate": [{ "fileName": "instance.json", "fileContent": "<the instance as a string>", "fileType": "json" }] }`
answers `{ "outcomes": [{ "issues": [...] }] }` (severity in `level`). Full
interface: <https://validator.fhir.org/swagger-ui/index.html>. Useful for CI
pipelines and test suites; the page's live box makes exactly this call.

**D. Self-hosted (the only route for real or realistic data).** The public
service is a container image:

```bash
docker run -d --name fhir-validator -p 3500:3500 markiantorno/validator-wrapper
```

Then use `http://<host>:3500` as the base URL for route C, and point the
terminology server at the SU-TermServ or your DIZ Ontoserver (next step). The
wrapper downloads a package from the registry on the first request that names
it — a version that is not on the registry (a CI build) needs route B.

### 4. Point the page at your self-hosted validator (optional)

The page reads `input/data/features.json`; the scaffold ships it with the
public defaults:

```json
{
  "validator": {
    "url": "https://validator.fhir.org",
    "tx": "https://tx.fhir.org"
  }
}
```

Set `validator.url` to your wrapper (`http://<host>:3500`) and `validator.tx`
to the terminology server the page should print and pass to the validator.
Rebuild: the live box now posts to your host, and the page's note names that
URL. Delete the file (or a key) to fall back to the defaults. Keep the
warning box in mind: the public defaults are safe for synthetic data only.

> **Terminology caveat.** The public `tx.fhir.org` may lack the German SNOMED
> CT extension and other codes the MII value sets use, so codes that are
> valid in the KDS can be reported as unknown. The SU-TermServ
> (`ontoserver.mii-termserv.de`) expands the MII value sets fully but
> authenticates with a client certificate — a bare `-tx` URL cannot present
> one. Two working setups: a DIZ Ontoserver reachable without a client
> certificate on the intranet (`-tx https://ontoserver.<diz>/fhir`), or the
> same client-certificate proxy the build workflows start
> ([../secrets.md](../secrets.md)) in front of the SU-TermServ, with `-tx`
> pointed at the proxy.

## Expected result

- *Conformance → Validate an instance* opens `validate.html` in the reader's
  language; the table names your package `id#version`, canonical and FHIR
  version, and the terminology server from `features.json` (or the default).
- Route B lists the issues for `instance.json` and ends with `Success`, or
  with `*FAILURE*` when there are errors.
- The live box lists issues (severity, line:column, location, message) for a
  pasted example, and its note names the validator it sent the text to.
- `qa.html` reports no broken link for `validate.html` in either language.

## Common errors & fixes

| Symptom | Cause | Fix |
| --- | --- | --- |
| Menu entry links to a 404 | The build used an IG template without the page (a release older than the feature, or a stale `ig-template/` mirror with `template = #ig-template`) | Build against a template release that carries `content/validate.html`; for the vendored form run `scripts/sync-ig-template.sh` |
| The page shows `#` with no version, or an empty package | The build ran without the publisher's `_data/fhir.json` (a SUSHI-only check) | Run the full IG Publisher build; the values are filled in from the publisher's own data |
| Route A: your version is not listed | The package is not on the registry the online validator reads (CI builds never are) | Route B with `-ig path/to/package.tgz` from the *Downloads* page |
| Codes from MII value sets are reported as unknown | `tx.fhir.org` lacks the German SNOMED CT extension or the MII code systems | Point `-tx` / `validator.tx` at the SU-TermServ (via the client-certificate proxy) or a DIZ Ontoserver |
| Live box: `Failed to fetch` | The configured `validator.url` is unreachable from the reader's browser, or a self-hosted wrapper does not allow the guide's origin | Check the URL from the reader's network; the public service allows every origin |
| Someone validated real data against the public service | The warning was ignored | Treat it as a data-protection incident per your institution's process; set `validator.url` to a self-hosted instance so the default target is inside the institution |
