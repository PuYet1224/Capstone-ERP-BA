# Entity Snapshot: tbl_SALOrderReceipt

> Source: src/Domain/Entities/tbl_SALOrderReceipt.cs (read 2026-05-13)
> Namespace: HoaiMinh.ERP.Domain.Entities
> Table: tbl_SALOrderReceipt
> FK Navigation: tbl_SALOrderMaster (via OrderMaster)

## Columns (exact C# names -- use THESE in anonymous type projection)

| Column | C# Type | Nullable | Notes |
|--------|---------|----------|-------|
| Code | long | NO | PK |
| Head | long | NO | Tenant filter -- MUST filter .Where(x => x.Head == currentUser.CompanyId) |
| OrderMaster | long | NO | FK to tbl_SALOrderMaster |
| ReceiptNo | string | YES | Receipt number (human-readable ID) |
| ReceiptSerial | string | YES | Receipt serial |
| EffDate | DateTime? | YES | Effective date |
| Cashier | int | NO | FK to tbl_HREmployee.Code |
| Customer | long? | YES | FK to tbl_CSLoyalCustomer.Code (nullable) |
| CustomerName | string | YES | Denormalized customer name |
| CellPhone | string | YES | Customer phone -- NEVER project as "Phone" |
| Address | string | YES | Customer address |
| PaymentMethod | int | NO | Stores TypeOfList from tbl_LSList WHERE TypeData=6. Verified values: 1=Tiền mặt, 2=Chuyển khoản |
| Description | string | YES | Notes/description |
| CollectedAmount | double | NO | Amount collected -- type is double NOT decimal |
| Signature | string | YES | Signature data |
| Status | int | NO | Status value (from tbl_LSStatus) |
| TypeData | int | NO | Sub-type discriminator |
| CreatedTime | DateTime? | YES | ⚠️ NOT CreateTime |
| CreatedBy | string | YES | ⚠️ NOT CreateBy |
| LastModifiedTime | DateTime? | YES | |
| LastModifiedBy | string | YES | |

## Navigation Properties (exclude from projection)

| Property | Type | FK Column |
|----------|------|-----------|
| tbl_SALOrderMaster | tbl_SALOrderMaster? | OrderMaster |

## Anonymous Type Projection Example

```csharp
.Select(s => new
{
    s.Code,
    s.Head,
    s.OrderMaster,
    s.ReceiptNo,
    s.ReceiptSerial,
    s.EffDate,
    s.Cashier,
    s.Customer,
    s.CustomerName,
    s.CellPhone,       // NOT Phone, NOT CustomerPhone
    s.Address,
    s.PaymentMethod,
    s.Description,
    s.CollectedAmount, // double, NOT decimal
    s.Signature,
    s.Status,
    s.TypeData,
    s.CreatedTime,
    s.CreatedBy,
    s.LastModifiedTime,
    s.LastModifiedBy,
    // Joined fields (custom DTO extension):
    CashierName = s.tbl_SALOrderMaster != null ? ... : null,
    OrderID = s.tbl_SALOrderMaster != null ? s.tbl_SALOrderMaster.ID : null,
})
```

## Payment Method Lookup (tbl_LSList)

PaymentMethod stores TypeOfList value from tbl_LSList where TypeData=6:
- TypeOfList=1 → Code=9, ListName="Tiền mặt" (Cash)
- TypeOfList=2 → Code=10, ListName="Chuyển khoản" (Transfer)

FE dropdown to load payment methods: call GetListLSList with filter TypeData=6.
Use TypeOfList as valueField, ListName as textField.

## Common Errors BA/BE Agents Make (DO NOT REPEAT)

| Wrong | Correct |
|-------|---------|
| `CreateBy = currentUser.FullName` | `CreatedBy = currentUser.FullName` |
| `CreateTime = DateTime.Now` | `CreatedTime = DateTime.Now` |
| `Cashier: int?` (nullable) | `Cashier: int` (NOT nullable) |
| `CollectedAmount: double?` (nullable) | `CollectedAmount: double` (NOT nullable) |
| `PaymentMethod: int?` (nullable) | `PaymentMethod: int` (NOT nullable) |
| `s.Phone` | `s.CellPhone` |
| Missing ReceiptNo, ReceiptSerial, EffDate | Include ALL columns above |
| Missing Customer, Address, Description | Include ALL columns above |
| `CollectedAmount: decimal` | `CollectedAmount: double` |
