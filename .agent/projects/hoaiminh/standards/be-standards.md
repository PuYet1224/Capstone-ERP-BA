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

> Consistent pattern for Hoai Minh DTO mapping.

### BE C# DTOs:

| Pattern | Usage | Example |
|---|---|---|
| `DTO{Module}{Entity}` | Full DTO - all fields from DB | `DTOSALOrderReceipt`, `DTOCSWorkOrderMaster` |
| `DTO{Module}{Entity}Cus` | Custom DTO - only fields needed for 1 use case | `DTOSALOrderReceiptCus`, `DTOCSWorkOrderMasterCus` |

**Production (.NET 10) - Request/Response DTOs:**
```csharp
// Request DTO (input from FE)
public record {Feature}SaveRequest(
    long Code,           // 0 = create, >0 = update
    long OrderMasterCode,
    decimal CollectedAmount,
    int PaymentType,
    string? Note
);

// Cus DTO (identify record - used in Get/Delete/Status)
public record {Feature}CusRequest(long Code);

// Filter DTO (list query params)
public record {Feature}FilterRequest(
    DateOnly? DateFrom,
    DateOnly? DateTo,
    int? Status,
    int Page = 1,
    int PageSize = 20
);

// Response DTO (output for FE)
public record {Feature}Response(
    long Code,
    string ReceiptNo,
    long OrderMasterCode,
    decimal CollectedAmount,
    int Status,
    string StatusName,
    // ... all fields FE needs
    DateTimeOffset CreatedAt,
    string CreatedByName
);
```

---

## 3. PROJECT ARCHITECTURE - VSA (Vertical Slice)

```
modules/HoaiMinh.ERP.Modules.{Module}/
-- Features/
|   -- {Feature}/
|       -- {Feature}Endpoints.cs        Minimal API route registration ONLY
|       -- GetList{Feature}Query.cs     CQRS Query record
|       -- GetList{Feature}Handler.cs   Query Handler (EF Core, LINQ, Redis)
|       -- Get{Feature}Query.cs
|       -- Get{Feature}Handler.cs
|       -- Update{Feature}Command.cs    CQRS Command record
|       -- Update{Feature}Handler.cs    Command Handler
|       -- UpdateStatus{Feature}Command.cs
|       -- UpdateStatus{Feature}Handler.cs
|       -- Delete{Feature}Command.cs
|       -- Delete{Feature}Handler.cs
|       -- {Feature}Dto.cs              All DTOs for this feature
-- {Module}ModuleExtensions.cs          DI & route registration
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

## 5. HANDLER PATTERN - GetList (with Redis Cache)

```csharp
// GetList{Feature}Handler.cs
public class GetList{Feature}Handler(HoaiMinhDbContext db, IDistributedCache cache)
    : IRequestHandler<GetList{Feature}Query, ApiResponse<PagedList<{Feature}Response>>>
{
    public async Task<ApiResponse<PagedList<{Feature}Response>>> Handle(
        GetList{Feature}Query request, CancellationToken ct)
    {
        // STEP 1: Try Redis cache
        var cacheKey = $"{module}:{feature}:list:{HashParams(request.Filter)}";

        // Redis - comment out if not available, use IMemoryCache instead:
        // var cached = await cache.GetStringAsync(cacheKey, ct);
        // if (cached != null) return JsonSerializer.Deserialize<...>(cached)!;

        // STEP 2: Query DB (EF Core 10 - use LeftJoin, not GroupJoin)
        var query = db.{PrimaryTable}s
            .Where(x => !x.IsDeleted)
            .Where(x => x.Head == request.CurrentUser.HeadCode)  // HEAD-01: MANDATORY
            .AsNoTracking();

        // Apply filters
        if (request.Filter.DateFrom.HasValue)
            query = query.Where(x => x.CreatedDate >= request.Filter.DateFrom.Value);
        if (request.Filter.Status.HasValue)
            query = query.Where(x => x.Status == request.Filter.Status.Value);

        // LeftJoin example (.NET 10 native syntax):
        var result = await query
            .LeftJoin(db.Employees,
                x => x.CashierCode,
                e => e.Code,
                (x, emp) => new {Feature}Response(
                    x.Code,
                    x.ReceiptNo,
                    CollectedAmount: x.CollectedAmount ? 0,
                    Status: x.Status,
                    StatusName: {Feature}Status.GetName(x.Status),
                    CashierName: emp != null ? emp.FullName : ""
                ))
            .OrderByDescending(x => x.Code)
            .Skip((request.Filter.Page - 1) * request.Filter.PageSize)
            .Take(request.Filter.PageSize)
            .ToListAsync(ct);

        var total = await query.CountAsync(ct);

        var pagedResult = new PagedList<{Feature}Response>(result, total, request.Filter.Page, request.Filter.PageSize);

        // STEP 3: Set cache (5 min TTL)
        // await cache.SetStringAsync(cacheKey, JsonSerializer.Serialize(pagedResult),
        //     new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5) }, ct);

        return ApiResponse<PagedList<{Feature}Response>>.Ok(pagedResult);
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

## 7. STATUS CONSTANTS PATTERN

```csharp
// {Feature}Status.cs - in {Feature}Dto.cs or separate file
public static class {Feature}Status
{
    // Values MAP TO tbl_LSStatus TypeData=XX - DO NOT CHANGE
    public const int New       = 1;   // TypeOfStatus=1
    public const int Completed = 2;   // TypeOfStatus=2
    public const int Cancelled = 3;   // TypeOfStatus=3

    private static readonly Dictionary<int, string> _names = new()
    {
        [New]       = "New",
        [Completed] = "Completed",
        [Cancelled] = "Cancelled"
    };

    public static string GetName(int? status) =>
        status.HasValue && _names.TryGetValue(status.Value, out var name) ? name : "Unknown";

    public static readonly int[] EditableStatuses = [New];
    public static readonly int[] FinalStatuses    = [Completed, Cancelled];
}
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
.Where(x => x.Head == currentUser.HeadCode)

// Rule 3: Status transition guard
var allowedFrom = new[] { {Feature}Status.New };
if (!allowedFrom.Contains(entity.Status))
    return ApiResponse<object>.BadRequest($"Cannot perform action from status: {entity.StatusName}");

// Rule 4: Audit fields - NEVER hardcode
entity.Head = currentUser.HeadCode;
entity.CreatedBy = currentUser.UserName;
entity.UpdatedBy = currentUser.UserName;

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
