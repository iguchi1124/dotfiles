#!/usr/bin/env python3
"""Initialize durable Claude Code coordinator state from bundled templates."""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import tempfile
from datetime import datetime
from pathlib import Path


SKILL_DIR = Path(__file__).resolve().parent.parent
TEMPLATE_DIR = SKILL_DIR / "assets" / "project-template"
SLUG_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
DATE_PATTERN = re.compile(r"^[0-9]{8}$")
TOKEN_PATTERN = re.compile(r"{{[A-Z0-9_]+}}")
TEMPLATE_FILES = (
    "project.md",
    "spec.md",
    "tasks.md",
    "progress.md",
    "decisions.md",
    "retro.md",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create .coordinator/<date>-<slug> from bundled templates."
    )
    parser.add_argument("--slug", required=True, help="short kebab-case project slug")
    parser.add_argument("--name", required=True, help="project display name")
    parser.add_argument(
        "--request-file",
        type=Path,
        help="UTF-8 file containing the user's request verbatim",
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=Path.cwd(),
        help="active project or worktree root (default: current directory)",
    )
    parser.add_argument(
        "--date",
        default=datetime.now().astimezone().strftime("%Y%m%d"),
        help=argparse.SUPPRESS,
    )
    return parser.parse_args()


def quote_block(value: str) -> str:
    lines = value.rstrip("\n").splitlines() or [""]
    return "\n".join(">" if not line else f"> {line}" for line in lines)


def render(template_name: str, values: dict[str, str]) -> str:
    content = (TEMPLATE_DIR / template_name).read_text(encoding="utf-8")
    unknown = sorted(
        token
        for token in set(TOKEN_PATTERN.findall(content))
        if token[2:-2] not in values
    )
    if unknown:
        raise ValueError(
            f"unknown template tokens in {template_name}: {', '.join(unknown)}"
        )
    for key, value in values.items():
        content = content.replace("{{" + key + "}}", value)
    return content


def initial_status(root: Path) -> str:
    result = subprocess.run(
        ["git", "status", "--porcelain"],
        cwd=root,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        return "(not a Git worktree)\n"
    return result.stdout if result.stdout else "(clean)\n"


def main() -> int:
    args = parse_args()
    if not SLUG_PATTERN.fullmatch(args.slug):
        raise SystemExit("error: --slug must be short kebab-case")
    if not args.name.strip():
        raise SystemExit("error: --name must not be empty")
    if not DATE_PATTERN.fullmatch(args.date):
        raise SystemExit("error: --date must use YYYYMMDD")
    if not TEMPLATE_DIR.is_dir():
        raise SystemExit(f"error: bundled template is missing: {TEMPLATE_DIR}")

    request = "TBD (replace with the user's request verbatim)"
    if args.request_file is not None:
        request_file = args.request_file.resolve()
        if not request_file.is_file():
            raise SystemExit(f"error: request file not found: {request_file}")
        request = request_file.read_text(encoding="utf-8")

    root = args.root.resolve()
    if not root.is_dir():
        raise SystemExit(f"error: project root not found: {root}")
    status = initial_status(root)
    run_name = f"{args.date}-{args.slug}"
    parent = root / ".coordinator"
    target = parent / run_name
    if target.exists():
        raise SystemExit(f"error: destination already exists: {target}")

    created_at = datetime.now().astimezone().isoformat(timespec="seconds")
    values = {
        "PROJECT_NAME": args.name.strip(),
        "PROJECT_TITLE_YAML": json.dumps(args.name.strip(), ensure_ascii=False),
        "PROJECT_SLUG": args.slug,
        "RUN_NAME": run_name,
        "CREATED_AT": created_at,
        "ORIGINAL_REQUEST_BLOCK": quote_block(request),
    }

    parent.mkdir(parents=True, exist_ok=True)
    temporary = Path(tempfile.mkdtemp(prefix=f".{run_name}.", dir=parent))
    try:
        for template_name in TEMPLATE_FILES:
            (temporary / template_name).write_text(
                render(template_name, values), encoding="utf-8"
            )
        (temporary / "initial-status.txt").write_text(status, encoding="utf-8")
        temporary.rename(target)
    except Exception:
        shutil.rmtree(temporary, ignore_errors=True)
        raise

    print(f"created: {target}")
    for path in sorted(target.iterdir()):
        if path.is_file():
            print(f"  {path.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
