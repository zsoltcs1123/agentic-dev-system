---
name: push-pr
description: Pushes branch to remote and creates a pull request. Use when asked to "push and create PR", "open a pull request", or as final step in dev-cycle after commit.
metadata:
  version: "0.1.0"
---

# Push and Create PR

Pushes the current branch and creates a pull request.

## When to Use

- User asks to "push and create PR" or "open a pull request"
- After commit step in dev-cycle
- Ready to submit work for review

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`)
- Current branch with committed changes

## Prerequisites

- GitHub MCP server configured or `gh` CLI available
- Changes committed to local branch
- Remote repository accessible

## Procedure

See `.agents/AGENTS.md` for path conventions and rules loading.

1. **Find relevant rules** in `.agents/rules/`:
   - Pull requests
2. **Parse task ID**: Extract phase number from prefix
3. **Locate phase folder**
4. **Determine branch name**:
   - Use existing branch if not on main/master
   - Create task branch if on main/master: `task/{task-id}`
5. **Push branch** to remote with `-u` flag
6. **Check for existing PR**: If PR exists for branch, return existing URL
7. **Create pull request** via GitHub MCP or `gh` CLI:
   - Title: Task description or commit message
   - Body: Follow rule format (summary + plan reference + test plan)
   - Base: main/master (or configured default)
8. **Update task state** to PR_CREATED in `{phase-folder}/tasks/{task-id}/{task-id}-state.json`
9. **Return PR URL**

## Branch Naming

| Context                | Branch Name                   |
| ---------------------- | ----------------------------- |
| Task with ID           | `task/{task-id}`              |
| Feature without ID     | `feature/{short-description}` |
| Already on task branch | Use existing branch           |

## PR Body Format

```markdown
## Summary

{1-3 bullet points describing the changes}

## Plan

See `.agents/artifacts/phases/{phase-folder}/tasks/{task-id}/{task-id}-plan.md`

## Test Plan

{How to verify the changes work}
```

## Output Format

### Success

```
## Push-PR: SUCCESS

- Branch: {branch-name}
- PR: {pr-url}
- Title: {pr-title}
```

### Failure

```
## Push-PR: FAILED

- Error: {error-message}
- Step: {push|pr-create}
- Suggestion: {how to resolve}
```

## Important

- Do not force push unless explicitly requested
- Warn if branch is behind base (may need rebase)
- Never push secrets or credentials
