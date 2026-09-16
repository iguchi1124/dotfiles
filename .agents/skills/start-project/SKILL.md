---
name: start-project
description: Initialize project planning or specification documents from a repository's existing templates, generators, and conventions. Use when asked to start a documented project, create a project-spec draft, or scaffold planning docs. Do not use for codebase scaffolding when no planning-document workflow is requested.
---

# Start a documented project

Create the repository-native project documentation without importing assumptions from
another project. Repository instructions and the discovered template contract take
precedence over this general workflow.

## Discover the local contract

1. Resolve the workspace root, documentation root, and any target repositories. Read
   the applicable `AGENTS.md` files and the relevant parts of `README.md`.
2. Search for project-start instructions, generators, and templates. Check likely
   locations such as repository skills, `scripts/`, `tools/`, package tasks,
   `docs/_template/`, and the documentation index. Prefer `rg` and `rg --files` for
   discovery.
3. If a repository-local start-project skill or guide exists, read it completely and
   follow it. Do not assume another assistant's configuration applies unless the
   repository instructions explicitly route to it.
4. Derive required inputs from the local contract. Typical inputs include a slug,
   display name, participating components, source or parent issue, and an alternate
   output directory. Infer values only when the user's request or repository makes
   them unambiguous; ask for a material missing choice.

## Generate safely

- Prefer the repository's maintained generator over manually copying a template.
  Inspect its help or source first so supported arguments, defaults, and side effects
  are understood.
- Confirm the destination before writing. Never overwrite, delete, or "start over"
  from an existing project directory without explicit user authorization.
- Pass only supported values and preserve repository-defined naming rules. Use an
  alternate output option for validation when the generator provides one.
- If there is a template but no generator, reproduce the documented copy,
  substitution, component-selection, numbering, and index-registration behavior.
  Avoid broad replacements outside the new project and its documented index entry.
- If neither a template nor a local workflow exists, do not invent a large document
  taxonomy. Build only the smallest planning structure supported by the request and
  current repository conventions, or ask for the intended format when that choice is
  consequential.
- Treat a failed run as potentially partial. Inspect its output and report the state;
  do not remove or overwrite partial files automatically.

## Refine the draft

- Populate facts available from the user's request and repository. Keep explicit
  placeholders for unknown product decisions instead of fabricating them.
- Preserve each file's intended responsibility, frontmatter, headings, and status
  vocabulary. Apply repository-specific rules for source-of-truth ownership,
  cross-document references, issue transfer, privacy, and progress tracking.
- Do not add AI attribution or signatures unless the user or repository requires
  them.
- Creating local drafts does not authorize publishing issues, pull requests, or
  other external artifacts.

## Verify and report

Before reporting completion, verify:

- the expected directory and files exist;
- required template tokens were replaced and remaining placeholders are intentional;
- selected and omitted components match the request;
- any required documentation index was updated exactly once;
- generated links, frontmatter, numbering, and status values satisfy the local
  contract; and
- version-control status, where applicable, contains no unintended changes.

Report the created paths, registration result, important defaults or inferred
choices, and the remaining placeholders or next decisions.
