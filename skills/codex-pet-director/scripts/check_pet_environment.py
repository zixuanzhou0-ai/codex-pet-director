#!/usr/bin/env python3
"""Check whether the local Codex environment can host custom desktop pets."""

from __future__ import annotations

import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass, asdict
from pathlib import Path


@dataclass
class Check:
    name: str
    status: str
    message: str
    path: str | None = None

    @property
    def ok(self) -> bool:
        return self.status == "ok"


def codex_home() -> Path:
    env = os.environ.get("CODEX_HOME")
    if env:
        return Path(env).expanduser()
    return Path.home() / ".codex"


def safe_glob(base: Path, pattern: str) -> list[Path]:
    try:
        return list(base.glob(pattern))
    except Exception:
        return []


def detect_desktop_app(system: str) -> Check:
    candidates: list[Path] = []
    if system == "Windows":
        program_files = Path(os.environ.get("ProgramFiles", r"C:\Program Files"))
        local_app_data = Path(os.environ.get("LOCALAPPDATA", ""))
        candidates.extend(safe_glob(program_files / "WindowsApps", "OpenAI.Codex_*"))
        candidates.extend(safe_glob(local_app_data / "Programs", "*Codex*"))
    elif system == "Darwin":
        candidates.extend([Path("/Applications/Codex.app"), Path.home() / "Applications/Codex.app"])
    else:
        found = shutil.which("codex")
        if found:
            candidates.append(Path(found))

    existing = [p for p in candidates if p.exists()]
    if existing:
        return Check("codex_desktop_app", "ok", "Found Codex desktop app evidence.", str(existing[0]))
    return Check(
        "codex_desktop_app",
        "warn",
        "Could not confirm the Codex desktop app from common locations. Ask the user to confirm the Pets UI if needed.",
    )


def detect_running_codex(system: str) -> Check:
    try:
        if system == "Windows":
            result = subprocess.run(
                ["tasklist", "/FI", "IMAGENAME eq Codex.exe"],
                check=False,
                capture_output=True,
                text=True,
                timeout=5,
            )
            text = result.stdout + result.stderr
            if "Codex.exe" in text:
                return Check("codex_process", "ok", "Codex desktop process is running.")
        else:
            result = subprocess.run(
                ["ps", "-A", "-o", "comm="],
                check=False,
                capture_output=True,
                text=True,
                timeout=5,
            )
            if any("Codex" in line or "codex" in line for line in result.stdout.splitlines()):
                return Check("codex_process", "ok", "Codex process is running.")
    except Exception as exc:
        return Check("codex_process", "warn", f"Could not inspect running processes: {exc}")
    return Check("codex_process", "warn", "Codex does not appear to be running right now.")


def check_directory(path: Path, name: str, fix: bool, dry_run: bool) -> Check:
    if path.exists():
        if path.is_dir():
            return Check(name, "ok", "Directory exists.", str(path))
        return Check(name, "fail", "Path exists but is not a directory.", str(path))
    if fix:
        if dry_run:
            return Check(name, "warn", "Directory is missing; --fix would create it.", str(path))
        try:
            path.mkdir(parents=True, exist_ok=True)
            return Check(name, "ok", "Directory was created.", str(path))
        except Exception as exc:
            return Check(name, "fail", f"Could not create directory: {exc}", str(path))
    return Check(name, "fail", "Directory is missing. Re-run with --fix to create it.", str(path))


def check_writable(path: Path) -> Check:
    if not path.exists() or not path.is_dir():
        return Check("pets_writable", "fail", "Pets directory is not available.", str(path))
    try:
        with tempfile.NamedTemporaryFile(prefix=".codex-pet-write-", dir=path, delete=True) as handle:
            handle.write(b"ok")
            handle.flush()
        return Check("pets_writable", "ok", "Pets directory is writable.", str(path))
    except Exception as exc:
        return Check("pets_writable", "fail", f"Pets directory is not writable: {exc}", str(path))


def run_checks(fix: bool, dry_run: bool) -> dict:
    system = platform.system() or "Unknown"
    home = codex_home()
    pets = home / "pets"
    skills = home / "skills"
    hatch_pet = skills / "hatch-pet"

    checks: list[Check] = [
        Check("platform", "ok", f"Detected {system}."),
        check_directory(home, "codex_home", fix, dry_run),
        check_directory(pets, "pets_directory", fix, dry_run),
        check_directory(skills, "skills_directory", False, dry_run),
        check_directory(hatch_pet, "hatch_pet_skill", False, dry_run),
        detect_desktop_app(system),
        detect_running_codex(system),
    ]
    checks.append(check_writable(pets))

    fail_count = sum(1 for check in checks if check.status == "fail")
    warn_count = sum(1 for check in checks if check.status == "warn")
    ready = fail_count == 0
    if ready and warn_count == 0:
        summary = "Ready to create and install official Codex custom pets."
    elif ready:
        summary = "Local pet folder is usable, but confirm any warnings before final production."
    else:
        summary = "Not ready for final Codex pet production."

    return {
        "ready": ready,
        "summary": summary,
        "codex_home": str(home),
        "pets_dir": str(pets),
        "checks": [asdict(check) for check in checks],
    }


def print_human(report: dict) -> None:
    print(report["summary"])
    print(f"Codex home: {report['codex_home']}")
    print(f"Pets dir:   {report['pets_dir']}")
    for check in report["checks"]:
        label = {"ok": "OK", "warn": "WARN", "fail": "FAIL"}[check["status"]]
        path = f" ({check['path']})" if check.get("path") else ""
        print(f"[{label}] {check['name']}: {check['message']}{path}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fix", action="store_true", help="Create safe local Codex pet directories when missing.")
    parser.add_argument("--dry-run", action="store_true", help="Show what --fix would do without creating directories.")
    parser.add_argument("--json", action="store_true", help="Print machine-readable JSON.")
    args = parser.parse_args(argv)

    report = run_checks(fix=args.fix, dry_run=args.dry_run)
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print_human(report)
    return 0 if report["ready"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
