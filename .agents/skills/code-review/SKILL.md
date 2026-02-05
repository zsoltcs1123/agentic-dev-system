---
name: code-review
description: Reviews code changes for quality issues. Saves report to task artifacts folder. Use as quality gate after implementation.
version: 0.2.0
---

# Code Review

Quality gate that reviews code changes and saves a structured report.

## Trigger

Use when:

- User asks to "review my changes" or "review the code"
- After implementation step in dev-cycle

## Input

- Task ID (e.g., `task-001`)
- Git diff or file changes to review
- Project rules from `.agents/rules/`

## Output

- Structured report saved to `.agents/artifacts/tasks/task-{id}/task-{id}-review.md`

## Procedure

1. Get the task ID from prompt
2. Get the diff (staged changes or specified files)
3. Read relevant rules from `.agents/rules/`
4. Check for:
   - Rule violations
   - Code quality issues
   - Potential bugs
   - Missing error handling
5. Save report to `.agents/artifacts/tasks/task-{id}/task-{id}-review.md`

## Output Format

Save to `.agents/artifacts/tasks/task-{id}/task-{id}-review.md`:

### PASS

```markdown
# Code Review: PASS

Task: task-{id}
Date: {YYYY-MM-DD}

No issues found. Changes are ready for verification.
```

### ISSUES

```markdown
# Code Review: ISSUES

Task: task-{id}
Date: {YYYY-MM-DD}

## Issue 1: {title}

- File: {filepath}
- Line: {line number}
- Severity: {high|medium|low}
- Description: {what's wrong}
- Suggestion: {how to fix}

## Issue 2: ...
```
