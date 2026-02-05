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
│   │   ├── code-review/
│   │   ├── code-verification/
│   │   ├── documentation-update/
│   │   └── dev-cycle/             # Orchestrator (invokes subagents)
│   │
│   ├── agents/                   # Subagent definitions (thin wrappers)
│   │   ├── reviewer.md           # → code-review skill
│   │   └── verifier.md           # → code-verification skill
│   │
│   ├── rules/                    # Coding conventions (portable)
│   │   ├── general.md            # SOLID, DRY, clean code
│   │   ├── csharp.md             # C# specific rules
│   │   ├── typescript.md         # TS specific rules
│   │   └── testing.md            # Testing conventions
│   │
│   └── artifacts/                # All task artifacts grouped by task
│       ├── phases/               # Task breakdowns (output of phase-breakdown)
│       │   ├── phase-00-setup.md
│       │   └── phase-01-core.md
│       │
│       └── tasks/                # Per-task artifacts
│           └── task-001/
│               ├── task-001-plan.md           # Implementation plan
│               ├── task-001-review.md         # Code review report
│               ├── task-001-verification.md   # Verification report
│               ├── task-001-test-results.md   # Test output (optional)
│               └── task-001-state.json        # Task state
│
├── .cursor/
│   ├── skills/                   # Symlinks → .agents/skills/*
│   └── agents/                   # Symlinks → .agents/agents/*
│
├── .claude/
│   ├── skills/                   # Symlinks → .agents/skills/*
│   └── agents/                   # Symlinks → .agents/agents/*
│
├── .gemini/skills/               # Symlinks → .agents/skills/*
│
└── projects/                     # Subdirectories with their own AGENTS.md
    └── feature-x/
        └── AGENTS.md             # Feature-specific context
```

## Core Principles

1. **Single source of truth** — Skills and rules live in `.agents/`, agent-specific folders use symlinks
2. **Portable** — No vendor lock-in; any agent that reads markdown works
3. **Lean context** — `AGENTS.md` files are brief; details live in skills/rules
4. **Composable** — Skills work standalone or chained via orchestrator
5. **State in files** — All task artifacts (plans, reviews, verifications, state) grouped per task in `.agents/artifacts/tasks/`
6. **Standards-based** — Uses `AGENTS.md` convention (60k+ repos, Linux Foundation stewardship)
7. **Leverage built-ins** — Trust agent's internal test/lint iteration; don't reinvent

## AGENTS.md Convention

Root and subdirectory `AGENTS.md` files contain:

- Brief project/feature description
- Known limitations and constraints
- Pointers to rules and skills (not duplicated instructions)

Keep under ~50 lines. Rules and skills are pointers, not inline content.

```markdown
# AGENTS.md (example)

## Overview

[1-2 sentences about this project/feature]

## Constraints

- [Hard limits, known issues]

## Rules

Coding conventions in `.agents/rules/`:

- `general.md` — SOLID, DRY, naming
- `csharp.md` — C# specific (if applicable)
- `testing.md` — Test conventions

Read relevant rule files based on the code you're working with.

## Skills

Workflows in `.agents/skills/`. Read SKILL.md in each folder when needed.
```

Agents see the pointers and read files on demand based on context. No forced loading.

## Rules Convention

Rules in `.agents/rules/` define coding standards that apply across projects or to specific languages/contexts.

### Rule Categories

| Rule File       | Scope              | Examples                                    |
| --------------- | ------------------ | ------------------------------------------- |
| `general.md`    | All code           | SOLID, DRY, naming, error handling          |
| `csharp.md`     | C# projects        | No `var`, nullable handling, async patterns |
| `typescript.md` | TS projects        | Strict mode, type patterns, imports         |
| `testing.md`    | All tests          | AAA pattern, naming, coverage expectations  |
| `security.md`   | Security-sensitive | Auth, secrets, input validation             |

### Rule File Structure

```markdown
# [Language/Topic] Rules

## [Category]

- [Rule]: [Brief rationale]

## Anti-patterns

- [What to avoid]: [Why]
```

Keep rules actionable and concise. Avoid essays — agents have limited context.

## Execution Model

The system operates in three layers. Each layer builds on the previous and adds automation.

```
Layer 3: Harness Script
   │      Deterministic task loop. Iterates through tasks, invokes Layer 2.
   │
   └──▶ Layer 2: Dev-Cycle Skill
          │      Orchestrates all steps for ONE task. Human reviews after.
          │
          └──▶ Layer 1: Individual Steps
                 Plan → Implement → Review → Verify → Document → Commit
                 Each step runs independently. Maximum control.
```

| Layer         | Controlled By    | Deterministic                              | Non-deterministic (LLM)             |
| ------------- | ---------------- | ------------------------------------------ | ----------------------------------- |
| 3 - Harness   | Script (PS/Bash) | Task ordering, state updates, pause points | None                                |
| 2 - Dev-Cycle | Skill + Agent    | Step sequencing, gate enforcement          | How to fix failures                 |
| 1 - Steps     | Agent            | Tool selection                             | Plan content, code, review findings |

---

### Layer 1: Individual Steps

Run each step manually via chat or CLI. Maximum control, human reviews between steps.

**Steps:**

| Step      | Skill/Tool                 | Input            | Output                                                      | Gate           |
| --------- | -------------------------- | ---------------- | ----------------------------------------------------------- | -------------- |
| Plan      | Agent Plan Mode            | task description | `.agents/artifacts/tasks/task-XXX/task-XXX-plan.md`         | Human approval |
| Implement | Agent                      | plan file        | code changes                                                | Lint/test pass |
| Review    | code-review skill          | git diff         | `.agents/artifacts/tasks/task-XXX/task-XXX-review.md`       | PASS required  |
| Verify    | code-verification skill    | diff + plan      | `.agents/artifacts/tasks/task-XXX/task-XXX-verification.md` | PASS required  |
| Document  | documentation-update skill | diff + docs      | updated docs                                                | None           |
| Commit    | git                        | staged changes   | commit hash                                                 | None           |
| Push-PR   | GitHub MCP                 | branch + commits | PR URL                                                      | None           |

**How to execute:**

```bash
# In Cursor/Claude Code chat:
"Plan implementation for task-001"              # → creates .agents/artifacts/tasks/task-001/task-001-plan.md
"Implement the plan for task-001"               # → writes code
"Review my changes for task-001"                # → runs code-review skill
"Verify changes for task-001"                   # → runs code-verification skill
"Update documentation"                          # → runs documentation-update skill
"Commit with message: Add user auth"            # → git commit
"Push and create PR"                            # → pushes branch, creates PR

# Or via CLI:
agent --mode=plan -p "Plan task-001: add user authentication"
agent -p "Implement plans/task-001.md"
agent -p "Follow .agents/skills/code-review/SKILL.md"
```

**When to use:** Learning the system, complex tasks requiring careful review, debugging issues.

---

### Layer 2: Dev-Cycle Skill

Single skill orchestrates all steps for ONE task. Human reviews after task completion.

**How it works:**

1. Read task from `.agents/artifacts/phases/*.md` or direct input
2. **Plan** — Invoke `planner` subagent (or run in main context) → saves `.agents/artifacts/tasks/task-{id}/plan.md`
3. **Implement** — Invoke `implementer` subagent (or run in main context) → writes code
4. **Review** — Invoke `reviewer` subagent → saves `.agents/artifacts/tasks/task-{id}/review.md`, must be PASS
5. **Verify** — Invoke `verifier` subagent → saves `.agents/artifacts/tasks/task-{id}/verification.md`, must be PASS
6. **Document** — Update relevant docs (optional)
7. **Commit** — Stage and commit changes
8. **Push-PR** — Push branch and create pull request via GitHub MCP
9. Update task state in `.agents/artifacts/tasks/task-{id}/state.json`

**Subagent strategy:**

- **Required as subagents:** Review, Verify (quality gates need isolation)
- **Optional as subagents:** Plan, Implement (can run in main context or as subagents)
- Running Plan and Implement as subagents provides context isolation between steps

**Gate enforcement:** If Review or Verify fails, fix issues and re-run only the failed gate (not full re-plan). Reports are overwritten on re-run.

**How to execute:**

```bash
# In chat:
"Run dev-cycle for task-001"

# Via CLI:
agent -p "Follow .agents/skills/dev-cycle/SKILL.md for task: task-001"
```

**When to use:** Standard workflow for implementing features. One task at a time with review after.

---

### Layer 3: Harness Script

PowerShell/Bash script runs multiple tasks sequentially. Fully deterministic task ordering.

**How it works:**

1. Discover pending tasks from `phases/*.md` or `.agents/state/`
2. For each task:
   - Update state to IN_PROGRESS
   - Invoke Layer 2 (dev-cycle) via CLI
   - Check result
   - If `manual` mode: pause for human review
   - Update state to DONE or BLOCKED
3. Continue to next task

**Pause modes:**

| Mode         | Behavior                                   |
| ------------ | ------------------------------------------ |
| `manual`     | Pause after every task for human review    |
| `auto`       | No pauses, run until completion or failure |
| `on-failure` | Pause only when gates fail                 |

**How to execute:**

```powershell
# Run with manual review after each task
./harness.ps1 --mode manual

# Run specific phase
./harness.ps1 --phase phase-01 --mode manual

# Auto mode (use with caution)
./harness.ps1 --mode auto --max-tasks 5
```

**When to use:** Processing multiple tasks from a phase. Only after Layer 1 & 2 are proven reliable.

---

### Task State Machine

```
PENDING → PLANNED → IMPLEMENTED → REVIEWED → VERIFIED → DOCUMENTED → COMMITTED → PR_CREATED → DONE
                         │              │
                         └──────────────┴──▶ (failure: back to IMPLEMENTED or BLOCKED)
```

### Control Flow Summary

**Deterministic (script/skill-controlled):**

- Step ordering (plan → implement → review → verify → document → commit → push-pr)
- Gate enforcement (review PASS required before verify)
- State persistence (write JSON after each step to `.agents/artifacts/tasks/task-{id}/task-{id}-state.json`)
- Artifact location (always `.agents/artifacts/tasks/task-{id}/`)
- Task sequencing (harness decides which task is next)

**Non-deterministic (LLM-decided):**

- Plan content (how to implement the task)
- Code changes (what to write)
- Review findings (what issues to flag)
- Fix strategies (how to address review/verify failures)
- When to give up (escalate to human)

## Artifact Persistence

**Problem:** Cursor saves plans to `~/.cursor/plans/` by default, not the repo.

**Solution:** Skill instructions explicitly tell the agent to save all artifacts to task folders with prefixed names:

```markdown
## Artifact Output

Save all task artifacts to `.agents/artifacts/tasks/task-{id}/`:

- `task-{id}-plan.md` — Implementation plan
- `task-{id}-review.md` — Code review report
- `task-{id}-verification.md` — Verification report
- `task-{id}-test-results.md` — Test output (optional)
- `task-{id}-state.json` — Task state

Do NOT use Cursor's default plan location.
```

## Skills

| Skill                  | Purpose            | Input               | Output                            | Step Mapping |
| ---------------------- | ------------------ | ------------------- | --------------------------------- | ------------ |
| `project-planner`      | Strategic planning | Requirements        | FOUNDATION, ARCHITECTURE, ROADMAP | —            |
| `phase-breakdown`      | Roadmap → Tasks    | ROADMAP phase       | `phases/phase-XX.md`              | —            |
| `code-review`          | Quality gate       | Code diff           | PASS / ISSUES                     | Review       |
| `code-verification`    | Plan compliance    | Diff + saved plan   | PASS / ISSUES                     | Verify       |
| `documentation-update` | Keep docs in sync  | Diff + project docs | Updated docs                      | Document     |
| `push-pr`              | Push and create PR | Branch + commits    | PR URL                            | Push-PR      |
| `dev-cycle`            | Orchestrator       | Task reference      | Completed PR                      | All steps    |

## Subagents

Subagents are thin wrappers that delegate to skills or perform focused tasks. They provide:

- **Context isolation** — each subagent gets fresh context, intermediate output doesn't pollute orchestrator
- **Parallelism** — independent tasks (review + verify) run concurrently
- **Cost efficiency** — use faster models for focused tasks
- **Clean handoffs** — artifacts saved to files, next step reads from files

| Subagent      | Purpose                    | Model     | Tools                         | Notes                                                                  |
| ------------- | -------------------------- | --------- | ----------------------------- | ---------------------------------------------------------------------- |
| `planner`     | Create implementation plan | `default` | Read, Write, Glob, Grep       | Saves to `.agents/artifacts/tasks/task-{id}/task-{id}-plan.md`         |
| `implementer` | Execute plan, write code   | `default` | Read, Write, Edit, Bash       | Reads from `.agents/artifacts/tasks/task-{id}/task-{id}-plan.md`       |
| `reviewer`    | Code quality review        | `fast`    | Read, Write, Grep, Glob       | Saves to `.agents/artifacts/tasks/task-{id}/task-{id}-review.md`       |
| `verifier`    | Verify code matches plan   | `fast`    | Read, Write, Grep, Glob, Bash | Saves to `.agents/artifacts/tasks/task-{id}/task-{id}-verification.md` |

**Required subagents:** `reviewer`, `verifier` (quality gates must be isolated)

**Optional subagents:** `planner`, `implementer` (can run in main context or as subagents for context isolation)

### Subagent File Format

```markdown
---
name: implementer
description: Implements a task based on a saved plan file.
model: default
tools: Read, Write, Edit, Glob, Grep, Bash
---

You are an implementation agent.

1. Read the plan file provided in the prompt
2. Follow the project's coding rules in `.agents/rules/`
3. Implement the plan step by step
4. Let the agent's internal loop handle lint/test iteration

Do not create a new plan. Execute the existing plan.
```

```markdown
---
name: reviewer
description: Code quality review. Use after implementation to check for issues.
model: fast
tools: Read, Grep, Glob
---

You are a code reviewer. Read and follow `.agents/skills/code-review/SKILL.md`.

Return a structured report:

- PASS or ISSUES
- If issues: list each with file, line, severity, description
```

Subagents reference skills via path. The skill contains the logic; the subagent provides execution context.

## MCP Requirements

Required MCP servers for full functionality:

| MCP Server     | Purpose                                       | Required For            | Priority        |
| -------------- | --------------------------------------------- | ----------------------- | --------------- |
| **GitHub**     | PR creation, branch management, issue reading | Commit step, issue sync | Required        |
| **Linear**     | Issue tracking, state sync                    | v2 state tracking       | Optional (v2)   |
| **Filesystem** | File operations                               | All steps               | Built-in        |
| **Git**        | Commit, diff, log                             | Review, Commit steps    | Built-in or MCP |

**GitHub MCP capabilities needed:**

- Create/update branches
- Create pull requests
- Read issues (for task context)
- Read PR comments (for feedback loop)

**Linear MCP capabilities needed (v2):**

- Read issues assigned to agent
- Update issue status
- Add comments with progress

**Recommendations:** GitHub MCP via `@anthropic/github-mcp` or similar. Linear via Cursor's native integration or `linear-mcp`.

## CLI Integration

**Design principle:** Skills and rules are markdown. Any agent that can read files and follow instructions works.

**Primary platform:** Cursor CLI (`agent` command)

```bash
# Layer 1: Individual steps
agent --mode=plan -p "Plan task-001: add user authentication"
agent -p "Follow .agents/skills/code-review/SKILL.md"

# Layer 2: Full dev-cycle
agent -p "Follow .agents/skills/dev-cycle/SKILL.md for task: task-001"

# Layer 3: Harness script
./harness.ps1 --mode manual --phase phase-01
```

**Other CLI agents:** Same pattern works with Claude Code (`claude -p`), Codex, etc. Skill invocation is portable; MCP configuration and subagent syntax vary by agent.

## State Tracking

### File-Based State (v1)

State is stored per-task in `.agents/artifacts/tasks/task-{id}/task-{id}-state.json`:

```
.agents/artifacts/tasks/
  task-001/
    task-001-plan.md
    task-001-review.md
    task-001-verification.md
    task-001-state.json           # Full task state + history
  task-002/
    task-002-plan.md
    task-002-state.json
```

**Task state schema:**

```json
{
  "id": "task-001",
  "description": "Add user authentication",
  "source": ".agents/artifacts/phases/phase-01-core.md",
  "state": "REVIEWED",
  "stateHistory": [
    { "state": "PENDING", "timestamp": "...", "trigger": "phase-breakdown" },
    { "state": "PLANNED", "timestamp": "..." },
    { "state": "IMPLEMENTED", "timestamp": "...", "commit": "abc123" },
    { "state": "REVIEWED", "timestamp": "...", "result": "PASS" }
  ],
  "commits": ["abc123", "def456"],
  "failures": []
}
```

### Issue Tracker Integration (v2 — Future)

Linear or GitHub Projects as state backend via MCP. File state becomes cache/fallback. Tasks synced bidirectionally.

## Remote Execution (Future)

Enable triggering the system from GitHub/Linear without local IDE.

### Cursor Cloud Agents

Comment `@cursor [prompt]` on any GitHub issue or PR. Cursor Cloud Agent clones repo, runs in cloud VM, pushes to branch, creates PR. Agent reads `.cursor/rules/` and `.cursor/skills/` from repo automatically.

**Setup:** Connect GitHub via [Cursor Dashboard → Integrations](https://cursor.com/dashboard?tab=integrations), configure `.cursor/environment.json`, add secrets in Dashboard.

### Cloud Agents API

```bash
curl -X POST https://api.cursor.com/v0/agents \
  -u YOUR_API_KEY: \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": { "text": "Follow .agents/skills/dev-cycle/SKILL.md for task: add-auth" },
    "source": { "repository": "https://github.com/your-org/your-repo", "ref": "main" },
    "target": { "autoCreatePr": true }
  }'
```

### Linear Integration

Cursor has native Linear integration. Assign issue to "Cursor" or comment `@Cursor` to trigger Cloud Agent.

## Symlink Setup

Skills and agents need symlinks for auto-discovery. Rules work via AGENTS.md pointers.

```bash
# Cursor
ln -s ../../.agents/skills .cursor/skills
ln -s ../../.agents/agents .cursor/agents

# Claude Code
ln -s ../../.agents/skills .claude/skills
ln -s ../../.agents/agents .claude/agents

# CLAUDE.md convention
ln -s AGENTS.md CLAUDE.md
```

**Windows (PowerShell):**

```powershell
New-Item -ItemType Directory -Force -Path .cursor
New-Item -ItemType Directory -Force -Path .claude

cmd /c mklink /J .cursor\skills .agents\skills
cmd /c mklink /J .cursor\agents .agents\agents

cmd /c mklink /J .claude\skills .agents\skills
cmd /c mklink /J .claude\agents .agents\agents

cmd /c mklink CLAUDE.md AGENTS.md
```

## Implementation Roadmap

### Phase 0: Specification ✓

Update the design document with execution model, state tracking, MCP requirements.

### Phase 1: Foundation + Layer 1 Skills

**1.1 Directory Structure**

- Create `.agents/` folder structure (skills, agents, rules, artifacts)
- Set up symlinks for Cursor (`.cursor/skills/` → `.agents/skills/`)
- Create `.agents/artifacts/phases/` and `.agents/artifacts/tasks/` directories
- Update root `AGENTS.md` with pointers

**1.2 Core Rules**

- `general.md` — SOLID, DRY, naming conventions
- `testing.md` — Test conventions (if needed)

**1.3 Layer 1 Skills**

| Skill                  | Purpose                                            | Depends On      |
| ---------------------- | -------------------------------------------------- | --------------- |
| `phase-breakdown`      | Convert ROADMAP phase → task list in `phases/*.md` | project-planner |
| `code-review`          | Review git diff, output PASS/ISSUES                | None            |
| `code-verification`    | Verify diff matches plan                           | code-review     |
| `documentation-update` | Update docs after changes                          | None            |
| `push-pr`              | Push branch and create PR via GitHub MCP           | None            |

**1.4 MCP Setup**

- Configure GitHub MCP server
- Test basic operations (read issues, create branch)

**Milestone:** Can run each skill manually: "review my changes", "verify against plan"

### Phase 2: Layer 2 Dev-Cycle

**2.1 Dev-Cycle Skill**

- Orchestrates: Plan → Implement → Review → Verify → Document → Commit → Push-PR
- Gates: Review PASS required before Verify
- Failure handling: Retry once, then escalate to human
- Plan persistence: Save to `plans/task-{id}.md`

**2.2 Subagents**

- `reviewer` — Thin wrapper → code-review skill (readonly, fast model)
- `verifier` — Thin wrapper → code-verification skill

**2.3 State Tracking (v1)**

- Implement `.agents/artifacts/tasks/task-{id}/task-{id}-state.json` files
- Task state schema
- State transitions on step completion

**Milestone:** Can run `dev-cycle` for a single task end-to-end with human review after

### Phase 3: Polish + Testing

- Test on real project, document friction points
- Finalize plan persistence approach
- Update README with usage instructions

**Milestone:** System works reliably for manual step-by-step and single-task dev-cycle

### Phase 4: Layer 3 Harness Script

Build the multi-task automation layer after Layer 1 & 2 are proven.

**4.1 Task Discovery**

- Parse `.agents/artifacts/phases/*.md` for pending tasks
- Read/write `.agents/artifacts/tasks/task-{id}/task-{id}-state.json` for progress tracking

**4.2 Harness Script**

- PowerShell script (`harness.ps1`) + Bash equivalent
- Pause modes: `manual`, `auto`, `on-failure`
- Failure handling: retry once, then mark BLOCKED

**4.3 Issue Tracker Integration (v2)**

- Linear or GitHub Projects as state backend via MCP
- Bidirectional sync: task status ↔ issue status

**Milestone:** Can run `harness.ps1 --mode=manual` to process multiple tasks with review points

### Phase 5: Remote Execution (FUTURE)

- Cursor Cloud Agents via `@cursor` comments on GitHub/Linear
- Cloud Agents API integration for programmatic triggers
- GitHub Actions as alternative execution environment

## Portability Matrix

| Agent Type               | Context File | Skills Discovery                 | Subagents              |
| ------------------------ | ------------ | -------------------------------- | ---------------------- |
| **Cursor, Claude Code**  | `AGENTS.md`  | Symlink `.cursor/` or `.claude/` | Supported              |
| **All other CLI agents** | `AGENTS.md`  | Read from pointer in `AGENTS.md` | Invoke skills directly |

**Key:** All agents read `AGENTS.md`. Cursor and Claude Code use symlinks for auto-discovery. Other agents read skill paths from `AGENTS.md` pointers and invoke skills directly (no subagent support).

## Open Items

- ~~Plan storage: gitignore vs. commit~~ → Commit to `.agents/artifacts/tasks/`
- ~~Verification failure handling~~ → Retry once, then escalate
- Phase breakdown output format (flat/hierarchical/table)
- Code review scope (security, performance, patterns)
- Documentation update scope (README, API docs, architecture)

## Version History

| Version | Date       | Changes                                                                          |
| ------- | ---------- | -------------------------------------------------------------------------------- |
| 0.9     | 2026-02-06 | Restructured artifacts: all task outputs in `.agents/artifacts/tasks/task-{id}/` |
| 0.8     | 2026-02-06 | Added push-pr step after commit for automated PR creation                        |
| 0.7     | 2026-02-05 | Added planner/implementer as optional subagents for context isolation            |
| 0.6     | 2026-02-05 | Expanded Layer 1/2/3 with execution details, simplified portability              |
| 0.5     | 2026-02-05 | Added execution model, state tracking, MCP requirements, roadmap                 |
| 0.4     | 2026-02-02 | Added subagents layer for orchestration + quality gates                          |
| 0.3     | 2026-02-02 | Simplified: rules via pointers, not symlinks                                     |
| 0.2     | 2026-02-02 | Added rules convention, portability matrix                                       |
| 0.1     | 2026-02-02 | Initial design                                                                   |
