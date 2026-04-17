---
name: clean-requirement
description: Transform messy meeting notes into structured Business Requirement Specification (BRS). Used by the director/PM after client meetings. Output is saved to the shared pipeline folder for BA to pick up.
---

# Clean Requirement Skill

> **Purpose:** Convert raw, unstructured meeting notes into a clean, standardized BRS document.  
> **Who uses this:** The Director/PM (you — the human) after a client meeting.  
> **Output:** A structured `.md` file saved to `C:\ai-pipeline\requirements\REQ_{SEQ}_{Name}.md`

---

## 1. Trigger

When user provides raw notes with phrases like:
- "clean requirement", "requirements cleanup", "clean up notes"
- "just finished a meeting", "meeting notes"
- Or pastes unstructured text about a feature

## 2. Input Processing

### Step 1: Read Raw Notes
- Accept ANY format: bullet points, scattered sentences, diagrams in text, mixed Vietnamese/English
- Identify the feature name and which module it belongs to (SAL, CS, WH, HR, SYS)

### Step 2: Read Domain Context
Load relevant domain files from `.agent\skills\hoaiminh-domain\sections\`:
- `01-glossary.md` — always read for terminology
- `07-business-rules.md` — always read for existing rules
- Module-specific: SAL→`03-sales-flow.md`, Service→`04-service-flow.md`, WH→`05-warehouse-flow.md`
- `06-database-schema.md` — if notes mention tables or data fields

### Step 3: Ask Clarifying Questions (MAX 3)
Only ask if truly ambiguous. Do NOT ask obvious questions. Examples:
- "Notes mention 5 statuses but only list 3 — what are the other 2?"
- "Is this feature for desktop web, mobile, or both?"

## 3. Output Template — 3 Pillars SRS

Generate a SRS file built around **3 pillars**: Business Rules, User Flow, Interface Definition.

```markdown
# Software Requirement Specification (SRS) — {Feature Name}

> **Project:** Hoai Minh Honda ERP  
> **Module:** {Module Name}  
> **Version:** 1.0  
> **Date:** {date}  
> **Audience:** Business Analyst (BA)  

---

## Background
{What this feature is, why it exists, relationship to other modules}

**Actors:**
| Role | Permissions |
|------|-------------|
| {Role} | {Permissions} |

---

## Pillar 1: Business Rules (Invariant Rules)

The "laws" of the system. Regardless of code or UI changes, these rules MUST NEVER be violated.

| ID | Rule | Explanation |
|----|------|-------------|
| BR-01 | {rule} | {why} |
| BR-02 | {rule} | {why} |

Group rules by category if needed (creation rules, status rules, calculation rules).

---

## Pillar 2: User Flow (Data Flow)

Where data comes from, which modules it passes through, where it ends up.

### Flow 1: {Main flow name}
{Step-by-step flow with arrows showing data journey}

### Flow 2: {State machine / lifecycle}
{All states + transition diagram + conditions}

### Flow 3: {Secondary flows}
{Edit flows, cancel flows, cross-module flows}

---

## Pillar 3: Interface Definition (Inputs / Outputs)

Inputs and outputs of each module must be clearly defined. Internal logic may change, but the interface is IMMUTABLE.

### Interface 1: Data read from other modules (READ ONLY)
| Data | Source | Notes |
|------|--------|-------|

### Interface 2: Own data (READ/WRITE)
| Data | Table/Entity | Editable when |
|------|-------------|---------------|

### Interface 3: Output for other modules
| Data | Meaning | Receiving module |
|------|---------|------------------|

### Interface 4+: Contract Values (Status codes, Payment types, etc.)
| Value | Meaning | Notes |
|-------|---------|-------|

---

## Acceptance Criteria
{Numbered list of testable acceptance criteria}
```

## 4. Saving

### Step 1: Determine Sequence Number
- Scan `C:\ai-pipeline\requirements\` for existing `REQ_*.md` files
- Next sequence = max existing + 1 (start at 001)

### Step 2: Save File
- Path: `C:\ai-pipeline\requirements\REQ_{SEQ}_{PascalCaseName}.md`
- Example: `REQ_002_Invoice.md`

### Step 3: Report
```
✅ Requirement file created:
   📄 C:\ai-pipeline\requirements\REQ_{SEQ}_{Name}.md
   
Next step: Open BA workspace → BA will automatically find and analyze this file
```

## 5. Rules

1. **Output is PURE business requirements** — no API schemas, no CSS, no database column types
2. **Vietnamese for business context, English for technical terms**
3. **State machines are MANDATORY** if the feature has any status/workflow
4. **Business rules must be numbered** (BR-01, BR-02) for traceability
5. **Do NOT invent requirements** — only structure what the user provided. If info is missing, ask.
