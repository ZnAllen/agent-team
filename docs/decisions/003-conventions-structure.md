# ADR-003: 兩層式團隊慣例結構 (Two-Layer Conventions Structure)

## Status

Accepted

## Context

The original `docs/conventions.md` (604 lines) mixed three concerns:
1. Universal team norms (git workflow, review etiquette) — apply to ALL projects
2. Tech-stack rules (Next.js, Hono, Drizzle) — only apply to the productivity tool
3. Framework-specific checklists — only relevant for a specific stack

The user's interests span multiple project types: web apps (Next.js), Android native apps (Kotlin/Jetpack Compose), and AI Agents (Python/LangChain). A single `conventions.md` cannot accommodate all.

## Decision

Split conventions into a **two-layer structure**:

```
docs/conventions/
├── index.md              ← Universal conventions (apply to ALL projects)
├── productivity-tool.md  ← Productivity tool specific
├── android-app.md        ← Future Android project
├── ai-agent.md           ← Future AI Agent project
└── template.md           ← Reusable template for new projects
```

### Layer 1: `index.md` (Universal)

- Formatting (Prettier rules)
- Universal naming (variables, functions, types, enums, constants)
- File organization rules
- Import ordering
- TypeScript strict rules
- Git workflow (branch strategy, commit format, PR workflow, review SLAs)
- Testing philosophy (pyramid, what-to-test, what-to-mock, coverage thresholds)
- Review criteria (mandatory checks, general checklist, review etiquette, merge rules)

### Layer 2: `{project-name}.md` (Project-Specific)

- Tech stack map & version policy
- Framework conventions
- Project directory structure
- Framework-specific naming (React components, DB tables, route files)
- Component patterns, state management, styling, error handling
- Tool-specific test configuration (Vitest, Playwright)
- Framework-specific review checklist items

### Template

`template.md` was planned as a skeleton for bootstrapping conventions for new project types but has been deferred — no second project exists yet. When a new project is added, create `template.md` from the structure of an existing conventions file.

## Consequences

### Positive

- **Discoverability** — one place for universal rules, one place per project for specifics
- **Maintainability** — updating git workflow happens once in `index.md`
- **Scalability** — adding an Android project means creating `android-app.md` without touching other files
- **Consistency** — universal rules anchor all projects; per-project files only add what's different

### Negative

- Developers need to check two files instead of one when working in a project
- Slight increase in file count (manageable with the template)

## Alternatives Considered

- **Option A (fully per-project):** Duplicates git workflow and review rules across N files. High maintenance burden.
- **Option C (meta-guide only):** Too abstract to be useful — cannot contain technology-specific rules.
