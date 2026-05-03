# Codex Pet Director

[简体中文](../README.md#简体中文) · [English](README.en.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Français](README.fr.md) · Deutsch

`codex-pet-director` ist ein Skill zum Erstellen offizieller Codex Desktop-Pets. Er prüft zuerst die lokale Umgebung, stellt dann einfache Fragen zu Figur, Form, Stil, Aussehen, Persönlichkeit und den 9 offiziellen Aktionen. Wenn es ein Referenzbild gibt, übersetzt er es in eine geprüfte `production_base` innerhalb der offiziellen `192x208`-Grenze, bevor der Brief an `hatch-pet` übergeben wird.

Die vollständige visuelle Showcase-Seite findest du auf [简体中文](../README.md#真实案例三个可加载宠物) oder [English](README.en.md#real-pet-showcase).

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

Beim Start fragt das Tool zuerst, ob du ein neues Pet erstellen, einen vorhandenen Entwurf fortsetzen oder einen Entwurf ansehen willst. Es setzt alte Entwürfe nicht stillschweigend fort und startet keine finale Produktion automatisch.

Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

Dieser Installer schreibt Skills, das lokale Plugin-Paket, den Codex Plugin Cache, Marketplace und `config.toml`.

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
- Trennt schöne Bestätigungsbilder von der echten `production_base`, damit detailreiche Konzeptbilder nicht direkt in die Spritesheet-Produktion gehen.
- Strebt maximale Ähnlichkeit innerhalb der offiziellen `192x208`-Grenze an, behält erkennbare Merkmale und vereinfacht kleine Details.
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
hatch_pet_handoff.json: übergibt production_base und Aktionsregeln
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

Danach wählst du Erstellen, Fortsetzen oder Ansehen. Erst dann beginnt die Umgebungsprüfung und die Charakterbefragung.
