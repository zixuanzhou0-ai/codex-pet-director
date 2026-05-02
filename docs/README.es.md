# Codex Pet Director

[简体中文](../README.md#简体中文) · [English](README.en.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · Español · [Français](README.fr.md) · [Deutsch](README.de.md)

`codex-pet-director` es un skill multilingue para crear mascotas de escritorio oficiales de Codex. Primero revisa el entorno del usuario, luego hace preguntas sencillas sobre el personaje, la forma, el estilo, la apariencia, la personalidad y las 9 acciones oficiales. Al final entrega el brief confirmado a `hatch-pet` para generar un paquete listo para Codex.

## Instalación con un comando

La entrada de inicio es `create-pet` en el grupo Skills del menú `/`. También puedes enviar `/create-pet` como un mensaje normal.

```text
Run this install command for me:
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

Después de instalar, reinicia Codex y escribe:

```text
/create-pet
```

Al iniciar, primero pregunta si quieres crear una mascota nueva, continuar un borrador existente o revisar un borrador. No continúa borradores antiguos ni empieza producción final automáticamente.

Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

Este instalador escribe skills, el paquete plugin local, la cache de plugins de Codex, marketplace y `config.toml`.

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

Después de instalar, busca `create-pet` en el menú `/`. También puedes enviar:

```text
/create-pet
```

Después eliges crear, continuar o revisar, y solo entonces empieza la comprobación del entorno y la entrevista del personaje.
