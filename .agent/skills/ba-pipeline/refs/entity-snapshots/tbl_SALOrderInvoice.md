# Entity Snapshot: tbl_SALOrderInvoice

> Source: src/Domain/Entities/tbl_SALOrderInvoice.cs (read 2026-05-13)
> Table: tbl_SALOrderInvoice
> FK Navigation: tbl_SALOrderMaster (OrderMaster), tbl_LSStatus (Status)

## Columns

| Column | C# Type | Nullable | Notes |
|--------|---------|----------|-------|
| Code | long | NO | PK |
| Head | long | NO | Tenant filter |
| OrderMaster | long | NO | FK -> tbl_SALOrderMaster |
| InvoiceNo | string | NO | |
| InvoiceSerial | string | NO | |
| EffDate | DateTime? | YES | Effective date |
| VATAmount | double? | YES | NOT decimal |
| DiscountPercent | double? | YES | |
| DiscountAmount | double? | YES | |
| DiscountReason | string | NO | |
| TotalAmount | double? | YES | NOT decimal |
| TypeData | int | NO | |
| VATCustomer | long? | YES | |
| VATCustomerName | string | NO | |
| VATPassport | string | NO | |
| VATCompanyName | string | NO | |
| VATCompanyTax | string | NO | |
| VATBRUName | string | NO | |
| VATBRUCode | string | NO | |
| VATAddress | string | NO | |
| VATEmail | string | NO | |
| VATCellPhone | string | NO | |
| VATNote | string | NO | |
| VATType | int? | YES | |
| Status | int | NO | FK -> tbl_LSStatus |
| CreatedTime | DateTime? | YES | |
| CreatedBy | string | NO | |
| LastModifiedTime | DateTime? | YES | |
| LastModifiedBy | string | NO | |

## Navigation Properties (exclude from projection)

| Property | Type | FK Column |
|----------|------|-----------|
| tbl_SALOrderMaster | tbl_SALOrderMaster | OrderMaster |
| tbl_LSStatus | tbl_LSStatus | Status |
| tbl_SALOrderInvoiceDetails | ICollection | - |

## CRITICAL NOTES

- `Head` IS present -- filter: `.Where(x => x.Head == currentUser.CompanyId)`
- All money fields are `double` NOT `decimal`
- Many string fields are non-nullable (string not string?) -- include in INSERT without N'' check

## Common Errors

| Wrong | Correct |
|-------|---------|
| `TotalAmount: decimal` | `TotalAmount: double` |
| Skip InvoiceNo/InvoiceSerial | Required non-nullable strings |
