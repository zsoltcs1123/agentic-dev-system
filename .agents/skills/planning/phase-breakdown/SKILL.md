---
name: phase-breakdown
description: Converts a ROADMAP phase into an actionable task list. Use when asked to "break down phase X", "create tasks for phase", or when starting a new development phase. Outputs structured phase folder with tasks.
metadata:
  version: "0.2.0"
---

# Phase Breakdown

Converts a ROADMAP phase into discrete, implementable tasks.

## When to Use

- You have a ROADMAP phase to break down
- User asks to "break down phase X" or "create tasks for phase X"
- Starting a new development phase

## Input

- Phase description from ROADMAP or user input
- Phase number/identifier (two digits, e.g., 01, 02, 10)

## Procedure

1. **Read phase description**: Understand scope and goals
2. **Identify tasks**: Break into discrete, implementable units
   - Each task should be completable in one dev-cycle
   - Tasks should have clear acceptance criteria
   - Identify dependencies between tasks
3. **Create phase folder**: `.agents/artifacts/phases/phase-{number}-{name}/`
4. **Create phase.md**: Initialize with phase header and empty Tasks section
5. **For each task**: Use `create-task` skill to create the task artifacts
   - Provide: description, phase folder, dependencies
   - `create-task` handles ID generation, state file, and phase.md entry

## Task ID Format

| Phase    | Task ID Format | Example        |
| -------- | -------------- | -------------- |
| Phase 1  | `p01-task-XXX` | `p01-task-001` |
| Phase 2  | `p02-task-XXX` | `p02-task-003` |
| Phase 10 | `p10-task-XXX` | `p10-task-015` |

## Output Format

```markdown
# Phase {number}: {name}

## Tasks

### p{number}-task-001: {title}

{description}
Dependencies: none

### p{number}-task-002: {title}

{description}
Dependencies: p{number}-task-001
```

## Guidelines

- Keep tasks small enough for one dev-cycle
- Order tasks by dependencies (independent tasks first)
- Be specific — vague tasks lead to scope creep

## Related Skills

- `create-task` — Creates individual task artifacts (used by this skill)
