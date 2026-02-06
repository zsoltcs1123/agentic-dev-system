# Agentic Dev System — Design

A portable, composable system for AI-assisted development workflows. Works with Cursor, Claude Code, Codex, Gemini, or any agent that can read markdown.

## Architecture

```
project-root/
│
├── AGENTS.md                     # Brief context + pointers to rules/skills
├── CLAUDE.md                     # Symlink → AGENTS.md (for Claude Code)
│
├── .agents/                      # SINGLE SOURCE OF TRUTH
│   ├── skills/                   # Workflows (logic lives here)
│   │   ├── project-planner/
│   │   ├── phase-breakdown/
│   │   ├── plan-task/
│   │   ├── implement-task/
│   │   ├── code-review/
│   │   ├── code-verification/
│   │   ├── documentation-update/
│   │   ├── commit/
│   │   ├── push-pr/
│   │   └── dev-cycle/            # Orchestrator (invokes subagents)
│   │
│   ├── agents/                   # Subagent definitions (thin wrappers)
│   │   ├── planner.md            # → plan-task skill
│   │   ├── implementer.md        # → implement-task skill
│   │   ├── reviewer.md           # → code-review skill
│   │   └── verifier.md           # → code-verification skill
│   │
│   ├── rules/                    # Coding conventions (portable)
│   │   ├── general.md
│   │   ├── csharp.md
│   │   ├── typescript.md
│   │   └── testing.md
│   │
│   └── artifacts/                # All task artifacts grouped by task
│       ├── phases/               # Task breakdowns (output of phase-breakdown)
│       └── tasks/                # Per-task artifacts
│           └── task-001/
│               ├── task-001-plan.md
│               ├── task-001-review.md
│               ├── task-001-verification.md
│               └── task-001-state.json
│
├── .cursor/
│   ├── skills/                   # Symlinks → .agents/skills/*
│   └── agents/                   # Symlinks → .agents/agents/*
│
├── .claude/
│   ├── skills/                   # Symlinks → .agents/skills/*
│   └── agents/                   # Symlinks → .agents/agents/*
│
└── .gemini/skills/               # Symlinks → .agents/skills/*
```

## Core Principles

1. **Single source of truth** — Skills and rules live in `.agents/`, agent-specific folders use symlinks
2. **Portable** — No vendor lock-in; any agent that reads markdown works
3. **Lean context** — `AGENTS.md` files are brief; details live in skills/rules
4. **Composable** — Every skill works standalone (e.g. "review my changes") or as part of the dev-cycle orchestrator. Mix and match freely.
5. **State in files** — All task artifacts grouped per task in `.agents/artifacts/tasks/`
6. **Portable skills** — Skills ship with minimal, generic instructions — just enough for the dev-cycle to function. This makes the system importable into any project. Project-specific conventions belong in `.agents/rules/`, not baked into skills.

## AGENTS.md Convention

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

Agents see the pointers and read files on demand. No forced loading.

## Rules Convention

Rules in `.agents/rules/` define coding standards. One file per language or topic.

```markdown
# [Language/Topic] Rules

## [Category]

- [Rule]: [Brief rationale]

## Anti-patterns

- [What to avoid]: [Why]
```

Keep rules actionable and concise. Agents have limited context.

## Execution Model

The system supports two usage modes depending on the task complexity and desired level of interaction.

### Usage Modes

**Cursor-native mode** — Use Cursor's built-in Plan Mode (Shift+Tab) for planning and its Build button for implementation. The remaining steps (review, verify, document, commit, push-pr) use the system's skills. Best for complex features with unanswered questions where interactive plan refinement is valuable.

**Full system mode** — All steps use skills and subagents, including `plan-task` and `implement-task`. Less interactive, better for well-defined straightforward tasks, CLI-driven workflows, and headless/CI execution.

Both modes share the same dev-cycle pipeline, artifact structure, and quality gates. The difference is only in who handles Plan and Implement.

### Dev-Cycle Pipeline

Every task follows the same pipeline:

```
Plan → Implement → Review → Verify → Document → Commit → Push-PR
                      │         │
                      └─────────┴──▶ (failure: fix and retry gate)
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

In Cursor-native mode, Plan and Implement are handled by Cursor's built-in features instead of the `plan-task`/`implement-task` skills. The dev-cycle skill detects existing plan and code, and skips those steps.

**Gate enforcement:** Review must PASS before Verify. On failure, fix issues and re-run only the failed gate. Max 2 retries per gate, then escalate to human.

**Subagent strategy:**

- **Required as subagents:** Review, Verify (quality gates need context isolation)
- **Optional as subagents:** Plan, Implement (can run in main context or as subagents)

### Running the Steps

```bash
# Individual steps (chat or CLI):
"Plan task-001: add user authentication"       # plan-task skill or Cursor Plan Mode
"Implement the plan for task-001"              # implement-task skill or Cursor Build
"Review my changes for task-001"               # code-review skill
"Verify changes for task-001"                  # code-verification skill
"Update documentation"                         # documentation-update skill
"Commit task-001"                              # commit skill
"Push and create PR"                           # push-pr skill

# Full dev-cycle:
"Run dev-cycle for task-001"

# CLI:
agent -p "Follow .agents/skills/dev-cycle/SKILL.md for task: task-001"
```

### Task State Machine

```
PENDING → PLANNED → IMPLEMENTED → REVIEWED → VERIFIED → DOCUMENTED → COMMITTED → PR_CREATED → DONE
                         │              │
                         └──────────────┴──▶ (failure: back to IMPLEMENTED or BLOCKED)
```

## Artifact Persistence

All task artifacts are stored in `.agents/artifacts/tasks/task-{id}/`:

| Artifact                    | Description          |
| --------------------------- | -------------------- |
| `task-{id}-plan.md`         | Implementation plan  |
| `task-{id}-review.md`       | Code review report   |
| `task-{id}-verification.md` | Verification report  |
| `task-{id}-state.json`      | Task state + history |

**Cursor Plan Mode note:** Cursor saves plans to `~/.cursor/plans/` by default. There is no setting to change this. After using Cursor's Plan Mode, manually save the plan markdown into `.agents/artifacts/tasks/task-{id}/` to integrate with the task system.

## Skills

| Skill                  | Purpose            | Step Mapping |
| ---------------------- | ------------------ | ------------ |
| `project-planner`      | Strategic planning | —            |
| `phase-breakdown`      | Roadmap → Tasks    | —            |
| `plan-task`            | Create task plan   | Plan         |
| `implement-task`       | Execute plan       | Implement    |
| `code-review`          | Quality gate       | Review       |
| `code-verification`    | Plan compliance    | Verify       |
| `documentation-update` | Keep docs in sync  | Document     |
| `commit`               | Stage and commit   | Commit       |
| `push-pr`              | Push and create PR | Push-PR      |
| `dev-cycle`            | Orchestrator       | All steps    |

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

You are a code reviewer. Read and follow `.agents/skills/code-review/SKILL.md`.
```

The skill contains the logic; the subagent provides execution context.

## State Tracking

State is stored per-task in `.agents/artifacts/tasks/task-{id}/task-{id}-state.json`:

```json
{
  "id": "task-001",
  "description": "Add user authentication",
  "source": ".agents/artifacts/phases/phase-01-core.md",
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

## GitHub Integration

The `push-pr` skill (and by extension the commit/push-pr steps of dev-cycle) requires GitHub access. One of the following must be available:

| Option         | How                                                  | Notes                                        |
| -------------- | ---------------------------------------------------- | -------------------------------------------- |
| **GitHub CLI** | `gh` installed and authenticated                     | Works everywhere, no MCP setup needed        |
| **GitHub MCP** | MCP server configured (e.g. `@anthropic/github-mcp`) | Richer integration: read issues, PR comments |

The `push-pr` skill auto-detects which is available. Either is sufficient for creating branches and pull requests.

## Future Ideas

See [future-ideas.md](future-ideas.md) for planned extensions including harness script automation, remote execution, TDD mode, and more.
