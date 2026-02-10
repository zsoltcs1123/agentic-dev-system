# AGENTS.md

## Paths

- Phases: `.agents/artifacts/phases/phase-{XX}/`
- Tasks: `{phase}/tasks/{task-id}/`
- Task ID: `p{XX}-task-{YYY}` (e.g., `p01-task-001`)

## Phase Resolution

From task ID `pXX-task-YYY`:

1. Extract phase number `XX` from prefix
2. Find folder `phase-{XX}` in `.agents/artifacts/phases/`
3. If not found → create folder `phase-{XX}`

## Artifact Naming

| File         | Pattern                     |
| ------------ | --------------------------- |
| Plan         | `{task-id}-plan.md`         |
| Review       | `{task-id}-review.md`       |
| Verification | `{task-id}-verification.md` |
| State        | `{task-id}-state.json`      |

## Rules Loading

Skills load rules from `.agents/config.json` → `skillRules.{skill-name}`:

1. Look up skill name in `skillRules`
2. Load each rule file from `.agents/rules/{rule-name}.md`
3. If file doesn't exist, skip (rules are optional)

## State Updates (dev-cycle)

When updating `state.json`:

1. Set `state` to new value
2. Append to `stateHistory` with timestamp
3. Gates: include `result: "PASS"|"ISSUES"`
4. Commit: include `commit: "{hash}"`
5. Push-PR: include `pr: "{url}"`

If `state.json` missing: create with current state, log warning.

## Output Limits

- Log/error output: max 50 lines
