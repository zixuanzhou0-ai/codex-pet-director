---
name: create-pet
description: Start /create-pet for Codex Pet Director. Use when the user selects create-pet from the Codex slash command menu, sends /create-pet, wants to create a custom Codex desktop pet, or asks to customize an official Codex pet.
metadata:
  short-description: Start custom Codex pet creation
---

# create-pet

This is the slash-menu entrypoint for `$codex-pet-director`.

When this skill is selected, or when the user sends `/create-pet`, immediately use `$codex-pet-director` and start the full pet creation flow from the environment check. Do not ask the user to repeat the command and do not explain internal skill names unless the user asks.

Keep the first user-facing response simple:

1. Say you will check whether this Codex environment can create desktop pets.
2. Run the `codex-pet-director` environment check.
3. Continue with the beginner-friendly interview from `$codex-pet-director`.

If `$codex-pet-director` is not available, explain that the launcher is installed but the main director skill is missing, then ask the user to reinstall this package.
