---
name: ba-pipeline
description: >-
  Reads SRS requirement files and Figma designs, then produces BE + FE implementation guides
  with full traceability. Use when the user runs /ba-analyst, asks to "analyze requirements",
  or wants to generate coding guides from an SRS file.
  Do NOT use for writing the SRS itself (use clean-requirement skill instead).
skills:
  - figma-reader
---

# BA Pipeline Skill â€” Requirements-to-Guide Generator v3.0

> **Purpose:** Read 7-Pillar SRS â†’ analyze Figma design â†’ produce zero-ambiguity implementation guides.
> **Mission:** Read 7-Pillar SRS -> load project-specific standards -> analyze Figma design -> resolve full technical contract -> create zero-ambiguity implementation guides.
> **Quality bar:** A developer who was NOT in any meeting can implement 100% correctly on the FIRST try.
> **Standard:** Every guide section cites the source requirement (BR-xx, FR-xx, NFR-xx, AC-xx).

---

## 1. Paths

### External (Shared Pipeline -- IO only)
```
READ:   {PROJECT_PIPELINE}\requirements\     (REQ_*.md -- SRS input)
READ:   Figma MCP (figma_read)           (live designs -- ONLY source of visual truth)
WRITE:  {PROJECT_PIPELINE}\guides\           (BE_*.md + FE_*.md -- output for dev teams)
```

> **Design source priority:** 1) Figma MCP (live) 2) `{PROJECT_PIPELINE}\designs\` PNG fallback 3) SRS text only.
> **NEVER generate guides WITHOUT reading the SRS first.** SRS is the source of truth.

### Internal (BA Workspace)
```
UNIVERSAL SKILLS: .agent\skills\          (generic -- works for any project)
PROJECT KNOWLEDGE: .agent\projects\       (project-specific -- load per project)
  +-- Capstone\
      |-- PROJECT.md                      (meta + trigger rules)
      |-- domain\*.md                     (business flows, schema, rules)
      |-- standards\be-standards.md       (BE coding standards)
      |-- standards\fe-standards.md       (FE coding standards)
      +-- memory\{Feature}.md            (feature analysis history)
```

---

## 2. File Naming Convention

```
SRS Input:       REQ_{SEQ}_{FeatureName}.md
BE Guide:        BE_{SEQ}_{FeatureName}.md
FE Guide (Web):  FE_WEB_{SEQ}_{FeatureName}.md    (when Platform = Web or Both)
FE Guide (Mob):  FE_MOBWEB_{SEQ}_{FeatureName}.md (when Platform = Mobile or Both)
FE Guide:        FE_WEB_{SEQ}_{FeatureName}.md    (when Platform unspecified -- default Web)

SEQ: 3-digit zero-padded (001, 002, ...)
FeatureName: PascalCase (Receipt, Invoice, WorkOrderList)
```

---

## 3. Execution Protocol

### STEP 1 -- Auto-Scan & Select SRS

1. Scan `{PROJECT_PIPELINE}\requirements\` for `REQ_*.md` files
2. Check `{PROJECT_PIPELINE}\guides\` -- find files WITHOUT a matching guide pair
3. Rule:
   - 1 unprocessed file -> auto-select, announce: "Processing REQ_{SEQ}_{Name}.md"
   - Multiple -> list them, ask user which to process
   - 0 -> "No new requirement files. Please run /clean-requirement first."
4. If user specified a filename (`/ba-analyst REQ_003_Xxx`) -> use that file directly

---

### STEP 2 -- Read SRS (Full 7-Pillar Extraction)

Read the entire SRS file. Extract and organize into working memory:

```
PILLAR 1 -> Extract:
  - Feature Key: read from SRS metadata field. If missing, derive from filename REQ_001_{Key}.md
  - Primary Table: read from SRS metadata (e.g. tbl_SALOrderReceipt). API/DTO names derive from THIS.
  - Module code (SAL/CS/WH/HR/SYS/MTB/PART)
  - Platform: Web | Mobile | Both (determines number of FE guides)
  - Actors: role list -> role-permission matrix for guides
  - Assumptions, Dependencies, Constraints (-> guide caveats)

  NAMING RULE (derive from Feature Key + Primary Table):
    Guide files    = BE_{SEQ}_{FeatureKey}.md
    API names      = GetList + table minus tbl_ (tbl_SALOrderReceipt -> GetListSALReceipt)
    DTO names      = DTO + table minus tbl_ (DTOSALOrderReceipt)
    ENUM names     = ENUM + table minus tbl_ + Status (ENUMSALOrderReceiptStatus)
    Feature folder = F.{FeatureKey} (F.Receipt)

PILLAR 2 -> Extract:
  - ALL BR-xx rules (verbatim) with rationale
  - Group: [creation rules] [status rules] [calculation rules] [security rules]
  - Note BR-xx that blocks certain operations -> status guards in BE

PILLAR 3 -> Extract:
  - ALL FR-xx requirements with priority (High/Medium/Low)
  - ALL AC-xx-xx BDD scenarios -> these become:
      BE: validation rules + error response cases
      FE: reactive form validators + button state logic
  - Feature groups -> map to API endpoints (1 FR-group = 1 endpoint group)

PILLAR 4 -> Extract:
  - NFR-Pxx (Performance) -> API response time targets + DB index hints
  - NFR-Sxx (Security) -> auth middleware list + audit log fields
  - NFR-Uxx (Usability) -> error message format + validation UX guide
  - NFR-Rxx (Reliability) -> logging requirements + fallback behavior

PILLAR 5 -> Extract:
  - Status list + definitions -> StatusConstants (BE C#) + StatusEnum (FE TS)
  - Transition table -> state machine guard (BE) + button visibility rules (FE)
  - Invalid transitions -> 400 error responses (BE) + hidden button rules (FE)
  - Primary user flow -> API call sequence diagram in guides

PILLAR 6 -> Extract:
  - Sec. 6.1 Data consumed -> read-only fields in FE, no write endpoints needed
  - Sec. 6.2 Owned data -> editable fields + validation rules per status + DB column mapping
  - Sec. 6.3 Data exposed -> output fields other modules consume
  - Sec. 6.4 Enumerations -> IMMUTABLE contract values -> use in constants/enums ONLY
  - Sec. 6.5 Integrations -> external service dependencies in BE

PILLAR 7 -> Extract:
  - Sec. 7.1 Design Reference: Figma file name, page name, frame names -> use in STEP 3
  - Sec. 7.2 Screen inventory -> component tree
  - Sec. 7.3 Screen descriptions -> PM-described elements, business rules, visibility notes

APPENDIX A -> Extract:
  - Risks -> BE edge case handlers + FE error states

APPENDIX B -> Extract:
  - Traceability matrix -> use to validate guide completeness

APPENDIX C -> Extract:
  - TBD-xx items -> mark as -> PENDING DECISION in both guides
  - Assumptions -> mark as -> ASSUMED in guides
```

---

### STEP 3 -- Read Design (Figma MCP or Archive Images)

1. Call `figma_status` -> verify Figma Desktop + Plugin connected

2. **If NOT connected -> try design archive fallback:**

   a. Scan `{PROJECT_PIPELINE}\designs\` for feature-related folders:
      - Look for: `{feature}\mobile\*.png`, `{feature}\*.png`, `mobile\*.png`
      - Also try lowercase/kebab-case variants (e.g., `receipt`, `sales-payment`)
   
   b. **If PNG images found:**
      - Read ALL images using `view_file` (supports binary/image files)
      - Analyze: layout structure, field labels, button positions, colors, card patterns
      - Note in guides: "[Analysis from design archive images -- not live Figma]"
      - Continue to cross-reference with SRS (same as step 3d below)
   
   c. **If NO images found either:**
      - Note in guides:
        > "No design source available (Figma MCP not connected + no images in designs folder). Screen specs based on SRS Pillar 7 only."
      - Continue with SRS data only.

3. **If connected:**

   a. **Infer frame names** from SRS Pillar 7 Sec. 7.1:
      - Use "Frame / Screen Names" from Sec. 7.1 Design Reference
      - If blank -> infer from feature name (e.g., feature "Receipt" -> search Figma for "MTB020", "Receipt", "Receipt")
      
   b. **Read each screen** in order (List first, then Detail):
      ```
      figma_read scan_design        -> overview: all text, colors, components
      figma_read get_design_context -> detailed layout of selected frame (tokens, components)
      figma_read get_css            -> exact CSS for key UI elements if needed
      ```

   c. **Analyze BODY content only** (skip sidebar/header/chrome):
      - Layout structure (grid columns, form sections, dialog sizes)
      - Map all visible field labels -> cross-check against SRS Sec. 6.2 owned data
      - Map all button labels -> cross-check against SRS Sec. 5.2 transitions
      - Map colors -> SCSS design tokens (from figma-reader skill if HM project)
      - Map components -> shared components (ps-button, ps-table, etc. if HM project)

   d. **Cross-reference SRS -- Figma -- generate discrepancy table:**
      ```
      For each SRS field in Sec. 6.2:
        -> Found in Figma? [YES] [NO -> DESIGN MISSING]
      For each field visible in Figma:
        -> Found in SRS Sec. 6.2? [YES] [NO -> UNDOCUMENTED -- flag for PM review]
      For each button in Figma:
        -> Matches SRS Sec. 5.2 transition trigger? [YES] [MISMATCH -> note both]
      ```

---

### STEP 4 -- Load Project Standards (Project-Specific)

**Detect project** from SRS Pillar 1 (module code, terminology, currency):

**If Capstone ERP** (SAL / CS / WH / HR / SYS / MTB module codes, VND, Honda/3PS terms):
```
MANDATORY LOAD:
  .agent\projects\Capstone\standards\be-standards.md   (BE stack, API naming, DTO patterns)
  .agent\projects\Capstone\standards\fe-standards.md   (FE stack, Angular patterns, components)

LOAD BASED ON MODULE:
  .agent\projects\Capstone\domain\01-glossary.md
  .agent\projects\Capstone\domain\06-database-schema.md
  .agent\projects\Capstone\domain\07-business-rules.md
  .agent\projects\Capstone\domain\11-coding-standards.md
  [SAL/MTB] -> domain\03-sales-flow.md + domain\08-approval-flows.md
  [CS]      -> domain\04-service-flow.md
  [WH]      -> domain\05-warehouse-flow.md
  [SYS/HR]  -> domain\02-roles-permissions.md
  [PART]    -> domain\05-warehouse-flow.md

CHECK MEMORY:
  .agent\projects\Capstone\memory\{FeatureName}.md  -> additional context
```

**Conflict resolution (AUTO -- never ask user):**
- SRS conflicts with domain file -> **SRS wins** (newer and more specific)
- Note the override in the generated memory file
- Only ask user if SRS genuinely contradicts itself

**For non-HM projects:** Skip domain + standards files. Rely entirely on SRS.

---

### STEP 5 -- Technical Contract Analysis

> This is the most critical step. BA must resolve EVERY technical detail before writing guides.
> Output: A complete contract that developers can implement with ZERO assumptions.

#### 5.1 Platform & Guide Plan
```
FROM SRS Pillar 1 -> Platform:
  Web    -> 1 FE guide: FE_WEB_{SEQ}_{Name}.md
  Mobile -> 1 FE guide: FE_MOBWEB_{SEQ}_{Name}.md  
  Both   -> 2 FE guides: FE_WEB_*.md + FE_MOBWEB_*.md
  
Always 1 BE guide: BE_{SEQ}_{Name}.md
```

#### 5.2 API Contract Resolution
```
For each feature group in SRS Sec. 3 (FR-xx groups):
  API Name    = [GetList|Get|Update|Delete] + [ModuleCode] + [EntityName] + [suffix?]
  Endpoint    = POST /api/v1/{module}/{feature}/{action}
  Request DTO = {Feature}[Save|Filter|Cus]Request
  Response    = ApiResponse<PagedList<{Feature}Response>> | ApiResponse<{Feature}Response>

RULES (from be-standards.md Sec. 1):
  GetList{Feature}      -> POST .../list     -> {Feature}FilterRequest -> PagedList<{Feature}Response>
  Get{Feature}          -> POST .../detail   -> {Feature}CusRequest   -> {Feature}Response
  Update{Feature}       -> POST .../save     -> {Feature}SaveRequest  -> { Code, {FeatureNo} }
  Update{Feature}Status -> POST .../status   -> UpdateStatusRequest<{Feature}CusRequest>
  Delete{Feature}       -> POST .../delete   -> {Feature}CusRequest   -> { success: true }

Example for Receipt:
  GetListSALReceipt     -> POST /api/v1/sal/receipt/list
  GetSALReceipt         -> POST /api/v1/sal/receipt/detail
  UpdateSALReceipt      -> POST /api/v1/sal/receipt/save
  UpdateSALReceiptStatus-> POST /api/v1/sal/receipt/status
  DeleteSALReceipt      -> POST /api/v1/sal/receipt/delete
```

#### 5.3 DTO Schema Resolution
```
For each API, define exact DTO:

{Feature}SaveRequest (create or update):
  - Code: long (0 = create, >0 = update) -> -> MANDATORY
  - [all editable fields from SRS Sec. 6.2 where "Editable When" is not "Never"]
  - [related IDs if FK relationship]

{Feature}CusRequest (identify record):
  - Code: long -> always required
  - [other identifying fields if composite key]

{Feature}FilterRequest (list query):
  - [all filter fields from SRS Sec. 7.3 filter bar description]
  - Page: int = 1
  - PageSize: int = 20
  - DateFrom?: DateOnly
  - DateTo?: DateOnly
  - Status?: int (if status filter exists)

{Feature}Response (list + detail output):
  - [ALL fields FE needs to display -- from SRS Sec. 7.3 grid columns + detail form]
  - [StatusName: string -- always include human-readable status]
  - [related entity names -- e.g., CashierName, CustomerName]
  - [computed/aggregated fields from SRS Sec. 6.3]

FE TypeScript DTOs:
  {Module}{Feature}DTO    -> maps to {Feature}Response
  {Module}{Feature}CusDTO -> maps to {Feature}CusRequest
  File: {module}-{feature}.dto.ts
```

#### 5.4 Status & Enum Catalog
```
For each status entity in SRS Sec. 6.4 / Sec. 5.2:

BE (C#) -- in {Feature}Dto.cs or Constants/{Feature}Status.cs:
  public enum ENUM{TableName}Status
  {
    public const int {StatusName} = {TypeOfStatus int};  // from tbl_LSStatus
    public static string GetName(int? s) => ...
    public static readonly int[] EditableStatuses = [...];
    public static readonly int[] FinalStatuses = [...];
  }

FE (TypeScript) -- in e-status/{module}-{feature}-status.enum.ts:
  export enum {Module}{Feature}StatusEnum {
    {StatusName} = {TypeOfStatus int},  // must match BE
  }

For HM project -> include LSStatusTypeDataEnum value for GetListStatus() call.
```

#### 5.5 Shared Service Catalog
```
From SRS Sec. 3 (what data the feature needs from outside) + SRS Sec. 7.3 (dropdowns, pickers):

For each dropdown/picker/autocomplete in the UI:
  -> Which CORE API provides it?
  -> Which PSCoreApiService method? With what param?
  -> When to load it? (OnInit / OnDialogOpen / On{field}Change)

Catalog format:
  | Data Needed | CORE API | FE Method | TypeData/Param | Load Trigger |
  |---|---|---|---|---|
  | Cashier | GetListEmployee | coreApi.GetListEmployee() | -- | OnInit |
  | Status filter | GetListStatus | coreApi.GetListStatus(LSStatusTypeDataEnum.Receipt) | TypeData=22 | OnInit |
  | Branch | GetListHead | coreApi.GetListHead(false) | isAll=false | OnInit |
```

#### 5.6 Caching Strategy
```
List queries -> Use Redis (IDistributedCache):
  Cache key: "{module}:{feature}:list:{md5(filterParams)}"
  TTL: 5 minutes
  Invalidate: on any Update or Delete for this feature
  
  IF Redis not available -> Comment Redis lines, use IMemoryCache:
  // var cached = _memCache.Get<PagedList<...>>(cacheKey);
  // _memCache.Set(cacheKey, result, TimeSpan.FromMinutes(5));

Detail queries -> No cache (always fresh)
Status changes -> Invalidate list cache
```

#### 5.7 FE Screen--Component Mapping
```
For each SCR-xx in SRS Sec. 7.2:
  Component name: {Module}{Seq}{Feature}Component
  File path: views/{module}/views/{module}{seq}-{feature}/
  Route: /{module}/{seq}-{feature}
  
  Grid columns (Web):
    | field (camelCase) | title (Vietnamese) | width | format | sortable |
  
  Filter components:
    | ps-dropdown binding | TypeData enum | CORE API method | label |
  
  Toolbar buttons (by status):
    | Button label | Status condition (enum) | Action | Role condition |
  
  Editability matrix (Detail screen):
    | Field | Editable when Status = | Read-only when Status = |
```

---

### STEP 6 -- Analysis Summary (Display to User)

```
-- ANALYSIS: {FeatureName}
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
-- SRS: REQ_{SEQ}_{Name}.md
  [OK] Figma: {Connected -> / Not Connected ?} -- Frames: {list}
|--  Module: {SAL|CS|...} | Platform: {Web|Mobile|Both}
-- Guides: {BE_xxx.md} + {FE_WEB_xxx.md} [+ FE_MOBWEB_xxx.md if Both]

BUSINESS RULES: {N} (BR-01 to BR-{N})
  |-- Critical: {BR-xx}: {rule summary}
  +-- Calculation: {BR-xx}: {formula}

APIs: {N} endpoints
  |-- GetList{Feature}  -> POST /api/v1/{module}/{feature}/list
  |-- Get{Feature}      -> POST /api/v1/{module}/{feature}/detail
  |-- Update{Feature}   -> POST /api/v1/{module}/{feature}/save
  |-- Update{Feature}Status -> POST /api/v1/{module}/{feature}/status
  +-- Delete{Feature}   -> POST /api/v1/{module}/{feature}/delete

DTOs: {Feature}SaveRequest ({N} fields), {Feature}Response ({N} fields)
StatusEnum: {Status1}={N}, {Status2}={N}, {Status3}={N}
Shared APIs: {GetListEmployee, GetListStatus(TypeData=xx), ...}
Cache: Redis list cache (5min) + invalidate on Update/Delete

STATE MACHINE: {N} statuses
  {STATUS_A}(1) -> {STATUS_B}(2) -> {STATUS_C}(3 terminal)

FIGMA vs SRS DISCREPANCIES:
  |-- UNDOCUMENTED in SRS: {list} or "None"
  +-- MISSING in Figma: {list} or "None"
  [OK] PENDING DECISIONS: {N} items
  +-- TBD-01: {question} -> blocks FR-{xx}
  [OK] Generating guides now...
```

**Approval Gate:**
- No TBD -> Auto-proceed immediately
- TBD present but non-blocking -> Proceed + flag in guide
- Critical TBD (blocks core functionality) -> Ask user the specific question first

---

### STEP 7 -- Generate BE Guide

Save to: `{PROJECT_PIPELINE}\guides\BE_{SEQ}_{FeatureName}.md`

```markdown
# BE Implementation Guide: {FeatureName}
> **Generated from:** REQ_{SEQ}_{Name}.md (7-Pillar SRS, IEEE 29148)
> **Generated at:** {ISO timestamp}
> **Module:** {module} | **Stack:** .NET 10 + Minimal API + VSA + CQRS (MediatR) + EF Core 10 + Redis
> **Traceability:** All sections reference SRS IDs (BR-xx, FR-xx, NFR-xx, AC-xx)

---

## 1. Overview & Performance Targets

{1-paragraph business description of what this feature does from BE perspective.}

| NFR | Requirement | Source |
|---|---|---|
| P95 List APIs | < {N}s response time | NFR-P01 |
| P95 Detail APIs | < {N}s response time | NFR-P02 |
| Concurrent users | {N} simultaneous | NFR-P03 |
| Auth | JWT Bearer required on all endpoints | NFR-S01 |
| Audit | CreatedBy/UpdatedBy from ICurrentUserService | NFR-S04 |
| HEAD filter | All list queries MUST filter by _currentUser.CompanyId | BR-{nn} |

---

## 2. API Contract

> POST-only endpoints. No GET/PUT/DELETE REST conventions.

| API Name | Endpoint | Request DTO | Response | Cache |
|---|---|---|---|---|
| GetList{Feature} | POST /api/v1/{module}/{feature}/list | {Feature}FilterRequest | ApiResponse<PagedList<{Feature}Response>> | Redis 5min |
| Get{Feature} | POST /api/v1/{module}/{feature}/detail | {Feature}CusRequest | ApiResponse<{Feature}Response> | None |
| Update{Feature} | POST /api/v1/{module}/{feature}/save | {Feature}SaveRequest | ApiResponse<{Code,{FeatureNo}}> | Invalidates list |
| Update{Feature}Status | POST /api/v1/{module}/{feature}/status | UpdateStatusRequest<{Feature}CusRequest> | ApiResponse<object> | Invalidates list |
| Delete{Feature} | POST /api/v1/{module}/{feature}/delete | {Feature}CusRequest | ApiResponse<object> | Invalidates list |

---

## 3. DTO Definitions

> File location: `modules/Capstone.ERP.Modules.{Module}/Features/{Feature}/{Feature}Dto.cs`

### {Feature}SaveRequest (Create or Update -- Code=0->INSERT, Code>0->UPDATE)
```csharp
public record {Feature}SaveRequest(
    long Code,                     // 0=create, >0=update  [FR-{nn}]
    {type} {field},               // {description} [BR-{nn}]
    {type}? {optionalField}       // optional -- {description}
);
```

### {Feature}CusRequest (Identify record -- used in Get/Delete/Status)
```csharp
public record {Feature}CusRequest(
    long Code                      // {Feature} primary key
);
```

### {Feature}FilterRequest (List query params)
```csharp
public record {Feature}FilterRequest(
    DateOnly? DateFrom,            // SRS Sec. 7.3 filter bar [FR-{nn}]
    DateOnly? DateTo,
    int? Status,                   // null = all statuses
    int Page = 1,
    int PageSize = 20
);
```

### {Feature}Response (Output -- list rows + detail view)
```csharp
public record {Feature}Response(
    long Code,
    string {FeatureNo},            // auto-generated number
    {type} {field},               // {from SRS Sec. 6.2 / Sec. 7.3 grid columns}
    int Status,
    string StatusName,             // human-readable -- from {Feature}Status.GetName()
    {type} {joinedField}Name,     // joined from {OtherTable}
    DateTimeOffset CreatedAt,
    string CreatedByName
);
```

---

## 4. Status & Enum Definitions

> Source: SRS Sec. 6.4 + Sec. 5.2 Transition Table
> **IMMUTABLE** -- values map to `tbl_LSStatus TypeData={XX}`

### BE C# (StatusConstants)
```csharp
// File: modules/.../Features/{Feature}/{Feature}Dto.cs
public enum ENUM{TableName}Status
{
    public const int {StatusName1} = {N};   // TypeOfStatus={N}, display: "{Display}" -- [SRS Sec. 6.4]
    public const int {StatusName2} = {N};
    public const int {StatusName3} = {N};   // TERMINAL

    private static readonly Dictionary<int, string> _names = new()
    {
        [{StatusName1}] = "{Display1}",
        [{StatusName2}] = "{Display2}",
        [{StatusName3}] = "{Display3}"
    };

    public static string GetName(int? s) =>
        s.HasValue && _names.TryGetValue(s.Value, out var n) -> n : "Unknown";

    public static readonly int[] EditableStatuses = [{StatusName1}];
    public static readonly int[] FinalStatuses    = [{StatusName2}, {StatusName3}];
}
```

---

## 5. VSA File Structure

```
modules/Capstone.ERP.Modules.{Module}/
+-- Features/
    +-- {Feature}/
        |-- {Feature}Endpoints.cs           -> Route registration + MediatR dispatch
        |-- GetList{Feature}Query.cs        -> CQRS Query record
        |-- GetList{Feature}Handler.cs      -> EF Core query + Redis cache
        |-- Get{Feature}Query.cs
        |-- Get{Feature}Handler.cs
        |-- Update{Feature}Command.cs       -> CQRS Command record
        |-- Update{Feature}Handler.cs       -> Business logic + DB write
        |-- UpdateStatus{Feature}Command.cs -> Status change command
        |-- UpdateStatus{Feature}Handler.cs -> Status transition guard
        |-- Delete{Feature}Command.cs
        |-- Delete{Feature}Handler.cs
        +-- {Feature}Dto.cs                 -> All DTOs + StatusConstants
```

---

## 6. Handler Logic (Step-by-Step)

### GetList{Feature}Handler
```
Step 1: Build Redis cache key = "{module}:{feature}:list:{md5(filter)}"
Step 2: Try cache.GetStringAsync(key) -> return if hit
        [Comment out Redis -> use IMemoryCache if Redis not setup]
Step 3: Query tbl_{PrimaryTable}
        -> .Where(x => !x.IsDeleted)                         -> soft delete
        -> .Where(x => x.Head == _currentUser.CompanyId)       -> HEAD-01 -> MANDATORY
        -> .Where(x => filter.DateFrom == null || x.CreatedDate >= filter.DateFrom)
        -> .Where(x => filter.Status == null || x.Status == filter.Status)
        -> .AsNoTracking()                                    -> read-only -> performance
Step 4: LeftJoin tbl_{RelatedTable} for joined names (.NET 10 native LeftJoin)
Step 5: Project to {Feature}Response record
Step 6: Order + paginate: .OrderByDescending(x => x.Code).Skip().Take()
Step 7: CountAsync for total
Step 8: Build PagedList<{Feature}Response> { Data, Total, Page, PageSize }
Step 9: Set cache (5min TTL) [Comment out if no Redis]
Step 10: Return ApiResponse<PagedList<{Feature}Response>>.Ok(result)
```

### Update{Feature}Handler
```
Step 1: Validate request fields (from SRS AC-xx)
        -> {field} required? -> return BadRequest({message from SRS})
        -> {amount} > 0? -> check from SRS BR-xx

Step 2: if Code == 0 -> CREATE branch:
        -> Verify no duplicate {uniqueField} (if BR-xx requires uniqueness)
        -> Generate {FeatureNo} via SysIncreaseService.NextAsync("{PREFIX}")
        -> new tbl_{PrimaryTable} {
            Head      = _currentUser.CompanyId,    -> ICurrentUserService -- NEVER hardcode
            Cashier   = _currentUser.LegacyUserId,
            CreatedBy = _currentUser.UserCode,
            CreatedDate = DateTime.UtcNow,
            Status    = {Feature}Status.{InitialStatus}
          }
        -> db.{PrimaryTable}s.Add(entity)

Step 3: if Code > 0 -> UPDATE branch:
        -> Load entity: db.{PrimaryTable}s.FirstOrDefaultAsync(x => x.Code == Code && !x.IsDeleted)
        -> If null -> return NotFound("{Feature} not found")
        -> Status guard: if not in EditableStatuses -> return BadRequest("{message}")
        -> Map changed fields from request
        -> entity.UpdatedBy = currentUser.UserName
        -> entity.UpdatedDate = DateTime.UtcNow

Step 4: db.SaveChangesAsync(ct)
Step 5: Invalidate Redis cache for this feature's list keys [comment if no Redis]
Step 6: Return ApiResponse<object>.Ok(new { entity.Code, entity.{FeatureNo} })
```

### UpdateStatus{Feature}Handler
```
Step 1: Load entity by Code -> check exists + not deleted
Step 2: Look up transition table (from SRS Sec. 5.2):
        Resolve: (currentStatus, targetStatus) -> allowed?
        If not allowed -> return BadRequest("Cannot transition from {from} to {to}")
Step 3: Require reason if targetStatus is Cancelled (from SRS BR-xx)
Step 4: entity.Status = targetStatus
        entity.{StatusDate} = DateTime.UtcNow  (if applicable)
        Log status change to tbl_LOGStatus (if required by SRS NFR-S04)
Step 5: db.SaveChangesAsync(ct)
Step 6: Invalidate cache [comment if no Redis]
Step 7: Return ApiResponse<object>.Ok(new { entity.Code, entity.Status })
```

---

## 7. Shared APIs Required (APICORE)

> BA MUST list which CORE APIs this feature relies on.

| CORE API | Module | When Called | Notes |
|---|---|---|---|
| {GetListXxx} | CORE | {When/trigger} | TypeData={N} if applicable |

---

## 8. Validation Rules

> Source: SRS Sec. 3 Acceptance Criteria (AC-xx)

| Rule | Condition | Error Message | Source |
|---|---|---|---|
| {Field} required | `{field} == null or empty` | "{field} is required" | AC-{nn}-{nn} |
| Amount > 0 | `amount <= 0` | "Amount must be greater than 0" | BR-{nn} |
| Status editable | `status not in EditableStatuses` | "Cannot edit in status {statusName}" | BR-{nn} |

---

## 9. Figma -- SRS Discrepancy Report

| Type | Field/Element | Details | Recommended Action |
|---|---|---|---|
| UNDOCUMENTED | {field in Figma, not in SRS} | Found in {screen}, not in SRS Sec. 6.2 | Confirm with PM -> add to SRS |
| DESIGN MISSING | {field in SRS, not in Figma} | In SRS Sec. 6.2, frame {SCR-xx} missing | Request design update |
| LABEL MISMATCH | {button} | SRS: "{A}" / Figma: "{B}" | SRS wins -> implement as "{A}" |

---

## 10. Pending Decisions

| ID | Question | Blocks | Assigned To |
|---|---|---|---|
| TBD-{nn} | {question from SRS Appendix C} | FR-{nn} | {stakeholder} |
```

---

### STEP 8 -- Generate FE Web Guide (if Platform = Web or Both)

Save to: `{PROJECT_PIPELINE}\guides\FE_WEB_{SEQ}_{FeatureName}.md`

```markdown
# FE Web Implementation Guide: {FeatureName}
> **Generated from:** REQ_{SEQ}_{Name}.md + Figma Analysis
> **Generated at:** {ISO timestamp}
> **Module:** {module} | **Platform:** Web (Capstone.FEWeb -- Angular 16 + Kendo UI 13)
> **Stack:** Angular 16, Kendo UI 13, SCSS, PSAPIService, PSCoreApiService

---

## 1. Overview

{Brief description of what FE needs to implement. List all screens.}

**Screens:**
| Screen ID | Component Name | Route | File Path |
|---|---|---|---|
| SCR-01 | {Module}{Seq}{Feature}Component | /{module}/{seq}-{feature} | views/{module}/views/{module}{seq}-{feature}/ |
| SCR-02 | {Module}{Seq}{Feature}DetailComponent | /{module}/{seq}-{feature}-detail | views/{module}/views/{module}{seq}-{feature}-detail/ |

---

## 2. Service Files

### {module}-api-static.service.ts -- URL Constants
```typescript
// File: views/{module}/services/{module}-api-static.service.ts
// ADD these URL constants (preserve existing ones):
export class {Module}ApiStaticService {
  static readonly {DLL_KEY} = {
    GetList{Feature}:          'api/v1/{module}/{feature}/list',
    Get{Feature}:              'api/v1/{module}/{feature}/detail',
    Update{Feature}:           'api/v1/{module}/{feature}/save',
    Update{Feature}Status:     'api/v1/{module}/{feature}/status',
    Delete{Feature}:           'api/v1/{module}/{feature}/delete',
  };
}
```

### {module}-api.service.ts -- Service Methods
```typescript
// INJECT: PSAPIService, PSGetConfigService
// IMPORT: {Feature}CusDTO, UpdatePropertiesInterface, UpdateStatusInterface

// Add these methods:
GetList{Feature}(param: State): Observable<ResponseDTO> { /* standard Observable pattern */ }
Get{Feature}(param: {Module}{Feature}CusDTO): Observable<ResponseDTO> { /* standard */ }
Update{Feature}(param: UpdatePropertiesInterface<{Module}{Feature}CusDTO>): Observable<ResponseDTO> { }
Update{Feature}Status(param: UpdateStatusInterface<{Module}{Feature}CusDTO>): Observable<ResponseDTO> { }
Delete{Feature}(param: {Module}{Feature}CusDTO): Observable<ResponseDTO> { }
```
[See fe-standards.md Sec. 3 for exact Observable pattern]

---

## 3. DTO Files

### {module}-{feature}.dto.ts
```typescript
// File: models/dtos/e-dtos/{module}-{feature}.dto.ts

export interface {Module}{Feature}DTO {
  Code: number;
  {FeatureNo}: string;
  {field}: {type};           // SRS Sec. 6.2 -- {description}
  Status: number;
  StatusName: string;
  {JoinedEntity}Name: string; // joined field
  CreatedAt: string;
  CreatedByName: string;
}

export interface {Module}{Feature}CusDTO {
  Code: number;               // always -- identifies record
}
```

---

## 4. Enum Files

### e-status/{module}-{feature}-status.enum.ts
```typescript
// File: models/enums/e-status/{module}-{feature}-status.enum.ts
export enum {Module}{Feature}StatusEnum {
  {StatusName1} = {N},  // "{Display1}" -- maps to BE {Feature}Status.{StatusName1}
  {StatusName2} = {N},  // "{Display2}"
  {StatusName3} = {N},  // "{Display3}" -- TERMINAL
}
```

### LSStatusTypeDataEnum value for GetListStatus()
```typescript
// Use: coreApi.GetListStatus(LSStatusTypeDataEnum.{X})
// Where TypeData = {N}  (from tbl_LSStatus -- HM DB)
```

---

## 5. Shared Core Services to Inject

| Data | FE Method | TypeData/Param | Load When |
|---|---|---|---|
| {Dropdown label} | coreApi.{GetListXxx}({param}) | {param value} | {OnInit / OnOpen / On{Field}Change} |

---

## 6. Screen Specifications

### SCR-01: {Feature} List Screen

**Kendo Grid Columns:**
| field | title | width | format | sortable | notes |
|---|---|---|---|---|---|
| {featureNo} | "No. {feature}" | 120 | -- | true | [FR-{nn}] |
| {amount} | "{Label}" | 150 | "{0:n0}" | true | VND format |
| {statusName} | "Status" | 120 | -- | true | badge color per status |

**Filter Bar Components:**
| Component | Binding | API Call | Label |
|---|---|---|---|
| kendo-daterangepicker | dateFrom / dateTo | - | "From date - To date" |
| ps-dropdown | statusFilter | coreApi.GetListStatus(TypeData={N}) | "Status" |

**Toolbar Buttons (by status / role):**
| Button | Label | Visible when | Action |
|---|---|---|---|
| Add | "Add New" | Always | openDialog(null) |
| Edit | "Edit" | row.Status = {StatusName1} | openDialog(row) |
| {Approve} | "{Label}" | Status={StatusName1}, Role={Role} | callUpdateStatus({StatusName2}) |
| Delete | "Delete" | Status={StatusName1} | confirmDelete(row) |

### SCR-02: {Feature} Detail Screen

**Form Fields (Editability Matrix):**
| Field | Label | Component | Editable when Status = | Source |
|---|---|---|---|---|
| {field} | "{Label}" | ps-input | {StatusName1} | SRS Sec. 6.2 |
| {amount} | "{label}" | kendo-numerictextbox | {StatusName1} | SRS Sec. 6.2 |
| {statusName} | "Status" | badge | Read-only always | -- |

**Action Buttons (Detail):**
| Button | Label | Show when | Action |
|---|---|---|---|
| Save | "Save" | Status={StatusName1} | callUpdate() |
| {Submit} | "{Label}" | Status={StatusName1} | callUpdateStatus({N}) |
| Cancel | "Cancel Transaction" | Status={StatusName1} | confirmCancel() with reason |

---

## 7. Status Badge & Rendering

```typescript
// In component class -- expose enum
{Feature}Status = {Module}{Feature}StatusEnum;

getStatusClass(status: number): string {
  return {
    [{Module}{Feature}StatusEnum.{Name1}]: 'badge badge-warning',
    [{Module}{Feature}StatusEnum.{Name2}]: 'badge badge-success',
    [{Module}{Feature}StatusEnum.{Name3}]: 'badge badge-danger',
  }[status] -> 'badge badge-secondary';
}
```

---

## 8. Validation (Reactive Forms)

```typescript
// Form group -- cite FR-xx for each validator
this.form = this.fb.group({
  {field}: [null, [Validators.required]],           // AC-{nn}-{nn}: required
  {amount}: [null, [Validators.min(1)]],            // AC-{nn}-{nn}: must > 0
});
```

---

## 9. Layout Rules

```
1. Page structure: ps-layout -> ps-toolbar-top -> ps-table / form
2. Scroll: table container: overflow-x: auto (zoom support)
3. Buttons: ONLY inside ps-toolbar -- never floating/absolute
4. Loading: kendo-loader for all API calls
5. Empty grid: show "No data available" -- never blank grid
6. Empty state: {Business-specific empty state message from SRS}
```

---

## 10. Figma -- SRS Discrepancies

| Type | Element | Details | Action |
|---|---|---|---|
| UNDOCUMENTED | {element} | In Figma {frame}, not in SRS | Implement if PM confirms |
| MISSING | {element} | In SRS, missing in Figma | Implement per SRS spec |
| MISMATCH | {element} | SRS: "{A}" / Figma: "{B}" | Use SRS version: "{A}" |

---

## 11. Pending Decisions

| TBD | Question | Blocks | Temp Implementation |
|---|---|---|---|
| TBD-{nn} | {question} | {FR-nn} | {temporary workaround if any} |
```

---

### STEP 9 -- Generate FE Mobile Guide (if Platform = Mobile or Both)

Save to: `{PROJECT_PIPELINE}\guides\FE_MOBWEB_{SEQ}_{FeatureName}.md`

```markdown
# FE Mobile Implementation Guide: {FeatureName}
> **Platform:** Mobile (Capstone.FEMobileWeb -- Angular 16, Responsive)
> **Key differences from Web:** No Kendo Grid, card-based lists, bottom action bar, touch targets 44px+

---
## 1. Overview
## 2. Service Files (same {module}-api.service.ts -- reuse, no changes needed if already created for web)
## 3. DTO Files (same as Web guide)
## 4. Enum Files (same as Web guide)
## 5. Shared Core Services (same as Web guide)
## 6. Screen Specs (Mobile-specific):
   - List as card layout (ul/li) NOT kendo-grid
   - Each card shows: {top 3-4 key fields}
   - Card tap -> navigate to detail route
   - Sticky bottom action bar for primary actions
## 7. Form Layout (Detail):
   - 1-column layout, full-width inputs
   - Label above input (not side-by-side)
   - Button min-height: 44px
## 8. Navigation Pattern:
   - router.navigate with back button (History API)
   - Back button in top bar
## 9. Pending Decisions
```

---

### STEP 10 -- Save Memory File

```
Path: .agent\projects\Capstone\memory\{FeatureName}.md (if HM project)

Content:
- SRS filename + key design decisions
- API names resolved (final)
- Status values resolved
- Discrepancies found + how resolved
- TBD items still open
- Key business rules to remember for future iterations
```

---

### STEP 11 -- Report to User

```
  [OK] BA Analysis Complete: {FeatureName}
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-?*?*
-- SRS: REQ_{SEQ}_{Name}.md
  [OK] Figma: {status}

-- Guides created:
   -> {PROJECT_PIPELINE}\guides\BE_{SEQ}_{Name}.md        ({N} lines)
   -> {PROJECT_PIPELINE}\guides\FE_WEB_{SEQ}_{Name}.md    ({N} lines)  [if Web/Both]
   -> {PROJECT_PIPELINE}\guides\FE_MOBWEB_{SEQ}_{Name}.md    ({N} lines)  [if Mobile/Both]

-- Technical Summary:
   APIs:     {N} endpoints (GetList, Get, Update, UpdateStatus, Delete)
   DTOs:     {N} DTO types defined
   Enums:    {N} status constants + {N} TypeScript enums
   Shared:   {N} PSCoreApiService methods required
   Cache:    Redis list cache (5min) + {N} invalidation triggers
   Screens:  {N} screens ({Web grid + detail} / {Mobile card + form})
  [OK]  Discrepancies: {N} Figma vs SRS conflicts -> see Sec. 10 in FE guides
  [OK]  Pending:       {N} TBD items -> {list which FRs blocked}

--- Next steps:
   BE team  -> read BE_{SEQ}_{Name}.md
   FE team  -> read FE_WEB_{SEQ}_{Name}.md [+ FE_MOB if applicable]
   PM/BA    -> resolve TBD items before sprint start
```

---

## 4. Quality Gates -- -> MANDATORY Before Saving Any Guide

### BE Guide Checklist
```
[ ] All 5 API endpoints defined (GetList/Get/Update/UpdateStatus/Delete)
[ ] ALL DTO types defined with full field lists (not "... other fields")
[ ] Status constants defined with EXACT int values from tbl_LSStatus
[ ] StatusGetName() method included
[ ] HEAD filter explicitly mentioned in every list handler
[ ] ICurrentUserService injection mandatory for all write handlers
[ ] Redis cache strategy documented (key pattern + TTL + invalidation)
[ ] Validation rules cite SRS AC-xx (not generic rules)
[ ] Shared APIs listed (which CORE APIs, with TypeData enums)
[ ] VSA file structure shows exact file names
[ ] Figma discrepancy table included (even if empty -- write "None")
[ ] All TBD-xx items flagged with [!] 
```

### FE Web Guide Checklist
```
[ ] Service file pattern correct (PSAPIService + Observable<ResponseDTO>)
[ ] Static service URLs correct (POST only -- no GET/PUT/DELETE)
[ ] DTO interfaces complete + Cus interface included
[ ] Enum file defined + maps to BE StatusConstants values
[ ] PSCoreApiService catalog complete (all dropdowns accounted for)
[ ] Grid columns table: field, title, width, format, sortable
[ ] Toolbar buttons table: label, status condition (enum -- NO magic numbers), action
[ ] Editability matrix: field |- status (from SRS Sec. 6.2 "Editable When")
[ ] Layout rules mentioned (scroll, buttons in toolbar, loading state)
[ ] Status badge getStatusClass() method defined
[ ] Figma discrepancy table included
[ ] All TBD-xx items flagged
```

### FE Mobile Guide Checklist
```
[ ] Service files: reference web service if already created (no duplication)
[ ] Card layout spec: which fields in each card
[ ] Bottom action bar: buttons + status conditions
[ ] 44px minimum touch target mentioned
[ ] Navigation with back button pattern included
```

---

## 5. Universal Adaptation Rules

| Project Type | Adaptation |
|---|---|
| **Capstone ERP** | Load `projects/Capstone/` -- use HM standards, module codes, VND |
| **Any other project** | Do NOT load projects/Capstone/ -- use only SRS content |
| **Stack unknown** | Infer from SRS technology constraints or ask once |
| **Platform unknown** | Default to Web only |

> **GOLDEN RULE:** Never output a guide with placeholder text like "{api_name}" or "{field}".
> Every single field, method name, endpoint path, enum value MUST be concrete and project-specific.
> If information is genuinely unknown -> write "? TBD: {specific question}" -- NOT a generic placeholder.
