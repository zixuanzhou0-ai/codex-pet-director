# Codex Pet Director

[简体中文](../README.md#简体中文) · [English](README.en.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · Français · [Deutsch](README.de.md)

`codex-pet-director` est un skill multilingue pour créer des animaux de bureau officiels pour Codex. Il vérifie d'abord l'environnement, puis guide l'utilisateur avec des questions simples sur le personnage, la forme, le style, l'apparence, la personnalité et les 9 actions officielles. Le brief validé est ensuite transmis à `hatch-pet` pour générer un paquet utilisable par Codex.

## Installation en une commande

Le point de départ est `create-pet` dans le groupe Skills du menu `/`. Vous pouvez aussi envoyer `/create-pet` comme un message normal.

```text
Run this install command for me:
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

Après l'installation, redémarrez Codex puis demandez :

```text
/create-pet
```

Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

Si vous téléchargez le ZIP ou clonez le dépôt, vous pouvez aussi double-cliquer sur `install.cmd`.

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.sh | bash
```

## Fonctionnalités

- Vérifie si Codex peut utiliser des pets personnalisés.
- Pose des questions simples, adaptées aux débutants.
- Permet de changer de langue pendant le processus.
- Génère 2-4 images de confirmation aux étapes clés.
- Enregistre les décisions dans `pet_brief.json` pour garder le personnage cohérent.
- Respecte le format officiel Codex pet : 9 actions, 8 colonnes, 9 lignes.
- Confie la génération finale à `hatch-pet`.

## Architecture

```text
Conversation utilisateur
  ↓
codex-pet-director : langue, entretien, images de confirmation, verrouillage du personnage
  ↓
pet_brief.json : décisions et 9 actions
  ↓
imagegen : images de confirmation
  ↓
hatch-pet : pet.json + spritesheet.webp
  ↓
Dossier pets de Codex : Codex détecte et charge le pet
```

## Utilisation

Après l'installation, cherchez `create-pet` dans le menu `/`. Vous pouvez aussi envoyer :

```text
/create-pet
```
