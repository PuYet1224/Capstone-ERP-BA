---
trigger: /ba-analyst
description: BA analyzes new requirements from the shared pipeline folder. Uses Figma MCP bridge to read live designs. Auto-scan, analyze, create BE + FE guides. Usage /ba-analyst [REQ_xxx] or /ba-analyst
skills:
  - ba-pipeline
  - figma-reader
---

# /ba-analyst - Analyze Requirements & Create Guides

## When user runs `/ba-analyst [feature name]`:

1. Read skill: `.agent/skills/ba-pipeline/SKILL.md` (FULL - all steps)
2. Read skill: `.agent/skills/figma-reader/SKILL.md`
3. **ba-pipeline will auto-detect project type and load project knowledge from:**
   - `.agent/projects/hoaiminh/` - if Hoai Minh ERP detected (SAL/CS/WH/HR/SYS/MTB module codes)
   - Other projects -> no project folder loaded (universal mode)
4. Execute **all** Steps 1 -> 11 in `ba-pipeline` SKILL.md
5. Do not ask additional questions beyond what the protocol requires
6. Figma MCP: Try connect -> if not available, continue with SRS data only (do NOT stop)

## Quick Reference

| Input | Output |
|-------|--------|
| `{PROJECT_PIPELINE}\requirements\REQ_*.md` | `{PROJECT_PIPELINE}\guides\BE_*.md` |
| Figma MCP (live design) | `{PROJECT_PIPELINE}\guides\FE_WEB_*.md` [+ `FE_MOBWEB_*.md` if Both] |
| `.agent\projects\hoaiminh\standards\*.md` | embedded in guides (standards enforced) |
| `.agent\projects\hoaiminh\memory\*.md` | additional context (if HM project) |

## Final Output

```
Analysis complete:
   BE Guide:     {PROJECT_PIPELINE}\guides\BE_{SEQ}_{Feature}.md
   FE Web Guide: {PROJECT_PIPELINE}\guides\FE_WEB_{SEQ}_{Feature}.md
   FE Mob Guide: {PROJECT_PIPELINE}\guides\FE_MOBWEB_{SEQ}_{Feature}.md  [if Platform=Both]
   Memory:       .agent\projects\hoaiminh\memory\{Feature}.md      [if HM project]
   Design:       Read from Figma Desktop (live) or SRS-only if not connected

Technical summary:
   APIs:    {N} endpoints | DTOs: {N} types | Enums: {N}
   Shared:  {N} PSCoreApiService methods | Cache: Redis list (5min)
   Screens: {N} screens | Discrepancies: {N} Figma vs SRS

Next steps:
   BE workspace  -> implement BE_{SEQ}_{Feature}.md
   FE workspace  -> implement FE_WEB_{SEQ}_{Feature}.md
   Mobile workspace -> implement FE_MOBWEB_{SEQ}_{Feature}.md (if applicable)
   After all done -> /memorize {feature-name} then /clean-pipeline {feature-name}
```
