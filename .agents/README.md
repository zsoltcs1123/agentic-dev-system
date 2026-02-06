# Agentic Dev System

A portable, composable framework for AI-assisted development workflows. Works with Cursor, Claude Code, Codex, Gemini, or any agent that reads markdown.

## Core Principles

1. **Single source of truth** — Skills and rules live in `.agents/`, agent-specific folders use symlinks
2. **Portable** — No vendor lock-in; any agent that reads markdown works
3. **Project tracker integration** - Adapt to your project tracker of choice (GitHub Projects, Linear, etc.)
4. **Lean context** — `AGENTS.md` files are brief; details live in skills/rules
5. **Composable** — Every skill works standalone or as part of the dev-cycle orchestrator
6. **State in files** — All task artifacts grouped per task in `.agents/artifacts/tasks/`
7. **Portable skills** — Skills contain minimal, generic instructions. Project-specific conventions belong in `.agents/rules/`

## Structure

```
.agents/
├── config.json   # System configuration
├── skills/       # Workflows (the logic)
├── agents/       # Subagent definitions (thin wrappers)
├── rules/        # Coding conventions
└── artifacts/    # Task artifacts (phases, plans, reviews, state)
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
"Review my changes for task-001"
"Verify changes for task-001"

# Full dev-cycle — hands-off automation
"Run dev-cycle for task-001"
```

No lock-in to the full pipeline. Start small, add steps as needed.

### Running Steps

```
# Individual steps (chat):
"Plan task-001: add user authentication"
"Implement the plan for task-001"
"Review my changes for task-001"
"Verify changes for task-001"
"Update documentation"
"Commit task-001"
"Push and create PR"

# Full dev-cycle:
"Run dev-cycle for task-001"

# CLI:
agent -p "Follow .agents/skills/workflow/dev-cycle/SKILL.md for task: task-001"
```

## Skills

### Planning

| Skill             | Purpose            |
| ----------------- | ------------------ |
| `project-planner` | Strategic planning |
| `phase-breakdown` | Roadmap → Tasks    |

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

### Tracker

| Skill                | Purpose              |
| -------------------- | -------------------- |
| `sync-tasks`         | Phase → tracker      |
| `add-task`           | Add task to tracker  |
| `update-task-status` | Sync state → tracker |

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

All task artifacts are stored in `.agents/artifacts/tasks/task-{id}/`:

| Artifact                    | Description          |
| --------------------------- | -------------------- |
| `task-{id}-plan.md`         | Implementation plan  |
| `task-{id}-review.md`       | Code review report   |
| `task-{id}-verification.md` | Verification report  |
| `task-{id}-state.json`      | Task state + history |

**Cursor Plan Mode note:** Cursor saves plans to `~/.cursor/plans/` by default. After using Cursor's Plan Mode, manually save the plan markdown into `.agents/artifacts/tasks/task-{id}/` to integrate with the task system.

State file example:

```json
{
  "id": "task-001",
  "description": "Add user authentication",
  "source": ".agents/artifacts/phases/phase-01-core.md",
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

### Project Tracker

Set `tracker.adapter` to the name of your tracker adapter:

```json
{
  "tracker": {
    "adapter": "github-projects"
  }
}
```

Set to `"none"` to disable tracker integration (local-only mode).

The system integrates with external project trackers (GitHub Projects, Linear, etc.) via an adapter pattern:

```
phase-breakdown
      │
      v
phases/phase-XX.md
      │
      ├──────────────────┬──────────────────┐
      v                  v                  v
 sync-tasks          add-task       update-task-status
      │                  │                  │
      └──────────────────┴──────────────────┘
                         │
                         v
                   config.json
                  adapter: "..."
                         │
         ┌───────────────┼───────────────┐
         v               v               v
  github-projects     linear          custom
```

Each skill reads `.agents/config.json` for the active adapter name, then loads adapter-specific instructions from `adapters/{adapter-name}.md` within the skill folder.

To add a new tracker: copy `adapters/_template.md` in any tracker skill, rename to `{tracker-name}.md`, fill in the commands, and set the adapter name in `config.json`.

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

## Future Ideas

See [docs/future-ideas.md](../docs/future-ideas.md) for planned extensions.
