# Codex Pet Director

[简体中文](../README.md#简体中文) · [English](../README.md#english) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · 한국어 · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md)

`codex-pet-director`는 Codex 공식 데스크톱 펫을 만들기 위한 다국어 skill입니다. 사용자의 환경을 먼저 확인하고, 쉬운 질문으로 캐릭터, 형태, 스타일, 외형, 성격, 9개의 공식 동작을 정한 뒤, 확정된 내용을 `hatch-pet`에 전달해 Codex에서 사용할 수 있는 펫 패키지를 생성합니다.

## 원클릭 설치

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.ps1 | iex"
```

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/zixuanzhou0-ai/codex-pet-director/main/install.sh | bash
```

## 주요 기능

- Codex에서 커스텀 pet을 사용할 수 있는지 확인합니다.
- 한국어, 中文, English, 日本語, Español, Français, Deutsch를 지원합니다.
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

설치 후 Codex에 이렇게 말하세요:

```text
Codex에서 바로 사용할 수 있는 커스텀 데스크톱 펫을 만들어줘.
```
