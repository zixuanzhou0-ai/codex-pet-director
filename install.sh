#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="codex-pet-director"
REPO="${CODEX_PET_DIRECTOR_REPO:-zixuanzhou0-ai/codex-pet-director}"
BRANCH="${CODEX_PET_DIRECTOR_BRANCH:-main}"
DRY_RUN=0
SKIP_AGENTS_MIRROR=0

if [ -n "${CODEX_PET_DIRECTOR_INSTALL_ROOT:-}" ]; then
  INSTALL_ROOT="$CODEX_PET_DIRECTOR_INSTALL_ROOT"
elif [ -n "${CODEX_HOME:-}" ]; then
  INSTALL_ROOT="$CODEX_HOME/skills"
else
  INSTALL_ROOT="$HOME/.codex/skills"
fi

if [ -n "${CODEX_PET_DIRECTOR_AGENTS_INSTALL_ROOT:-}" ]; then
  AGENTS_INSTALL_ROOT="$CODEX_PET_DIRECTOR_AGENTS_INSTALL_ROOT"
elif [ -n "${AGENTS_HOME:-}" ]; then
  AGENTS_INSTALL_ROOT="$AGENTS_HOME/skills"
else
  AGENTS_INSTALL_ROOT="$HOME/.agents/skills"
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      REPO="${2:-}"
      shift 2
      ;;
    --branch)
      BRANCH="${2:-}"
      shift 2
      ;;
    --install-root)
      INSTALL_ROOT="${2:-}"
      shift 2
      ;;
    --agents-install-root)
      AGENTS_INSTALL_ROOT="${2:-}"
      shift 2
      ;;
    --skip-agents-mirror)
      SKIP_AGENTS_MIRROR=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
  esac
done

step() {
  printf '[codex-pet-director] %s\n' "$1"
}

print_next_step() {
  step "Next step: restart Codex if needed, then paste this into Codex:"
  printf '%s\n' "/create-pet"
}

normalize_path_string() {
  local value="$1"
  case "$value" in
    /*) ;;
    *) value="$(pwd)/$value" ;;
  esac
  printf '%s\n' "${value%/}"
}

script_dir() {
  local source="${BASH_SOURCE[0]:-$0}"
  local dir
  dir="$(CDPATH= cd -- "$(dirname -- "$source")" >/dev/null 2>&1 && pwd -P || pwd)"
  printf '%s\n' "$dir"
}

find_local_source() {
  local dir
  dir="$(script_dir)"
  if [ -f "$dir/$SKILL_NAME/SKILL.md" ]; then
    printf '%s\n' "$dir/$SKILL_NAME"
    return 0
  fi
  if [ -f "$(pwd)/$SKILL_NAME/SKILL.md" ]; then
    printf '%s\n' "$(pwd)/$SKILL_NAME"
    return 0
  fi
  return 1
}

download_source() {
  if [ -z "$REPO" ] || [ "$REPO" = "YOUR_GITHUB_USER/codex-pet-director" ]; then
    echo "Set the real GitHub repo first. Replace YOUR_GITHUB_USER/codex-pet-director in install.sh, or run with --repo owner/repo." >&2
    exit 1
  fi

  local tmp tarball skill_md
  tmp="$(mktemp -d)"
  tarball="$tmp/source.tar.gz"
  local archive_url="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"

  step "Downloading $archive_url"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$archive_url" -o "$tarball"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$tarball" "$archive_url"
  else
    echo "curl or wget is required for remote install." >&2
    exit 1
  fi

  tar -xzf "$tarball" -C "$tmp"
  skill_md="$(find "$tmp" -type f -path "*/$SKILL_NAME/SKILL.md" -print -quit)"
  if [ -z "$skill_md" ]; then
    echo "Could not find $SKILL_NAME/SKILL.md in the downloaded archive." >&2
    exit 1
  fi

  dirname "$skill_md"
}

run_environment_check() {
  local installed="$1"
  local check="$installed/scripts/check_pet_environment.py"

  if [ ! -f "$check" ]; then
    step "Environment check script was not found."
    return 0
  fi

  if command -v python3 >/dev/null 2>&1; then
    step "Running environment check"
    python3 "$check" --fix || step "Environment check reported issues. The skill was installed, but Codex pet support may still need attention."
  elif command -v python >/dev/null 2>&1; then
    step "Running environment check"
    python "$check" --fix || step "Environment check reported issues. The skill was installed, but Codex pet support may still need attention."
  else
    step "Python was not found, so the environment check was skipped."
  fi
}

install_skill_copy() {
  local source="$1"
  local root="$2"
  local label="$3"
  local destination="$root/$SKILL_NAME"

  step "$label target: $destination"
  if [ "$DRY_RUN" -eq 1 ]; then
    return 0
  fi

  mkdir -p "$root"
  rm -rf "$destination"
  cp -R "$source" "$destination"
}

if SOURCE="$(find_local_source)"; then
  :
else
  SOURCE="$(download_source)"
fi

DESTINATION="$INSTALL_ROOT/$SKILL_NAME"
SHOULD_MIRROR_TO_AGENTS=1
INSTALL_ROOT_NORMALIZED="$(normalize_path_string "$INSTALL_ROOT")"
AGENTS_INSTALL_ROOT_NORMALIZED="$(normalize_path_string "$AGENTS_INSTALL_ROOT")"
if [ "$SKIP_AGENTS_MIRROR" -eq 1 ] || [ "$INSTALL_ROOT_NORMALIZED" = "$AGENTS_INSTALL_ROOT_NORMALIZED" ]; then
  SHOULD_MIRROR_TO_AGENTS=0
fi

step "Source: $SOURCE"
step "Codex skill root: $INSTALL_ROOT"
if [ "$SHOULD_MIRROR_TO_AGENTS" -eq 1 ]; then
  step "Agents skill mirror root: $AGENTS_INSTALL_ROOT"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  install_skill_copy "$SOURCE" "$INSTALL_ROOT" "Codex skill"
  if [ "$SHOULD_MIRROR_TO_AGENTS" -eq 1 ]; then
    install_skill_copy "$SOURCE" "$AGENTS_INSTALL_ROOT" "Agents skill mirror"
  fi
  step "Dry run only. No files were copied."
  exit 0
fi

install_skill_copy "$SOURCE" "$INSTALL_ROOT" "Codex skill"
step "Installed $SKILL_NAME to Codex skills"
if [ "$SHOULD_MIRROR_TO_AGENTS" -eq 1 ]; then
  install_skill_copy "$SOURCE" "$AGENTS_INSTALL_ROOT" "Agents skill mirror"
  step "Mirrored $SKILL_NAME to Agents skills for skill search discovery"
fi
run_environment_check "$DESTINATION"
step "Done. Restart Codex if the skill list has not refreshed yet."
print_next_step
