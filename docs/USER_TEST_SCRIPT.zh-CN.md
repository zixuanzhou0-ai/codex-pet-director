# 真实用户测试脚本

这个文档用来模拟一个第一次看到 `codex-pet-director` 的用户，检查他是否能从 GitHub 安装并启动这个 skill。

## 测试目标

验证用户能完成这条链路：

```text
打开 GitHub 仓库
  ↓
按 README 运行一键安装器
  ↓
重启 Codex
  ↓
选择 create-pet 或输入 /create-pet
  ↓
选择新建、继续或查看
  ↓
看到环境检查
  ↓
进入宠物定制问答
  ↓
确认概念图和正式角色图
  ↓
生成并检查 192x208-ready production_base
  ↓
动作导演先收集特殊动作需求，再确认或补齐 9 个官方动作
  ↓
确认关键动作预览，生成 hatch_pet_handoff.json 后再进入 hatch-pet
  ↓
检查最终 pet.json + spritesheet.webp 输出
```

## 测试前准备

建议用一个新 Codex 对话来测，不要在旧对话里测。

如果你想模拟“完全没安装过”的用户，可以先确认本机是否已有这个目录：

```powershell
Test-Path "$env:USERPROFILE\.codex\skills\codex-pet-director"
Test-Path "$env:USERPROFILE\.codex\skills\create-pet"
Test-Path "$env:USERPROFILE\.agents\skills\codex-pet-director"
Test-Path "$env:USERPROFILE\.agents\skills\create-pet"
Test-Path "$env:USERPROFILE\plugins\codex-pet-director"
Test-Path "$env:USERPROFILE\.codex\plugins\cache\local-codex-pet-director"
```

如果已经安装过，真实新用户测试会不够纯。可以换一台机器测试，或者手动把旧目录临时改名备份。

## 路线 A：普通 Codex 用户

这是最应该优先测试的路线，因为它不要求用户懂命令行。

### 1. 打开仓库

打开：

```text
https://github.com/zixuanzhou0-ai/codex-pet-director
```

观察点：

- README 顶部是否能立刻看到“快速入口”。
- 用户是否能一眼找到安装句子。
- `/create-pet` 是否足够明显。

### 2. 把安装句子发给 Codex

复制这句话，发给 Codex：

```text
请运行这个安装命令，帮我安装 Codex Pet Director：
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

期望结果：

- Codex 运行 GitHub 项目安装器。
- 安装目标应该是类似：

```text
C:\Users\<用户名>\.codex\skills\codex-pet-director
C:\Users\<用户名>\.codex\skills\create-pet
C:\Users\<用户名>\.agents\skills\codex-pet-director
C:\Users\<用户名>\.agents\skills\create-pet
C:\Users\<用户名>\plugins\codex-pet-director
C:\Users\<用户名>\.codex\plugins\cache\local-codex-pet-director\codex-pet-director\<版本号>
C:\Users\<用户名>\.agents\plugins\marketplace.json
```

### 3. 重启 Codex

安装完成后，关闭并重新打开 Codex。

期望结果：

- Codex 能发现新 skill。
- 不需要用户知道 skill 的内部文件结构。

### 4. 启动

在 Codex 的斜杠菜单里搜索并选择：

```text
create-pet
```

也可以直接发送：

```text
/create-pet
```

如果手动输入完整 `/create-pet` 时显示“无命令”，也直接把它当普通消息发送。第三方 skill 入口需要从菜单里选择才会变成菜单项。

期望结果：

- 它应该先问 `新建宠物`、`继续已有` 或 `查看已有`。
- 如果当前目录已有 `pet_brief.json`，它应该提示发现草稿，但不能自动继续。
- 用户选择 `新建宠物` 或 `继续已有` 后，它应该检查环境。
- 它应该说明是否能创建 Codex 官方桌面宠物。
- 如果环境可用，它应该开始问第一个板块的问题：这个宠物是谁、像什么、有无参考图。

## 路线 B：Windows PowerShell 用户

这是给愿意复制命令的用户。

在 PowerShell 里运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

期望结果：

- 下载安装完整本地 plugin 结构。
- 写入 Codex skills、Agents skills 镜像、本地 plugin package、Codex plugin cache、marketplace 和 `config.toml`。
- 自动运行环境检查。
- 最后提示用户重启 Codex，并输入：

```text
/create-pet
```

## 路线 C：Skills CLI 用户

这是更接近成熟 skill 生态的一种安装方式。

运行：

```bash
npx skills add zixuanzhou0-ai/codex-pet-director --skill codex-pet-director --agent codex -g -y --copy
npx skills add zixuanzhou0-ai/codex-pet-director --skill create-pet --agent codex -g -y --copy
```

期望结果：

- 从 GitHub 的 `skills/codex-pet-director` 和 `skills/create-pet` 路径安装。
- 写入本机 Agents skills 目录。
- 写入或更新 `.agents/.skill-lock.json`。
- Codex 能在后续会话中发现主 skill 和 `create-pet` 入口。

## 路线 D：项目自带 npx 安装器

这是给开发者或熟悉终端的用户。

运行：

```bash
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

期望结果：

- 从 GitHub 拉取 package。
- 安装到本机 Codex skills 目录，包括 `codex-pet-director` 和 `create-pet`。
- 同步镜像到 Agents skills 目录，并更新 `.agents/.skill-lock.json`，方便 Skill 搜索页和管理器发现。
- 写入本地 plugin package、Codex plugin cache、marketplace 和 `config.toml`。
- 输出下一步 `/create-pet`。

## 启动后的测试对话

可以用这个用户身份来测：

```text
我想做一个蓝色机器人猫，像一个陪我写代码的小助手。它不要太幼稚，也不要太写实，要有一点赛博感，但整体还是可爱。我没有参考图。
```

期望它继续问：

- 它是什么形态：全身、半身、头像、漂浮物、小物件拟人。
- 它是什么风格。
- 它是什么性格。
- 它长什么样，哪些要保留，哪些不要。
- 它应该说明：漂亮确认图不是最终生产图，正式生产前会再做一张适合 `192x208` 的 `production_base`。
- 动作导演应该先问用户有没有特别想要的动作表现。
- 如果用户说不出来，它应该根据角色形态、性格和风格推荐完整 9 动作方案。

## production_base 对接测试

这个测试用来确认 `create-pet` 和 `hatch-pet` 没有再把高清图直接混用。

### 场景 1：高清参考图

给用户一个高清插画、自拍、动漫截图或复杂概念图，然后说：

```text
请尽量像这张图，但做成 Codex 官方桌面宠物。
```

期望结果：

- 它应该理解为“在官方桌宠边界内尽量像”，而不是拒绝用户需求。
- 它应该先生成或整理用户确认图，用来确认角色方向。
- 它不应该直接把高清确认图交给 `hatch-pet`。
- 它应该生成一张简化后的 `production_base`，并说明这是为了适配 `192x208` 小尺寸动画资产。
- 它应该运行 `check_pet_asset_fit.py`，输出 `asset_fit.json`、`cell-preview.png` 和 `review.md`。
- 它应该让用户确认真实 `192x208` 单格预览，失败时要求修复或重做 `production_base`。

### 场景 2：合格生产基准图

当 `production_base` 已经是透明或纯色背景、角色清楚、细节不糊、适合 `192x208` 的小桌宠图时，期望结果：

- `production_base` 检查通过。
- 动作导演已经记录 9 个动作的 `final_direction`。
- 用户已经确认 `production_base` 的真实尺寸预览。
- `pet_brief.py validate --stage final` 能通过。
- `build_hatch_handoff.py` 生成 `hatch_pet_handoff.json`。
- 只有在用户明确确认正式生产后，才加载 `hatch-pet`。
- `hatch-pet` 使用 `production_base` 作为主参考，而不是概念图或正式角色大图。
- 生成完成后运行 `check_hatch_output.py`，输出 `output_check.json`、`contact-sheet.png` 和 9 行 row GIF。

## 参考角色联网测试

再开一个新对话，输入 `/create-pet` 后，可以用这个方向测试：

```text
我想做一个像某个动漫角色的 Codex 桌面宠物，但我不太会描述外观。
```

然后给出一个具体名字。

期望结果：

- 它应该先说会查一下这个人物或角色，避免凭记忆做错。
- 它应该联网确认这个人物或角色的外观和版本。
- 如果名字有多个版本，它应该先问你要哪个版本。
- 它应该先给出“参考角色识别卡”，让你确认关键外观。
- 你确认后，它才开始生成 2-4 张视觉确认图。

## 成功标准

一次测试算成功，需要满足：

- 用户能从 README 找到安装方法。
- 用户不需要理解 `SKILL.md`、`pet_brief.json`、spritesheet。
- 安装后选择 `create-pet` 或输入 `/create-pet` 能启动。
- 裸 `/create-pet` 启动后第一步是模式选择，不会自动续跑旧草稿。
- 选择新建或继续后会进行环境检查。
- 问题是小白能懂的中文。
- 它不会承诺无限动作、额外帧数、键盘控制或手柄控制。
- 它会把“尽量像参考图”解释为“在官方 `192x208` 桌宠边界内尽量像”。
- 它会区分确认图、正式角色图和 `production_base`。
- `production_base` 不通过检查时，不会进入 `hatch-pet` 正式生产。
- 它会先问特殊动作需求，再补齐 9 个官方动作，而不是直接丢给用户 9 个表格问题。
- 它会在正式生产前生成 `hatch_pet_handoff.json`。
- 它会明确最终交给 `hatch-pet` 生成官方格式。
- 它会对最终 `pet.json` 和 `spritesheet.webp` 做 Director 层验收。

## 记录问题

测试时建议记录：

```text
测试日期：
测试系统：
Codex 是否重启：
安装路线：A / B / C / D
是否安装成功：
create-pet 是否能在斜杠菜单搜索到：
/create-pet 普通消息是否启动：
Codex plugin cache 是否生成：
环境检查是否出现：
第一轮问题是否清楚：
是否说明 production_base：
production_base 是否通过检查：
production_base 真实尺寸预览是否确认：
动作导演是否先问特殊动作需求：
9 个动作 final_direction 是否齐全：
hatch_pet_handoff.json 是否生成：
check_hatch_output.py 是否输出验收文件：
用户卡住的位置：
需要修改 README 的地方：
需要修改 skill 的地方：
```
