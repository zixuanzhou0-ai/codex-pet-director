# Codex Pet Director

[简体中文](../README.md#简体中文) · [English](../README.md#english) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · Español · [Français](README.fr.md) · [Deutsch](README.de.md)

`codex-pet-director` es un skill multilingue para crear mascotas de escritorio oficiales de Codex. Primero revisa el entorno del usuario, luego hace preguntas sencillas sobre el personaje, la forma, el estilo, la apariencia, la personalidad y las 9 acciones oficiales. Al final entrega el brief confirmado a `hatch-pet` para generar un paquete listo para Codex.

## Instalación con un comando

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.sh | bash
```

## Qué hace

- Comprueba si Codex puede usar mascotas personalizadas.
- Soporta Español, 中文, English, 日本語, 한국어, Français y Deutsch.
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

Después de instalar, dile a Codex:

```text
Ayúdame a crear una mascota de escritorio personalizada para Codex.
```
