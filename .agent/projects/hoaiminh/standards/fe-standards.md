---
name: fe-standards
description: Frontend coding standards for Hoai Minh ERP. Defines folder structure, service patterns, DTO/enum naming, shared components, Kendo Grid patterns, mobile differences. Load before any FE implementation.
---

# Hoai Minh ERP -- FE Coding Standards

> **Web Stack:** Angular 16, Kendo UI 13, SCSS (`hoaiminh3Ps-FE`)
> **Mobile Stack:** Angular 16, Responsive (no Kendo Grid) (`hoaiminh3Ps-mobileApp`)
> **MANDATORY:** BA Guide MUST include all patterns from this file for every FE feature.

---

## 1. Platform Detection -- Web vs Mobile

```
SRS Pillar 1 -> Platform field:
  "Web"    -> FE Guide uses hoaiminh3Ps-FE patterns (Kendo UI, full grid)
  "Mobile" -> FE Guide uses hoaiminh3Ps-mobileApp patterns (responsive, not Kendo Grid)
  "Both"   -> BA creates 2 separate guide files:
               FE_WEB_{SEQ}_{Name}.md    ← Web guide
               FE_MOBWEB_{SEQ}_{Name}.md ← Mobile guide

File naming:
  FE_WEB_001_Receipt.md
  FE_MOBWEB_001_Receipt.md
```

---

## 2. Folder Structure Pattern

```
src/app/views/{module}/
|--- {module}.module.ts
|--- {module}.routing.ts
|--- services/
|   |--- {module}-api.service.ts          ← API methods (Observable<ResponseDTO>)
|   `--- {module}-api-static.service.ts   ← URL string constants only
`--- views/
    |--- {module}{seq}-{feature}/         ← List screen
    |   |--- {module}{seq}-{feature}.component.ts
    |   |--- {module}{seq}-{feature}.component.html
    |   `--- {module}{seq}-{feature}.component.scss
    `--- {module}{seq}-{feature}-detail/  ← Detail screen
        |--- {module}{seq}-{feature}-detail.component.ts
        |--- {module}{seq}-{feature}-detail.component.html
        `--- {module}{seq}-{feature}-detail.component.scss
```

**Naming examples:**
```
cs001-template               -> CS module, screen 001, feature: template
cs002-zns-message            -> CS module, screen 002, feature: ZNS message
cs002-zns-message-detail     -> Corresponding detail screen
mtb020-receipt               -> MTB module, screen 020, feature: receipt
mtb021-receipt-detail        -> Detail screen
```

**Route pattern:**
```typescript
// {module}.routing.ts
{ path: '{seq}-{feature}',        component: {Module}{Seq}{Feature}Component },
{ path: '{seq}-{feature}-detail', component: {Module}{Seq}{Feature}DetailComponent }
// e.g.: { path: '001-template', component: Cs001TemplateComponent }
```

---

## 3. Service File Pattern -- MANDATORY

### {module}-api-static.service.ts (URL constants -- not logic)

```typescript
export class {Module}ApiStaticService {
  // Pattern: object with DLL key (multi-branch support)
  static readonly [dllKey: string]: {
    GetList{Feature}: string;
    Get{Feature}: string;
    Update{Feature}: string;
    Update{Feature}Status: string;
    Delete{Feature}: string;
  } | any;

  // Or flat (if single endpoint set):
  static readonly GetList{Feature}  = 'api/{module}/{feature}/list';
  static readonly Get{Feature}      = 'api/{module}/{feature}/detail';
  static readonly Update{Feature}   = 'api/{module}/{feature}/save';
  static readonly Update{Feature}Status = 'api/{module}/{feature}/status';
  static readonly Delete{Feature}   = 'api/{module}/{feature}/delete';
}
```

### {module}-api.service.ts (methods -- Observable pattern)

```typescript
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { State, toDataSourceRequest } from '@progress/kendo-data-query';
import { PSAPIService } from 'src/app/services/core/ps-api.service';
import { PSGetConfigService } from 'src/app/services/core/ps-get-config.service';
import { ResponseDTO } from 'src/app/models/dtos/reponse.dto';
import { {Feature}CusDTO } from 'src/app/models/dtos/e-dtos/{module}-{feature}.dto';
import { UpdateStatusInterface } from 'src/app/models/dtos/update-status.interface';
import { UpdatePropertiesInterface } from 'src/app/models/dtos/update-properties.interface';

@Injectable({ providedIn: 'root' })
export class {Module}ApiService {
  constructor(
    private api: PSAPIService,
    private config: PSGetConfigService,
  ) {}

  // List with Kendo State (filter, sort, page)
  public GetList{Feature}(param: State): Observable<ResponseDTO> {
    return new Observable<ResponseDTO>((obs) => {
      this.api.post(
        {Module}ApiStaticService[this.config.GetDLL()].GetList{Feature},
        toDataSourceRequest(param)
      ).subscribe(
        (res: ResponseDTO) => { obs.next(res); obs.complete(); },
        (errors) => { obs.error(errors); obs.complete(); }
      );
    });
  }

  // Get single record
  public Get{Feature}(param: {Feature}CusDTO): Observable<ResponseDTO> {
    return new Observable<ResponseDTO>((obs) => {
      this.api.post(
        {Module}ApiStaticService[this.config.GetDLL()].Get{Feature},
        param
      ).subscribe(
        (res: ResponseDTO) => { obs.next(res); obs.complete(); },
        (errors) => { obs.error(errors); obs.complete(); }
      );
    });
  }

  // Create or Update
  public Update{Feature}(param: UpdatePropertiesInterface<{Feature}CusDTO>): Observable<ResponseDTO> {
    return new Observable<ResponseDTO>((obs) => {
      this.api.post(
        {Module}ApiStaticService[this.config.GetDLL()].Update{Feature},
        param
      ).subscribe(
        (res: ResponseDTO) => { obs.next(res); obs.complete(); },
        (errors) => { obs.error(errors); obs.complete(); }
      );
    });
  }

  // Status change
  public Update{Feature}Status(param: UpdateStatusInterface<{Feature}CusDTO>): Observable<ResponseDTO> {
    return new Observable<ResponseDTO>((obs) => {
      this.api.post(
        {Module}ApiStaticService[this.config.GetDLL()].Update{Feature}Status,
        param
      ).subscribe(
        (res: ResponseDTO) => { obs.next(res); obs.complete(); },
        (errors) => { obs.error(errors); obs.complete(); }
      );
    });
  }

  // Delete
  public Delete{Feature}(param: {Feature}CusDTO): Observable<ResponseDTO> {
    return new Observable<ResponseDTO>((obs) => {
      this.api.post(
        {Module}ApiStaticService[this.config.GetDLL()].Delete{Feature},
        param
      ).subscribe(
        (res: ResponseDTO) => { obs.next(res); obs.complete(); },
        (errors) => { obs.error(errors); obs.complete(); }
      );
    });
  }
}
```

---

## 4. DTO Naming Pattern (TypeScript)

| File Name | Class Name | Purpose |
|-----------|-----------|---------|
| `{module}-{entity}.dto.ts` | `{Module}{Entity}DTO` | Full DTO -- all fields |
| `{module}-{entity}.dto.ts` | `{Module}{Entity}CusDTO` | Custom DTO -- selected fields (same file) |

**Examples:**
```
sal-order-master.dto.ts   -> SalOrderMasterDTO, SalOrderMasterCusDTO
cs-vehicle.dto.ts         -> CsVehicleDTO, CsVehicleCusDTO
csms-send-master.dto.ts   -> CsmsSendMasterDTO, CsmsSendMasterCusDTO
```

**DTO file structure:**
```typescript
export interface {Module}{Feature}DTO {
  Code: number;
  ReceiptNo: string;
  CollectedAmount: number;
  Status: number;
  StatusName: string;
  CreatedAt: string;
  CreatedByName: string;
}

export interface {Module}{Feature}CusDTO {
  Code: number; // always required -- identifies the record
}
```

---

## 5. Enum Pattern

| Folder | Purpose | Example |
|--------|---------|---------|
| `e-status/` | Business status enums | `SalReceiptStatusEnum` |
| `e-type/` | TypeData enums for CORE APIs | `LSStatusTypeDataEnum` |

```typescript
// e-status/{module}-{feature}-status.enum.ts
export enum {Module}{Feature}StatusEnum {
  New = 1,        // Maps to tbl_LSStatus TypeOfStatus=1
  Completed = 2,
  Cancelled = 3
}

// e-type/ls-status-type-data.enum.ts (shared -- ALREADY EXISTS)
export enum LSStatusTypeDataEnum {
  Receipt = 22,
  Invoice = 23,
  SalesOrder = 18,
  // ... check actual file
}
```

**In component -- MUST expose enum for template binding:**
```typescript
export class MyComponent {
  // Expose enum for template -- NEVER use magic numbers in HTML
  {Feature}Status = {Module}{Feature}StatusEnum;
}
```

```html
<!-- CORRECT -- use enum -->
<div *ngIf="item.Status !== {Feature}Status.Completed">
<!-- WRONG -- magic number -->
<div *ngIf="item.Status !== 2">
```

---

## 6. Shared Components -- MUST Use, NEVER Recreate

| Component | Selector | Purpose | DO NOT replace with |
|-----------|----------|---------|---------------------|
| `ps-button` | `<ps-button>` | All buttons | `<button>`, `<kendo-button>` |
| `ps-dialog` | `<ps-dialog>` | All modals/dialogs | `<kendo-dialog>`, `<div class="modal">` |
| `ps-dropdown` | `<ps-dropdown>` | All dropdowns | `<kendo-dropdownlist>`, `<select>` |
| `ps-input` | `<ps-input>` | Text inputs | `<input>`, `<kendo-textbox>` |
| `ps-editor` | `<ps-editor>` | Rich text | `<textarea>`, `<ckeditor>` |
| `ps-layout` | `<ps-layout>` | Page layout | Custom div layout |
| `ps-table` | `<ps-table>` | Data grids | `<kendo-grid>` raw |

**Layout pattern:**
```html
<ps-layout>
  <div class="toolbar" ps-toolbar>
    <!-- ps-button components here -->
  </div>
  <div class="content" ps-content>
    <!-- ps-table or form content here -->
  </div>
</ps-layout>
```

---

## 7. Shared Core Services -- PSCoreApiService

| Method | Param | When to Inject |
|--------|-------|---------------|
| `GetListEmployee()` | none | Cashier picker, Employee picker |
| `GetListHead(isAll)` | boolean | Branch filter |
| `GetListWarehouse(headNumber)` | number | Warehouse picker |
| `GetListProvprintce()` | none | Address form |
| `GetListDistrict(provprintce)` | LSProvprintceDTO | Address cascade |
| `GetListWard(district)` | LSDistrictDTO | Address cascade |
| `GetListLSList(typeData)` | LSListTypeDataEnum | Category dropdown |
| `GetListStatus(typeData)` | LSStatusTypeDataEnum | Status filter |
| `GetListPartnerCustomer()` | none | Customer picker |
| `GetListSupplier()` | none | Supplier picker |
| `UploadImage(keypath, files)` | string, FileInfo[] | Image upload |
| `DeleteImage(paths)` | string[] | Image delete |
| `ExportExcel(param)` | ReportInputDTO | Export Excel |
| `ExportExcelPDF(param)` | ReportInputDTO | Export PDF |

**Inject pattern:**
```typescript
constructor(
  private coreApi: PSCoreApiService,    // shared APIs
  private featureApi: {Module}ApiService // feature-specific APIs
) {}
```

---

## 8. Kendo Grid Pattern (Web Only)

```typescript
import { State, process } from '@progress/kendo-data-query';
import { GridDataResult } from '@progress/kendo-angular-grid';

gridState: State = { skip: 0, take: 20, sort: [], filter: { logic: 'and', filters: [] } };
gridData: GridDataResult = { data: [], total: 0 };

loadList() {
  this.featureApi.GetList{Feature}(this.gridState).subscribe(res => {
    if (res.Status) {
      this.gridData = { data: res.Data.Data, total: res.Data.Total };
    }
  });
}

onStateChange(state: State) {
  this.gridState = state;
  this.loadList();
}
```

```html
<ps-table [data]="gridData" [state]="gridState" (stateChange)="onStateChange($event)">
  <kendo-grid-column field="ReceiptNo" title="Receipt No" [width]="120"></kendo-grid-column>
  <kendo-grid-column field="CollectedAmount" title="Amount" [width]="150" format="{0:n0}"></kendo-grid-column>
  <kendo-grid-column field="StatusName" title="Status" [width]="120">
    <ng-template kendoGridCellTemplate let-dataItem>
      <span [class]="getStatusClass(dataItem.Status)">{{ dataItem.StatusName }}</span>
    </ng-template>
  </kendo-grid-column>
</ps-table>
```

---

## 9. Status Badge Pattern

```typescript
getStatusClass(status: number): string {
  const config: Record<number, string> = {
    [{Module}{Feature}StatusEnum.New]:       'badge badge-warning',
    [{Module}{Feature}StatusEnum.Completed]: 'badge badge-success',
    [{Module}{Feature}StatusEnum.Cancelled]: 'badge badge-danger',
  };
  return config[status] ?? 'badge badge-secondary';
}
```

---

## 10. Layout Rules (UI/UX Standards)

```
1. SCROLL: When zoom > 100% -> content MUST be scrollable (overflow-x: auto on table container)
2. BUTTONS: Always place in ps-toolbar or ps-layout toolbar section -- NEVER position manually
3. FORM GRID: Use CSS grid or row/col from layout system -- NEVER use absolute/fixed
4. PAGE STRUCTURE: Every page MUST have: Toolbar (top) -> Filter bar -> Content (grid/form)
5. DIALOG: Always use ps-dialog -- NEVER use custom overlay
6. LOADING: Every async operation MUST have loading printdicator (kendo-loader or ps-loading)
7. EMPTY STATE: Empty grid MUST show "No data available" message, NEVER leave grid blank
```

---

## 11. Mobile-Specific Patterns

```
Differences from Web:
1. NO Kendo Grid -> use <ul>/<li> card layout or custom list
2. NO ps-table -> use custom responsive list
3. Buttons: larger (min-height: 44px) for touch target
4. Form: 1 column, full width inputs
5. Toolbar: bottom navigation bar style, not top toolbar
6. Filter: Collapsible filter panel instead of always-visible filter bar
7. Navigation: Router navigate with back button support
```

```typescript
// Mobile service -- SAME service files as web
// Do NOT create separate service -- reuse {module}-api.service.ts
```

---

## 12. Update Properties / Status Interface

```typescript
// Shared interfaces -- ALREADY EXIST, reuse:
export interface UpdatePropertiesInterface<T> {
  Properties: T;
  // ... (check actual file for full definition)
}

export interface UpdateStatusInterface<T> {
  Key: T;
  Status: number;
  Reason?: string; // required when cancellprintg
}
```

---

## 13. BA Guide Requirements -- Mandatory FE Sections

> BA MUST include ALL of the followprintg in every FE (Web) Guide:

```
§1  Overview + Platform confirmation (Web/Mobile/Both)
§2  Component Architecture (exact folder tree with file names)
§3  Service Files
    - {module}-api-static.service.ts (all URL constants)
    - {module}-api.service.ts (all methods with exact Observable pattern)
§4  DTO Files
    - {module}-{feature}.dto.ts ({Feature}DTO + {Feature}CusDTO)
§5  Enum Files
    - {module}-{feature}-status.enum.ts
    - LSStatusTypeDataEnum value to use in GetListStatus()
§6  PSCoreApiService Methods to Inject (which shared APIs, when called)
§7  Screen Specs -- for each SCR-xx:
    - Grid columns (field, title, width, format)
    - Filter bar (component, param, TypeData enum)
    - Action buttons per status (using enum, not magic numbers)
    - Editability matrix (field × status)
§8  Status Badge Rendering (enum values + CSS class)
§9  Validation (reactive form validators citing SRS AC-xx)
§10 Layout Rules (scroll, buttons, toolbar)
§11 Figma ↔ SRS Discrepancies
§12 Pending Decisions (from SRS TBD items)
```

> BA MUST include ALL of the followprintg in every FE (Mobile) Guide:

```
§1  Overview + Platform: Mobile
§2  Component Architecture (mobile folder tree)
§3  Service Files (same as web -- reuse {module}-api.service.ts)
§4  DTO Files (same as web)
§5  Enum Files (same as web)
§6  PSCoreApiService Methods to Inject
§7  Screen Specs -- List as card layout, Detail as form:
    - Card fields (what to show in each card)
    - Detail form layout (1 column, full width)
    - Bottom action bar buttons
§8  Navigation & Back Button pattern
§9  Touch target sizes (min 44px buttons)
§10 Pending Decisions
```
