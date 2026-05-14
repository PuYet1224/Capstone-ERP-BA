# Entity Snapshot: tbl_SALOrderDetail

> Source: src/Domain/Entities/tbl_SALOrderDetail.cs (read 2026-05-13)
> Table: tbl_SALOrderDetail
> FK Navigation: tbl_SALOrderMaster (Master), tbl_LSStatus x2, tbl_HREmployee x2, tbl_CSVehicle, tbl_LSVehicleColor

## Columns

| Column | C# Type | Nullable | Notes |
|--------|---------|----------|-------|
| Code | long | NO | PK |
| Master | long | NO | FK -> tbl_SALOrderMaster |
| CSVehicle | long? | YES | FK -> tbl_CSVehicle |
| Price | double? | YES | NOT decimal |
| VAT | double? | YES | |
| RegisterDate | DateTime? | YES | |
| RegisterStaff | int? | YES | FK -> tbl_HREmployee |
| PlateDeliveryDate | DateTime? | YES | |
| TechnicalStaff | int? | YES | FK -> tbl_HREmployee |
| DeliveryStatus | int? | YES | FK -> tbl_LSStatus |
| DeliveryDate | DateTime? | YES | |
| CreatedBy | string? | YES | |
| CreatedTime | DateTime? | YES | |
| LastModifiedBy | string? | YES | |
| LastModifiedTime | DateTime? | YES | |
| TypeData | int? | YES | |
| OrderBy | int? | YES | |
| VehicleColor | long? | YES | FK -> tbl_LSVehicleColor |
| Status | int? | YES | FK -> tbl_LSStatus |
| IsPaid | bool? | YES | |
| Owner | long? | YES | |
| PaymentType | int? | YES | FK -> tbl_LSList |
| FinanceCompany | long? | YES | FK -> tbl_LSTypeOfPartner |
| InstallmentTerm | int? | YES | |
| InterestRate | double? | YES | |
| ContractID | string? | YES | |
| TypeOfVehicleName | string? | YES | Denormalized |
| VehicleName | string? | YES | Denormalized |
| VehicleColorName | string? | YES | Denormalized |
| IsCompare | bool? | YES | |
| IsFollow | bool? | YES | |
| IsLock | bool? | YES | |
| Warehouse | long? | YES | |
| HeadTransfer | long? | YES | |
| SIODetailVehicle | long? | YES | |
| DepositAmount | double? | YES | |
| DiscountAmount | double? | YES | [NotMapped] -- calculate, not stored |
| TransferCSVehicle | long? | YES | [NotMapped] |
| WHOut | long? | YES | [NotMapped] |
| WHIn | long? | YES | [NotMapped] |

## Navigation Properties (exclude from projection)

| Property | Type | FK Column |
|----------|------|-----------|
| tbl_LSVehicleColor | tbl_LSVehicleColor? | VehicleColor |
| tbl_SALOrderMaster | tbl_SALOrderMaster? | Master |
| tbl_LSStatus1 | tbl_LSStatus? | Status |
| tbl_LSList | tbl_LSList? | PaymentType |
| tbl_LSTypeOfPartner | tbl_LSTypeOfPartner? | FinanceCompany |
| tbl_CSVehicle | tbl_CSVehicle? | CSVehicle |
| tbl_LSStatus | tbl_LSStatus? | DeliveryStatus |
| tbl_HREmployee | tbl_HREmployee? | RegisterStaff |
| tbl_HREmployee1 | tbl_HREmployee? | TechnicalStaff |
| tbl_SALOrderDetailService | ICollection | - |
| tbl_SALOrderDetailPartItem | ICollection | - |
| tbl_SALOrderDetailPromotion | ICollection | - |

## CRITICAL NOTES

- **NO `Head` column** -- this is a detail table, no tenant filter needed (filter via Master join)
- Price/VAT/DepositAmount/InterestRate are all `double` NOT `decimal`
- `DiscountAmount`, `TransferCSVehicle`, `WHOut`, `WHIn` are `[NotMapped]` -- NOT stored in DB

## Common Errors

| Wrong | Correct |
|-------|---------|
| `Price: decimal` | `Price: double` |
| Include DiscountAmount in INSERT | Skip [NotMapped] columns in INSERT |
