# Existing API Patterns - Hoai Minh ERP

> BA MUST reference this file when writing BE_Guide.md.
> These are the ACTUAL patterns used in the codebase. DO NOT invent new patterns.

## Tech Stack

- .NET 10, Minimal API, EF Core 10, MediatR (CQRS)
- DB: SQL Server (Code-First, reverse-engineered from legacy DB)
- Auth: JWT Bearer from external identity.hoaiminh.vn

## Project Structure

```
modules/MTB/Features/
-- GetListVehicle.cs               Shared across modules
-- F.Config/                       Config features (CRUD vehicles, colors)
|   -- DeleteTypeOfVehicle.cs
|   -- UpdateVehicle.cs
|   -- UpdateVehicleColor.cs
-- M.Sale/                         Sale module features
|   -- GetSaleOverview.cs
|   -- GetListSALMaster.cs
|   -- UpdateSALMaster.cs
|   -- GetListSALInvoice.cs
|   -- UpdateSALReceipt.cs
|   -- F.Consult/                  Sub-feature
|       -- GetSALMaster.cs
-- M.Warehouse/                    Warehouse module
|   -- F.DeliveryOrder/
|       -- GetListDOMaster.cs
|       -- UpdateDOMaster.cs
-- M.Repair/                       Repair/Service module
    -- F.Consult/
    -- F.Task/
```

## CQRS Pattern (MediatR)

### Query (GET operations)
```csharp
// Record = query definition
public record GetListSALMasterQuery(dynamic Payload) : IRequest<ApiResponse<object>>;

// Handler = business logic
public class GetListSALMasterHandler : IRequestHandler<GetListSALMasterQuery, ApiResponse<object>>
{
    private readonly HoaiMinhDbContext _db;
    public GetListSALMasterHandler(HoaiMinhDbContext db) => _db = db;

    public async Task<ApiResponse<object>> Handle(GetListSALMasterQuery request, CancellationToken ct)
    {
        var data = await _db.SALOrderMasters
            .AsNoTracking()
            .Select(x => new { x.Code, x.ID, x.SaleDate })
            .ToListAsync(ct);

        return ApiResponse<object>.Ok(data);
    }
}
```

### Command (POST/PUT/DELETE operations)
```csharp
public record UpdateSALMasterCommand(dynamic Payload) : IRequest<ApiResponse<object>>;

public class UpdateSALMasterHandler(HoaiMinhDbContext db) 
    : IRequestHandler<UpdateSALMasterCommand, ApiResponse<object>>
{
    public async Task<ApiResponse<object>> Handle(UpdateSALMasterCommand request, CancellationToken ct)
    {
        // Business logic here
        return ApiResponse<object>.Ok(result);
    }
}
```

## Response Wrapper

ALL endpoints return `ApiResponse<object>`:
```csharp
// Success
return ApiResponse<object>.Ok(data);
return ApiResponse<object>.Ok(new { Message = "Created successfully" });

// Error
return ApiResponse<object>.BadRequest("Validation failed");
return ApiResponse<object>.NotFound("Order not found");
```

## Naming Conventions

### ONLY 4 PREFIXES ALLOWED (NO EXCEPTIONS):

| Prefix | Meaning | Example |
|:-------|:--------|:-------|
| **Get** | Fetch data (single or list) | `GetSALReceipt`, `GetListSALMaster` |
| **Update** | Create, edit, or change status | `UpdateSALReceipt`, `UpdateSALReceiptStatus` |
| **Delete** | Delete | `DeleteSODetail`, `DeleteSALPartItem` |
| **Add** | Add item to collection with field | `AddSALSelectedVehicles` |

### FORBIDDEN PREFIXES (ABSOLUTELY DO NOT USE):

| Forbidden | Replace with | Reason |
|:----------|:------------|:-------|
| ~~Create~~ | **Update** | Create = Update with Code=0 (insert), Code>0 (update) |
| ~~Cancel~~ | **Update...Status** | Cancel = status change -> `UpdateSALReceiptStatus` |
| ~~Complete~~ | **Update...Status** | Complete = status change -> `UpdateSALReceiptStatus` |
| ~~Insert~~ | **Update** or **Add** | Do not use Insert |
| ~~Remove~~ | **Delete** | Do not use Remove |
| ~~Set~~ | **Update** | Do not use Set |
| ~~Patch~~ | **Update** | Do not use Patch |

### Naming Rules

| Type | Pattern | Example |
|:---|:---|:---|
| Query record | `Get{Action}Query` | `GetListSALMasterQuery` |
| Command record | `Update{Entity}Command` | `UpdateSALReceiptCommand` |
| Status command | `Update{Entity}StatusCommand` | `UpdateSALReceiptStatusCommand` |
| Handler class | `{Action}Handler` | `GetListSALMasterHandler` |
| File name | `{Action}.cs` | `GetListSALMaster.cs` |
| Namespace | `HoaiMinh.ERP.Modules.Sale.Features.{Module}` | |

### Example mapping:
```
Create receipt        -> UpdateSALReceipt (Code=0 -> insert, Code>0 -> update)
Cancel receipt        -> UpdateSALReceiptStatus (Status = ReceiptStatus.Cancelled)
Complete receipt      -> UpdateSALReceiptStatus (Status = ReceiptStatus.Completed)
Get list              -> GetListSALReceipt
Get detail            -> GetSALReceipt
Delete receipt        -> DeleteSALReceipt
```

## Key Namespaces

```csharp
using HoaiMinh.ERP.Infrastructure.Persistence;  // HoaiMinhDbContext
using HoaiMinh.ERP.Shared.Responses;             // ApiResponse<T>
using MediatR;                                     // IRequest, IRequestHandler
using Microsoft.EntityFrameworkCore;               // AsNoTracking, ToListAsync
```

## DbContext DbSet Naming

Entity tables map to DbSet with prefix removed:
- `tbl_SALOrderMaster` -> `_db.SALOrderMasters`
- `tbl_LSVehicle` -> `_db.LSVehicles`
- `tbl_CSWorkOrderMaster` -> `_db.CSWorkOrderMasters`

## Performance Rules for BE_Guide

1. ALWAYS use `.AsNoTracking()` for read-only queries
2. ALWAYS use `.Select()` projection - NEVER return full entity to client
3. Use `CancellationToken ct` in all async methods
4. Primary constructor `Handler(HoaiMinhDbContext db)` for simple DI

## Existing Feature List (95 handlers as of April 2026)

### M.Sale (28 handlers)
GetListSALMaster, GetSALMaster, UpdateSALMaster, UpdateSALMasterStatus,
GetListSALInvoice, GetSALInvoice, UpdateSALInvoice, UpdateSALInvoiceInfo,
GetListSALReceipt, GetSALReceipt, UpdateSALReceipt, UpdateSALReceiptDetail,
GetListSALOrderItem, GetListSALPartVehicle, GetListSALService, GetListSALPromotion,
GetListSALSelectedVehicle, AddSALSelectedVehicles, DeleteSALSelectedVehicles,
UpdateSALSelectedVehicleLock, GetListSALPaymentList, GetSALPayment,
GetListSALCollection, GetSaleOverview, UpdateSALDetail, DeleteSALDetail,
UpdateSALPartItem, DeleteSALPartItem, UpdateSALService, UpdateSALPromotion,
PrintReceipt, GetCustomer, UpdateLoyalCustomer

### M.Warehouse (12 handlers)
GetListDOMaster, GetDOMaster, UpdateDOMaster, UpdateDOMasterStatus,
GetListDODetail, UpdateDODetail, DeleteDODetail, ImportDODetail,
GetListIOMasterVehicle, GetIOMasterVehicle, UpdateIOMasterVehicle,
UpdateIOMasterVehicleStatus, GetListIODetailVehicle, UpdateIODetailVehicle,
DeleteIODetailVehicle, GetIOSeri, GetIOSeriInternal

### M.Repair (8 handlers)
GetListWOMConsultant, GetWOMConsultant, UpdateWOMConsultant, DeleteWOMConsultant,
GetListWOTask, UpdateWOTask, DeleteWOTask, GetListServiceMaster,
GetListTaskBank, GetWOMVehicle, UpdateWOMVehicle, GetListWOMCustomer,
UpdateWOMCustomer

### F.Config (7 handlers)
GetListVehicle, GetListVehicleConfig, GetListVehicleOptions, GetListColor,
UpdateVehicle, DeleteVehicle, UpdateVehicleColor, DeleteVehicleColor,
UpdateTypeOfVehicle, DeleteTypeOfVehicle, GetListVehicleColorCodeImage,
GetListVehicleSettingImage, GetListVehicleReceipt

## DEPRECATED Patterns (DO NOT USE for NEW code)

The following patterns exist in LEGACY handlers but MUST NOT be used for new features:

### `dynamic Payload` - DEPRECATED
```csharp
// OLD pattern (only in existing ~95 handlers) - DO NOT COPY
public record GetListSALMasterQuery(dynamic Payload) : IRequest<ApiResponse<object>>;
```

### Typed Record - USE THIS for all new handlers
```csharp
// NEW pattern - MANDATORY for all new features
public record GetListSALReceiptQuery(
    int? Status,
    long? OrderMasterCode,
    int Page = 1,
    int PageSize = 20
) : IRequest<ApiResponse<object>>;
```

> **Rule:** Legacy handlers with `dynamic Payload` are accepted as-is.
> All NEW handlers MUST use typed records. See `11-coding-standards.md` for full rules.
