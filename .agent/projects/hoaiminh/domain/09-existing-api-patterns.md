# Existing API Patterns â€” HoÃ i Minh ERP

> BA MUST reference this file when writing BE_Guide.md.
> These are the ACTUAL patterns used in the codebase. DO NOT invent new patterns.

## Tech Stack

- .NET 10, Minimal API, EF Core 10, MediatR (CQRS)
- DB: SQL Server (Code-First, reverse-engineered from legacy DB)
- Auth: JWT Bearer from external identity.hoaiminh.vn

## Project Structure

```
modules/MTB/Features/
â”œâ”€â”€ GetListVehicle.cs              â† Shared across modules
â”œâ”€â”€ F.Config/                      â† Config features (CRUD vehicles, colors)
â”‚   â”œâ”€â”€ DeleteTypeOfVehicle.cs
â”‚   â”œâ”€â”€ UpdateVehicle.cs
â”‚   â””â”€â”€ UpdateVehicleColor.cs
â”œâ”€â”€ M.Sale/                        â† Sale module features
â”‚   â”œâ”€â”€ GetSaleOverview.cs
â”‚   â”œâ”€â”€ GetListSALMaster.cs
â”‚   â”œâ”€â”€ UpdateSALMaster.cs
â”‚   â”œâ”€â”€ GetListSALInvoice.cs
â”‚   â”œâ”€â”€ UpdateSALReceipt.cs
â”‚   â””â”€â”€ F.Consult/                 â† Sub-feature
â”‚       â””â”€â”€ GetSALMaster.cs
â”œâ”€â”€ M.Warehouse/                   â† Warehouse module
â”‚   â””â”€â”€ F.DeliveryOrder/
â”‚       â”œâ”€â”€ GetListDOMaster.cs
â”‚       â””â”€â”€ UpdateDOMaster.cs
â””â”€â”€ M.Repair/                      â† Repair/Service module
    â”œâ”€â”€ F.Consult/
    â””â”€â”€ F.Task/
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

### ⚠️ CHỈ ĐƯỢC DÙNG 4 PREFIX SAU (KHÔNG CÓ NGOẠI LỆ):

| Prefix | Ý nghĩa | Ví dụ |
|:-------|:---------|:------|
| **Get** | Lấy data (1 item hoặc danh sách) | `GetSALReceipt`, `GetListSALMaster` |
| **Update** | Tạo mới, sửa, đổi trạng thái | `UpdateSALReceipt`, `UpdateSALReceiptStatus` |
| **Delete** | Xóa | `DeleteSODetail`, `DeleteSALPartItem` |
| **Add** | Thêm item vào collection cùng field | `AddSALSelectedVehicles` |

### ❌ CÁC PREFIX BỊ CẤM (TUYỆT ĐỐI KHÔNG DÙNG):

| Prefix cấm | Thay bằng | Lý do |
|:------------|:----------|:------|
| ~~Create~~ | **Update** | Tạo mới = Update (nếu Code=0 thì tạo, nếu có Code thì sửa) |
| ~~Cancel~~ | **Update...Status** | Hủy = đổi trạng thái → `UpdateSALReceiptStatus` |
| ~~Complete~~ | **Update...Status** | Hoàn tất = đổi trạng thái → `UpdateSALReceiptStatus` |
| ~~Insert~~ | **Update** hoặc **Add** | Không dùng Insert |
| ~~Remove~~ | **Delete** | Không dùng Remove |
| ~~Set~~ | **Update** | Không dùng Set |
| ~~Patch~~ | **Update** | Không dùng Patch |

### Quy tắc đặt tên

| Type | Pattern | Example |
|:---|:---|:---|
| Query record | `Get{Action}Query` | `GetListSALMasterQuery` |
| Command record | `Update{Entity}Command` | `UpdateSALReceiptCommand` |
| Status command | `Update{Entity}StatusCommand` | `UpdateSALReceiptStatusCommand` |
| Handler class | `{Action}Handler` | `GetListSALMasterHandler` |
| File name | `{Action}.cs` | `GetListSALMaster.cs` |
| Namespace | `HoaiMinh.ERP.Modules.Sale.Features.{Module}` | |

### Ví dụ mapping:
```
Tạo phiếu thu     → UpdateSALReceipt (Code=0 → insert, Code>0 → update)
Hủy phiếu thu     → UpdateSALReceiptStatus (Status = ReceiptStatus.Cancelled)
Hoàn tất phiếu thu → UpdateSALReceiptStatus (Status = ReceiptStatus.Completed)
Lấy danh sách     → GetListSALReceipt
Lấy chi tiết      → GetSALReceipt
Xóa phiếu thu     → DeleteSALReceipt
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
- `tbl_SALOrderMaster` â†’ `_db.SALOrderMasters`
- `tbl_LSVehicle` â†’ `_db.LSVehicles`
- `tbl_CSWorkOrderMaster` â†’ `_db.CSWorkOrderMasters`

## Performance Rules for BE_Guide

1. ALWAYS use `.AsNoTracking()` for read-only queries
2. ALWAYS use `.Select()` projection â€” NEVER return full entity to client
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

## ⚠️ DEPRECATED Patterns (DO NOT USE for NEW code)

The following patterns exist in LEGACY handlers but MUST NOT be used for new features:

### ❌ `dynamic Payload` — DEPRECATED
```csharp
// OLD pattern (only in existing ~95 handlers) — DO NOT COPY
public record GetListSALMasterQuery(dynamic Payload) : IRequest<ApiResponse<object>>;
```

### ✅ Typed Record — USE THIS for all new handlers
```csharp
// NEW pattern — MANDATORY for all new features
public record GetListSALReceiptQuery(
    int? Status,
    long? OrderMasterCode,
    int Page = 1,
    int PageSize = 20
) : IRequest<ApiResponse<object>>;
```

> **Rule:** Legacy handlers with `dynamic Payload` are accepted as-is.
> All NEW handlers MUST use typed records. See `11-coding-standards.md` for full rules.
