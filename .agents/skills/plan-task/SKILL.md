---
name: plan-task
description: Creates an implementation plan for a single task. Analyzes requirements and codebase, outputs structured plan to task artifacts folder.
version: 0.1.0
---

# Plan Task

Creates a structured implementation plan for a single task.

## Trigger

Use when:

- User asks to "plan task-XXX"
- Dev-cycle invokes the plan step (full system mode)

## Input

- Task ID and description
- Optional: phase file reference

## Output

- Plan saved to `.agents/artifacts/tasks/task-{id}/task-{id}-plan.md`

## Procedure

1. Read the task description
2. Analyze the codebase to understand context
3. Create folder `.agents/artifacts/tasks/task-{id}/` if it doesn't exist
4. Create a structured implementation plan
5. Save to `.agents/artifacts/tasks/task-{id}/task-{id}-plan.md`
6. Update task state to PLANNED

## Plan Format

```markdown
# Task {id}: {title}

## Approach

{High-level approach to implementation}

## Files to Modify

- {file1}: {what changes}
- {file2}: {what changes}

## Steps

1. {First step}
2. {Second step}

## Risks

- {Potential issue and mitigation}
```

Do NOT implement the plan. Only create it.
