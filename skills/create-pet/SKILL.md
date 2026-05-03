---
name: create-pet
description: Start /create-pet for Codex Pet Director. Use when the user selects create-pet from the Codex slash command menu, sends /create-pet, wants to create a custom Codex desktop pet, or asks to customize an official Codex pet with a checked hatch-pet handoff.
metadata:
  short-description: Start custom Codex pet creation
---

# create-pet

This is the slash-menu entrypoint for `$codex-pet-director`.

When this skill is selected, or when the user sends only `/create-pet`, open a safe launcher for `$codex-pet-director`. Do not start production, do not load `$hatch-pet`, and do not resume an existing `pet_brief.json` until the user chooses a mode.

Keep the first user-facing response simple:

1. Say this will start Codex Pet Director.
2. If the current folder has `pet_brief.json`, mention that an existing draft was found.
3. Ask the user to choose one of these plain-language modes:
   - `新建宠物`: start a fresh pet brief and interview.
   - `继续已有`: inspect and resume the existing `pet_brief.json`.
   - `查看已有`: summarize the existing `pet_brief.json` without changing it.
4. Say environment checking comes next after the user chooses `新建宠物` or `继续已有`.

If the user sends `/create-pet` with a clear design request in the same message, such as `/create-pet 做一只蓝色机器人猫`, treat that as choosing `新建宠物`, then use `$codex-pet-director` from its environment check.

If the user chooses `继续已有`, first summarize the existing brief and ask whether to continue from the recorded stage. Do not silently continue an old brief.

If the user chooses `查看已有`, read and summarize the brief only. Do not write files, generate images, or call `$hatch-pet`.

If `$codex-pet-director` is not available, explain that the launcher is installed but the main director skill is missing, then ask the user to reinstall this package.
