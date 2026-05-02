# Codex Pet Director

`codex-pet-director` 是一个 Codex 桌面宠物高定制向导 skill。它会先检查用户环境，再用简单问题一步步确认角色、形态、风格、外观、性格和 9 个官方动作，最后把锁定后的方案交给现有 `hatch-pet` 生成 Codex 可用的宠物包。

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
- 用中文、面向小白的问题做高定制采访。
- 每个关键板块后生成 2-4 张确认图，让用户选择或混合偏好。
- 记录 `pet_brief.json`，避免每轮重新发明角色。
- 明确使用 Codex 官方 pet 固定格式：9 个动作、8 帧、8x9 spritesheet。
- 最终正式生产阶段调用已有 `hatch-pet`，不重写底层 spritesheet 逻辑。

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
python .\codex-pet-director\scripts\pet_brief.py --help
```
