---
name: code-verification
description: Verifies code changes match the implementation plan and acceptance criteria. Use when asked to "verify task", "check plan compliance", or as final gate after code-review passes.
metadata:
  version: "0.1.0"
---

# Code Verification

Final gate that verifies implementation matches the plan.

## When to Use

- User asks to "verify task" or "check against plan"
- After code-review PASS in dev-cycle
- Before marking a task complete

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`)

## Procedure

See `.agents/AGENTS.md` for path conventions and rules loading.

1. **Find relevant rules** in `.agents/rules/`:
   - Code verification
2. **Parse task ID**: Extract phase number from prefix
3. **Locate phase folder**
4. **Read plan** from `{phase-folder}/tasks/{task-id}/{task-id}-plan.md`
5. **Get the diff**: Staged changes or specified files
6. **Verify against rule criteria**:
   - All planned steps completed?
   - All files in "Files to Modify" touched?
   - Any unplanned changes? (flag for justification)
   - Approach matches what was planned?
7. **Check acceptance criteria**: Each criterion from the plan should be verifiable
8. **Determine verdict**:
   - **PASS**: All planned items done, acceptance criteria met
   - **ISSUES**: Missing items, unplanned changes, or criteria not met
9. **Save report** to `{phase-folder}/tasks/{task-id}/{task-id}-verification.md`
10. **Update task state** to VERIFIED

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
```

## Error Handling

- Plan not found → fail with: "Plan file not found. Run plan-task first."
- No diff/changes → fail with: "No changes to verify"
- Phase folder not found → fail with: "Phase folder not found for {task-id}"

## Important

Verify only — do not fix issues. Report findings for implementer to address.
