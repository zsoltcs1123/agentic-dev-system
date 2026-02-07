---
name: code-verification
description: Verifies code changes match the implementation plan and acceptance criteria. Use when asked to "verify task", "check plan compliance", or as final gate after code-review passes. Runs tests if applicable.
metadata:
  version: "0.3.0"
---

# Code Verification

Final gate that verifies implementation matches the plan and passes tests.

## When to Use

- User asks to "verify task" or "check against plan"
- After code-review PASS in dev-cycle
- Before marking a task complete

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`)

## Procedure

1. **Parse task ID**: Extract phase number from prefix (e.g., `p01-task-001` → phase `01`)
2. **Locate phase folder**: `.agents/artifacts/phases/phase-{number}-*/`
3. **Read plan** from `{phase-folder}/tasks/{task-id}/{task-id}-plan.md`
4. **Get the diff**: Staged changes or specified files
5. **Verify plan compliance**:
   - All planned steps completed?
   - All files in "Files to Modify" touched?
   - Any unplanned changes? (flag for justification)
   - Approach matches what was planned?
6. **Check acceptance criteria**: Each criterion from the plan should be verifiable
7. **Run tests** if project has them:
   - Run relevant test suite
   - Capture pass/fail counts and output
8. **Determine verdict**:
   - **PASS**: All planned items done, acceptance criteria met, tests pass
   - **ISSUES**: Missing items, unplanned changes, or test failures
9. **Save report** to `{phase-folder}/tasks/{task-id}/{task-id}-verification.md`
10. **Save test results** (if tests ran) to `{phase-folder}/tasks/{task-id}/{task-id}-test-results.md`
11. **Update task state** to VERIFIED

## Report Format

### PASS

```markdown
# Verification: PASS

Task: {task-id}
Date: {YYYY-MM-DD}

All planned items completed. Acceptance criteria met.

- [x] {planned step 1}
- [x] {planned step 2}
- [x] {acceptance criterion 1}
```

### ISSUES

```markdown
# Verification: ISSUES

Task: {task-id}
Date: {YYYY-MM-DD}

## Missing: {planned item}

{What's missing from implementation}

## Unplanned: {change}

{Change not in plan — needs justification or removal}

## Mismatch: {item}

- Plan: {what was planned}
- Actual: {what was implemented}

## Test Failures

{Summary of failing tests}
```

### Test Results

Save to `{phase-folder}/tasks/{task-id}/{task-id}-test-results.md`:

```markdown
# Test Results

Task: {task-id}
Date: {YYYY-MM-DD}

## Summary

| Metric | Count |
| ------ | ----- |
| Total  | {n}   |
| Passed | {n}   |
| Failed | {n}   |

## Output

{test runner output}
```

## Important

Verify only — do not fix issues. Report findings for implementer to address.
