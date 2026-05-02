# Codex Pet Director

[简体中文](../README.md#简体中文) · [English](../README.md#english) · 繁體中文 · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md)

`codex-pet-director` 是一個多語言 Codex 桌面寵物高定制向導 skill。它會先檢查使用者環境，再用簡單問題一步步確認角色、形態、風格、外觀、性格和 9 個官方動作，最後把鎖定後的方案交給 `hatch-pet` 生成 Codex 可用的寵物包。

## 一鍵安裝

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.sh | bash
```

## 它能做什麼

- 檢查 Codex 是否能使用自訂 pet。
- 支援繁體中文、簡體中文、English、日本語、한국어、Español、Français、Deutsch。
- 用新手也能懂的問題做角色訪談。
- 中途可以切換語言。
- 在關鍵階段生成 2-4 張確認圖。
- 用 `pet_brief.json` 鎖定角色，避免後續圖片漂移。
- 遵守 Codex 官方 pet 格式：9 個動作、8 欄、9 列。
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
hatch-pet：生成 pet.json + spritesheet.webp
  ↓
Codex pets 目錄：Codex 識別並載入寵物
```

## 使用方式

安裝後，在 Codex 裡說：

```text
幫我定制一個能在 Codex 裡直接使用的桌面寵物。
```
