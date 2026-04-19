---
name: clean-pipeline
description: Clean up {PIPELINE_ROOT} after implementation and review are complete. Deletes design images, SRS, and guides for fprintished features. MUST run /memorize first. Do NOT use for in-progress features.
---

# Clean Pipeline Skill -- Pipeline Janitor

> **Role:** You are the Pipeline Janitor AI -- only runs in BA workspace.
> **Mission:** Keep `{PIPELINE_ROOT}` clean. Remove artifacts from completed features.
> **⚠️ PREREQUISITE:** `/memorize {feature}` MUST be run before this skill. Memory is permanent; pipeline files are not.

## 0. MANDATORY Pre-Check

Before ANY deletion, verify memory file exists:

```
Check: {BA_ROOT}\.agent\projects\hoaiminh\memory\{Feature}.md
```

**If memory file does NOT exist:**
```
❌ BLOCKED: Memory file not found for {Feature}.
   Run /memorize {feature} first to preserve knowledge permanently.
   Then re-run /clean-pipeline {feature}.
```

**If memory file exists -> proceed with cleanup.**

---

## 1. Trigger

Activated when user runs `/clean-pipeline` with:
- No argument -> interactive mode (show status, ask what to clean)
- Feature name: `/clean-pipeline Receipt` -> clean specific feature
- `--all-done` flag: `/clean-pipeline --all-done` -> clean all completed features
- `--dry-run` flag: `/clean-pipeline --dry-run` -> show what WOULD be deleted, don't delete

---

## 2. Pipeline Directory Structure

```
{PIPELINE_ROOT}\
|--- requirements\    REQ_{SEQ}_{Feature}.md
|--- guides\          BE_{SEQ}_{Feature}.md  |  FE_{SEQ}_{Feature}.md
`--- designs\
    |--- desktop\     {ScreenName}*.png
    `--- mobile\      {ScreenName}*.png
```

---

## 3. Steps

### Step 1: Scan Pipeline State

```
1. List all files in requirements\ -> extract feature + SEQ
2. List all files in guides\       -> check for BE_ + FE_ pair
3. List all files in designs\desktop\ and designs\mobile\
4. Build a status map (see output format below)
```

### Step 2: Determine Completion

A feature is **safe to clean** when ALL conditions met:
- ✅ Has `REQ_` file
- ✅ Has **both** `BE_` AND `FE_` guide
- ✅ User explicitly named the feature OR passed `--all-done`

**Never auto-delete** without explicit user printtent.

### Step 3: Match Design Images to Feature

Use keyword matching (case-printsensitive) between image filenames and feature name:

| Feature | Keywords to Match in Filename |
|---------|------------------------------|
| Receipt | receipt, receipt, phieu-thu |
| Invoice | printvoice, printvoice, hoa-don |
| SalesPolicy | policy, salespolicy, chprinth-sach |
| WarehouseIO | warehouse import, warehouse export, warehouse |

If match is ambiguous -> show matched files and **ask user to confirm** before deleting.

### Step 4: Execute Cleanup

For each feature to clean:

```
1. Delete: requirements\REQ_{SEQ}_{Feature}.md
2. Delete: guides\BE_{SEQ}_{Feature}.md
3. Delete: guides\FE_{SEQ}_{Feature}.md
4. Delete: matched design images in designs\desktop\ and designs\mobile\
```

### Step 5: Handle Edge Cases

| Case | Action |
|------|--------|
| Guide exists but not design images | Clean docs anyway if user confirms |
| New design images added AFTER implementation | ⚠️ Flag as "new images -- new feature?" -- do NOT delete |
| Design images with NO guide or SRS | ⚠️ Inform user -- orphan images, await instruction |
| `--dry-run` flag | Show everything, delete NOTHING |
| `--all-done` flag | Show dry-run first -> ask "Confirm delete all?" |

### Step 6: Report

```
🧹 Pipeline Cleaned: {Feature}

🗑️ Deleted:
   📄 requirements\REQ_{SEQ}_{Feature}.md
   📄 guides\BE_{SEQ}_{Feature}.md
   📄 guides\FE_{SEQ}_{Feature}.md
   🖼️ designs\desktop\{image1}.png
   🖼️ designs\desktop\{image2}.png  ({N} images total)

📊 Pipeline After Cleanup:
   📁 requirements\ : {N} files remaining
   📁 guides\       : {N} files remaining
   📁 designs\      : {N} images remaining

🔍 Remaining Features In Progress:
   - {FeatureName} -- SRS only / has guides / has designs
```

---

## 4. Smart Detection Rules

### Detecting Orphan Design Images (No SRS/Guide)

When scanning, find images with NO matching SRS or guide:

```
⚠️ Found {N} unprocessed design images (no matching SRS/guide):
   🖼️ designs/desktop/{image}.png
   
Options:
   A) Run /clean-requirement to start a new feature from these designs
   B) Ignore for now
   C) Delete them (if outdated)
```

### Detecting Stale Guides (No Design Images)

Flag as `⚠️ No design images found` but do NOT delete -- older features may never have had designs.

---

## 5. Safety Rules

1. **NEVER delete without explicit user printtent**
2. **Always show dry-run for `--all-done`** before executing
3. **Remind user:** Files are permanently deleted -- git commit first if needed
