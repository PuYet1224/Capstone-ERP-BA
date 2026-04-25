---
trigger: /memorize
description: Distill SRS + actual code (BE + FE) + guides into a permanent English memory file in BA workspace. Run BEFORE /clean-pipeline. Usage /memorize [feature-name]
skills:
  - memorize
---

# /memorize [feature-name]

> **MUST run BEFORE `/clean-pipeline`.**
> Load and follow skill `memorize` exactly.

## Steps

1. Read skill: `.agent/skills/memorize/SKILL.md`
2. Execute all steps: read SRS -> read guides -> read actual code -> distill -> write memory

## Memory Output Path

**Capstone ERP projects:**
```
.agent/projects/Capstone/memory/{Feature}.md
```

**Other projects:**
```
.agent/projects/{project-name}/memory/{Feature}.md
(create folder if doesn't exist)
```

## Final Output

```
[OK] Memorized: {Feature}
    Memory: .agent/projects/Capstone/memory/{Feature}.md
    Deviations from plan: {N}
    Covers: {N} states, {N} rules, {N} APIs, {N} gotchas

[OK] Safe to run: /clean-pipeline {feature-name}
```
