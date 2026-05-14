# Hoai Minh Honda ERP - Project Knowledge Base

> **Project**: Hoai Minh Honda ERP (Production)
> **Company**: 3PS Technology
> **Type**: Internal ERP for Honda HEAD Dealership

---

## Trigger Rules (When should BA load this namespace)

`ba-pipeline` automatically loads `projects/hoaiminh/` when detecting **any** of the following:
- SRS header contains: "Hoai Minh", "Honda", "3PS", "HM_ERP", "SAL", "CS", "WH", "HR", "SYS" module codes
- SRS uses VND currency or mentions branch/HEAD
- User mentions "hoai minh", "3ps", "honda head"

## Directory Structure

```
projects/hoaiminh/
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
|   |-- be-standards.md      .NET 10 VSA CQRS + company patterns
|   |-- fe-standards.md      Angular + Kendo + 3PS component patterns
|-- memory/                  Feature analysis memories (Long-term AI memory)
    |-- {FeatureName}.md
```

## Project Overview

| Item | Value |
|---|---|
| **BE Stack** | .NET 10, Minimal API, VSA, CQRS (MediatR), EF Core 10, IMemoryCache (TTL=15s) |
| **FE Web Stack** | Angular 16, Kendo UI 13, SCSS |
| **FE Mobile Stack** | Angular 16, Kendo UI 13, Responsive |
| **DB** | SQL Server, Code-First reverse-engineered |
| **Auth** | JWT Bearer - External Identity Server |

## Module Codes (Business Domain → Technical Module)

> Business codes used in SRS/meeting notes. Technical module mapping in `refs/module-map.md`.

| Business Code | Business Domain | Vietnamese | Technical Module | Sub-Module |
|---|---|---|---|---|
| SAL | Sales | Bán hàng | MTB | M.Sale |
| CS | Customer Service / Repair | Dịch vụ / Sửa chữa | MTB | M.Repair |
| WH | Warehouse | Kho hàng | MTB | M.Warehouse |
| HR / HRM | Human Resources | Nhân sự | HRM | M.Org |
| CRM | CRM / Messaging | Quản lý quan hệ KH | CRM | M.Config / M.SentMessage |
| PART / PRT | Parts | Phụ tùng | PRT | M.Config / M.Inventory / M.IO |
| RPT / REP | Report | Báo cáo | RPT | M.Report |
| SYS | System | Hệ thống | (system tables -- no VSA module) | - |
