# Agentic Dev System — Future Ideas

Extensions and ideas not yet implemented.

## Harness Script (Layer 3)

PowerShell/Bash script that runs multiple tasks sequentially. Fully deterministic task ordering.

1. Discover pending tasks from `.agents/artifacts/phases/*.md`
2. For each task:
   - Update state to IN_PROGRESS
   - Invoke dev-cycle via CLI
   - Check result
   - If `manual` mode: pause for human review
   - Update state to DONE or BLOCKED
3. Continue to next task

Pause modes:

| Mode         | Behavior                                   |
| ------------ | ------------------------------------------ |
| `manual`     | Pause after every task for human review    |
| `auto`       | No pauses, run until completion or failure |
| `on-failure` | Pause only when gates fail                 |

```powershell
./harness.ps1 --mode manual --phase phase-01
./harness.ps1 --mode auto --max-tasks 5
```

Only build this after Layer 1 (individual steps) and Layer 2 (dev-cycle) are proven reliable.

## Parallel Execution (layer 4)

A layer 4 that handles parallel execution of tasks. This is a serious effort to get it right mainly due to the complexity of handling PR's merge conflicts etc. It will take time and experimentation.

## Remote Execution

Trigger the system from GitHub/Linear without a local IDE.

### Cursor Cloud Agents

Comment `@cursor [prompt]` on any GitHub issue or PR. Cursor Cloud Agent clones repo, runs in cloud VM, pushes to branch, creates PR. Agent reads `.cursor/rules/` and `.cursor/skills/` from repo automatically.

Setup: Connect GitHub via [Cursor Dashboard → Integrations](https://cursor.com/dashboard?tab=integrations), configure `.cursor/environment.json`, add secrets in Dashboard.

### Cloud Agents API

```bash
curl -X POST https://api.cursor.com/v0/agents \
  -u YOUR_API_KEY: \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": { "text": "Follow .agents/skills/workflow/dev-cycle/SKILL.md for task: add-auth" },
    "source": { "repository": "https://github.com/your-org/your-repo", "ref": "main" },
    "target": { "autoCreatePr": true }
  }'
```

## TDD Mode

Alternative plan-implement phase: write tests first from the plan, then write minimal code to pass them. The flow becomes:

```
Plan → Write Tests → Implement (minimal to pass) → Review → Verify → ...
```

Useful for well-specified behavior and regression-heavy work where the acceptance criteria can be expressed as tests upfront.

## Feature-Scoped Skills

`plan-feature` and `implement-feature` for larger units of work that span multiple tasks. A feature-level plan would break down into task-level plans, each following the standard dev-cycle. Still exploratory — needs more thought on how this interacts with the phase-breakdown skill.

## Setup Skills

A `setup-skills` skill that analyzes a target codebase and enriches the generic built-in skills with project-specific instructions. This would make the system truly plug-and-play: import the `.agents/` folder into any project, run `setup-skills`, and get workflow skills tailored to the project's framework, conventions, and structure.

This connects to the "portable skills" design principle — skills ship generic, `setup-skills` makes them specific.
