---
trigger: /clean-requirement
description: Transform messy post-meeting notes into a structured SRS (3-pillar format). Output saved to {PIPELINE_ROOT}\requirements\.
---

# /clean-requirement -- Clean Up Requirements

## When user runs `/clean-requirement`:

1. Load skill `clean-requirement`
2. User pastes raw notes into chat
3. BA reads domain knowledge -> transforms notes into structured SRS (3 pillars)
4. Save to `{PIPELINE_ROOT}\requirements\REQ_{SEQ}_{Name}.md`

## Quick Reference

- **Read domain from:** `.agent\projects\hoaiminh\domain\` (HM project) or SRS notes only (other projects)
- **Write SRS to:** `{PIPELINE_ROOT}\requirements\`
- **Template:** 7-Pillar SRS (IEEE 29148)
