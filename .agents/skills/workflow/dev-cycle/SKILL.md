---
name: dev-cycle
description: Orchestrates the full development cycle for a single task. Use when asked to "run dev-cycle", "complete task-XXX", or processing tasks from a phase. Sequences Plan → Implement → Review → Verify → Document → Commit → Push-PR with gate enforcement.
metadata:
  version: "0.1.0"
---

# Dev Cycle

Orchestrates the complete development workflow for a single task.

## When to Use

- User asks to "run dev-cycle for pXX-task-XXX"
- Processing a task from a phase file
- Running end-to-end task completion

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`)

## Artifact Location

```
.agents/artifacts/phases/phase-01-core/tasks/p01-task-001/
├── p01-task-001-plan.md
├── p01-task-001-review.md
├── p01-task-001-verification.md
└── p01-task-001-state.json
```

Phase number extracted from task ID prefix (e.g., `p01-task-001` → phase `01`).

## Workflow

```
Plan → Implement → Review → Verify → Document → Commit → Push-PR
                      │         │
                      └─────────┴──▶ (failure: fix and retry gate)
```

## Procedure

See `.agents/AGENTS.md` for path conventions.

### 0. Pre-flight

- Check `dependencies` in state.json
- If any dependency task not DONE → fail with: "Blocked by: {task-ids}"

### 1. Plan

- **Run** `plan-task` skill OR invoke `planner` subagent
- **Skip** if plan already exists
- **Save** to `{phase-folder}/tasks/{task-id}/{task-id}-plan.md`
- **Update state**: PLANNED

### 2. Implement

- **Run** `implement-task` skill OR invoke `implementer` subagent
- **Skip** if code changes already exist
- **Read** plan, follow rules in `.agents/rules/`
- **Update state**: IMPLEMENTED

### 3. Review (Gate)

- **Run** `code-review` skill OR invoke `reviewer` subagent
- **Save** to `{task-id}-review.md`
- **Must PASS** to proceed
- **On ISSUES**: Fix and re-run review only
- **Update state**: REVIEWED

### 4. Verify (Gate)

- **Run** `code-verification` skill OR invoke `verifier` subagent
- **Save** to `{task-id}-verification.md`
- **Must PASS** to proceed
- **On ISSUES**: Fix and re-run verify only
- **Update state**: VERIFIED

### 5. Document

- **Run** `documentation-update` skill
- **Update** affected docs
- **Update state**: DOCUMENTED

### 6. Commit

- **Run** `commit` skill
- **Stage and commit** with descriptive message
- **Update state**: COMMITTED

### 7. Push-PR

- **Run** `push-pr` skill
- **Push** branch and create pull request
- **Update state**: PR_CREATED

## Gate Enforcement

- Review must PASS before Verify
- Verify must PASS before Document
- On failure: fix and retry failed gate only (not full re-plan)
- Max retries: 2 per gate, then escalate to human

## State Tracking

Update `{task-id}-state.json` after each step:

```json
{
  "id": "p01-task-001",
  "phase": "phase-01-core",
  "state": "PR_CREATED",
  "stateHistory": [
    { "state": "PENDING", "timestamp": "..." },
    { "state": "PLANNED", "timestamp": "..." },
    { "state": "IMPLEMENTED", "timestamp": "..." },
    { "state": "REVIEWED", "timestamp": "...", "result": "PASS" },
    { "state": "VERIFIED", "timestamp": "...", "result": "PASS" },
    { "state": "DOCUMENTED", "timestamp": "..." },
    { "state": "COMMITTED", "timestamp": "...", "commit": "abc123" },
    { "state": "PR_CREATED", "timestamp": "...", "pr": "https://..." }
  ]
}
```

## Subagent Strategy

**Required as subagents** (for isolation):

- `reviewer` — quality gate needs clean context
- `verifier` — compliance check needs clean context

**Optional as subagents**:

- `planner` — can run in main context
- `implementer` — can run in main context

## Hooks

Check `.agents/config.json` for optional hooks after each step:

- `afterPlan`, `afterImplement`, `afterReview`, `afterVerify`, `beforeCommit`
- Run hook script if defined
- Continue on success, fail pipeline on error
