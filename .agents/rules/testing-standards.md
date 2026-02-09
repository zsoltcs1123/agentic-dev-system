# Testing Standards

## Structure

- AAA pattern: Arrange, Act, Assert
- One assertion per test (logical assertion)
- Test names describe behavior: `should_[behavior]_when_[condition]`

## Coverage

- Unit tests for business logic
- Integration tests for boundaries
- No tests for trivial code (getters/setters)

## Anti-patterns

- Testing implementation details: Test behavior, not internals
- Shared mutable state: Isolate test fixtures
- Flaky tests: Fix or remove immediately
