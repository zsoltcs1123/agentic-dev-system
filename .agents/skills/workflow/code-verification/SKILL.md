---
name: code-verification
description: Verifies code changes match the implementation plan. Saves report to task artifacts folder. Use after code-review passes.
version: 0.3.0
---

# Code Verification

Verifies that implementation matches the saved plan.

## Trigger

Use when:

- User asks to "verify against plan" or "check plan compliance"
- After code-review PASS in dev-cycle

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`)
- Git diff or file changes

## Output

- Structured report saved to task folder
- Test results saved to task folder (if tests run)

## Procedure

1. Get the task ID from prompt
2. Parse task ID: extract phase number from prefix (e.g., `p01-task-001` → phase `01`)
3. Locate phase folder: `.agents/artifacts/phases/phase-{number}-*/`
4. Read the plan file from `{phase-folder}/tasks/{task-id}/{task-id}-plan.md`
5. Get the diff (staged changes or specified files)
6. Compare implementation against plan:
   - Are all planned changes present?
   - Are there unplanned changes?
   - Do changes match the approach?
7. Run tests if specified in plan
8. Save report to `{phase-folder}/tasks/{task-id}/{task-id}-verification.md`
9. If tests were run, save results to `{phase-folder}/tasks/{task-id}/{task-id}-test-results.md`

## Output Format

Save to `{phase-folder}/tasks/{task-id}/{task-id}-verification.md`:

### PASS

```markdown
# Verification: PASS

Task: {task-id}
Date: {YYYY-MM-DD}

Implementation matches plan. All planned items completed.

- [x] {planned item 1}
- [x] {planned item 2}
```

### ISSUES

```markdown
# Verification: ISSUES

Task: {task-id}
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

Save to `{phase-folder}/tasks/{task-id}/{task-id}-test-results.md`:

```markdown
# Test Results

Task: {task-id}
Date: {YYYY-MM-DD}

## Summary

- Total: {count}
- Passed: {count}
- Failed: {count}

## Details

{test output}
```
