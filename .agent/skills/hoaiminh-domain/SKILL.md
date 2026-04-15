---
name: hoaiminh-domain
description: Honda HEAD HoÃ i Minh business domain knowledge base. Contains all business processes, terminology, database schema, and business rules. MUST READ before generating any HoÃ i Minh business-related code.
version: 1.0.0
skills:
  - clean-code
  - api-patterns
  - database-design
---

# Honda HEAD HoÃ i Minh - Domain Knowledge Skill

> **PURPOSE:** This is the "Business Brain" of the entire HoÃ i Minh ERP system. All Agents MUST reference this skill when generating code to ensure logic aligns with real-world business operations.

## When To Read This Skill

| Trigger | Action |
|---------|--------|
| Creating/modifying Sale-related APIs | â†’ Read `sections/03-sales-flow.md` |
| Creating/modifying Service/Maintenance APIs | â†’ Read `sections/04-service-flow.md` |
| Creating/modifying Warehouse APIs | â†’ Read `sections/05-warehouse-flow.md` |
| Any code related to Role/Permission | â†’ Read `sections/02-roles-permissions.md` |
| Encountering unknown terms (HEAD, KTV, CSKH...) | â†’ Read `sections/01-glossary.md` |
| Need database table structures | â†’ Read `sections/06-database-schema.md` |
| Need existing code conventions/patterns | â†’ Read `sections/09-existing-api-patterns.md` |
| Need project folder structure | â†’ Read `sections/10-project-architecture.md` |

## Directory Structure

```text
hoaiminh-domain/
â”œâ”€â”€ SKILL.md                      # This file - Index & Guide
â””â”€â”€ sections/
    â”œâ”€â”€ 01-glossary.md             # Internal Honda HEAD terminology
    â”œâ”€â”€ 02-roles-permissions.md    # Roles, permissions & org structure
    â”œâ”€â”€ 03-sales-flow.md           # Vehicle sales process (detailed)
    â”œâ”€â”€ 04-service-flow.md         # Maintenance/repair process
    â”œâ”€â”€ 05-warehouse-flow.md       # Warehouse flow (vehicles + parts)
    â”œâ”€â”€ 06-database-schema.md      # DB schema & table relationships
    â”œâ”€â”€ 07-business-rules.md       # Hard constraints (MUST NOT VIOLATE)
    â”œâ”€â”€ 08-approval-flows.md       # Multi-level approval workflows
    â”œâ”€â”€ 09-existing-api-patterns.md # Current code patterns (MediatR, CQRS, handlers)
    â””â”€â”€ 10-project-architecture.md  # Project structure & module organization
```

## Usage Principles

1. **Selective Reading:** DO NOT read all files. Only read sections relevant to the current task.
2. **Business Rules = Law:** Content in `07-business-rules.md` are HARD CONSTRAINTS. Code that violates them = BUG.
3. **Database Schema = Source of Truth:** When generating Entity/DTO, MUST reference `06-database-schema.md`.
4. **Glossary Resolves Ambiguity:** When encountering unfamiliar terms in requirements, check `01-glossary.md` first.

## Integration With Agent Routing

When `intelligent-routing` detects a HoÃ i Minh-related request:

```text
User: "Add periodic maintenance reminder feature"
â†’ Detected: hoaiminh-domain (service flow) + backend
â†’ Agent: hoaiminh-analyst (analysis) â†’ backend-specialist (code)
â†’ Skill loaded: hoaiminh-domain/sections/04-service-flow.md
```

## Context: What Is Honda HEAD?

Honda HEAD (Honda Exclusive Authorized Dealer) is Honda Vietnam's authorized dealership network. HoÃ i Minh is a multi-branch HEAD in TÃ¢y Ninh province, Vietnam, operating 10+ branches selling Honda motorcycles and providing after-sales services (maintenance, repair, genuine parts).

