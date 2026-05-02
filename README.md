# Codex Pet Director

<p align="center">
  <a href="#简体中文">简体中文</a> ·
  <a href="#english">English</a> ·
  <a href="docs/README.zh-TW.md">繁體中文</a> ·
  <a href="docs/README.ja.md">日本語</a> ·
  <a href="docs/README.ko.md">한국어</a> ·
  <a href="docs/README.es.md">Español</a> ·
  <a href="docs/README.fr.md">Français</a> ·
  <a href="docs/README.de.md">Deutsch</a>
</p>

## 简体中文

`codex-pet-director` 是一个多语言 Codex 桌面宠物高定制向导 skill。它会先检查用户环境，再用简单问题一步步确认角色、形态、风格、外观、性格和 9 个官方动作，最后把锁定后的方案交给现有 `hatch-pet` 生成 Codex 可用的宠物包。

### 一键安装

不需要斜杠命令，也不需要用户知道 skill 名称。安装和启动都可以用普通聊天句子完成。

第一步，把下面这句话直接发给 Codex：

```text
请使用 skill-installer 安装这个 GitHub skill：https://github.com/zixuanzhou0-ai/codex-pet-director/tree/main/codex-pet-director
```

第二步，安装完成后重启 Codex，然后把下面这句话发给 Codex：

```text
帮我定制一个能在 Codex 里直接使用的桌面宠物。
```

开发者也可以用 `npx`：

```bash
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

Windows 用户推荐直接复制这一行到 PowerShell：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

如果你是下载 ZIP 或 clone 仓库，也可以直接双击：

```text
install.cmd
```

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.sh | bash
```

### 这个 skill 做什么

- 检查用户是否具备 Codex pet 使用环境。
- 用面向小白的问题做高定制采访，中途可以切换语言。
- 每个关键板块后生成 2-4 张确认图，让用户选择或混合偏好。
- 记录 `pet_brief.json`，避免每轮重新发明角色。
- 明确使用 Codex 官方 pet 固定格式：9 个动作、8 列、9 行 spritesheet。
- 最终正式生产阶段调用已有 `hatch-pet`，不重写底层 spritesheet 逻辑。

### 给用户看的介绍

这个工具适合想做“自己的 Codex 桌面宠物”的人。用户不需要懂图片格式、动作帧或安装目录，只要回答几个简单问题：

- 它像什么？
- 它是什么性格？
- 它开心、等待、失败时会怎么动？
- 你喜欢哪张确认图？
- 有哪些东西一定要保留，哪些一定不要？

如果用户有参考图，可以直接发给 Codex；如果没有，也可以先生成几种方向让用户选。每一轮都会先总结，再进入下一轮，关键阶段会给 2-4 张确认图。

### 多语言切换

安装后可以直接用任意支持语言开始，例如：

```text
Help me create a custom Codex desktop pet.
```

也可以中途切换：

```text
切换到英文
```

语言选择会记录在 `pet_brief.json` 的 `meta.language` 字段里，后续问题、总结、确认卡片都会跟随这个语言。

### 底层架构

```text
用户对话
  ↓
codex-pet-director：语言、采访、确认图、角色锁定
  ↓
pet_brief.json：保存用户选择和 9 个动作设定
  ↓
imagegen：生成每轮确认图
  ↓
hatch-pet：正式生成 pet.json + spritesheet.webp
  ↓
Codex pets 目录：Codex 识别并加载宠物
```

### 为什么这样设计

这个 skill 不直接重写宠物生成器，而是把“用户定制”和“正式生产”分开。

- 用户定制阶段负责把模糊想法变成稳定角色。
- `pet_brief.json` 负责锁定角色，避免后续图片越生成越不像。
- 确认图让新手用视觉选择，不需要一开始就写完美提示词。
- `hatch-pet` 继续负责官方格式的 spritesheet、`pet.json` 和 QA。

这样后续更容易维护：如果 Codex 的宠物底层格式变化，主要改生产层；如果用户访谈、语言、风格菜单要升级，则主要改这个 director skill。

### 依赖

完整生成宠物包需要用户本机已经能使用：

- Codex 桌面端的 pet 功能
- Python 3
- `hatch-pet` skill
- 可用的图片生成能力

如果缺少目录，安装器会尝试安全创建。它不会修改 Codex app 本体。

### 使用方式

安装后，不需要输入 `/` 命令。在 Codex 里直接说：

```text
帮我定制一个能在 Codex 里直接使用的桌面宠物。
```

或：

```text
我有一张参考图，帮我做成 Codex 官方桌面宠物。
```

## English

`codex-pet-director` is a multilingual Codex skill for creating highly customized official Codex desktop pets. It checks the user's environment, guides the user through simple design questions, confirms the character with generated images, records the final direction in `pet_brief.json`, and then hands the locked brief to `hatch-pet` to produce a Codex-ready pet package.

### One-Click Install

No slash command is required, and users do not need to know the internal skill name. Installation and usage both work through normal chat messages.

Step 1: paste this directly into Codex:

```text
Use skill-installer to install this GitHub skill: https://github.com/zixuanzhou0-ai/codex-pet-director/tree/main/codex-pet-director
```

Step 2: after installation, restart Codex and paste this:

```text
Help me create a custom Codex desktop pet.
```

Developers can also use `npx`:

```bash
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

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

### What It Does

- Checks whether the local Codex environment can use custom pets.
- Interviews beginners in small, plain-language blocks.
- Lets the user switch language during the flow.
- Generates 2-4 visual confirmation images at key stages.
- Saves decisions in `pet_brief.json` so the character stays consistent.
- Respects the official Codex pet format: 9 actions, 8 columns, 9 rows.
- Uses the existing `hatch-pet` skill for final package generation instead of rebuilding the spritesheet pipeline.

### User-Friendly Explanation

This tool is for anyone who wants a personal Codex desktop pet without learning image formats, animation frames, or install folders.

The user only needs to answer simple questions:

- What should it look like?
- What personality should it have?
- How should it move when idle, waiting, working, or failing?
- Which preview image do you prefer?
- What must be kept, and what must be avoided?

If the user has a reference image, they can provide it. If not, the skill can generate several directions first. Each round summarizes the decision before moving on.

### Language Switching

After installation, users can start in any supported language:

```text
Help me create a custom Codex desktop pet.
```

They can also switch during the process:

```text
Switch to English.
```

The selected language is stored in `pet_brief.json` under `meta.language`, so later questions, summaries, and confirmation cards follow the same language.

### Architecture

```text
User conversation
  ↓
codex-pet-director: language, interview, confirmation images, character locking
  ↓
pet_brief.json: stores user choices and the 9 action settings
  ↓
imagegen: creates visual confirmation images
  ↓
hatch-pet: produces pet.json + spritesheet.webp
  ↓
Codex pets folder: Codex detects and loads the pet
```

### Why This Design

This skill separates creative direction from final production.

- The director flow turns a vague idea into a stable character.
- `pet_brief.json` locks identity, colors, silhouette, props, and action choices.
- Confirmation images help beginners choose visually instead of writing perfect prompts.
- `hatch-pet` remains responsible for the official spritesheet, `pet.json`, and QA.

This keeps the system maintainable. If Codex changes the pet production format later, the production layer can change without rewriting the whole interview and multilingual guidance layer.

### Requirements

Full pet generation requires:

- Codex desktop pet support
- Python 3
- The `hatch-pet` skill
- Available image generation

The installer safely creates missing local folders when possible. It does not modify the Codex app itself.

### Usage

After installation, no `/` command is needed. Just ask Codex:

```text
Help me create a custom Codex desktop pet.
```

or:

```text
I have a reference image. Turn it into an official Codex desktop pet.
```

## Repository Structure

```text
.
├── codex-pet-director/
│   ├── SKILL.md
│   ├── agents/
│   ├── references/
│   └── scripts/
├── docs/
├── bin/
├── install.cmd
├── install.ps1
├── install.sh
├── package.json
└── README.md
```

## Release Check

```powershell
python C:\Users\Administrator\.codex\skills\.system\skill-creator\scripts\quick_validate.py .\codex-pet-director
python .\codex-pet-director\scripts\check_pet_environment.py --json
python .\codex-pet-director\scripts\pet_brief.py languages
python .\codex-pet-director\scripts\pet_brief.py --help
```
