# Codex Pet Director

[简体中文](../README.md#简体中文) · [English](README.en.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · Français · [Deutsch](README.de.md)

`codex-pet-director` est un skill pour créer des pets de bureau officiels pour Codex. Il vérifie d'abord l'environnement, puis guide l'utilisateur avec des questions simples sur le personnage, la forme, le style, l'apparence, la personnalité et les 9 actions officielles. Si l'utilisateur donne une image de référence, il la traduit en `production_base` validée pour la limite officielle `192x208` avant de transmettre le brief à `hatch-pet`.

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

Au démarrage, l'outil demande d'abord si vous voulez créer un nouveau pet, continuer un brouillon ou consulter un brouillon. Il ne reprend pas un ancien brouillon et ne lance pas la production finale automatiquement.

Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

Cet installateur écrit les skills, le package plugin local, le cache plugin de Codex, le marketplace et `config.toml`.

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
- Sépare les belles images de confirmation de la vraie `production_base`, afin de ne pas envoyer une illustration trop détaillée directement en production.
- Cherche la ressemblance maximale dans la limite officielle `192x208`, en gardant les traits reconnaissables et en simplifiant les détails fragiles.
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
hatch_pet_handoff.json : transmet production_base et règles d'action
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

Choisissez ensuite créer, continuer ou consulter, puis l'outil lance la vérification d'environnement et l'entretien du personnage.
