<p align="center">
  <img src="curseforge/logo.png" alt="Gabba Unit Frames – Gruppenframes mit grünen Lebens- und blauen Ressourcenbalken" width="200">
</p>

<h1 align="center">Gabba Unit Frames</h1>

<p align="center">
  <strong>Deine Gruppe im Blick. Dein vertrautes Blizzard-UI.</strong><br>
  Klare Werte, übersichtliche Pets und Raid-Gruppen, die zu deinem Bildschirm passen. 💚
</p>

<p align="center">
  <a href="https://github.com/Gabbajoe/GabbaUnitFrames/actions/workflows/ci.yml"><img src="https://github.com/Gabbajoe/GabbaUnitFrames/actions/workflows/ci.yml/badge.svg?branch=main" alt="Tests und Paketbau"></a>
  <a href="https://github.com/Gabbajoe/GabbaUnitFrames/releases"><img src="https://img.shields.io/github/v/release/Gabbajoe/GabbaUnitFrames?style=flat-square&amp;color=34d399&amp;label=Release" alt="Neuester veröffentlichter Release"></a>
  <img src="https://img.shields.io/badge/WoW-Classic_Era-34d399?style=flat-square" alt="WoW Classic Era">
  <img src="https://img.shields.io/badge/Interface-11509-38bdf8?style=flat-square" alt="Interface 11509">
  <img src="https://img.shields.io/badge/Abh%C3%A4ngigkeiten-keine-fbbf24?style=flat-square" alt="Keine erforderlichen Zusatzaddons">
  <img src="https://img.shields.io/badge/CurseForge--Projekt-1734116-f16436?style=flat-square" alt="CurseForge-Projekt 1734116">
</p>

<p align="center">
  <a href="https://github.com/Gabbajoe/GabbaUnitFrames/releases"><strong>📦 Downloads</strong></a> ·
  <a href="https://github.com/Gabbajoe/GabbaUnitFrames/issues"><strong>💬 Ideen &amp; Fehler</strong></a> ·
  <a href="CHANGELOG.md"><strong>📝 Änderungen</strong></a> ·
  <a href="RELEASING.md"><strong>🛠️ Entwicklung</strong></a>
</p>

---

**Gabba Unit Frames** ergänzt Blizzards Gruppen-, Pet-, Spieler- und Zielframes
in **WoW Classic Era** um gut lesbare Informationen und einstellbare Layouts.
Du behältst die vertrauten Frames und entscheidest selbst, welche Werte du sehen möchtest.

Entstanden aus dem Unitframe-Modul des **Gabba-Addons**, jetzt als eigenständiges
Addon mit eigenem Einstellungsfenster und Minimap-Button. **Gabba wird nicht benötigt.**

> **Aktueller Stand: Version 1.0.0 zum lokalen Testen vorbereitet.**
> GitHub-Veröffentlichung und erster CurseForge-Upload stehen noch aus.
> Die GitHub-Links und Live-Badges werden nach der Veröffentlichung verfügbar.

## ✨ Was Gabba Unit Frames kann

| Bereich | Deine Möglichkeiten |
| --- | --- |
| 💚 **Gruppe** | Lebens- und Ressourcenwerte als Prozentzahl und exakter Wert auf den klassischen Partyframes |
| 🐾 **Party-Pets** | Größe von 100–200 %, Position unterhalb, links oder rechts; Namen, Leben und Ressourcen einzeln einstellbar |
| 🎯 **Spieler & Ziel** | Statusschrift von 8–16 px, Lebenswerte feindlicher Ziele und Lebensprozente beim Ziel-des-Ziels |
| 🛡️ **Raid** | Separate Gruppen horizontal oder vertikal anordnen und 1–8 Gruppen pro Zeile einstellen |
| 🧭 **Minimap** | Eigener GUF-Button: Linksklick öffnet die Optionen, Ziehen verschiebt das Symbol |
| 💾 **Charaktere** | Jeder Charakter behält seine eigenen Einstellungen |

Änderungen an geschützten Party- und Raid-Layouts werden nach dem Kampf angewendet.
Die Raid-Anordnung unterstützt auch die sichtbare Raid-Vorschau in Blizzards Edit Mode.
Das GUF-Logo erscheint außerdem direkt in der WoW-Addonliste.

## 🎛️ So bedienst du das Addon

| Aktion | Ergebnis |
| --- | --- |
| **Linksklick aufs Minimap-Symbol** | Einstellungen öffnen oder schließen |
| **Symbol ziehen** | Position an der Minimap ändern und speichern |
| **`/guf`** | Einstellungen öffnen oder schließen |
| **`/guf reset`** | Einstellungen dieses Charakters zurücksetzen |
| **Escape** | Einstellungsfenster schließen |

Die Optionen sind nach **Party members**, **Party pets**, **Raid layout** und
**Player and target labels** gegliedert. Die Oberfläche ist derzeit Englisch.

## 📦 Installation

1. Lade das installierbare **`GabbaUnitFrames-<Version>.zip`** aus den
   [Releases](https://github.com/Gabbajoe/GabbaUnitFrames/releases) herunter.
2. Entpacke den Ordner **`GabbaUnitFrames`** nach:

   ```text
   World of Warcraft/_classic_era_/Interface/AddOns/
   ```

3. Dort muss anschließend `GabbaUnitFrames/GabbaUnitFrames.toc` liegen.
4. Starte WoW vollständig neu, aktiviere **Gabba Unit Frames** in der Addonliste
   und öffne die Optionen über das Minimap-Symbol oder `/guf`.

Die automatisch von GitHub erzeugten **Source code**-Archive sind keine fertig
gepackten Addon-Downloads. Für den lokalen Test liegt das Paket unter `dist/`.

## 🤝 Zusammen mit Gabba

Die angepasste Gabba-Version erkennt ein aktiviertes **GabbaUnitFrames** automatisch
und überspringt ihre eigenen Party-/Raid- und Zieltextmodule. Alle anderen
Gabba-Funktionen bleiben verfügbar. Die Party-/Raid-Einstellungen in Gabba führen
dann zum Standalone-Fenster.

Deaktivierst du GabbaUnitFrames und lädst die UI neu, übernimmt Gabba wieder.
**Beide Addons speichern ihre Einstellungen getrennt**; bestehende Gabba-Werte
werden nicht automatisch importiert. Verwende zum gemeinsamen Testen auch die
aktualisierte Gabba-Version mit dieser Erkennung.

## 🎮 Kompatibilität

Zielclient: **WoW Classic Era 1.15.9**, Interface **11509**.
Die Raid-Anordnung benötigt Blizzards **Separate Groups**-Layout und die
entsprechenden Layout-Funktionen des Clients. Das Addon ergänzt Blizzard-Frames;
komplette Unitframe-Ersetzungen können andere Frames verwenden.

Das ursprüngliche Gabba-Modul wird bereits im Spiel verwendet. Die ausgelagerte
Version samt Einstellungsfenster, Minimap-Button und automatischer Übergabe ist
für den eigenständigen Spieltest vorbereitet. Retail und andere Classic-Zweige
sind derzeit nicht als unterstützt ausgewiesen.

## 🛠️ Entwicklung & Releases

Die Pipeline folgt GabbaSounds: **Tests → ZIP mit SHA256 → GitHub-Release →
CurseForge-Upload**, sobald Projekt-ID und Upload-Token hinterlegt sind.

- **CI:** Lua-Prüfungen, Regressionstests und reproduzierbarer Paketbau bei Push und Pull Request.
- **Release:** Ein Tag wie `v1.0.0` veröffentlicht ZIP, Prüfsumme und Changelog.
- **CurseForge-Check:** Manuell ausführbarer Zugangstest ohne Datei-Upload.
- **Dependabot:** Monatliche Prüfung der verwendeten GitHub Actions auf Updates.

| Dokument | Inhalt |
| --- | --- |
| [Releases vorbereiten](RELEASING.md) | Lokale Prüfungen, Versionen, Tags, Token und Upload |
| [Changelog](CHANGELOG.md) | Änderungen am Addon |
| [CurseForge-Projekt](curseforge/PROJECT.md) | Projekt-ID, Upload-Daten und Screenshot-Ideen |
| [CurseForge-Beschreibung](curseforge/DESCRIPTION.md) | Englischer Text für die Projektseite |

## 💬 Feedback

Fehlt dir eine Einstellung oder sitzt eine Anzeige nicht richtig?
[Erstelle ein Issue](https://github.com/Gabbajoe/GabbaUnitFrames/issues) mit deiner
WoW-Version, Addon-Version und möglichst einem Screenshot oder Lua-Fehler.
