---
name: plan-task
description: Creates a structured implementation plan for a coding task. Use when asked to "plan pXX-task-XXX", create an implementation plan, or before starting complex development work. Analyzes requirements and codebase context.
metadata:
  version: "0.1.0"
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

See `.agents/AGENTS.md` for path conventions, output limits, and rules loading.

1. **Find relevant rules** in `.agents/rules/`:
   - Planning
   - Coding standards
   - Testing standards
   - Language specific rules
2. **Parse task ID**: Extract phase number from prefix
3. **Locate phase folder**
4. **Clarify requirements**: Ensure the task description is clear. Ask if ambiguous.
5. **Analyze codebase**:
   - Find similar patterns in the codebase
   - Identify files likely to be affected
   - Check for relevant conventions or abstractions
6. **Create task folder** inside phase: `.agents/artifacts/phases/phase-{number}-{name}/tasks/{task-id}/`
7. **Create plan** using the format below
8. **Save** to `{task-folder}/{task-id}-plan.md`
9. **Update task state** to PLANNED

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

## Error Handling

- Task doesn't exists → ask if it should be created - use create-task skill
- Plan already exists → prompt: overwrite or skip?
- Phase not found → fail with: "Phase folder not found for {task-id}"
- Ambiguous requirements → ask user to clarify before proceeding

## Important

Do NOT implement. Only plan.
