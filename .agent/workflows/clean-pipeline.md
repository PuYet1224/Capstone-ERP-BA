---
trigger: /clean-pipeline
description: Dọn dẹp C:\ai-pipeline sau khi implementation xong. Xóa SRS, guide, ảnh design của features đã hoàn thành. Usage /clean-pipeline [feature-name] or /clean-pipeline --dry-run
skills:
  - clean-pipeline
---

# /clean-pipeline [options]

> Load and follow skill `clean-pipeline` exactly.

## Usage

```
/clean-pipeline                  → Interactive: show pipeline status, ask what to clean
/clean-pipeline Receipt          → Clean specific feature by name
/clean-pipeline --dry-run        → Show what WOULD be deleted (safe preview, no delete)
/clean-pipeline --all-done       → Clean all completed features (shows dry-run first)
```

## Steps

1. Read skill: `.agent/skills/clean-pipeline/SKILL.md`
2. Execute all steps defined in that skill

## Safety Reminder

> ⚠️ Files are **permanently deleted**. Recommend git commit before running.

## Final Output

```
🧹 Cleaned: {Feature}
   Deleted: {N} files ({N} images + SRS + BE guide + FE guide)
   
📁 Pipeline remaining: {N} features still in progress
```
