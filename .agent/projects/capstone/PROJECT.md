# Capstone ERP - Project Knowledge Base

> **Project**: Capstone ERP (Academic Capstone)
> **Type**: ERP System for Capstone Dealership

---

## Trigger Rules (When should BA load this namespace)

`ba-pipeline` automatically loads `projects/capstone/` when detecting **any** of the following:
- SRS header contains: "Capstone", "ERP", "SAL", "CS", "WH", "HR", "SYS" module codes
- SRS uses VND currency or mentions branch/HEAD
- User mentions "capstone", "erp"

## Directory Structure

```
projects/capstone/
|-- PROJECT.md               This file - meta & trigger rules
|-- domain/                  Business knowledge (11 sections)
|   |-- 01-glossary.md
|   |-- 02-roles-permissions.md
|   |-- 03-sales-flow.md
|   |-- 04-service-flow.md
|   |-- 05-warehouse-flow.md
|   |-- 06-database-schema.md
|   |-- 07-business-rules.md
|   |-- 08-approval-flows.md
|   |-- 09-existing-api-patterns.md
|   |-- 10-project-architecture.md
|   |-- 11-coding-standards.md
|-- standards/               Technical coding standards
|   |-- be-standards.md      .NET 10 VSA CQRS patterns
|   |-- fe-standards.md      Angular + Kendo component patterns
|-- memory/                  Feature analysis memories (Long-term AI memory)
    |-- {FeatureName}.md
```

## Project Overview

| Item | Value |
|---|---|
| **BE Stack** | .NET 10, Minimal API, VSA, CQRS (MediatR), EF Core 10, Redis |
| **FE Web Stack** | Angular 16, Kendo UI 13, SCSS |
| **FE Mobile Stack** | Angular 16, Kendo UI 13, Responsive |
| **DB** | SQL Server, Code-First reverse-engineered |
| **Auth** | JWT Bearer - External Identity Server |

## Module Codes

| Code | Module | Vietnamese Name |
|---|---|---|
| SAL | Sales | Ban hang |
| CS | Customer Service | Dich vu khach hang |
| WH | Warehouse | Kho hang |
| HR | Human Resources | Nhan su |
| SYS | System | He thong |
| MTB | Finance | Phieu thu / Quy |
| PART | Parts | Phu tung |
| REP | Report | Bao cao |
