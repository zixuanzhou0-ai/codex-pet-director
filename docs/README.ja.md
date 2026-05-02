# Codex Pet Director

[简体中文](../README.md#简体中文) · [English](README.en.md) · [繁體中文](README.zh-TW.md) · 日本語 · [한국어](README.ko.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md)

`codex-pet-director` は、Codex の公式デスクトップペットを作るための多言語対応 skill です。環境を確認し、やさしい質問でキャラクター、形、スタイル、見た目、性格、9 個の公式アクションを決め、最後に `hatch-pet` に渡して Codex で使えるペットパッケージを生成します。

## ワンクリックインストール

開始入口はスラッシュメニューの Skills にある `create-pet` です。`/create-pet` を通常のメッセージとして送っても使えます。

```text
Run this install command for me:
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

インストール後に Codex を再起動し、次のように依頼します：

```text
/create-pet
```

起動後はまず新規作成、既存下書きの続行、既存下書きの確認を選びます。古い下書きを勝手に続行したり、すぐ本番生成を始めたりしません。

Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

このインストーラーは skills、ローカル plugin package、Codex plugin cache、marketplace、`config.toml` を書き込みます。

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

インストール後はスラッシュメニューで `create-pet` を検索します。通常メッセージとして送ることもできます：

```text
/create-pet
```

その後、新規作成、続行、確認を選んでから、環境チェックとキャラクター質問に進みます。
