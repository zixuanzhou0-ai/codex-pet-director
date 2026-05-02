---
description: Start the Codex Pet Director flow to create an official custom Codex desktop pet.
---

# /create-pet

Start the beginner-friendly Codex desktop pet creation flow.

## Arguments

- `language`: optional language preference, such as Chinese, English, Japanese, Korean, Spanish, French, German, or Traditional Chinese.
- `reference`: optional reference image or short character idea.
- `name`: optional pet name.

## Workflow

1. Use `$codex-pet-director`.
2. Run the pet environment check before asking design questions.
3. If the environment can host Codex pets, continue with the seven-block interview.
4. If the environment is missing safe local folders, create only those folders with the skill's environment script.
5. If Codex pet support or `$hatch-pet` is missing, explain the limitation and offer to continue with concept design only.
6. Ask one beginner-friendly block at a time: identity, form, style, personality, appearance, actions, final confirmation.
7. Generate 2-4 user-facing confirmation images at key visual stages.
8. Record decisions in `pet_brief.json`.
9. After the formal character image is confirmed, keep identity locked and only vary action poses.
10. Hand the final brief to `$hatch-pet` for `pet.json` and `spritesheet.webp`.

## Guardrails

- Use the official Codex pet format only.
- Do not promise extra official actions, extra frames, keyboard control, controller control, or unlimited random actions.
- Keep the user-facing language simple.
- Treat confirmation images as previews, not final production sprites.
- For a half-body, head-only, screen-face, floating object, or mascot pet, adapt action descriptions through bouncing, drifting, tilting, sliding, expression changes, prop motion, or screen effects.
