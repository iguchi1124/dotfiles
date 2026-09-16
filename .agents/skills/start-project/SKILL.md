---
name: start-project
description: Initialize English project planning and specification documents from templates bundled with this skill. Use when asked to start a documented project, create a project-spec draft, or scaffold planning docs. Do not use for codebase scaffolding when no planning-document workflow is requested.
---

# Start a documented project

Generate a self-contained planning workspace from this skill's templates. Repository
instructions determine how the draft is refined, but the skill does not depend on a
repository-local template or generator.

## Inputs

Resolve the workspace root and read the applicable `AGENTS.md` files and relevant
`README.md` sections. Determine:

- a kebab-case project slug;
- a display name;
- the participating components, if the work has separately owned areas; and
- an optional source document or parent issue URL.

Infer inputs only when the request or repository makes them unambiguous. Ask for a
material missing choice. Component identifiers must be kebab-case and should describe
responsibilities such as `backend`, `web`, `mobile`, or `infrastructure`; do not assume
a fixed technology stack.

## Generate

Run the bundled generator from the workspace root:

```bash
python3 <skill-directory>/scripts/new_project.py \
  --slug <project-slug> \
  --name '<display name>' \
  --components backend,web \
  --source '<optional URL or document reference>'
```

`--components` and `--source` are optional. `--docs-dir` defaults to `docs` relative
to the current directory. The generator reads the English templates under
`assets/project-template/`, creates `docs/<slug>/` atomically, and refuses an existing
destination. Do not copy templates by hand or substitute a repository-local template.

Never overwrite, delete, or recreate an existing project directory without explicit
user authorization. A failed run may be retried only after inspecting its output and
confirming the destination was not created.

## Refine the draft

- Populate facts available from the request and repository. Leave `TBD` for unknown
  product or technical decisions instead of fabricating them.
- Adapt component sections to the repository's actual architecture while preserving
  each file's responsibility and avoiding duplicated requirements.
- Apply repository-specific rules for source-of-truth ownership, references,
  privacy, status tracking, and issue transfer.
- Do not add AI attribution or signatures unless the user or repository requires
  them.
- Creating local drafts does not authorize publishing issues, pull requests, or
  other external artifacts.

## Verify and report

Before reporting completion, verify:

- the expected directory and files exist;
- no `{{PLACEHOLDER}}` tokens remain;
- selected components each have one specification file and task section;
- remaining `TBD` values are intentional; and
- version-control status, where applicable, contains no unintended changes.

Report the created paths, selected components, source reference, and remaining
decisions.
