# Entity Snapshot: tbl_LSStatus

> Source: src/Domain/Entities/tbl_LSStatus.cs (read 2026-05-13)
> Table: tbl_LSStatus
> FK Navigation: none

## Columns

| Column | C# Type | Nullable | Notes |
|--------|---------|----------|-------|
| Code | int | NO | PK |
| StatusID | string? | YES | String code |
| StatusName | string? | YES | Display name (Vietnamese) |
| TypeOfStatus | int | NO | Groups statuses by feature |
| TypeData | int | NO | |
| ParentID | int? | YES | |
| Remark | string? | YES | |
| CreateBy | string? | YES | |
| CreateTime | DateTime? | YES | |
| LastModifiedBy | string? | YES | |
| LastModifiedTime | DateTime? | YES | |

## CRITICAL NOTES

- No `Head` column -- this is a lookup/reference table, no tenant filter needed
- `TypeOfStatus` is the key for filtering by feature group (NOT `TypeData`)
- `TypeData` = position/sequence within a group (1=first state, 2=second state, etc.)
- When joining from other tables: `.Include(x => x.tbl_LSStatus)` then `s.tbl_LSStatus.StatusName`
- GetListStatus API filters by TypeOfStatus to return statuses for a specific entity

## Known TypeOfStatus Groups (verified from DB 2026-05-14)

> ⚠️ CRITICAL: Entity Status fields store **TypeData** (1,2,3...) — NOT Code/PK (27,28,92...).
> Proof: `EnumSALOrderMasterStatus` in code has values 1-6 (TypeData), not 27-31 (Code PK).

| TypeOfStatus | Feature Entity | TypeData → StatusName | Existing ENUM file |
|---|---|---|---|
| 7 | tbl_SALOrderMaster | 1=Mới, 2=Chờ giao/Chọn xe, 3=Chờ xử lý/Xe mua, 4=Đang xử lý/Thành công, 5=Hoàn tất/Hủy, 6=Hủy giao dịch | `EnumSALOrderMasterStatus.cs` ✅ |
| 18 | tbl_SALOrderReceipt | Query DB to get TypeData values | Check `src/Domain/ENUM/` |

> SQL for ENUM resolution (use TypeData, NOT Code):
> `SELECT TypeData, StatusName FROM tbl_LSStatus WHERE TypeOfStatus = {N} ORDER BY TypeData`
> Default new-entity Status = TypeData of the FIRST state (TypeData=1) in the group.
> If feature has no status workflow → Section 3a = N/A → do NOT set Status on new entity.

## Common Errors

| Wrong | Correct |
|-------|---------|
| `.Where(x => x.Head == ...)` | No Head filter -- lookup table |
| `StatusCode` column | `Code` (PK is Code not StatusCode) |
| `TypeData` for status type | `TypeOfStatus` (not TypeData) |
| BA asks TBD about "TypeData" of status group | Ask about `TypeOfStatus` value |
