# AGENTS.md

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

## Rules Loading

Skills dynamically load rules from `.agents/rules/`. Each skill specifies which rules it needs.

- Search `.agents/rules/` for matching files by name/topic
- IMPORTANT: if no matching rule file exists, use sensible defaults
- Rules are additive — load all that apply

Example: `code-review` loads `coding-standards.md`, `testing-standards.md`, and `code-review.md`.

## Hooks

Optional hooks in `config.json`:

- `afterPlan`, `afterImplement`, `afterReview`, `afterVerify`, `beforeCommit`

Run hook script if defined. Continue on success, fail pipeline on error.
