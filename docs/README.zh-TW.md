# Codex Pet Director

[简体中文](../README.md#简体中文) · [English](README.en.md) · 繁體中文 · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md)

`codex-pet-director` 是一個 Codex 桌面寵物高定制向導 skill。它會先檢查使用者環境，再用簡單問題一步步確認角色、形態、風格、外觀和性格；如果使用者提供參考圖，它會在官方 `192x208` 桌寵邊界內盡量還原，生成通過檢查的 `production_base`，接著用動作導演收集特殊動作需求並補齊 9 個官方動作，最後交給 `hatch-pet` 生成 Codex 可用的寵物包。

完整圖文展示請看 [简体中文](../README.md#真实案例三个可加载宠物) 或 [English](README.en.md#real-pet-showcase)。

## 一鍵安裝

啟動入口是在斜線選單裡搜尋 `create-pet`。你也可以把 `/create-pet` 當普通訊息發出去。

```text
請執行這個安裝命令，幫我安裝 Codex Pet Director：
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

安裝完成後重啟 Codex，然後直接說：

```text
/create-pet
```

啟動後會先讓你選擇新建、繼續或查看，不會直接續跑舊草稿或開始正式生成。

Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

這個安裝器會寫入 skills、本地 plugin package、Codex plugin cache、marketplace 和 `config.toml`。

如果下載 ZIP 或 clone 倉庫，也可以直接雙擊 `install.cmd`。

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.sh | bash
```

## 它能做什麼

- 檢查 Codex 是否能使用自訂 pet。
- 用新手也能懂的問題做角色訪談。
- 中途可以切換語言。
- 在關鍵階段生成 2-4 張確認圖。
- 用 `pet_brief.json` 鎖定角色，避免後續圖片漂移。
- 動作導演會先問使用者有沒有特別想要的動作，再補齊 9 個官方動作。
- 把漂亮確認圖和正式 `production_base` 分開，避免高清插畫直接進入 spritesheet 生產。
- 在交接前輸出 `cell-preview.png` 和 `review.md`，讓使用者確認 192x208 真實尺寸可讀性。
- 在官方 `192x208` 邊界內盡量貼近參考圖，保留最強識別點並簡化小尺寸下會糊掉的細節。
- 遵守 Codex 官方 pet 格式：9 個動作、8 欄、9 列。
- 生成完成後可用 `check_hatch_output.py` 做最終驗收，輸出 contact sheet、row GIF 和 `output_check.json`。
- 最終正式生成交給 `hatch-pet`。

## 底層架構

```text
使用者對話
  ↓
codex-pet-director：語言、訪談、確認圖、角色鎖定
  ↓
pet_brief.json：保存選擇和 9 個動作設定
  ↓
imagegen：生成確認圖
  ↓
Action Director：收集特殊動作需求，補齊 9 個官方動作
  ↓
hatch_pet_handoff.json：明確交接 production_base 和動作設定
  ↓
hatch-pet：生成 pet.json + spritesheet.webp
  ↓
check_hatch_output.py：檢查最終包並生成驗收圖
  ↓
Codex pets 目錄：Codex 識別並載入寵物
```

## 使用方式

安裝後，在 Codex 斜線選單裡搜尋並選擇 `create-pet`。也可以直接發送：

```text
/create-pet
```

接著選擇新建、繼續或查看，再開始環境檢查和角色訪談。
