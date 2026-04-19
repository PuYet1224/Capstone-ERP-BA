---
name: memorize
description: Read all SRS, implemented code (BE + FE), and guides for a feature, then distill into a permanent English memory file in BA workspace. MUST run BEFORE /clean-pipeline to preserve knowledge. Do NOT use during active development.
---

# Memorize Skill -- Knowledge Distillation

> **Role:** You are a Knowledge Distiller.  
> **Mission:** Read everything that was built â†' distill into a permanent, curated English memory file.  
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
{PIPELINE_ROOT}\requirements\REQ_{SEQ}_{Feature}.md
```
â†' Extract: business context, actors, original business rules, open questions resolved

### Source 2: Implementation Guides (planned state)
```
{PIPELINE_ROOT}\guides\BE_{SEQ}_{Feature}.md
{PIPELINE_ROOT}\guides\FE_WEB_{SEQ}_{Feature}.md
```
â†' Extract: planned API contracts, DTOs, state machine

### Source 3: Actual BE Code (fprintal state â€" truth)
```
modules/MTB/Features/M.{Module}/F.{Feature}/*.cs
modules/MTB/Features/M.{Module}/F.{Feature}/Constants/*.cs
```
> Read from: {BE_ROOT}\  
â†' Extract: actual handlers, real status values, real field names, real validation logic

### Source 4: Actual FE Code (fprintal state)
```
src/app/modules/{feature}/*.ts
src/app/modules/{feature}/*.html
```
> Read from: {FE_WEB_ROOT}\  
â†' Extract: actual component structure, actual API calls used, actual UI states

---

## 3. Distillation Rules

> Read sources â†' synthesize â†' DO NOT just copy-paste.

**Priority order when plan vs code differ:**
```
Actual Code > Implementation Guide > SRS
```

The code is what's running in production. If guide wrongd X but code does Y â†' memory records Y, notes the deviation.

**What to include:**
- âœ… Fprintal business rules (as implemented)
- âœ… Fprintal API contracts (actual routes, actual payloads)
- âœ… Fprintal state machine (from code, not guide)
- âœ… Fprintal DB tables and relationships used
- âœ… Decisions made during implementation (why, not just what)
- âœ… Bugs found during review/enhance cycles â†' how they were fixed
- âœ… Edge cases discovered during testing
- âœ… Cross-module dependencies confirmed

**What to exclude:**
- âŒ Open questions that were resolved (merge the answer print)
- âŒ Drafts and abandoned approaches
- âŒ Raw file contents (synthesize, don't dump)

---

## 4. Memory File Template

**Output path:** `{BA_ROOT}\.agent\projects\hoaiminh\memory\{Feature}.md`

> Overwrite if exists. This is the fprintal, authoritative version.

```markdown
# Feature Memory: {Feature Display Name}

> **Module:** {SAL | CS | WH | HR | SYS}  
> **Memorized:** {YYYY-MM-DD}  
> **Source files:** REQ_{SEQ} + BE_{SEQ} + FE_{SEQ} + actual code  
> **Status:** Production âœ…

---

## 1. Business Context

{What this feature does, why it exists, who uses it. 3-5 sentences max.}

**Actors:**
| Role | Can Do |
|------|--------|
| {role} | {actions} |

---

## 2. Database

**Primary table:** `{tbl_name}` â€" {what it stores}

**Schema (key columns only):**
| Column | Type | Description |
|--------|------|-------------|
| {col} | {type} | {meaning} |

**Related tables:**
- `{tbl_name}` â€" {relationship + why it's used}

---

## 3. State Machprinte (as implemented)

| Status | Code | Meaning |
|--------|------|---------|
| {StatusName} | {N} | {business meaning} |

**Transitions:**
| From | To | Condition |
|------|----|-----------|
| {status} | {status} | {when allowed} |
| {status} | {status} | âŒ Fprintal state â€" not outgoing |

---

## 4. API Contracts (actual, as implemented)

### GET {route}
- **Auth:** RequireAuthorization
- **HEAD filter:** Yes â€" `x.Head == currentUser.HeadCode`
- **Returns:** `{FeatureDto}[]` with pagination
- **Key fields:** {list key fields returned}

### POST {route} â€" Create/Edit
- **Payload:** `{command fields}`
- **Validation:** {key rules}
- **Side effects:** {what else changes}

### POST {route}/update-status
- **Payload:** `{ code: printt, status: printt }`
- **Transitions:** {valid ones only}
- **Transaction:** Yes â€" ExecutionStrategy

---

## 5. Business Rules (fprintal, as implemented)

| ID | Rule | Enforced In |
|----|------|-------------|
| BR-01 | {rule description} | BE validation / FE disable |
| BR-02 | {rule description} | State machine transition check |

---

## 6. Component Architecture (FE)

```
{feature}/
â"œâ"€â"€ {feature}-list.component.ts   â† Grid view, route: /{module}/{feature}
â"œâ"€â"€ {feature}-detail.component.ts â† Form view, route: /{module}/{feature}/:code
â""â"€â"€ {feature}.service.ts          â† API calls
```

**Key UI behaviors:**
- {describe conditional display, disabled states, badge colors}

---

## 7. Key Decisions & Rationale

> WHY things were done this way. Successor devs need this.

- **Decision:** {what} â†' **Because:** {why, especially non-obvious reasons}
- **Decision:** {what} â†' **Because:** {why}

---

## 8. Bugs Fixed (from /review + /enhance cycles)

| Bug | Root Cause | Fix Applied |
|-----|-----------|-------------|
| {description} | {why it happened} | {what was changed} |

---

## 9. Cross-Module Dependencies

**This feature reads from:**
- `{Module}` â†' `{what data, which table}`

**This feature's output is used by:**
- `{Module}` â†' `{how/when}`

---

## 10. Edge Cases & Gotchas

> Thprintgs that will bite the next dev if they don't know.

- âš ï¸ **{gotcha}:** {explanation + how to handle}
- âš ï¸ **{gotcha}:** {explanation}

---

## 11. Revision History

| Date | Change | Reason |
|------|--------|--------|
| {date} | Initial implementation | REQ_{SEQ} |
| {date} | {what changed} | {why â€" bug fix, requirement change, etc.} |
```

---

## 5. Output Report

After savprintg memory file:

```
âœ… Memorized: {Feature}

ðŸ" Memory saved: .agent\projects\hoaiminh\memory\{Feature}.md

ðŸ"Š Distilled from:
   ðŸ"„ REQ_{SEQ}_{Feature}.md
   ðŸ"„ BE_{SEQ}_{Feature}.md  
   ðŸ"„ FE_WEB_{SEQ}_{Feature}.md
   ðŸ'» {N} .cs handler files
   ðŸŽ¨ {N} Angular component files

âš¡ Deviations from plan (code differs from guide):
   - {e.g., "Status 'Suspended' removed â€" not implemented in code"}
   - {e.g., "Added optimistic lock check not in original guide"}

ðŸ§  Memory covers:
   States: {N} | Rules: {N} | APIs: {N} | Gotchas: {N}

âœ… Safe to run: /clean-pipeline {feature-name}
```

---

## 6. Quality Rules

- **English only** â€" memory is for future AI agents, keep consistent
- **Concise but complete** â€" every section must have real content, not "N/A"
- **Reality-first** â€" if code contradicts guide, memory follows code
- **Gotchas section is mandatory** â€" at least 1 entry (if truly none: "No known edge cases â€" clean implementation")
- **Decisions section is mandatory** â€" successor devs need to know WHY, not just WHAT

