---
name: dev-cycle
description: Orchestrates the full development cycle for a single task. Sequences Plan, Implement, Review, Verify, Document, Commit, Push-PR with gate enforcement. Use when running a complete task workflow.
version: 0.4.0
---

# Dev Cycle

Orchestrates the complete development workflow for a single task.

## Trigger

Use when:

- User asks to "run dev-cycle for pXX-task-XXX"
- Processing a task from a phase file

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`)

## Output

- Pull request created with all gates passed
- All artifacts in the task folder

## Artifact Location

Task artifacts are stored inside their phase folder:

```
.agents/artifacts/phases/phase-01-core/tasks/p01-task-001/
├── p01-task-001-plan.md
├── p01-task-001-review.md
├── p01-task-001-verification.md
├── p01-task-001-test-results.md   # Optional
└── p01-task-001-state.json
```

The phase number is extracted from the task ID prefix (e.g., `p01-task-001` → phase `01`).

## Workflow

```
Plan → Implement → Review → Verify → Document → Commit → Push-PR
                      │         │
                      └─────────┴──▶ (failure: fix and retry gate)
```

## Procedure

### 1. Plan

- Run `plan-task` skill OR invoke `planner` subagent
- If plan already exists (Cursor-native mode), skip this step
- Save to `{phase-folder}/tasks/{task-id}/{task-id}-plan.md`
- Update state: PLANNED

### 2. Implement

- Run `implement-task` skill OR invoke `implementer` subagent
- If code changes already exist (Cursor-native mode), skip this step
- Read plan from `{phase-folder}/tasks/{task-id}/{task-id}-plan.md`
- Follow rules in `.agents/rules/`
- Update state: IMPLEMENTED

### 3. Review (Gate)

- Invoke `reviewer` subagent OR run code-review skill
- Save report to `{phase-folder}/tasks/{task-id}/{task-id}-review.md`
- Must return PASS to proceed
- On ISSUES: fix and re-run review only
- Update state: REVIEWED

### 4. Verify (Gate)

- Invoke `verifier` subagent OR run code-verification skill
- Save report to `{phase-folder}/tasks/{task-id}/{task-id}-verification.md`
- Compare implementation to plan
- Must return PASS to proceed
- On ISSUES: fix and re-run verify only
- Update state: VERIFIED

### 5. Document

- Run documentation-update skill
- Update affected docs
- Update state: DOCUMENTED

### 6. Commit

- Run `commit` skill
- Stage changes and commit with descriptive message
- Update state: COMMITTED

### 7. Push-PR

- Run push-pr skill
- Push branch to remote
- Create pull request
- Update state: PR_CREATED

## Gate Enforcement

- Review must PASS before Verify
- Verify must PASS before Document
- On failure: fix issues and retry failed gate only (not full re-plan)
- Max retries: 2 per gate, then escalate to human

## State Tracking

Update `{phase-folder}/tasks/{task-id}/{task-id}-state.json` after each step:

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
    {
      "state": "PR_CREATED",
      "timestamp": "...",
      "pr": "https://github.com/..."
    }
  ]
}
```

## Subagent Strategy

Required as subagents (for isolation):

- `reviewer` — quality gate needs clean context
- `verifier` — compliance check needs clean context

Optional as subagents:

- `planner` — can run in main context
- `implementer` — can run in main context
