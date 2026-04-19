---
trigger: /memorize
description: Read SRS + actual code (BE + FE) + guides and distill into a permanent English memory file in BA. Run BEFORE /clean-pipeline. Usage /memorize [feature-name]
skills:
  - memorize
---

# /memorize [feature-name]

> **Mandatory: run BEFORE `/clean-pipeline`.**  
> Load and follow skill `memorize` exactly.

## Steps

1. Read skill: `.agent/skills/memorize/SKILL.md`
2. Execute all steps: read SRS -> read guides -> read actual code -> distill -> write memory

## Memory Output Path

**Hoai Minh ERP projects:**
```
.agent/projects/hoaiminh/memory/{Feature}.md
```

**Other projects:**
```
.agent/projects/{project-name}/memory/{Feature}.md
(create folder if doesn't exist)
```

## Fprintal Output

```
✅ Memorized: {Feature}
   📝 Memory: .agent/projects/hoaiminh/memory/{Feature}.md
   ⚡ Deviations from plan: {N}
   🧠 Covers: {N} states, {N} rules, {N} APIs, {N} gotchas

✅ Safe to run: /clean-pipeline {feature-name}
```
