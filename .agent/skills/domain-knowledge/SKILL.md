---
skill: domain-knowledge
role: BA
version: 1.0
trigger: "Any domain question; before writing SRS, BE guide, or FE guide"
---

# Domain Knowledge -- Hoai Minh Honda ERP

> Single source of truth: `.agent/projects/hoaiminh/domain/`
> NEVER duplicate these files elsewhere. Reference them; do not copy content.

## Purpose

Provide business domain context (terminology, flows, schema, rules) to all BA workflows.
Load BEFORE writing any SRS or guide. Prevents invented business logic.

## Hard Rules

- RULE-DK-01: NEVER duplicate domain file content in other .agent/ files. Reference the path.
- RULE-DK-02: If domain file and SRS contradict -> SRS wins. Record the override in memory file.
- RULE-DK-03: If information is not in any domain file -> mark as TBD-xx. NEVER invent.

## Steps

1. **Identify required files** based on feature module code
   - Always load: 01, 06, 07
   - SAL / MTB M.Sale: also load 03 + 08
   - CS / MTB M.Repair: also load 04
   - WH / MTB M.Warehouse / PRT: also load 05
   - HR / HRM M.Org / SYS: also load 02
   - CRM: no dedicated flow file yet -- use 01, 06, 07 + note CRM-specific rules in SRS
   - RPT: no dedicated flow file -- use 01, 06, 07 only

2. **Load files** using path: `.agent/projects/hoaiminh/domain/{filename}`
   - Gate: Files found -> proceed. File missing -> state error, do not invent content.

3. **Apply terminology** from loaded files to all output (SRS, guides, analysis)

## Domain Files Index

| File | Content | Load When |
|---|---|---|
| 01-glossary.md | Vietnamese business terms, table prefixes | Always |
| 02-roles-permissions.md | Staff roles, permission hierarchy | HR/SYS features |
| 03-sales-flow.md | End-to-end vehicle sales process | SAL/MTB features |
| 04-service-flow.md | Repair and maintenance workflow | CS features |
| 05-warehouse-flow.md | Stock in/out, transfers, inventory | WH/PART features |
| 06-database-schema.md | All tables, columns, relationships | Always |
| 07-business-rules.md | Cross-module business constraints | Always |
| 08-approval-flows.md | Approval chains for discounts/POs | SAL/MTB features |
| 09-field-glossary.md | Field-level name mapping (VN to EN) | When mapping DTO fields |
