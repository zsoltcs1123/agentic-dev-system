---
name: plan-task
description: Creates a structured implementation plan for a coding task. Use when asked to "plan pXX-task-XXX", create an implementation plan, or before starting complex development work. Analyzes requirements and codebase context.
metadata:
  version: "0.2.0"
---

# Plan Task

Creates a structured implementation plan before coding begins.

## When to Use

- User asks to "plan pXX-task-XXX"
- Dev-cycle invokes the plan step (full system mode)
- Before implementing any non-trivial change

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`)
- Task description

## Procedure

1. **Parse task ID**: Extract phase number from prefix (e.g., `p01-task-001` → phase `01`)
2. **Locate phase folder**: `.agents/artifacts/phases/phase-{number}-*/`
3. **Clarify requirements**: Ensure the task description is clear. Ask if ambiguous.
4. **Analyze codebase**:
   - Find similar patterns in the codebase
   - Identify files likely to be affected
   - Check for relevant conventions or abstractions
5. **Create task folder** inside phase: `.agents/artifacts/phases/phase-{number}-{name}/tasks/{task-id}/`
6. **Create plan** using the format below
7. **Save** to `{task-folder}/{task-id}-plan.md`
8. **Update task state** to PLANNED

## Plan Format

```markdown
# Task {id}: {title}

## Summary

{One sentence describing what this task accomplishes}

## Approach

{High-level strategy — why this approach over alternatives}

## Files to Modify

| File   | Change         |
| ------ | -------------- |
| {path} | {what and why} |

## Steps

1. {Step with enough detail to execute}
2. {Next step}

## Dependencies

- {What must exist or be true before starting}

## Acceptance Criteria

- [ ] {How to verify this is complete}

## Risks

| Risk    | Mitigation      |
| ------- | --------------- |
| {Issue} | {How to handle} |
```

## Important

Do NOT implement. Only plan.
