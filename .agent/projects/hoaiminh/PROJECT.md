# Hoài Minh Honda ERP — Project Knowledge Base

> **Project**: Hoài Minh Honda ERP (Capstone → Production)
> **Company**: 3PS Technology
> **Type**: Internal ERP for Honda HEAD Dealership

---

## Khi nào BA load folder này

`ba-pipeline` tự động load `projects/hoaiminh/` khi phát hiện **bất kỳ dấu hiệu nào** sau:
- SRS header có: "Hoai Minh", "Hoài Minh", "Honda", "3PS", "HM_ERP", "SAL", "CS", "WH", "HR", "SYS" module codes
- SRS dùng VND currency hoặc đề cập chi nhánh/head
- User mention "hoai minh", "3ps", "honda head"

## Cấu Trúc Thư Mục

```
projects/hoaiminh/
├── PROJECT.md              ← File này — meta & trigger rules
├── domain/                 ← Business knowledge (11 sections)
│   ├── 01-glossary.md
│   ├── 02-roles-permissions.md
│   ├── 03-sales-flow.md
│   ├── 04-service-flow.md
│   ├── 05-warehouse-flow.md
│   ├── 06-database-schema.md
│   ├── 07-business-rules.md
│   ├── 08-approval-flows.md
│   ├── 09-existing-api-patterns.md
│   ├── 10-project-architecture.md
│   └── 11-coding-standards.md
├── standards/              ← Technical coding standards
│   ├── be-standards.md     ← .NET 10 VSA CQRS + company patterns
│   └── fe-standards.md     ← Angular + Kendo + 3PS component patterns
└── memory/                 ← Feature analysis memories (10 năm vẫn nhớ)
    └── {FeatureName}.md
```

## Tổng Quan Dự Án

| Item | Value |
|---|---|
| **BE Stack** | .NET 10, Minimal API, VSA, CQRS (MediatR), EF Core 10, Redis |
| **FE Web Stack** | Angular 16, Kendo UI 13, SCSS |
| **FE Mobile Stack** | Angular 16 (Responsive, no Kendo Grid) |
| **DB** | SQL Server, Code-First reverse-engineered |
| **Auth** | JWT Bearer — External Identity Server |
| **Legacy Reference** | .NET 4.7.2 (hoaiminh-api) — patterns để tham khảo |

## Module Codes (SAL/CS/WH/HR/SYS)

| Code | Module | Vietnamese |
|---|---|---|
| SAL | Sales | Bán hàng |
| CS | Customer Service | Dịch vụ khách hàng |
| WH | Warehouse | Kho hàng |
| HR | Human Resources | Nhân sự |
| SYS | System | Hệ thống |
| MTB | Finance (Phiếu Thu) | Phiếu thu / Finance |
| PART | Parts | Phụ tùng |
| REP | Report | Báo cáo |
