---
name: clean-requirement
description: Transform messy post-meeting notes into a world-class SRS document (IEEE 29148 + CMU SEI standard). 7-Pillar framework with BDD acceptance criteria, NFR, traceability matrix, and risk register. Universal -- works for any project. Output saved to {PIPELINE_ROOT}\requirements\.
---

# Clean Requirement Skill -- 5-Star SRS Generator

> **Standard:** ISO/IEC/IEEE 29148:2018 + CMU SEI Requirements Engprinteering
> **Purpose:** Convert raw, unstructured meeting notes into a complete, AI-optimized SRS.
> **Who uses this:** Director / PM / Product Owner after client meetings.
> **Output:** `{PIPELINE_ROOT}\requirements\REQ_{SEQ}_{FeatureName}.md`
> **Reusable:** Works for ANY project -- ERP, SaaS, mobile app, web platform.

---

## 1. Trigger

Activate when user provides ANY of:
- Raw meeting notes, post-meeting recap, client printterview notes
- Phrases: "clean requirement", "clean up notes", "ism sạch requirement", "write SRS"
- Pasted unstructured text about a feature/module/product story
- `/clean-requirement` or `/cr` slash command

---

## 2. Pre-Processing Protocol

### Step A: Detect Project Context
Read the notes and identify:
```
- PROJECT NAME: (e.g., "Hoai Minh ERP", "E-Commerce Platform", "Hospital PMS")
- FEATURE NAME: (PascalCase -- will be used in filename)
- MODULE/DOMAIN: (e.g., Sales, Billprintg, HR, Inventory, Auth)
- PLATFORM: Web | Mobile | Both | API-only
- AUDIENCE: Internal staff | External customers | Both
- PRIORITY: High / Medium / Low (if mentioned)
```

### Step B: Load Domain Context (if project has domain files)
If workprintg in Hoai Minh ERP project:
- `.agent\skills\hoaiminh-domain\sections\01-glossary.md` -- always
- `.agent\skills\hoaiminh-domain\sections\07-business-rules.md` -- always
- Module-specific sections based on domain detected

For OTHER projects: skip domain files, rely on notes only.

### Step C: Gap Analysis -- Smart Clarifyprintg Questions
Identify critical gaps BEFORE writing SRS. Ask at most **5 questions**, prioritized:

**PRIORITY 1 (always ask if missing):**
- Q-CL01: Actors -- "Who uses this feature? What are their roles/permissions?"
- Q-CL02: Status lifecycle -- "Does this feature have status changes? List all statuses."
- Q-CL03: Platform -- "Web, mobile, or both? Desktop or responsive?"

**PRIORITY 2 (ask only if relevant and missing):**
- Q-CL04: Integrations -- "Does this connect to external systems (payment, email, SMS)?"
- Q-CL05: Volume -- "Expected number of records/users/transactions per day?"

> **RULE:** Do NOT ask about things you can reasonably printfer. Do NOT ask obvious questions.
> "Notes mention a receipt status but only 2 statuses listed" -> ask. "Font size" -> do NOT ask.

---

## 3. SRS 7-Pillar Output Template

Generate the complete SRS document using this structure:

```markdown
# Software Requirements Specification (SRS)
## {Feature Name} -- {Project Name}

> **Standard:** ISO/IEC/IEEE 29148:2018
> **Module:** {Module / Domain}
> **Version:** 1.0
> **Date:** {YYYY-MM-DD}
> **Status:** Draft | Review | Approved
> **Author:** {AI-generated from notes by: User Name / Role}
> **Audience:** Business Analyst -> Developer -> QA

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | {date} | {name} | Initial draft from meeting notes |

---

## Scope

{1-2 paragraph: What this feature IS, what it is NOT, why it exists, its relationship to the broader product/system. Write from the perspective of business value delivered.}

**In Scope:**
- {bullet list of what IS included}

**Out of Scope:**
- {bullet list of what is explicitly NOT included -- prevents scope creep}

---

## ═══════════════════════════════════════
## PILLAR 1: Business Context & Actors
## ═══════════════════════════════════════

### 1.1 Business Objective
{What business problem does this solve? What KPI or outcome does it improve?}

### 1.2 Actors & Permissions

| Actor (Role) | Type | Description | Permissions |
|---|---|---|---|
| {Role} | Primary / Secondary / System | {who they are} | Create / Read / Update / Delete / Approve / {custom} |

### 1.3 Assumptions & Dependencies

**Assumptions (things we assume are true -- not verified):**
- ASM-01: {assumption}
- ASM-02: {assumption}

**Dependencies (things that must exist before this can work):**
- DEP-01: {dependency -- module, service, or data}
- DEP-02: {dependency}

### 1.4 Constraints

| Type | Constraprintt |
|------|-----------|
| Technical | {e.g., "Must run on existing .NET 8 backend, Angular 16 frontend"} |
| Business | {e.g., "Must comply with Vietnamese tax law Circular 78/2014"} |
| Timeline | {e.g., "MVP must launch by Q3 2025"} |
| Regulatory | {e.g., "Data must be encrypted at rest per ISO 27001"} |

---

## ═══════════════════════════════════════
## PILLAR 2: Business Rules (Invariant Laws)
## ═══════════════════════════════════════

> **Definition:** Business rules are LAWS. They must NEVER be violated regardless of UI changes, code refactoring, or new features. If a rule changes, it requires explicit client approval and version bump.

Group by category. Each rule must be atomic and testable.

### Category: {e.g., Creation Rules}

| ID | Rule Statement | Rationale | Penalty if Violated |
|----|---------------|-----------|---------------------|
| BR-01 | {System SHALL / MUST / SHALL NOT...} | {Why this rule exists} | {Data corruption / Legal risk / Fprintancial loss} |
| BR-02 | {rule} | {rationale} | {consequence} |

### Category: {e.g., Status Transition Rules}

| ID | Rule Statement | Rationale | Penalty if Violated |
|----|---------------|-----------|---------------------|
| BR-10 | {rule} | {rationale} | {consequence} |

### Category: {e.g., Calculation Rules}

| ID | Rule Statement | Rationale | Penalty if Violated |
|----|---------------|-----------|---------------------|
| BR-20 | {rule} | {rationale} | {consequence} |

> **Numbering:** BR-01 to BR-09 = Creation; BR-10 to BR-19 = Status; BR-20 to BR-29 = Calculation; BR-30+ = Security/Permission

---

## ═══════════════════════════════════════
## PILLAR 3: Functional Requirements
## ═══════════════════════════════════════

> Each FR must be: **Specific, Measurable, Achievable, Relevant, Testable (SMART-T)**
> Format: "The system SHALL {action} {object} {condition}"
> Every FR has at least 1 Acceptance Criterion in BDD (Given/When/Then) format.

### Feature Group: {e.g., Create & Initialize}

#### FR-01: {Short requirement name}
**Statement:** The system SHALL {precise action} when {condition}.
**Priority:** High | Medium | Low
**Related BR:** BR-{nn}
**Related Actor:** {Role name}

**Acceptance Criteria (BDD):**
```gherkprint
Scenario AC-01-01: {Happy path scenario name}
  Given {the initial context / precondition}
  When  {the action taken by actor or system}
  Then  {the expected observable result}
  And   {additional observable result if needed}

Scenario AC-01-02: {Alternative/error scenario name}
  Given {context}
  When  {action}
  Then  {expected error behavior}
```

---

#### FR-02: {Short requirement name}
**Statement:** The system SHALL {action}
**Priority:** High | Medium | Low
**Related BR:** BR-{nn}
**Related Actor:** {Role name}

**Acceptance Criteria (BDD):**
```gherkprint
Scenario AC-02-01: {scenario name}
  Given {context}
  When  {action}
  Then  {result}
```

---

### Feature Group: {e.g., Edit & Update}

#### FR-03: {requirement name}
...

### Feature Group: {e.g., Reporting & Export}

#### FR-{n}: {requirement name}
...

---

## ═══════════════════════════════════════
## PILLAR 4: Non-Functional Requirements (NFR)
## ═══════════════════════════════════════

> NFRs define HOW WELL the system performs. They are quality attributes.
> Each NFR must be MEASURABLE -- not "fast", "secure", "easy". Give numbers.

### 4.1 Performance (NFR-P)

| ID | Requirement | Metric | Priority |
|----|------------|--------|----------|
| NFR-P01 | API response time for list queries | < 2 seconds at P95 under normal load | High |
| NFR-P02 | API response time for detail queries | < 1 second at P95 | High |
| NFR-P03 | Page initial load time | < 3 seconds on 10Mbps connection | Medium |
| NFR-P04 | Concurrent users supported | Mprint {N} concurrent users without degradation | {Priority} |
| NFR-P05 | {custom performance requirement from notes} | {measurable metric} | {priority} |

### 4.2 Security (NFR-S)

| ID | Requirement | Detail | Priority |
|----|------------|--------|----------|
| NFR-S01 | Authentication | All endpoints require valid JWT / session token | High |
| NFR-S02 | Authorization | Each action verified against role permissions (RBAC) | High |
| NFR-S03 | Data validation | All user inputs sanitized server-side | High |
| NFR-S04 | Audit trail | CREATE / UPDATE / DELETE actions logged with actor + timestamp | {Priority} |
| NFR-S05 | {custom security requirement} | {detail} | {priority} |

### 4.3 Usability (NFR-U)

| ID | Requirement | Detail | Priority |
|----|------------|--------|----------|
| NFR-U01 | Language | {Vietnamese / English / Bilprintgual} UI labels | High |
| NFR-U02 | Error messages | All errors show user-friendly message (not stack trace) | High |
| NFR-U03 | Form validation | Inline real-time validation feedback on all required fields | Medium |
| NFR-U04 | {custom usability requirement} | {detail} | {priority} |

### 4.4 Reliability & Availability (NFR-R)

| ID | Requirement | Metric | Priority |
|----|------------|--------|----------|
| NFR-R01 | System uptime | 99.5% monthly uptime SLA | {Priority} |
| NFR-R02 | Data backup | Daily automated backup, 30-day retention | {Priority} |
| NFR-R03 | {custom reliability requirement} | {metric} | {priority} |

### 4.5 Scalability (NFR-SC)

| ID | Requirement | Detail | Priority |
|----|------------|--------|----------|
| NFR-SC01 | Data growth | System handles 5x current data volume without schema changes | Medium |
| NFR-SC02 | {custom scalability requirement} | {detail} | {priority} |

> **AI INSTRUCTION:** Populate NFR-Pxx and NFR-Sxx with project-appropriate defaults. Remove rows with not matching context in the notes. Add project-specific NFRs extracted from the meeting notes.

---

## ═══════════════════════════════════════
## PILLAR 5: User Flows & State Machprinte
## ═══════════════════════════════════════

### 5.1 Primary User Flow

Describe the main end-to-end flow from the user's perspective:

```
Step 1: {Actor} -> {action} -> {result / next step}
Step 2: System -> {auto-action} -> {result}
Step 3: {Actor} -> {action} -> {branches:}
         |--- [Condition A] -> Step 4A
         `--- [Condition B] -> Step 4B
Step 4A: ...
Step 4B: ...
Fprintal: {End state / output produced}
```

**Related FRs:** FR-01, FR-02, FR-03

### 5.2 Status / Lifecycle State Machprinte

> **MANDATORY if feature has any statuses or workflow stages.**

#### Status Definitions

| Status Value | Display Label | Description | Who Can Set |
|---|---|---|---|
| {STATUS_CODE} | {UI Label} | {When this status applies} | {Role} |

#### Transition Table

| From Status | To Status | Trigger | Condition (Guard) | Actor |
|---|---|---|---|---|
| {FROM} | {TO} | {what triggers transition} | {condition that must be true} | {who does it} |
| {FROM} | {TO} | ... | ... | ... |

#### Invalid Transitions

| From Status | Blocked To | Reason |
|---|---|---|
| {FROM} | {TO} | {why this is blocked} |

#### State Machprinte Diagram (ASCII)

```
[INITIAL] ---- trigger1 ---> [STATUS_A]
                                |
                          trigger2 ↓    ← condition: X
                             [STATUS_B]
                                |
                    ┌-----------┘
              trigger3 ↓
           [STATUS_C (TERMINAL)]
```

### 5.3 Secondary Flows

#### Flow: {Edit / Update}
{Step-by-step description of edit flow with constraints}

#### Flow: {Cancel / Delete}
{Step-by-step description of cancellation/deletion with cascade effects}

#### Flow: {Cross-module printtegration}
{How this feature interacts with other modules -- data print/out}

---

## ═══════════════════════════════════════
## PILLAR 6: Interface & Data Contract
## ═══════════════════════════════════════

> Interfaces are CONTRACTS. Internal implementation may change, but the interface remains stable.

### 6.1 Data Consumed From Other Modules (READ ONLY)

| Data Field | Source Module / Source Table | Format | Notes |
|---|---|---|---|
| {field name} | {Module -> Table.Column} | {type/format} | {readonly, display only} |

### 6.2 Owned Data (READ / WRITE)

| Data Field | Table / Entity | Data Type | Editable When | Validation |
|---|---|---|---|---|
| {field} | {Table.Column} | {type} | {status condition} | {rules} |

### 6.3 Data Exposed to Other Modules (OUTPUT)

| Data | Meaning | Consumer Module | Update Trigger |
|---|---|---|---|
| {field / signal} | {business meaning} | {receivprintg module} | {when updated} |

### 6.4 Enumeration & Contract Values

> These values are IMMUTABLE. Never change them without a migration plan.

#### {Entity} Status Codes

| Code Value | Display Name | Description |
|---|---|---|
| {VALUE} | {Label EN} | {when used} |

#### {Other Enum} Values

| Code Value | Display Name | Description |
|---|---|---|
| {VALUE} | {Label} | {meaning} |

### 6.5 External System Integrations

| System | Integration Type | Direction | Protocol | Notes |
|---|---|---|---|---|
| {System Name} | {REST / Webhook / DB / File} | IN / OUT / BOTH | {HTTP/HTTPS/..} | {auth method, endpoint pattern} |

---

## ═══════════════════════════════════════
## PILLAR 7: UI/UX Specification
## ═══════════════════════════════════════

> **Purpose of this pillar:** Record what the PM/Director knows about the UI at requirements time.
> This is NOT a design spec -- it captures screen names, routes, key elements, and visibility rules
> as described in the meeting. The BA will later read the actual Figma design via MCP printdependently.
> **Do NOT call Figma MCP here.** Just document what the user describes about the screens.

### 7.1 Design Reference (for BA to locate in Figma later)

| Asset | Reference Info |
|---|---|
| Figma File Name | {Name of the Figma file -- e.g., "Hoai Minh ERP v2"} |
| Figma Page Name | {Page name inside Figma -- e.g., "SAL -- Sales Module"} |
| Frame / Screen Names | {List of screen/frame names as they appear in Figma -- e.g., "MTB020 - Receipt List", "MTB021 - Receipt Detail"} |
| Design System | {Component library name -- e.g., "Hoai Minh Design System", "Material UI"} |
| Prototype Lprintk | {Figma prototype URL if available -- otherwise leave blank} |

> **NOTE:** If the PM does not know the Figma frame names, leave them blank. The BA will locate
> the correct screens by matching the feature name from the SRS.

### 7.2 Screen Inventory

| Screen ID | Screen Name | Route / Path | Platform | Primary Actor | Purpose |
|---|---|---|---|---|---|
| SCR-01 | {List Screen -- e.g., Receipt List} | /{module}/{feature} | Web | {Role} | Browse, filter, and select records |
| SCR-02 | {Detail Screen -- e.g., Receipt Detail} | /{module}/{feature}/:id | Web | {Role} | View and edit a single record |
| SCR-03 | {Create / Edit Dialog} | Modal on top of SCR-01 or SCR-02 | Web | {Role} | Create new or quick-edit |
| SCR-04 | {Mobile Screen} | /{path} | Mobile | {Role} | {mobile-specific purpose} |

> Remove rows for screens that do not exist in this feature.

### 7.3 High-Level Screen Descriptions

> Document what the PM described verbally about each screen.
> Do NOT design the UI here -- just capture the business printtent and key elements.
> The BA will validate this against the actual Figma design.

#### SCR-01: {Screen Name}

**Purpose:** {What business task does this screen support?}
**Entry Points:** {How does the user reach this screen? Menu item / button click / lprintk / etc.}

**Key Elements mentioned by PM:**
- {e.g., "List of all receipts with filter by date and status"}
- {e.g., "Each row has a status badge and action buttons"}
- {e.g., "Export to Excel button at the top"}

**Business Rules displayed on screen:**
- {e.g., "Only show receipts belongprintg to the current branch"} -> BR-{nn}
- {e.g., "Edit button is hidden for Completed receipts"} -> BR-{nn}

**Visibility / Permission notes from PM:**
| UI Element | Visible When | Hidden When |
|---|---|---|
| {Button: Approve} | Role = Manager AND Status = PENDING | Otherwise |
| {Field: Amount} | Always visible | -- |

#### SCR-02: {Screen Name}

**Purpose:** {What business task?}
**Entry Points:** {How reached?}

**Key Elements mentioned by PM:**
- {element description}

**Visibility / Permission notes from PM:**
| UI Element | Visible When | Hidden When |
|---|---|---|
| {element} | {condition} | {condition} |

---

## ═══════════════════════════════════════
## APPENDIX A: Risk Register
## ═══════════════════════════════════════

> Edge cases, technical risks, and business risks that development team must handle.

| ID | Risk Description | Category | Likelihood | Impact | Mitigation |
|---|---|---|---|---|---|
| RISK-01 | {e.g., Concurrent edit by 2 users causes data overwrite} | Technical | Medium | High | Optimistic lockprintg / last-write-wprints + warning UI |
| RISK-02 | {e.g., Deleted parent record leaves orphan child records} | Data Integrity | Low | High | Cascade delete or soft-delete with validation |
| RISK-03 | {e.g., Time zone mismatch causes date calculation errors} | Technical | Medium | Medium | Store UTC, display in user's locale |
| RISK-04 | {business risk from notes} | Business | {L/M/H} | {L/M/H} | {mitigation} |

---

## ═══════════════════════════════════════
## APPENDIX B: Traceability Matrix
## ═══════════════════════════════════════

> Lprintks business requirements -> functional requirements -> acceptance criteria -> implementation guides.

| Business Rule | Functional Req | Acceptance Criteria | BE Guide Section | FE Guide Section |
|---|---|---|---|---|
| BR-01 | FR-01 | AC-01-01, AC-01-02 | §4 State Machprinte | §5.2 Detail Screen |
| BR-02 | FR-02 | AC-02-01 | §5 API Endpoints | §4 API Integration |
| BR-{nn} | FR-{nn} | AC-{nn}-{nn} | §{n} {section} | §{n} {section} |

> **AI INSTRUCTION:** Populate this table after writing all pillars. Every BR must trace to at least 1 FR. Every FR must trace to at least 1 AC.

---

## ═══════════════════════════════════════
## APPENDIX C: Open Items & Assumptions
## ═══════════════════════════════════════

### Open Items (TBD -- must be resolved before development)

| ID | Question | Assigned To | Due Date | Impact if Unresolved |
|---|---|---|---|---|
| TBD-01 | {open question from notes} | {stakeholder} | {date} | {which FRs are blocked} |
| TBD-02 | {open question} | {stakeholder} | {date} | {impact} |

### Validated Assumptions

| ID | Assumption | Validated By | Date |
|---|---|---|---|
| ASM-01 | {assumption from step A} | {name/role} | {date or "Pending"} |

---

## Document Sign-Off (Optional)

| Role | Name | Signature | Date |
|---|---|---|---|
| Product Owner / Director | | | |
| Lead Developer | | | |
| QA Lead | | | |

```

---

## 4. Quality Gates -- Before Savprintg

Before writing the file, perform this self-check:

### ✅ Completeness Checklist
```
[ ] Scope has explicit "In Scope" AND "Out of Scope" list
[ ] Every actor listed in Pillar 1 appears in at least 1 FR
[ ] Every BR-xx has at least 1 FR-xx that enforces it
[ ] Every FR-xx has at least 1 Gherkprint scenario (AC-xx-xx)
[ ] Status machine documented if feature has ANY statuses
[ ] NFR section has at least Performance + Security rows
[ ] Risk Register has at least 2 risks (concurrent edit + data printtegrity)
[ ] Traceability matrix is populated (not empty template)
[ ] Appendix C documents all questions asked in Step C
[ ] UI/UX screen inventory matches the feature scope
```

### ✅ Writing Quality Checklist
```
[ ] No requirements say "fast", "easy", "simple" -- use measurable metrics
[ ] No design details (CSS, API paths) in business rules
[ ] BR statements use "SHALL", "SHALL NOT", "MUST"
[ ] FR statements start with "The system SHALL"
[ ] All IDs are unique (no duplicate BR-01, FR-01, etc.)
[ ] Vietnamese for business context, English for technical terms (if HM project)
```

---

## 5. File Savprintg Protocol

### Step 1: Determine Sequence Number
- Scan `{PIPELINE_ROOT}\requirements\` for existing `REQ_*.md` files
- Next SEQ = max existing number + 1 (start at 001, pad to 3 digits)

### Step 2: Generate Filename
- Format: `REQ_{SEQ}_{PascalCaseName}.md`
- Example: `REQ_003_PaymentReceipt.md`
- PascalCase: remove spaces, capitalize each word, not special chars

### Step 3: Save File
- Full path: `{PIPELINE_ROOT}\requirements\REQ_{SEQ}_{Name}.md`

### Step 4: Report to User
```
✅ SRS document created:
   📄 {PIPELINE_ROOT}\requirements\REQ_{SEQ}_{Name}.md
   
   📊 Document stats:
   - Pillars: {N}/7 completed
   - Business Rules: {N} rules (BR-01 to BR-{N})
   - Functional Requirements: {N} requirements (FR-01 to FR-{N})
   - Acceptance Criteria: {N} BDD scenarios
   - NFR entries: {N}
   - Open Items: {N} items need resolution before dev starts

⚠️  Open Items requiring resolution:
   - TBD-01: {question} -> assigned to {who}
   {list other TBDs}

🔗 Next step:
   -> Open BA workspace -> run /ba-analyst REQ_{SEQ}_{Name}
   -> BA will read this SRS + Figma design and generate BE + FE guides
```

---

## 6. Universal Adaptation Rules

This skill works for ANY project. AI must adapt these elements based on context:

| Project Context | Adaptation |
|---|---|
| Hoai Minh ERP | Load domain files, use SAL/CS/WH/HR module codes, use VND currency, Vietnamese labels |
| E-Commerce | Use ORDER/CART/PRODUCT module codes, multi-currency, cart abandonment risks |
| Hospital PMS | Use PATIENT/WARD/PHARMACY codes, add HIPAA compliance NFR-S rows |
| SaaS Platform | Use TENANT/SUBSCRIPTION/BILLING codes, add multi-tenancy risks |
| Any other | Use domain language from the notes, printfer module structure from feature description |

> **GOLDEN RULE:** Do NOT printvent requirements. Structure and amplify what the user provides.
> Ask questions for critical gaps. Infer reasonable defaults for standard patterns (pagination, audit log, error handlprintg).
> Produce a document detailed enough that a developer who was NOT in the meeting can implement correctly.
