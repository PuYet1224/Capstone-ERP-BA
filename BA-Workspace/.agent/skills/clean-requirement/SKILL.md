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
- "clean requirement", "làm requirement", "dọn note"
- "vừa họp xong", "note cuộc họp"
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

> **Dự án:** Hoài Minh Honda ERP  
> **Module:** {Module Name}  
> **Version:** 1.0  
> **Ngày tạo:** {date}  
> **Đối tượng đọc:** Business Analyst (BA)  

---

## Bối cảnh
{What this feature is, why it exists, relationship to other modules}

**Actors:**
| Vai trò | Quyền hạn |
|---------|----------|
| {Role} | {Permissions} |

---

## Trụ cột 1: Business Rules (Quy tắc bất biến)

Những "luật chơi" của hệ thống. Dù code hay UI thay đổi, rules này KHÔNG BAO GIỜ được vi phạm.

| ID | Quy tắc | Giải thích |
|----|---------|-----------|
| BR-01 | {rule} | {why} |
| BR-02 | {rule} | {why} |

Group rules by category if needed (creation rules, status rules, calculation rules).

---

## Trụ cột 2: User Flow (Luồng dữ liệu)

Dữ liệu đi từ đâu, qua module nào, kết thúc ở đâu.

### Flow 1: {Main flow name}
{Step-by-step flow with arrows showing data journey}

### Flow 2: {State machine / lifecycle}
{All states + transition diagram + conditions}

### Flow 3: {Secondary flows}
{Edit flows, cancel flows, cross-module flows}

---

## Trụ cột 3: Interface Definition (Đầu vào / Đầu ra)

Đầu vào và đầu ra của mỗi module phải rõ ràng. Logic bên trong có thể thay đổi, nhưng interface là BẤT BIẾN.

### Interface 1: Dữ liệu đọc từ module khác (READ ONLY)
| Dữ liệu | Nguồn | Ghi chú |
|----------|-------|---------|

### Interface 2: Dữ liệu riêng (READ/WRITE)
| Dữ liệu | Bảng/Entity | Editable khi |
|----------|-------------|-------------|

### Interface 3: Output cho module khác
| Dữ liệu | Nghĩa | Module nhận |
|----------|-------|------------|

### Interface 4+: Contract Values (Status codes, Payment types, etc.)
| Value | Nghĩa | Ghi chú |
|-------|--------|---------|

---

## Tiêu chí Nghiệm thu
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
   
Next step: Open BA workspace → BA sẽ tự tìm và phân tích file này
```

## 5. Rules

1. **Output is PURE business requirements** — no API schemas, no CSS, no database column types
2. **Vietnamese for business context, English for technical terms**
3. **State machines are MANDATORY** if the feature has any status/workflow
4. **Business rules must be numbered** (BR-01, BR-02) for traceability
5. **Do NOT invent requirements** — only structure what the user provided. If info is missing, ask.
