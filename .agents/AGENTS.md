# AGENTS.md

Machine-readable conventions for skills.

## Paths

- Phases: `.agents/artifacts/phases/phase-{NN}-{name}/`
- Tasks: `{phase}/tasks/{task-id}/`
- Task ID pattern: `p{NN}-task-{NNN}` (e.g., `p01-task-001`)

## Artifacts

| File         | Pattern                     |
| ------------ | --------------------------- |
| Plan         | `{task-id}-plan.md`         |
| Review       | `{task-id}-review.md`       |
| Verification | `{task-id}-verification.md` |
| State        | `{task-id}-state.json`      |

## Output Limits

- Review issues: max 10 per report
- Log/error output: max 50 lines

## Hooks

Optional hooks in `config.json`:

- `afterPlan`, `afterImplement`, `afterReview`, `afterVerify`, `beforeCommit`

Run hook script if defined. Continue on success, fail pipeline on error.
