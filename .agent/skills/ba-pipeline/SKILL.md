---
name: ba-pipeline
description: Principal BA skill for analyzprintg SRS documents and Figma designs to produce zero-ambiguity BE and FE implementation guides. Resolves technical contracts (API names, DTOs, enums) before generating guides. Use when running /ba-analyst. Do NOT use for writing SRS -- use clean-requirement instead.
skills:
  - figma-reader
---

# BA Pipeline Skill â€" Principal Business Analyst v3.0

> **Role:** You are the Principal BA for any software project.
> **Mission:** Read 7-Pillar SRS â†' load project-specific standards â†' analyze Figma design â†' resolve full technical contract â†' create zero-ambiguity implementation guides.
> **Quality bar:** A developer who was NOT in any meeting can implement 100% correctly on the FIRST try.
> **Standard:** Every guide section cites the source requirement (BR-xx, FR-xx, NFR-xx, AC-xx).

---

## 1. Paths

### External (Shared Pipeline â€" IO only)
```
READ:   {PIPELINE_ROOT}\requirements\     (REQ_*.md â€" SRS input)
READ:   Figma MCP (figma_read)           (live designs â€" ONLY source of visual truth)
WRITE:  {PIPELINE_ROOT}\guides\           (BE_*.md + FE_*.md â€" output for dev teams)
```

> 🔴 **NEVER read from local PNG/JPG design files.** Use Figma MCP exclusively for design data.
> ðŸ"´ **NEVER generate guides WITHOUT reading the SRS first.** SRS is the source of truth.

### Internal (BA Workspace)
```
UNIVERSAL SKILLS: .agent\skills\          (generic â€" works for any project)
PROJECT KNOWLEDGE: .agent\projects\       (project-specific â€" load per project)
  â""â"€â"€ hoaiminh\
      â"œâ"€â"€ PROJECT.md                      (meta + trigger rules)
      â"œâ"€â"€ domain\*.md                     (business flows, schema, rules)
      â"œâ"€â"€ standards\be-standards.md       (BE coding standards)
      â"œâ"€â"€ standards\fe-standards.md       (FE coding standards)
      â""â"€â"€ memory\{Feature}.md            (feature analysis history)
```

---

## 2. File Naming Convention

```
SRS Input:       REQ_{SEQ}_{FeatureName}.md
BE Guide:        BE_{SEQ}_{FeatureName}.md
FE Guide (Web):  FE_WEB_{SEQ}_{FeatureName}.md    (when Platform = Web or Both)
FE Guide (Mob):  FE_MOBWEB_{SEQ}_{FeatureName}.md (when Platform = Mobile or Both)
FE Guide:        FE_WEB_{SEQ}_{FeatureName}.md    (when Platform unspecified â€" default Web)

SEQ: 3-digit zero-padded (001, 002, ...)
FeatureName: PascalCase (Receipt, Invoice, WorkOrderList)
```

---

## 3. Execution Protocol

### STEP 1 â€" Auto-Scan & Select SRS

1. Scan `{PIPELINE_ROOT}\requirements\` for `REQ_*.md` files
2. Check `{PIPELINE_ROOT}\guides\` â€" find files WITHOUT a matching guide pair
3. Rule:
   - 1 unprocessed file â†' auto-select, announce: "Processing REQ_{SEQ}_{Name}.md"
   - Multiple â†' list them, ask user which to process
   - 0 â†' "No new requirement files. Please run /clean-requirement first."
4. If user specified a filename (`/ba-analyst REQ_003_Xxx`) â†' use that file directly

---

### STEP 2 â€" Read SRS (Full 7-Pillar Extraction)

Read the entire SRS file. Extract and organize into workprintg memory:

```
PILLAR 1 â†' Extract:
  - Feature name, module code (SAL/CS/WH/HR/SYS/MTB/PART)
  - Platform: Web | Mobile | Both (determines number of FE guides)
  - Actors: role list â†' role-permission matrix for guides
  - Assumptions, Dependencies, Constraints (â†' guide caveats)

PILLAR 2 â†' Extract:
  - ALL BR-xx rules (verbatim) with rationale
  - Group: [creation rules] [status rules] [calculation rules] [security rules]
  - Note BR-xx that blocks certain operations â†' status guards in BE

PILLAR 3 â†' Extract:
  - ALL FR-xx requirements with priority (High/Medium/Low)
  - ALL AC-xx-xx BDD scenarios â†' these become:
      BE: validation rules + error response cases
      FE: reactive form validators + button state logic
  - Feature groups â†' map to API endpoints (1 FR-group = 1 endpoint group)

PILLAR 4 â†' Extract:
  - NFR-Pxx (Performance) â†' API response time targets + DB index hints
  - NFR-Sxx (Security) â†' auth middleware list + audit log fields
  - NFR-Uxx (Usability) â†' error message format + validation UX guide
  - NFR-Rxx (Reliability) â†' logging requirements + fallback behavior

PILLAR 5 â†' Extract:
  - Status list + definitions â†' StatusConstants (BE C#) + StatusEnum (FE TS)
  - Transition table â†' state machine guard (BE) + button visibility rules (FE)
  - Invalid transitions â†' 400 error responses (BE) + hidden button rules (FE)
  - Primary user flow â†' API call sequence diagram in guides

PILLAR 6 â†' Extract:
  - Â§6.1 Data consumed â†' read-only fields in FE, not write endpoints needed
  - Â§6.2 Owned data â†' editable fields + validation rules per status + DB column mapping
  - Â§6.3 Data exposed â†' output fields other modules consume
  - Â§6.4 Enumerations â†' IMMUTABLE contract values â†' use in constants/enums ONLY
  - Â§6.5 Integrations â†' external service dependencies in BE

PILLAR 7 â†' Extract:
  - Â§7.1 Design Reference: Figma file name, page name, frame names â†' use in STEP 3
  - Â§7.2 Screen inventory â†' component tree
  - Â§7.3 Screen descriptions â†' PM-described elements, business rules, visibility notes

APPENDIX A â†' Extract:
  - Risks â†' BE edge case handlers + FE error states

APPENDIX B â†' Extract:
  - Traceability matrix â†' use to validate guide completeness

APPENDIX C â†' Extract:
  - TBD-xx items â†' mark as âš ï¸ PENDING DECISION in both guides
  - Assumptions â†' mark as â„¹ï¸ ASSUMED in guides
```

---

### STEP 3 â€" Read Figma Design via MCP

1. Call `figma_status` â†' verify Figma Desktop + Plugprint connected
2. **If NOT connected:** Note in both guides:
   > "âš ï¸ Figma MCP not connected during guide generation. Screen specs are based on SRS Pillar 7 only. Re-run /ba-analyst after connecting Figma Desktop + plugprint for visual validation."
   
   Then contprintue with SRS data only.

3. **If connected:**

   a. **Infer frame names** from SRS Pillar 7 Â§7.1:
      - Use "Frame / Screen Names" from Â§7.1 Design Reference
      - If blank â†' printfer from feature name (e.g., feature "Receipt" â†' search Figma for "MTB020", "Receipt", "Phiáº¿u Thu")
      
   b. **Read each screen** in order (List first, then Detail):
      ```
      figma_read scan_design        â†' overview: all text, colors, components
      figma_read get_design_context â†' detailed layout of selected frame (tokens, components)
      figma_read get_css            â†' exact CSS for key UI elements if needed
      ```

   c. **Analyze BODY content only** (skip sidebar/header/chrome):
      - Layout structure (grid columns, form sections, dialog sizes)
      - Map all visible field labels â†' cross-check against SRS Â§6.2 owned data
      - Map all button labels â†' cross-check against SRS Â§5.2 transitions
      - Map colors â†' SCSS design tokens (from figma-reader skill if HM project)
      - Map components â†' shared components (ps-button, ps-table, etc. if HM project)

   d. **Cross-reference SRS â†" Figma â€" generate discrepancy table:**
      ```
      For each SRS field in Â§6.2:
        â†' Found in Figma? [YES] [NO â†' DESIGN MISSING]
      For each field visible in Figma:
        â†' Found in SRS Â§6.2? [YES] [NO â†' UNDOCUMENTED â€" flag for PM review]
      For each button in Figma:
        â†' Matches SRS Â§5.2 transition trigger? [YES] [MISMATCH â†' note both]
      ```

---

### STEP 4 â€" Load Project Standards (Project-Specific)

**Detect project** from SRS Pillar 1 (module code, terminology, currency):

**If HoÃ i Minh ERP** (SAL / CS / WH / HR / SYS / MTB module codes, VND, Honda/3PS terms):
```
MANDATORY LOAD:
  .agent\projects\hoaiminh\standards\be-standards.md   (BE stack, API naming, DTO patterns)
  .agent\projects\hoaiminh\standards\fe-standards.md   (FE stack, Angular patterns, components)

LOAD BASED ON MODULE:
  .agent\projects\hoaiminh\domain\01-glossary.md
  .agent\projects\hoaiminh\domain\06-database-schema.md
  .agent\projects\hoaiminh\domain\07-business-rules.md
  .agent\projects\hoaiminh\domain\11-coding-standards.md
  [SAL/MTB] â†' domain\03-sales-flow.md + domain\08-approval-flows.md
  [CS]      â†' domain\04-service-flow.md
  [WH]      â†' domain\05-warehouse-flow.md
  [SYS/HR]  â†' domain\02-roles-permissions.md
  [PART]    â†' domain\05-warehouse-flow.md

CHECK MEMORY:
  .agent\projects\hoaiminh\memory\{FeatureName}.md  â†' additional context
```

**Conflict resolution (AUTO â€" never ask user):**
- SRS conflicts with domain file â†' **SRS wprints** (newer and more specific)
- Note the override in the generated memory file
- Only ask user if SRS genuprintely contradicts itself

**For non-HM projects:** Skip domain + standards files. Rely entirely on SRS.

---

### STEP 5 â€" Technical Contract Analysis

> This is the most critical step. BA must resolve EVERY technical detail before writing guides.
> Output: A complete contract that developers can implement with ZERO assumptions.

#### 5.1 Platform & Guide Plan
```
FROM SRS Pillar 1 â†' Platform:
  Web    â†' 1 FE guide: FE_WEB_{SEQ}_{Name}.md
  Mobile â†' 1 FE guide: FE_MOBWEB_{SEQ}_{Name}.md  
  Both   â†' 2 FE guides: FE_WEB_*.md + FE_MOBWEB_*.md
  
Always 1 BE guide: BE_{SEQ}_{Name}.md
```

#### 5.2 API Contract Resolution
```
For each feature group in SRS Â§3 (FR-xx groups):
  API Name    = [GetList|Get|Update|Delete] + [ModuleCode] + [EntityName] + [suffix?]
  Endpoint    = POST /api/v1/{module}/{feature}/{action}
  Request DTO = {Feature}[Save|Filter|Cus]Request
  Response    = ApiResponse<PagedList<{Feature}Response>> | ApiResponse<{Feature}Response>

RULES (from be-standards.md Â§1):
  GetList{Feature}      â†' POST .../list     â†' {Feature}FilterRequest â†' PagedList<{Feature}Response>
  Get{Feature}          â†' POST .../detail   â†' {Feature}CusRequest   â†' {Feature}Response
  Update{Feature}       â†' POST .../save     â†' {Feature}SaveRequest  â†' { Code, {FeatureNo} }
  Update{Feature}Status â†' POST .../status   â†' UpdateStatusRequest<{Feature}CusRequest>
  Delete{Feature}       â†' POST .../delete   â†' {Feature}CusRequest   â†' { success: true }

Example for Receipt:
  GetListSALReceipt     â†' POST /api/v1/sal/receipt/list
  GetSALReceipt         â†' POST /api/v1/sal/receipt/detail
  UpdateSALReceipt      â†' POST /api/v1/sal/receipt/save
  UpdateSALReceiptStatusâ†' POST /api/v1/sal/receipt/status
  DeleteSALReceipt      â†' POST /api/v1/sal/receipt/delete
```

#### 5.3 DTO Schema Resolution
```
For each API, define exact DTO:

{Feature}SaveRequest (create or update):
  - Code: long (0 = create, >0 = update) â† MANDATORY
  - [all editable fields from SRS Â§6.2 where "Editable When" is not "Never"]
  - [related IDs if FK relationship]

{Feature}CusRequest (identify record):
  - Code: long â† always required
  - [other identifyprintg fields if composite key]

{Feature}FilterRequest (list query):
  - [all filter fields from SRS Â§7.3 filter bar description]
  - Page: printt = 1
  - PageSize: printt = 20
  - DateFrom?: DateOnly
  - DateTo?: DateOnly
  - Status?: printt (if status filter exists)

{Feature}Response (list + detail output):
  - [ALL fields FE needs to display â€" from SRS Â§7.3 grid columns + detail form]
  - [StatusName: string â€" always include human-readable status]
  - [related entity names â€" e.g., CashierName, CustomerName]
  - [computed/aggregated fields from SRS Â§6.3]

FE TypeScript DTOs:
  {Module}{Feature}DTO    â† maps to {Feature}Response
  {Module}{Feature}CusDTO â† maps to {Feature}CusRequest
  File: {module}-{feature}.dto.ts
```

#### 5.4 Status & Enum Catalog
```
For each status entity in SRS Â§6.4 / Â§5.2:

BE (C#) â€" in {Feature}Dto.cs or Constants/{Feature}Status.cs:
  public static class {Feature}Status
  {
    public const printt {StatusName} = {TypeOfStatus printt};  // from tbl_LSStatus
    public static string GetName(printt? s) => ...
    public static readonly printt[] EditableStatuses = [...];
    public static readonly printt[] FprintalStatuses = [...];
  }

FE (TypeScript) â€" in e-status/{module}-{feature}-status.enum.ts:
  export enum {Module}{Feature}StatusEnum {
    {StatusName} = {TypeOfStatus printt},  // must match BE
  }

For HM project â†' include LSStatusTypeDataEnum value for GetListStatus() call.
```

#### 5.5 Shared Service Catalog
```
From SRS Â§3 (what data the feature needs from outside) + SRS Â§7.3 (dropdowns, pickers):

For each dropdown/picker/autocomplete in the UI:
  â†' Which CORE API provides it?
  â†' Which PSCoreApiService method? With what param?
  â†' When to load it? (OnInit / OnDialogOpen / On{field}Change)

Catalog format:
  | Data Needed | CORE API | FE Method | TypeData/Param | Load Trigger |
  |---|---|---|---|---|
  | NhÃ¢n viÃªn thu tiá»n | GetListEmployee | coreApi.GetListEmployee() | â€" | OnInit |
  | Tráº¡ng thÃ¡i filter | GetListStatus | coreApi.GetListStatus(LSStatusTypeDataEnum.Receipt) | TypeData=22 | OnInit |
  | Chi nhÃ¡nh | GetListHead | coreApi.GetListHead(false) | isAll=false | OnInit |
```

#### 5.6 Cachprintg Strategy
```
List queries â†' Use Redis (IDistributedCache):
  Cache key: "{module}:{feature}:list:{md5(filterParams)}"
  TTL: 5 minutes
  Invalidate: on any Update or Delete for this feature
  
  IF Redis not available â†' Comment Redis lines, use IMemoryCache:
  // var cached = _memCache.Get<PagedList<...>>(cacheKey);
  // _memCache.Set(cacheKey, result, TimeSpan.FromMprintutes(5));

Detail queries â†' No cache (always fresh)
Status changes â†' Invalidate list cache
```

#### 5.7 FE Screenâ€"Component Mapping
```
For each SCR-xx in SRS Â§7.2:
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

### STEP 6 â€" Analysis Summary (Display to User)

```
ðŸ"Š ANALYSIS: {FeatureName}
â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
ðŸ" SRS: REQ_{SEQ}_{Name}.md
ðŸŽ¨ Figma: {Connected âœ… / Not Connected âš ï¸} â€" Frames: {list}
ðŸ--ï¸  Module: {SAL|CS|...} | Platform: {Web|Mobile|Both}
ðŸ"„ Guides: {BE_xxx.md} + {FE_WEB_xxx.md} [+ FE_MOBWEB_xxx.md if Both]

BUSINESS RULES: {N} (BR-01 to BR-{N})
  â"œâ"€â"€ Critical: {BR-xx}: {rule summary}
  â""â"€â"€ Calculation: {BR-xx}: {formula}

APIs: {N} endpoints
  â"œâ"€â"€ GetList{Feature}  â†' POST /api/v1/{module}/{feature}/list
  â"œâ"€â"€ Get{Feature}      â†' POST /api/v1/{module}/{feature}/detail
  â"œâ"€â"€ Update{Feature}   â†' POST /api/v1/{module}/{feature}/save
  â"œâ"€â"€ Update{Feature}Status â†' POST /api/v1/{module}/{feature}/status
  â""â"€â"€ Delete{Feature}   â†' POST /api/v1/{module}/{feature}/delete

DTOs: {Feature}SaveRequest ({N} fields), {Feature}Response ({N} fields)
StatusEnum: {Status1}={N}, {Status2}={N}, {Status3}={N}
Shared APIs: {GetListEmployee, GetListStatus(TypeData=xx), ...}
Cache: Redis list cache (5min) + invalidate on Update/Delete

STATE MACHINE: {N} statuses
  {STATUS_A}(1) â†' {STATUS_B}(2) â†' {STATUS_C}(3 terminal)

FIGMA vs SRS DISCREPANCIES:
  â"œâ"€â"€ UNDOCUMENTED in SRS: {list} or "None"
  â""â"€â"€ MISSING in Figma: {list} or "None"

âš ï¸ PENDING DECISIONS: {N} items
  â""â"€â"€ TBD-01: {question} â†' blocks FR-{xx}

ðŸš€ Generating guides now...
```

**Approval Gate:**
- No TBD â†' Auto-proceed immediately
- TBD present but non-blockprintg â†' Proceed + flag in guide
- Critical TBD (blocks core functionality) â†' Ask user the specific question first

---

### STEP 7 â€" Generate BE Guide

Save to: `{PIPELINE_ROOT}\guides\BE_{SEQ}_{FeatureName}.md`

```markdown
# BE Implementation Guide: {FeatureName}
> **Generated from:** REQ_{SEQ}_{Name}.md (7-Pillar SRS, IEEE 29148)
> **Generated at:** {ISO timestamp}
> **Module:** {module} | **Stack:** .NET 10 + Mprintimal API + VSA + CQRS (MediatR) + EF Core 10 + Redis
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
| HEAD filter | All list queries MUST filter by current user's HeadCode | BR-{nn} |

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

> File location: `modules/HoaiMinh.ERP.Modules.{Module}/Features/{Feature}/{Feature}Dto.cs`

### {Feature}SaveRequest (Create or Update â€" Code=0â†'INSERT, Code>0â†'UPDATE)
```csharp
public record {Feature}SaveRequest(
    long Code,                     // 0=create, >0=update  [FR-{nn}]
    {type} {field},               // {description} [BR-{nn}]
    {type}? {optionalField}       // optional â€" {description}
);
```

### {Feature}CusRequest (Identify record â€" used in Get/Delete/Status)
```csharp
public record {Feature}CusRequest(
    long Code                      // {Feature} primary key
);
```

### {Feature}FilterRequest (List query params)
```csharp
public record {Feature}FilterRequest(
    DateOnly? DateFrom,            // SRS Â§7.3 filter bar [FR-{nn}]
    DateOnly? DateTo,
    printt? Status,                   // null = all statuses
    printt Page = 1,
    printt PageSize = 20
);
```

### {Feature}Response (Output â€" list rows + detail view)
```csharp
public record {Feature}Response(
    long Code,
    string {FeatureNo},            // auto-generated number
    {type} {field},               // {from SRS Â§6.2 / Â§7.3 grid columns}
    printt Status,
    string StatusName,             // human-readable â€" from {Feature}Status.GetName()
    {type} {joprintedField}Name,     // joprinted from {OtherTable}
    DateTimeOffset CreatedAt,
    string CreatedByName
);
```

---

## 4. Status & Enum Definitions

> Source: SRS Â§6.4 + Â§5.2 Transition Table
> **IMMUTABLE** â€" values map to `tbl_LSStatus TypeData={XX}`

### BE C# (StatusConstants)
```csharp
// File: modules/.../Features/{Feature}/{Feature}Dto.cs
public static class {Feature}Status
{
    public const printt {StatusName1} = {N};   // TypeOfStatus={N}, display: "{Display}" â€" [SRS Â§6.4]
    public const printt {StatusName2} = {N};
    public const printt {StatusName3} = {N};   // TERMINAL

    private static readonly Dictionary<printt, string> _names = new()
    {
        [{StatusName1}] = "{Display1}",
        [{StatusName2}] = "{Display2}",
        [{StatusName3}] = "{Display3}"
    };

    public static string GetName(printt? s) =>
        s.HasValue && _names.TryGetValue(s.Value, out var n) ? n : "KhÃ´ng xÃ¡c Ä‘á»‹nh";

    public static readonly printt[] EditableStatuses = [{StatusName1}];
    public static readonly printt[] FprintalStatuses    = [{StatusName2}, {StatusName3}];
}
```

---

## 5. VSA File Structure

```
modules/HoaiMinh.ERP.Modules.{Module}/
â""â"€â"€ Features/
    â""â"€â"€ {Feature}/
        â"œâ"€â"€ {Feature}Endpoints.cs           â† Route registration + MediatR dispatch
        â"œâ"€â"€ GetList{Feature}Query.cs        â† CQRS Query record
        â"œâ"€â"€ GetList{Feature}Handler.cs      â† EF Core query + Redis cache
        â"œâ"€â"€ Get{Feature}Query.cs
        â"œâ"€â"€ Get{Feature}Handler.cs
        â"œâ"€â"€ Update{Feature}Command.cs       â† CQRS Command record
        â"œâ"€â"€ Update{Feature}Handler.cs       â† Business logic + DB write
        â"œâ"€â"€ UpdateStatus{Feature}Command.cs â† Status change command
        â"œâ"€â"€ UpdateStatus{Feature}Handler.cs â† Status transition guard
        â"œâ"€â"€ Delete{Feature}Command.cs
        â"œâ"€â"€ Delete{Feature}Handler.cs
        â""â"€â"€ {Feature}Dto.cs                 â† All DTOs + StatusConstants
```

---

## 6. Handler Logic (Step-by-Step)

### GetList{Feature}Handler
```
Step 1: Build Redis cache key = "{module}:{feature}:list:{md5(filter)}"
Step 2: Try cache.GetStringAsync(key) â†' return if hit
        [Comment out Redis â†' use IMemoryCache if Redis not setup]
Step 3: Query tbl_{PrimaryTable}
        â†' .Where(x => !x.IsDeleted)                         â† soft delete
        â†' .Where(x => x.Head == currentUser.HeadCode)       â† HEAD-01 MANDATORY
        â†' .Where(x => filter.DateFrom == null || x.CreatedDate >= filter.DateFrom)
        â†' .Where(x => filter.Status == null || x.Status == filter.Status)
        â†' .AsNoTrackprintg()                                    â† read-only â†' performance
Step 4: LeftJoprint tbl_{RelatedTable} for joprinted names (.NET 10 native LeftJoprint)
Step 5: Project to {Feature}Response record
Step 6: Order + pagprintate: .OrderByDescending(x => x.Code).Skip().Take()
Step 7: CountAsync for total
Step 8: Build PagedList<{Feature}Response> { Data, Total, Page, PageSize }
Step 9: Set cache (5min TTL) [Comment out if not Redis]
Step 10: Return ApiResponse<PagedList<{Feature}Response>>.Ok(result)
```

### Update{Feature}Handler
```
Step 1: Validate request fields (from SRS AC-xx)
        â†' {field} required? â†' return BadRequest({message from SRS})
        â†' {amount} > 0? â†' check from SRS BR-xx

Step 2: if Code == 0 â†' CREATE branch:
        â†' Verify not duplicate {uniqueField} (if BR-xx requires uniqueness)
        â†' Generate {FeatureNo} via SysIncreaseService.NextAsync("{PREFIX}")
        â†' new tbl_{PrimaryTable} {
            Head      = currentUser.HeadCode,    â† ICurrentUserService â€" NEVER hardcode
            Cashier   = currentUser.EmployeeCode,
            CreatedBy = currentUser.UserName,
            CreatedDate = DateTime.UtcNow,
            Status    = {Feature}Status.{InitialStatus}
          }
        â†' db.{PrimaryTable}s.Add(entity)

Step 3: if Code > 0 â†' UPDATE branch:
        â†' Load entity: db.{PrimaryTable}s.FirstOrDefaultAsync(x => x.Code == Code && !x.IsDeleted)
        â†' If null â†' return NotFound("{Feature} khÃ´ng tá»"n táº¡i")
        â†' Status guard: if not in EditableStatuses â†' return BadRequest("{message}")
        â†' Map changed fields from request
        â†' entity.UpdatedBy = currentUser.UserName
        â†' entity.UpdatedDate = DateTime.UtcNow

Step 4: db.SaveChangesAsync(ct)
Step 5: Invalidate Redis cache for this feature's list keys [comment if not Redis]
Step 6: Return ApiResponse<object>.Ok(new { entity.Code, entity.{FeatureNo} })
```

### UpdateStatus{Feature}Handler
```
Step 1: Load entity by Code â†' check exists + not deleted
Step 2: Look up transition table (from SRS Â§5.2):
        Resolve: (currentStatus, targetStatus) â†' allowed?
        If not allowed â†' return BadRequest("KhÃ´ng thá»ƒ chuyá»ƒn tá»« {from} sang {to}")
Step 3: Require reason if targetStatus is Cancelled (from SRS BR-xx)
Step 4: entity.Status = targetStatus
        entity.{StatusDate} = DateTime.UtcNow  (if applicable)
        Log status change to tbl_LOGStatus (if required by SRS NFR-S04)
Step 5: db.SaveChangesAsync(ct)
Step 6: Invalidate cache [comment if not Redis]
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

> Source: SRS Â§3 Acceptance Criteria (AC-xx)

| Rule | Condition | Error Message | Source |
|---|---|---|---|
| {Field} required | `{field} == null or empty` | "{field khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng}" | AC-{nn}-{nn} |
| Amount > 0 | `amount <= 0` | "Sá»‘ tiá»n pháº£i lá»›n hÆ¡n 0" | BR-{nn} |
| Status editable | `status not in EditableStatuses` | "KhÃ´ng thá»ƒ sá»­a á»Ÿ tráº¡ng thÃ¡i {statusName}" | BR-{nn} |

---

## 9. Figma â†" SRS Discrepancy Report

| Type | Field/Element | Details | Recommended Action |
|---|---|---|---|
| UNDOCUMENTED | {field in Figma, not in SRS} | Found in {screen}, not in SRS Â§6.2 | Confirm with PM â†' add to SRS |
| DESIGN MISSING | {field in SRS, not in Figma} | In SRS Â§6.2, frame {SCR-xx} missing | Request design update |
| LABEL MISMATCH | {button} | SRS: "{A}" / Figma: "{B}" | SRS wprints â†' implement as "{A}" |

---

## 10. Pending Decisions

| ID | Question | Blocks | Assigned To |
|---|---|---|---|
| TBD-{nn} | {question from SRS Appendix C} | FR-{nn} | {stakeholder} |
```

---

### STEP 8 â€" Generate FE Web Guide (if Platform = Web or Both)

Save to: `{PIPELINE_ROOT}\guides\FE_WEB_{SEQ}_{FeatureName}.md`

```markdown
# FE Web Implementation Guide: {FeatureName}
> **Generated from:** REQ_{SEQ}_{Name}.md + Figma Analysis
> **Generated at:** {ISO timestamp}
> **Module:** {module} | **Platform:** Web (hoaiminh3Ps-FE â€" Angular 16 + Kendo UI 13)
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

### {module}-api-static.service.ts â€" URL Constants
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

### {module}-api.service.ts â€" Service Methods
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
[See fe-standards.md Â§3 for exact Observable pattern]

---

## 3. DTO Files

### {module}-{feature}.dto.ts
```typescript
// File: models/dtos/e-dtos/{module}-{feature}.dto.ts

export interface {Module}{Feature}DTO {
  Code: number;
  {FeatureNo}: string;
  {field}: {type};           // SRS Â§6.2 â€" {description}
  Status: number;
  StatusName: string;
  {JoprintedEntity}Name: string; // joprinted field
  CreatedAt: string;
  CreatedByName: string;
}

export interface {Module}{Feature}CusDTO {
  Code: number;               // always â€" identifies record
}
```

---

## 4. Enum Files

### e-status/{module}-{feature}-status.enum.ts
```typescript
// File: models/enums/e-status/{module}-{feature}-status.enum.ts
export enum {Module}{Feature}StatusEnum {
  {StatusName1} = {N},  // "{Display1}" â€" maps to BE {Feature}Status.{StatusName1}
  {StatusName2} = {N},  // "{Display2}"
  {StatusName3} = {N},  // "{Display3}" â€" TERMINAL
}
```

### LSStatusTypeDataEnum value for GetListStatus()
```typescript
// Use: coreApi.GetListStatus(LSStatusTypeDataEnum.{X})
// Where TypeData = {N}  (from tbl_LSStatus â€" HM DB)
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
| {featureNo} | "Sá»‘ {feature}" | 120 | â€" | true | [FR-{nn}] |
| {amount} | "{Label}" | 150 | "{0:n0}" | true | VND format |
| {statusName} | "Tráº¡ng thÃ¡i" | 120 | â€" | true | badge color per status |

**Filter Bar Components:**
| Component | Bprintding | API Call | Label |
|---|---|---|---|
| kendo-daterangepicker | dateFrom / dateTo | â€" | "Tá»« ngÃ y â€" Äáº¿n ngÃ y" |
| ps-dropdown | statusFilter | coreApi.GetListStatus(TypeData={N}) | "Tráº¡ng thÃ¡i" |

**Toolbar Buttons (by status / role):**
| Button | Label | Visible when | Action |
|---|---|---|---|
| Add | "ThÃªm má»›i" | Always | openDialog(null) |
| Edit | "Sá»­a" | row.Status = {StatusName1} | openDialog(row) |
| {Approve} | "{Label}" | Status={StatusName1}, Role={Role} | callUpdateStatus({StatusName2}) |
| Delete | "XÃ³a" | Status={StatusName1} | confirmDelete(row) |

### SCR-02: {Feature} Detail Screen

**Form Fields (Editability Matrix):**
| Field | Label | Component | Editable when Status = | Source |
|---|---|---|---|---|
| {field} | "{Vietnamese label}" | ps-input | {StatusName1} | SRS Â§6.2 |
| {amount} | "{label}" | kendo-numerictextbox | {StatusName1} | SRS Â§6.2 |
| {statusName} | "Tráº¡ng thÃ¡i" | badge | Read-only always | â€" |

**Action Buttons (Detail):**
| Button | Label | Show when | Action |
|---|---|---|---|
| Save | "LÆ°u" | Status={StatusName1} | callUpdate() |
| {Submit} | "{Label}" | Status={StatusName1} | callUpdateStatus({N}) |
| Cancel | "Há»§y giao dá»‹ch" | Status={StatusName1} | confirmCancel() with reason |

---

## 7. Status Badge & Rendering

```typescript
// In component class â€" expose enum
{Feature}Status = {Module}{Feature}StatusEnum;

getStatusClass(status: number): string {
  return {
    [{Module}{Feature}StatusEnum.{Name1}]: 'badge badge-warning',
    [{Module}{Feature}StatusEnum.{Name2}]: 'badge badge-success',
    [{Module}{Feature}StatusEnum.{Name3}]: 'badge badge-danger',
  }[status] ?? 'badge badge-secondary';
}
```

---

## 8. Validation (Reactive Forms)

```typescript
// Form group â€" cite FR-xx for each validator
this.form = this.fb.group({
  {field}: [null, [Validators.required]],           // AC-{nn}-{nn}: required
  {amount}: [null, [Validators.min(1)]],            // AC-{nn}-{nn}: must > 0
});
```

---

## 9. Layout Rules

```
1. Page structure: ps-layout â†' ps-toolbar-top â†' ps-table / form
2. Scroll: table container: overflow-x: auto (zoom support)
3. Buttons: ONLY inside ps-toolbar â€" never floating/absolute
4. Loading: kendo-loader for all API calls
5. Empty grid: show "KhÃ´ng cÃ³ dá»¯ liá»‡u" â€" never blank grid
6. Empty state: {Business-specific empty state message from SRS}
```

---

## 10. Figma â†" SRS Discrepancies

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

### STEP 9 â€" Generate FE Mobile Guide (if Platform = Mobile or Both)

Save to: `{PIPELINE_ROOT}\guides\FE_MOBWEB_{SEQ}_{FeatureName}.md`

```markdown
# FE Mobile Implementation Guide: {FeatureName}
> **Platform:** Mobile (hoaiminh3Ps-mobileApp â€" Angular 16, Responsive)
> **Key differences from Web:** No Kendo Grid, card-based lists, bottom action bar, touch targets 44px+

---
## 1. Overview
## 2. Service Files (same {module}-api.service.ts â€" reuse, not changes needed if already created for web)
## 3. DTO Files (same as Web guide)
## 4. Enum Files (same as Web guide)
## 5. Shared Core Services (same as Web guide)
## 6. Screen Specs (Mobile-specific):
   - List as card layout (ul/li) NOT kendo-grid
   - Each card shows: {top 3-4 key fields}
   - Card tap â†' navigate to detail route
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

### STEP 10 â€" Save Memory File

```
Path: .agent\projects\hoaiminh\memory\{FeatureName}.md (if HM project)

Content:
- SRS filename + key design decisions
- API names resolved (fprintal)
- Status values resolved
- Discrepancies found + how resolved
- TBD items still open
- Key business rules to remember for future iterations
```

---

### STEP 11 â€" Report to User

```
âœ… BA Analysis Complete: {FeatureName}
â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
ðŸ"„ SRS: REQ_{SEQ}_{Name}.md
ðŸŽ¨ Figma: {status}

ðŸ"¦ Guides created:
   â†' {PIPELINE_ROOT}\guides\BE_{SEQ}_{Name}.md        ({N} lines)
   â†' {PIPELINE_ROOT}\guides\FE_WEB_{SEQ}_{Name}.md    ({N} lines)  [if Web/Both]
   â†' {PIPELINE_ROOT}\guides\FE_MOBWEB_{SEQ}_{Name}.md    ({N} lines)  [if Mobile/Both]

ðŸ"Š Technical Summary:
   APIs:     {N} endpoints (GetList, Get, Update, UpdateStatus, Delete)
   DTOs:     {N} DTO types defined
   Enums:    {N} status constants + {N} TypeScript enums
   Shared:   {N} PSCoreApiService methods required
   Cache:    Redis list cache (5min) + {N} invalidation triggers
   Screens:  {N} screens ({Web grid + detail} / {Mobile card + form})

âš ï¸  Discrepancies: {N} Figma vs SRS conflicts â†' see Â§10 in FE guides
âš ï¸  Pending:       {N} TBD items â†' {list which FRs blocked}

ðŸ"-- Next steps:
   BE team  â†' read BE_{SEQ}_{Name}.md
   FE team  â†' read FE_WEB_{SEQ}_{Name}.md [+ FE_MOB if applicable]
   PM/BA    â†' resolve TBD items before sprprintt start
```

---

## 4. Quality Gates â€" MANDATORY Before Savprintg Any Guide

### BE Guide Checklist
```
[ ] All 5 API endpoints defined (GetList/Get/Update/UpdateStatus/Delete)
[ ] ALL DTO types defined with full field lists (not "... other fields")
[ ] Status constants defined with EXACT printt values from tbl_LSStatus
[ ] StatusGetName() method included
[ ] HEAD filter explicitly mentioned in every list handler
[ ] ICurrentUserService injection mandatory for all write handlers
[ ] Redis cache strategy documented (key pattern + TTL + invalidation)
[ ] Validation rules cite SRS AC-xx (not generic rules)
[ ] Shared APIs listed (which CORE APIs, with TypeData enums)
[ ] VSA file structure shows exact file names
[ ] Figma discrepancy table included (even if empty â€" write "None")
[ ] All TBD-xx items flagged with âš ï¸
```

### FE Web Guide Checklist
```
[ ] Service file pattern correct (PSAPIService + Observable<ResponseDTO>)
[ ] Static service URLs correct (POST only â€" not GET/PUT/DELETE)
[ ] DTO interfaces complete + Cus interface included
[ ] Enum file defined + maps to BE StatusConstants values
[ ] PSCoreApiService catalog complete (all dropdowns accounted for)
[ ] Grid columns table: field, title, width, format, sortable
[ ] Toolbar buttons table: label, status condition (enum â€" NO magic numbers), action
[ ] Editability matrix: field Ã-- status (from SRS Â§6.2 "Editable When")
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
| **HoÃ i Minh ERP** | Load `projects/hoaiminh/` â€" use HM standards, module codes, VND |
| **Any other project** | Do NOT load projects/hoaiminh/ â€" use only SRS content |
| **Stack unknown** | Infer from SRS technology constraints or ask once |
| **Platform unknown** | Default to Web only |

> **GOLDEN RULE:** Never output a guide with placeholder text like "{api_name}" or "{field}".
> Every single field, method name, endpoint path, enum value MUST be concrete and project-specific.
> If information is genuprintely unknown â†' write "âš ï¸ TBD: {specific question}" â€" NOT a generic placeholder.

