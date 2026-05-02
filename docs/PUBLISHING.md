# Publishing Notes

This repository currently supports these install paths:

1. GitHub-backed project installer through `npx`
2. Windows `install.cmd` / PowerShell install
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

## GitHub Release Path

For a beginner-friendly release:

1. Create a tag, such as `v0.4.6`.
2. Create a GitHub Release from that tag.
3. Tell Windows users to download the source ZIP and double-click `install.cmd`.
4. Tell Codex users to run the GitHub project installer so both `codex-pet-director` and `create-pet` are installed.

Release title:

```text
Codex Pet Director v0.4.6
```

Short release description:

```text
Adds the `create-pet` entry skill so Codex Desktop can surface the pet flow in the Skills slash menu.
```
