#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="codex-pet-director"
REPO="${CODEX_PET_DIRECTOR_REPO:-zixuanzhou0-ai/codex-pet-director}"
BRANCH="${CODEX_PET_DIRECTOR_BRANCH:-main}"
DRY_RUN=0

if [ -n "${CODEX_PET_DIRECTOR_INSTALL_ROOT:-}" ]; then
  INSTALL_ROOT="$CODEX_PET_DIRECTOR_INSTALL_ROOT"
elif [ -n "${CODEX_HOME:-}" ]; then
  INSTALL_ROOT="$CODEX_HOME/skills"
else
  INSTALL_ROOT="$HOME/.codex/skills"
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
  printf '%s\n' "Use codex-pet-director to help me create a custom Codex desktop pet."
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

if SOURCE="$(find_local_source)"; then
  :
else
  SOURCE="$(download_source)"
fi

DESTINATION="$INSTALL_ROOT/$SKILL_NAME"

step "Source: $SOURCE"
step "Install target: $DESTINATION"

if [ "$DRY_RUN" -eq 1 ]; then
  step "Dry run only. No files were copied."
  exit 0
fi

mkdir -p "$INSTALL_ROOT"
rm -rf "$DESTINATION"
cp -R "$SOURCE" "$DESTINATION"

step "Installed $SKILL_NAME"
run_environment_check "$DESTINATION"
step "Done. Restart Codex if the skill list has not refreshed yet."
print_next_step
