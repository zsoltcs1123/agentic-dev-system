---
name: implement-task
description: Implements a single task based on its saved plan file. Writes code following project rules.
version: 0.2.0
---

# Implement Task

Executes an existing implementation plan by writing code.

## Trigger

Use when:

- User asks to "implement pXX-task-XXX"
- Dev-cycle invokes the implement step (full system mode)

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`)

## Output

- Code changes as described in the plan

## Procedure

1. Parse task ID: extract phase number from prefix (e.g., `p01-task-001` → phase `01`)
2. Locate phase folder: `.agents/artifacts/phases/phase-{number}-*/`
3. Read the plan from `{phase-folder}/tasks/{task-id}/{task-id}-plan.md`
4. Read relevant coding rules from `.agents/rules/`
5. Implement the plan step by step
6. Let the agent's internal loop handle lint/test iteration
7. Update task state to IMPLEMENTED

## Guidelines

- Follow the plan's approach and steps exactly
- Apply rules from `.agents/rules/general.md` and language-specific rule files
- Handle errors explicitly
- Keep changes focused on what the plan specifies

Do NOT create a new plan. Execute the existing plan.
