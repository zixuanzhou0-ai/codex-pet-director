# Codex Pet Director

[简体中文](../README.md#简体中文) · [English](README.en.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · Español · [Français](README.fr.md) · [Deutsch](README.de.md)

`codex-pet-director` es un skill multilingue para crear mascotas de escritorio oficiales de Codex. Primero revisa el entorno del usuario, luego hace preguntas sencillas sobre el personaje, la forma, el estilo, la apariencia, la personalidad y las 9 acciones oficiales. Al final entrega el brief confirmado a `hatch-pet` para generar un paquete listo para Codex.

## Instalación con un comando

La entrada de inicio es `/create-pet`. Si tu versión de Codex no muestra un menú de comandos con `/`, envía `/create-pet` como un mensaje normal.

```text
Use skill-installer to install this GitHub skill: https://github.com/zixuanzhou0-ai/codex-pet-director/tree/main/skills/codex-pet-director
```

Después de instalar, reinicia Codex y escribe:

```text
/create-pet
```

Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

Si descargas el ZIP o clonas el repositorio, también puedes hacer doble clic en `install.cmd`.

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.sh | bash
```

## Qué hace

- Comprueba si Codex puede usar mascotas personalizadas.
- Guía al usuario con preguntas simples.
- Permite cambiar de idioma durante el proceso.
- Genera 2-4 imágenes de confirmación en etapas clave.
- Guarda las decisiones en `pet_brief.json` para mantener la consistencia.
- Respeta el formato oficial de Codex pet: 9 acciones, 8 columnas, 9 filas.
- Delega la generación final a `hatch-pet`.

## Arquitectura

```text
Conversación con el usuario
  ↓
codex-pet-director: idioma, entrevista, imágenes de confirmación, bloqueo del personaje
  ↓
pet_brief.json: guarda decisiones y las 9 acciones
  ↓
imagegen: crea imágenes de confirmación
  ↓
hatch-pet: genera pet.json + spritesheet.webp
  ↓
Carpeta pets de Codex: Codex detecta y carga la mascota
```

## Uso

Después de instalar, escribe esto en Codex:

```text
/create-pet
```
