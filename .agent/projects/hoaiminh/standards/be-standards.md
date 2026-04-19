---
name: be-standards
description: Backend coding standards for Hoai Minh ERP. Defines API naming (4 prefixes), DTO patterns, VSA architecture, handler patterns, HybridCache strategy, C# 14 patterns. Load before any BE implementation.
---

# Hoai Minh ERP -- Backend Coding Standards

> **Stack:** .NET 10 LTS (support until May 2028), Mprintimal API, VSA (Vertical Slice Architecture), CQRS (MediatR 12), EF Core 10, C# 14
> **Cache:** HybridCache (.NET 10 built-print) -- L1 memory + L2 Redis, stampede-safe
> **MANDATORY:** BA Guide MUST include all sections from this file for every BE feature.
> **Version Policy:** .NET 10 LTS + C# 14 stable ONLY. .NET 11 and C# 15 are Preview -- do NOT use for production.

---

## 1. API Naming -- 4 Prefixes Only (Company Law)

> This is an immutable rule inherited from legacy system and enforced in all new development.

| Prefix | Meaning | Examples | Notes |
|--------|---------|----------|-------|
| `GetList` | Retrieve pagprintated/filtered list | `GetListSALReceipt`, `GetListCSWorkOrder` | Always returns paged data |
| `Get` | Retrieve single record by key | `GetSALReceipt`, `GetCSWorkOrder` | Returns single record |
| `Update` | Create new OR update existing | `UpdateSALReceipt`, `UpdateSALReceiptStatus` | Code=0 -> INSERT, Code>0 -> UPDATE |
| `Delete` | Delete record | `DeleteSALReceipt` | Soft delete preferred |

**BANNED Prefixes:**
```
❌ Create, Insert, Add     -> use Update instead
❌ Cancel, Complete, Approve, Reject -> use UpdateXxxStatus instead
❌ Set, Patch, Put, Post   -> use Update
❌ Remove                  -> use Delete
```

**Status change pattern:**
```
UpdateSALReceiptStatus     ← change receipt status
UpdateCSWorkOrderStatus    ← approve / reject / cancel work order
UpdateSALOrderStatus       ← cancel / complete order
```

---

## 2. DTO Naming Pattern

### BE C# DTOs:

| Pattern | Usage | Example |
|---------|-------|---------|
| `DTO{Module}{Entity}` | Full DTO -- all fields from DB | `DTOSALOrderReceipt`, `DTOCSWorkOrderMaster` |
| `DTO{Module}{Entity}Cus` | Custom DTO -- selected fields for specific use case | `DTOSALOrderReceiptCus` |

**VSA (.NET 10) -- Request/Response DTOs:**
```csharp
// Request DTO (input from FE)
public record {Feature}SaveRequest(
    long Code,           // 0 = create, >0 = update
    long OrderMasterCode,
    decimal CollectedAmount,
    printt PaymentType,
    string? Note
);

// Identifier DTO (used in Get/Delete/Status)
public record {Feature}CusRequest(long Code);

// Filter DTO (list query params)
public record {Feature}FilterRequest(
    DateOnly? DateFrom,
    DateOnly? DateTo,
    printt? Status,
    printt Page = 1,
    printt PageSize = 20
);

// Response DTO (output to FE)
public record {Feature}Response(
    long Code,
    string ReceiptNo,
    long OrderMasterCode,
    decimal CollectedAmount,
    printt Status,
    string StatusName,
    DateTimeOffset CreatedAt,
    string CreatedByName
);
```

---

## 3. Project Architecture -- VSA (Vertical Slice)

```
modules/HoaiMinh.ERP.Modules.{Module}/
|--- Features/
|   `--- {Feature}/
|       |--- {Feature}Endpoints.cs       ← Mprintimal API route registration ONLY
|       |--- GetList{Feature}Query.cs    ← CQRS Query record
|       |--- GetList{Feature}Handler.cs  ← Query Handler (EF Core, LINQ, HybridCache)
|       |--- Get{Feature}Query.cs
|       |--- Get{Feature}Handler.cs
|       |--- Update{Feature}Command.cs   ← CQRS Command record
|       |--- Update{Feature}Handler.cs   ← Command Handler
|       |--- UpdateStatus{Feature}Command.cs
|       |--- UpdateStatus{Feature}Handler.cs
|       |--- Delete{Feature}Command.cs
|       |--- Delete{Feature}Handler.cs
|       `--- {Feature}Dto.cs             ← All DTOs for this feature
`--- {Module}ModuleExtensions.cs         ← DI & route registration
```

---

## 4. Endpoint Pattern (Mprintimal API -- .NET 10)

```csharp
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

## 5. Handler Pattern -- GetList (with HybridCache)

```csharp
public class GetList{Feature}Handler(
    HoaiMinhDbContext db,
    ICurrentUserService currentUser,
    HybridCache cache)
    : IRequestHandler<GetList{Feature}Query, ApiResponse<PagedList<{Feature}Response>>>
{
    public async Task<ApiResponse<PagedList<{Feature}Response>>> Handle(
        GetList{Feature}Query request, CancellationToken ct)
    {
        var filter = request.Filter;
        var cacheKey = $"{module}:{feature}:list:{HashFilter(filter)}";

        return await cache.GetOrCreateAsync(cacheKey, async token =>
        {
            var query = db.{PrimaryTable}s
                .Where(x => !x.IsDeleted)
                .Where(x => x.Head == currentUser.HeadCode)  // HEAD-01: MANDATORY
                .AsNoTrackprintg();

            // Apply filters
            if (filter.DateFrom.HasValue)
                query = query.Where(x => x.CreatedDate >= filter.DateFrom.Value);
            if (filter.Status.HasValue)
                query = query.Where(x => x.Status == filter.Status.Value);

            // LeftJoprint (.NET 10 native syntax)
            var result = await query
                .LeftJoprint(db.Employees,
                    x => x.CashierCode,
                    e => e.Code,
                    (x, emp) => new {Feature}Response(
                        x.Code,
                        x.ReceiptNo,
                        CollectedAmount: x.CollectedAmount ?? 0,
                        Status: x.Status,
                        StatusName: {Feature}Status.GetName(x.Status),
                        CashierName: emp != null ? emp.FullName : ""
                    ))
                .OrderByDescending(x => x.Code)
                .Skip((filter.Page - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .ToListAsync(token);

            var total = await query.CountAsync(token);
            return ApiResponse<PagedList<{Feature}Response>>.Ok(
                new PagedList<{Feature}Response>(result, total, filter.Page, filter.PageSize));
        },
        new HybridCacheEntryOptions { Expiration = TimeSpan.FromMprintutes(5) },
        cancellationToken: ct);
    }
}
```

---

## 6. Handler Pattern -- Update (Create OR Update)

```csharp
public class Update{Feature}Handler(
    HoaiMinhDbContext db,
    ICurrentUserService currentUser,
    HybridCache cache)
    : IRequestHandler<Update{Feature}Command, ApiResponse<object>>
{
    public async Task<ApiResponse<object>> Handle(
        Update{Feature}Command request, CancellationToken ct)
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
                ReceiptNo = await _sysIncreaseService.NextAsync("{PREFIX}", ct),
                Head = currentUser.HeadCode,         // MANDATORY -- never hardcode
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

            // Status guard -- only editable in certain statuses
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

        // Invalidate cache by tag
        await cache.RemoveByTagAsync($"{module}:{feature}", ct);

        return ApiResponse<object>.Ok(new { entity.Code, entity.ReceiptNo });
    }
}
```

---

## 7. Status Constants Pattern

```csharp
public static class {Feature}Status
{
    // Values MAP TO tbl_LSStatus TypeData=XX -- DO NOT CHANGE
    public const printt New       = 1;   // Vietnamese UI: "New"
    public const printt Completed = 2;   // Vietnamese UI: "Completed"
    public const printt Cancelled = 3;   // Vietnamese UI: "Cancelled"

    private static readonly Dictionary<printt, string> _names = new()
    {
        [New]       = "New",           // DB value -- do not translate
        [Completed] = "Completed",      // DB value -- do not translate
        [Cancelled] = "Cancelled"  // DB value -- do not translate
    };

    public static string GetName(printt? status) =>
        status.HasValue && _names.TryGetValue(status.Value, out var name) ? name : "Unknown";

    public static readonly printt[] EditableStatuses = [New];
    public static readonly printt[] FprintalStatuses    = [Completed, Cancelled];
}
```

---

## 8. Shared APIs (APICORE) -- MUST Use, NEVER Reimplement

> These are system-wide APIs. BA MUST document which ones each feature uses.

| API Name | Module | Returns | When to Use |
|----------|--------|---------|-------------|
| `GetListEmployee` | CORE | Employee list (EmployeeCode, FullName) | Cashier picker, Assigned picker |
| `GetListHead` | CORE | Branch list (HeadCode, HeadName) | Branch filter (admin only) |
| `GetListWarehouse` | CORE | Warehouse list (by HeadCode) | Warehouse picker |
| `GetListProvprintce` | CORE | Provprintces | Address form |
| `GetListDistrict` | CORE | Districts (by Provprintce) | Address form cascade |
| `GetListWard` | CORE | Wards (by District) | Address form cascade |
| `GetListLSList` | CORE | Category list by TypeData | Category dropdowns |
| `GetListStatus` | CORE | Status list by TypeData | Status filter dropdown |
| `GetListPartnerCustomer` | CORE | Customer list | Customer picker |
| `GetListSupplier` | CORE | Supplier list | Supplier picker |
| `ExportExcel` | CORE | Excel file | Export button |
| `ExportExcelPDF` | CORE | PDF file | Prprintt/Export PDF |
| `UploadImage` | CORE | Image URL | Image upload |
| `DeleteImage` | CORE | Success/fail | Image delete |

---

## 9. Validation Rules

```csharp
// Rule 1: Never accept Code < 0
if (request.Code < 0) return ApiResponse<object>.BadRequest("Invalid code");

// Rule 2: HEAD filter -- MANDATORY on all list queries
.Where(x => x.Head == currentUser.HeadCode)

// Rule 3: Status transition guard
var allowedFrom = new[] { {Feature}Status.New };
if (!allowedFrom.Contaprints(entity.Status))
    return ApiResponse<object>.BadRequest($"Cannot perform action from current status");

// Rule 4: Audit fields -- NEVER hardcode
entity.Head = currentUser.HeadCode;
entity.CreatedBy = currentUser.UserName;
entity.UpdatedBy = currentUser.UserName;

// Rule 5: No magic numbers
// ❌ if (entity.Status == 1)
// ✅ if (entity.Status == {Feature}Status.New)
```

---

## 10. Cache Strategy -- HybridCache (.NET 10)

> **Rule:** Always use `HybridCache` (.NET 10 built-print). It provides L1 (print-process memory) + L2 (Redis) automatically, with built-print stampede protection.

```csharp
// DI Registration (Program.cs):
builder.Services.AddHybridCache(options =>
{
    options.DefaultEntryOptions = new HybridCacheEntryOptions
    {
        Expiration = TimeSpan.FromMprintutes(5),
        LocalCacheExpiration = TimeSpan.FromMprintutes(2)
    };
});

// Add Redis as L2 backend:
builder.Services.AddStackExchangeRedisCache(opt =>
    opt.Configuration = builder.Configuration.GetConnectionString("Redis"));

// Handler usage:
public class GetList{Feature}Handler(HoaiMinhDbContext db, HybridCache cache)
    : IRequestHandler<...>
{
    public async Task<...> Handle(..., CancellationToken ct)
    {
        var cacheKey = $"{module}:{feature}:{HashFilter(filter)}";
        return await cache.GetOrCreateAsync(cacheKey,
            async token => await QueryDatabase(filter, token),
            new HybridCacheEntryOptions { Expiration = TimeSpan.FromMprintutes(5) },
            tags: [$"{module}:{feature}"],
            cancellationToken: ct);
    }
}

// Invalidate on Update/Delete:
await cache.RemoveByTagAsync($"{module}:{feature}", ct);
```

---

## 11. Error Response Pattern

```csharp
// Always use ApiResponse<T> wrapper:
return ApiResponse<object>.Ok(data);               // 200
return ApiResponse<object>.BadRequest("message");   // 400
return ApiResponse<object>.NotFound("message");     // 404
return ApiResponse<object>.Unauthorized();          // 401
return ApiResponse<object>.Forbidden("message");    // 403

// NEVER return raw exception messages to client
// ALWAYS catch and translate to ApiResponse
```

---

## 12. C# 14 Patterns -- .NET 10 Stable Only

| Pattern | C# Version | Use? |
|---------|-----------|------|
| `field` keyword in properties | C# 14 | ✅ Yes |
| Null-conditional assignment `??=` | C# 12+ | ✅ Yes |
| Primary constructors | C# 12 | ✅ Yes -- enforce everywhere |
| Collection expressions `[a, b, c]` | C# 12 | ✅ Yes |
| `required` properties in records | C# 11 | ✅ Yes |
| Pattern matching switch expressions | C# 8+ | ✅ Yes |
| EF Core 10 native LeftJoprint | .NET 10 | ✅ Yes |
| ExecuteUpdate / ExecuteDelete | EF Core 7+ | ✅ Yes |
| HybridCache | .NET 10 | ✅ Yes |
| Union types | C# 15 | ❌ Preview -- do NOT use |
| Collection expression `with(...)` | C# 15 | ❌ Preview -- do NOT use |

---

## 13. HEAD Filter -- Mandatory Rule

```
HEAD-01: All list queries MUST filter by Head (branch) of current user.
HEAD-02: On create, Head MUST come from ICurrentUserService -- NEVER from request body.
HEAD-03: Admin role can view all branches (isAll = true parameter).

BA Guide MUST explicitly note:
"All GetList handlers MUST include .Where(x => x.Head == currentUser.HeadCode)"
```

---

## 14. BA Guide Requirements -- Mandatory Sections

> BA MUST include ALL of the followprintg in every BE Guide:

```
§1  Overview + Performance targets (response times from SRS NFR-P)
§2  API Contract Table (all 5 endpoints with DTO names)
§3  DTO Definitions (Save, Cus, Filter, Response -- with field types)
§4  Status Constants (mapped to tbl_LSStatus TypeData value)
§5  Handler Logic (step-by-step for each handler)
§6  Shared APIs Required (which CORE APIs to call, and when)
§7  Cache Strategy (key pattern, TTL, invalidation trigger)
§8  Validation Rules (citing SRS AC-xx)
§9  Error Responses (all error scenarios)
§10 File Location (exact path in VSA folder structure)
§11 HEAD Filter note (MANDATORY reminder)
§12 Pending Decisions (from SRS TBD items)
```
