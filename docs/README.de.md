# Codex Pet Director

[简体中文](../README.md#简体中文) · [English](README.en.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Français](README.fr.md) · Deutsch

`codex-pet-director` ist ein mehrsprachiger Skill zum Erstellen offizieller Codex Desktop-Pets. Er prüft zuerst die lokale Umgebung, stellt dann einfache Fragen zu Figur, Form, Stil, Aussehen, Persönlichkeit und den 9 offiziellen Aktionen. Danach wird der bestätigte Brief an `hatch-pet` übergeben, um ein Codex-fähiges Pet-Paket zu erzeugen.

## Installation mit einem Befehl

Der Einstieg ist `create-pet` im Skills-Bereich des Slash-Menüs. Du kannst auch `/create-pet` als normale Nachricht senden.

```text
Run this install command for me:
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

Starte Codex nach der Installation neu und schreibe dann:

```text
/create-pet
```

Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

Wenn du das ZIP herunterlädst oder das Repository klonst, kannst du auch `install.cmd` per Doppelklick starten.

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.sh | bash
```

## Funktionen

- Prüft, ob Codex benutzerdefinierte pets verwenden kann.
- Führt Anfänger mit einfachen Fragen durch den Entwurf.
- Erlaubt Sprachwechsel während des Prozesses.
- Erstellt in wichtigen Phasen 2-4 Bestätigungsbilder.
- Speichert Entscheidungen in `pet_brief.json`, damit die Figur konsistent bleibt.
- Beachtet das offizielle Codex pet Format: 9 Aktionen, 8 Spalten, 9 Zeilen.
- Übergibt die finale Produktion an `hatch-pet`.

## Architektur

```text
Benutzergespräch
  ↓
codex-pet-director: Sprache, Interview, Bestätigungsbilder, Figur fixieren
  ↓
pet_brief.json: Entscheidungen und 9 Aktionen
  ↓
imagegen: Bestätigungsbilder
  ↓
hatch-pet: pet.json + spritesheet.webp
  ↓
Codex pets Ordner: Codex erkennt und lädt das Pet
```

## Nutzung

Nach der Installation suche `create-pet` im Slash-Menü. Du kannst auch senden:

```text
/create-pet
```
