---
name: capstone-domain
description: >
  DEPRECATED LOCATION - This skill has been moved.
  New path: .agent/projects/capstone/
  
  Domain knowledge files are now at: .agent/projects/capstone/domain/
  Memory files are now at: .agent/projects/capstone/memory/
  Standards files are now at: .agent/projects/capstone/standards/
  
  The ba-pipeline skill should read from the new location instead.
  Do NOT read from this folder. The files here are kept as backup only.
---

# MOVED - Capstone ERP Domain Knowledge

> **This skill folder is deprecated.**
> All content has been moved to: `.agent/projects/capstone/`

## New Structure

```
.agent/projects/capstone/
-- PROJECT.md               Meta + trigger rules
-- domain/                  Business knowledge
-- standards/               Technical standards
|   -- be-standards.md
|   -- fe-standards.md
-- memory/                  Feature memories
```

**ba-pipeline** will load from the new location automatically.
