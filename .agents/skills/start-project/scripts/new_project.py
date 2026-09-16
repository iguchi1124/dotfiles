#!/usr/bin/env python3
"""Create project planning documents from the templates bundled with this skill."""

from __future__ import annotations

import argparse
import json
import re
import shutil
import tempfile
from pathlib import Path


SKILL_DIR = Path(__file__).resolve().parent.parent
TEMPLATE_DIR = SKILL_DIR / "assets" / "project-template"
SLUG_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
TOKEN_PATTERN = re.compile(r"{{[A-Z0-9_]+}}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create docs/<slug> from the start-project skill templates."
    )
    parser.add_argument("--slug", required=True, help="kebab-case directory name")
    parser.add_argument("--name", required=True, help="project display name")
    parser.add_argument(
        "--components",
        default="",
        help="comma-separated kebab-case responsibility names",
    )
    parser.add_argument(
        "--source",
        default="TBD",
        help="source document, parent issue, or URL",
    )
    parser.add_argument(
        "--docs-dir",
        type=Path,
        default=Path("docs"),
        help="documentation root (default: ./docs)",
    )
    return parser.parse_args()


def parse_components(raw: str) -> list[str]:
    components = [value.strip() for value in raw.split(",") if value.strip()]
    if len(components) != len(set(components)):
        raise ValueError("--components contains duplicates")
    invalid = [value for value in components if not SLUG_PATTERN.fullmatch(value)]
    if invalid:
        raise ValueError(
            "component names must be kebab-case: " + ", ".join(invalid)
        )
    return components


def display_name(slug: str) -> str:
    return " ".join(part.capitalize() for part in slug.split("-"))


def task_prefix(slug: str) -> str:
    return slug.upper()


def render(template_name: str, values: dict[str, str]) -> str:
    content = (TEMPLATE_DIR / template_name).read_text(encoding="utf-8")
    for key, value in values.items():
        content = content.replace("{{" + key + "}}", value)
    remaining = sorted(set(TOKEN_PATTERN.findall(content)))
    if remaining:
        raise ValueError(
            f"unresolved template tokens in {template_name}: {', '.join(remaining)}"
        )
    return content


def component_rows(components: list[str]) -> str:
    if not components:
        return "| — | コンポーネント別仕様なし | — |"
    return "\n".join(
        f"| `{component}.md` | {display_name(component)} の責務・設計・検証 | {display_name(component)} 担当 |"
        for component in components
    )


def component_task_sections(components: list[str]) -> str:
    if not components:
        return "## 2. コンポーネント別タスク\n\nTBD（必要になったら追加する）"

    sections = []
    for number, component in enumerate(components, start=2):
        label = display_name(component)
        prefix = task_prefix(component)
        sections.append(
            f"## {number}. {label}\n\n"
            f"仕様は `{component}.md` を正とする。\n\n"
            "| ID | タスク | 優先度 | 規模 | 依存 | 状態 |\n"
            "|---|---|---|---|---|---|\n"
            f"| {prefix}-1 | TBD | P1 | M | SPEC-1 | 未着手 |"
        )
    return "\n\n---\n\n".join(sections)


def write_project(
    target: Path,
    name: str,
    slug: str,
    components: list[str],
    source: str,
) -> None:
    component_list = ", ".join(f"`{value}`" for value in components) or "なし"
    values = {
        "PROJECT_NAME": name,
        "PROJECT_TITLE_YAML": json.dumps(f"{name} ドキュメント", ensure_ascii=False),
        "PROJECT_SPEC_TITLE_YAML": json.dumps(f"{name} プロジェクト仕様", ensure_ascii=False),
        "PROJECT_TASKS_TITLE_YAML": json.dumps(f"{name} 実装タスク", ensure_ascii=False),
        "SLUG": slug,
        "SOURCE_YAML": json.dumps(source, ensure_ascii=False),
        "COMPONENT_LIST": component_list,
        "COMPONENT_ROWS": component_rows(components),
        "COMPONENT_TASK_SECTIONS": component_task_sections(components),
        "RELEASE_SECTION_NUMBER": str(max(3, len(components) + 2)),
    }

    (target / "README.md").write_text(
        render("README.md", values), encoding="utf-8"
    )
    (target / "project.md").write_text(
        render("project.md", values), encoding="utf-8"
    )
    (target / "tasks.md").write_text(
        render("tasks.md", values), encoding="utf-8"
    )

    for component in components:
        component_values = values | {
            "COMPONENT": component,
            "COMPONENT_NAME": display_name(component),
            "COMPONENT_TITLE_YAML": json.dumps(
                f"[{name}] {display_name(component)} 仕様", ensure_ascii=False
            ),
        }
        (target / f"{component}.md").write_text(
            render("component.md", component_values), encoding="utf-8"
        )


def main() -> int:
    args = parse_args()
    if not SLUG_PATTERN.fullmatch(args.slug):
        raise SystemExit("error: --slug must be kebab-case")
    if not args.name.strip():
        raise SystemExit("error: --name must not be empty")
    try:
        components = parse_components(args.components)
    except ValueError as error:
        raise SystemExit(f"error: {error}") from error

    docs_dir = args.docs_dir.resolve()
    target = docs_dir / args.slug
    if target.exists():
        raise SystemExit(f"error: destination already exists: {target}")
    if not TEMPLATE_DIR.is_dir():
        raise SystemExit(f"error: bundled template is missing: {TEMPLATE_DIR}")

    docs_dir.mkdir(parents=True, exist_ok=True)
    temporary = Path(tempfile.mkdtemp(prefix=f".{args.slug}.", dir=docs_dir))
    try:
        write_project(temporary, args.name.strip(), args.slug, components, args.source)
        temporary.rename(target)
    except Exception:
        shutil.rmtree(temporary, ignore_errors=True)
        raise

    files = sorted(path.name for path in target.iterdir() if path.is_file())
    tbd_count = sum(
        path.read_text(encoding="utf-8").count("TBD")
        for path in target.iterdir()
        if path.is_file()
    )
    print(f"created: {target}")
    for filename in files:
        print(f"  {filename}")
    print(f"components: {', '.join(components) if components else 'none'}")
    print(f"TBD: {tbd_count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
