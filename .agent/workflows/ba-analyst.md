---
trigger: /ba-analyst
description: BA phân tích requirement mới từ shared pipeline folder. Auto-scan → analyze → create BE + FE guides. Usage /ba-analyst [REQ_xxx] or /ba-analyst
skills:
  - ba-pipeline
  - hoaiminh-domain
---

# /ba-analyst — Phân tích Requirement & Tạo Guide

## Khi user gõ `/ba-analyst [tên feature]`:

1. Read skill: `.agent/skills/ba-pipeline/SKILL.md`
2. Load domain knowledge: `.agent/skills/hoaiminh-domain/sections/`
3. Thực hiện **toàn bộ** Step 1 → Step 7 trong `ba-pipeline` SKILL.md
4. Không hỏi thêm gì ngoài những gì protocol yêu cầu

## Quick Reference

| Input | Output |
|-------|--------|
| `C:\ai-pipeline\requirements\REQ_*.md` | `C:\ai-pipeline\guides\BE_*.md` |
| `.agent\skills\hoaiminh-domain\sections\` | `C:\ai-pipeline\guides\FE_*.md` |
| | `.agent\skills\hoaiminh-domain\memory\{Feature}.md` |

## Final Output

```
✅ Phân tích hoàn tất:
   📄 BE Guide: C:\ai-pipeline\guides\BE_{SEQ}_{Feature}.md
   📄 FE Guide: C:\ai-pipeline\guides\FE_{SEQ}_{Feature}.md
   📝 Memory: .agent\skills\hoaiminh-domain\memory\{Feature}.md

Bước tiếp:
   👉 Mở BE workspace → /be-implement
   👉 Mở FE workspace → /fe-implement
   👉 Sau khi xong hết → /clean-pipeline {feature-name} (tại BA workspace này)
```
