---
name: code-verification
description: Verifies code changes match the implementation plan. Saves report to task artifacts folder. Use after code-review passes.
version: 0.2.0
---

# Code Verification

Verifies that implementation matches the saved plan.

## Trigger

Use when:

- User asks to "verify against plan" or "check plan compliance"
- After code-review PASS in dev-cycle

## Input

- Task ID (e.g., `task-001`)
- Git diff or file changes
- Plan file from `.agents/artifacts/tasks/task-{id}/task-{id}-plan.md`

## Output

- Structured report saved to `.agents/artifacts/tasks/task-{id}/task-{id}-verification.md`
- Test results saved to `.agents/artifacts/tasks/task-{id}/task-{id}-test-results.md` (if tests run)

## Procedure

1. Get the task ID from prompt
2. Read the plan file from `.agents/artifacts/tasks/task-{id}/task-{id}-plan.md`
3. Get the diff (staged changes or specified files)
4. Compare implementation against plan:
   - Are all planned changes present?
   - Are there unplanned changes?
   - Do changes match the approach?
5. Run tests if specified in plan
6. Save report to `.agents/artifacts/tasks/task-{id}/task-{id}-verification.md`
7. If tests were run, save results to `.agents/artifacts/tasks/task-{id}/task-{id}-test-results.md`

## Output Format

Save to `.agents/artifacts/tasks/task-{id}/task-{id}-verification.md`:

### PASS

```markdown
# Verification: PASS

Task: task-{id}
Date: {YYYY-MM-DD}

Implementation matches plan. All planned items completed.

- [x] {planned item 1}
- [x] {planned item 2}
```

### ISSUES

```markdown
# Verification: ISSUES

Task: task-{id}
Date: {YYYY-MM-DD}

## Missing: {planned item}

Description: {what's missing from implementation}

## Unplanned: {change}

Description: {change not in plan, needs justification}

## Mismatch: {item}

Plan: {what was planned}
Actual: {what was implemented}
```

### Test Results (if applicable)

Save to `.agents/artifacts/tasks/task-{id}/task-{id}-test-results.md`:

```markdown
# Test Results

Task: task-{id}
Date: {YYYY-MM-DD}

## Summary

- Total: {count}
- Passed: {count}
- Failed: {count}

## Details

{test output}
```
