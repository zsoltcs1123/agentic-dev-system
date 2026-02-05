---
name: push-pr
description: Pushes branch to remote and creates a pull request via GitHub MCP. Use after commit step.
version: 0.1.0
---

# Push and Create PR

Pushes the current branch and creates a pull request.

## Trigger

Use when:

- User asks to "push and create PR" or "open a pull request"
- After commit step in dev-cycle

## Input

- Current branch with committed changes
- Task context (description, plan file path)

## Output

- PR URL

## Prerequisites

- GitHub MCP server configured
- Changes committed to local branch
- Remote repository accessible

## Procedure

1. Determine branch name
   - Use existing branch if not on main/master
   - Create task branch if on main/master: `task/{task-id}` or `feature/{description}`
2. Push branch to remote with `-u` flag
3. Create pull request via GitHub MCP or `gh` CLI:
   - Title: Task description or commit message
   - Body: Reference to plan file, summary of changes
   - Base: main/master (or configured default branch)
4. Return PR URL

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

See `plans/{task-id}.md`

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

## Notes

- If PR already exists for branch, return existing PR URL
- Do not force push unless explicitly requested
- Ensure branch is up to date with base before creating PR (warn if behind)
