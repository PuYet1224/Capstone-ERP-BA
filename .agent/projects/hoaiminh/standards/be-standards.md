# Hoài Minh ERP — BE Coding Standards

> **Target Stack:** .NET 10 LTS (support đến May 2028), Minimal API, VSA (Vertical Slice Architecture), CQRS (MediatR 12), EF Core 10, C# 14
> **Cache Strategy:** IDistributedCache interface — Redis impl khi có server, MemoryCache impl khi local dev
> **Legacy Reference:** .NET 4.7.2 (`hoaiminh-api`) — đọc để hiểu business patterns, KHÔNG copy code
> **MANDATORY:** BA Guide MUST include all sections from this file for every BE feature.
> **WHY .NET 10 LTS (not .NET 11):** .NET 11 vẫn là Preview 3 (April 2026) — KHÔNG dùng cho production/capstone.
> C# 15 (union types + collection args) vẫn là Preview — chỉ dùng C# 14 stable features.

---

## 1. API NAMING — 4 PREFIX DUY NHẤT (LAW CỦA CÔNG TY)

> Đây là quy tắc bất biến từ legacy system và tiếp tục trong capstone.

| Prefix | Meaning | Examples | Notes |
|---|---|---|---|
| `GetList` | Lấy danh sách có phân trang/filter | `GetListSALReceipt`, `GetListCSWorkOrder` | Always returns paged data |
| `Get` | Lấy 1 record theo key | `GetSALReceipt`, `GetCSWorkOrder` | Returns single record |
| `Update` | Tạo mới **hoặc** cập nhật | `UpdateSALReceipt`, `UpdateSALReceiptStatus` | Code=0 → INSERT, Code>0 → UPDATE |
| `Delete` | Xóa | `DeleteSALReceipt` | Soft delete preferred |

**BỊ CẤM TUYỆT ĐỐI:**
```
❌ Create, Insert, Add (dùng Update thay thế)
❌ Cancel, Complete, Approve, Reject (dùng UpdateXxxStatus thay thế)
❌ Set, Patch, Put, Post (dùng Update)
❌ Remove (dùng Delete)
```

**Pattern cho đổi trạng thái:**
```
UpdateSALReceiptStatus   ← đổi status receipt
UpdateCSWorkOrderStatus  ← approve / reject / cancel work order
UpdateSALOrderStatus     ← cancel / complete order
```

---

## 2. DTO NAMING PATTERN

> Đọc từ `hoaiminh-api/HM_ERP.DTO/DTO/` — 151 files, pattern rất nhất quán.

### BE C# DTOs:

| Pattern | Usage | Example |
|---|---|---|
| `DTO{Module}{Entity}` | Full DTO — tất cả fields từ DB | `DTOSALOrderReceipt`, `DTOCSWorkOrderMaster` |
| `DTO{Module}{Entity}Cus` | Custom DTO — chỉ fields cần thiết cho 1 use case | `DTOSALOrderReceiptCus`, `DTOCSWorkOrderMasterCus` |

**Capstone (.NET 10) — Request/Response DTOs:**
```csharp
// Request DTO (input từ FE)
public record {Feature}SaveRequest(
    long Code,           // 0 = create, >0 = update
    long OrderMasterCode,
    decimal CollectedAmount,
    int PaymentType,
    string? Note
);

// Cus DTO (identify record — used in Get/Delete/Status)
public record {Feature}CusRequest(long Code);

// Filter DTO (list query params)
public record {Feature}FilterRequest(
    DateOnly? DateFrom,
    DateOnly? DateTo,
    int? Status,
    int Page = 1,
    int PageSize = 20
);

// Response DTO (output cho FE)
public record {Feature}Response(
    long Code,
    string ReceiptNo,
    long OrderMasterCode,
    decimal CollectedAmount,
    int Status,
    string StatusName,
    // ... all fields FE cần
    DateTimeOffset CreatedAt,
    string CreatedByName
);
```

---

## 3. PROJECT ARCHITECTURE — VSA (Vertical Slice)

```
modules/HoaiMinh.ERP.Modules.{Module}/
├── Features/
│   └── {Feature}/
│       ├── {Feature}Endpoints.cs       ← Minimal API route registration ONLY
│       ├── GetList{Feature}Query.cs    ← CQRS Query record
│       ├── GetList{Feature}Handler.cs  ← Query Handler (EF Core, LINQ, Redis)
│       ├── Get{Feature}Query.cs
│       ├── Get{Feature}Handler.cs
│       ├── Update{Feature}Command.cs   ← CQRS Command record
│       ├── Update{Feature}Handler.cs   ← Command Handler
│       ├── UpdateStatus{Feature}Command.cs
│       ├── UpdateStatus{Feature}Handler.cs
│       ├── Delete{Feature}Command.cs
│       ├── Delete{Feature}Handler.cs
│       └── {Feature}Dto.cs             ← All DTOs for this feature
└── {Module}ModuleExtensions.cs         ← DI & route registration
```

---

## 4. ENDPOINT PATTERN (Minimal API — .NET 10)

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

## 5. HANDLER PATTERN — GetList (with Redis Cache)

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

        // Redis — comment out if not available, use IMemoryCache instead:
        // var cached = await cache.GetStringAsync(cacheKey, ct);
        // if (cached != null) return JsonSerializer.Deserialize<...>(cached)!;

        // STEP 2: Query DB (EF Core 10 — use LeftJoin, not GroupJoin)
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
                    CollectedAmount: x.CollectedAmount ?? 0,
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

## 6. HANDLER PATTERN — Update (Create or Update)

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
            return ApiResponse<object>.BadRequest("Số tiền phải lớn hơn 0");

        tbl_{PrimaryTable}? entity;

        if (req.Code == 0) // CREATE
        {
            entity = new tbl_{PrimaryTable}
            {
                // Auto-generated sequence number (NOT manual concat)
                ReceiptNo = await _sysIncreaseService.NextAsync("{PREFIX}", ct),
                Head = currentUser.HeadCode,         // MANDATORY — never hardcode
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

            if (entity == null) return ApiResponse<object>.NotFound("{Feature} không tồn tại");

            // Status guard — only editable in certain statuses
            if (entity.Status != {Feature}Status.New)
                return ApiResponse<object>.BadRequest("Chỉ được sửa khi ở trạng thái Mới");

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
// {Feature}Status.cs — in {Feature}Dto.cs or separate file
public static class {Feature}Status
{
    // Values MAP TO tbl_LSStatus TypeData=XX — DO NOT CHANGE
    public const int New       = 1;   // TypeOfStatus=1
    public const int Completed = 2;   // TypeOfStatus=2
    public const int Cancelled = 3;   // TypeOfStatus=3

    private static readonly Dictionary<int, string> _names = new()
    {
        [New]       = "Mới",
        [Completed] = "Hoàn tất",
        [Cancelled] = "Hủy giao dịch"
    };

    public static string GetName(int? status) =>
        status.HasValue && _names.TryGetValue(status.Value, out var name) ? name : "Không xác định";

    public static readonly int[] EditableStatuses = [New];
    public static readonly int[] FinalStatuses    = [Completed, Cancelled];
}
```

---

## 8. SHARED APIs (APICORE) — PHẢI DÙNG, KHÔNG TỰ CODE LẠI

> Đây là các API dùng chung cho toàn hệ thống. BA MUST document which ones each feature uses.

| API Name | Module | What it returns | When to use |
|---|---|---|---|
| `GetListEmployee` | CORE | Danh sách nhân viên (EmployeeCode, FullName) | Cashier picker, Assigned picker |
| `GetListHead` | CORE | Danh sách chi nhánh (HeadCode, HeadName) | Branch filter (admin only) |
| `GetListWarehouse` | CORE | Danh sách kho (by HeadCode) | Warehouse picker |
| `GetListProvince` | CORE | Tỉnh thành | Address form |
| `GetListDistrict` | CORE | Quận huyện (by Province) | Address form cascade |
| `GetListWard` | CORE | Phường xã (by District) | Address form cascade |
| `GetListLSList` | CORE | Danh mục theo TypeData | Category dropdowns |
| `GetListStatus` | CORE | Trạng thái theo TypeData | Status filter dropdown |
| `GetListPartnerCustomer` | CORE | Danh sách khách hàng | Customer picker |
| `GetListSupplier` | CORE | Danh sách nhà cung cấp | Supplier picker |
| `ExportExcel` | CORE | File Excel | Export button |
| `ExportExcelPDF` | CORE | File PDF | Print/Export PDF |
| `UploadImage` | CORE | Image URL | Image upload |
| `DeleteImage` | CORE | Success/fail | Image delete |

---

## 9. VALIDATION RULES

```csharp
// Rule 1: Never accept Code < 0
if (request.Code < 0) return ApiResponse<object>.BadRequest("Mã không hợp lệ");

// Rule 2: HEAD filter — MANDATORY on all list queries
.Where(x => x.Head == currentUser.HeadCode)

// Rule 3: Status transition guard
var allowedFrom = new[] { {Feature}Status.New };
if (!allowedFrom.Contains(entity.Status))
    return ApiResponse<object>.BadRequest($"Không thể thực hiện từ trạng thái: {entity.StatusName}");

// Rule 4: Audit fields — NEVER hardcode
entity.Head = currentUser.HeadCode;
entity.CreatedBy = currentUser.UserName;
entity.UpdatedBy = currentUser.UserName;

// Rule 5: No magic numbers
// ❌ if (entity.Status == 1)
// ✅ if (entity.Status == {Feature}Status.New)
```

---

## 10. REDIS / CACHE STRATEGY — OPTIMAL APPROACH

> **Quy tắc vàng:** Luôn dùng `IDistributedCache` interface. Không hardcode implementation.
> Khi deploying: cấu hình Redis trong DI. Khi local/dev: swap bằng MemoryCache — KHÔNG sửa code business logic.

```csharp
// DI Registration (Program.cs):
// PRODUCTION — Redis:
builder.Services.AddStackExchangeRedisCache(opt =>
    opt.Configuration = builder.Configuration.GetConnectionString("Redis"));

// LOCAL DEV — swap này thay Redis (không sửa code handler):
// builder.Services.AddDistributedMemoryCache(); // ← comment/uncomment để switch

// Handler luôn inject IDistributedCache — KHÔNG thay đổi dù dùng Redis hay Memory:
public class GetList{Feature}Handler(HoaiMinhDbContext db, IDistributedCache cache) : IRequestHandler<...>

// Cache key pattern:
var cacheKey = $"{module}:{feature}:list:{Convert.ToHexString(MD5.HashData(Encoding.UTF8.GetBytes(JsonSerializer.Serialize(filter))))}";

// Get:
var cached = await cache.GetStringAsync(cacheKey, ct);
if (cached != null) return JsonSerializer.Deserialize<ApiResponse<PagedList<{Feature}Response>>>(cached)!;

// Set (5 min TTL):
await cache.SetStringAsync(cacheKey, JsonSerializer.Serialize(result),
    new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5) }, ct);

// Invalidate on Update/Delete (dùng prefix pattern nếu Redis, hoặc key cụ thể):
// ⚠️ IDistributedCache không có wildcard remove — dùng 1 trong 2 cách:
// Option A (Simple — recommended): Lưu list cache keys vào 1 key set (Redis Set)
// Option B (Simple local): Dùng tag-based cache nếu library hỗ trợ (Garnet, HybridCache .NET 10)
await cache.RemoveAsync($"{module}:{feature}:list:invalidated", ct); // sentinel key
```

### .NET 10 HybridCache (Recommended — mới nhất .NET 10)
```csharp
// HybridCache — thay thế cả IDistributedCache + IMemoryCache trong .NET 10:
// L1 (in-process memory) + L2 (Redis) tự động — stampede protection built-in
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

// Invalidate: dùng tags
await hybridCache.RemoveByTagAsync($"{module}:{feature}", ct);
```

> **⭐ Best Practice cho Capstone:** Dùng **HybridCache** (.NET 10 built-in) — nó tự động dùng cả memory cache + Redis (L1+L2), stampede-safe, invalidate bằng tags. Không cần chọn giữa IMemoryCache và IDistributedCache nữa.

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

## 12. C# 14 PATTERNS TO USE — .NET 10 STABLE ONLY

> **⚠️ Version Decision (April 2026):**
> - ✅ **.NET 10 LTS + C# 14** → Dùng cho mọi code production/capstone
> - ❌ **.NET 11 Preview 3 + C# 15** → Chưa release, KHÔNG dùng cho nghiệm thu

| Pattern | C# Version | Status | Dùng cho Capstone? |
|---|---|---|---|
| `field` keyword in properties | C# 14 | ✅ Stable | ✅ Có |
| Null-conditional assignment `??=` | C# 12+ | ✅ Stable | ✅ Có |
| Primary constructors | C# 12 | ✅ Stable | ✅ Có |
| Collection expressions `[a, b, c]` | C# 12 | ✅ Stable | ✅ Có |
| `required` properties in records | C# 11 | ✅ Stable | ✅ Có |
| Pattern matching switch expressions | C# 8+ | ✅ Stable | ✅ Có |
| EF Core 10 native LeftJoin | .NET 10 | ✅ Stable | ✅ Có |
| ExecuteUpdate / ExecuteDelete | EF Core 7+ | ✅ Stable | ✅ Có |
| HybridCache | .NET 10 | ✅ Stable | ✅ Có |
| Union types `public union X(A,B)` | C# 15 | ❌ Preview | ❌ Không |
| Collection expression `with(...)` | C# 15 | ❌ Preview | ❌ Không |

```csharp
// ✅ 1. field keyword (C# 14 — mới nhất stable)
public decimal Amount
{
    get => field;
    set
    {
        if (value < 0) throw new ArgumentOutOfRangeException(nameof(value));
        field = value;
    }
}

// ✅ 2. Null-conditional assignment
userProfile?.Settings ??= new UserSettings();

// ✅ 3. Primary constructors — enforce everywhere
public class GetListReceiptHandler(
    HoaiMinhDbContext db,
    ICurrentUserService user,
    HybridCache cache)  // ← inject HybridCache, không phải IDistributedCache
    : IRequestHandler<GetListReceiptQuery, ApiResponse<PagedList<ReceiptResponse>>>

// ✅ 4. EF Core 10 native LeftJoin (không còn dùng GroupJoin)
var result = await db.Receipts
    .Where(r => !r.IsDeleted && r.Head == user.HeadCode)
    .LeftJoin(db.Employees,
        r => r.CashierCode,
        e => e.Code,
        (r, emp) => new ReceiptResponse(r.Code, r.ReceiptNo, emp != null ? emp.FullName : ""))
    .OrderByDescending(r => r.Code)
    .ToListAsync(ct);

// ✅ 5. ExecuteUpdate — update không cần load entity
await db.Receipts
    .Where(r => r.Code == req.Code && r.Status == ReceiptStatus.New)
    .ExecuteUpdateAsync(s => s
        .SetProperty(r => r.Status, ReceiptStatus.Completed)
        .SetProperty(r => r.UpdatedDate, DateTime.UtcNow)
        .SetProperty(r => r.UpdatedBy, user.UserName), ct);

// ✅ 6. Collection expressions (C# 12+)
int[] editableStatuses = [ReceiptStatus.New, ReceiptStatus.InProgress];
// NOT: new int[] { ReceiptStatus.New }

// ✅ 7. required properties trong SaveRequest record
public record ReceiptSaveRequest
{
    public required long Code { get; init; }          // 0=create, >0=update
    public required decimal CollectedAmount { get; init; }
    public int PaymentType { get; init; } = 1;        // default: cash
    public string? Note { get; init; }                // optional
}

// ✅ 8. Pattern matching — clean status dispatch
string statusLabel = receipt.Status switch
{
    ReceiptStatus.New       => "Mới",
    ReceiptStatus.Completed => "Hoàn tất",
    ReceiptStatus.Cancelled => "Hủy giao dịch",
    _                       => "Không xác định"
};
```

---

## 13. HEAD FILTER — RULE BẮT BUỘC

```
HEAD-01: Mọi list query PHẢI filter theo Head (chi nhánh) của current user.
HEAD-02: Khi tạo mới, Head PHẢI lấy từ ICurrentUserService — KHÔNG nhận từ request body.
HEAD-03: Admin role có thể xem tất cả chi nhánh (isAll = true parameter).

BA Guide PHẢI explicitly note:
"All GetList handlers MUST include .Where(x => x.Head == currentUser.HeadCode)"
```

---

## 14. BA GUIDE REQUIREMENTS — Mandatory Sections

> BA MUST include ALL of the following in every BE Guide:

```
§1  Overview + Performance targets (response times from SRS NFR-P)
§2  API Contract Table (all 5 endpoints with DTO names)
§3  DTO Definitions (Save, Cus, Filter, Response — with field types)
§4  Status Constants (mapped to tbl_LSStatus TypeData value)
§5  Handler Logic (step-by-step for each handler)
§6  Shared APIs Required (which CORE APIs to call, and when)
§7  Redis Cache Strategy (key pattern, TTL, invalidation trigger)
§8  Validation Rules (citing SRS AC-xx)
§9  Error Responses (all error scenarios)
§10 File Location (exact path in VSA folder structure)
§11 HEAD Filter note (MANDATORY reminder)
§12 Pending Decisions (from SRS TBD items)
```
