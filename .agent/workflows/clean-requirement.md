---
workflow: clean-requirement
role: BA
version: 1.0
trigger: "/clean-requirement [feature-name]"
---

# /clean-requirement [feature-name]

## Purpose

Transform meeting notes or MEETING_TEMPLATE file into a structured 7-Pillar SRS.
Standard: IEEE 29148 adapted, EARS syntax for requirements, Gherkin BDD for acceptance criteria.

## Pre-conditions

- [ ] MEETING_*.md exists (from /clean-note) OR user has raw notes to provide

---

## Steps

### Step 1 -- Read Input
- Input: Meeting notes (file path, inline text, or pasted content)
- Action:
  - File path provided -> read file
  - Inline text -> use directly
  - Detect project: look for module codes (SAL/CS/WH/HR/SYS/MTB/PART), "Hoai Minh", "Honda", "HEAD"
  - If Hoai Minh detected -> load domain context:
    - Always: `domain/01-glossary.md` + `domain/06-database-schema.md` + `domain/07-business-rules.md`
    - SAL/MTB: also `domain/03-sales-flow.md` + `domain/08-approval-flows.md`
    - CS: also `domain/04-service-flow.md`
    - WH: also `domain/05-warehouse-flow.md`
- Gate: Input received and domain loaded -> proceed.

### Step 2 -- Extract and Normalize
- Action: From notes extract and convert:
  - Feature name + module code -> derive FeatureKey, PrimaryTable
  - User stories -> FR-xx functional requirements
  - Business rules -> BR-xx with EARS syntax
  - Status flow -> state machine table
  - Data fields -> data dictionary
  - Screens -> screen inventory
  - Integrations -> dependency list
  - Undecided items -> TBD-xx in Appendix C

  EARS Syntax reference:
  - Ubiquitous: "The [system] shall [action]"
  - Event-driven: "When [trigger], the [system] shall [action]"
  - State-driven: "While [state], the [system] shall [action]"
  - Unwanted: "If [condition], then the [system] shall [action]"

  Gherkin BDD reference:
  ```
  AC-01-01: [scenario title]
    Given [precondition]
    When [action]
    Then [expected result]
  ```
- Gate: All 7 pillars have at least a draft value. Pure unknowns -> TBD-xx.

### Step 3 -- Generate SRS Document
- Input: Normalized content + SRS template from `.agent/refs/srs-template.md`
- Action: Fill ALL 7 pillars + appendices.
  - Every field must have a concrete value (no unfilled placeholders)
  - Genuine unknowns -> write `TBD-xx: [specific question]`
  - Vietnamese display labels are OK (field names, button labels)
  - ALL other content in English
  - Number all items: BR-01, FR-01, AC-01-01, NFR-P01, SCR-01, TBD-01
- Gate: All 7 pillars filled. Zero unfilled placeholders.

### Step 4 -- Determine SEQ Number
- Action: Scan `{PROJECT_PIPELINE}\requirements\` for existing `REQ_*.md` files.
  - SEQ = highest existing number + 1 (zero-padded to 3 digits)
  - No files exist -> SEQ = 001
- Gate: SEQ number determined.

### Step 5 -- Save and Report
- Action: Save to `{PROJECT_PIPELINE}\requirements\REQ_{SEQ}_{FeatureKey}.md`
- Gate: File saved successfully.
- Output report (must include full path):

```
SRS Created: REQ_{SEQ}_{FeatureKey}.md
  Full Path: {PROJECT_PIPELINE}\requirements\REQ_{SEQ}_{FeatureKey}.md
  Module: {module} | Platform: {platform} | Primary Table: {table}
  Requirements: {N} FRs, {N} BRs, {N} NFRs
  Acceptance Criteria: {N} scenarios
  TBD Items: {N} -- resolve before /ba-analyst

  >> Next command (copy this):
  /ba-analyst {PROJECT_PIPELINE}\requirements\REQ_{SEQ}_{FeatureKey}.md
```

---

## Gotchas

- Notes mention a feature with existing memory file -> load it for context
- SRS contradicts domain knowledge -> ask user (notes are fresher but could be wrong)
- Always include Pillar 7 (UI/UX) even if no designs yet
- Platform: scan `{PROJECT_PIPELINE}\designs\{feature}\` for subfolders with actual images.
  Only `mobile/` images = Mobile. Only `web/` images = Web. Both = Both. Nothing = ask user.
