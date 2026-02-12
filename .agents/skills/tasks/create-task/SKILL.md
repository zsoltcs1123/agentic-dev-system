---
name: create-task
description: Creates a standardized task from any input. Use when asked to "create task", "add task", or "new task". Outputs state.json and appends to phase.md.
metadata:
  version: "0.1.0"
---

# Create Task

Creates a standardized task from user input. Synthesizes a clean description from potentially messy or informal requests.

## When to Use

- User asks to "create task" or "add task"
- Called by `dev-cycle` when given a user request instead of task ID

## When NOT to Use

- Deep task analysis or implementation planning → use `plan`
- Updating existing task state → modify state.json directly

## Task Fields

**Required (system)** — always present, cannot be removed:

- `id`: Generated automatically
- `description`: Synthesized from user input (clean, actionable summary)
- `phase`: Must be provided by user or inferred from context
- `state`: Always starts as `PENDING`

**User-defined** — additional fields from `.agents/config.json` → `tasks.fields`:

- Read the config to discover extra fields (e.g., `priority`)
- For each user-defined field, try to infer from context
- If cannot infer, ask user to provide

## Procedure

1. **Load config**: Read `.agents/config.json` → `tasks.fields` to get all fields. Also load rules from `skillRules.create-task` if present.
2. **Synthesize description**:
   - User input may be messy, informal, or vague
   - Extract the core intent and synthesize a clean, actionable description
   - If truly ambiguous (multiple interpretations), ask user to clarify
3. **Break into subtasks** (if applicable):
   - If the task involves multiple logical chunks, list them as subtasks
   - Subtasks must be in logical execution order
   - Read `maxSubtasks` from `.agents/config.json` → `tasks.maxSubtasks` (default: 7)
   - If subtask count exceeds the limit, tell user the task is too large and suggest how to split it. Do not proceed.
   - Simple tasks may have no subtasks — that's fine
4. **Determine phase**:
   - Get from user input or infer from context
   - If missing and cannot infer, ask user
5. **Gather user-defined fields**:
   - For each field in config beyond the required four:
     - Try to infer from context or user input
     - If cannot infer, ask user
   - Continue until all fields have values
6. **Generate task ID**: Extract phase number from phase name, find next available `p{NN}-task-XXX`
7. **Create artifacts**:
   - Task folder: `.agents/artifacts/phases/{phase}/tasks/{task-id}/`
   - State file: `{task-id}-state.json`
   - Append entry to `{phase}/phase.md`
8. **Output**: Report using format below

## Task ID Generation

Scan existing task folders in the phase to find the next available number:

```
.agents/artifacts/phases/phase-01/tasks/
├── p01-task-001/
├── p01-task-002/
└── p01-task-003/
→ Next ID: p01-task-004
```

## State File Format

```json
{
  "id": "p01-task-001",
  "description": "Setup devcontainer",
  "subtasks": [
    "Configure base image",
    "Configure extensions",
    "Configure shell",
    "Mount filesystem"
  ],
  "phase": "phase-01",
  "state": "PENDING",
  "stateHistory": [{ "state": "PENDING", "timestamp": "..." }]
}
```

The `subtasks` array is optional — omit it for simple tasks with no subtasks.

## Phase.md Entry Format

Append to the Tasks section:

```markdown
### p01-task-001: {title}

{description}
```

## Output Format

```markdown
## Task Created: {task-id}

- Phase: {phase}
- Description: {description}
  {For each user-defined field:}
- {field}: {value}
```

## Error Handling

- Phase not found → ask user to specify or create phase first
- Missing required info → ask user (do not guess)
- Ambiguous description → ask user to clarify

## Guidelines

- Keep descriptions actionable and specific
- Do not perform deep analysis — that's `plan`'s responsibility
- Single logical unit of work
- Completable in one session
- Subtasks should be in logical execution order
- If task exceeds the configured subtask limit, split into separate tasks
