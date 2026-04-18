---
trigger: /ba-analyst
description: BA analyzes new requirements from the shared pipeline folder. Uses Figma MCP bridge to read live designs. Auto-scan → analyze → create BE + FE guides. Usage /ba-analyst [REQ_xxx] or /ba-analyst
skills:
  - ba-pipeline
  - figma-reader
  - hoaiminh-domain
---

# /ba-analyst — Analyze Requirements & Create Guides

## When user runs `/ba-analyst [feature name]`:

1. Read skill: `.agent/skills/ba-pipeline/SKILL.md`
2. Read skill: `.agent/skills/figma-reader/SKILL.md`
3. Load domain knowledge: `.agent/skills/hoaiminh-domain/sections/`
4. **Figma MCP Check** (MANDATORY before any design analysis):
   - Call `figma_status` → verify connected
   - If connected → read design via `figma_read scan_design` + `get_selection`
   - If NOT connected → STOP, ask user to connect Figma Desktop + MCP plugin
5. Execute **all** Steps 1 → 7 in `ba-pipeline` SKILL.md
6. Do not ask additional questions beyond what the protocol requires

## Quick Reference

| Input | Output |
|-------|--------|
| `C:\ai-pipeline\requirements\REQ_*.md` | `C:\ai-pipeline\guides\BE_*.md` |
| Figma MCP (live design) | `C:\ai-pipeline\guides\FE_*.md` |
| `.agent\skills\hoaiminh-domain\sections\` | `.agent\skills\hoaiminh-domain\memory\{Feature}.md` |

## Final Output

```
✅ Analysis complete:
   📄 BE Guide: C:\ai-pipeline\guides\BE_{SEQ}_{Feature}.md
   📄 FE Guide: C:\ai-pipeline\guides\FE_{SEQ}_{Feature}.md
   📝 Memory:   .agent\skills\hoaiminh-domain\memory\{Feature}.md
   🎨 Design:   Read from Figma Desktop (live)

Next steps:
   👉 Open BE workspace → /be-implement
   👉 Open FE workspace → /fe-implement
   👉 After all done → /clean-pipeline {feature-name} (in this BA workspace)
```
