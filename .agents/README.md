# Agentic Dev System

A portable, composable framework for AI-assisted development workflows. Works with Cursor, Claude Code, Codex, Gemini, or any agent that reads markdown.

## Quick Start

```powershell
# Windows - enable Cursor auto-discovery
.\.agents\cursor-setup.ps1

# Linux/macOS
./.agents/cursor-setup.sh
```

After setup, skills appear in Cursor's slash command menu.

## Structure

```
.agents/
├── skills/       # Workflows (the logic)
├── agents/       # Subagent definitions (thin wrappers)
├── rules/        # Coding conventions
├── plans/        # Saved implementation plans
├── phases/       # Task breakdowns from roadmaps
└── state/        # Task state tracking (JSON)
```

## Usage

### Layer 1: Manual Steps

Run each step individually via chat:

```
"Plan implementation for task-001"
"Implement the plan in plans/task-001.md"
"Review my changes"
"Verify changes against plans/task-001.md"
```

### Layer 2: Dev-Cycle

Run the full workflow for one task:

```
"Run dev-cycle for task-001"
```

Sequences: Plan → Implement → Review → Verify → Document → Commit

## Skills

| Skill                  | Purpose                               |
| ---------------------- | ------------------------------------- |
| `code-review`          | Quality gate — returns PASS or ISSUES |
| `code-verification`    | Verifies code matches plan            |
| `documentation-update` | Keeps docs in sync                    |
| `phase-breakdown`      | Converts roadmap phase to tasks       |
| `dev-cycle`            | Orchestrates full workflow            |

## Subagents

| Agent         | Model   | Purpose                          |
| ------------- | ------- | -------------------------------- |
| `planner`     | default | Creates implementation plans     |
| `implementer` | default | Executes plans                   |
| `reviewer`    | fast    | Code quality review (readonly)   |
| `verifier`    | fast    | Plan compliance check (readonly) |

## Workflow

```
PENDING → PLANNED → IMPLEMENTED → REVIEWED → VERIFIED → DOCUMENTED → COMMITTED
```

Gates (Review, Verify) must pass before proceeding. On failure, fix and retry the gate only.

## Portability

- All agents read `AGENTS.md` for context
- Skills work via explicit reference — no vendor lock-in
- Setup scripts create platform-specific links for auto-discovery

## Full Documentation

See `workspace/agentic-dev-system.md` for complete architecture and design.
