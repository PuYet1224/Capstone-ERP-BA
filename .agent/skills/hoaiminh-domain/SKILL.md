---
name: hoaiminh-domain
description: >
  DEPRECATED LOCATION - This skill has been moved.
  New path: .agent/projects/hoaiminh/
  
  Domain knowledge files are now at: .agent/projects/hoaiminh/domain/
  Memory files are now at: .agent/projects/hoaiminh/memory/
  Standards files are now at: .agent/projects/hoaiminh/standards/
  
  The ba-pipeline skill should read from the new location instead.
  Do NOT read from this folder. The files here (sections/ and memory/) 
  are kept as backup only and may become stale.
---

# MOVED - Hoai Minh Domain Knowledge

>  **This skill folder is deprecated.**
> All content has been moved to: `.agent/projects/hoaiminh/`

## New Structure

```
.agent/projects/hoaiminh/
-- PROJECT.md               Meta + trigger rules
-- domain/                  Business knowledge
-- standards/               Technical standards
|   -- be-standards.md
|   -- fe-standards.md
-- memory/                  Feature memories
```

**ba-pipeline** will load from the new location automatically.
