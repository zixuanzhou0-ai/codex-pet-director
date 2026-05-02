# 真实用户测试脚本

这个文档用来模拟一个第一次看到 `codex-pet-director` 的用户，检查他是否能从 GitHub 安装并启动这个 skill。

## 测试目标

验证用户能完成这条链路：

```text
打开 GitHub 仓库
  ↓
按 README 安装 skill
  ↓
重启 Codex
  ↓
输入 /create-pet
  ↓
看到环境检查
  ↓
进入宠物定制问答
```

## 测试前准备

建议用一个新 Codex 对话来测，不要在旧对话里测。

如果你想模拟“完全没安装过”的用户，可以先确认本机是否已有这个目录：

```powershell
Test-Path "$env:USERPROFILE\.codex\skills\codex-pet-director"
Test-Path "$env:USERPROFILE\.agents\skills\codex-pet-director"
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
请使用 skill-installer 安装这个 GitHub skill：https://github.com/zixuanzhou0-ai/codex-pet-director/tree/main/skills/codex-pet-director
```

期望结果：

- Codex 使用 `skill-installer` 从 GitHub 安装。
- 安装目标应该是类似：

```text
C:\Users\<用户名>\.codex\skills\codex-pet-director
C:\Users\<用户名>\.agents\skills\codex-pet-director
```

### 3. 重启 Codex

安装完成后，关闭并重新打开 Codex。

期望结果：

- Codex 能发现新 skill。
- 不需要用户知道 skill 的内部文件结构。

### 4. 启动

在 Codex 里输入：

```text
/create-pet
```

如果没有弹出斜杠命令菜单，也直接把它当普通消息发送。

期望结果：

- 它应该先检查环境。
- 它应该说明是否能创建 Codex 官方桌面宠物。
- 如果环境可用，它应该开始问第一个板块的问题：这个宠物是谁、像什么、有无参考图。

## 路线 B：Windows PowerShell 用户

这是给愿意复制命令的用户。

在 PowerShell 里运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

期望结果：

- 下载安装 skill。
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
```

期望结果：

- 从 GitHub 的 `skills/codex-pet-director` 路径安装。
- 写入本机 Agents skills 目录。
- 写入或更新 `.agents/.skill-lock.json`。
- Codex 能在后续会话中发现这个 skill。

## 路线 D：项目自带 npx 安装器

这是给开发者或熟悉终端的用户。

运行：

```bash
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

期望结果：

- 从 GitHub 拉取 package。
- 安装到本机 Codex skills 目录。
- 同步镜像到 Agents skills 目录，并更新 `.agents/.skill-lock.json`，方便 Skill 搜索页和管理器发现。
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
- 9 个官方动作怎么动。

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
- 安装后输入 `/create-pet` 能启动。
- 启动后第一步是环境检查。
- 问题是小白能懂的中文。
- 它不会承诺无限动作、额外帧数、键盘控制或手柄控制。
- 它会明确最终交给 `hatch-pet` 生成官方格式。

## 记录问题

测试时建议记录：

```text
测试日期：
测试系统：
Codex 是否重启：
安装路线：A / B / C / D
是否安装成功：
/create-pet 是否启动：
环境检查是否出现：
第一轮问题是否清楚：
用户卡住的位置：
需要修改 README 的地方：
需要修改 skill 的地方：
```
