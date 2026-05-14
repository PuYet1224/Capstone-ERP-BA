---
workflow: clean-pipeline
role: BA
version: 1.0
trigger: "/clean-pipeline [feature-name]"
---

# /clean-pipeline [feature-name]

## Purpose

Remove completed feature artifacts from the pipeline folder.
Keeps pipeline clean so only active features remain.

## Pre-conditions

- [ ] `/memorize {feature}` MUST have been run first (memory file must exist)

---

## Steps

### Step 1 -- Verify Memory Exists
- Input: Feature name
- Action: Check `.agent/projects/hoaiminh/memory/{FeatureName}.md`
- Gate: File exists -> proceed. File NOT found -> STOP: "Run /memorize {feature} first."

### Step 2 -- Identify Files to Remove
- Action: Scan `{PROJECT_PIPELINE}` for files matching the feature:
  ```
  {PROJECT_PIPELINE}\requirements\REQ_*_{FeatureName}.md
  {PROJECT_PIPELINE}\requirements\MEETING_*{FeatureName}*.md
  {PROJECT_PIPELINE}\guides\BE_*_{FeatureName}.md
  {PROJECT_PIPELINE}\guides\FE_WEB_*_{FeatureName}.md
  {PROJECT_PIPELINE}\guides\FE_MOBWEB_*_{FeatureName}.md
  {PROJECT_PIPELINE}\designs\{feature}\*
  ```
- Gate: Files listed before deletion. User can see what will be removed.

### Step 3 -- Delete Files
- Action: Delete each identified file.
- Gate: All files deleted. Report results.

### Step 4 -- Report

```
Pipeline Cleaned: {FeatureName}
  Removed: {N} files
  Memory preserved at: .agent/projects/hoaiminh/memory/{FeatureName}.md
  Pipeline is clean for next feature.
```

---

## Safety Rules

- NEVER delete memory files (`.agent/projects/hoaiminh/memory/`)
- NEVER delete files for features that have NOT been memorized
- NEVER delete template files or .agent/ files
- Only delete from `{PROJECT_PIPELINE}` paths
