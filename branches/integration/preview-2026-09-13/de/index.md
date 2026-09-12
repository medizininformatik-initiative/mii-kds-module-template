# Startseite - MII Implementation Guide Module Template v2027.0.0-draft.1

* [**Inhaltsverzeichnis**](toc.md)
* **Startseite**

## Startseite

| | |
| :--- | :--- |
| *Offizielle URL*:https://www.medizininformatik-initiative.de/fhir/modul-template/ImplementationGuide/mii-ig-template | *Version*:2027.0.0-draft.1 |
| Active Stand: 2027-01-01 | *Maschinenlesbarer Name*:MII_IG_Template |

### Einleitung

Diese Spezifikation beschreibt die FHIR-Repräsentation des Kerndatensatz-(KDS-)Moduls **Module Template** der Medizininformatik-Initiative (MII). Sie beschreibt die Anwendungsfälle des Moduls sowie die zugehörigen FHIR-Profile, Extensions und Terminologie-Ressourcen in ihrer verbindlichen Form. Der MII-Kerndatensatz dient der standardisierten Nutzung klinischer Routinedaten für die medizinische Forschung.

> [TODO: Beschreiben Sie in ein bis zwei Sätzen den fachlichen Gegenstand Ihres Moduls — welche Daten es abdeckt und wofür sie genutzt werden.]

| | |
| :--- | :--- |
| Datum | 2027-01-01 |
| Version | 2027.0.0-draft.1 (CalVer`JJJJ.n.n`) |
| Status | active |
| Realm | DE |

### Zielgruppe

Dieser Implementierungsleitfaden richtet sich an:

##### Implementierende

Datenintegrationszentren (DIZ), Software-Entwickelnde und System-Architekt:innen, die FHIR-basierte Lösungen umsetzen.
 → siehe [Profile](profiles.md) und [Logische Modelle](logical-models.md).

##### Forschende

Wissenschaftler:innen, die KDS-Daten für die medizinische Forschung nutzen.
 → siehe [Anleitung für Forschende](researcher-guidance.md).

### Inhalt dieses Leitfadens

* **[Anleitung](guidance.md)** — Einstieg und fachliche Hinweise.
* **Konformität** — die KDS-weiten Konformitätsregeln (Anforderungssprache, Must-Support, Umgang mit fehlenden Daten) pflegt zentral das [Meta-Modul](https://github.com/medizininformatik-initiative/kerndatensatz-meta/wiki/Conformance); die modul-spezifischen Aspekte zu [Sicherheit und Datenschutz](security-and-privacy.md) sind Teil dieses Leitfadens.
* **[Profile](profiles.md)** und die weiteren **[Artefakt-Seiten](artifacts.md)** — die technischen Artefakte.
* **[Beispiele](examples.md)** — Beispielinstanzen.
* **[Abhängigkeiten](ImplementationGuide-mii-ig-template.md)** — die ImplementationGuide-Ressource mit Abhängigkeitstabelle, versionsübergreifender Analyse und Urheberrechtshinweisen.

### Verwandte Leitfäden

Dieses Modul ist Teil des MII-Kerndatensatzes; die weiteren KDS-Module und ihre Abhängigkeiten sind unter [medizininformatik-initiative.de](https://www.medizininformatik-initiative.de/) beschrieben.

> [TODO: Nennen Sie die formalen Abhängigkeiten (siehe `dependencies` in `sushi-config.yaml`) und verwandte Leitfäden Ihres Moduls.]

Weitere FHIR-Implementierungsleitfäden finden Sie im offiziellen **[FHIR IG Registry](https://fhir.org/guides/registry/)** (Quelle: [`FHIR/ig-registry`](https://github.com/FHIR/ig-registry)).

### Impressum

Dieser Leitfaden ist im Rahmen der Medizininformatik-Initiative erstellt worden und unterliegt per Governance-Prozess dem Abstimmungsverfahren des Interoperabilitätsforums und der Technischen Komitees von HL7 Deutschland e. V.

### Ansprechpartner

Fragen zu dieser Publikation können im HL7-FHIR-Zulip [chat.fhir.org](https://chat.fhir.org) im Stream `german/mi-initiative` oder im MII-Zulip [mii.zulipchat.com](https://mii.zulipchat.com/) im Stream `MII-Kerndatensatz` gestellt werden. Anmerkungen und Kritik werden als **Issues** auf [GitHub](https://github.com/medizininformatik-initiative/mii-kds-module-template/issues) entgegengenommen.

> [TODO: Nennen Sie die fachlichen Ansprechpartner:innen Ihres Moduls.]

### Autor:innen (in alphabetischer Reihenfolge)

> [TODO: Listen Sie die Autor:innen des Moduls mit Institution auf.]

### Urheberrecht und Lizenz

© 2027+ TMF e. V., Charlottenstraße 42, 10117 Berlin

Dieses Werk ist lizenziert unter der [Creative Commons Namensnennung 4.0 International Lizenz (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/deed.de).

Für die Nutzungsrechte der zugrunde liegenden FHIR-Technologie siehe die FHIR-Basisspezifikation.

Einige der verwendeten Codesysteme werden von anderen Organisationen veröffentlicht und gepflegt; es gilt das Urheberrecht der jeweiligen Herausgeber.

### Haftungsausschluss

Der Inhalt dieses Dokuments ist öffentlich. Bitte beachten Sie, dass Teile dieses Dokuments auf FHIR Version R4 basieren, dessen Urheberrecht bei HL7 International liegt.

Obwohl diese Publikation mit größter Sorgfalt erstellt wurde, können die Autor:innen keine Haftung für direkte oder indirekte Schäden übernehmen, die aus dem Inhalt dieser Spezifikation entstehen könnten.

