---
workflow: ba-analyst
role: BA
version: 1.0
trigger: "/ba-analyst [path-to-REQ-file or feature-name]"
goal: "BE guide + FE guide(s) saved to guides/ folder, quality gate passed for each guide, all TBDs surfaced"
---

# /ba-analyst [REQ file path or feature name]

## Purpose

Analyze SRS + design images, produce BE and FE implementation guides.
Thin entry point: delegates all heavy logic to ba-pipeline skill.

## Pre-conditions

- [ ] REQ_*.md file exists in `{PROJECT_PIPELINE}\requirements\`
- [ ] Domain files loaded (01-glossary + 06-database-schema minimum)

---

## Steps

### Step 1 -- Load Skill
- Action: Read `.agent/skills/ba-pipeline/SKILL.md` in full (all steps and rules)
- Gate: Skill loaded -> proceed.

### Step 2 -- Find REQ File
- Input: User argument (full path or feature name)
- Action:
  - Full path provided -> read that file directly
  - Feature name provided -> scan `{PROJECT_PIPELINE}\requirements\` for matching `REQ_*.md`
  - No argument -> scan for any REQ_*.md without matching guide in `guides/`
- Gate: Exactly 1 REQ file resolved. 0 found -> STOP: "No REQ file found. Run /clean-requirement first." Multiple found -> list all, ask user to pick.

### Step 3 -- Read Design Images
- Action: Scan `{PROJECT_PIPELINE}\designs\{feature-name}\` for actual PNG/JPG files.
  - Check `mobile/`, `web/`, `desktop/` subfolders for actual image files (not just folder existence)
  - Read images using view_file tool in batches of 3
  - Do NOT use Figma MCP -- designs come from PNG files in pipeline only
- Gate: Platform resolved (Mobile/Web/Both) before generating guides.

### Step 4 -- Load Domain Knowledge
- Action: Load `domain-knowledge` skill.
  - Always read: `01-glossary.md` + `06-database-schema.md`
  - Load module-specific files based on feature module code (SAL/CS/WH/HR)
- Gate: Domain loaded.

### Step 5 -- Execute BA Pipeline
- Action: Execute all Steps 1-11 from `ba-pipeline` SKILL.md
- Output: BE guide + FE guide(s) saved to `{PROJECT_PIPELINE}\guides\`
- Gate: All guides saved. Quality gate checklist passed for each guide.

### Step 6 -- Verify Goal (MANDATORY before reporting done)
- Action: Re-read the `goal:` field from this workflow's frontmatter. Check EACH condition:
  - [ ] BE guide saved to `guides/BE_*.md`
  - [ ] FE Mobile guide saved to `guides/FE_MOBWEB_*.md` (if mobile design exists)
  - [ ] FE Web guide saved to `guides/FE_WEB_*.md` (if desktop design exists)
  - [ ] Quality gate checklist passed for each guide (no known defects)
  - [ ] All TBDs surfaced explicitly (even if unresolved -- they must be listed)
- If ALL conditions met → proceed to Step 7 (Report)
- If ANY condition not met → fix the guide NOW, then re-verify. Do NOT skip to Report.
- Gate: Every condition in goal: field confirmed true.

### Step 7 -- Report Next Commands (MANDATORY -- always output this block)

After saving all guides, output EXACTLY this block so the user can copy-paste:

```
[OK] Guides generated:
  BE:        {PROJECT_PIPELINE}\guides\BE_{SEQ}_{Feature}.md
  FE Mobile: {PROJECT_PIPELINE}\guides\FE_MOBWEB_{SEQ}_{Feature}.md  (if applicable)
  FE Web:    {PROJECT_PIPELINE}\guides\FE_WEB_{SEQ}_{Feature}.md     (if applicable)

[NEXT COMMANDS -- copy and run in order]
  BE workspace:     /be-implement
  FE Mobile:        /fe-mobile-implement
  FE Web:           /fe-implement

[OPEN TBDs -- resolve before implementing]
  TBD-xx: {question} -> blocks: {FR/BR}
```

---

## Quick Reference

| Input | Output |
|---|---|
| `{PROJECT_PIPELINE}\requirements\REQ_*.md` | `{PROJECT_PIPELINE}\guides\BE_*.md` |
| `{PROJECT_PIPELINE}\designs\{feature}\mobile\*.png` | `{PROJECT_PIPELINE}\guides\FE_MOBWEB_*.md` |
| `{PROJECT_PIPELINE}\designs\{feature}\desktop\*.png` | `{PROJECT_PIPELINE}\guides\FE_WEB_*.md` |
