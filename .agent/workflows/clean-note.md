---
workflow: clean-note
role: BA
version: 1.0
trigger: "/clean-note [feature-name]"
---

# /clean-note [feature-name]

## Purpose

Convert messy meeting notes into a structured 9-section English template
that /clean-requirement can process into an SRS.

## Pre-conditions

- [ ] User has raw meeting notes (file or pasted text)

---

## Steps

### Step 1 -- Find Raw Notes
- Input: Feature name or notes text
- Action: Scan `{PROJECT_PIPELINE}\requirements\` for files matching the feature name.
  If not found, ask user to paste notes directly.
- Gate: Notes received -> proceed.

### Step 2 -- Load Glossary
- Action: Load `domain-knowledge` skill. Read `01-glossary.md`.
- Gate: Glossary loaded (ensures correct terminology in output).

### Step 3 -- Detect Platform
- Action: Scan `{PROJECT_PIPELINE}\designs\{feature-name}\` for actual IMAGE FILES (png/jpg).
  - `mobile/` has images AND (`web/` or `desktop/`) has images -> Both
  - `mobile/` has images, others empty -> Mobile
  - (`web/` or `desktop/`) has images, mobile empty -> Web
  - Empty folders do NOT count. `desktop/` = Web equivalent.
  - No designs folder -> Mobile (project default)
  - Keyword fallback: `phieu-thu` = receipt, `hoa-don` = invoice, `ban-hang` = sale
- Gate: Platform resolved to Mobile/Web/Both. NEVER leave as [?].

### Step 4 -- Classify and Organize
- Action: Load `note-to-template` skill. Classify each idea into 9 sections.
  Every output line MUST be English. Vietnamese only in parentheses as labels.
- Gate: All 9 sections present. No Vietnamese outside parentheses.

### Step 5 -- Save Output
- Action: Save to `{PROJECT_PIPELINE}\requirements\MEETING_{feature-name}.md`
- Gate: File saved successfully.

### Step 6 -- List Clarification Questions
- Output: Questions in English only. Present to user for resolution before /clean-requirement.

### Step 7 -- Report

```
Template Created: MEETING_{feature-name}.md
  Full Path: {PROJECT_PIPELINE}\requirements\MEETING_{feature-name}.md

  >> Next command (copy this):
  /clean-requirement {PROJECT_PIPELINE}\requirements\MEETING_{feature-name}.md
```
