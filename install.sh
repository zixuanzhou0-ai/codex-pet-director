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
  if [ -f "$dir/skills/$SKILL_NAME/SKILL.md" ]; then
    printf '%s\n' "$dir/skills/$SKILL_NAME"
    return 0
  fi
  if [ -f "$dir/$SKILL_NAME/SKILL.md" ]; then
    printf '%s\n' "$dir/$SKILL_NAME"
    return 0
  fi
  if [ -f "$(pwd)/skills/$SKILL_NAME/SKILL.md" ]; then
    printf '%s\n' "$(pwd)/skills/$SKILL_NAME"
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
  skill_md="$(find "$tmp" -type f -path "*/skills/$SKILL_NAME/SKILL.md" -print -quit)"
  if [ -z "$skill_md" ]; then
    skill_md="$(find "$tmp" -type f -path "*/$SKILL_NAME/SKILL.md" -print -quit)"
  fi
  if [ -z "$skill_md" ]; then
    echo "Could not find $SKILL_NAME/SKILL.md in the downloaded archive." >&2
    exit 1
  fi

  dirname "$skill_md"
}

source_skill_path() {
  case "${1%/}" in
    */skills/$SKILL_NAME) printf 'skills/%s/SKILL.md\n' "$SKILL_NAME" ;;
    *) printf '%s/SKILL.md\n' "$SKILL_NAME" ;;
  esac
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

update_skill_lock() {
  local installed="$1"
  local skill_path="$2"

  if [ ! -f "$installed/SKILL.md" ]; then
    step "Agents skill lock skipped because the Agents mirror was not installed."
    return 0
  fi

  local python_bin=""
  if command -v python3 >/dev/null 2>&1; then
    python_bin="python3"
  elif command -v python >/dev/null 2>&1; then
    python_bin="python"
  else
    step "Python was not found, so the Agents skill lock was skipped."
    return 0
  fi

  CODEX_PET_DIRECTOR_LOCK_ROOT="$AGENTS_INSTALL_ROOT" \
  CODEX_PET_DIRECTOR_INSTALLED_SKILL="$installed" \
  CODEX_PET_DIRECTOR_REPO_SLUG="$REPO" \
  CODEX_PET_DIRECTOR_SKILL_PATH="$skill_path" \
  "$python_bin" - <<'PY'
import datetime
import hashlib
import json
import os

agents_root = os.environ["CODEX_PET_DIRECTOR_LOCK_ROOT"]
installed = os.environ["CODEX_PET_DIRECTOR_INSTALLED_SKILL"]
repo = os.environ["CODEX_PET_DIRECTOR_REPO_SLUG"]
skill_path = os.environ["CODEX_PET_DIRECTOR_SKILL_PATH"]

def folder_hash(root):
    digest = hashlib.sha1()
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames.sort()
        for filename in sorted(filenames):
            path = os.path.join(dirpath, filename)
            relative = os.path.relpath(path, root).replace(os.sep, "/")
            digest.update((relative + "\n").encode("utf-8"))
            with open(path, "rb") as handle:
                digest.update(handle.read())
            digest.update(b"\n")
    return digest.hexdigest()

agents_home = os.path.dirname(os.path.abspath(agents_root))
lock_path = os.path.join(agents_home, ".skill-lock.json")
if os.path.exists(lock_path):
    with open(lock_path, "r", encoding="utf-8") as handle:
        lock = json.load(handle)
else:
    lock = {"version": 3, "skills": {}}

lock.setdefault("version", 3)
if not isinstance(lock.get("skills"), dict):
    lock["skills"] = {}

existing = lock["skills"].get("codex-pet-director", {})
now = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
lock["skills"]["codex-pet-director"] = {
    "source": repo,
    "sourceType": "github",
    "sourceUrl": f"https://github.com/{repo}.git",
    "skillPath": skill_path,
    "skillFolderHash": folder_hash(installed),
    "installedAt": existing.get("installedAt", now),
    "updatedAt": now,
}

os.makedirs(os.path.dirname(lock_path), exist_ok=True)
with open(lock_path, "w", encoding="utf-8") as handle:
    json.dump(lock, handle, ensure_ascii=False, indent=2)
    handle.write("\n")

print(f"[codex-pet-director] Updated Agents skill lock: {lock_path}")
PY
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
  if [ "$SKIP_AGENTS_MIRROR" -eq 0 ]; then
    step "Would update Agents skill lock under $AGENTS_INSTALL_ROOT"
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
if [ "$SKIP_AGENTS_MIRROR" -eq 0 ]; then
  update_skill_lock "$AGENTS_INSTALL_ROOT/$SKILL_NAME" "$(source_skill_path "$SOURCE")"
fi
run_environment_check "$DESTINATION"
step "Done. Restart Codex if the skill list has not refreshed yet."
print_next_step
