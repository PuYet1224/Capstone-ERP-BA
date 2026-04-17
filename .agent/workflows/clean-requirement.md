---
trigger: /clean-requirement
description: Transform messy post-meeting notes into a structured SRS (3-pillar format). Output saved to C:\ai-pipeline\requirements\.
---

# /clean-requirement — Clean Up Requirements

## When user runs `/clean-requirement`:

1. Load skill `clean-requirement`
2. User pastes raw notes into chat
3. BA reads domain knowledge → transforms notes into structured SRS (3 pillars)
4. Save to `C:\ai-pipeline\requirements\REQ_{SEQ}_{Name}.md`

## Quick Reference

- **Read domain from:** `.agent\skills\hoaiminh-domain\sections\`
- **Write SRS to:** `C:\ai-pipeline\requirements\`
- **Template:** 3 pillars (Business Rules + User Flow + Interface Definition)
