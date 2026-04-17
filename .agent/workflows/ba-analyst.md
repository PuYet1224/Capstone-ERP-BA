---
trigger: /ba-analyst
description: BA analyzes new requirements from the shared pipeline folder. Auto-scan → analyze → create BE + FE guides. Usage /ba-analyst [REQ_xxx] or /ba-analyst
skills:
  - ba-pipeline
  - hoaiminh-domain
---

# /ba-analyst — Analyze Requirements & Create Guides

## When user runs `/ba-analyst [feature name]`:

1. Read skill: `.agent/skills/ba-pipeline/SKILL.md`
2. Load domain knowledge: `.agent/skills/hoaiminh-domain/sections/`
3. Execute **all** Steps 1 → 7 in `ba-pipeline` SKILL.md
4. Do not ask additional questions beyond what the protocol requires

## Quick Reference

| Input | Output |
|-------|--------|
| `C:\ai-pipeline\requirements\REQ_*.md` | `C:\ai-pipeline\guides\BE_*.md` |
| `.agent\skills\hoaiminh-domain\sections\` | `C:\ai-pipeline\guides\FE_*.md` |
| | `.agent\skills\hoaiminh-domain\memory\{Feature}.md` |

## Final Output

```
✅ Analysis complete:
   📄 BE Guide: C:\ai-pipeline\guides\BE_{SEQ}_{Feature}.md
   📄 FE Guide: C:\ai-pipeline\guides\FE_{SEQ}_{Feature}.md
   📝 Memory:   .agent\skills\hoaiminh-domain\memory\{Feature}.md

Next steps:
   👉 Open BE workspace → /be-implement
   👉 Open FE workspace → /fe-implement
   👉 After all done → /clean-pipeline {feature-name} (in this BA workspace)
```
