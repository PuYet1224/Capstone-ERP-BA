# BE Guide Template

> Used by ba-pipeline Step 7. Fill ALL sections with concrete values.
> CRITICAL: This template MUST match the ACTUAL code patterns in the project.
> Read existing handlers in `modules/{ModuleCode}/Features/` to verify patterns.
> Module metadata in guide header is the SSoT — BE/FE agents derive paths, routes, abbr from it.

---

## RULE-DTO-01: DTO Files Are FORBIDDEN (Read Before Writing Anything)

This project does NOT use DTO class files. This is the #1 source of wrong BE output.

FORBIDDEN -- never generate any of these:
- Any file named `DTO*.cs` (e.g., `DTOSALOrderReceipt.cs`)
- Any class with `namespace HM_ERP.DTO` or similar
- Any `Expression<Func<TEntity, TResult>>` Select method in any class
- Any static `Select()` factory method returning an expression
- Any class whose purpose is holding projection fields with methods attached

CORRECT -- anonymous type inline inside the handler:
```csharp
var data = await db.SALOrderReceipts
    .Where(w => w.Head == currentUser.CompanyId)
    .AsNoTracking()
    .Select(s => new          // anonymous type HERE, inside handler
    {
        s.Code,
        s.CellPhone,          // exact entity column name
        s.CollectedAmount,    // exact entity type (double, not decimal)
    })
    .ToListAsync(ct);
```

WRONG -- do not generate:
```csharp
// WRONG: never create this file
public class DTOSALOrderReceipt
{
    public static Expression<Func<tbl_SALOrderReceipt, DTOSALOrderReceipt>> Select()
        => s => new DTOSALOrderReceipt { Code = s.Code, ... };
}
```

---

> **NAMING RULES (MANDATORY):**
> - API Name = `GetList` + PrimaryTable name WITHOUT `tbl_` prefix
>   e.g., `tbl_SALOrderReceipt` -> `GetListSALOrderReceipt`
> - Handler file = same as API name + `.cs`
> - VSA Folder = `{VSAPath}` (read from module metadata block in guide header — do NOT hardcode)
>   e.g., MTB/M.Sale → `modules/MTB/Features/M.Sale/F.{FeatureName}/`
>   e.g., CRM/M.Config → `modules/CRM/Features/M.Config/F.{FeatureName}/`

## MANDATORY SECTION STRUCTURE (10 sections, NO EXTRAS)

The guide MUST have EXACTLY these 10 sections in this order. No DTO section allowed.

| # | Section | Required |
|---|---------|---------|
| 1 | Entity Verification | YES |
| 2 | API Contract | YES |
| 3 | Status Constants | YES (or "N/A") |
| 4 | VSA File Structure | YES |
| 5 | Handler Code Patterns | YES |
| 6 | Validation Rules | YES |
| 7 | Endpoint Registration | YES |
| 8 | Database Registration SQL | YES -- all 4 tables |
| 9 | Seed Data SQL | YES -- 3-5 rows |
| 10 | Shared APIs Required | YES (or "None") |

BANNED SECTIONS (will cause BE to generate wrong code):
- "DTO Specifications" -- NEVER add this section
- "DTO Files" -- NEVER add this section
- Any section generating DTO*.cs files

---

```markdown
# BE Implementation Guide: {FeatureName}
> **Generated from:** REQ_{SEQ}_{Name}.md
> **Generated at:** {ISO timestamp}
> **Stack:** .NET 10 + Minimal API + VSA + CQRS (MediatR) + EF Core 10
> **Primary Table:** {tbl_XXX}
> **Detail Table:** {tbl_XXXDetail} (if exists)

> ---
> **MODULE METADATA (SSoT — BE and FE agents read from here):**
> - **Module:** {ModuleCode} / {SubModule}  _(e.g., MTB / M.Sale)_
> - **VSA Path:** {VSAPath}  _(e.g., modules/MTB/Features/M.Sale/F.{Feature}/)_
> - **Namespace:** {Namespace}  _(e.g., HoaiMinh.ERP.Modules.MTB.Features.M.Sale.F.{Feature})_
> - **ModuleConfig:** {ModuleConfigFile}  _(e.g., modules/MTB/MtbModuleConfig.cs)_
> - **Route prefix:** {routePrefix}  _(e.g., /api/sale/ — from module-map.md, includes /api/ prefix, with trailing slash)_
> - **FE Mobile Abbr:** {feAbbr}  _(e.g., sal, cs, wh, crm, hrm, prt, rpt)_
> - **DB ModuleID:** {moduleID}  _(query: SELECT Code FROM tbl_SYSModule WHERE ModuleName='{ModuleCode}')_
> - **DB Product:** Mobile=3 | Desktop=1
> ---

---

## 1. Entity Verification

> Read from: entity snapshot `refs/entity-snapshots/{table}.md` (MANDATORY -- not from memory)
> If snapshot missing: STOP and create it first per HOW_TO_ADD.md
> ALL columns below must come from the snapshot, not from inference.

**{tbl_PrimaryTable} columns:**
| Column | C# Type | Nullable | Notes |
|--------|---------|----------|-------|
| Code | long | NO | PK |
| Head | long | NO | HEAD filter |
| ... | ... | ... | ... |

---

## 2. API Contract

> POST-only endpoints. All via MediatR CQRS.
> **API Name = Prefix + PrimaryTableName (without tbl_)**

> **Allowed prefixes ONLY:** GetList, Get, Update, Delete, Add, Import, Export
> **BANNED prefixes:** Create, Insert, Save, Set, Cancel, Approve, Remove
> **Update = handles BOTH create (Code==0) and edit (Code>0) in ONE handler**

> **Route prefix lookup:** Open `modules/MTB/MtbModuleConfig.cs` → find MapGroup path.
> Current groups: `/sale`, `/repair`, `/warehouse`, `/lookup`, `/config`
> Sale module = `/sale` (NOT `/sal`), Repair = `/repair`, Warehouse = `/warehouse`

| API Name | Endpoint | Response |
|---|---|---|
| GetList{TableName} | POST /{ModuleRoute}/GetList{TableName} | ApiResponse<object> |
| Get{TableName} | POST /{ModuleRoute}/Get{TableName} | ApiResponse<object> |
| Update{TableName} | POST /{ModuleRoute}/Update{TableName} | ApiResponse<object> |
| Delete{TableName} | POST /{ModuleRoute}/Delete{TableName} | ApiResponse<object> |

> Only include endpoints needed by FR-xx. No extras.

---

## 3. Status Constants

### 3a. Feature Status (if feature has own status)
> If NO independent status → write "N/A -- Relies on {Parent} status" and skip 3a.

> ⚠️ ENUM VALUES ARE NEVER GUESSED. Run the SQL below FIRST, then write the enum.
> ⚠️ ENUM NAMES MUST BE ENGLISH. e.g., `Pending`, `Processing`, `Done` — NEVER `ChoXuLy`, `HoanThanh`

**SQL to get actual TypeData values (run BEFORE writing enum):**
> ⚠️ Look up TypeOfStatus from `refs/entity-snapshots/tbl_LSStatus.md` → "Known TypeOfStatus Groups" table.
> NEVER guess the TypeOfStatus value.
> ⚠️ CRITICAL: Status fields store **TypeData** (1,2,3...), NOT Code/PK (27,28,92...).
>   - CORRECT: `EnumSALOrderMasterStatus.RetailProcessing = 4` (TypeData=4)
>   - WRONG: using Code=28 from tbl_LSStatus as enum value
> Verified values: TypeOfStatus=18 for tbl_SALOrderReceipt | TypeOfStatus=7 for tbl_SALOrderMaster
```sql
SELECT TypeData, StatusName
FROM tbl_LSStatus
WHERE TypeOfStatus = {N}  -- e.g., 7 for tbl_SALOrderMaster
ORDER BY TypeData
```

After getting TypeData values from DB, write enum:
```csharp
// File: src/Domain/ENUM/Enum{TableName}Status.cs
// namespace MUST be HM_ERP.DTO (matches existing enum files)
// Names MUST be English. Naming: EnumXxxStatus (NOT ENUMXxxStatus)
// ⚠️ CHECK EXISTING FILE FIRST — if Enum{TableName}Status.cs exists, use it. Do NOT create duplicate.
namespace HM_ERP.DTO
{
    public enum Enum{TableName}Status
    {
        Pending    = {TypeData value — e.g., 1},
        Processing = {TypeData value — e.g., 4},
        Done       = {TypeData value — e.g., 5},
    }
}
```

### 3b. Parent Entity Status Values (if handler updates a PARENT entity's status)
> Required when Update{Table} also changes status of a parent table (e.g., SALOrderMaster).
> NEVER hardcode integers. Always use enum constant.
> ⚠️ ALWAYS check existing Enum file in `src/Domain/ENUM/` first — use it as-is if it exists.
> ⚠️ Status stores TypeData (1,2,3...) — NOT Code PK. Existing EnumSALOrderMasterStatus proves this (values 1-6).

```csharp
// Step 1: Check src/Domain/ENUM/ for existing Enum{ParentEntity}Status.cs
// Step 2: Read existing enum values to find the correct TypeData for the target state
// Step 3: Use it in handler — NEVER create a duplicate enum file

// Example for retail sale (bán lẻ):
parent.Status = (int)EnumSALOrderMasterStatus.RetailProcessing;  // TypeData=4 = Đang xử lý
// NOT: parent.Status = 28  (28 is Code PK, not TypeData)
// NOT: parent.Status = (int)ENUMSALOrderMasterStatus.Processing  (wrong naming + wrong value)
```

---

## 4. VSA File Structure

> Read **VSA Path** from the MODULE METADATA block in this guide's header.
> DO NOT hardcode the path. Different modules use different paths.

```
{VSAPath}               <- from MODULE METADATA above
+-- GetList{TableName}.cs         -> Query + Handler (1 file)
+-- Get{TableName}.cs             -> Query + Handler (1 file)
+-- Update{TableName}.cs          -> Command + Handler (1 file)
+-- Delete{TableName}.cs          -> Command + Handler (if needed)
```

> **Examples by module:**
> - MTB/M.Sale → `modules/MTB/Features/M.Sale/F.{Feature}/`
> - MTB/M.Repair → `modules/MTB/Features/M.Repair/F.{Feature}/`
> - CRM/M.Config → `modules/CRM/Features/M.Config/F.{Feature}/`
> - HRM/M.Org → `modules/HRM/Features/M.Org/F.{Feature}/`

---

## 5. Handler Code Patterns

> **CRITICAL: Follow the EXACT patterns below. These are copied from working handlers.**
> **NO DTO classes. Use anonymous type projection (new { }) inline.**
> **NO Expression<Func<>>. NO separate DTO files.**
> **HybridCache: ALL read handlers cache results. ALL write handlers invalidate cache.**
> **Cache key pattern: `"{TableName}_List_HeadOut_{currentUser.CompanyId}"` -- HeadOut_ is MANDATORY. NEVER omit it.**

### GetList{TableName} Pattern:
> ⚠️ NEVER use .Include() — EF Core ignores Include when Select is used.
> ⚠️ NEVER reference navigation properties inside .Select() — property names are unknown at guide-write time and will cause compile errors.
>   FORBIDDEN: `s.tbl_SALOrderMaster.ID` or `s.OrderMaster.Code` — these assume nav prop names that may not exist.
>   ALLOWED: `s.OrderMaster` (the FK long value itself) — FE uses this FK or calls Get{Table} for joined display.
> Project ONLY columns that exist directly on {DbSetName}. No cross-table references.
```csharp
using System.Text.Json;
using HoaiMinh.ERP.Infrastructure.Persistence;
using HoaiMinh.ERP.Shared.Abstractions;
using HoaiMinh.ERP.Shared.Responses;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Hybrid;

namespace {Namespace};

public record GetList{TableName}Query(JsonElement Payload) : IRequest<ApiResponse<object>>;

public class GetList{TableName}Handler(
    HoaiMinhDbContext db,
    ICurrentUserService currentUser,
    HybridCache cache)
    : IRequestHandler<GetList{TableName}Query, ApiResponse<object>>
{
    public async Task<ApiResponse<object>> Handle(
        GetList{TableName}Query request, CancellationToken ct)
    {
        string cacheKey = $"{TableName}_List_HeadOut_{currentUser.CompanyId}";

        var data = await cache.GetOrCreateAsync(
            cacheKey,
            async _ =>
            {
                var query = db.{DbSetName}
                    .Where(w => w.Head == currentUser.CompanyId)
                    .AsNoTracking()
                    .Select(s => new
                    {
                        s.Code,
                        s.{Field1},      // EXACT column name from entity snapshot
                        s.{Field2},      // EXACT column name from entity snapshot
                        s.{ForeignKey},  // FK value OK (e.g. s.OrderMaster) — but NEVER s.OrderMaster.Code
                        // ⛔ NEVER: s.tbl_XXX.Anything — navigation property refs cause compile errors
                    });

                var count = await query.CountAsync(ct);
                var items = await query.ToListAsync(ct);
                return new { Total = count, Data = items };
            },
            new HybridCacheEntryOptions { Expiration = TimeSpan.FromSeconds(15) },
            cancellationToken: ct);

        return ApiResponse<object>.Ok(data);
    }
}
```

### Get{TableName} Pattern (MANDATORY -- must be present for detail page):
```csharp
using System.Text.Json;
using HoaiMinh.ERP.Infrastructure.Persistence;
using HoaiMinh.ERP.Shared.Abstractions;
using HoaiMinh.ERP.Shared.Responses;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace {Namespace};

public record Get{TableName}Query(JsonElement Payload) : IRequest<ApiResponse<object>>;

public class Get{TableName}Handler(
    HoaiMinhDbContext db,
    ICurrentUserService currentUser)
    : IRequestHandler<Get{TableName}Query, ApiResponse<object>>
{
    public async Task<ApiResponse<object>> Handle(
        Get{TableName}Query request, CancellationToken ct)
    {
        var code = request.Payload.GetProperty("Code").GetInt64();

        var entity = await db.{DbSetName}
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Code == code && x.Head == currentUser.CompanyId, ct);

        if (entity == null) return ApiResponse<object>.Fail("Không tìm thấy.");

        return ApiResponse<object>.Ok(entity);
    }
}
```

### Update{TableName} Pattern:
```csharp
using System.Text.Json;
using HM_ERP.DTO;                              // needed for ENUM{ParentEntity}Status references
using HoaiMinh.ERP.Domain.Entities;
using HoaiMinh.ERP.Infrastructure.Persistence;
using HoaiMinh.ERP.Shared.Abstractions;
using HoaiMinh.ERP.Shared.Extensions;
using HoaiMinh.ERP.Shared.Responses;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Hybrid;

namespace {Namespace};  // from MODULE METADATA block — e.g., HoaiMinh.ERP.Modules.MTB.Features.M.Sale.F.{Feature}

public record Update{TableName}Command(JsonElement Payload) : IRequest<ApiResponse<object>>;

public class Update{TableName}Handler(
    HoaiMinhDbContext db,
    ICurrentUserService currentUser,
    HybridCache cache)
    : IRequestHandler<Update{TableName}Command, ApiResponse<object>>
{
    public async Task<ApiResponse<object>> Handle(
        Update{TableName}Command request, CancellationToken ct)
    {
        var dto = request.Payload.GetProperty("DTO");
        var properties = request.Payload.GetProperty("Properties")
            .EnumerateArray().Select(x => x.GetString()).ToList();

        var code = dto.GetNullableLong("Code") ?? 0;

        tbl_{TableName} entity;

        if (code > 0)
        {
            // EDIT existing
            entity = await db.{DbSetName}
                .FirstOrDefaultAsync(x => x.Code == code, ct);
            if (entity == null) return ApiResponse<object>.Fail("Không tìm thấy.");
            if (entity.Head != currentUser.CompanyId)
                return ApiResponse<object>.Fail("Truy cập bị từ chối.");
        }
        else
        {
            // CREATE new (Code == 0)
            entity = new tbl_{TableName}
            {
                Head = currentUser.CompanyId,
                CreatedBy = currentUser.FullName,    // MUST match entity column name
                CreatedTime = DateTime.Now,           // MUST match entity column name
                        // ⚠️ STATUS RULE — choose exactly ONE:
                // CASE 1 — Section 3a has ENUM:
                //   Status = (int)ENUM{TableName}Status.{DefaultStatus},
                //   (DefaultStatus = INITIAL state e.g. Pending/Created — NEVER Done/Completed)
                // CASE 2 — Section 3a = N/A (no independent status):
                //   → DELETE this comment block. DO NOT write any Status line. Let DB use its own default.
                // ⛔ NEVER write: Status = 0  or  Status = 1  — magic numbers are FORBIDDEN regardless of case
            };
            db.{DbSetName}.Add(entity);
        }

        // Map changed fields using Properties list
        if (properties.Contains("{FieldName}"))
            entity.{FieldName} = dto.GetNullableInt("{FieldName}");
        // ... repeat for each field

        entity.LastModifiedBy = currentUser.FullName;
        entity.LastModifiedTime = DateTime.Now;

        // If this feature updates a PARENT entity status -- add block below:
        // ⚠️ NEVER use magic number: parent.Status = 28 is FORBIDDEN
        // ⚠️ ALWAYS use ENUM: parent.Status = (int)ENUM{ParentEntity}Status.Processing
        // ⚠️ Check Section 3b for parent ENUM definition
        if (entity.{ParentForeignKey} > 0)
        {
            var parent = await db.{ParentDbSet}
                .FirstOrDefaultAsync(x => x.Code == entity.{ParentForeignKey}, ct);
            if (parent != null)
            {
                parent.Status = (int)ENUM{ParentTableName}Status.Processing; // ENUM -- NOT parent.Status = 28
                parent.LastModifiedBy = currentUser.FullName;
                parent.LastModifiedTime = DateTime.Now;
            }
        }
        // Remove parent block entirely if feature does NOT update parent status

        await db.SaveChangesAsync(ct);

        // Invalidate cache so next GetList fetches fresh data
        await cache.RemoveAsync($"{TableName}_List_HeadOut_{currentUser.CompanyId}");

        return ApiResponse<object>.Ok(new { entity.Code }, "Success");
    }
}
```

### Delete{TableName} Pattern:
```csharp
using System.Text.Json;
using HoaiMinh.ERP.Infrastructure.Persistence;
using HoaiMinh.ERP.Shared.Abstractions;
using HoaiMinh.ERP.Shared.Responses;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Hybrid;

namespace {Namespace};  // from MODULE METADATA block — e.g., HoaiMinh.ERP.Modules.MTB.Features.M.Sale.F.{Feature}

public record Delete{TableName}Command(JsonElement Payload) : IRequest<ApiResponse<object>>;

public class Delete{TableName}Handler(
    HoaiMinhDbContext db,
    ICurrentUserService currentUser,
    HybridCache cache)
    : IRequestHandler<Delete{TableName}Command, ApiResponse<object>>
{
    public async Task<ApiResponse<object>> Handle(
        Delete{TableName}Command request, CancellationToken ct)
    {
        var code = request.Payload.GetProperty("Code").GetInt64();

        var entity = await db.{DbSetName}
            .FirstOrDefaultAsync(x => x.Code == code && x.Head == currentUser.CompanyId, ct);

        if (entity == null) return ApiResponse<object>.Fail("Không tìm thấy.");

        db.{DbSetName}.Remove(entity);
        await db.SaveChangesAsync(ct);

        // Invalidate cache so next GetList fetches fresh data
        await cache.RemoveAsync($"{TableName}_List_HeadOut_{currentUser.CompanyId}");

        return ApiResponse<object>.Ok(new { entity.Code }, "Deleted");
    }
}
```

### Delete{ChildTableName} Pattern (ONLY if feature has a child-table delete operation):
> Use when FE needs to delete a row from a RELATED/CHILD table (e.g., remove an item from a cart).
> No cache on child-table deletes — parent list cache is already separate.
```csharp
using System.Text.Json;
using HoaiMinh.ERP.Infrastructure.Persistence;
using HoaiMinh.ERP.Shared.Abstractions;
using HoaiMinh.ERP.Shared.Responses;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace {Namespace};

public record Delete{ChildTableName}Command(JsonElement Payload) : IRequest<ApiResponse<object>>;

public class Delete{ChildTableName}Handler(
    HoaiMinhDbContext db,
    ICurrentUserService currentUser)
    : IRequestHandler<Delete{ChildTableName}Command, ApiResponse<object>>
{
    public async Task<ApiResponse<object>> Handle(
        Delete{ChildTableName}Command request, CancellationToken ct)
    {
        var code = request.Payload.GetProperty("Code").GetInt64();

        var entity = await db.{ChildDbSetName}
            .FirstOrDefaultAsync(x => x.Code == code, ct);

        if (entity == null) return ApiResponse<object>.Fail("Không tìm thấy.");

        db.{ChildDbSetName}.Remove(entity);
        await db.SaveChangesAsync(ct);

        return ApiResponse<object>.Ok(new { entity.Code }, "Deleted");
    }
}
```
> If this pattern is NOT needed for the feature → omit entirely. Do not include empty patterns.

---

## 6. Validation Rules

> Source: SRS Acceptance Criteria (AC-xx)

| Rule | Condition | Error Message | Source |
|---|---|---|---|
| {Field} required | null or empty | "{field} is required" | AC-{nn} |

---

## 7. Endpoint Registration ({ModuleConfigFile})

> ⚠️ MapPost ONLY. This project uses POST for ALL operations.
> NEVER write MapGet, MapPut, MapDelete, MapPatch -- they will cause 404/405.
> **ModuleConfig** = read from MODULE METADATA block (e.g., MtbModuleConfig.cs, CrmModuleConfig.cs)

```csharp
// Add to {ModuleConfigFile} inside the correct route group  <- from MODULE METADATA
// -- F.{FeatureName} --
g.MapPost("/GetList{TableName}", async (JsonElement p, IMediator m)
    => Results.Ok(await m.Send(new GetList{TableName}Query(p))));
g.MapPost("/Get{TableName}", async (JsonElement p, IMediator m)
    => Results.Ok(await m.Send(new Get{TableName}Query(p))));
g.MapPost("/Update{TableName}", async (JsonElement p, IMediator m)
    => Results.Ok(await m.Send(new Update{TableName}Command(p))));
g.MapPost("/Delete{TableName}", async (JsonElement p, IMediator m)
    => Results.Ok(await m.Send(new Delete{TableName}Command(p))));
```

---

## 8. Database Registration (SQL)

> MUST register ALL of these. Missing any = FE cannot see the feature.

### 8a-ZERO. tbl_SYSModule (ONLY for brand-new module not yet in DB)
> Skip this block entirely if ModuleCode already exists in tbl_SYSModule (MTB, CRM, HRM, PRT, RPT all exist).
> Run the SELECT first. Only INSERT if no row returned.
```sql
-- Check first:
SELECT Code FROM tbl_SYSModule WHERE ModuleName = '{ModuleCode}';
-- If no row → INSERT:
INSERT INTO tbl_SYSModule (ModuleName, Vietnamese, OrderBy)
OUTPUT INSERTED.Code
VALUES ('{ModuleCode}', N'{Tên module tiếng Việt}', {OrderBy});
-- Capture output Code as @moduleId → use as ModuleID in 8a below
```

### 8a. tbl_SYSFunction (menu entry)
> **DLLPackage**: from `refs/module-map.md` DLLPackage table. NEVER derive as `{abbr}-{feature}`.
> **ModuleID**: from MODULE METADATA block above. M.Sale → 7 | M.Repair → 6
> **MANDATORY: Use DECLARE + IF block below exactly — never plain INSERT without check.**
```sql
DECLARE @funcId INT;

SELECT @funcId = Code FROM tbl_SYSFunction
WHERE DLLPackage = '{dllPackage}' AND Product = 3;

IF @funcId IS NULL
BEGIN
    INSERT INTO tbl_SYSFunction (Product, ModuleID, Vietnamese, English, OrderBy, TypeData, DLLPackage)
    VALUES (3, {ModuleID}, N'{Vietnamese Name}', '{English Name}', {OrderBy}, 1, '{dllPackage}');

    SET @funcId = SCOPE_IDENTITY();
END
-- @funcId now holds the FunctionID for use in 8b/8c/8d
```

### 8b. tbl_SYSAction (permissions)
```sql
-- Skip if actions already exist for this FunctionID
IF NOT EXISTS (SELECT 1 FROM tbl_SYSAction WHERE FunctionID = @funcId)
BEGIN
    INSERT INTO tbl_SYSAction (FunctionID, ActionName, TypeData, IsVisible)
    VALUES
        (@funcId, N'Xem', 1, 1),
        (@funcId, N'Sửa', 2, 1),
        (@funcId, N'Xóa', 3, 1);
END
```

### 8c. tbl_SYSPermissions (assign to admin role RoleID=1)
```sql
-- Assign all new actions to admin role (RoleID=1). Head and StaffID are NULL (role-level permission).
INSERT INTO tbl_SYSPermissions (ActionID, RoleID)
SELECT Code, 1 FROM tbl_SYSAction
WHERE FunctionID = @funcId
  AND Code NOT IN (SELECT ActionID FROM tbl_SYSPermissions WHERE RoleID = 1);
```

### 8d. tbl_SYSAPI (API route registration)
```sql
-- URL = route PREFIX including /api/ (e.g. '/api/sale/') — confirmed from MapModuleEndpoints wrapper
-- Final URL = ServerURL + URL + APIID = 'http://10.10.30.121:31' + '/api/sale/' + 'GetListSALOrderReceipt'
-- CORRECT: URL='/api/sale/'    WRONG: URL='/sale/' (missing /api/) or URL=APIID value
-- ModuleID same as tbl_SYSFunction above (e.g. 7 for M.Sale)
INSERT INTO tbl_SYSAPI (ModuleID, FunctionID, APIID, URL, ServerURL, IsClosed, OrderBy)
SELECT {ModuleID}, @funcId, apiid, '{routePrefix}', 'http://10.10.30.121:31', 0, rn
FROM (VALUES
    (1, 'GetList{TableName}'),
    (2, 'Get{TableName}'),
    (3, 'Update{TableName}'),
    (4, 'Delete{TableName}')
) AS t(rn, apiid)
WHERE NOT EXISTS (SELECT 1 FROM tbl_SYSAPI WHERE APIID = t.apiid AND FunctionID = @funcId);
```

### 8e. tbl_LSList (ONLY if feature needs new lookup values not yet in DB)
> Skip this section if all dropdown values already exist in tbl_LSList.
> Use when SRS/UI requires a new option that has no matching row (e.g., "Tiền mặt + Chuyển khoản").
```sql
-- Check existing values first:
SELECT TypeOfList, ListName FROM tbl_LSList WHERE TypeData = {TypeData} ORDER BY TypeOfList;
-- Insert only missing values:
INSERT INTO tbl_LSList (Head, TypeData, TypeOfList, ListName, OrderBy)
VALUES ({Head}, {TypeData}, {NextTypeOfList}, N'{DisplayName}', {OrderBy});
-- Verify:
SELECT TypeOfList, ListName FROM tbl_LSList WHERE TypeData = {TypeData} ORDER BY TypeOfList;
```

> **After DB registration:** User must logout then login (or call GetConfig via Postman)
> to refresh API routing on FE. NEVER tell user to restart IIS.

---

## 9. Seed Data (for testing)

> Insert 3-5 sample rows so FE has data to display immediately.
> Use Head = {default HEAD value from project}.

> ⚠️ Status value MUST use the actual Code from Section 3 ENUM (e.g., 92 for Tạo mới in SALOrderReceipt).
> NEVER write `Status = 1` or any other magic number. Look up the initial state Code from Section 3a.
```sql
INSERT INTO {tbl_PrimaryTable} (Head, {fields...}, Status, CreatedBy, CreatedTime)
VALUES
    ({Head}, {sample values...}, {InitialStatusCode}, 'SYSTEM', GETDATE()),
    ({Head}, {sample values...}, {InitialStatusCode}, 'SYSTEM', GETDATE()),
    ({Head}, {sample values...}, {InitialStatusCode}, 'SYSTEM', GETDATE());
-- {InitialStatusCode} = Code of the first/initial state from Section 3a ENUM (e.g., 92 for Tạo mới)
```

---

## 10. Shared APIs Required

| CORE API | When Called | Notes |
|---|---|---|
| {GetListXxx} | {trigger} | TypeData={N} if applicable |
```
