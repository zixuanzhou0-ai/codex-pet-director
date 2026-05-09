# Publishing Notes

This repository currently supports these install paths:

1. GitHub-backed full local plugin installer through `npx`
2. Windows `install.cmd` / PowerShell full plugin install
3. Skills CLI install from GitHub

## Current User Install Commands

Codex chat:

```text
请运行这个安装命令，帮我安装 Codex Pet Director：
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

Skills CLI. Install both skills so Codex Desktop can find the `create-pet` entry:

```bash
npx skills add zixuanzhou0-ai/codex-pet-director --skill codex-pet-director --agent codex -g -y --copy
npx skills add zixuanzhou0-ai/codex-pet-director --skill create-pet --agent codex -g -y --copy
```

GitHub project installer:

```bash
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

This installs skills, the Agents mirror, the local plugin package, the Codex plugin cache, marketplace metadata, and `config.toml`.

Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

## npm Publish Path

Publishing to npm would let users install with:

```bash
npx codex-pet-director
```

Before publishing:

```bash
npm login
npm test
npm pack --dry-run
npm publish --access public
```

The package is already prepared with:

- `bin/install.js`
- skill files
- standard `skills/codex-pet-director/SKILL.md` layout
- command metadata
- plugin manifest
- examples
- docs
- install scripts
- validation scripts

## GitHub Release Path

For a beginner-friendly release:

1. Run `npm test`.
2. Run the production handoff smoke checks:

```bash
python .\codex-pet-director\scripts\check_pet_asset_fit.py --help
python .\codex-pet-director\scripts\build_hatch_handoff.py --help
python .\codex-pet-director\scripts\check_hatch_output.py --help
python .\codex-pet-director\scripts\pet_brief.py --help
```

3. Create a tag, such as `v0.5.6`.
4. Create a GitHub Release from that tag.
5. Tell Windows users to download the source ZIP and double-click `install.cmd`.
6. Tell Codex users to run the GitHub project installer so the full local plugin structure is installed.

Release title:

```text
Codex Pet Director v0.5.6
```

Short release description:

```text
Adds Action Director and the production QA loop: create-pet now collects special motion requests, completes the 9 official actions, checks a 192x208-ready production_base with preview/report files, hands the locked brief to hatch-pet, and verifies the final spritesheet package.
```
