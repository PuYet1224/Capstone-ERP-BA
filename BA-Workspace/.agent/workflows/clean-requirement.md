---
trigger: /clean-requirement
description: Biến note bừa bãi sau cuộc họp thành SRS chuẩn 3 trụ cột. Output lưu vào C:\ai-pipeline\requirements\.
---

# /clean-requirement — Dọn dẹp yêu cầu

## Khi user gõ `/clean-requirement`:

1. Load skill `clean-requirement`
2. User paste raw notes vào chat
3. BA đọc domain knowledge → biến note thành SRS 3 trụ cột
4. Lưu vào `C:\ai-pipeline\requirements\REQ_{SEQ}_{Name}.md`

## Quick Reference

- **Đọc domain từ:** `.agent\skills\hoaiminh-domain\sections\`
- **Ghi SRS vào:** `C:\ai-pipeline\requirements\`
- **Template:** 3 trụ cột (Business Rules + User Flow + Interface Definition)
