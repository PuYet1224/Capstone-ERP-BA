# Hoai Minh ERP - BE Coding Standards

> **Target Stack:** .NET 10 LTS (supported until May 2028), Minimal API, VSA (Vertical Slice Architecture), CQRS (MediatR 12), EF Core 10, C# 14
> **Cache Strategy:** IDistributedCache interface - Redis impl for production, MemoryCache impl for local dev
> **MANDATORY:** BA Guide MUST include all sections from this file for every BE feature.
---

## 1. API NAMING - ONLY 4 PREFIXES (COMPANY LAW)

> This is an immutable rule for Hoai Minh ERP architecture.

| Prefix | Meaning | Examples | Notes |
|---|---|---|---|
| `GetList` | Get paginated/filtered list | `GetListSALReceipt`, `GetListCSWorkOrder` | Always returns paged data |
| `Get` | Get single record by key | `GetSALReceipt`, `GetCSWorkOrder` | Returns single record |
| `Update` | Create **or** update | `UpdateSALReceipt`, `UpdateSALReceiptStatus` | Code=0  INSERT, Code>0  UPDATE |
| `Delete` | Delete | `DeleteSALReceipt` | Soft delete preferred |

**ABSOLUTELY FORBIDDEN:**
```
 Create, Insert, Add (use Update instead)
 Cancel, Complete, Approve, Reject (use UpdateXxxStatus instead)
 Set, Patch, Put, Post (use Update)
 Remove (use Delete)
```

**Pattern for status changes:**
```
UpdateSALReceiptStatus    change receipt status
UpdateCSWorkOrderStatus   approve / reject / cancel work order
UpdateSALOrderStatus      cancel / complete order
```

---

## 2. DTO NAMING PATTERN

> DTO name MUST match the DB table name. `tbl_SALOrderReceipt` → `DTOSALOrderReceipt`.

### DTO Location: `src/Domain/DTO/` (NEVER in Feature folders)

| Pattern | Usage | Example | File |
|---|---|---|---|
| `DTO{Table}` | Base DTO - ALL columns from DB table | `DTOSALOrderReceipt` | `src/Domain/DTO/DTOSALOrderReceipt.cs` |
| `DTO{Table}Cus` | Custom DTO - joined/computed fields | `DTOSALOrderReceiptCus` | `src/Domain/DTO/DTOSALOrderReceiptCus.cs` |

### Namespace: `namespace HM_ERP.DTO`

**Base DTO (mirrors DB table columns):**
```csharp
// File: src/Domain/DTO/DTOSALOrderReceipt.cs
namespace HM_ERP.DTO
{
    public class DTOSALOrderReceipt
    {
        public long Code { get; set; }            // PK
        public long Head { get; set; }             // branch
        public long OrderMaster { get; set; }      // FK
        public Nullable<int> Cashier { get; set; } // FK tbl_HREmployee
        public Nullable<double> CollectedAmount { get; set; }
        public Nullable<int> PaymentMethod { get; set; }
        public int Status { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<DateTime> CreatedTime { get; set; }
        // ... ALL other columns from DB
    }
}
```

**Custom DTO (joined/computed fields only):**
```csharp
// File: src/Domain/DTO/DTOSALOrderReceiptCus.cs
namespace HM_ERP.DTO
{
    public class DTOSALOrderReceiptCus : DTOSALOrderReceipt
    {
        public string StatusName { get; set; }     // joined from tbl_LSStatus
        public string CashierName { get; set; }    // joined from tbl_HREmployee
        public string CustomerName { get; set; }   // joined from tbl_CSLoyalCustomer
        // ... only joined/computed fields
    }
}
```

### 🔴 BANNED
```
❌ public record XxxResponse(...)        → use class with { get; set; }
❌ DTO inside Feature folder             → always src/Domain/DTO/
❌ DTO name ≠ table name                 → DTOSALOrderReceipt = tbl_SALOrderReceipt
❌ Inventing names like SALPaymentOrder  → match EXACT table name
```

---

## 3. PROJECT ARCHITECTURE - VSA (1 File Per Handler, FLAT)

> Each handler = 1 .cs file containing BOTH the Record and Handler class.
> Feature folders are FLAT — NO subfolders (no Constants/, no Endpoints.cs).

```
modules/MTB/
├── Features/
│   └── M.Sale/
│       └── F.Receipt/              ← FLAT folder, no subfolders
│           ├── GetListSALReceipt.cs     (Record + Handler in 1 file)
│           ├── GetSALReceipt.cs
│           ├── UpdateSALReceipt.cs
│           ├── UpdateSALReceiptStatus.cs
│           └── DeleteSALReceipt.cs
├── MtbModuleConfig.cs              ← endpoint registration

src/Domain/
├── DTO/
│   ├── DTOSALOrderReceipt.cs       ← base DTO (DB columns)
│   └── DTOSALOrderReceiptCus.cs    ← custom DTO (joined fields)
├── ENUM/
│   └── ENUMSALOrderReceiptStatus.cs ← status enum
```

### 🔴 BANNED structure
```
❌ Feature/Endpoints.cs             → register in MtbModuleConfig.cs instead
❌ Feature/Constants/               → use src/Domain/ENUM/
❌ Feature/{Feature}Dto.cs          → use src/Domain/DTO/
❌ Separate Query.cs + Handler.cs   → combine in 1 file
```

---

## 4. ENDPOINT PATTERN (Minimal API - .NET 10)

```csharp
// {Feature}Endpoints.cs
public static class {Feature}Endpoints
{
    public static IEndpointRouteBuilder Map{Feature}Endpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/v1/{module}/{feature}")
            .RequireAuthorization()
            .WithTags("{Feature}");

        group.MapPost("/list",   (IMediator m, {Feature}FilterRequest req, CancellationToken ct)
            => m.Send(new GetList{Feature}Query(req), ct))
            .WithName("GetList{Feature}");

        group.MapPost("/detail", (IMediator m, {Feature}CusRequest req, CancellationToken ct)
            => m.Send(new Get{Feature}Query(req), ct))
            .WithName("Get{Feature}");

        group.MapPost("/save",   (IMediator m, {Feature}SaveRequest req, CancellationToken ct)
            => m.Send(new Update{Feature}Command(req), ct))
            .WithName("Update{Feature}");

        group.MapPost("/status", (IMediator m, UpdateStatusRequest<{Feature}CusRequest> req, CancellationToken ct)
            => m.Send(new UpdateStatus{Feature}Command(req), ct))
            .WithName("Update{Feature}Status");

        group.MapPost("/delete", (IMediator m, {Feature}CusRequest req, CancellationToken ct)
            => m.Send(new Delete{Feature}Command(req), ct))
            .WithName("Delete{Feature}");

        return app;
    }
}
```

---

## 5. HANDLER PATTERN - GetList (Reference: GetListSALMaster.cs)

> Follow the EXISTING handler pattern from `modules/MTB/Features/M.Sale/F.Consult/GetListSALMaster.cs`.
> Record + Handler in SAME file. Uses `dynamic Param`. Uses `IMemoryCache` or `HybridCache`.

```csharp
// File: GetListSALReceipt.cs (Record + Handler in 1 file)
using HM_ERP.DTO;
using HoaiMinh.ERP.Infrastructure.Persistence;
using HoaiMinh.ERP.Shared.Abstractions;
using HoaiMinh.ERP.Shared.Responses;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace HoaiMinh.ERP.Modules.Sale.Features.M.Sale.F.Receipt;

public sealed record GetListSALReceiptQuery(dynamic Param) : IRequest<ApiResponse<object>>;

public sealed class GetListSALReceiptHandler : IRequestHandler<GetListSALReceiptQuery, ApiResponse<object>>
{
    private readonly HoaiMinhDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IMemoryCache _cache;

    public GetListSALReceiptHandler(HoaiMinhDbContext db, ICurrentUserService currentUser, IMemoryCache cache)
    {
        _db = db;
        _currentUser = currentUser;
        _cache = cache;
    }

    public async Task<ApiResponse<object>> Handle(
        GetListSALReceiptQuery request, CancellationToken ct)
    {
        long headId = _currentUser.CompanyId; // HEAD filter — MANDATORY

        var data = await _db.SALOrderReceipts
            .Where(w => w.Head == headId)
            .OrderByDescending(o => o.CreatedTime)
            .AsNoTracking()
            .Select(s => new
            {
                s.Code,
                s.ReceiptNo,
                s.CollectedAmount,
                s.PaymentMethod,
                s.Status,
                StatusName = s.tbl_LSStatus != null ? s.tbl_LSStatus.StatusName ?? "" : "",
                CashierName = s.tbl_HREmployee != null ? s.tbl_HREmployee.StaffID ?? "" : "",
            })
            .ToListAsync(ct);

        return ApiResponse<object>.Ok(data);
    }
}
```

---

## 6. HANDLER PATTERN - Update (Create or Update)

```csharp
// Update{Feature}Handler.cs
public class Update{Feature}Handler(HoaiMinhDbContext db, ICurrentUserService currentUser, IDistributedCache cache)
    : IRequestHandler<Update{Feature}Command, ApiResponse<object>>
{
    public async Task<ApiResponse<object>> Handle(Update{Feature}Command request, CancellationToken ct)
    {
        var req = request.Data;

        // VALIDATION
        if (req.CollectedAmount <= 0)
            return ApiResponse<object>.BadRequest("Amount must be greater than 0");

        tbl_{PrimaryTable}? entity;

        if (req.Code == 0) // CREATE
        {
            entity = new tbl_{PrimaryTable}
            {
                // Auto-generated sequence number (NOT manual concat)
                ReceiptNo = await _sysIncreaseService.NextAsync("{PREFIX}", ct),
                Head = currentUser.HeadCode,         // MANDATORY - never hardcode
                Cashier = currentUser.EmployeeCode,   // MANDATORY
                CreatedBy = currentUser.UserName,
                CreatedDate = DateTime.UtcNow,
                Status = {Feature}Status.New,
                IsDeleted = false
            };
            db.{PrimaryTable}s.Add(entity);
        }
        else // UPDATE
        {
            entity = await db.{PrimaryTable}s
                .FirstOrDefaultAsync(x => x.Code == req.Code && !x.IsDeleted, ct);

            if (entity == null) return ApiResponse<object>.NotFound("{Feature} not found");

            // Status guard - only editable in certain statuses
            if (entity.Status != {Feature}Status.New)
                return ApiResponse<object>.BadRequest("Can only edit in New status");

            entity.UpdatedBy = currentUser.UserName;
            entity.UpdatedDate = DateTime.UtcNow;
        }

        // Map fields
        entity.CollectedAmount = req.CollectedAmount;
        entity.PaymentType = req.PaymentType;
        entity.Note = req.Note;

        await db.SaveChangesAsync(ct);

        // Invalidate Redis cache
        // await cache.RemoveAsync($"{module}:{feature}:list:*", ct);

        return ApiResponse<object>.Ok(new { entity.Code, entity.ReceiptNo });
    }
}
```

---

## 7. STATUS ENUM PATTERN

> Status enums go in `src/Domain/ENUM/`, NOT in Feature folders.
> ENUM name MUST match table name: `tbl_SALOrderReceipt` → `ENUMSALOrderReceiptStatus`

```csharp
// File: src/Domain/ENUM/ENUMSALOrderReceiptStatus.cs
namespace HM_ERP.DTO
{
    public enum ENUMSALOrderReceiptStatus
    {
        New = 1,        // tbl_LSStatus TypeOfStatus=1
        Success = 2,    // tbl_LSStatus TypeOfStatus=2
        Canceled = 3,   // tbl_LSStatus TypeOfStatus=3
    }
}
```

### 🔴 BANNED
```
❌ public static class ReceiptStatus { ... }  → use enum, not static class
❌ Placing enum in Feature folder             → always src/Domain/ENUM/
❌ Naming without ENUM prefix                 → ENUMSALOrderReceiptStatus
```

---

## 8. SHARED APIs (APICORE) - MUST USE, DO NOT RE-IMPLEMENT

> These are shared APIs for the entire system. BA MUST document which ones each feature uses.

| API Name | Module | Returns | When to use |
|---|---|---|---|
| `GetListEmployee` | CORE | Employee list (EmployeeCode, FullName) | Cashier picker, Assigned picker |
| `GetListHead` | CORE | Branch list (HeadCode, HeadName) | Branch filter (admin only) |
| `GetListWarehouse` | CORE | Warehouse list (by HeadCode) | Warehouse picker |
| `GetListProvince` | CORE | Province list | Address form |
| `GetListDistrict` | CORE | District list (by Province) | Address form cascade |
| `GetListWard` | CORE | Ward list (by District) | Address form cascade |
| `GetListLSList` | CORE | Categories by TypeData | Category dropdowns |
| `GetListStatus` | CORE | Statuses by TypeData | Status filter dropdown |
| `GetListPartnerCustomer` | CORE | Customer list | Customer picker |
| `GetListSupplier` | CORE | Supplier list | Supplier picker |
| `ExportExcel` | CORE | Excel file | Export button |
| `ExportExcelPDF` | CORE | PDF file | Print/Export PDF |
| `UploadImage` | CORE | Image URL | Image upload |
| `DeleteImage` | CORE | Success/fail | Image delete |

---

## 9. VALIDATION RULES

```csharp
// Rule 1: Never accept Code < 0
if (request.Code < 0) return ApiResponse<object>.BadRequest("Invalid code");

// Rule 2: HEAD filter - MANDATORY on all list queries
.Where(x => x.Head == currentUser.CompanyId)

// Rule 3: Status transition guard
var allowedFrom = new[] { {Feature}Status.New };
if (!allowedFrom.Contains(entity.Status))
    return ApiResponse<object>.BadRequest($"Cannot perform action from status: {entity.StatusName}");

// Rule 4: Audit fields - NEVER hardcode
entity.Head = currentUser.CompanyId;
entity.CreatedBy = currentUser.UserCode;
entity.UpdatedBy = currentUser.UserCode;

// Rule 5: No magic numbers
//  if (entity.Status == 1)
//  if (entity.Status == {Feature}Status.New)
```

---

## 10. REDIS / CACHE STRATEGY - OPTIMAL APPROACH

> **Golden rule:** Always use `IDistributedCache` interface. Never hardcode implementation.
> Production: configure Redis in DI. Local dev: swap with MemoryCache - NO business logic changes.

```csharp
// DI Registration (Program.cs):
// PRODUCTION - Redis:
builder.Services.AddStackExchangeRedisCache(opt =>
    opt.Configuration = builder.Configuration.GetConnectionString("Redis"));

// LOCAL DEV - swap this for Redis (no handler code changes):
// builder.Services.AddDistributedMemoryCache(); //  comment/uncomment to switch
```

### .NET 10 HybridCache (Recommended - latest .NET 10)
```csharp
// HybridCache - replaces both IDistributedCache + IMemoryCache in .NET 10:
// L1 (in-process memory) + L2 (Redis) automatic - stampede protection built-in
builder.Services.AddHybridCache();

// Handler:
public class GetList{Feature}Handler(HoaiMinhDbContext db, HybridCache hybridCache) : IRequestHandler<...>
{
    public async Task<...> Handle(..., CancellationToken ct)
    {
        var cacheKey = $"{module}:{feature}:{HashFilter(filter)}";
        return await hybridCache.GetOrCreateAsync(cacheKey,
            async token => await QueryDatabase(filter, token),
            new HybridCacheEntryOptions { Expiration = TimeSpan.FromMinutes(5) },
            cancellationToken: ct);
    }
}

// Invalidate: use tags
await hybridCache.RemoveByTagAsync($"{module}:{feature}", ct);
```

> **Best Practice:** Use **HybridCache** (.NET 10 built-in) - auto-manages both memory + Redis (L1+L2), stampede-safe, invalidate by tags. No need to choose between IMemoryCache and IDistributedCache.

---

## 11. ERROR RESPONSE PATTERN (.NET 10)

```csharp
// Always use ApiResponse<T> wrapper:
return ApiResponse<object>.Ok(data);               // 200
return ApiResponse<object>.BadRequest("message");  // 400
return ApiResponse<object>.NotFound("message");    // 404
return ApiResponse<object>.Unauthorized();         // 401
return ApiResponse<object>.Forbidden("message");   // 403

// NEVER return raw exception messages to client
// ALWAYS catch and translate to ApiResponse
```

---

## 12. C# 14 PATTERNS TO USE - .NET 10 STABLE ONLY

> **Version Decision:**
> -  **.NET 10 LTS + C# 14**  Use for all production code
> -  **.NET 11 Preview 3 + C# 15**  Not released, DO NOT use

| Pattern | C# Version | Status | Allowed? |
|---|---|---|---|
| `field` keyword in properties | C# 14 |  Stable |  Yes |
| Null-conditional assignment `?=` | C# 12+ |  Stable |  Yes |
| Primary constructors | C# 12 |  Stable |  Yes |
| Collection expressions `[a, b, c]` | C# 12 |  Stable |  Yes |
| `required` properties in records | C# 11 |  Stable |  Yes |
| Pattern matching switch expressions | C# 8+ |  Stable |  Yes |
| EF Core 10 native LeftJoin | .NET 10 |  Stable |  Yes |
| ExecuteUpdate / ExecuteDelete | EF Core 7+ |  Stable |  Yes |
| HybridCache | .NET 10 |  Stable |  Yes |
| Union types `public union X(A,B)` | C# 15 |  Preview |  No |
| Collection expression `with(...)` | C# 15 |  Preview |  No |

---

## 13. HEAD FILTER - MANDATORY RULE

```
HEAD-01: All list queries MUST filter by Head (branch) of current user.
HEAD-02: On create, Head MUST come from ICurrentUserService - NEVER accept from request body.
HEAD-03: Admin role can view all branches (isAll = true parameter).

BA Guide MUST explicitly note:
"All GetList handlers MUST include .Where(x => x.Head == currentUser.HeadCode)"
```

---

## 14. BA GUIDE REQUIREMENTS - Mandatory Sections

> BA MUST include ALL of the following in every BE Guide:

```
S1  Overview + Performance targets (response times from SRS NFR-P)
S2  API Contract Table (all 5 endpoints with DTO names)
S3  DTO Definitions (Save, Cus, Filter, Response - with field types)
S4  Status Constants (mapped to tbl_LSStatus TypeData value)
S5  Handler Logic (step-by-step for each handler)
S6  Shared APIs Required (which CORE APIs to call, and when)
S7  Redis Cache Strategy (key pattern, TTL, invalidation trigger)
S8  Validation Rules (citing SRS AC-xx)
S9  Error Responses (all error scenarios)
S10 File Location (exact path in VSA folder structure)
S11 HEAD Filter note (MANDATORY reminder)
S12 Pending Decisions (from SRS TBD items)
```
