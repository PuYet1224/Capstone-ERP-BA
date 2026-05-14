# Entity Snapshot: tbl_CSLoyalCustomer

> Source: src/Domain/Entities/tbl_CSLoyalCustomer.cs (read 2026-05-13)
> Table: tbl_CSLoyalCustomer
> FK Navigation: tbl_HRList x2 (Gender, Occupation), tbl_CSList (FreeTimeType)

## Columns

| Column | C# Type | Nullable | Notes |
|--------|---------|----------|-------|
| Code | long | NO | PK |
| CardNo | string? | YES | Loyalty card number |
| FirstName | string? | YES | |
| MiddleName | string? | YES | |
| LastName | string? | YES | |
| FullName | string? | YES | Preferred for display |
| BirthDay | int? | YES | Day part only |
| BirthMonth | int? | YES | Month part only |
| BirthYear | int? | YES | Year part only |
| BirthDate | DateTime? | YES | Full date |
| Gender | int? | YES | FK -> tbl_HRList |
| Province | int? | YES | |
| District | int? | YES | |
| Ward | int? | YES | |
| Address | string? | YES | |
| FullAddress | string? | YES | Concatenated |
| Cellphone1 | string? | YES | Primary phone |
| Cellphone2 | string? | YES | |
| Cellphone3 | string? | YES | |
| Email | string? | YES | |
| Occupation | int? | YES | FK -> tbl_HRList |
| FirstHead | long? | YES | First branch |
| CurrentPoint | double? | YES | Loyalty points |
| CurrentDiscount | double? | YES | |
| StartDiscountDate | DateTime? | YES | |
| FinishDiscountDate | DateTime? | YES | |
| TypeSMS | int? | YES | |
| StatusID | int? | YES | |
| TypeData | int? | YES | |
| CreateBy | string? | YES | |
| CreateTime | DateTime? | YES | |
| LastModifiedBy | string? | YES | |
| LastModifiedTime | DateTime? | YES | |
| Zalo | string? | YES | |
| IsCellPhone | bool? | YES | |
| MyHonda | int? | YES | |
| MyHondaReason | int? | YES | |
| MyHondaReasonDetail | string? | YES | |
| OA | int? | YES | |
| OAReason | int? | YES | |
| OAaReasonDetail | string? | YES | Note: typo in entity (OAa not OA) |
| Personality | string? | YES | |
| Interest | string? | YES | |
| OtherConsiderations | string? | YES | |
| CitizenCardNo | string? | YES | |
| DateOfIssue | DateTime? | YES | |
| FreeStartTime | DateTime? | YES | |
| FreeEndTime | DateTime? | YES | |
| FreeTimeType | int? | YES | FK -> tbl_CSList |

## Navigation Properties (exclude from projection)

| Property | Type | FK Column |
|----------|------|-----------|
| tbl_HRList | tbl_HRList | Gender |
| tbl_HRList1 | tbl_HRList | Occupation |
| tbl_CSList | tbl_CSList | FreeTimeType |

## CRITICAL NOTES

- **NO `Head` column** -- customer is cross-branch (FirstHead tracks first registration branch)
- Phone field is `Cellphone1` NOT `CellPhone` or `Phone` or `CustomerPhone`
- `FullName` is the preferred display field (not FirstName+LastName concatenation)
- `CurrentPoint/CurrentDiscount` are `double` NOT `decimal`

## Common Errors

| Wrong | Correct |
|-------|---------|
| `CellPhone` | `Cellphone1` |
| `Phone` | `Cellphone1` |
| `CustomerPhone` | `Cellphone1` |
| `.Where(x => x.Head == ...)` | No Head filter -- cross-branch lookup |
| `CurrentDiscount: decimal` | `CurrentDiscount: double` |
