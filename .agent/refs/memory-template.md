# Memory File Template

> Overwrite if exists. This is the final, authoritative version.

```markdown
# Feature Memory: {Feature Display Name}

> **Module:** {ModuleCode}/{SubModule}  _(e.g., MTB/M.Sale, CRM/M.Config -- from module-map.md)_
> **Memorized:** {YYYY-MM-DD}
> **Source files:** REQ_{SEQ} + BE_{SEQ} + FE_{SEQ} + actual code
> **Status:** Production

---

## 1. Business Context

{What this feature does, why it exists, who uses it. 3-5 sentences max.}

**Actors:**
| Role | Can Do |
|------|--------|
| {role} | {actions} |

---

## 2. Database

**Primary table:** `{tbl_name}` -- {what it stores}

**Schema (key columns only):**
| Column | Type | Description |
|--------|------|-------------|
| {col} | {type} | {meaning} |

**Related tables:**
- `{tbl_name}` -- {relationship}

---

## 3. State Machine (as implemented)

| Status | Code | Meaning |
|--------|------|---------|
| {StatusName} | {N} | {business meaning} |

**Transitions:**
| From | To | Condition |
|------|----|-----------| 
| {status} | {status} | {when allowed} |

---

## 4. API Contracts (actual, as implemented)

### POST {routePrefix}{Action} -- List
- **Route prefix:** {routePrefix}  _(e.g., /sale/, /repair/ -- see module-map.md)_
- **HEAD filter:** Yes
- **Returns:** { Total, Data } with items
- **Key fields:** {list}

### POST {routePrefix}{Action} -- Create/Edit
- **Payload:** {fields}
- **Validation:** {rules}
- **Side effects:** {what else changes}

---

## 5. Business Rules (final)

| ID | Rule | Enforced In |
|----|------|-------------|
| BR-01 | {rule} | BE validation / FE disable |

---

## 6. Component Architecture (FE)

```
{feature}/
|-- list.component.ts   -> Grid view
|-- detail.component.ts -> Form view
|-- service.ts           -> API calls
```

---

## 7. Key Decisions and Rationale

- **Decision:** {what} -> **Because:** {why}

---

## 8. Bugs Fixed

| Bug | Root Cause | Fix Applied |
|-----|-----------|-------------|
| {description} | {why} | {fix} |

---

## 9. Cross-Module Dependencies

**Reads from:** {Module} -> {what data}
**Used by:** {Module} -> {how}

---

## 10. Edge Cases and Gotchas

- **{gotcha}:** {explanation + how to handle}

---

## 11. Revision History

| Date | Change | Reason |
|------|--------|--------|
| {date} | Initial | REQ_{SEQ} |
```
