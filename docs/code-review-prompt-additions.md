# Code Review Prompt Additions

Issues the LLM review missed that a human reviewer caught:

## Missed Issues

1. **SRP violation in services** — Large service doing 4+ things (interfaces, config, dhcp, connectivity)
2. **DTOs leaking into service layer** — DTOs should stay at controller boundary, services use domain types
3. **Generic naming** — `network-utils.ts` should be `subnet-utils.ts`, `tokens/` should be `constants/`
4. **Input/output DTO ambiguity** — No naming convention distinguishing request vs response DTOs
5. **Naming inconsistencies** — Mixed patterns like `NetworkHostService` vs `GatewayBackendNetworkHostService`

## Prompt Additions

Add these review criteria to your LLM code review prompt:

```markdown
## Architectural Review Criteria

### Single Responsibility Principle

- Flag any service/class doing more than one cohesive thing
- If a service has methods spanning multiple sub-domains (e.g., interfaces + config + dhcp + connectivity), recommend decomposition into focused sub-services with an orchestrator
- "Large but well-tested" is not an excuse for SRP violations

### Layer Boundaries

- DTOs belong ONLY at the controller layer
- Services must work with domain/entity types, not DTOs
- Controllers transform between DTOs and domain types
- Flag any DTO import in a service file as a violation
- Rationale: DTOs leak API concerns into business logic, hurting reusability

### Naming Precision

- Generic names like `utils.ts`, `helpers.ts`, `types.ts`, `tokens.ts` are red flags
- Require specific names: `subnet-utils.ts`, `network.constants.ts`
- Multiple focused files > one catch-all file

### DTO Conventions

- Request DTOs: suffix with `Request` or `Input` (e.g., `ApplyConfigRequest`)
- Response DTOs: suffix with `Response` or `Output` (e.g., `IpConfigResponse`)
- Or use folders: `dtos/requests/`, `dtos/responses/`

### Naming Consistency

- Class names within a module should follow one pattern
- Flag mixed conventions (e.g., `FooService` alongside `ModuleBarService`)
```

## Why the LLM Missed These

The original review focused on:

- Security (auth, validation, injection) ✓
- Testing coverage ✓
- Error handling ✓
- Documentation ✓

It did NOT scrutinize:

- Internal architecture quality
- Layer separation discipline
- Naming conventions
- Long-term maintainability patterns

The LLM saw "separation of concerns" at the module level and praised it, without examining whether individual classes also followed SRP. It validated the patterns that were present rather than questioning whether better patterns should be used.
