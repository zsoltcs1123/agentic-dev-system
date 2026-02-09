---
name: implement-task
description: Implements a single task by executing its saved plan file. Use when asked to "implement task-XXX", execute a plan, or write code for a planned task. Writes code following project rules.
metadata:
  version: "0.1.0"
---

# Implement Task

Executes an existing implementation plan by writing code.

## When to Use

- User asks to "implement pXX-task-XXX"
- Dev-cycle invokes the implement step (full system mode)
- A plan exists and is ready for execution

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`)

## Procedure

See `.agents/AGENTS.md` for path conventions.

1. **Parse task ID**: Extract phase number from prefix
2. **Locate phase folder**
3. **Read the plan** from `{phase-folder}/tasks/{task-id}/{task-id}-plan.md`
4. **Verify plan is current**: If plan references files/patterns that no longer exist, stop and flag for re-planning
5. **Read relevant coding rules** from `.agents/rules/`
6. **Implement step by step**:
   - Follow the plan's steps in order
   - Check each acceptance criterion as you go
   - Handle errors explicitly — don't swallow exceptions
7. **Iterate on quality**: Let the agent's internal loop handle lint/test fixes
8. **Update task state** to IMPLEMENTED

## Guidelines

- Follow the plan exactly — don't add scope
- Apply project rules from `.agents/rules/`
- Keep changes minimal and focused
- If the plan is unclear, ask before guessing

## Error Handling

- Plan file not found → fail with: "No plan found for {task-id}. Run plan-task first."
- Phase folder not found → fail with: "Phase folder not found for {task-id}"
- Plan is stale (references non-existent files) → fail with: "Plan references outdated files. Re-run plan-task."
- State file missing → create minimal state.json with current state
- Implementation blocked by missing dependency → fail with: "Blocked: {dependency} not available"

## Important

1. Do NOT create a new plan. Execute the existing plan.
2. Only read the rules that are relevant to the task.
