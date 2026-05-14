# Quality Gates -- Mandatory Before Saving Any Guide

> Run ALL checks. CRITICAL fail -> STOP and fix before saving.

---

## BE Guide Checklist

### CRITICAL (must pass -- guide is rejected if any fail)

- [ ] **(R1)** Folder = `modules/{ModuleCode}/Features/{SubModule}/F.{Feature}/` -- derived from module-map.md (e.g. `modules/MTB/Features/M.Sale/F.Receipt/`). NEVER `modules/SAL/`, `modules/CS/`
- [ ] **(R2)** API Name = Prefix + table name without `tbl_` (e.g., `GetListSALOrderReceipt`)
- [ ] **(R2)** Only allowed prefixes used: GetList, Get, Update, Delete, Add, Import, Export
- [ ] **(R4)** NO DTO class files anywhere -- handler uses anonymous type `new {}` inline in `.Select()`
- [ ] **(R4)** NO `Expression<Func<>>` methods in any class
- [ ] **(R3)** Anonymous type field names EXACTLY match entity columns (e.g., `s.CellPhone` not `s.Phone`)
- [ ] **(R3)** Anonymous type field types match entity types (e.g., `double` not `decimal`)
- [ ] **(R7)** tbl_SYSAPI URL = route prefix from module-map.md (e.g. `/sale/` for Sale, `/repair/` for Repair, `/api/config/` for CRM) -- NEVER `/sal/`, `/api/sal/`, uppercase, or missing trailing slash
- [ ] **(R8)** Base projection includes ALL entity columns (except navigation properties)
- [ ] HEAD filter (`ICurrentUserService.CompanyId`) present in EVERY handler
- [ ] ALL GetList responses use `ApiResponse<object>.Ok(new { Total = data.Count, Data = data })` -- `data.Count` from flat list (no separate DB count query needed)
- [ ] MtbModuleConfig.cs endpoint registration code included (Section 7)
- [ ] DB registration SQL included for ALL 4 tables: SYSFunction, SYSAction, SYSPermissions, SYSAPI (Section 8)
- [ ] Seed data SQL included: 3-5 INSERT rows, no DELETE (Section 9)

### STRUCTURE CHECK (mandatory -- agent commonly omits these)

- [ ] Guide has EXACTLY 10 sections (1-Entity, 2-API, 3-Status, 4-VSA, 5-Handlers, 6-Validation, 7-Registration, 8-DB SQL, 9-Seed SQL, 10-Shared)
- [ ] NO "DTO Specifications" section exists anywhere in guide
- [ ] Section 8 (DB Registration) has SQL for ALL 4 tables: SYSFunction, SYSAction, SYSPermissions, SYSAPI
- [ ] Section 9 (Seed Data) has 3-5 INSERT rows with realistic values

### IMPORTANT (should pass)

- [ ] IMemoryCache pattern used: `GetOrCreateAsync` on reads, `cache.Remove(key)` after SaveChangesAsync on writes, TTL=15s, key=`"{Table}_List_{CompanyId}"`
- [ ] NO magic numbers in Status assignments: `Status = 1`, `Status = 27`, `parent.Status = 28` are ALL FORBIDDEN -- use `(int)ENUMXxxStatus.Value`
- [ ] Status constants with exact int values from tbl_LSStatus
- [ ] All FR-xx from SRS have corresponding API endpoint

---

## FE Mobile Guide Checklist

### CRITICAL (must pass -- guide is rejected if any fail)

- [ ] **(RULE-MOB-04)** Module abbreviation looked up from `refs/module-map.md` "FE Mobile Abbr" column (sal/cs/wh/prt/crm/hrm/rpt/dbd)
- [ ] **(RULE-MOB-04)** Folder = `mtb{NNN}-{abbr}-{feature}/` -- MUST contain module abbr segment (e.g. `sal`, `cs`, `wh`)
- [ ] **(RULE-MOB-04)** Class = `Mtb{NNN}{Abbr}{Feature}Component` -- MUST contain abbr in PascalCase (e.g. `Sal`, `Cs`, `Wh`)
- [ ] **(RULE-MOB-04)** Selector = `mtb{NNN}-{abbr}-{feature}` -- MUST contain module abbr
- [ ] **(R5)** Component number from component-registry.md -- NEVER reuse existing number
- [ ] **(R6)** API names EXACTLY match BE guide (copy-paste, no re-typing)
- [ ] **(R3)** Field names match entity columns (e.g., `CellPhone` not `Phone`)
- [ ] `MtbikeApiService` used -- NEVER custom service class
- [ ] Namespace CASE verified by reading ACTUAL FILE (not assumed): state "CASE A: '{key}' -> {ns}" or "CASE B: not found"
- [ ] CASE A: keys added to EXISTING namespace (e.g. `fpayment`) -- NOT created new `freceipt` or `fsal`
- [ ] SCSS wrapper = `::ng-deep { mtb{NNN}-{abbr}-{feature} { } }` with `@import "colors"` (abbr from MODULE METADATA)
- [ ] Registered in `mtbike.module.ts` + `mtbike.routing.ts`
- [ ] Detail component = SEPARATE component (`mtb{NNN+1}-{abbr}-{feature}-detail`) -- NOT `isDetailView` toggle
- [ ] `KeyLocalStorageEnum` entry for detail navigation added
- [ ] Component registry updated after guide saved (increment by 2 if list+detail)

### IMPORTANT (should pass)

- [ ] Kendo UI wrappers used (`ps-kendo-textbox`, `ps-kendo-dropdown-list`, etc.)
- [ ] Mobile card layout for lists (NOT kendo-grid)
- [ ] Bottom action bar with min touch target 44px

---

## FE Web Guide Checklist

### CRITICAL (must pass -- guide is rejected if any fail)

- [ ] **(R5)** Component name = `mtb{NNN}-{feature}` from registry
- [ ] **(R6)** API names EXACTLY match BE guide
- [ ] **(R3)** Field names match entity columns
- [ ] `MtbikeApiService` used -- NEVER custom service class
- [ ] OnPush change detection declared
- [ ] Registered in module + routing file

### IMPORTANT (should pass)

- [ ] Kendo UI wrappers used (ps-kendo-*, ps-filter-*, ps-toolbar-top)
- [ ] kendo-grid used for list screens (NOT card layout)
- [ ] Standard filter bar pattern (textbox + dropdown + status filter + buttons)
