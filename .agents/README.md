# Agentic Dev System

A portable, composable framework for AI-assisted development workflows. Works with Cursor, Claude Code, Codex, Gemini, or any agent that reads markdown.

## Core Principles

1. **Single source of truth** — Skills and rules live in `.agents/`, agent-specific folders use symlinks
2. **Portable** — No vendor lock-in; any agent that reads markdown works
3. **Lean context** — `AGENTS.md` files are brief; details live in skills/rules
4. **Composable** — Every skill works standalone or as part of the dev-cycle orchestrator
5. **State in files** — All task artifacts grouped by phase in `.agents/artifacts/phases/`
6. **Portable skills** — Skills contain minimal, generic instructions. Project-specific conventions belong in `.agents/rules/`

## Structure

```
.agents/
├── config.json   # System configuration
├── skills/       # Workflows (the logic)
├── agents/       # Subagent definitions (thin wrappers)
├── rules/        # Coding conventions
└── artifacts/
    └── phases/
        └── phase-01-core/
            ├── phase.md           # Phase description and task list
            └── tasks/
                └── p01-task-001/  # Task artifacts (plan, review, state)
```

Agent-specific folders (`.cursor/`, `.claude/`, `.gemini/`) contain symlinks to `.agents/skills/`.

## Dev-Cycle Pipeline

Every task follows this pipeline:

```
Plan ──▶ Implement ──▶ Review ──▶ Verify ──▶ Document ──▶ Commit ──▶ Push-PR
                         │          │
                         └──────────┴──▶ (failure: fix and retry)
```

| Step      | Skill                  | Subagent      | Gate           |
| --------- | ---------------------- | ------------- | -------------- |
| Plan      | `plan-task`            | `planner`     | Human approval |
| Implement | `implement-task`       | `implementer` | Lint/test pass |
| Review    | `code-review`          | `reviewer`    | PASS required  |
| Verify    | `code-verification`    | `verifier`    | PASS required  |
| Document  | `documentation-update` | —             | None           |
| Commit    | `commit`               | —             | None           |
| Push-PR   | `push-pr`              | —             | None           |

**Gate enforcement:** Review must PASS before Verify. On failure, fix issues and re-run only the failed gate. Max 2 retries per gate, then escalate to human.

**Subagent strategy:**

- **Required as subagents:** Review, Verify (quality gates need context isolation)
- **Optional as subagents:** Plan, Implement (can run in main context or as subagents)

### Task State Machine

```
PENDING → PLANNED → IMPLEMENTED → REVIEWED → VERIFIED → DOCUMENTED → COMMITTED → PR_CREATED → DONE
                          │            │
                          └────────────┴──▶ (failure: back to IMPLEMENTED or BLOCKED)
```

## Usage

### Usage Modes

**Cursor-native mode** — Use Cursor's built-in Plan Mode (Shift+Tab) for planning and its Build button for implementation. The remaining steps use the system's skills. Best for complex features with unanswered questions.

**Full system mode** — All steps use skills and subagents, including `plan-task` and `implement-task`. Best for well-defined tasks, CLI-driven workflows, and headless/CI execution.

Both modes share the same pipeline, artifact structure, and quality gates.

### Composability

Every skill works standalone. Use one skill, chain a few, or run the full dev-cycle — match your workflow to the task:

```
# Single skill — quick code review on current changes
"Review my changes"

# Partial pipeline — already implemented, just need QA
"Review my changes for p01-task-001"
"Verify changes for p01-task-001"

# Full dev-cycle — hands-off automation
"Run dev-cycle for p01-task-001"
```

No lock-in to the full pipeline. Start small, add steps as needed.

### Running Steps

```
# Individual steps (chat):
"Plan p01-task-001: add user authentication"
"Implement the plan for p01-task-001"
"Review my changes for p01-task-001"
"Verify changes for p01-task-001"
"Update documentation"
"Commit p01-task-001"
"Push and create PR"

# Full dev-cycle:
"Run dev-cycle for p01-task-001"

# CLI:
agent -p "Follow .agents/skills/workflow/dev-cycle/SKILL.md for task: p01-task-001"
```

## Skills

### Planning

| Skill             | Purpose            |
| ----------------- | ------------------ |
| `project-planner` | Strategic planning |
| `phase-breakdown` | Roadmap → Tasks    |
| `create-task`     | Task factory       |

### Workflow

| Skill                  | Purpose            |
| ---------------------- | ------------------ |
| `plan-task`            | Create task plan   |
| `implement-task`       | Execute plan       |
| `code-review`          | Quality gate       |
| `code-verification`    | Plan compliance    |
| `documentation-update` | Keep docs in sync  |
| `commit`               | Stage and commit   |
| `push-pr`              | Push and create PR |
| `dev-cycle`            | Orchestrator       |

## Subagents

Subagents are thin wrappers that delegate to skills. They provide context isolation, cost efficiency (faster models for focused tasks), and clean file-based handoffs.

| Subagent      | Skill               | Model     | Required |
| ------------- | ------------------- | --------- | -------- |
| `planner`     | `plan-task`         | `default` | No       |
| `implementer` | `implement-task`    | `default` | No       |
| `reviewer`    | `code-review`       | `fast`    | Yes      |
| `verifier`    | `code-verification` | `fast`    | Yes      |

Subagent file format:

```markdown
---
name: reviewer
description: Code quality review.
model: fast
tools: Read, Grep, Glob
---

You are a code reviewer. Read and follow `.agents/skills/workflow/code-review/SKILL.md`.
```

## Artifacts & State

Tasks are organized by phase. Each phase folder contains a `phase.md` and a `tasks/` subfolder:

```
.agents/artifacts/phases/phase-01-core/
├── phase.md              # Phase description and task list
└── tasks/
    └── p01-task-001/     # Task folder (phase-prefixed ID)
        ├── p01-task-001-plan.md
        ├── p01-task-001-review.md
        ├── p01-task-001-verification.md
        └── p01-task-001-state.json
```

### Task ID Format

Task IDs are prefixed with the phase number to prevent collisions and provide context:

| Phase    | Task ID Format | Example        |
| -------- | -------------- | -------------- |
| Phase 1  | `p01-task-XXX` | `p01-task-001` |
| Phase 2  | `p02-task-XXX` | `p02-task-003` |
| Phase 10 | `p10-task-XXX` | `p10-task-015` |

**Cursor Plan Mode note:** Cursor saves plans to `~/.cursor/plans/` by default. After using Cursor's Plan Mode, manually save the plan markdown into the appropriate task folder to integrate with the task system.

### State File

State file example (`.agents/artifacts/phases/phase-01-core/tasks/p01-task-001/p01-task-001-state.json`):

```json
{
  "id": "p01-task-001",
  "description": "Add user authentication",
  "phase": "phase-01-core",
  "trackerId": "PVTI_abc123",
  "state": "REVIEWED",
  "stateHistory": [
    { "state": "PENDING", "timestamp": "..." },
    { "state": "PLANNED", "timestamp": "..." },
    { "state": "IMPLEMENTED", "timestamp": "..." },
    { "state": "REVIEWED", "timestamp": "...", "result": "PASS" }
  ],
  "commits": ["abc123"],
  "failures": []
}
```

## Configuration

System settings live in `.agents/config.json`.

### Task Schema

Task fields are configurable in `config.json`. Example adding custom fields:

```json
{
  "tasks": {
    "fields": [
      "id",
      "description",
      "phase",
      "state",
      "priority",
      "assignee",
      "estimate"
    ]
  }
}
```

### GitHub Integration

The `push-pr` skill requires GitHub access. One of the following must be available:

| Option         | How                                                  | Notes                                        |
| -------------- | ---------------------------------------------------- | -------------------------------------------- |
| **GitHub CLI** | `gh` installed and authenticated                     | Works everywhere, no MCP setup needed        |
| **GitHub MCP** | MCP server configured (e.g. `@anthropic/github-mcp`) | Richer integration: read issues, PR comments |

The `push-pr` skill auto-detects which is available.

## Conventions

### AGENTS.md Files

Root and subdirectory `AGENTS.md` files contain brief project context and pointers to rules/skills. Keep under ~50 lines.

```markdown
# AGENTS.md (example)

## Overview

[1-2 sentences about this project/feature]

## Constraints

- [Hard limits, known issues]

## Rules

Coding conventions in `.agents/rules/`. Read relevant rule files based on context.

## Skills

Workflows in `.agents/skills/`. Read SKILL.md in each folder when needed.
```

### Rules Files

Rules in `.agents/rules/` define coding standards. One file per language or topic.

```markdown
# [Language/Topic] Rules

## [Category]

- [Rule]: [Brief rationale]

## Anti-patterns

- [What to avoid]: [Why]
```

Keep rules actionable and concise. Agents have limited context.

## Project Tracker Integration

Tracker integration is **not baked in** — it lives outside the core system as scripts you run manually, in CI, or via [Cursor hooks](https://cursor.com/docs/agent/hooks).

The system outputs standard file formats (`phase.md`, `state.json`) that scripts can consume:

```
phase-breakdown (LLM)
      │
      v
phases/phase-XX-name/phase.md    ← Standard format
      │
      v
sync-phase.sh (script)           ← Your automation
      │
      v
GitHub Projects / Linear / etc.
```

### Integration Options

**Manual/CI** — Run scripts when needed or on push/merge.

**Cursor Hooks** — Auto-sync on agent events:

- `afterFileEdit` — trigger when `state.json` changes
- `stop` — sync status when agent completes a task

### Sample Scripts

See `scripts/gh-tracker/` for GitHub CLI examples:

| Script             | Purpose                                            |
| ------------------ | -------------------------------------------------- |
| `sync-phase.sh`    | Parse `phase.md` → create items in GitHub Projects |
| `update-status.sh` | Sync `state.json` → GitHub Projects status         |
| `add-task.sh`      | Create task locally + in GitHub Projects           |

Copy to your repo (e.g., `.github/scripts/`) and customize for your tracker.

## Future Ideas

See [docs/future-ideas.md](../docs/future-ideas.md) for planned extensions.
