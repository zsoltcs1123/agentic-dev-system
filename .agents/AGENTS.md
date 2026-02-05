# AGENTS.md

## Overview

Agentic Dev System — A portable, composable framework for AI-assisted development workflows.

## Constraints

- Skills must follow agentskills.io specification
- Plans persist to `plans/` directory (not agent-specific locations)
- Review and Verify gates must pass before commit

## Rules

Coding conventions in `rules/`:

- `general.md` — SOLID, DRY, naming, error handling
- `testing.md` — Test conventions

Read relevant rule files based on the code you're working with.

## Skills

Workflows in `skills/`. Read SKILL.md in each folder when needed.

| Skill                  | Purpose                        |
| ---------------------- | ------------------------------ |
| `phase-breakdown`      | Convert ROADMAP phase to tasks |
| `code-review`          | Quality gate (PASS/ISSUES)     |
| `code-verification`    | Verify code matches plan       |
| `documentation-update` | Keep docs in sync              |
| `dev-cycle`            | Orchestrator for full workflow |

## Subagents

Thin wrappers in `agents/`:

- `planner.md` — Creates implementation plans
- `implementer.md` — Executes plans
- `reviewer.md` — Code quality review
- `verifier.md` — Plan compliance check
