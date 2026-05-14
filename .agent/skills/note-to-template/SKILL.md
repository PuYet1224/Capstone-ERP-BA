---
skill: note-to-template
role: BA
version: 1.0
trigger: "/clean-note, 'format meeting notes', 'organize notes'"
---

# Note-to-Template Skill

## Purpose

Convert raw meeting notes (Vietnamese or mixed) into a structured English 9-section template
that /clean-requirement can turn into a proper SRS.

## Hard Rules

- RULE-NT-01: Output file content MUST be 100% English. Translate ALL Vietnamese.
- RULE-NT-02: Vietnamese terms go ONLY in parentheses as labels: "Full Payment (Tra het)"
- RULE-NT-03: NEVER output [?] for Platform -- always resolve to Mobile/Web/Both.
- RULE-NT-04: [?] questions in the OUTPUT FILE must be in English. When presenting questions to the user in the response, follow RULE-LANG-01 (Vietnamese with diacritics).

## Steps

1. **Read raw notes**
   - Input: File from `{PROJECT_PIPELINE}\requirements\` or pasted text from user
   - Gate: Notes received -> proceed. Nothing received -> ask user to provide notes.

2. **Load glossary**
   - Action: Load `domain-knowledge` skill, read `01-glossary.md`
   - Gate: Glossary loaded -> proceed (ensures correct term translation).

3. **Detect Platform**
   - Action: Infer from the notes text only. Do NOT scan any folder or read any file.
     - Notes mention "mobile", "điện thoại", "app" -> Mobile
     - Notes mention "web", "desktop", "máy tính" -> Web
     - Notes mention both -> Both
     - Cannot infer from notes -> **Mobile (project default for this project)**
   - Gate: Platform resolved. No file/folder access in this step.

4. **Classify ideas into 9 sections**

   | Section | Header | Detect When Note Contains |
   |---|---|---|
   | 1 | CONTEXT | "need to...", "problem is...", "can...", "van de..." |
   | 2 | DECISIONS | "agreed", "ok", "dong y", "thong nhat" |
   | 3 | USER STORIES | "staff...", "nhan vien...", "muon..." |
   | 4 | SCREENS | "list", "detail", "form", "danh sach", "chi tiet" |
   | 5 | BUSINESS RULES | "must not", "bat buoc", "phai", "neu...thi..." |
   | 6 | STATUS FLOW | "new", "approved", "cho xu ly", "dang xu ly" |
   | 7 | DATA FIELDS | field names, "bat buoc", "tuy chon", "tu dong" |
   | 8 | INTEGRATION | DB table names, "lien ket", "doc tu", "ghi vao" |
   | 9 | ADDITIONAL NOTES | "later", "sau nay", "chua can", open ideas |

5. **Write output file**
   - All content in English. Vietnamese only in parentheses.
   - Save to: `{PROJECT_PIPELINE}\requirements\MEETING_{FeatureName}.md`
   - Gate: File saved successfully.

6. **Report clarification questions**
   - List any [?] items in English so user can resolve before running /clean-requirement.

## Output Format

```markdown
# Meeting Notes: {Feature English Name}

> Date: {date} | Participants: {who} | Duration: {time}
> Module: {SAL/CS/WH/HR}
> Platform: {Mobile/Web/Both}

---

## 1. CONTEXT (What problem are we solving?)
- {English content}

## 2. DECISIONS (What was agreed?)
- [x] {English decision. Vietnamese label in parentheses only.}

## 3. USER STORIES (Who does what?)
- As a {role}, I want to {action} so that {goal}.

## 4. SCREENS
- Screen 1: {English name} -- {English description}

## 5. BUSINESS RULES
- {English rule}

## 6. STATUS FLOW
- {English status} ({Vietnamese label}) -> {English status} ({Vietnamese label})

## 7. DATA FIELDS
- Required: {English field names}
- Optional: {English field names}

## 8. INTEGRATION (Which modules?)
- Reads from: {table names}
- Writes to: {table names}

## 9. ADDITIONAL NOTES
- {English notes}

---
## CLARIFICATION NEEDED
- [?] Section {N}: {English question}
```
