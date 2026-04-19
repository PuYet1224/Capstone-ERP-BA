---
name: clean-pipeline
description: Clean up {PIPELINE_ROOT} after implementation and review are complete. Deletes SRS and guides for finished features. MUST run /memorize first. Do NOT use for in-progress features.
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
`--- guides\          BE_{SEQ}_{Feature}.md  |  FE_{SEQ}_{Feature}.md
```

> **Design data** comes from **Figma MCP** (live) -- no local design files in pipeline.

---

## 3. Steps

### Step 1: Scan Pipeline State

```
1. List all files in requirements\ -> extract feature + SEQ
2. List all files in guides\       -> check for BE_ + FE_ pair
3. Build a status map (see output format below)
```

### Step 2: Determine Completion

A feature is **safe to clean** when ALL conditions met:
- ✅ Has `REQ_` file
- ✅ Has **both** `BE_` AND `FE_` guide
- ✅ User explicitly named the feature OR passed `--all-done`

**Never auto-delete** without explicit user intent.

### Step 3: Execute Cleanup

For each feature to clean:

```
1. Delete: requirements\REQ_{SEQ}_{Feature}.md
2. Delete: guides\BE_{SEQ}_{Feature}.md
3. Delete: guides\FE_{SEQ}_{Feature}.md
```

### Step 4: Handle Edge Cases

| Case | Action |
|------|--------|
| Guide exists but no SRS | Clean docs anyway if user confirms |
| `--dry-run` flag | Show everything, delete NOTHING |
| `--all-done` flag | Show dry-run first -> ask "Confirm delete all?" |

### Step 5: Report

```
🧹 Pipeline Cleaned: {Feature}

🗑️ Deleted:
   📄 requirements\REQ_{SEQ}_{Feature}.md
   📄 guides\BE_{SEQ}_{Feature}.md
   📄 guides\FE_{SEQ}_{Feature}.md

📊 Pipeline After Cleanup:
   📁 requirements\ : {N} files remaining
   📁 guides\       : {N} files remaining

🔍 Remaining Features In Progress:
   - {FeatureName} -- SRS only / has guides
```

---

## 4. Safety Rules

1. **NEVER delete without explicit user intent**
2. **Always show dry-run for `--all-done`** before executing
3. **Remind user:** Files are permanently deleted -- git commit first if needed
