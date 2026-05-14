# How to Add Entity Snapshots

> When BA agent needs an entity NOT in this folder, follow these steps.

## For new features: create snapshot BEFORE running /ba-analyst

1. Find entity file: `BE_project\src\Domain\Entities\tbl_{TableName}.cs`
2. Read the .cs file
3. Create snapshot: `tbl_{TableName}.md` in this folder using template below
4. Run /ba-analyst

## Snapshot Template

```markdown
# Entity Snapshot: tbl_{TableName}

> Source: src/Domain/Entities/tbl_{TableName}.cs (read {date})
> Table: tbl_{TableName}
> FK Navigation: {list FK navigations}

## Columns

| Column | C# Type | Nullable | Notes |
|--------|---------|----------|-------|
| Code | long | NO | PK |
| Head | long | NO | Tenant filter |
| ... | ... | ... | ... |

## Navigation Properties (exclude from projection)

| Property | Type | FK Column |
|----------|------|-----------|
| {NavProp} | {EntityType}? | {FK column name} |

## Common Errors

| Wrong | Correct |
|-------|---------|
| ... | ... |
```

## Snapshots Created (as of 2026-05-13)

| Table | Status |
|-------|--------|
| tbl_SALOrderReceipt | Done |
| tbl_SALOrderReceiptDetail | Done |
| tbl_SALOrderMaster | Done |
| tbl_SALOrderDetail | Done |
| tbl_SALOrderInvoice | Done |
| tbl_CSLoyalCustomer | Done |
| tbl_HREmployee | Done |
| tbl_LSStatus | Done |

## Key Entity Files to Snapshot Next (priority order)

| Table | Path |
|-------|------|
| tbl_CSWorkOrderMaster | src/Domain/Entities/tbl_CSWorkOrderMaster.cs |
| tbl_LSPartner | src/Domain/Entities/tbl_LSPartner.cs |
| tbl_LSVehicle | src/Domain/Entities/tbl_LSVehicle.cs |
| tbl_LSVehicleColor | src/Domain/Entities/tbl_LSVehicleColor.cs |
| tbl_CSVehicle | src/Domain/Entities/tbl_CSVehicle.cs |
