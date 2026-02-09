---
name: code-review
description: Reviews code changes for quality issues and rule compliance. Use when asked to "review code", "check my changes", or as a quality gate after implementation. Saves structured report to task artifacts.
metadata:
  version: "0.1.0"
---

# Code Review

Quality gate that reviews code changes and saves a structured report.

## When to Use

- User asks to "review my changes" or "review the code"
- After implementation step in dev-cycle
- Before committing or creating a PR

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`)
- Git diff or file changes to review

## Procedure

See `.agents/AGENTS.md` for path conventions, output limits, and rules loading.

1. **Find relevant rules** in `.agents/rules/`:
   - Coding standards
   - Testing standards
   - Code review
   - Language specific rules
2. **Parse task ID**: Extract phase number from prefix
3. **Locate phase folder**
4. **Get the diff**: Staged changes, diff against main or specified files
5. **Review against rule criteria** (security, performance, correctness, style)
6. **Classify severity**:
   - **High**: Bugs, security issues, data loss risks — must fix
   - **Medium**: Rule violations, poor patterns — should fix
   - **Low**: Style, minor improvements — nice to fix
7. **Determine verdict**: PASS if no high/medium issues, otherwise ISSUES
8. **Save report** to `{phase-folder}/tasks/{task-id}/{task-id}-review.md`
9. **Update task state** to REVIEWED

## Report Format

### PASS

```markdown
# Code Review: PASS

Task: {task-id}
Date: {YYYY-MM-DD}

No blocking issues. Ready for verification.
```

### ISSUES

```markdown
# Code Review: ISSUES

Task: {task-id}
Date: {YYYY-MM-DD}

## Issue 1: {title}

- File: {filepath}
- Line: {line number}
- Severity: high|medium|low
- Description: {what's wrong}
- Suggestion: {how to fix}
```

## Error Handling

- No diff/changes to review → report: "No staged changes to review"
- Phase folder not found → fail with: "Phase folder not found for {task-id}"
- State file missing → create minimal state.json with current state

## Output Limits

- Max 10 issues per report
- If more issues exist, summarize: "...and {N} more low-severity issues"

## Important

Review only — do not fix issues directly. Report findings for the implementer to address.
