---
name: dev-cycle
description: Orchestrates the full development cycle for a single task. Sequences Plan, Implement, Review, Verify, Document, Commit, Push-PR with gate enforcement. Use when running a complete task workflow.
version: 0.3.0
---

# Dev Cycle

Orchestrates the complete development workflow for a single task.

## Trigger

Use when:

- User asks to "run dev-cycle for task-XXX"
- Processing a task from `.agents/artifacts/phases/*.md`

## Input

- Task ID or task description
- Optional: phase file reference

## Output

- Pull request created with all gates passed
- All artifacts in `.agents/artifacts/tasks/task-{id}/`

## Artifact Location

All task artifacts are stored in `.agents/artifacts/tasks/task-{id}/`:

```
.agents/artifacts/tasks/task-{id}/
├── task-{id}-plan.md
├── task-{id}-review.md
├── task-{id}-verification.md
├── task-{id}-test-results.md   # Optional
└── task-{id}-state.json
```

## Workflow

```
Plan → Implement → Review → Verify → Document → Commit → Push-PR
                      │         │
                      └─────────┴──▶ (failure: fix and retry gate)
```

## Procedure

### 1. Plan

- Read task description
- Create implementation plan
- Save to `.agents/artifacts/tasks/task-{id}/task-{id}-plan.md`
- Update state: PLANNED

### 2. Implement

- Read plan from `.agents/artifacts/tasks/task-{id}/task-{id}-plan.md`
- Follow rules in `.agents/rules/`
- Write code changes
- Let agent handle lint/test iteration
- Update state: IMPLEMENTED

### 3. Review (Gate)

- Invoke `reviewer` subagent OR run code-review skill
- Save report to `.agents/artifacts/tasks/task-{id}/task-{id}-review.md`
- Must return PASS to proceed
- On ISSUES: fix and re-run review only
- Update state: REVIEWED

### 4. Verify (Gate)

- Invoke `verifier` subagent OR run code-verification skill
- Save report to `.agents/artifacts/tasks/task-{id}/task-{id}-verification.md`
- Compare implementation to plan
- Must return PASS to proceed
- On ISSUES: fix and re-run verify only
- Update state: VERIFIED

### 5. Document

- Run documentation-update skill
- Update affected docs
- Update state: DOCUMENTED

### 6. Commit

- Stage changes
- Commit with descriptive message
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

Update `.agents/artifacts/tasks/task-{id}/task-{id}-state.json` after each step:

```json
{
  "id": "task-001",
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
