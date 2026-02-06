# AGENTS.md

## Overview

Agentic Dev System — A portable, composable framework for AI-assisted development workflows.

## Constraints

- Plans persist to `.agents/artifacts/tasks/task-{id}/` (not agent-specific locations)
- Review and Verify gates must pass before commit

## Rules

Coding conventions in `rules/`:

- `general.md` — SOLID, DRY, naming, error handling
- `testing.md` — Test conventions

Read relevant rule files based on the code you're working with.

## Skills

Workflows in `skills/`. Read SKILL.md in each folder when needed.

| Skill                  | Purpose                         |
| ---------------------- | ------------------------------- |
| `project-planner`      | Strategic planning              |
| `phase-breakdown`      | Convert ROADMAP phase to tasks  |
| `plan-task`            | Create task implementation plan |
| `implement-task`       | Execute plan, write code        |
| `code-review`          | Quality gate (PASS/ISSUES)      |
| `code-verification`    | Verify code matches plan        |
| `documentation-update` | Keep docs in sync               |
| `commit`               | Stage and commit changes        |
| `push-pr`              | Push branch, create PR          |
| `dev-cycle`            | Orchestrator for full workflow  |

## Subagents

Thin wrappers in `agents/`:

- `planner.md` — Creates implementation plans (→ plan-task skill)
- `implementer.md` — Executes plans (→ implement-task skill)
- `reviewer.md` — Code quality review (→ code-review skill)
- `verifier.md` — Plan compliance check (→ code-verification skill)
