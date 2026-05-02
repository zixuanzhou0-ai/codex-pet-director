# Codex Pet Director

`codex-pet-director` 是一个多语言 Codex 桌面宠物高定制向导 skill。它会先检查用户环境，再用简单问题一步步确认角色、形态、风格、外观、性格和 9 个官方动作，最后把锁定后的方案交给现有 `hatch-pet` 生成 Codex 可用的宠物包。

## 一键安装

默认仓库名按当前登录账号设置为 `zixuanzhou0-ai/codex-pet-director`。如果你最后在 GitHub 上用了别的仓库名，再把下面三处里的仓库名改掉：

- `README.md`
- `install.ps1`
- `install.sh`

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.sh | bash
```

## 本地安装

如果用户是下载 zip 或 clone 仓库，可以在仓库根目录运行：

Windows:

```powershell
.\install.ps1
```

macOS / Linux:

```bash
chmod +x ./install.sh
./install.sh
```

安装器会把 `codex-pet-director` 复制到：

- 设置了 `CODEX_HOME` 时：`$CODEX_HOME/skills/codex-pet-director`
- 默认情况：`~/.codex/skills/codex-pet-director`

安装后如果 Codex 没有立刻识别 skill，重启 Codex。

## 这个 skill 做什么

- 检查用户是否具备 Codex pet 使用环境。
- 支持中文、繁體中文、English、日本語、한국어、Español、Français、Deutsch。
- 用面向小白的问题做高定制采访，中途可以切换语言。
- 每个关键板块后生成 2-4 张确认图，让用户选择或混合偏好。
- 记录 `pet_brief.json`，避免每轮重新发明角色。
- 明确使用 Codex 官方 pet 固定格式：9 个动作、8 列、9 行 spritesheet。
- 最终正式生产阶段调用已有 `hatch-pet`，不重写底层 spritesheet 逻辑。

## 给用户看的介绍

这个工具适合想做“自己的 Codex 桌面宠物”的人。用户不需要懂图片格式、动作帧或安装目录，只要回答几个简单问题：

- 它像什么？
- 它是什么性格？
- 它开心、等待、失败时会怎么动？
- 你喜欢哪张确认图？
- 有哪些东西一定要保留，哪些一定不要？

如果用户有参考图，可以直接发给 Codex；如果没有，也可以先生成几种方向让用户选。每一轮都会先总结，再进入下一轮，关键阶段会给 2-4 张确认图。

## 多语言切换

安装后可以直接用任意支持语言开始，例如：

```text
Help me create a custom Codex desktop pet.
```

也可以中途切换：

```text
切换到英文
```

或：

```text
日本語に切り替えて
```

语言选择会记录在 `pet_brief.json` 的 `meta.language` 字段里，后续问题、总结、确认卡片都会跟随这个语言。

## 底层架构

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

## 为什么这样设计

这个 skill 不直接重写宠物生成器，而是把“用户定制”和“正式生产”分开。

- 用户定制阶段负责把模糊想法变成稳定角色。
- `pet_brief.json` 负责锁定角色，避免后续图片越生成越不像。
- 确认图让新手用视觉选择，不需要一开始就写完美提示词。
- `hatch-pet` 继续负责官方格式的 spritesheet、`pet.json` 和 QA。

这样后续更容易维护：如果 Codex 的宠物底层格式变化，主要改生产层；如果用户访谈、语言、风格菜单要升级，则主要改这个 director skill。

## 依赖

完整生成宠物包需要用户本机已经能使用：

- Codex 桌面端的 pet 功能
- Python 3
- `hatch-pet` skill
- 可用的图片生成能力

如果缺少目录，安装器会尝试安全创建。它不会修改 Codex app 本体。

## 使用方式

安装后，在 Codex 里直接说类似：

```text
帮我定制一个能在 Codex 里直接使用的桌面宠物。
```

或：

```text
我有一张参考图，帮我做成 Codex 官方桌面宠物。
```

## 仓库结构

```text
.
├── codex-pet-director/
│   ├── SKILL.md
│   ├── agents/
│   ├── references/
│   └── scripts/
├── install.ps1
├── install.sh
└── README.md
```

## 发布前检查

```powershell
python C:\Users\Administrator\.codex\skills\.system\skill-creator\scripts\quick_validate.py .\codex-pet-director
python .\codex-pet-director\scripts\check_pet_environment.py --json
python .\codex-pet-director\scripts\pet_brief.py languages
python .\codex-pet-director\scripts\pet_brief.py --help
```
