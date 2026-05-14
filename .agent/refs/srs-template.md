# 7-Pillar SRS Template (IEEE 29148 Adapted)

> Fill every section. Use `TBD-xx` for genuinely unknown items only.

```markdown
# SRS: {Feature Display Name}

> **Feature Key:** {FeatureKey} (PascalCase, e.g., Receipt, WorkOrder)
> **Module:** {SAL|CS|WH|HR|SYS|MTB|PART}
> **Primary Table:** {tbl_XXXEntityName}
> **Platform:** {Web | Mobile | Both}
> **Version:** 1.0
> **Date:** {YYYY-MM-DD}
> **Author:** {name}

---

## Pillar 1: Scope and Context

### 1.1 Purpose
{2-3 sentences: what this feature does and why it exists}

### 1.2 Actors
| Actor | Role | Vietnamese |
|-------|------|-----------|
| {role} | {what they do in this feature} | {Vietnamese name} |

### 1.3 Assumptions
- ASM-01: {assumption}

### 1.4 Dependencies
- DEP-01: Requires {other feature/module} to be implemented first

### 1.5 Constraints
- CON-01: {technical or business constraint}

---

## Pillar 2: Business Rules

> EARS syntax: "When [trigger], the [system] shall [action]"

| ID | Rule | Rationale |
|----|------|-----------|
| BR-01 | When [trigger], the system shall [action] | {why this rule exists} |
| BR-02 | The system shall [action] | {why} |

---

## Pillar 3: Functional Requirements

### FR Group 1: {Group Name} (e.g., List Management)
| ID | Requirement | Priority |
|----|------------|----------|
| FR-01 | The system shall [action] | High |
| FR-02 | When [trigger], the system shall [action] | Medium |

#### Acceptance Criteria
```gherkin
AC-01-01: {scenario title}
  Given {precondition}
  When {action}
  Then {expected result}

AC-01-02: {scenario title}
  Given {precondition}
  When {action}
  Then {expected result}
```

### FR Group 2: {Group Name}
| ID | Requirement | Priority |
|----|------------|----------|
| FR-03 | ... | High |

#### Acceptance Criteria
```gherkin
AC-02-01: ...
```

---

## Pillar 4: Non-Functional Requirements

### Performance
| ID | Requirement |
|----|------------|
| NFR-P01 | List API response time < 500ms for up to 1000 records |
| NFR-P02 | Detail API response time < 200ms |

### Security
| ID | Requirement |
|----|------------|
| NFR-S01 | All endpoints require JWT Bearer authentication |
| NFR-S02 | HEAD isolation: users can only access data from their own HEAD |
| NFR-S03 | Role-based access: only authorized roles can perform status changes |
| NFR-S04 | All create/update operations must log CreatedBy/UpdatedBy from JWT |

### Usability
| ID | Requirement |
|----|------------|
| NFR-U01 | Error messages must be specific and actionable (not generic) |
| NFR-U02 | Form validation must be real-time (on blur, not on submit) |

---

## Pillar 5: Status and Workflow

### 5.1 Status Definitions
| Status Name | Code (int) | Vietnamese | Meaning |
|-------------|-----------|-----------|---------|
| {StatusA} | {N} | {Vietnamese} | {business meaning} |
| {StatusB} | {N} | {Vietnamese} | {meaning} |
| {StatusC} | {N} | {Vietnamese} | TERMINAL |

> LSStatus TypeData = {N} (from tbl_LSStatus)

### 5.2 Transition Table
| From | To | Trigger | Actor | Condition |
|------|-----|---------|-------|-----------|
| {A} | {B} | {button/event} | {role} | {when allowed} |
| {A} | {C} | Cancel | {role} | Requires reason |

### 5.3 Primary User Flow
```
Actor opens list -> selects record -> edits form -> saves
-> submits for approval -> approved/rejected -> completed
```

---

## Pillar 6: Data Contract

### 6.1 Data Consumed (read-only, from other modules)
| Data | Source Table | How Used |
|------|-------------|----------|
| {data name} | {tbl_XXX} | {dropdown/display/lookup} |

### 6.2 Owned Data (editable fields)
| Field | DB Column | Type | Required | Editable When | Validation |
|-------|-----------|------|----------|--------------|------------|
| {label} | {column} | {type} | Yes/No | Status = {X} | {rule} |

### 6.3 Data Exposed (output to other modules)
| Data | Consumer | Format |
|------|----------|--------|
| {data} | {module} | {how it's consumed} |

### 6.4 Enumerations
| Enum Name | Values | Source |
|-----------|--------|--------|
| {StatusEnum} | {A}={N}, {B}={N} | tbl_LSStatus TypeData={N} |

### 6.5 External Integrations
| System | Integration Type | Purpose |
|--------|-----------------|---------|
| {system} | {API/Event} | {what it does} |

### 6.6 New Entities (tables that DO NOT EXIST yet in DB)

> Skip this section if the feature only uses existing tables.
> For each new entity, provide FULL column specification.
> AI BE reads this to create Entity class + EF Core Migration.

#### {tbl_XXXEntityName} (NEW)

| Column | Type | Required | Unique | FK | Description |
|--------|------|----------|--------|-----|-------------|
| Code | bigint | PK | Yes | - | Auto-increment primary key |
| {Column} | {nvarchar(N)/int/bigint/float/bit/datetime} | Yes/No | Yes/No | {tbl_XXX or -} | {business meaning} |
| Head | bigint | Yes | No | tbl_LSHead | HEAD filter (multi-tenant) |
| Status | int | Yes | No | tbl_LSStatus | Status code |
| TypeData | int | Yes | No | - | Sub-type discriminator |
| CreatedBy | nvarchar(100) | Yes | No | - | Audit: who created |
| CreatedTime | datetime | Yes | No | - | Audit: when created |
| LastModifiedBy | nvarchar(100) | No | No | - | Audit: last editor |
| LastModifiedTime | datetime | No | No | - | Audit: last edit time |

### 6.7 Field Glossary (business meaning of ambiguous fields)

> List any field whose name does NOT clearly convey business meaning.
> AI MUST consult this before writing code. If unclear -> ASK user.

| Table | Field | Technical | Business Meaning |
|-------|-------|-----------|------------------|
| {tbl_XXX} | {FieldName} | {type} | {plain language explanation} |

---

## Pillar 7: UI/UX Specification

### 7.1 Design Reference
- Figma File: {file name or "N/A"}
- Figma Page: {page name}
- Frame Names: {frame1}, {frame2}

### 7.2 Screen Inventory
| ID | Screen Name | Type | Route |
|----|------------|------|-------|
| SCR-01 | {Feature} List | List/Grid | /{module}/{seq}-{feature} |
| SCR-02 | {Feature} Detail | Form/Dialog | /{module}/{seq}-{feature}/:code |

### 7.3 Screen Descriptions

#### SCR-01: {Feature} List
**Filter bar:**
- {dropdown/date picker/text search}

**Grid columns:**
| Column | Label (Vietnamese) | Width | Format | Sortable |
|--------|-------------------|-------|--------|----------|
| {field} | {label} | {px} | {format} | Yes/No |

**Toolbar buttons:**
| Button | Label | Visible When | Action |
|--------|-------|-------------|--------|
| Add | {label} | Always | Open create form |

#### SCR-02: {Feature} Detail
**Form sections:**
- Section 1: {name} -- {fields}
- Section 2: {name} -- {fields}

**Action buttons:**
| Button | Label | Show When Status = | Action |
|--------|-------|-------------------|--------|
| Save | {label} | {StatusA} | Save form |
| Submit | {label} | {StatusA} | Change status to {StatusB} |

---

## Appendix A: Risks

| ID | Risk | Impact | Mitigation |
|----|------|--------|-----------|
| RSK-01 | {risk description} | {impact} | {mitigation} |

## Appendix B: Traceability Matrix

| BR/FR | -> API | -> Screen | -> AC |
|-------|--------|-----------|-------|
| BR-01 | Update{Feature} | SCR-02 | AC-01-01 |
| FR-01 | GetList{Feature} | SCR-01 | AC-01-02 |

## Appendix C: Open Questions (TBD)

| ID | Question | Blocks | Assigned To | Due Date |
|----|----------|--------|-------------|----------|
| TBD-01 | {question} | FR-{nn} | {person} | {date} |
```
