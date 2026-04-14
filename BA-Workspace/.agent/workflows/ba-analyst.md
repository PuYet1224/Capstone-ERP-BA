---
trigger: /ba-analyst
description: BA phân tích requirement mới từ shared pipeline folder. Auto-scan → analyze → create BE + FE guides.
---

# /ba-analyst — Phân tích Requirement

## Khi user gõ `/ba-analyst`:

1. Load skill `ba-pipeline` (nếu chưa load)
2. Thực hiện **toàn bộ** Step 1 → Step 7 trong `ba-pipeline` SKILL.md
3. Không hỏi thêm gì ngoài những gì protocol yêu cầu

## Quick Reference

- **Đọc requirement từ:** `C:\ai-pipeline\requirements\` (REQ_*.md)
- **Đọc domain từ:** `.agent\skills\hoaiminh-domain\sections\` (internal)
- **Ghi guides vào:** `C:\ai-pipeline\guides\` (BE_*.md + FE_*.md)
- **Ghi memory vào:** `.agent\skills\hoaiminh-domain\memory\` (internal)
