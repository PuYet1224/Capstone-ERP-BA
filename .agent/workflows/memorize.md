---
workflow: memorize
role: BA
version: 1.0
trigger: "/memorize [feature-name]"
---

# /memorize [feature-name]

## Purpose

Distill everything built for a completed feature into a permanent memory file.
Pipeline files are temporary. Memory is the permanent truth.
Run BEFORE /clean-pipeline.

## Pre-conditions

- [ ] Feature implementation is complete (BE code merged, FE code merged)
- [ ] Guide files exist in `{PROJECT_PIPELINE}\guides\`

---

## Steps

### Step 1 -- Read All 4 Sources
- Action: Read in priority order (highest to lowest trust):
  1. BE Code: `modules/MTB/Features/M.{Module}/F.{Feature}/*.cs`
  2. FE Code: `src/app/modules/{feature}/*.ts`
  3. Guides: `{PROJECT_PIPELINE}\guides\BE_*_{Feature}.md` + `FE_*_{Feature}.md`
  4. SRS: `{PROJECT_PIPELINE}\requirements\REQ_*_{Feature}.md`
- Gate: At least sources 3 and 4 found. Code sources preferred but optional.
- Priority rule: Actual Code > Guide > SRS. If guide says X but code does Y -> memory records Y.

### Step 2 -- Distill
- Action: Extract only permanent truths. Apply distillation rules:
  - INCLUDE: Final business rules, final API contracts, final state machine,
    DB tables used, decisions made (WHY not just WHAT), bugs fixed, edge cases, cross-module deps
  - EXCLUDE: Resolved open questions, abandoned approaches, raw file dumps, temp notes
- Gate: Every section has real content. No placeholder text.

### Step 3 -- Write Memory File
- Input: Template from `.agent/refs/memory-template.md`
- Action: Fill all sections with distilled content. English only.
- Gate:
  - Gotchas section has at least 1 entry
  - Decisions section explains WHY (not just WHAT was decided)
  - Reality-first: code version recorded where code differs from guide
- Output: `.agent/projects/hoaiminh/memory/{Feature}.md`

### Step 4 -- Report

```
Memory Saved: {Feature}.md
  Path: .agent/projects/hoaiminh/memory/{Feature}.md
  APIs recorded: {N}
  Business rules: {N}
  Gotchas: {N}

  >> Next command (copy this):
  /clean-pipeline {feature-name}
```
