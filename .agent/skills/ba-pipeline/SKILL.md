---
name: ba-pipeline
description: Analyze 7-Pillar SRS + design images and produce zero-ambiguity BE and FE implementation guides. Use when running /ba-analyst, analyzing requirements, or generating implementation guides.
metadata:
  role: BA
  version: "1.0"
  trigger: "/ba-analyst, 'analyze requirements', 'generate guide'"
---

# BA Pipeline -- SRS to Implementation Guides

## Goal
Read a 7-Pillar SRS + design images → output 2 complete, zero-ambiguity implementation guides (BE + FE Mobile) that any developer can implement on the first try without attending any meeting.

---

## GOTCHAS (read first — these are the mistakes the agent makes without this list)
- `TypeOfStatus` ≠ `TypeData` — always use `TypeOfStatus` to filter tbl_LSStatus groups
- `tbl_SALOrderReceipt` uses TypeOfStatus=**18**, `tbl_SALOrderMaster` uses TypeOfStatus=**7** — never swap
- **Status fields store TypeData (1,2,3...) — NOT Code PK (27,28,92...)** — SQL for ENUM: `SELECT TypeData, StatusName`. Existing `EnumSALOrderMasterStatus` (values 1-6) proves TypeData convention.
- **Status ENUM naming = `EnumXxxStatus`** (camelCase) — NOT `ENUMXxxStatus`. Check existing files in `src/Domain/ENUM/` first, never create duplicates.
- **Section 3a = N/A** → do NOT write any `Status =` line in new entity creation block.
- Route prefix = `/api/sale/` not `/sale/` — missing `/api/` prefix causes 404 permanently
- `tbl_SYSPermissions` uses `RoleID=1`, not `StaffID=1`
- `tbl_LSList` dropdowns: `[valueField]="'TypeOfList'"` not `'Code'` — entity stores TypeOfList integer
- **Get{TableName} handler is MANDATORY** — detail page will 404 without it
- DLLPackage: look up from `refs/module-map.md` — NEVER derive as `{abbr}-{feature}` (e.g., NEVER 'sal-receipt')
- Notification strings: Vietnamese WITH full diacritics — `'Lưu thành công'` not `'Luu thanh cong'`
- ModuleID: M.Sale=7, M.Repair=6 — NEVER use Product code (3) as ModuleID
- **Navigation properties in GetList Select() are FORBIDDEN** — `s.tbl_XXX.Column` causes compile error because nav prop names are unknown. Use FK value directly (e.g., `s.OrderMaster`) instead of `s.tbl_SALOrderMaster.Code`
- **New tbl_LSList values needed → add Section 8e** — if UI requires a lookup option not in DB (e.g., TypeOfList=3 for "Tiền mặt + Chuyển khoản"), add it in Section 8e, not as a silent assumption
- **tbl_SALOrderMaster.TypeData** stores payment type (Trả hết / Đặt cọc / Trả góp) — NOT tbl_SALOrderMaster.PaymentMethod

---

## Hard Rules
<!-- Violation = reject output immediately. Do not save guide with violation. -->

### R1: VSA Folder Path
- Path = `modules/{ModuleCode}/Features/{SubModule}/F.{Feature}/`
- **Determine ModuleCode + SubModule from SRS business domain. Read `refs/module-map.md` first.**
- Common mappings (see full table in `refs/module-map.md`):
  | Business Domain | ModuleCode | SubModule | Path Example |
  |---|---|---|---|
  | Sale / Order / Invoice / Receipt | MTB | M.Sale | `modules/MTB/Features/M.Sale/F.Receipt/` |
  | Repair / Work Order / CS | MTB | M.Repair | `modules/MTB/Features/M.Repair/F.Consult/` |
  | Warehouse / Delivery / Import | MTB | M.Warehouse | `modules/MTB/Features/M.Warehouse/F.DeliveryOrder/` |
  | CRM / Messaging / ZNS | CRM | M.SentMessage | `modules/CRM/Features/M.SentMessage/F.ZNS/` |
  | Parts / Inventory | PRT | M.Inventory | `modules/PRT/Features/M.Inventory/F.Inventory/` |
  | HRM / Employee / Org | HRM | M.Org | `modules/HRM/Features/M.Org/F.Org/` |
  | Reports / Export | RPT | M.Report | `modules/RPT/Features/M.Report/F.Report/` |
- NEVER: `modules/SAL/`, `modules/CS/`, any path not matching ModuleCode from map above
- If domain is ambiguous -> ask user before generating

### R2: API Naming = Prefix + Full Table Name (without tbl_)
- `tbl_SALOrderReceipt` -> API = `GetListSALOrderReceipt`
- `tbl_SALOrderInvoice` -> API = `GetListSALOrderInvoice`
- NEVER shorten: `GetListReceipt` or `GetListInvoice` are WRONG
- Allowed prefixes: `GetList`, `Get`, `Update`, `Delete`, `Add`, `Import`, `Export`
- BANNED prefixes: Create, Insert, Save, Set, Cancel, Approve, Remove

### R3: Anonymous Type Field Names = Entity Column Names
- Use EXACT column names from entity snapshot in Select projection
- Entity says `CellPhone` -> projection says `s.CellPhone` (NEVER `Phone`, `CustomerPhone`)
- Entity says `CollectedAmount` (double) -> projection type = double (NEVER decimal)
- If unsure -> read `refs/entity-snapshots/tbl_{Table}.md`

### R4: NO DTO Class Files -- Anonymous Types Only
- Project DOES NOT use DTO classes or `Expression<Func<>>` Select methods
- Project uses anonymous type `new { }` inline in `.Select()`
- NEVER generate `DTOSALOrderReceipt.cs` or any `DTO*.cs` file
- NEVER generate `namespace HM_ERP.DTO;`
- NEVER add methods, expressions, or static factories to a DTO-like class
- A data transfer object = plain data properties ONLY

### R5: FE Component = mtb{NNN} from Registry
- Read `refs/component-registry.md` -> use "Next Available Number"
- Format: `mtb{NNN}-{feature-kebab}` -> Class: `Mtb{NNN}{FeaturePascal}Component`
- NEVER use `Mtb001` unless registry says 001 is next
- NEVER use `Sal001`, `Receipt001`, or any non-mtb naming
- After saving guide -> update registry: increment next available number

### R6: FE API Names Must Match BE Exactly
- Copy-paste API names from the BE guide you just generated
- BE says `GetListSALOrderReceipt` -> FE must say `GetListSALOrderReceipt`
- Any mismatch = FE will call wrong endpoint

### R7: API Route Prefix (derive from module-map.md)
- Final URL = ServerURL + RoutePrefix + APIID
- **Read `refs/module-map.md` → look up Sub-Module → get BE Route Prefix**
- `MapModuleEndpoints()` wraps ALL modules in a central `/api` group (src/Shared/Extensions/ModuleDiscoveryExtensions.cs).
  Each module adds its own sub-path → all MTB routes are `/api/sale/`, NOT `/sale/`.
  | Sub-Module | Route Prefix | Final URL example |
  |---|---|---|
  | MTB/M.Sale | `/api/sale/` | `http://server:31/api/sale/GetListSALOrderReceipt` |
  | MTB/M.Repair | `/api/repair/` | `http://server:31/api/repair/GetListWOMConsultant` |
  | MTB/M.Warehouse | `/api/warehouse/` | `http://server:31/api/warehouse/GetListDOMaster` |
  | CRM/M.Config | `/api/config/` | `http://server:31/api/config/GetListSMSTemplate` |
  | CRM/M.SentMessage | `/api/message/` | `http://server:31/api/message/GetListSendMaster` |
  | HRM/M.Org | `/api/org/` | `http://server:31/api/org/GetListDepartmentTree` |
  | PRT | `/api/prt/` | `http://server:31/api/prt/GetListIOMaster` |
  | RPT | `/api/rpt/` | `http://server:31/api/rpt/GetListReport` |
- NEVER: `/sal/`, `/sale/` (missing /api/), `/api/sal/`, uppercase paths

### R8: Include ALL Entity Columns in Base DTO
- Read entity snapshot -> include EVERY column in base DTO (except navigation properties)
- Custom DTO = base DTO + joined/calculated fields
- Detail DTO = separate anonymous type (NOT inheriting from parent)

---

## Paths

```
READ:   {PROJECT_PIPELINE}\requirements\          (REQ_*.md -- SRS input)
READ:   {PROJECT_PIPELINE}\designs\{feature}\     (PNG images from Figma export)
WRITE:  {PROJECT_PIPELINE}\guides\                (BE_*.md + FE_*.md -- output)
```

---

## Steps

### Step 1 -- Auto-Scan and Select SRS
- Input: `{PROJECT_PIPELINE}\requirements\`
- Action: Scan for `REQ_*.md`. Find files WITHOUT matching guide in `guides/`.
- Gate: 1 file -> auto-select. Multiple -> ask user. 0 -> STOP: "Run /clean-requirement first."

### Step 2 -- Read SRS + Entity Snapshots
- Input: Selected REQ file + entity snapshot at ABSOLUTE path:
  `{BA_ROOT}\.agent\skills\ba-pipeline\refs\entity-snapshots\tbl_{PrimaryTable}.md`
- Action: Extract ALL 7 pillars. Read entity snapshot FIRST -- before any analysis.
  - Detail table exists -> also read `refs/entity-snapshots/tbl_{DetailTable}.md`
  - **If snapshot missing**: Ask user ONE question before stopping:
    "Bảng `tbl_{PrimaryTable}` chưa có entity snapshot.
     - Bảng đã tồn tại trong DB? → Cần tạo snapshot trước:
       1. BE agent đọc src/Domain/Entities/tbl_{PrimaryTable}.cs
       2. Tạo file theo HOW_TO_ADD.md
       3. Chạy lại /ba-analyst
     - Bảng CHƯA tồn tại (feature hoàn toàn mới)? → Trả lời 'mới' để BA đề xuất schema"
  - **If table is brand new** (user confirms): BA proposes minimal schema in Section 1 of guide.
    BE agent will create entity + migration. No snapshot needed until after table is created.
  - Snapshot found -> read EVERY column, note C# types and nullability
    ⚠️ COUNT columns in snapshot. Write that count in your working memory: "Snapshot has N columns."
    ⚠️ Section 1 of guide MUST list ALL N columns. If guide lists fewer → STOP, re-read snapshot.
  - **Detail Table rule**: Only set Detail Table in guide header if SRS Pillar 1 EXPLICITLY names a second entity (e.g., "tbl_XxxDetail for line items"). NEVER infer from FK relationships. If SRS has only 1 primary table → write "Detail Table: N/A".
  - Read component registry: `refs/component-registry.md`
  - Apply naming rules R2 and R3 from entity table names
  - Group requirements: BR-xx, FR-xx, AC-xx, NFR-xx
- Gate: Snapshot read with ALL columns confirmed. SRS must have all 7 pillars.

### Step 3 -- Read Design Images + Detect Platform
- Input: `{PROJECT_PIPELINE}\designs\{feature}\`
- Action: Check for actual IMAGE FILES (png/jpg), not just folder existence.
  - `mobile/` has images AND (`web/` or `desktop/`) has images -> Both
  - `mobile/` has images, others empty -> Mobile
  - (`web/` or `desktop/`) has images, `mobile/` empty -> Web
  - `desktop/` = Web equivalent. Empty folder does NOT count.
  - No designs folder -> Mobile (project default)
  - Read images using view_file tool in batches of 3. **Read ALL images — do NOT stop after first batch. Continue until every image file in the folder is read.**
  - Example: 13 images → 5 batches of 3 (last batch = 1). ALL must be read before proceeding.
  - Do NOT use Figma MCP.
- Gate: Platform must be resolved (Mobile/Web/Both) before Step 5.

### Step 4 -- Load Project Standards
- Input: `projects/hoaiminh/`
- Action: Load domain files + standards.
  - Always load: `domain/01-glossary.md`, `domain/06-database-schema.md`, `domain/07-business-rules.md`
  - SAL/MTB features: also load `domain/03-sales-flow.md`, `domain/08-approval-flows.md`
  - CS features: also load `domain/04-service-flow.md`
  - WH features: also load `domain/05-warehouse-flow.md`
- Gate: Domain loaded -> proceed. Domain files missing -> state error, do not continue.

### Step 5 -- Technical Contract Analysis
- Input: SRS pillars + entity snapshots + domain knowledge
- Action: Resolve ALL API names (R2), anonymous type schemas (R3, R4, R8), status enums.
  - Use platform from Step 3 (NOT from SRS if design files exist)
  - Determine caching strategy: HybridCache key per entity+CompanyId, TTL=15s, invalidate on write (`await cache.RemoveAsync(key)`)
  - **Status ENUM resolution (HARD GATE -- do this BEFORE writing any handler code):**
    1. Check if SRS mentions status values for this feature's entity or parent entity
    2. Look up TypeOfStatus from `refs/entity-snapshots/tbl_LSStatus.md` → "Known TypeOfStatus Groups" table.
       NEVER guess the TypeOfStatus value. NEVER use TypeData as the filter.
       Example values (verified from DB): tbl_SALOrderReceipt=18, tbl_SALOrderMaster=7.
       If entity not in table → write TypeOfStatus=TBD and ask user.
    3. Always include SQL in Section 3 so BE agent can look up TypeData values:
       `SELECT TypeData, StatusName FROM tbl_LSStatus WHERE TypeOfStatus = {N} ORDER BY TypeData`
       (TypeData = sequential value stored in entity Status field — NOT Code/PK)
    4. In handler code: always write `(int)Enum{TableName}Status.{ValueName}` -- NEVER magic numbers
       Naming = `EnumXxxStatus` (NOT `ENUMXxxStatus`) — match existing files in `src/Domain/ENUM/`
    5. Add comment in handler: `// BE agent: check if Enum{TableName}Status exists in src/Domain/ENUM/ — use existing, overwrite only if values wrong`
- Gate: No unresolved critical TBDs -> proceed. Critical TBDs -> ask user.

### Step 6 -- Analysis Summary (Display to User)
- Output: Summary showing module, APIs, DTO schemas, status machine, discrepancies, TBDs
- Gate: User sees summary. No critical TBD -> auto-proceed. Critical TBD -> wait for user.

### Step 7 -- Generate BE Guide
- Input: `refs/be-guide-template.md` + all resolved values from Step 5
- Action: Fill ALL 10 sections with concrete values. No placeholders.
  - **MANDATORY FIRST**: Fill the MODULE METADATA block in guide header using `refs/module-map.md`:
    ```
    Module: {ModuleCode} / {SubModule}
    VSA Path: modules/{ModuleCode}/Features/{SubModule}/F.{Feature}/
    Namespace: HoaiMinh.ERP.Modules.{ModuleCode}.Features.{SubModule}.F.{Feature}
    ModuleConfig: modules/{ModuleCode}/{ModuleCode}ModuleConfig.cs
    Route prefix: {routePrefix}   <- from module-map.md BE Route Prefix column
    FE Mobile Abbr: {feAbbr}      <- from module-map.md FE Mobile Abbr column
    DB ModuleID: {moduleID}       <- from module-map.md DB ModuleID column (e.g., M.Sale=7, M.Repair=6). NEVER use Product code (3) as ModuleID. NEVER use desktop module ID (12 = "Xe máy" desktop).
    DB Product: Mobile=3 | Desktop=1
    ```
  - **VSA Path feature name rule**: `{Feature}` = SHORT business name, NOT the table name.
    e.g., `tbl_SALOrderReceipt` → `F.Receipt` (NOT `F.SALOrderReceipt`)
    e.g., `tbl_WOMConsultant` → `F.Consult` (NOT `F.WOMConsultant`)
    e.g., `tbl_DODeliveryOrder` → `F.DeliveryOrder` (NOT `F.DODeliveryOrder`)
  - BE agent reads this header block directly — no embedded lookup table needed in BE SKILL.md
  - **MANDATORY DLLPackage**: Section 8a DLLPackage value MUST be looked up from `refs/module-map.md` DLLPackage table (match by Feature Group). NEVER derive as `{abbr}-{feature}` pattern (e.g., NEVER 'sal-receipt'). Example: SAL Receipt → `receipt`. If not in table → write `[CHECK-FE]`.
  - **MANDATORY handlers**: ALL 4 handlers (GetList, Get, Update, Delete) MUST be fully written from template. NEVER abbreviate any handler as "see template" or "standard pattern" — that is a critical failure.
  - **MANDATORY default Status**: If Section 3a = N/A → do NOT write any `Status =` line. If Section 3a has ENUM → use `(int)EnumXxxStatus.{FirstState}` (TypeData=1, initial state). NEVER use Done/Completed. NEVER magic number.
- Self-check before saving:
  - [ ] MODULE METADATA block filled in guide header (SSoT for BE/FE agents)
  - [ ] Folder = `modules/{ModuleCode}/Features/{SubModule}/F.{Feature}/` matches module-map.md (R1)
  - [ ] Every API name = Prefix + full table name, no tbl_ (R2)
  - [ ] NO DTO class files anywhere in guide (R4) -- anonymous types only
  - [ ] Every anonymous type field matches entity snapshot exactly (R3)
  - [ ] ALL entity columns in base projection (R8)
  - [ ] tbl_SYSAPI URL column = route prefix from module-map.md (R7) -- NEVER `/sal/` or `/api/sal/`
  - [ ] Section 7 uses `g.MapPost(...)` ONLY -- MapGet/MapPut/MapDelete are BANNED
  - [ ] {ModuleConfig} file registration included (Section 7) using be-guide-template pattern
  - [ ] DB registration SQL included for ALL 4 tables (Section 8) -- all required columns
  - [ ] Seed data SQL included (Section 9)
  - [ ] Only allowed prefixes: GetList, Get, Update, Delete, Add, Import, Export (R2)
  - [ ] Entity Verification section column COUNT matches snapshot column count exactly (e.g., "snapshot has 22 cols → guide lists 22 cols") -- if counts differ → STOP and rewrite Section 1
  - [ ] Entity Verification: no invented columns, no renamed columns (e.g., `Notes` when entity says `Description`)
  - [ ] Detail Table in guide header = N/A unless SRS Pillar 1 explicitly names a second entity
  - [ ] Section 5 has ALL 4 handler patterns: GetList, Get, Update, Delete -- none skipped
  - [ ] VSA Path feature name = SHORT business name (e.g., F.Receipt), NOT table name (e.g., NOT F.SALOrderReceipt)
  - [ ] DB ModuleID = from module-map.md ModuleID column -- NEVER same value as Product (3)
  - [ ] Section 3 TypeOfStatus values come from `refs/entity-snapshots/tbl_LSStatus.md` Known TypeOfStatus Groups table -- NEVER guessed (e.g., 18=SALOrderReceipt, 7=SALOrderMaster, NOT 22)
  - [ ] Seed data INSERT includes ALL NOT NULL columns from entity Section 1
  - [ ] Seed data Status value = TypeData value from Section 3 ENUM (e.g., TypeData=1 for initial state), NOT Code PK, NOT magic number
  - [ ] Section 3a = N/A → NO `Status =` line in new-entity creation block. Section 3a has ENUM → use `(int)EnumXxxStatus.Pending` (TypeData=1)
  - [ ] Update handler entity Status uses ENUM constant -- NEVER magic number (`Status = 1` raw or `Status = 27` are FORBIDDEN — use `(int)EnumXxxStatus.Pending`)
  - [ ] New entity default Status = INITIAL workflow state (TypeData=1 / Pending), NOT terminal state (Done/Completed)
  - [ ] If handler updates PARENT entity status: `parent.Status = (int)EnumXxxStatus.RetailProcessing` -- NEVER `parent.Status = 28` or any integer
  - [ ] Parent ENUM: check existing file in `src/Domain/ENUM/` first — document existing values in Section 3b. SQL: `SELECT TypeData, StatusName FROM tbl_LSStatus WHERE TypeOfStatus={N}`
  - [ ] All GetList/Get handlers include HybridCache injection + `cache.GetOrCreateAsync` wrapping query
  - [ ] All Update/Delete handlers include `await cache.RemoveAsync(key)` AFTER `SaveChangesAsync`
  - [ ] DLLPackage in Section 8a SQL = looked up from refs/module-map.md DLLPackage table, NOT derived as '{abbr}-{feature}'
  - [ ] ALL 4 handlers fully generated -- NO "see template" or "standard pattern" shortcuts
- Gate: ALL self-check items pass -> save. Any CRITICAL fail -> fix before saving.
- Output: `{PROJECT_PIPELINE}\guides\BE_{SEQ}_{FeatureName}.md`

### Step 8 -- Generate FE Web Guide (if Platform = Web or Both)
- Input: `refs/fe-web-guide-template.md` + BE guide from Step 7
- Action: Fill all sections. API names MUST match BE guide exactly (R6).
- Gate: API names verified against BE guide.
- Output: `{PROJECT_PIPELINE}\guides\FE_WEB_{SEQ}_{FeatureName}.md`

### Step 9 -- Generate FE Mobile Guide (if Platform = Mobile or Both)
- Input: `refs/fe-mobile-guide-template.md` + component registry + BE guide from Step 7
- NOTE: BA does NOT have access to FE Mobile workspace. Do NOT search or read any file outside BA workspace or ai.pipeline.
  - DLLPackage value: copy from BE guide Section 8a (which was already looked up from module-map.md DLLPackage table).
  - CASE A vs CASE B: determine from `refs/module-map.md` DLLPackage table "Notes" column:
    - "Already in namespaceMap" → CASE A. Also document the FE Mobile Namespace (e.g., `fpayment`) from table.
    - No note or missing entry → CASE B (FE agent will create new namespace).
  - FE Mobile agent will verify at implement time, but BA must pre-document the correct case.
- Action: Fill all sections. CRITICAL naming rule: derive module abbreviation from `refs/module-map.md` → "FE Mobile Abbr" column.
  - Pattern: folder=`mtb{NNN}-{abbr}-{feature}`, class=`Mtb{NNN}{Abbr}{Feature}Component`, selector=`mtb{NNN}-{abbr}-{feature}`
  - Examples: Sale → `sal` → `mtb028-sal-receipt`; Repair → `cs` → `mtb030-cs-consult`; Warehouse → `wh` → `mtb032-wh-delivery`
  - The module abbreviation segment is MANDATORY -- NEVER omit it
- Self-check before saving:
  - [ ] Module abbr looked up from `refs/module-map.md` "FE Mobile Abbr" column (e.g. sal/cs/wh/prt/crm) (RULE-MOB-04)
  - [ ] Component folder = `mtb{NNN}-{abbr}-{feature}/` -- has module abbr? (RULE-MOB-04)
  - [ ] Class = `Mtb{NNN}{Abbr}{Feature}Component` -- has module abbr (PascalCase)? (RULE-MOB-04)
  - [ ] Selector = `mtb{NNN}-{abbr}-{feature}` -- has module abbr? (RULE-MOB-04)
  - [ ] Component = `mtb{NNN}` from registry (R5) -- NOT Mtb001 unless registry says so
  - [ ] API names match BE guide exactly (R6)
  - [ ] DLLPackage in MODULE METADATA = from module-map.md DLLPackage table — NEVER '{abbr}-{feature}' pattern
  - [ ] Section 3a: states CASE A or B determined from module-map.md DLLPackage table Notes column
  - [ ] Section 3a documents DLLPackage value AND FE namespace (e.g., CASE A: 'receipt' → fpayment)
  - [ ] Section 3a uses namespace key pattern `{namespace}.{APIID}` (e.g. `fpayment.GetListSALOrderReceipt`) -- NEVER `this.http.get/post`
  - [ ] Section 3b methods use `this.post({namespace}.{APIID}, payload)` -- no direct HTTP
  - [ ] Response format uses `res.StatusCode === 0` + `res.ObjectReturn` -- NEVER `res.Success/res.Data`
  - [ ] MtbikeApiService used -- NEVER custom service class, NotificationService, LoaderService
  - [ ] Field names match entity columns (R3)
  - [ ] SCSS wrapper = `::ng-deep { mtb{NNN}-{abbr}-{feature} { } }` with `@import colors`
  - [ ] Registered in mtbike.module.ts + mtbike.routing.ts
  - [ ] 5 standard services in constructor (Router, MtbikeApiService, PsCache, PsKendoNotificationService, SystemLoaderService)
  - [ ] No lucide-icon (use material-icons only)
  - [ ] No hardcoded arrays (paymentMethods, statusList) -- BANNED mock data
  - [ ] All dropdown loaders call real API (e.g., GetListLSList for tbl_LSList-based lists) -- NO empty placeholder methods
  - [ ] tbl_LSList dropdowns use [valueField]="'TypeOfList'" NOT [valueField]="'Code'" (entity stores TypeOfList integer, not Code)
  - [ ] tbl_LSList dropdowns use [textField]="'ListName'" (display column name in tbl_LSList)
  - [ ] notification.onSuccess() strings use Vietnamese WITH diacritics (e.g., 'Lưu thành công', NOT 'Luu thanh cong')
  - [ ] Detail component = SEPARATE mtb{NNN+1}-{abbr}-{feature}-detail (NOT isDetailView toggle)
  - [ ] KeyLocalStorageEnum entry for detail navigation added
- Gate: ALL self-check items pass -> save. After saving -> update registry (increment by 2 if both list+detail).
- Output: `{PROJECT_PIPELINE}\guides\FE_MOBWEB_{SEQ}_{FeatureName}.md`
  ⚠️ FILENAME MUST START WITH `FE_MOBWEB_` — NEVER `FE_` alone. Wrong name = FE agent cannot find the guide.

### Step 10 -- Save Memory File
- Input: All analysis decisions from Steps 2-9
- Action: Save to `.agent/projects/hoaiminh/memory/{FeatureName}.md`
- Gate: Memory file saved -> proceed.

### Step 11 -- Report to User
- Output: List all guides created with line counts + technical summary (APIs, schemas, enums, screens, discrepancies)

---

## Output

BE Guide structure (10 sections):
1. Entity Verification -- column table from snapshot
2. API Contract -- endpoint table
3. Status Constants -- if applicable
4. VSA File Structure -- folder tree
5. Handler Code Patterns -- GetList, Get, Update, Delete
6. Validation Rules -- from AC-xx
7. Endpoint Registration -- MtbModuleConfig.cs code
8. Database Registration -- SQL for 4 tables (SYSFunction, SYSAction, SYSPermissions, SYSAPI)
9. Seed Data -- 3-5 INSERT rows for testing
10. Shared APIs Required -- dependencies

---

## References

- Entity snapshots: `refs/entity-snapshots/` (read before Step 2)
- Component registry: `refs/component-registry.md` (read in Step 2, update after Step 9)
- BE guide template: `refs/be-guide-template.md`
- FE Mobile guide template: `refs/fe-mobile-guide-template.md`
- FE Web guide template: `refs/fe-web-guide-template.md`
- Quality gate checklists: `refs/quality-gates.md` (run before saving any guide)
