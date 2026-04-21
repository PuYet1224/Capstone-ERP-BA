> **Architecture Notes for BA Agents:** This document describes the AI pipeline workflow and workspace layout for the Hoai Minh ERP project.

# AI Pipeline Architecture - Hoai Minh ERP (BA View)

## Workspace Map

| Role | Workspace | Purpose |
|------|-----------|---------|
| **BA** (this workspace) | BA workspace | Analyze requirements, create guides for BE/FE |
| **BE** | BE workspace | Implement .NET 10 API handlers |
| **FE Web** | FE Web workspace | Implement Angular 16 desktop components |
| **FE Mobile** | FE Mobile workspace | Implement Angular 16 mobile components |

## Shared Pipeline Folder

```
{PIPELINE_ROOT}\                          C:\ai.pipeline
|--- Hoai-Minh-Project\                   {PROJECT_PIPELINE} for this project
|    |--- requirements\    <- BA writes REQ_{ID}_{Feature}.md here
|    |--- guides\          <- BA writes BE_*.md + FE_*.md here (BE/FE teams read)
|--- Other-Project\                       Future projects go here
     |--- requirements\
     |--- guides\
```

> Design data comes from **Figma MCP** (live) -- no local design files.
> Each project has its own `requirements/` and `guides/` folders.

---

## AI Workflow -- Feature Development Pipeline

```
[Client Meeting] -> [/clean-requirement] -> [/ba-analyst] -> [/be-implement + /fe-implement] -> [/review] -> [/test] -> [/memorize] -> [/clean-pipeline]
```

| Stage | Command | AI Role | Workspace | Input | Output |
|-------|---------|---------|-----------|-------|--------|
| 1. Gather requirements | `/clean-requirement` | **BA AI** | BA | Raw meeting notes | `REQ_{ID}_{Feature}.md` |
| 2. Analyze business | `/ba-analyst [feature]` | **BA AI** | BA | SRS file | `BE_{ID}_.md` + `FE_{ID}_.md` |
| 3. Backend | `/be-implement [feature]` | BE AI | BE | `BE_*.md` guide | `.cs` handlers |
| 4. Frontend | `/fe-implement [feature]` | FE AI | FE | `FE_*.md` guide | Angular components |
| 5. Code Review | `/review [feature]` | Senior AI | BE | Source code | Report issues |
| 6. Fix bugs | `/enhance [desc]` | Senior AI | BE | Issue description | Fixed code |
| 7. Test | `/test [feature]` | Test AI | BE | Handlers | xUnit test files |
| 8. Distill memory | `/memorize [feature]` | **BA AI** | BA | SRS + guides + code | Memory file |
| 9. Clean pipeline | `/clean-pipeline [feature]` | **BA AI** | BA | Feature name | Delete completed files |

> **BA is responsible for Stages 1, 2, 8, 9.**

---

## BA Workspace Internal Structure

```
.agent\
|--- rules\
|    `--- GEMINI.md    # BA identity + rules
|--- ARCHITECTURE.md    # This file
|--- agents\            # Specialized agents (ui-designer, etc.)
|--- skills\            # BA skills (ba-pipeline, hoaiminh-domain, figma-reader, memorize...)
|--- workflows\         # BA commands (/ba-analyst, /clean-requirement, /memorize...)
`--- projects\          # Project-specific context
```

---

## Multi-User Safety Rules

> **When multiple people work on the same pipeline:**

1. **MUST pass feature name** when calling command: `/ba-analyst Receipt`, NOT `/ba-analyst`
2. **File naming:** `{ID}_{FeatureName}` -- ID = TaskID (priority) or SEQ (fallback)
3. **Do NOT auto-select** when there are multiple files -- ask user

---

## Skill Governance Rules

| Type of Change | Requirement | Who Executes |
|--------------|---------|-------------|
| **Rules** (GEMINI.md) | **Team meeting required** before | PM + Team |
| **Skills** (`.agent/skills/`) | Add freely, no meeting needed | BA AI or Dev |
| **Workflows** (`.agent/workflows/`) | Add freely | Dev |
| **Domain knowledge** | Update anytime | BA or Dev |
