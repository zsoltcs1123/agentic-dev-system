---
name: phase-breakdown
description: Converts a ROADMAP phase into an actionable task list saved to phases/*.md. Use when breaking down a phase into implementable tasks.
version: 0.1.0
---

# Phase Breakdown

Converts a ROADMAP phase into discrete, implementable tasks.

## Trigger

Use when:

- You have a ROADMAP phase to break down
- User asks to "break down phase X" or "create tasks for phase X"

## Input

- Phase description from ROADMAP or user input
- Phase number/identifier

## Output

- Task list saved to `phases/phase-{number}-{name}.md`

## Procedure

1. Read the phase description
2. Identify discrete, implementable tasks
3. For each task:
   - Assign a task ID (task-001, task-002, etc.)
   - Write a clear, actionable description
   - Note dependencies on other tasks
4. Save to `phases/phase-{number}-{name}.md`

## Output Format

```markdown
# Phase {number}: {name}

## Tasks

### task-001: {title}

{description}
Dependencies: none

### task-002: {title}

{description}
Dependencies: task-001
```
