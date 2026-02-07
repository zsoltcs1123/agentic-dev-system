---
name: phase-breakdown
description: Converts a ROADMAP phase into an actionable task list saved to a phase folder. Use when breaking down a phase into implementable tasks.
version: 0.2.0
---

# Phase Breakdown

Converts a ROADMAP phase into discrete, implementable tasks.

## Trigger

Use when:

- You have a ROADMAP phase to break down
- User asks to "break down phase X" or "create tasks for phase X"

## Input

- Phase description from ROADMAP or user input
- Phase number/identifier (two digits, e.g., 01, 02, 10)

## Output

- Phase folder created at `.agents/artifacts/phases/phase-{number}-{name}/`
- Task list saved to `phase.md` inside that folder

## Procedure

1. Read the phase description
2. Identify discrete, implementable tasks
3. Create folder `.agents/artifacts/phases/phase-{number}-{name}/`
4. For each task:
   - Assign a phase-prefixed task ID: `p{number}-task-XXX` (e.g., `p01-task-001`)
   - Write a clear, actionable description
   - Note dependencies on other tasks (using full prefixed IDs)
5. Save to `.agents/artifacts/phases/phase-{number}-{name}/phase.md`

## Task ID Format

Task IDs must be prefixed with the phase number:

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
