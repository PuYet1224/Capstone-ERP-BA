---
description: Systematic debugging for BA workspace. Use when skills fail, SRS generation errors, or pipeline outputs are incorrect. Usage /debug
skills:
  - debug
  - ba-pipeline
---

# /debug — Systematic BA Debug

## STEP 1: Understand the Issue
- What skill/workflow was running?
- What was the expected output?
- What actually happened? (error message, wrong output, missing file)

## STEP 2: Triage
```
Which part is failing?
├── /clean-requirement     → Check input notes format, SRS template
├── /ba-analyst            → Check SRS file exists, Figma/design connection
├── Figma MCP              → Check plugin running, bridge started, port 38451
├── File I/O               → Check {PROJECT_PIPELINE} path exists and writable
└── Skill itself           → Check SKILL.md YAML frontmatter, instructions
```

## STEP 3: Fix Root Cause
- Read the skill file that failed
- Check the input data (SRS file, notes, design images)
- Fix the source of the error, not the symptom

## STEP 4: Verify
- Re-run the failed skill/workflow
- Confirm output files are generated correctly
- Check output content matches expectations

## STEP 5: Report
```
✅ Issue resolved:
   Root cause: {description}
   Fix: {what was changed}
   Verified: {workflow} runs successfully
```
