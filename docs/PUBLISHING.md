# Publishing Notes

This repository currently supports three install paths:

1. Codex-native install through `skill-installer`
2. GitHub-backed `npx`
3. Windows `install.cmd` / PowerShell install

## Current User Install Commands

Codex chat:

```text
请使用 skill-installer 安装这个 GitHub skill：https://github.com/zixuanzhou0-ai/codex-pet-director/tree/main/codex-pet-director
```

GitHub `npx`:

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
- command metadata
- plugin manifest
- examples
- docs
- install scripts

## GitHub Release Path

For a beginner-friendly release:

1. Create a tag, such as `v0.4.0`.
2. Create a GitHub Release from that tag.
3. Tell Windows users to download the source ZIP and double-click `install.cmd`.
4. Tell Codex users to use `skill-installer` with the repository URL.

Release title:

```text
Codex Pet Director v0.4.0
```

Short release description:

```text
Adds named person and known character reference research before preview image generation.
```
