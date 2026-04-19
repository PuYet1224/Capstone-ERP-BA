---
name: ba-pipeline
description: Principal BA auto-discovers SRS files (7-Pillar IEEE 29148 format), reads live Figma design via MCP bridge, performs deep cross-analysis of requirements + UI, and produces comprehensive BE + FE implementation guides with full traceability.
skills:
  - hoaiminh-domain
  - figma-reader
---

# BA Pipeline Skill — Principal Business Analyst v2.0

> **Role:** You are the Principal BA for any software project.
> **Mission:** Read 7-Pillar SRS → analyze with Figma design → create implementation guides so precise that developers implement correctly on the FIRST try.
> **Quality bar:** Guides must be complete enough for senior developers to implement with ZERO additional questions.
> **Standard:** Every guide section cites the source requirement (BR-xx, FR-xx, NFR-xx).

---

## 1. Paths

### External (Shared Pipeline — IO only)
```
READ:   C:\ai-pipeline\requirements\     (REQ_*.md — SRS input)
READ:   Figma MCP (figma_read)           (live designs — ONLY source of visual truth)
WRITE:  C:\ai-pipeline\guides\           (BE_*.md + FE_*.md — output for dev teams)
```

> 🔴 **NEVER read from `C:\ai-pipeline\designs\` or local PNG files.** Use Figma MCP exclusively.
> 🔴 **NEVER generate guides WITHOUT reading the SRS first.** SRS is the source of truth.

### Internal (BA Workspace)
```
DOMAIN:  .agent\skills\hoaiminh-domain\sections\   (business context, schema, rules — if HM project)
MEMORY:  .agent\skills\hoaiminh-domain\memory\     (feature analysis history)
```

---

## 2. File Naming Convention

```
SRS Input:    REQ_{SEQ}_{FeatureName}.md
BE Guide:     BE_{SEQ}_{FeatureName}.md
FE Guide:     FE_{SEQ}_{FeatureName}.md

SEQ: 001-099 = Hoài Minh Honda
SEQ: 100-199 = Other projects (if using this skill)
FeatureName: PascalCase (Receipt, Invoice, CustomerPortal)
```

---

## 3. Execution Protocol

### Step 1: Auto-Scan & Select SRS

1. Scan `C:\ai-pipeline\requirements\` for `REQ_*.md` files without a matching guide pair in `C:\ai-pipeline\guides\`
2. If 1 unprocessed file → auto-select it
3. If multiple → list them and ask user which to process
4. If 0 → inform: "No new requirement files found. Please run /clean-requirement first."

**Check memory first:** Read `.agent\skills\hoaiminh-domain\memory\` for `{FeatureName}.md` → use as additional context. Do NOT ask user — just use it.

---

### Step 2: Read SRS — Extract All 7 Pillars

Read the SRS file completely. Extract and organize:

```
FROM PILLAR 1 → Extract:
  - Project name, module, platform
  - Actors table → role-permission matrix
  - Assumptions + Dependencies + Constraints

FROM PILLAR 2 → Extract:
  - ALL business rules (BR-xx) with rationale
  - Group by category (creation / status / calculation / security)

FROM PILLAR 3 → Extract:
  - ALL functional requirements (FR-xx) with priority + related BR
  - ALL BDD scenarios (AC-xx-xx) — these become validation rules + test cases
  - Feature group structure → maps to API endpoint groups

FROM PILLAR 4 → Extract:
  - Performance requirements (NFR-Pxx) → BE: API response time constraints, DB index hints
  - Security requirements (NFR-Sxx) → BE: auth middleware, audit log requirements
  - Usability requirements (NFR-Uxx) → FE: error message format, validation UX
  - Reliability requirements (NFR-Rxx) → BE: logging, backup notes

FROM PILLAR 5 → Extract:
  - Primary user flow → API endpoint call sequence
  - Status definitions → C# enum + TypeScript enum
  - Transition table → state machine guard logic in BE + FE button visibility
  - Invalid transitions → 400 error responses in BE

FROM PILLAR 6 → Extract:
  - Data consumed → readonly fields in FE, no write endpoints
  - Owned data → editable field matrix per status
  - Enumerations → contract values (IMMUTABLE, use in constants)
  - External integrations → BE service dependencies

FROM PILLAR 7 → Extract:
  - Screen inventory → FE component tree
  - Figma file name + page name → used to load correct Figma frame via MCP
  - Screen specs → grid columns, filter fields, dialog fields
  - Visibility rules → FE editability matrix

FROM APPENDIX A → Extract:
  - Risks → BE edge case handling, FE UX error states

FROM APPENDIX C → Extract:
  - TBD items → flag in guides as ⚠️ PENDING DECISION
  - Assumptions → note in guides as ℹ️ ASSUMED
```

---

### Step 3: Read Figma Design via MCP

1. Call `figma_status` → verify Figma Desktop + Plugin connected
2. **If NOT connected:** Note in both guides: "⚠️ Figma design not read — connect Figma Desktop + MCP plugin and re-run for visual specs." Then continue with SRS data only.
3. **If connected:**

   a. **Infer which screen to read** from SRS Pillar 7 screen inventory:
      - Take the first screen in SCR-01 (usually List screen) → look for a frame with matching name in Figma
      - Then read SCR-02 (Detail screen) if present
      
   b. **Read design data:**
      ```
      figma_read scan_design       → overview of all text, colors, components on page
      figma_read get_selection     → if user has a frame selected → prioritize this
      figma_read get_design_context → for selected/main frame → layout, tokens, components
      ```

   c. **Analyze BODY content only** (skip sidebar, header, navigation chrome):
      - Identify layout structure (grid columns, form sections, dialogs)
      - Map colors → SCSS design tokens (from figma-reader skill)
      - Map components → Hoài Minh wrapper components (from figma-reader skill)
      - Extract exact field names visible in UI → cross-check against SRS Pillar 6 data
      - Extract button labels → verify against SRS Pillar 5 transitions + Pillar 7 visibility

   d. **Cross-reference SRS ↔ Figma:**
      ```
      For each screen in SRS Pillar 7:
        - Verify fields in Figma match fields in SRS Pillar 6 owned data table
        - Note ANY field in Figma not in SRS → flag as UNDOCUMENTED in FE Guide
        - Note ANY field in SRS not in Figma → flag as DESIGN MISSING in FE Guide
        - Verify button labels match transition triggers in SRS Pillar 5
      ```

---

### Step 4: Load Domain Knowledge (Project-Specific)

**For Hoai Minh ERP projects (module code SAL/CS/WH/HR/SYS):**
- Always read: `01-glossary.md`, `07-business-rules.md`, `06-database-schema.md`, `11-coding-standards.md`
- Module-specific:
  - SAL → `03-sales-flow.md` + `08-approval-flows.md`
  - CS → `04-service-flow.md`
  - WH → `05-warehouse-flow.md`
  - SYS → `02-roles-permissions.md`

**Conflict resolution (AUTO — never ask user):**
- SRS BR conflicts with domain file → **SRS wins** (it is more recent and project-specific)
- Update mental model, note the override in memory file
- Only ask user if SRS genuinely contradicts itself (not if it contradicts domain file)

**For non-HM projects:** Skip domain files. Rely entirely on SRS content.

---

### Step 5: Deep Analysis (Present to User Before Writing Guides)

Display a structured analysis summary:

```
📊 ANALYSIS SUMMARY: {FeatureName}
═══════════════════════════════════════════
📁 Source: REQ_{SEQ}_{Name}.md
🎨 Figma: {Connected ✅ | Not Connected ⚠️} — Frames read: {list}
🏗️  Module: {SAL|CS|WH|...} | Platform: {Web|Mobile|Both}

BUSINESS RULES: {N} rules extracted (BR-01 to BR-{N})
  ├── Critical (SHALL NOT violated): {list top 3}
  └── Calculation rules: {list any formula rules}

FUNCTIONAL REQUIREMENTS: {N} requirements
  ├── High Priority: {N} (FR-xx, FR-xx, ...)
  ├── Medium Priority: {N}
  └── With BDD scenarios: {N} scenarios total

STATE MACHINE: {N} statuses detected
  └── {STATUS_A} → {STATUS_B} → {STATUS_C} (terminal)

DATABASE IMPACT:
  ├── Primary table: {table}
  ├── Related tables: {list}
  └── New columns needed: {list or "None"}

⚠️  CONFLICTS DETECTED:
  ├── SRS vs Figma: {field X in Figma not in SRS} or "None"
  └── SRS vs Domain: {rule Y differs} or "None"

⚠️  PENDING DECISIONS (from SRS TBD items):
  ├── TBD-01: {question} → impacts FR-xx
  └── TBD-02: {question} → impacts BE validation

🎯 GUIDE CREATION: Proceeding to generate BE + FE guides...
```

**Approval Gate:**
- **No conflicts, no TBD items** → Auto-proceed: "Analysis complete. Creating guides now..."
- **Conflicts found** → Auto-resolve using rules above, note resolution in guides
- **Critical TBD that blocks implementation** → Ask user the specific TBD question, then proceed

---

### Step 6: Create BE Guide → `C:\ai-pipeline\guides\BE_{SEQ}_{Name}.md`

Every section must cite its source requirement.

```markdown
# BE Implementation Guide: {FeatureName}
> **From:** REQ_{SEQ}_{Name}.md (7-Pillar SRS, IEEE 29148)
> **Generated:** {ISO timestamp}
> **Module:** {module} | **Platform:** {platform}
> **Traceability:** All sections reference SRS IDs (BR-xx, FR-xx, NFR-xx)

---

## 1. Overview
{What this feature does from a BE perspective. 1 paragraph max.}

**NFR Performance Targets (from SRS §NFR-P):**
- API list endpoints: < {N}s at P95 → enforce with query optimization + pagination
- API detail endpoints: < {N}s at P95 → enforce with eager loading, avoid N+1
- Concurrent users: {N} → connection pool sizing, async handlers

**Security Requirements (from SRS §NFR-S):**
- {Auth middleware requirement from NFR-S01}
- {Audit log requirement from NFR-S04}

---

## 2. Database Schema
> Source: SRS §6.2 Owned Data + §6.1 Consumed Data

### Primary Table: {TableName}
| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| Id | uniqueidentifier | NO | newid() | PK |
| {field} | {type} | {Y/N} | {default} | {from FR-xx / BR-xx} |
| Status | varchar(50) | NO | '{initial_status}' | Contract values — see §3 |
| CreatedAt | datetime2 | NO | getutcdate() | Audit — NFR-S04 |
| CreatedBy | uniqueidentifier | NO | — | FK → Users.Id — NFR-S04 |
| UpdatedAt | datetime2 | YES | — | Audit — NFR-S04 |
| UpdatedBy | uniqueidentifier | YES | — | FK → Users.Id |
| IsDeleted | bit | NO | 0 | Soft delete |

### Related Tables (from SRS §6.1)
| Table | Relationship | Access Type | Notes |
|-------|-------------|-------------|-------|
| {Table} | {FK relationship} | READ-ONLY | SRS §6.1 |

### New Columns / Migration Required
```sql
-- Migration: Add {FeatureName} columns
ALTER TABLE {Table} ADD {column} {type} NULL;
-- or: CREATE TABLE {NewTable} (...)
```

---

## 3. Constants & Enums
> Source: SRS §6.4 Contract Values — IMMUTABLE

```csharp
// File: Constants/{FeatureName}Constants.cs
public static class {FeatureName}Status
{
    // Source: SRS §6.4 {Entity} Status Codes — DO NOT CHANGE VALUES
    public const string {STATUS_A} = "{STATUS_CODE_A}";  // BR-{nn}
    public const string {STATUS_B} = "{STATUS_CODE_B}";
    // ... all statuses from SRS §6.4
    
    public static readonly IReadOnlyList<string> All = new[]
    {
        {STATUS_A}, {STATUS_B}, // ...
    };
}

public static class {FeatureName}Permissions
{
    // Source: SRS §1.2 Actors & Permissions
    public const string Create = "{module}.{feature}.create";
    public const string Edit   = "{module}.{feature}.edit";
    public const string Approve = "{module}.{feature}.approve";
    public const string Delete = "{module}.{feature}.delete";
}
```

---

## 4. State Machine
> Source: SRS §5.2 Status / Lifecycle — BR-{nn}, BR-{nn}

### Status Definitions

| Status | Display | Description | Source |
|--------|---------|-------------|--------|
| {STATUS_A} | {label} | {from SRS} | SRS §5.2 |

### Valid Transitions

| From | To | Guard Condition | Actor | API Action | Source |
|------|----|-----------------|-------|------------|--------|
| {FROM} | {TO} | {condition from SRS transition table} | {role} | PATCH /.../{id}/status | BR-{nn} |

### Invalid Transition Responses
```
Any transition not in the valid table above → HTTP 400
{
  "code": "INVALID_STATUS_TRANSITION",
  "message": "Cannot transition from {FROM} to {TO}",
  "currentStatus": "{FROM}",
  "requestedStatus": "{TO}"
}
```

---

## 5. API Endpoints
> Source: SRS §3 Functional Requirements — FR-xx mapped to endpoints

### Record Type Definitions (C#)

```csharp
// Request: {FeatureName}CreateRequest — FR-{nn}
public record {FeatureName}CreateRequest(
    // Fields from SRS §6.2 Owned Data (editable when status = INITIAL)
    {type} {Field1},     // FR-{nn}: {description}
    {type} {Field2},     // FR-{nn}: {description}
    // Validation enforced by Pillar 3 AC-{nn} BDD scenarios
);

// Response: {FeatureName}Response
public record {FeatureName}Response(
    Guid Id,
    string Status,
    {type} {Field1},
    // ... all fields from SRS §6.2 + §6.1 readonly fields
    DateTimeOffset CreatedAt,
    string CreatedByName
);
```

### Endpoint Definitions

#### [GET] /api/{module}/{feature}
> Implements: FR-{nn} — {FR title}
> Auth: NFR-S01 (JWT required), Permission: {permission}

**Query Parameters:**
| Param | Type | Required | Description | Validation |
|-------|------|----------|-------------|------------|
| {filter} | {type} | No | {what it filters} | {rule} |
| page | int | No | Page number (default: 1) | > 0 |
| pageSize | int | No | Items per page (default: 20, max: 100) | NFR-P01: P95 < {N}s |

**Handler Logic (step-by-step):**
1. Validate JWT → extract actor identity (NFR-S01)
2. Authorize: check actor has `{permission}` (NFR-S02)
3. Build query: {base WHERE clause from SRS constraints}
4. Apply tenant/scope filter: {scope rule from BR-xx}
5. Apply pagination (NFR-P01: add DB index on {column} to meet P95 target)
6. Map to {FeatureName}Response records
7. Return: `{ items: [...], total: N, page: P, pageSize: S }`

---

#### [GET] /api/{module}/{feature}/{id}
> Implements: FR-{nn} — {FR title}

**Handler Logic:**
1. Validate JWT (NFR-S01)
2. Authorize (NFR-S02)
3. Fetch by Id — include related data from SRS §6.1
4. Verify actor has scope access (BR-{nn})
5. Map and return {FeatureName}Response

---

#### [POST] /api/{module}/{feature}
> Implements: FR-{nn} — {FR title}
> Validates: BR-{nn} (creation rules)

**Handler Logic:**
1. Validate JWT + Permission: `{feature}.create`
2. Validate request model:
   - {field}: {validation from SRS §3 AC-xx} → else HTTP 422
   - {field}: required, not empty → BR-{nn}
3. Business rules check:
   - BR-{nn}: {rule check}
4. Create entity:
   - Set Status = {initial_status} (BR-{nn}: initial status rule)
   - Set CreatedAt = UtcNow, CreatedBy = actor.Id (NFR-S04)
5. Save to DB + audit log entry
6. Return HTTP 201 + created record

---

#### [PATCH] /api/{module}/{feature}/{id}
> Implements: FR-{nn} — {FR title}

**Handler Logic:**
1. Validate JWT + Permission: `{feature}.edit`
2. Load existing record — 404 if not found
3. Check editable status: Status must be in [{editable_statuses}] (BR-{nn})
4. Apply partial update — only fields in SRS §6.2 marked "editable"
5. Set UpdatedAt, UpdatedBy (NFR-S04)
6. Save + audit log

---

#### [PATCH] /api/{module}/{feature}/{id}/status
> Implements: FR-{nn} — {FR title}
> Enforces: SRS §5.2 State Machine

```csharp
// Handler logic
var transition = ValidTransitions.FirstOrDefault(
    t => t.From == current.Status && t.To == request.NewStatus);

if (transition == null)
    return BadRequest(new { code = "INVALID_STATUS_TRANSITION", ... });

if (!actor.HasRole(transition.AllowedActor))
    return Forbid();

// Execute transition
entity.Status = request.NewStatus;
// Side effects per SRS §5.3:
// {e.g., if transitioning to COMPLETED → notify via {method}}
```

---

## 6. Validation Rules
> Source: SRS §3 FR-xx Acceptance Criteria (BDD scenarios)

| ID | Field / Target | Condition | Error Message (user-facing) | HTTP Code | Source AC |
|----|---------------|-----------|----------------------------|-----------|-----------|
| VAL-01 | {field} | Required, not null/empty | "{Field} là bắt buộc" | 422 | AC-{nn}-{nn} |
| VAL-02 | {field} | {condition from BDD Given clause} | "{message}" | {code} | AC-{nn}-{nn} |
| VAL-{n} | {business rule} | BR-{nn}: {condition} | "{message}" | 400/422 | BR-{nn} |

---

## 7. Edge Cases & Error Handling
> Source: SRS Appendix A Risk Register

| Risk ID | Scenario | Detection | Handling |
|---------|----------|-----------|---------|
| RISK-01 | {concurrent edit scenario from SRS appendix} | Check ETag / RowVersion | HTTP 409 Conflict + current state |
| RISK-02 | {orphan data risk} | Before delete, check children | HTTP 409 + list of blocking children |
| RISK-{n} | {risk from SRS} | {detection method} | {handling} |

---

## 8. Coding Standards & File Locations
> Source: SRS §1.4 Constraints + domain coding standards

```
{FeatureName}/
├── {FeatureName}Handler.cs          // Request handlers (CQRS pattern)
├── {FeatureName}Repository.cs       // DB access layer
├── {FeatureName}Constants.cs        // Enums, status codes — §3
├── {FeatureName}Validator.cs        // FluentValidation — §6
├── {FeatureName}MappingProfile.cs   // AutoMapper profiles
└── {FeatureName}Tests/
    └── {FeatureName}HandlerTests.cs // Test: AC-xx-xx BDD scenarios
```

---

## 9. ⚠️ Pending Decisions (from SRS TBD items)

> These items CANNOT be implemented until resolved. Dev team must WAIT.

{For each TBD-xx in SRS Appendix C:}
| TBD ID | Question | Impacts | Recommended Default |
|--------|---------|---------|---------------------|
| TBD-01 | {question from SRS} | {endpoint or rule} | {reasonable default if dev needs to proceed} |
```

---

### Step 7: Create FE Guide → `C:\ai-pipeline\guides\FE_{SEQ}_{Name}.md`

```markdown
# FE Implementation Guide: {FeatureName}
> **From:** REQ_{SEQ}_{Name}.md (7-Pillar SRS) + Figma design
> **Generated:** {ISO timestamp}
> **Platform:** {Angular 16 + Kendo UI 13 | React | Vue | ...}
> **Figma Source:** {file name + page + frame names read via MCP}
> **Traceability:** All sections reference SRS IDs (FR-xx, NFR-xx, AC-xx)

---

## 1. Overview
{What this feature looks like and does from FE perspective. Reference SRS §1.1 Business Objective.}

**Performance Constraints (SRS NFR-P):**
- Initial page load: < {N}s → lazy-load route module
- API calls: < {N}s → add loading skeleton UI while fetching

**UX Requirements (SRS NFR-U):**
- Language: {Vietnamese | English | Bilingual}
- Error display: {inline / toast / modal} — NFR-U02
- Validation: real-time inline feedback on blur/submit — NFR-U03

---

## 2. Component Architecture
> Source: SRS §7.2 Screen Inventory + Figma scan

```
{feature}/
├── {feature}-list/
│   ├── {feature}-list.component.ts
│   ├── {feature}-list.component.html
│   └── {feature}-list.component.scss
├── {feature}-detail/
│   ├── {feature}-detail.component.ts
│   └── ...
├── {feature}-dialog/          (if SCR-03 exists in SRS)
│   └── ...
├── {feature}.service.ts       (API calls)
├── {feature}.model.ts         (TypeScript interfaces)
├── {feature}.constants.ts     (status codes, enums from SRS §6.4)
└── {feature}.routes.ts
```

---

## 3. Constants & Enums (TypeScript)
> Source: SRS §6.4 Contract Values — IMMUTABLE (mirror BE constants)

```typescript
// {feature}.constants.ts

// Status codes — SRS §6.4 — DO NOT CHANGE VALUES
export const {FEATURE}_STATUS = {
  {STATUS_A}: '{STATUS_CODE_A}',  // BR-{nn}
  {STATUS_B}: '{STATUS_CODE_B}',
} as const;
export type {Feature}Status = typeof {FEATURE}_STATUS[keyof typeof {FEATURE}_STATUS];

// Status badge display config — SRS §5.2 + Figma color tokens
export const {FEATURE}_STATUS_CONFIG: Record<{Feature}Status, { label: string; cssClass: string; color: string }> = {
  [{FEATURE}_STATUS.{STATUS_A}]: {
    label: '{Display Label from SRS §5.2}',
    cssClass: 'badge-{color}',
    color: '$color-{token}',  // SCSS token from design system
  },
  // ... all statuses
};
```

---

## 4. TypeScript Interfaces
> Source: SRS §6.2 Owned Data + §6.1 Consumed Data

```typescript
// {feature}.model.ts

export interface {Feature} {
  id: string;
  status: {Feature}Status;
  {field1}: {type};  // SRS §6.2 — owned, editable when {condition}
  {field2}: {type};  // SRS §6.1 — readonly, from {SourceModule}
  // ...
  createdAt: string;
  createdByName: string;
}

export interface {Feature}ListItem {
  // Grid columns only — subset of {Feature}
  id: string;
  status: {Feature}Status;
  {gridField1}: {type};
  {gridField2}: {type};
}

export interface Create{Feature}Request {
  {field}: {type};  // FR-{nn}: required
}
```

---

## 5. API Integration
> Source: SRS §3 FR-xx mapped to BE endpoints

| UI Action | FR | HTTP | Endpoint | Payload | Response | Error Handling |
|-----------|-----|------|----------|---------|---------|---------------|
| Load list | FR-{nn} | GET | /api/{module}/{feature} | query params | {Feature}ListItem[] | Show empty state |
| Open detail | FR-{nn} | GET | /api/{module}/{feature}/{id} | — | {Feature} | 404 → navigate back |
| Create new | FR-{nn} | POST | /api/{module}/{feature} | Create{Feature}Request | {Feature} | 422 → show inline errors |
| Edit | FR-{nn} | PATCH | /api/{module}/{feature}/{id} | Partial<{Feature}> | {Feature} | 409 → conflict msg |
| Change status | FR-{nn} | PATCH | /api/{module}/{feature}/{id}/status | { newStatus } | {Feature} | 400 → toast error |

---

## 6. Screen Specifications

### SCR-01: {Feature} List Screen
> Source: SRS §7.3 SCR-01 + Figma frame "{FrameName}"
> Route: `/{module}/{feature}`

**Filter Bar (from Figma + SRS §7.3):**
| Filter | Component | Field | API Param |
|--------|-----------|-------|-----------|
| {Date range} | `<ps-kendo-date-range>` | dateFrom/dateTo | dateFrom, dateTo |
| {Status} | `<ps-kendo-dropdown>` | status | status |
| {Search} | `<ps-kendo-textbox>` | keyword | q |

**Grid Columns (from Figma column widths + SRS §7.3):**
| # | Column Header | Field | Width | Format | Sortable |
|---|---|---|---|---|---|
| 1 | {header from Figma} | {field} | {px from Figma} | {format} | Yes/No |

**Status Badge per Row (SRS §5.2 + Figma colors):**
```html
<span [class]="getStatusClass(item.status)">{{ getStatusLabel(item.status) }}</span>
```
```typescript
getStatusClass(status: {Feature}Status): string {
  return {FEATURE}_STATUS_CONFIG[status]?.cssClass ?? 'badge-default';
}
```

**Action Menu per Status (SRS §7.3 Visibility Rules):**
| Status | Available Actions | Triggered FR |
|--------|-------------------|-------------|
| {STATUS_A} | View, Edit, {Action} | FR-{nn}, FR-{nn} |
| {STATUS_B} | View only | — |

---

### SCR-02: {Feature} Detail Screen
> Source: SRS §7.3 SCR-02 + Figma frame "{FrameName}"
> Route: `/{module}/{feature}/{id}`

**Form Sections (from Figma layout scan):**

**Section 1: {Section Name} (from Figma)**
| Field Label | Component | Data Binding | Editable When |
|---|---|---|---|
| {label from Figma} | `<ps-kendo-textbox>` | `form.get('{field}')` | Status in [{editable_statuses}] — FR-{nn} |
| {label} | `<ps-kendo-numeric-textbox>` | `form.get('{field}')` | Read-only — SRS §6.1 |

**Editability Matrix (SRS §7.3 Visibility Rules + Pillar 6):**
| Field | Draft | Pending | Approved | Completed |
|-------|-------|---------|---------|-----------|
| {field1} | ✏️ Edit | ✏️ Edit | 🔒 Read | 🔒 Read |
| {field2} | ✏️ Edit | 🔒 Read | 🔒 Read | 🔒 Read |

**Action Buttons (SRS Pillar 5 Transition Table → Pillar 7 Visibility Rules):**
| Button Label | Trigger FR | Visible When | Enabled When | Calls Endpoint |
|---|---|---|---|---|
| {Save} | FR-{nn} | Status = DRAFT | Form valid | PATCH /.../{id} |
| {Submit} | FR-{nn} | Status = DRAFT, Role = {role} | No pending changes | PATCH /.../{id}/status |
| {Approve} | FR-{nn} | Status = PENDING, Role = Manager | — | PATCH /.../{id}/status |

---

### SCR-03: {Create / Edit Dialog} (if exists)
> Source: SRS §7.3 SCR-03

**Trigger:** {button click or navigation}
**Fields:** {from SRS §7.3 + Figma form fields}

```typescript
// Dialog form group
this.form = this.fb.group({
  {field1}: ['', [Validators.required]],      // FR-{nn}: required
  {field2}: [null, [Validators.min(0)]],       // BR-{nn}: must be >= 0
});
```

---

## 7. Form Validation
> Source: SRS §3 BDD Acceptance Criteria (AC-xx-xx) — mirror BE validation

| Field | Angular Validator | Error Message | Trigger | Source AC |
|-------|-----------------|---------------|---------|-----------|
| {field} | `Validators.required` | "{Field} là bắt buộc" | On blur + submit | AC-{nn}-{nn} |
| {field} | `Validators.min(0)` | "{Field} phải lớn hơn 0" | On blur | AC-{nn}-{nn} |
| {field} | `{customValidator}` | "{business message}" | On submit | BR-{nn} |

**Error Display Pattern (NFR-U02, NFR-U03):**
```html
<kendo-formfield>
  <kendo-textbox formControlName="{field}"></kendo-textbox>
  <kendo-formerror *ngIf="form.get('{field}')?.errors?.['required']">
    {Field} là bắt buộc
  </kendo-formerror>
</kendo-formfield>
```

---

## 8. Design Tokens Reference
> Source: Figma MCP color scan + project design system

**Colors used (mapped from Figma):**
| Figma Token | SCSS Variable | Usage |
|---|---|---|
| {figma-color-token} | `$color-{name}` | {where used: badge, button, etc.} |

**Typography (from Figma):**
- Headers: `{font-family}, {size}px, {weight}`
- Body: `{font-family}, {size}px, {weight}`

**Spacing (from Figma layout):**
- Section padding: `{N}px` → `$spacing-{token}`
- Field gap: `{N}px` → `$spacing-{token}`

---

## 9. ⚠️ Design ↔ SRS Discrepancies

{List any field/button found in Figma but NOT in SRS, or in SRS but NOT in Figma}

| Type | Item | Found In | Missing In | Action Required |
|------|------|----------|-----------|----------------|
| UNDOCUMENTED | {field} | Figma | SRS | ⚠️ Ask PM to add to SRS |
| DESIGN MISSING | {field} | SRS §6.2 | Figma | ⚠️ Ask design team to add to Figma |
| LABEL MISMATCH | {field} | SRS: "{label1}" | Figma: "{label2}" | ℹ️ Use Figma label for display, SRS for data binding |

---

## 10. ⚠️ Pending Decisions (from SRS TBD items)

{For each TBD-xx in SRS Appendix C:}
| TBD ID | Question | Impacts FE | Temporary Approach |
|--------|---------|-----------|-------------------|
| TBD-01 | {question from SRS} | {component or feature} | {hide behind feature flag / show placeholder} |
```

---

### Step 8: Save Context Memory

File: `.agent\skills\hoaiminh-domain\memory\{FeatureName}.md`

> For non-HM projects: create a `memory/` folder under the project BA workspace (if applicable). If no BA workspace defined, skip memory.

Memory must contain all 10 sections (see previous version of skill for template). Additionally include:
- SRS version that was analyzed (REQ_{SEQ})
- Number of BDD scenarios successfully mapped
- Discrepancies found between Figma and SRS

---

### Step 9: Report

```
✅ BA Analysis Complete: {FeatureName}
══════════════════════════════════════════════

📄 SRS Analyzed: REQ_{SEQ}_{Name}.md
   ├── Pillars read: 7/7
   ├── Business Rules: {N} (BR-01 to BR-{N})
   ├── Functional Requirements: {N} (FR-01 to FR-{N})
   ├── BDD Scenarios: {N} acceptance criteria mapped
   └── TBD items: {N} items pending

🎨 Figma Design: {✅ Read N screens | ⚠️ Not connected}
   ├── SCR-01: {frame name} — {N} fields extracted
   ├── SCR-02: {frame name} — {N} fields extracted
   └── Discrepancies: {N} items flagged in FE Guide §9

📁 Guides Generated:
   📄 BE Guide: C:\ai-pipeline\guides\BE_{SEQ}_{Name}.md ({N} lines)
   📄 FE Guide: C:\ai-pipeline\guides\FE_{SEQ}_{Name}.md ({N} lines)
   📝 Memory:   .agent\skills\hoaiminh-domain\memory\{Name}.md

⚠️  Action Required Before Development:
   {List all TBD items from SRS that need PM/client resolution}

🔗 Next Steps:
   → BE team: Open BE workspace → /be-implement
   → FE team: Open FE workspace → /fe-implement
   → If Figma not connected: Connect and re-run for visual specs
```

---

## 4. Quality Gates

### Minimum Acceptance Criteria for Guides:
- **BE Guide:**
  - ≥ 120 lines
  - Has: Overview with NFR targets, DB schema, C# constants, state machine table + invalid transitions, all CRUD + status endpoints with step-by-step handler logic, validation table citing AC-xx, edge case table citing RISK-xx, file structure
  - Every BR-xx cited at least once
  - Every FR-xx has a corresponding endpoint or validation rule

- **FE Guide:**
  - ≥ 120 lines
  - Has: Overview with performance + UX constraints, component tree, TS constants + status config, API integration table, all screens with grid columns + filter bar + editability matrix + button visibility matrix, form validation table citing AC-xx, design tokens table from Figma
  - Every screen in SRS §7.2 has a section in guide §6

### Banned Patterns (instant fail):
- ❌ Copy-pasting requirements into guides without translation to technical spec
- ❌ Leaving template placeholder text (e.g., `{field}`, `{type}`) in guides
- ❌ Any section with only headers and no content
- ❌ Missing traceability (no FR-xx, BR-xx citations)
- ❌ BE Guide has API endpoints but no handler logic steps

---

## 5. Memory Management

- **One memory file per feature** (not per session)
- Re-analyzing same feature → **overwrite** existing memory
- Memory file name = PascalCase feature (e.g., `Receipt.md`, `PaymentPortal.md`)
- Memory must include revision history with date + SEQ source
