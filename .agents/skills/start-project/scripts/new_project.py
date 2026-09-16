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
TEMPLATE_ROOT = SKILL_DIR / "assets" / "project-template"
SLUG_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
TOKEN_PATTERN = re.compile(r"{{[A-Z0-9_]+}}")
TEXT = {
    "ja": {
        "document_title": "ドキュメント",
        "project_title": "プロジェクト仕様",
        "tasks_title": "実装タスク",
        "component_title": "仕様",
        "component_responsibility": " の責務・設計・検証",
        "component_owner": " 担当",
        "no_component_spec": "コンポーネント別仕様なし",
        "no_components": "なし",
        "component_tasks": "コンポーネント別タスク",
        "add_when_needed": "TBD（必要になったら追加する）",
        "source_of_truth": "仕様は `{component}.md` を正とする。",
        "task_table_header": "| ID | タスク | 優先度 | 規模 | 依存 | 状態 |",
        "task_table_separator": "|---|---|---|---|---|---|",
        "not_started": "未着手",
    },
    "en": {
        "document_title": "Documentation",
        "project_title": "Project Specification",
        "tasks_title": "Implementation Tasks",
        "component_title": "Specification",
        "component_responsibility": " responsibilities, design, and validation",
        "component_owner": " owner",
        "no_component_spec": "No component-specific specification",
        "no_components": "none",
        "component_tasks": "Component Tasks",
        "add_when_needed": "TBD (add when needed)",
        "source_of_truth": "`{component}.md` is the source of truth.",
        "task_table_header": "| ID | Task | Priority | Size | Depends on | Status |",
        "task_table_separator": "|---|---|---|---|---|---|",
        "not_started": "Not started",
    },
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create docs/<slug> from the start-project skill templates."
    )
    parser.add_argument("--slug", required=True, help="kebab-case directory name")
    parser.add_argument("--name", required=True, help="project display name")
    parser.add_argument(
        "--language",
        choices=sorted(TEXT),
        default="ja",
        help="template language (default: ja)",
    )
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


def render(template_dir: Path, template_name: str, values: dict[str, str]) -> str:
    content = (template_dir / template_name).read_text(encoding="utf-8")
    for key, value in values.items():
        content = content.replace("{{" + key + "}}", value)
    remaining = sorted(set(TOKEN_PATTERN.findall(content)))
    if remaining:
        raise ValueError(
            f"unresolved template tokens in {template_name}: {', '.join(remaining)}"
        )
    return content


def component_rows(components: list[str], text: dict[str, str]) -> str:
    if not components:
        return f"| — | {text['no_component_spec']} | — |"
    return "\n".join(
        f"| `{component}.md` | {display_name(component)}{text['component_responsibility']} | {display_name(component)}{text['component_owner']} |"
        for component in components
    )


def component_task_sections(components: list[str], text: dict[str, str]) -> str:
    if not components:
        return f"## 2. {text['component_tasks']}\n\n{text['add_when_needed']}"

    sections = []
    for number, component in enumerate(components, start=2):
        label = display_name(component)
        prefix = task_prefix(component)
        sections.append(
            f"## {number}. {label}\n\n"
            f"{text['source_of_truth'].format(component=component)}\n\n"
            f"{text['task_table_header']}\n"
            f"{text['task_table_separator']}\n"
            f"| {prefix}-1 | TBD | P1 | M | SPEC-1 | {text['not_started']} |"
        )
    return "\n\n---\n\n".join(sections)


def write_project(
    target: Path,
    name: str,
    components: list[str],
    source: str,
    language: str,
) -> None:
    text = TEXT[language]
    template_dir = TEMPLATE_ROOT / language
    component_list = (
        ", ".join(f"`{value}`" for value in components) or text["no_components"]
    )
    values = {
        "PROJECT_NAME": name,
        "PROJECT_TITLE_YAML": json.dumps(
            f"{name} {text['document_title']}", ensure_ascii=False
        ),
        "PROJECT_SPEC_TITLE_YAML": json.dumps(
            f"{name} {text['project_title']}", ensure_ascii=False
        ),
        "PROJECT_TASKS_TITLE_YAML": json.dumps(
            f"{name} {text['tasks_title']}", ensure_ascii=False
        ),
        "SOURCE_YAML": json.dumps(source, ensure_ascii=False),
        "COMPONENT_LIST": component_list,
        "COMPONENT_ROWS": component_rows(components, text),
        "COMPONENT_TASK_SECTIONS": component_task_sections(components, text),
        "RELEASE_SECTION_NUMBER": str(max(3, len(components) + 2)),
    }

    (target / "README.md").write_text(
        render(template_dir, "README.md", values), encoding="utf-8"
    )
    (target / "project.md").write_text(
        render(template_dir, "project.md", values), encoding="utf-8"
    )
    (target / "tasks.md").write_text(
        render(template_dir, "tasks.md", values), encoding="utf-8"
    )

    for component in components:
        component_values = values | {
            "COMPONENT": component,
            "COMPONENT_NAME": display_name(component),
            "COMPONENT_TITLE_YAML": json.dumps(
                f"[{name}] {display_name(component)} {text['component_title']}",
                ensure_ascii=False,
            ),
        }
        (target / f"{component}.md").write_text(
            render(template_dir, "component.md", component_values), encoding="utf-8"
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
    template_dir = TEMPLATE_ROOT / args.language
    if not template_dir.is_dir():
        raise SystemExit(f"error: bundled template is missing: {template_dir}")

    docs_dir.mkdir(parents=True, exist_ok=True)
    temporary = Path(tempfile.mkdtemp(prefix=f".{args.slug}.", dir=docs_dir))
    try:
        write_project(
            temporary,
            args.name.strip(),
            components,
            args.source,
            args.language,
        )
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
    print(f"language: {args.language}")
    print(f"TBD: {tbd_count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
