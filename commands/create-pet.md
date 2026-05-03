---
description: Start the Codex Pet Director flow to create an official custom Codex desktop pet.
---

# /create-pet

Open the beginner-friendly Codex desktop pet launcher. A bare `/create-pet` should ask whether the user wants to create a new pet, continue an existing draft, or inspect an existing draft before any production work starts.

## Arguments

- `language`: optional language preference, such as Chinese, English, Japanese, Korean, Spanish, French, German, or Traditional Chinese.
- `reference`: optional reference image or short character idea.
- `name`: optional pet name.

## Workflow

1. Use `$codex-pet-director`.
2. If the user only sends `/create-pet`, ask them to choose `新建宠物`, `继续已有`, or `查看已有`.
3. If the current folder has `pet_brief.json`, mention it, but do not resume or overwrite it silently.
4. Run the pet environment check after the user chooses `新建宠物` or `继续已有`.
5. If the environment can host Codex pets, continue with the seven-block interview.
6. If the environment is missing safe local folders, create only those folders with the skill's environment script.
7. If Codex pet support or `$hatch-pet` is missing, explain the limitation and offer to continue with concept design only.
8. Ask one beginner-friendly block at a time: identity, form, style, personality, appearance, actions, final confirmation.
9. If the user names a celebrity, public figure, anime/game/film character, mascot, or other known figure, research the reference online before image generation.
10. Generate 2-4 user-facing confirmation images at key visual stages.
11. Record decisions in `pet_brief.json`.
12. After the formal character image is confirmed, keep identity locked and generate a simplified `production_base` for the official 192x208 pet boundary.
13. Run `check_pet_asset_fit.py`; if it fails, regenerate or revise `production_base` instead of loading `$hatch-pet`.
14. Build `hatch_pet_handoff.json` with `build_hatch_handoff.py`.
15. Ask for explicit final production confirmation before loading `$hatch-pet`.
16. Hand the validated `production_base` and final brief to `$hatch-pet` for `pet.json` and `spritesheet.webp`.

## Guardrails

- Use the official Codex pet format only.
- Do not promise extra official actions, extra frames, keyboard control, controller control, or unlimited random actions.
- Keep the user-facing language simple.
- Treat confirmation images as previews, not final production sprites.
- Treat the user's request as the creative target, but keep the official 192x208 Codex pet format as the hard boundary.
- Do not use high-resolution confirmation images, selfies, anime screenshots, or polished concept art as the main `$hatch-pet` production reference.
- Use `confirmations.production_base` as the only production reference, and only after it passes `check_pet_asset_fit.py`.
- Do not start production just because the user selected the slash entry.
- Do not silently continue a previous `pet_brief.json`.
- Do not rely on memory for named people or known fictional characters when no clear reference image is provided.
- For a half-body, head-only, screen-face, floating object, or mascot pet, adapt action descriptions through bouncing, drifting, tilting, sliding, expression changes, prop motion, or screen effects.
