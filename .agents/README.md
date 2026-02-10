# Agentic Dev System

A portable, composable framework for AI-assisted development workflows. Works with Cursor, Claude Code, Codex, Gemini, or any agent that reads markdown.

## Principles

1. **Single source of truth** — Skills and rules live in `.agents/`; agent-specific folders use symlinks
2. **Portable** — No vendor lock-in; any agent that reads markdown works
3. **Lean context** — `AGENTS.md` files are brief; details live in skills/rules
4. **Composable** — Every skill works standalone or as part of the dev-cycle orchestrator
5. **State in files** — All task artifacts grouped by phase in `.agents/artifacts/phases/`

## Quick Start

### 0. Clone the repository

```bash
git clone https://github.com/your-username/agentic-dev-system.git
cd agentic-dev-system
```

Copy the `.agents/` folder to your project.

```bash
cp -r .agents/ ~/projects/my-project/.agents/
```

### 1. Define Rules (optional)

Create markdown files in `.agents/rules/` with your coding standards, then map them in `config.json`:

```json
"skillRules": {
  "plan": ["coding-standards"],
  "code-review": ["coding-standards", "code-review"]
}
```

### 2. Install to Cursor

```bash
.agents/cursor-install.sh      # Linux/macOS
.agents/cursor-install.ps1     # Windows
```

### 3. Use

**Individual skills** — run any skill directly:

```
"Plan adding user authentication" or "/plan adding user authentication"
"Review my changes" or "/review my changes"
"Commit with message: Add auth middleware" or "/commit with message: Add auth middleware"
```

**Task mode** — create a task and run the full pipeline:

```
"/create task: Add user authentication"    → creates p01-task-001
"/dev-cycle p01-task-001"          → runs Plan → Implement → Review → Verify → Document → Commit → Push-PR
```

## Structure

```
.agents/
├── AGENTS.md         # Brief project context and pointers
├── config.json       # System configuration (task fields, skill rules)
├── skills/           # Workflows (the logic)
│   ├── tasks/        # create-task
│   └── workflow/     # plan, implement-task, code-review, etc.
├── rules/            # User-defined rules (skill-specific criteria)
└── artifacts/phases/ # Phase folders with tasks
```

Agent-specific folders (`.cursor/`, `.claude/`, `.gemini/`) contain symlinks to `.agents/skills/`.

## Installation

Install scripts create symlinks from agent-specific folders to `.agents/`, making skills and agents discoverable.

### Cursor

```bash
# Linux/macOS
.agents/cursor-install.sh

# Windows (PowerShell)
.agents/cursor-install.ps1
```

The script creates `.cursor/skills/{skill-name}` symlinks pointing to each skill folder, and `.cursor/rules` pointing to `.agents/rules`. Cursor auto-discovers these at runtime.

Subagents are also installed for each skill into `.cursor/agents/{subagent-name}`.

Other agents (Claude Code, Codex, Gemini) are not yet supported but follow the same pattern.

## Architecture

**Layer 1: Pure Skills** — Stateless operations that work standalone. No task IDs required.

**Layer 2: Task Orchestration** — `dev-cycle` provides task context, manages state, saves artifacts.

```
Standalone:  User → Skill → Chat Output
Task Mode:   User → dev-cycle → Skill → Artifacts
```

## Skills

### Tasks

| Skill         | Purpose                  |
| ------------- | ------------------------ |
| `create-task` | Create standardized task |

### Workflow

| Skill                  | Input              | Output             |
| ---------------------- | ------------------ | ------------------ |
| `plan`                 | description        | Plan markdown      |
| `implement-task`       | plan               | Code changes       |
| `code-review`          | changes (optional) | PASS/ISSUES report |
| `code-verification`    | criteria or plan   | PASS/ISSUES report |
| `documentation-update` | —                  | Updated docs       |
| `commit`               | message (optional) | Commit hash        |
| `push-pr`              | branch (optional)  | PR URL             |
| `dev-cycle`            | task-id            | Full pipeline      |

## Pipeline

```
Plan → Implement → Review → Verify → Document → Commit → Push-PR
```

Linear flow. On gate failure, stop and report. User fixes and re-runs.

| Step      | Skill                  | Gate          |
| --------- | ---------------------- | ------------- |
| Plan      | `plan`                 | —             |
| Implement | `implement-task`       | —             |
| Review    | `code-review`          | PASS required |
| Verify    | `code-verification`    | PASS required |
| Document  | `documentation-update` | —             |
| Commit    | `commit`               | —             |
| Push-PR   | `push-pr`              | —             |

**Gates:** Review and Verify are gates. If either returns ISSUES, dev-cycle stops. User fixes manually and re-runs dev-cycle to resume from current state. No automatic retry.

### Task States

```
PENDING → PLANNED → IMPLEMENTED → REVIEWED → VERIFIED → DOCUMENTED → COMMITTED → PR_CREATED → DONE
```

`DONE` is set externally (after PR merge or manual marking).

## Usage

### Standalone Skills

Every skill works without a task ID:

```
"Review my changes"           → code-review outputs to chat
"Plan adding user auth"       → plan outputs to chat
"Commit my changes"           → commit runs directly
```

### Task Mode (dev-cycle)

For structured task tracking:

```
"Run dev-cycle for p01-task-001"
```

dev-cycle handles: task context, artifact paths, state updates. Skills just do their job.

### Composability

Mix and match:

```
# Single skill
"Review my changes"

# Partial pipeline (already implemented)
"Verify my changes against this plan: ..."

# Full automation
"Run dev-cycle for p01-task-001"
```

## Artifacts

Tasks are organized by phase. To create a new phase, create the folder:

```
mkdir .agents/artifacts/phases/phase-01
```

Phase structure:

```
.agents/artifacts/phases/phase-01/
├── phase.md              # Phase description and task list (optional)
└── tasks/p01-task-001/   # Task artifacts
    ├── p01-task-001-plan.md
    ├── p01-task-001-review.md
    ├── p01-task-001-verification.md
    └── p01-task-001-state.json
```

**Task ID format:** `pXX-task-YYY` (phase-prefixed to prevent collisions)

### State File

```json
{
  "id": "p01-task-001",
  "description": "Add user authentication",
  "phase": "phase-01",
  "state": "REVIEWED",
  "priority": "high",
  "stateHistory": [
    { "state": "PENDING", "timestamp": "..." },
    { "state": "PLANNED", "timestamp": "..." },
    { "state": "IMPLEMENTED", "timestamp": "..." },
    { "state": "REVIEWED", "timestamp": "...", "result": "PASS" }
  ]
}
```

## Rules

Rules are **optional and user-defined**. The `.agents/rules/` folder starts empty. Skills work without rules — they use sensible defaults.

To customize skill behavior:

1. Create a markdown file in `.agents/rules/` (e.g., `coding-standards.md`)
2. Add the rule name to the skill's entry in `config.json` → `skillRules`
3. Skills load rules at runtime; if a file doesn't exist, it's skipped

Example: To add coding standards that `plan` and `code-review` should follow:

```markdown
<!-- .agents/rules/coding-standards.md -->

# Coding Standards

- Use TypeScript strict mode
- Prefer composition over inheritance
- All public functions must have JSDoc comments
```

Then in `config.json`:

```json
"skillRules": {
  "plan": ["coding-standards"],
  "code-review": ["coding-standards"]
}
```

Both skills will now load and apply these standards.

## Configuration

Settings in `.agents/config.json`:

```json
{
  "tasks": {
    "fields": ["priority", "assignee"]
  },
  "skillRules": {
    "plan": ["planning", "coding-standards"],
    "code-review": ["code-review", "coding-standards"],
    "commit": ["commit"]
  }
}
```

**Task fields:** Custom fields to add to tasks beyond the required ones (`id`, `description`, `phase`, `state`). These fields will be gathered by `create-task` when creating new tasks.

**Skill rules:** Map skill names to rule file names in `.agents/rules/`. Skills look up their name in this config and load the corresponding rule files.

## Integrations

### GitHub

The `push-pr` skill auto-detects available options:

| Option     | Notes                                 |
| ---------- | ------------------------------------- |
| GitHub CLI | `gh` installed and authenticated      |
| GitHub MCP | Richer integration (issues, comments) |

### Project Trackers

Tracker integration lives outside the core system as scripts. The system outputs standard formats (`phase.md`, `state.json`) that scripts can consume.
