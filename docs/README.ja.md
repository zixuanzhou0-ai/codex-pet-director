# Codex Pet Director

[简体中文](../README.md#简体中文) · [English](README.en.md) · [繁體中文](README.zh-TW.md) · 日本語 · [한국어](README.ko.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md)

`codex-pet-director` は、Codex の公式デスクトップペットを作るための多言語対応 skill です。環境を確認し、やさしい質問でキャラクター、形、スタイル、見た目、性格、9 個の公式アクションを決め、最後に `hatch-pet` に渡して Codex で使えるペットパッケージを生成します。

## ワンクリックインストール

開始入口は `/create-pet` です。Codex にスラッシュコマンドメニューが表示されない場合でも、`/create-pet` を通常のメッセージとして送れば使えます。

```text
Use skill-installer to install this GitHub skill: https://github.com/zixuanzhou0-ai/codex-pet-director/tree/main/skills/codex-pet-director
```

インストール後に Codex を再起動し、次のように依頼します：

```text
/create-pet
```

Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

ZIP をダウンロードした場合、またはリポジトリを clone した場合は、`install.cmd` をダブルクリックしてインストールできます。

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.sh | bash
```

## できること

- Codex がカスタム pet を使える環境か確認します。
- 初心者向けの短い質問でペットの方向性を決めます。
- 途中で言語を切り替えられます。
- 重要な段階で 2-4 枚の確認画像を生成します。
- `pet_brief.json` に決定内容を保存し、キャラクターの一貫性を保ちます。
- Codex 公式 pet 形式に従います：9 アクション、8 列、9 行。
- 最終生成は `hatch-pet` に任せます。

## アーキテクチャ

```text
ユーザーとの会話
  ↓
codex-pet-director：言語、質問、確認画像、キャラクター固定
  ↓
pet_brief.json：選択内容と 9 アクションを保存
  ↓
imagegen：確認画像を生成
  ↓
hatch-pet：pet.json + spritesheet.webp を生成
  ↓
Codex pets フォルダ：Codex がペットを読み込む
```

## 使い方

インストール後、Codex にこう入力します：

```text
/create-pet
```
