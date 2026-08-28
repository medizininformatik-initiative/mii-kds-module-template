# Artefakt-Rendering (Demo) - MII Implementation Guide Module Template v2027.0.0-draft.1

* [**Inhaltsverzeichnis**](toc.md)
* **Artefakt-Rendering (Demo)**

## Artefakt-Rendering (Demo)

Der IG Publisher erzeugt für jedes Profil, jede Extension, jedes ValueSet und jedes Beispiel dieses Leitfadens eine eigene Seite. Sie müssen Leserinnen und Leser nicht dorthin wegschicken — Sie können die entscheidenden Teile **direkt in einer Fließtextseite** rendern, unmittelbar neben der Erläuterung.

Diese Seite zeigt ein funktionierendes Beispiel für **jede Direktive, die in dieser Vorlage fehlerfrei läuft**. Jeder Block nennt zuerst die Quellzeile und zeigt dann das Ergebnis. Zeile kopieren, Artefaktnamen ändern, Seite löschen.

##### Was diese Seite ist
Eine mitgelieferte, lebende Demonstration der Modulvorlage. Lesen Sie den Quelltext dieser Seite neben ihrer Darstellung, übernehmen Sie, was Sie brauchen, und löschen Sie die Seite anschließend.
**Die Schritt-für-Schritt-Fassung ist**
[`docs/recipes/render-existing-artifacts.md`](https://github.com/medizininformatik-initiative/mii-kds-module-template/blob/main/docs/recipes/render-existing-artifacts.md)in diesem Repository. Dort ist jede Datei aufgeführt, die beim Löschen dieser Seite mit entfernt werden muss.

### 1. Ein erzeugtes Fragment einbinden

Während des Builds schreibt der Publisher für jedes Artefakt des Leitfadens eine Reihe kleiner HTML-Dateien — sogenannte **Fragmente**. Die Artefaktseiten, die Sie ohnehin sehen, sind daraus aufgebaut, und jede Fließtextseite kann dieselben Fragmente einbinden.

Der Name lautet stets `<Ressourcentyp>-<Id>-<Code>.xhtml` und wird aus der `Id:` des Artefakts gebildet, nicht aus dem FSH-Namen hinter `Profile:`. Das Beispielprofil dieser Vorlage hat `Id: example-patient`; sein Elementverzeichnis lautet also:

```
{% include StructureDefinition-example-patient-dict-key.xhtml %}
```

Guidance on how to interpret the contents of this table can be found[here](https://build.fhir.org/ig/FHIR/ig-guidance/readingIgs.html#data-dictionaries)

**Dieser Build erzeugt 96 Fragment-Codes für die beiden Artefakte dieser Vorlage.** Es gibt keine veröffentlichte Liste, die dazu passt — die [IG-Publisher-Dokumentation](https://confluence.hl7.org/spaces/FHIR/pages/35718627/IG+Publisher+Documentation) sagt das über ihrer eigenen Liste selbst: **„Note: as of July 2023, this list is not comprehensive.“** Der folgende Katalog stammt aus dem Build, nicht aus einem Dokument, und jeder Eintrag ist live. Klappen Sie einen auf, um seine Include-Zeile und seine Darstellung zu sehen.

Manche sind absichtlich leer: `history` hat ohne Provenance-Ressourcen nichts zu zeigen, `experimental-warning` nichts, solange das Artefakt nicht als experimentell gekennzeichnet ist. Ein leeres Fragment ist kein Fehler.

Vier der 96 sind mit ihrer Include-Zeile aufgeführt, **ohne** ihre Darstellung. `search-params`, `span`, `spanall` und `pseudo-json` verweisen auf Ziele, die es nur im Kontext der Artefaktseite gibt — die Seiten der Basisspezifikation, `formats.html` oder Anker, die die Artefaktseite für sich selbst definiert. In eine Fließtextseite eingebettet lösen diese nicht auf, und der Build meldet jeden davon als defekten Link. Das ist allgemein wissenswert: Dass ein Fragment erzeugt wird, heißt nicht, dass es überall eingebettet werden kann. Wenn Ihr QA-Bericht nach dem Einbinden eines Fragments defekte Links ausweist, liegt es daran.

#### Das Beispielprofil — 78 Codes

#### Die Beispielinstanz — 10 Codes

Für Instanzen gibt es deutlich weniger: Ansichten, die nur für eine **Definition** sinnvoll sind — Snapshot, Differential, Elementverzeichnis, Invarianten — existieren hier nicht.

#### Artefaktübergreifende Listen — 8 Formen

Diese werden je Profil statt je Ansicht erzeugt und listen die zugehörigen Beispiele, Testpläne und Testskripte auf.

### 2. Einen Ausschnitt einer Beispielinstanz einbetten

Die Direktive `{% fragment %}` rendert eine in diesem Leitfaden enthaltene Instanz und kann sie per FHIRPath einengen, sodass nur das gerade besprochene Element sichtbar wird — hilfreich, wenn ein Beispiel lang ist und es nur auf ein Feld ankommt.

Die Syntax lautet `[Ressourcentyp]/[id] [Format] [Filter]`. Als Format ist `json`, `xml`, `ttl` oder `fml` zulässig; alles andere ist ein Fehler. In der Praxis verwenden Sie `json` oder `xml` — siehe unten. Die `id` ist die Instanz-Id, und die Ressource muss in diesem Leitfaden vorhanden sein.

```
{% fragment Patient/ExamplePatientInstance JSON BASE:name %}
```

Derselbe Teilbaum als XML:

```
{% fragment Patient/ExamplePatientInstance XML BASE:name %}
```

`ttl` und `fml` werden von derselben Prüfung akzeptiert, hier aber nicht gezeigt. `ttl` wird geparst und anschließend nicht gerendert: Der Publisher schreibt sein internes Objekt in die Seite —

```
org.hl7.fhir.utilities.turtle.Turtle@7d4f6072

```

— ohne Fehler, ohne Warnung und ohne defekten Link; nur wer die Seite liest, bemerkt es. `fml` gilt für StructureMaps, die diese Vorlage nicht enthält. Verwenden Sie `json` oder `xml`.

Ohne Filter erhalten Sie die vollständige Instanz. `ELIDE:` ersetzt ein benanntes Element durch `...`, statt es zu entfernen — so bleibt die Struktur der Ressource sichtbar, während Details ausgeblendet werden:

```
{% fragment Patient/ExamplePatientInstance JSON ELIDE:meta %}
```

Es gibt insgesamt drei Filter. `BASE:` wählt den anzuzeigenden Teilbaum und darf je Fragment nur einmal vorkommen. `ELIDE:` ersetzt ein Element durch `...` und darf wiederholt werden. `EXCEPT:` behält ein benanntes Element innerhalb eines ansonsten ausgeblendeten Bereichs und kann ein eigenes `BASE:` tragen.

### 3. Die eigenen Artefakte des Leitfadens abfragen

Während des Builds schreibt der Publisher `package.db` — eine SQLite-Datenbank der Inhalte dieses Leitfadens. Jede Seite kann sie abfragen und das Ergebnis als Tabelle rendern; das ist die IG-Publisher-Antwort auf eine artefaktübergreifende Abfrage:

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

`Resources` ist die Tabelle, die Sie am häufigsten benötigen. Zu ihren Spalten zählen `Key`, `Type`, `Id`, `Web`, `Url`, `Version`, `Status`, `Date`, `Name`, `Title`, `Description`, `Purpose`, `Copyright`, `Realm`, `derivation` und `kind`. Weitere Tabellen enthalten Konzepte, Bezeichnungen, die Verwendung von Extensions sowie Paket-Metadaten. Das Schema ist zwischen Publisher-Versionen nicht stabil — öffnen Sie `package.db` aus Ihrem eigenen Build mit einem beliebigen SQLite-Werkzeug und sehen Sie nach, bevor Sie sich auf eine Spalte verlassen.

Eine JSON-Form derselben Direktive steuert Spaltentitel, CSS-Klasse und die Darstellung je Spalte — `link`, `markdown`, `canonical`, `resource` und weitere:

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

### 4. In eine Variable statt in eine Tabelle abfragen

`sqlToData` führt dieselbe Abfrage aus, übergibt Ihnen aber die Datensätze, statt sie zu rendern — die Darstellung bestimmen Sie selbst. Das erste Argument benennt die Variable; die Datensätze landen zusätzlich in `_data/<Name>.json` und sind über `site.data.<Name>` erreichbar:

```
{% sqlToData artifactCount
  select count(*) as n from Resources
%}
```

Dieser Leitfaden enthält 4 Ressourcen. Diese Zahl stammt aus der Abfrage oben und wurde als `{{ artifactCount[0].n }}` geschrieben.

Da das Ergebnis ein gewöhnliches Liquid-Array ist, können Sie darüber iterieren:

```
{% sqlToData profileList
  select Name, Web from Resources where Type = 'StructureDefinition' order by Name
%}
```

* [ExamplePatient](StructureDefinition-example-patient.md)

### 5. Eine JSON-Datei über eine Schablone rendern

Die Direktive `{% json %}` liest eine beliebige JSON-Datei des Repositories und rendert sie über eine Liquid-Schablone, die Sie selbst schreiben. Beide Pfade sind relativ zum Wurzelverzeichnis des Repositories — dem Verzeichnis, in dem `ig.ini` liegt. Gedacht war die Direktive für die Dokumentation von Testfällen; sie funktioniert aber für jedes JSON, das Sie neben dem Leitfaden pflegen.

Hier rendert sie die Datei `publication-request.json` dieses Repositories — die Datei, die die formale Publikation steuert:

```
{% json publication-request.json demo/rendering-artifacts.liquid %}
```

* **Package**: 
* **Version**: {{CALVER_VERSION}} (release, milestone)
* **Path**: [https://{{GITHUB_ORG}}.github.io/{{REPO_NAME}}/{{CALVER_VERSION}}](https://{{GITHUB_ORG}}.github.io/{{REPO_NAME}}/{{CALVER_VERSION}})

Die Schablone umfasst fünf Zeilen und liegt unter `demo/rendering-artifacts.liquid`. Löschen Sie sie zusammen mit dieser Seite.

### 6. Die Sprache der Leserin einbinden

Diese Vorlage ist zweisprachig, und der Publisher schreibt von jedem Fragment eine `-en`- und eine `-de`-Variante. `{% lang-fragment %}` wählt diejenige, die zur gerade gerenderten Seite passt — eine einzige Zeile bedient also beide Sprachen:

```
{% lang-fragment StructureDefinition-example-patient-summary.xhtml %}
```

** Summary **

Mandatory: 2 elements
 Must-Support: 4 elements

Auf der englischen Seite löst das zu `StructureDefinition-example-patient-summary-en.xhtml` auf, auf der deutschen zu `-de`. Verwenden Sie dies anstelle eines einfachen `include`, sobald das Fragment Fließtext enthält — sonst bekommen deutschsprachige Lesende englische Tabellen.

### 7. Auf ein Artefakt über seinen Namen verlinken

Dreifache eckige Klammern erzeugen einen Link auf ein Artefakt, ohne dass Sie die URL schreiben. Hinein gehört ein Ressourcen-**Name**, eine kanonische URL oder ein FHIR-Typname:

```
Das Profil Example Patient — template starter schränkt Patient ein.
```

Das Profil [Example Patient — template starter](StructureDefinition-example-patient.md) schränkt [Patient](http://hl7.org/fhir/R4/patient.html) ein.

Verglichen wird der `name` des Artefakts, ohne Beachtung der Groß- und Kleinschreibung — hier `ExamplePatient`, also der FSH-Name hinter `Profile:` und **nicht** die für Fragmente verwendete `Id:`. Ein Name, der sich nicht auflösen lässt, bleibt als `[[[…]]]` in der Seite stehen: leicht zu finden, und der Build schlägt deswegen nicht fehl.

### 8. Direktiven ohne Beispiel auf dieser Seite

Vier Keywords des Publishers werden oben nicht demonstriert. Die Gründe sind es wert, bekannt zu sein, bevor Sie danach greifen.

| | | |
| :--- | :--- | :--- |
| `{% uml %}` | **Sie ist defekt.**Das Keyword ist registriert, aber ohne Implementierung dahinter; es schreibt`Error processing command: Internal Error - unknown keyword uml`in Ihre Seite, während der Build weiterhin Erfolg meldet | Stattdessen`class-diagram`verwenden |
| `{% class-diagram %}` | Benötigt ein Verzeichnis`input/diagrams/`und ein logisches Modell zum Zeichnen; diese Vorlage hat beides nicht | Ein logisches Modell sowie Graphviz auf dem Build-Rechner |
| `{% multi-map %}` | Benötigt ein Quell-ValueSet und ConceptMaps zum Auswerten; diese Vorlage definiert keine Terminologie | Ein ValueSet und mindestens eine ConceptMap |
| `{% dataset %}` | Benötigt ein über einen IG-Parameter registriertes Dataset; ohne ein solches wirft sie`Unable to find dataset` | Ein in`sushi-config.yaml`deklariertes Dataset |

Ergänzen Sie das jeweils benötigte Artefakt, und die Direktive funktioniert — keine davon ist abgekündigt. Das Rezept erläutert, wo die einzelnen Direktiven dokumentiert sind und welche überhaupt dokumentiert sind.

##### Eine Direktive zeigen, ohne sie auszuführen
Oben kommen zwei Maskierungen vor, weil zwei Engines nacheinander laufen. Der eigene Liquid-Durchlauf des Publishers läuft
**vor**Jekyll und beansprucht acht Keywords für sich:
`sql`,
`fragment`,
`json`,
`class-diagram`,
`uml`,
`multi-map`,
`lang-fragment`und
`dataset`. Um eines davon zu zeigen, ohne es auszuführen, setzen Sie ein Ausrufezeichen:
`{% sql … %}`. Der Publisher wandelt das selbst in eine wörtliche Ausgabe um. Es in
`{% raw %}`zu verpacken, funktioniert
**nicht**: Der Durchlauf des Publishers läuft zuerst und kennt
`raw`nicht; die Direktive wird ausgeführt und ihre Fehlermeldung landet in der Seite, während der Build weiterhin Erfolg meldet.

Bei einer reinen Jekyll-Direktive wie
`{% include %}`ist es umgekehrt: Der Publisher sieht sie gar nicht an, also ist
`{% raw %}`die richtige Maskierung — und das Ausrufezeichen ein Build-Fehler, weil der Publisher es unangetastet lässt und Jekyll es nicht parsen kann.

##### Bevor Sie sich darauf verlassen
Die drei Familien in den Abschnitten 1 bis 3 sind dokumentiert und stabil. Mehrere benachbarte Mechanismen sind es nicht — manche sind implementiert, tauchen aber in keiner Dokumentation auf, und eine ist dokumentiert, läuft aber nicht. Das Rezept führt auf, was worauf zutrifft, jeweils mit der Primärquelle.

