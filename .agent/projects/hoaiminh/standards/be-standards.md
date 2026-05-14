# BE Coding Standards -- Hoai Minh ERP

> Source of truth: BE workspace `.agent/skills/coding-standard/SKILL.md`
> This file is a summary for BA reference when generating BE guides.

## Stack

| Layer | Technology |
|-------|-----------|
| Language | C# 14, .NET 10 LTS |
| Architecture | MediatR CQRS + Vertical Slice |
| API | Minimal API (MapPost only) |
| ORM | EF Core 10 Code-First, Fluent API |
| Cache | IMemoryCache (TTL=15s, key="{Table}_List_{CompanyId}") |
| DI | Primary Constructors |

## API Naming Convention

| Prefix | Purpose | HTTP Method |
|--------|---------|-------------|
| GetList{Feature} | Read list | POST |
| Get{Feature} | Read single | POST |
| Update{Feature} | Create/Edit | POST |
| Update{Feature}Status | Status change | POST |
| Delete{Feature} | Soft delete | POST |

> BANNED names: Create, Insert, Add, Save, Set, Cancel, Approve

## Endpoint URL Pattern

`{routePrefix}{ActionName}` -- PascalCase, all MapPost, no /v1/, no global /api/ prefix.
Route prefix from module (see module-map.md): `/sale/`, `/repair/`, `/warehouse/`, `/api/config/`...
Final URL = ServerURL + routePrefix + ActionName (e.g., `http://10.10.30.121:31/sale/GetListSALOrderReceipt`)

## Response Shape (MANDATORY)

```csharp
// List responses:
new { Total = count, Data = items }

// FE reads: res.ObjectReturn.Data + res.ObjectReturn.Total
// NEVER use: Items, TotalCount, Results, Count
```

## Handler Rules

1. Primary constructors for DI
2. AsNoTracking().Select() on all reads -- never return full entities
3. HEAD filter via ICurrentUserService.CompanyId on every business query
4. IMemoryCache: `GetOrCreateAsync(key, async entry => { entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromSeconds(15); ... })` on reads
5. IMemoryCache: `cache.Remove(key)` AFTER SaveChangesAsync on writes (NOT RemoveByTagAsync)
6. CancellationToken on every async method

## DTO Rule (CRITICAL -- NO DTO FILES)

This project does NOT use DTO class files. This is the #1 source of wrong BE output.

FORBIDDEN -- never generate:
- Any file named `DTO*.cs` (e.g., `DTOSALOrderReceipt.cs`)
- Any class with `namespace HM_ERP.DTO` or similar DTO namespace
- Any `Expression<Func<TEntity, TResult>>` Select method

CORRECT -- anonymous type inline inside each handler:
```csharp
.Select(s => new { s.Code, s.CellPhone, s.CollectedAmount })
```

## VSA File Structure

```
modules/MTB/Features/M.{Module}/F.{Feature}/
|-- GetList{Feature}.cs
|-- Get{Feature}.cs
|-- Update{Feature}.cs
|-- Delete{Feature}.cs
```

