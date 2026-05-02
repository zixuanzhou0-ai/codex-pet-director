---
name: codex-pet-director
description: Guide users through creating official custom Codex desktop pets that can be installed under the Codex pets folder. Use when a user wants a high-customization Codex desktop pet, wants to make a custom pet from text or reference images, wants a beginner-friendly pet interview with image confirmations, needs to check whether their Codex environment supports custom pets, or wants to prepare a pet brief before handing off to hatch-pet.
---

# Codex Pet Director

## Overview

Create an official Codex desktop pet through a beginner-friendly high-customization flow. This skill owns environment checks, simple user interviews, style and form choices, staged image confirmations, pet brief management, and the final handoff to `$hatch-pet`.

Keep the user-facing conversation in plain Chinese unless the user chooses another language. Avoid technical terms unless they are necessary.

## Hard Boundaries

- Target only the official Codex custom pet format.
- Do not present alternative product choices or external desktop-pet capabilities unless the user asks.
- Treat the Codex pet format as fixed: 8 columns x 9 rows, 192x208 cells, 1536x1872 atlas, 9 named states.
- Do not claim the user can add extra official actions, extra rows, extra frames, random behaviors, or custom controls through `pet.json`.
- Do not rewrite the lower-level spritesheet pipeline. Use `$hatch-pet` for final official pet generation and packaging.
- Keep reference-image discussion focused on likeness level. If the user provides a reference, ask how close they want the pet to feel to that reference.

## Required Flow

### 0. Check The Environment

Start every full pet creation request by checking whether the local Codex environment can host a custom pet:

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/check_pet_environment.py"
```

If the pets directory is missing and the rest of the environment is plausible, create only the safe local folders:

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/check_pet_environment.py" --fix
```

Never modify the installed Codex app. If the script cannot find a supported Codex desktop app or `hatch-pet`, explain the missing piece and stop before final pet production. You may still help the user design a brief and concept images if they explicitly want that.

### 1. Interview In Small Blocks

Use the seven-block interview from `references/question-flow.md`. Ask one block at a time, not the whole questionnaire at once.

Default blocks:

1. 它是谁
2. 它是什么形态
3. 它是什么风格
4. 它是什么性格
5. 它长什么样
6. 它怎么动
7. 最终确认

After each block, summarize what was decided in simple Chinese. For important visual blocks, generate 2-4 user-facing confirmation images and ask which direction they prefer. A user may answer by mixing choices, for example: `要 A 的脸 + B 的颜色 + C 的气质`.

### 2. Maintain A Pet Brief

Create or update a `pet_brief.json` in the working folder while interviewing:

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/pet_brief.py" init --path /absolute/path/to/pet_brief.json
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/pet_brief.py" update --path /absolute/path/to/pet_brief.json --set identity.concept="蓝色屏幕脸机器人猫"
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/pet_brief.py" validate --path /absolute/path/to/pet_brief.json --stage final
```

Use the brief as the source of truth for all prompts, confirmation summaries, and final handoff. Once the user confirms the formal character image, lock the identity: keep the same face, colors, body type, props, and core silhouette for all actions.

### 3. Generate Confirmation Images

For visual confirmation images, use `$imagegen`. Load the image generation skill before generating images:

```text
${CODEX_HOME:-$HOME/.codex}/skills/.system/imagegen/SKILL.md
```

Confirmation images are decision aids, not the final spritesheet. Follow `references/image-confirmation-flow.md` to keep this clear:

- early images help users choose identity, form, style, and expression
- production images later create the base reference and 9 official action rows

Do not use local scripts, SVG, canvas, or handmade image editing as a substitute for generated visual confirmation images.

### 4. Design The 9 Official Actions

Use `references/action-guide.md` for state names, frame counts, and beginner-friendly questions.

Official states:

- `idle`
- `running-right`
- `running-left`
- `waving`
- `jumping`
- `failed`
- `waiting`
- `running`
- `review`

Adapt movement to the pet form. A half-body pet, screen face, floating object, or object mascot does not need literal legs; translate movement into drifting, bouncing, tilting, sliding, jetting, screen flicker, or prop motion.

### 5. Hand Off To Hatch Pet

When the user has confirmed:

- environment is usable
- character direction
- formal character image
- key actions
- final pet card

load `$hatch-pet` and follow its workflow. Use `references/handoff-to-hatch-pet.md` to convert the pet brief into `hatch-pet` inputs. The `hatch-pet` skill owns base generation, row generation, atlas assembly, QA, preview videos, `pet.json`, and `spritesheet.webp`.

## Reference Files

- `references/question-flow.md`: user interview blocks and simple wording.
- `references/style-menu.md`: style choices and internal visual translations.
- `references/action-guide.md`: official action slots, frame counts, and form adaptation.
- `references/image-confirmation-flow.md`: staged confirmation image policy.
- `references/handoff-to-hatch-pet.md`: final production handoff.

## Acceptance Criteria

- The flow starts with an environment check.
- The user is asked simple questions one block at a time.
- A `pet_brief.json` exists before final production.
- The official Codex fixed format is respected.
- The formal character image is locked before action generation.
- Final production is delegated to `$hatch-pet`.
- The final installed pet contains `pet.json` and `spritesheet.webp` under `${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/`.
