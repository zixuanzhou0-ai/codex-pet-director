# Codex Pet Director

[简体中文](../README.md#简体中文) · English · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md)

`codex-pet-director` is a multilingual Codex skill for creating highly customized official Codex desktop pets. It checks the user's environment, guides the user through simple design questions, confirms the character with generated images, records the final direction in `pet_brief.json`, and then hands the locked brief to `hatch-pet` to produce a Codex-ready pet package.

## One-Click Install

The start entry is `create-pet` in the Skills slash menu. You can also send `/create-pet` as a normal chat message.

**Option A: ask Codex to install it.**

Paste this directly into Codex:

```text
Run this install command for me:
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

After installation, restart Codex and paste this:

```text
/create-pet
```

**Option B: install from a terminal.**

If your environment has the Skills CLI, install both skills. The first is the main director; the second is the Codex Desktop entry.

```bash
npx skills add zixuanzhou0-ai/codex-pet-director --skill codex-pet-director --agent codex -g -y --copy
npx skills add zixuanzhou0-ai/codex-pet-director --skill create-pet --agent codex -g -y --copy
```

The recommended terminal path is this repository's installer:

```bash
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

The installer writes to the Codex skills directory, the Agents skills mirror, and `.agents/.skill-lock.json`, so the model can load the skill and skill managers can identify its source and update path.

Recommended Windows PowerShell command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

If you download the ZIP or clone the repository, you can also double-click:

```text
install.cmd
```

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.sh | bash
```

## 30-Second Start

1. Install the skill.
2. Restart Codex.
3. Search and select `create-pet` in the slash menu, or send `/create-pet`.
4. Answer who it is, what form it has, what style it should use, and what it looks like.
5. Pick from 2-4 confirmation images, or mix choices like "A's face + B's colors".
6. Confirm the 9 official actions.
7. Let `hatch-pet` produce `pet.json` and `spritesheet.webp`.

## What It Does

- Checks whether the local Codex environment can use custom pets.
- Interviews beginners in small, plain-language blocks.
- When the user names a celebrity, public figure, anime character, game character, or other known character, researches the appearance and version online before generating previews.
- Lets the user switch language during the flow.
- Generates 2-4 visual confirmation images at key stages.
- Saves decisions in `pet_brief.json` so the character stays consistent.
- Respects the official Codex pet format: 9 actions, 8 columns, 9 rows.
- Uses the existing `hatch-pet` skill for final package generation instead of rebuilding the spritesheet pipeline.

## User-Friendly Explanation

This tool is for anyone who wants a personal Codex desktop pet without learning image formats, animation frames, or install folders.

The user only needs to answer simple questions:

- What should it look like?
- What personality should it have?
- How should it move when idle, waiting, working, or failing?
- Which preview image do you prefer?
- What must be kept, and what must be avoided?

If the user has a reference image, they can provide it. If not, the skill can generate several directions first. Each round summarizes the decision before moving on.

If the user only says "make it like this celebrity / anime character / game character", the skill first researches the person or character online, turns the result into a reference card, and asks the user to confirm the version and key traits before generating images.

## Language Switching

After installation, users can start in any supported language:

```text
Help me create a custom Codex desktop pet.
```

They can also switch during the process:

```text
Switch to English.
```

The selected language is stored in `pet_brief.json` under `meta.language`, so later questions, summaries, and confirmation cards follow the same language.

## Architecture

```text
User conversation
  ↓
codex-pet-director: language, interview, confirmation images, character locking
  ↓
reference_research: confirms named people or known characters online
  ↓
pet_brief.json: stores user choices and the 9 action settings
  ↓
imagegen: creates visual confirmation images
  ↓
hatch-pet: produces pet.json + spritesheet.webp
  ↓
Codex pets folder: Codex detects and loads the pet
```

## Why This Design

This skill separates creative direction from final production.

- The director flow turns a vague idea into a stable character.
- `pet_brief.json` locks identity, colors, silhouette, props, and action choices.
- Confirmation images help beginners choose visually instead of writing perfect prompts.
- `hatch-pet` remains responsible for the official spritesheet, `pet.json`, and QA.

This keeps the system maintainable. If Codex changes the pet production format later, the production layer can change without rewriting the whole interview and multilingual guidance layer.

## Requirements

Full pet generation requires:

- Codex desktop pet support
- Python 3
- The `hatch-pet` skill
- Available image generation

The installer safely creates missing local folders when possible. It does not modify the Codex app itself.

## Post-Install Check

When the user selects `create-pet` or sends `/create-pet`, the skill checks:

- whether the machine is Windows, macOS, or Linux
- whether Codex `skills` and `pets` folders exist
- whether the `pets` folder is writable
- whether `hatch-pet` is installed
- whether there is evidence of Codex desktop pet support

If something is missing, it explains the missing piece. If only safe local folders are missing, the installer creates them.

## Usage

After installation, search `create-pet` in the Codex slash menu. You can also send:

```text
/create-pet
```

If manually typed `/create-pet` still shows "No commands", select `create-pet` from the Skills group instead, or send it as normal text. You can also say:

```text
I have a reference image. Turn it into an official Codex desktop pet.
```

## Example

See [../examples/wukong-spark](../examples/wukong-spark) for a real generated Codex desktop pet package. It contains the actual `pet.json` and `spritesheet.webp` files Codex can load.

See [../examples/blue-robot-cat](../examples/blue-robot-cat) for a complete sample brief, preview card, and action prompt notes.

The Wukong example shows the finished output. The blue robot cat example shows how a rough idea becomes a structured brief before final production.
