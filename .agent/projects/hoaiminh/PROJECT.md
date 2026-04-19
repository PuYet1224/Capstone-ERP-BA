# Hoai Minh Honda ERP -- Project Knowledge Base

> **Project**: Hoai Minh Honda ERP (Capstone -> Production)
> **Company**: 3PS Technology
> **Type**: Internal ERP for Honda HEAD Dealership

---

## When nào BA load folder this

`ba-pipeline` automatic load `projects/hoaiminh/` when it detects **any indicator** of:
- SRS header has: "Hoai Minh", "Hoai Minh", "Honda", "3PS", "HM_ERP", "SAL", "CS", "WH", "HR", "SYS" module codes
- SRS use VND currency or mentions branch/head
- User mention "hoai minh", "3ps", "honda head"

## Directory Structure

```
projects/hoaiminh/
|--- PROJECT.md              ← File this -- meta & trigger rules
|--- domain/                 ← Business knowledge (11 sections)
|   |--- 01-glossary.md
|   |--- 02-roles-permissions.md
|   |--- 03-sales-flow.md
|   |--- 04-service-flow.md
|   |--- 05-warehouse-flow.md
|   |--- 06-database-schema.md
|   |--- 07-business-rules.md
|   |--- 08-approval-flows.md
|   |--- 09-existing-api-patterns.md
|   |--- 10-project-architecture.md
|   `--- 11-coding-standards.md
|--- standards/              ← Technical coding standards
|   |--- be-standards.md     ← .NET 10 VSA CQRS + company patterns
|   `--- fe-standards.md     ← Angular + Kendo + 3PS component patterns
`--- memory/                 ← Feature analysis memories (permanent knowledge)
    `--- {FeatureName}.md
```

## Project Overview

| Item | Value |
|---|---|
| **BE Stack** | .NET 10, Mprintimal API, VSA, CQRS (MediatR), EF Core 10, Redis |
| **FE Web Stack** | Angular 16, Kendo UI 13, SCSS |
| **FE Mobile Stack** | Angular 16 (Responsive, not Kendo Grid) |
| **DB** | SQL Server, Code-First reverse-engprinteered |
| **Auth** | JWT Bearer -- External Identity Server |
| **Legacy Reference** | .NET 4.7.2 (hoaiminh-api) -- patterns for reference |

## Module Codes (SAL/CS/WH/HR/SYS)

| Code | Module | Vietnamese |
|---|---|---|
| SAL | Sales | Bán row |
| CS | Customer Service | Customer Service |
| WH | Warehouse | Kho row |
| HR | Human Resources | Human Resources |
| SYS | System | System |
| MTB | Finance (Receipt) | Receipt / Finance |
| PART | Parts | Parts |
| REP | Report | Report |
