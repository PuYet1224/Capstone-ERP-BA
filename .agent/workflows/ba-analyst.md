---
trigger: /ba-analyst
description: BA analyzes new requirements from the shared pipeline folder. Uses Figma MCP bridge to read live designs. Auto-scan â†’ analyze â†’ create BE + FE guides. Usage /ba-analyst [REQ_xxx] or /ba-analyst
skills:
  - ba-pipeline
  - figma-reader
---

# /ba-analyst â€” Analyze Requirements & Create Guides

## When user runs `/ba-analyst [feature name]`:

1. Read skill: `.agent/skills/ba-pipeline/SKILL.md` (FULL â€” all steps)
2. Read skill: `.agent/skills/figma-reader/SKILL.md`
3. **ba-pipeline will auto-detect project type and load project knowledge from:**
   - `.agent/projects/hoaiminh/` â€” if HoÃ i Minh ERP detected (SAL/CS/WH/HR/SYS/MTB module codes)
   - Other projects â†’ no project folder loaded (universal mode)
4. Execute **all** Steps 1 â†’ 11 in `ba-pipeline` SKILL.md
5. Do not ask additional questions beyond what the protocol requires
6. Figma MCP: Try connect â†’ if not available, continue with SRS data only (do NOT stop)

## Quick Reference

| Input | Output |
|-------|--------|
| `C:\ai-pipeline\requirements\REQ_*.md` | `C:\ai-pipeline\guides\BE_*.md` |
| Figma MCP (live design) | `C:\ai-pipeline\guides\FE_WEB_*.md` [+ `FE_MOBWEB_*.md` if Both] |
| `.agent\projects\hoaiminh\standards\*.md` | embedded in guides (standards enforced) |
| `.agent\projects\hoaiminh\memory\*.md` | additional context (if HM project) |

## Final Output

```
âœ… Analysis complete:
   ðŸ“„ BE Guide:     C:\ai-pipeline\guides\BE_{SEQ}_{Feature}.md
   ðŸ“„ FE Web Guide: C:\ai-pipeline\guides\FE_WEB_{SEQ}_{Feature}.md
   ðŸ“„ FE Mob Guide: C:\ai-pipeline\guides\FE_MOBWEB_{SEQ}_{Feature}.md  [if Platform=Both]
   ðŸ“ Memory:       .agent\projects\hoaiminh\memory\{Feature}.md      [if HM project]
   ðŸŽ¨ Design:       Read from Figma Desktop (live) or SRS-only if not connected

Technical summary:
   APIs:    {N} endpoints | DTOs: {N} types | Enums: {N}
   Shared:  {N} PSCoreApiService methods | Cache: Redis list (5min)
   Screens: {N} screens | Discrepancies: {N} Figma vs SRS

Next steps:
   ðŸ‘‰ BE workspace  â†’ implement BE_{SEQ}_{Feature}.md
   ðŸ‘‰ FE workspace  â†’ implement FE_WEB_{SEQ}_{Feature}.md
   ðŸ‘‰ Mobile workspace â†’ implement FE_MOBWEB_{SEQ}_{Feature}.md (if applicable)
   ðŸ‘‰ After all done â†’ /memorize {feature-name} then /clean-pipeline {feature-name}
```

