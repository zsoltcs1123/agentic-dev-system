---
name: implement-task
description: Implements a single task based on its saved plan file. Writes code following project rules.
version: 0.1.0
---

# Implement Task

Executes an existing implementation plan by writing code.

## Trigger

Use when:

- User asks to "implement task-XXX"
- Dev-cycle invokes the implement step (full system mode)

## Input

- Task ID
- Plan file at `.agents/artifacts/tasks/task-{id}/task-{id}-plan.md`

## Output

- Code changes as described in the plan

## Procedure

1. Read the plan from `.agents/artifacts/tasks/task-{id}/task-{id}-plan.md`
2. Read relevant coding rules from `.agents/rules/`
3. Implement the plan step by step
4. Let the agent's internal loop handle lint/test iteration
5. Update task state to IMPLEMENTED

## Guidelines

- Follow the plan's approach and steps exactly
- Apply rules from `.agents/rules/general.md` and language-specific rule files
- Handle errors explicitly
- Keep changes focused on what the plan specifies

Do NOT create a new plan. Execute the existing plan.
