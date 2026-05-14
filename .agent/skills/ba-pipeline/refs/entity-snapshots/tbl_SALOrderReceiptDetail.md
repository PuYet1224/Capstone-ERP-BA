# Entity Snapshot: tbl_SALOrderReceiptDetail

> Source: src/Domain/Entities/tbl_SALOrderReceiptDetail.cs (read 2026-05-13)
> Namespace: HoaiMinh.ERP.Domain.Entities
> Table: tbl_SALOrderReceiptDetail
> FK: Receipt -> tbl_SALOrderReceipt.Code; OrderDetail -> tbl_SALOrderDetail.Code

## Columns

| Column | C# Type | Nullable | Notes |
|--------|---------|----------|-------|
| Code | long | NO | PK |
| Receipt | long | NO | FK to tbl_SALOrderReceipt.Code |
| OrderDetail | long | NO | FK to tbl_SALOrderDetail.Code |
| CollectedAmount | double | NO | Amount for this detail line -- double NOT decimal |
| CreatedTime | DateTime? | YES | |
| CreatedBy | string | YES | |
| LastModifiedTime | DateTime? | YES | |
| LastModifiedBy | string | YES | |

## Notes

- No Head column -- filter detail by joining to parent Receipt with HEAD filter
- CollectedAmount = double (same as parent Receipt)
