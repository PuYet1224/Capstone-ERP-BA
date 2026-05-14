# Entity Snapshot: tbl_SALOrderMaster

> Source: src/Domain/Entities/tbl_SALOrderMaster.cs (read 2026-05-13)
> Table: tbl_SALOrderMaster
> FK Navigation: tbl_LSStatus (Status), tbl_HREmployee (SaleStaff), tbl_CSLoyalCustomer (Customer)
> Collection Navigation: tbl_SALOrderDetail, tbl_SALOrderInvoices, tbl_SALOrderReceipts

## Columns

| Column | C# Type | Nullable | Notes |
|--------|---------|----------|-------|
| Code | long | NO | PK |
| ID | string? | YES | Order ID string |
| UserID | int? | YES | |
| Customer | long? | YES | FK -> tbl_CSLoyalCustomer |
| IsNewCustomer | bool? | YES | |
| Partner | long? | YES | |
| SaleDate | DateTime? | YES | |
| SaleStaff | int? | YES | FK -> tbl_HREmployee |
| AmountPaid | double? | YES | NOT decimal |
| PaymentMethod | int? | YES | |
| PaymentCount | int? | YES | |
| TypeData | int | NO | |
| Status | int | NO | FK -> tbl_LSStatus |
| HeadOut | long | NO | Tenant filter (use HeadOut not Head) |
| WHOut | long? | YES | Warehouse out |
| CreatedBy | string? | YES | |
| CreatedTime | DateTime? | YES | |
| LastModifiedBy | string? | YES | |
| LastModifiedTime | DateTime? | YES | |
| CustomerNeeds | string? | YES | |
| CustomerCharacteristics | string? | YES | |
| CustomerExpectation | string? | YES | |
| CustomerPreferences | string? | YES | |
| CustomerNotes | string? | YES | |
| CustomerName | string? | YES | Denormalized customer name |
| CustomerGender | int? | YES | |
| SIOMasterVehicle | long? | YES | |

## Navigation Properties (exclude from projection)

| Property | Type | FK Column |
|----------|------|-----------|
| tbl_LSStatus | tbl_LSStatus? | Status |
| tbl_HREmployee | tbl_HREmployee? | SaleStaff |
| tbl_CSLoyalCustomer | tbl_CSLoyalCustomer? | Customer |
| tbl_SALOrderDetail | ICollection | - |
| tbl_SALOrderInvoices | ICollection | - |
| tbl_SALOrderReceipts | ICollection | - |

## CRITICAL NOTES

- **Tenant filter column is `HeadOut` NOT `Head`** -- this table has no `Head` column
- Filter MUST be: `.Where(x => x.HeadOut == currentUser.CompanyId)`
- AmountPaid is `double` NOT `decimal`
- CustomerName is denormalized (copied at order time, may differ from tbl_CSLoyalCustomer.FullName)

## Common Errors

| Wrong | Correct |
|-------|---------|
| `.Where(x => x.Head == ...)` | `.Where(x => x.HeadOut == ...)` |
| `AmountPaid: decimal` | `AmountPaid: double` |
| `CollectedAmount` | `AmountPaid` (no such column) |
