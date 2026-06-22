# Project-Specific Agent Instructions

## Session Start — Optional Daily Tech Scan

When a new session begins, you may optionally run:

1. Call `@memory-keeper 執行每日技術掃描` to produce `docs/session-notes/daily-tech-YYYY-MM-DD.md`
2. Summarize key findings to the user

## Tiered Routing Protocol

Follow the global AGENTS.md routing protocol:
- **Tier 1** — Lead direct (simple research/query tasks handled by me)
- **Tier 2** (`@code-writer-xxx`, `@test-writer`, etc.) — Implementation/test tasks via cloud API
- **Tier 3** (Lead direct) — Architecture/design/security/strategy tasks
