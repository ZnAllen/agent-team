# User Journey Maps — Productivity Tool for Small Dev Teams

> Last updated: 2026-06-20

---

## Journey 1: Daily Flow — "A day in the life of Priya"

### Morning: Catching up
1. Opens tool — sees a **digest** of what happened since she last checked (PRs merged, new comments on her tasks, blockers resolved)
2. Scans the **team view** — sees what everyone is working on (auto-populated from task assignments + git activity)
3. Picks a task from her queue — tool suggests next priority based on goals + deadlines

### Deep work: Shipping
4. Clicks "Start task" — tool auto-creates a branch from latest main, links branch to task
5. Codes, commits, pushes — tool automatically updates task status to "In Progress"
6. Opens PR — tool auto-transitions task to "In Review", notifies reviewers
7. PR gets approved and merged — tool moves task to "Done", asks Priya if it should close

### Wrap-up: Review
8. Tool sends a short async summary to Slack: "You closed 2 tasks today. 1 PR needs your review."

**Pain points this addresses:**
- ❌ No manual status updates
- ❌ No context-switching to a separate tool
- ❌ No "what did I miss?" anxiety

---

## Journey 2: Planning Cycle — "Marcus sets the direction"

### Kickoff
1. Marcus opens the **roadmap view** — sees current cycle's goals + tasks grouped under them
2. Drops in 3–5 goals for the next cycle from ideas he's collected in the backlog
3. Tool auto-suggests tasks from the backlog that align with each goal

### Daily check-in
4. Marcus opens the **cycle dashboard** — sees burn-up chart of tasks completed vs planned
5. Notices a blocker on a critical task — tool surfaces it with a warning badge
6. Marcus comments on the task to unblock: "Try approach B, I reviewed the API docs"

### Retrospective
7. At cycle end, tool generates a **retro summary**: what shipped, cycle time, what was descoped
8. Marcus exports a short update for the broader team/stakeholders

**Pain points this addresses:**
- ❌ No rigid sprint ceremonies
- ❌ No manual chart building
- ❌ No separate status-report writing

---

## Journey 3: Onboarding — "Yuki joins the team"

### Day 1
1. Yuki gets an invite link — opens the tool, sees a **team overview** with faces + roles + what each person is working on
2. Opens the single project she's assigned to — sees the **board** with only 4 columns: Backlog / Doing / In Review / Done
3. Reads the **linked GitHub repo** — all PRs and commits are visible inline on tasks

### First task
4. Yuki opens a task assigned to her — the **description** includes a clear problem statement + acceptance criteria + linked GH issue
5. Comments ask for clarification — gets an answer within 2 hours (async)
6. Starts working — tool creates a branch for her automatically

### Ongoing
7. Tool sends Yuki a daily email digest: "Tasks updated, PRs to review, comments for you"
8. She never needs to attend a standup — her status is visible through her activity

**Pain points this addresses:**
- ❌ No custom workflow to learn
- ❌ No meeting required to get context
- ❌ No fear of being forgotten as a remote contributor
