# Module Map -- Single Source of Truth

> Derived from actual code: MtbModuleConfig.cs, CrmModuleConfig.cs, HrmModuleConfig.cs, PrtModuleConfig.cs, RptModuleConfig.cs, Program.cs
> **Agents: read this file when starting any new feature. Never guess paths or routes.**

---

## Route Prefix Rules

Program.cs calls `app.MapModuleEndpoints()` with NO global prefix. Each module's MapEndpoints controls its own prefix:
- MTB routes are mapped directly (no `/api/` prefix)
- CRM wraps with `/api` internally
- All others use their own prefix

---

## Module Map

> **HOW ROUTING WORKS:** `MapModuleEndpoints()` wraps ALL modules inside a central `/api` group.
> Each module then adds its own sub-path. Final URL = `/api/{module-path}/{APIID}`.
> tbl_SYSAPI.URL column must store the FULL prefix including `/api/`.

| Module | Sub-Module | BE Route Prefix (URL column in tbl_SYSAPI) | VSA Path | FE Mobile Abbr | FE Web Abbr | DB Product |
|---|---|---|---|---|---|---|
| MTB | M.Sale | `/api/sale/` | `modules/MTB/Features/M.Sale/F.{Feature}/` | `sal` | _(none)_ | Mobile=3, Desktop=1 |
| MTB | M.Repair | `/api/repair/` | `modules/MTB/Features/M.Repair/F.{Feature}/` | `cs` | _(none)_ | Mobile=3, Desktop=1 |
| MTB | M.Warehouse | `/api/warehouse/` | `modules/MTB/Features/M.Warehouse/F.{Feature}/` | `wh` | _(none)_ | Mobile=3, Desktop=1 |
| CRM | M.Config | `/api/config/` | `modules/CRM/Features/M.Config/F.{Feature}/` | `crm` | _(none)_ | Mobile=3, Desktop=1 |
| CRM | M.SentMessage | `/api/message/` | `modules/CRM/Features/M.SentMessage/F.{Feature}/` | `crm` | _(none)_ | Mobile=3, Desktop=1 |
| HRM | M.Org | `/api/org/` | `modules/HRM/Features/M.Org/F.{Feature}/` | `hrm` | _(none)_ | Mobile=3, Desktop=1 |
| HRM | M.Profile | `/api/profile/` | `modules/HRM/Features/M.Profile/F.{Feature}/` | `hrm` | _(none)_ | Mobile=3, Desktop=1 |
| PRT | M.Config | `/api/prt/` | `modules/PRT/Features/M.Config/F.{Feature}/` | `prt` | _(none)_ | Mobile=3, Desktop=1 |
| PRT | M.Inventory | `/api/prt/` | `modules/PRT/Features/M.Inventory/F.{Feature}/` | `prt` | _(none)_ | Mobile=3, Desktop=1 |
| PRT | M.IO | `/api/prt/` | `modules/PRT/Features/M.IO/F.{Feature}/` | `prt` | _(none)_ | Mobile=3, Desktop=1 |
| RPT | M.Report | `/api/rpt/` | `modules/RPT/Features/M.Report/F.{Feature}/` | `rpt` | _(none)_ | Mobile=3, Desktop=1 |
| DBD | M.Dashboard | `/api/BusinessDashboard/` | `modules/DBD/Features/M.Dashboard/F.{Feature}/` | `dbd` | _(none)_ | Mobile=3, Desktop=1 |

---

## FE Mobile Abbreviation Notes

Abbreviation is derived from the **business sub-module**, not the top-level module code:
- **`sal`** = tbl_SAL* tables (Sale: order, invoice, receipt, collection)
- **`cs`** = tbl_WOM*, tbl_WO* tables (Repair/Work Order/Customer Service)
- **`wh`** = tbl_WH*, tbl_DO*, tbl_IO* for standalone Warehouse features
- **`prt`** = tbl_PRT*, tbl_Inventory*, tbl_IO* in PRT module (Parts)
- **`crm`** = CRM module features
- **`hrm`** = HRM module features
- **`rpt`** = RPT module features
- **`dbd`** = DBD dashboard features

**FE Web**: NO module abbreviation. Naming = `mtb{NNN}-{feature}` only.

---

## C# Namespace Pattern

| Module | Sub-Module | C# Namespace |
|---|---|---|
| MTB | M.Sale | `HoaiMinh.ERP.Modules.MTB.Features.M.Sale.F.{Feature}` |
| MTB | M.Repair | `HoaiMinh.ERP.Modules.MTB.Features.M.Repair.F.{Feature}` |
| MTB | M.Warehouse | `HoaiMinh.ERP.Modules.MTB.Features.M.Warehouse.F.{Feature}` |
| CRM | M.Config | `HoaiMinh.ERP.Modules.CRM.Features.M.Config.F.{Feature}` |
| CRM | M.SentMessage | `HoaiMinh.ERP.Modules.CRM.Features.M.SentMessage.F.{Feature}` |
| HRM | M.Org | `HoaiMinh.ERP.Modules.HRM.Features.M.Org.F.{Feature}` |
| PRT | M.Config | `HoaiMinh.ERP.Modules.PRT.Features.M.Config.F.{Feature}` |
| PRT | M.Inventory | `HoaiMinh.ERP.Modules.PRT.Features.M.Inventory.F.{Feature}` |
| PRT | M.IO | `HoaiMinh.ERP.Modules.PRT.Features.M.IO.F.{Feature}` |
| RPT | M.Report | `HoaiMinh.ERP.Modules.RPT.Features.M.Report.F.{Feature}` |
| DBD | M.Dashboard | `HoaiMinh.ERP.Modules.DBD.Features.M.Dashboard.F.{Feature}` |

---

## DB Registration Values

### ModuleID (tbl_SYSFunction.ModuleID = tbl_SYSModule.Code)
> Verified from actual DB tbl_SYSFunction. ModuleID is per SUB-MODULE, NOT per ModuleCode.
> Do NOT use Product code (3) as ModuleID. Do NOT use tbl_SYSModule.Code=12 ("Xe máy" desktop).

| Sub-Module | DB ModuleID | tbl_SYSModule reference |
|---|---|---|
| MTB / M.Sale | **7** | Code=7, Vietnamese="Bán hàng" (Sales) |
| MTB / M.Repair | **6** | Code=6, Vietnamese="Xe máy" (legacy mobile entry) |
| MTB / M.Warehouse | **6** | Same legacy entry — verify with: `SELECT ModuleID FROM tbl_SYSFunction WHERE DLLPackage='sale_wh'` |
| CRM | run: `SELECT ModuleID FROM tbl_SYSFunction WHERE DLLPackage='crm-config' AND Product=3` | |
| HRM | run: `SELECT ModuleID FROM tbl_SYSFunction WHERE DLLPackage='hrm-profile' AND Product=3` | |
| PRT | run: `SELECT ModuleID FROM tbl_SYSFunction WHERE DLLPackage LIKE 'prt%' AND Product=3` | |
| RPT | run: `SELECT ModuleID FROM tbl_SYSFunction WHERE DLLPackage LIKE 'rpt%' AND Product=3` | |

> IMPORTANT: For any new feature, run `SELECT ModuleID FROM tbl_SYSFunction WHERE DLLPackage='{same_module_sibling}' AND Product=3` to get the correct ModuleID. Never guess.

### Product Code (tbl_SYSFunction)
| Platform | Product Value |
|---|---|
| Desktop Web | 1 |
| Mobile Web | 3 |

### DLLPackage (tbl_SYSFunction)
For **Mobile**: must match the key in `namespaceMap` inside `mtbike-api-static.service.ts`.
For **Desktop**: must match the static field name in `PSMtbikeApiStaticService`.
Run `SELECT TOP 5 APIID, URL, ServerURL FROM tbl_SYSAPI ORDER BY Code DESC` to verify existing format.

**⚠️ BA RULE: Do NOT invent DLLPackage values.**
Use the table below. If the feature is not listed → write `[CHECK-FE]` so the FE agent verifies against the actual file.

| Feature Group | DLLPackage | FE Mobile Namespace | Notes |
|---|---|---|---|
| SAL Receipt, Collection | `receipt` | `fpayment` | Already in namespaceMap |
| SAL Invoice | `invoice` | _(FE verify)_ | Check namespaceMap before use |
| SAL Master / Consultant | `consultant` | _(FE verify)_ | Check namespaceMap before use |
| Repair / Work Order | `workorder` | _(FE verify)_ | Check namespaceMap before use |
| Warehouse / IO | `warehouse` | _(FE verify)_ | Check namespaceMap before use |
| CRM Config | `crm-config` | _(FE verify)_ | Check namespaceMap before use |
| HRM Profile | `hrm-profile` | _(FE verify)_ | Check namespaceMap before use |

> When FE agent runs, it MUST read the actual `mtbike-api-static.service.ts` and verify the key exists in namespaceMap. If missing → create new namespace (CASE B). If exists → use existing (CASE A).
> **BE agent** must also use this DLLPackage value when inserting into `tbl_SYSFunction`.

---

## Endpoint Registration (ModuleConfig.cs)

When adding new endpoints to an existing ModuleConfig, place inside the **correct** `Map*Endpoints` method:
- Sale feature → `MapSaleEndpoints`
- Repair feature → `MapRepairEndpoints`
- Warehouse feature → `MapWarehouseEndpoints`

Pattern (ALL endpoints use MapPost):
```csharp
g.MapPost("/GetList{TableName}", async (JsonElement p, IMediator m)
    => Results.Ok(await m.Send(new GetList{TableName}Query(p))));
```
