# Codex Pet Director

[简体中文](../README.md#简体中文) · [English](README.en.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · 한국어 · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md)

`codex-pet-director`는 Codex 공식 데스크톱 펫을 만들기 위한 다국어 skill입니다. 사용자의 환경을 먼저 확인하고, 쉬운 질문으로 캐릭터, 형태, 스타일, 외형, 성격, 9개의 공식 동작을 정한 뒤, 확정된 내용을 `hatch-pet`에 전달해 Codex에서 사용할 수 있는 펫 패키지를 생성합니다.

## 원클릭 설치

시작 항목은 슬래시 메뉴의 Skills 그룹에 있는 `create-pet`입니다. `/create-pet`을 일반 메시지로 보내도 됩니다.

```text
Run this install command for me:
npx --yes github:zixuanzhou0-ai/codex-pet-director
```

설치 후 Codex를 다시 시작하고 이렇게 말하세요:

```text
/create-pet
```

시작하면 먼저 새로 만들기, 기존 초안 이어가기, 기존 초안 보기 중에서 선택합니다. 이전 초안을 조용히 이어가거나 바로 최종 생성을 시작하지 않습니다.

Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

이 설치 프로그램은 skills, 로컬 plugin package, Codex plugin cache, marketplace, `config.toml`을 함께 씁니다.

ZIP을 다운로드하거나 저장소를 clone한 경우 `install.cmd`를 더블 클릭해서 설치할 수도 있습니다.

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.sh | bash
```

## 주요 기능

- Codex에서 커스텀 pet을 사용할 수 있는지 확인합니다.
- 초보자도 이해하기 쉬운 질문으로 캐릭터를 설계합니다.
- 진행 중 언어를 바꿀 수 있습니다.
- 중요한 단계마다 2-4장의 확인 이미지를 생성합니다.
- `pet_brief.json`에 결정을 저장해 캐릭터 일관성을 유지합니다.
- Codex 공식 pet 형식을 따릅니다: 9개 동작, 8열, 9행.
- 최종 생성은 `hatch-pet`이 담당합니다.

## 구조

```text
사용자 대화
  ↓
codex-pet-director: 언어, 인터뷰, 확인 이미지, 캐릭터 고정
  ↓
pet_brief.json: 선택 내용과 9개 동작 저장
  ↓
imagegen: 확인 이미지 생성
  ↓
hatch-pet: pet.json + spritesheet.webp 생성
  ↓
Codex pets 폴더: Codex가 펫을 인식하고 로드
```

## 사용 방법

설치 후 슬래시 메뉴에서 `create-pet`을 검색하세요. 일반 메시지로 보낼 수도 있습니다:

```text
/create-pet
```

그다음 새로 만들기, 이어가기, 보기 중 하나를 선택한 뒤 환경 확인과 캐릭터 인터뷰를 시작합니다.
