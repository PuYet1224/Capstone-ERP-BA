---
name: memorize
description: Read all SRS, implemented code (BE + FE), and guides. Distill into a permanent English memory file in BA workspace. Run BEFORE /clean-pipeline to ensure AI remembers everything permanently.
---

# Memorize Skill -- Knowledge Distillation

> **Role:** You are a Knowledge Distiller.  
> **Mission:** Read everything that was built -> distill into a permanent, curated English memory file.  
> **Why:** Pipeline files are temporary. Code changes. Memory is the permanent truth.

---

## 1. Trigger

Activated when user runs `/memorize [feature-name]`.

**MUST run BEFORE `/clean-pipeline`.**

---

## 2. What to Read

Read from multiple sources to build a complete picture:

### Source 1: Original Requirement
```
{PROJECT_PIPELINE}\requirements\REQ_{SEQ}_{Feature}.md
```
-> Extract: business context, actors, original business rules, open questions resolved

### Source 2: Implementation Guides (planned state)
```
{PROJECT_PIPELINE}\guides\BE_{SEQ}_{Feature}.md
{PROJECT_PIPELINE}\guides\FE_WEB_{SEQ}_{Feature}.md
```
-> Extract: planned API contracts, DTOs, state machine

### Source 3: Actual BE Code (final state -- truth)
```
modules/MTB/Features/M.{Module}/F.{Feature}/*.cs
modules/MTB/Features/M.{Module}/F.{Feature}/Constants/*.cs
```
> Read from: {BE_ROOT}\  
-> Extract: actual handlers, real status values, real field names, real validation logic

### Source 4: Actual FE Code (final state)
```
src/app/modules/{feature}/*.ts
src/app/modules/{feature}/*.html
```
> Read from: {FE_ROOT}\  
-> Extract: actual component structure, actual API calls used, actual UI states

---

## 3. Distillation Rules

> Read sources -> synthesize -> DO NOT just copy-paste.

**Priority order when plan vs code differ:**
```
Actual Code > Implementation Guide > SRS
```

The code is what's running in production. If guide said X but code does Y -> memory records Y, notes the deviation.

**What to include:**
- [OK] Final business rules (as implemented)
- [OK] Final API contracts (actual routes, actual payloads)
- [OK] Final state machine (from code, not guide)
- [OK] Final DB tables and relationships used
- [OK] Decisions made during implementation (why, not just what)
- [OK] Bugs found during review/enhance cycles -> how they were fixed
- [OK] Edge cases discovered during testing
- [OK] Cross-module dependencies confirmed

**What to exclude:**
- [NO] Open questions that were resolved (merge the answer in)
- [NO] Drafts and abandoned approaches
- [NO] Raw file contents (synthesize, don't dump)

---

## 4. Memory File Template

**Output path:** `{BA_ROOT}\.agent\projects\hoaiminh\memory\{Feature}.md`

> Overwrite if exists. This is the final, authoritative version.

```markdown
# Feature Memory: {Feature Display Name}

> **Module:** {SAL | CS | WH | HR | SYS}  
> **Memorized:** {YYYY-MM-DD}  
> **Source files:** REQ_{SEQ} + BE_{SEQ} + FE_{SEQ} + actual code  
> **Status:** Production [OK]

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
- `{tbl_name}` -- {relationship + why it's used}

---

## 3. State Machine (as implemented)

| Status | Code | Meaning |
|--------|------|---------|
| {StatusName} | {N} | {business meaning} |

**Transitions:**
| From | To | Condition |
|------|----|-----------|
| {status} | {status} | {when allowed} |
| {status} | {status} | [!] Final state -- no outgoing |

---

## 4. API Contracts (actual, as implemented)

### GET {route}
- **Auth:** RequireAuthorization
- **HEAD filter:** Yes -- `x.Head == currentUser.HeadCode`
- **Returns:** `{FeatureDto}[]` with pagination
- **Key fields:** {list key fields returned}

### POST {route} -- Create/Edit
- **Payload:** `{command fields}`
- **Validation:** {key rules}
- **Side effects:** {what else changes}

### POST {route}/update-status
- **Payload:** `{ code: int, status: int }`
- **Transitions:** {valid ones only}
- **Transaction:** Yes -- ExecutionStrategy

---

## 5. Business Rules (final, as implemented)

| ID | Rule | Enforced In |
|----|------|-------------|
| BR-01 | {rule description} | BE validation / FE disable |
| BR-02 | {rule description} | State machine transition check |

---

## 6. Component Architecture (FE)

```
{feature}/
|-- {feature}-list.component.ts   -> Grid view, route: /{module}/{feature}
|-- {feature}-detail.component.ts -> Form view, route: /{module}/{feature}/:code
|-- {feature}.service.ts          -> API calls
```

**Key UI behaviors:**
- {describe conditional display, disabled states, badge colors}

---

## 7. Key Decisions & Rationale

> WHY things were done this way. Successor devs need this.

- **Decision:** {what} -> **Because:** {why, especially non-obvious reasons}
- **Decision:** {what} -> **Because:** {why}

---

## 8. Bugs Fixed (from /review + /enhance cycles)

| Bug | Root Cause | Fix Applied |
|-----|-----------|-------------|
| {description} | {why it happened} | {what was changed} |

---

## 9. Cross-Module Dependencies

**This feature reads from:**
- `{Module}` -> `{what data, which table}`

**This feature's output is used by:**
- `{Module}` -> `{how/when}`

---

## 10. Edge Cases & Gotchas

> Things that will bite the next dev if they don't know.

- [!] **{gotcha}:** {explanation + how to handle}
- [!] **{gotcha}:** {explanation}

---

## 11. Revision History

| Date | Change | Reason |
|------|--------|--------|
| {date} | Initial implementation | REQ_{SEQ} |
| {date} | {what changed} | {why -- bug fix, requirement change, etc.} |
```

---

## 5. Output Report

After saving memory file:

```
[OK] Memorized: {Feature}

-- Memory saved: .agent\projects\hoaiminh\memory\{Feature}.md

-- Distilled from:
   -- REQ_{SEQ}_{Feature}.md
   -- BE_{SEQ}_{Feature}.md  
   -- FE_WEB_{SEQ}_{Feature}.md
   -> {N} .cs handler files
   -> {N} Angular component files

[!] Deviations from plan (code differs from guide):
   - {e.g., "Status 'Suspended' removed -- not implemented in code"}
   - {e.g., "Added optimistic lock check not in original guide"}

[OK] Memory covers:
   States: {N} | Rules: {N} | APIs: {N} | Gotchas: {N}

[OK] Safe to run: /clean-pipeline {feature-name}
```

---

## 6. Quality Rules

- **English only** -- memory is for future AI agents, keep consistent
- **Concise but complete** -- every section must have real content, not "N/A"
- **Reality-first** -- if code contradicts guide, memory follows code
- **Gotchas section is mandatory** -- at least 1 entry (if truly none: "No known edge cases -- clean implementation")
- **Decisions section is mandatory** -- successor devs need to know WHY, not just WHAT

