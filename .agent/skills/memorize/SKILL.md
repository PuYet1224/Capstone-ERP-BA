---
name: memorize
description: Đọc toàn bộ SRS, code đã implement (BE + FE), và guides → chưng cất thành 1 file memory English vĩnh viễn trong BA workspace. Chạy TRƯỚC /clean-pipeline để đảm bảo AI nhớ mọi thứ mãi mãi.
---

# Memorize Skill — Knowledge Distillation

> **Role:** You are a Knowledge Distiller.  
> **Mission:** Read everything that was built → distill into a permanent, curated English memory file.  
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
C:\ai-pipeline\requirements\REQ_{SEQ}_{Feature}.md
```
→ Extract: business context, actors, original business rules, open questions resolved

### Source 2: Implementation Guides (planned state)
```
C:\ai-pipeline\guides\BE_{SEQ}_{Feature}.md
C:\ai-pipeline\guides\FE_{SEQ}_{Feature}.md
```
→ Extract: planned API contracts, DTOs, state machine

### Source 3: Actual BE Code (final state — truth)
```
modules/MTB/Features/M.{Module}/F.{Feature}/*.cs
modules/MTB/Features/M.{Module}/F.{Feature}/Constants/*.cs
```
> Read from: C:\Users\lala0\Capstone-ERP-API-VSA\  
→ Extract: actual handlers, real status values, real field names, real validation logic

### Source 4: Actual FE Code (final state)
```
src/app/modules/{feature}/*.ts
src/app/modules/{feature}/*.html
```
> Read from: C:\Users\lala0\Capstone-ERP-WEB\  
→ Extract: actual component structure, actual API calls used, actual UI states

---

## 3. Distillation Rules

> Read sources → synthesize → DO NOT just copy-paste.

**Priority order when plan vs code differ:**
```
Actual Code > Implementation Guide > SRS
```

The code is what's running in production. If guide said X but code does Y → memory records Y, notes the deviation.

**What to include:**
- ✅ Final business rules (as implemented)
- ✅ Final API contracts (actual routes, actual payloads)
- ✅ Final state machine (from code, not guide)
- ✅ Final DB tables and relationships used
- ✅ Decisions made during implementation (why, not just what)
- ✅ Bugs found during review/enhance cycles → how they were fixed
- ✅ Edge cases discovered during testing
- ✅ Cross-module dependencies confirmed

**What to exclude:**
- ❌ Open questions that were resolved (merge the answer in)
- ❌ Drafts and abandoned approaches
- ❌ Raw file contents (synthesize, don't dump)

---

## 4. Memory File Template

**Output path:** `C:\Users\lala0\Capstone-ERP-BA\BA-Workspace\.agent\skills\hoaiminh-domain\memory\{Feature}.md`

> Overwrite if exists. This is the final, authoritative version.

```markdown
# Feature Memory: {Feature Display Name}

> **Module:** {SAL | CS | WH | HR | SYS}  
> **Memorized:** {YYYY-MM-DD}  
> **Source files:** REQ_{SEQ} + BE_{SEQ} + FE_{SEQ} + actual code  
> **Status:** Production ✅

---

## 1. Business Context

{What this feature does, why it exists, who uses it. 3-5 sentences max.}

**Actors:**
| Role | Can Do |
|------|--------|
| {role} | {actions} |

---

## 2. Database

**Primary table:** `{tbl_name}` — {what it stores}

**Schema (key columns only):**
| Column | Type | Description |
|--------|------|-------------|
| {col} | {type} | {meaning} |

**Related tables:**
- `{tbl_name}` — {relationship + why it's used}

---

## 3. State Machine (as implemented)

| Status | Code | Meaning |
|--------|------|---------|
| {StatusName} | {N} | {business meaning} |

**Transitions:**
| From | To | Condition |
|------|----|-----------|
| {status} | {status} | {when allowed} |
| {status} | {status} | ❌ Final state — no outgoing |

---

## 4. API Contracts (actual, as implemented)

### GET {route}
- **Auth:** RequireAuthorization
- **HEAD filter:** Yes — `x.Head == currentUser.HeadCode`
- **Returns:** `{FeatureDto}[]` with pagination
- **Key fields:** {list key fields returned}

### POST {route} — Create/Edit
- **Payload:** `{command fields}`
- **Validation:** {key rules}
- **Side effects:** {what else changes}

### POST {route}/update-status
- **Payload:** `{ code: int, status: int }`
- **Transitions:** {valid ones only}
- **Transaction:** Yes — ExecutionStrategy

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
├── {feature}-list.component.ts   ← Grid view, route: /{module}/{feature}
├── {feature}-detail.component.ts ← Form view, route: /{module}/{feature}/:code
└── {feature}.service.ts          ← API calls
```

**Key UI behaviors:**
- {describe conditional display, disabled states, badge colors}

---

## 7. Key Decisions & Rationale

> WHY things were done this way. Successor devs need this.

- **Decision:** {what} → **Because:** {why, especially non-obvious reasons}
- **Decision:** {what} → **Because:** {why}

---

## 8. Bugs Fixed (from /review + /enhance cycles)

| Bug | Root Cause | Fix Applied |
|-----|-----------|-------------|
| {description} | {why it happened} | {what was changed} |

---

## 9. Cross-Module Dependencies

**This feature reads from:**
- `{Module}` → `{what data, which table}`

**This feature's output is used by:**
- `{Module}` → `{how/when}`

---

## 10. Edge Cases & Gotchas

> Things that will bite the next dev if they don't know.

- ⚠️ **{gotcha}:** {explanation + how to handle}
- ⚠️ **{gotcha}:** {explanation}

---

## 11. Revision History

| Date | Change | Reason |
|------|--------|--------|
| {date} | Initial implementation | REQ_{SEQ} |
| {date} | {what changed} | {why — bug fix, requirement change, etc.} |
```

---

## 5. Output Report

After saving memory file:

```
✅ Memorized: {Feature}

📝 Memory saved: .../memory/{Feature}.md

📊 Distilled from:
   📄 REQ_{SEQ}_{Feature}.md
   📄 BE_{SEQ}_{Feature}.md  
   📄 FE_{SEQ}_{Feature}.md
   💻 {N} .cs handler files
   🎨 {N} Angular component files

⚡ Deviations from plan (code differs from guide):
   - {e.g., "Status 'Suspended' removed — not implemented in code"}
   - {e.g., "Added optimistic lock check not in original guide"}

🧠 Memory covers:
   States: {N} | Rules: {N} | APIs: {N} | Gotchas: {N}

✅ Safe to run: /clean-pipeline {feature-name}
```

---

## 6. Quality Rules

- **English only** — memory is for future AI agents, keep consistent
- **Concise but complete** — every section must have real content, not "N/A"
- **Reality-first** — if code contradicts guide, memory follows code
- **Gotchas section is mandatory** — at least 1 entry (if truly none: "No known edge cases — clean implementation")
- **Decisions section is mandatory** — successor devs need to know WHY, not just WHAT
