---
trigger: /memorize
description: Đọc SRS + code thực tế (BE + FE) + guides → chưng cất thành memory file English vĩnh viễn trong BA. Chạy TRƯỚC /clean-pipeline. Usage /memorize [feature-name]
skills:
  - memorize
---

# /memorize [feature-name]

> **Bắt buộc chạy TRƯỚC `/clean-pipeline`.**  
> Load and follow skill `memorize` exactly.

## Steps

1. Read skill: `.agent/skills/memorize/SKILL.md`
2. Execute all steps: read SRS → read guides → read actual code → distill → write memory

## Final Output

```
✅ Memorized: {Feature}
   📝 Memory: .agent/skills/hoaiminh-domain/memory/{Feature}.md
   ⚡ Deviations from plan: {N}
   🧠 Covers: {N} states, {N} rules, {N} APIs, {N} gotchas

✅ Safe to run: /clean-pipeline {feature-name}
```
