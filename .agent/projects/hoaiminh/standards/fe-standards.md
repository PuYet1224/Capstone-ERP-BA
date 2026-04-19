# HoÃ i Minh ERP â€” FE Coding Standards

> **Web Stack:** Angular 16, Kendo UI 13, SCSS (`hoaiminh3Ps-FE`)
> **Mobile Stack:** Angular 16, Responsive (no Kendo Grid) (`hoaiminh3Ps-mobileApp`)
> **MANDATORY:** BA Guide MUST include all patterns from this file for every FE feature.

---

## 1. PLATFORM DETECTION â€” WEB vs MOBILE

```
SRS Pillar 1 â†’ Platform field:
  "Web"    â†’ FE Guide dÃ¹ng hoaiminh3Ps-FE patterns (Kendo UI, full grid)
  "Mobile" â†’ FE Guide dÃ¹ng hoaiminh3Ps-mobileApp patterns (responsive, no Kendo Grid)
  "Both"   â†’ BA táº¡o 2 file guide riÃªng:
              FE_WEB_{SEQ}_{Name}.md  â† Web guide
              FE_MOBWEB_{SEQ}_{Name}.md  â† Mobile guide

File naming:
  FE_WEB_001_Receipt.md
  FE_MOBWEB_001_Receipt.md
```

---

## 2. FOLDER STRUCTURE PATTERN

> Äá»c tá»« `hoaiminh3Ps-FE/src/app/views/cs/` â€” pattern chuáº©n nháº¥t.

```
src/app/views/{module}/
â”œâ”€â”€ {module}.module.ts
â”œâ”€â”€ {module}.routing.ts
â”œâ”€â”€ services/
â”‚   â”œâ”€â”€ {module}-api.service.ts          â† API methods (Observable<ResponseDTO>)
â”‚   â””â”€â”€ {module}-api-static.service.ts   â† URL string constants only
â””â”€â”€ views/
    â”œâ”€â”€ {module}{seq}-{feature}/         â† List screen
    â”‚   â”œâ”€â”€ {module}{seq}-{feature}.component.ts
    â”‚   â”œâ”€â”€ {module}{seq}-{feature}.component.html
    â”‚   â””â”€â”€ {module}{seq}-{feature}.component.scss
    â””â”€â”€ {module}{seq}-{feature}-detail/  â† Detail screen
        â”œâ”€â”€ {module}{seq}-{feature}-detail.component.ts
        â”œâ”€â”€ {module}{seq}-{feature}-detail.component.html
        â””â”€â”€ {module}{seq}-{feature}-detail.component.scss
```

**Screen naming examples (tá»« source):**
```
cs001-template               â†’ CS module, screen 001, feature: template
cs002-zns-message            â†’ CS module, screen 002, feature: ZNS message
cs002-zns-message-detail     â†’ Detail screen tÆ°Æ¡ng á»©ng
mtb020-receipt               â†’ MTB module, screen 020, feature: receipt
mtb021-receipt-detail        â†’ Detail screen
```

**Route pattern:**
```typescript
// {module}.routing.ts
{ path: '{seq}-{feature}',        component: {Module}{Seq}{Feature}Component },
{ path: '{seq}-{feature}-detail', component: {Module}{Seq}{Feature}DetailComponent }
// e.g.: { path: '001-template', component: Cs001TemplateComponent }
```

---

## 3. SERVICE FILE PATTERN â€” Báº®TBUá»˜C THEO NGUYÃŠN Táº®C NÃ€Y

> Äá»c trá»±c tiáº¿p tá»« `cs-api.service.ts` vÃ  `ps-core-api.service.ts`

### {module}-api-static.service.ts (URL constants â€” khÃ´ng cÃ³ logic)

```typescript
export class {Module}ApiStaticService {
  // Pattern: object vá»›i tÃªn DLL (multi-branch support)
  static readonly [dllKey: string]: {
    GetList{Feature}: string;
    Get{Feature}: string;
    Update{Feature}: string;
    Update{Feature}Status: string;
    Delete{Feature}: string;
  } | any;

  // Hoáº·c flat (náº¿u chá»‰ 1 endpoint set):
  static readonly GetList{Feature}  = 'api/{module}/{feature}/list';
  static readonly Get{Feature}      = 'api/{module}/{feature}/detail';
  static readonly Update{Feature}   = 'api/{module}/{feature}/save';
  static readonly Update{Feature}Status = 'api/{module}/{feature}/status';
  static readonly Delete{Feature}   = 'api/{module}/{feature}/delete';
}
```

### {module}-api.service.ts (methods â€” Observable pattern)

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

  // List vá»›i Kendo State (filter, sort, page)
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

## 4. DTO NAMING PATTERN (TypeScript)

> Äá»c tá»« `hoaiminh3Ps-FE/src/app/models/dtos/e-dtos/`

| File Name | Class Name | Purpose |
|---|---|---|
| `{module}-{entity}.dto.ts` | `{Module}{Entity}DTO` | Full DTO â€” táº¥t cáº£ fields |
| `{module}-{entity}.dto.ts` | `{Module}{Entity}CusDTO` | Cus DTO â€” chá»‰ fields cáº§n (trong cÃ¹ng file) |

**Examples tá»« source:**
```
sal-order-master.dto.ts   â†’ SalOrderMasterDTO, SalOrderMasterCusDTO
cs-vehicle.dto.ts         â†’ CsVehicleDTO, CsVehicleCusDTO
csms-send-master.dto.ts   â†’ CsmsSendMasterDTO, CsmsSendMasterCusDTO
wh-io-master.dto.ts       â†’ WhIoMasterDTO, WhIoMasterCusDTO
```

**DTO file structure:**
```typescript
// {module}-{feature}.dto.ts
export interface {Module}{Feature}DTO {
  Code: number;
  ReceiptNo: string;
  CollectedAmount: number;
  Status: number;
  StatusName: string;
  // ... all fields from BE response
  CreatedAt: string;
  CreatedByName: string;
}

export interface {Module}{Feature}CusDTO {
  Code: number; // always required â€” identifies the record
  // Only fields needed for this specific operation
}
```

---

## 5. ENUM PATTERN

> Äá»c tá»« `hoaiminh3Ps-FE/src/app/models/enums/`

| Folder | Purpose | Example |
|---|---|---|
| `e-status/` | Business status enums | `SalReceiptStatusEnum` |
| `e-type/` | TypeData enums for CORE APIs | `LSStatusTypeDataEnum`, `LSListTypeDataEnum` |

```typescript
// e-status/{module}-{feature}-status.enum.ts
export enum {Module}{Feature}StatusEnum {
  New = 1,        // TypeOfStatus=1 tá»« tbl_LSStatus
  Completed = 2,  // TypeOfStatus=2
  Cancelled = 3   // TypeOfStatus=3
}

// e-type/ls-status-type-data.enum.ts (dÃ¹ng chung â€” ÄÃƒ CÃ“)
export enum LSStatusTypeDataEnum {
  Receipt = 22,
  Invoice = 23,
  SalesOrder = 18,
  // ... xem file thá»±c táº¿
}
```

**Trong component â€” báº¯t buá»™c expose enum Ä‘á»ƒ dÃ¹ng trong HTML:**
```typescript
export class MyComponent {
  // Expose enum cho template â€” KHÃ”NG dÃ¹ng magic numbers trong HTML
  {Feature}Status = {Module}{Feature}StatusEnum;
}
```

```html
<!-- ÄÃšNG â€” dÃ¹ng enum -->
<div *ngIf="item.Status !== {Feature}Status.Completed">
<!-- SAI â€” magic number -->
<div *ngIf="item.Status !== 2">
```

---

## 6. SHARED COMPONENTS â€” Báº®TBUá»˜C DÃ™NG, KHÃ”NG Tá»° CHáº¾

> Äá»c tá»« `hoaiminh3Ps-FE/src/app/components/`

| Component | Selector | Purpose | KHÃ”NG Ä‘Æ°á»£c thay báº±ng |
|---|---|---|---|
| `ps-button` | `<ps-button>` | Táº¥t cáº£ buttons | `<button>`, `<kendo-button>` |
| `ps-dialog` | `<ps-dialog>` | Táº¥t cáº£ modals/dialogs | `<kendo-dialog>`, `<div class="modal">` |
| `ps-dropdown` | `<ps-dropdown>` | Táº¥t cáº£ dropdowns | `<kendo-dropdownlist>`, `<select>` |
| `ps-input` | `<ps-input>` | Text inputs | `<input>`, `<kendo-textbox>` |
| `ps-editor` | `<ps-editor>` | Rich text | `<textarea>`, `<ckeditor>` |
| `ps-layout` | `<ps-layout>` | Trang layout | Custom div layout |
| `ps-table` | `<ps-table>` | Data grids | `<kendo-grid>` raw |

**Layout pattern (ps-layout):**
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

## 7. SHARED CORE SERVICES â€” PSCoreApiService

> Äá»c tá»« `hoaiminh3Ps-FE/src/app/services/ps-core-api.service.ts`

| Method | Param | When to inject |
|---|---|---|
| `GetListEmployee()` | none | Cashier picker, Employee picker |
| `GetListHead(isAll)` | boolean | Branch filter |
| `GetListWarehouse(headNumber)` | number | Warehouse picker |
| `GetListProvince()` | none | Address form |
| `GetListDistrict(province)` | LSProvinceDTO | Address cascade |
| `GetListWard(district)` | LSDistrictDTO | Address cascade |
| `GetListLSList(typeData)` | LSListTypeDataEnum | Category dropdown |
| `GetListStatus(typeData)` | LSStatusTypeDataEnum | Status filter |
| `GetListHRList(typeData)` | HRListTypeDataEnum | HR category |
| `GetListCSList(typeData)` | CSListTypeDataEnum | CS category |
| `GetListPartnerCustomer()` | none | Customer picker |
| `GetListSupplier()` | none | Supplier picker |
| `UploadImage(keypath, files)` | string, FileInfo[] | Image upload |
| `DeleteImage(paths)` | string[] | Image delete |
| `GetTemplate(filename)` | string | Template download |
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

## 8. KENDO GRID PATTERN (Web only â€” hoaiminh3Ps-FE)

```typescript
// Component
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
<!-- Template -->
<ps-table [data]="gridData" [state]="gridState" (stateChange)="onStateChange($event)">
  <kendo-grid-column field="ReceiptNo"    title="Sá»‘ phiáº¿u"      [width]="120"></kendo-grid-column>
  <kendo-grid-column field="CollectedAmount" title="Sá»‘ tiá»n"   [width]="150" format="{0:n0}"></kendo-grid-column>
  <kendo-grid-column field="StatusName"  title="Tráº¡ng thÃ¡i"    [width]="120">
    <ng-template kendoGridCellTemplate let-dataItem>
      <span [class]="getStatusClass(dataItem.Status)">{{ dataItem.StatusName }}</span>
    </ng-template>
  </kendo-grid-column>
  <kendo-grid-column title="Thao tÃ¡c" [width]="100" [locked]="true">
    <ng-template kendoGridCellTemplate let-dataItem>
      <ps-button (click)="viewDetail(dataItem)">Xem</ps-button>
    </ng-template>
  </kendo-grid-column>
</ps-table>
```

---

## 9. STATUS BADGE PATTERN

```typescript
// Component
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

## 10. LAYOUT RULES (UI/UX Standards â€” theo thiáº¿t káº¿ HoÃ i Minh)

```
1. SCROLL: Khi zoom in > 100% â†’ content PHáº¢I scroll Ä‘Æ°á»£c (overflow-x: auto on table container)
2. BUTTONS: LuÃ´n Ä‘áº·t trong ps-toolbar hoáº·c ps-layout toolbar section â€” KHÃ”NG Tá»° Äáº¶T Vá»Š TRÃ
3. FORM GRID: DÃ¹ng CSS grid hoáº·c row/col tá»« layout há»‡ thá»‘ng â€” KHÃ”NG dÃ¹ng absolute/fixed
4. PAGE STRUCTURE: Má»i trang PHáº¢I cÃ³: Toolbar (top) â†’ Filter bar â†’ Content (grid/form)
5. DIALOG: LuÃ´n dÃ¹ng ps-dialog â€” KHÃ”NG dÃ¹ng custom overlay
6. LOADING: Má»i async operation PHáº¢I cÃ³ loading indicator (kendo-loader hoáº·c ps-loading)
7. EMPTY STATE: Grid rá»—ng PHáº¢I hiá»ƒn thá»‹ "KhÃ´ng cÃ³ dá»¯ liá»‡u" message, KHÃ”NG Ä‘á»ƒ grid blank
```

---

## 11. MOBILE-SPECIFIC PATTERNS (hoaiminh3Ps-mobileApp)

```
KHÃC biá»‡t so vá»›i Web:
1. KHÃ”NG dÃ¹ng Kendo Grid â†’ dÃ¹ng <ul>/<li> card layout hoáº·c custom list
2. KHÃ”NG dÃ¹ng ps-table â†’ dÃ¹ng custom responsive list
3. Buttons: to hÆ¡n (min-height: 44px) cho touch target
4. Form: 1 column, full width inputs
5. Toolbar: bottom navigation bar style, khÃ´ng pháº£i top toolbar
6. Filter: Collapsible filter panel thay vÃ¬ always-visible filter bar
7. Navigation: Router navigate vá»›i back button support
```

```typescript
// Mobile service â€” CÃ™NG service files vá»›i web nhÆ°ng inject vÃ o mobile component
// KhÃ´ng táº¡o separate service â€” dÃ¹ng láº¡i {module}-api.service.ts
```

---

## 12. UPDATE PROPERTIES / STATUS INTERFACE

> Tá»« `hoaiminh3Ps-FE/src/app/models/dtos/update-properties.interface.ts`

```typescript
// Shared interfaces â€” Ä‘Ã£ cÃ³ sáºµn, dÃ¹ng láº¡i:
export interface UpdatePropertiesInterface<T> {
  Properties: T;
  // ... (xem file thá»±c táº¿)
}

export interface UpdateStatusInterface<T> {
  Key: T;
  Status: number;
  Reason?: string; // required khi cancel
}
```

---

## 13. BA GUIDE REQUIREMENTS â€” Mandatory FE Sections

> BA MUST include ALL of the following in every FE (Web) Guide:

```
Â§1  Overview + Platform confirmation (Web/Mobile/Both)
Â§2  Component Architecture (exact folder tree with file names)
Â§3  Service Files
    - {module}-api-static.service.ts (all URL constants)
    - {module}-api.service.ts (all methods with exact Observable pattern)
Â§4  DTO Files
    - {module}-{feature}.dto.ts ({Feature}DTO + {Feature}CusDTO)
Â§5  Enum Files
    - {module}-{feature}-status.enum.ts
    - LSStatusTypeDataEnum value to use in GetListStatus()
Â§6  PSCoreApiService Methods to Inject (which shared APIs, when called)
Â§7  Screen Specs â€” for each SCR-xx:
    - Grid columns (field, title, width, format)
    - Filter bar (component, param, TypeData enum)
    - Action buttons per status (using enum, not magic numbers)
    - Editability matrix (field Ã— status)
Â§8  Status Badge Rendering (enum values + CSS class)
Â§9  Validation (reactive form validators citing SRS AC-xx)
Â§10 Layout Rules (scroll, buttons, toolbar)
Â§11 Figma â†” SRS Discrepancies
Â§12 Pending Decisions (from SRS TBD items)
```

> BA MUST include ALL of the following in every FE (Mobile) Guide:

```
Â§1  Overview + Platform: Mobile
Â§2  Component Architecture (mobile folder tree)
Â§3  Service Files (same as web â€” reuse {module}-api.service.ts)
Â§4  DTO Files (same as web)
Â§5  Enum Files (same as web)
Â§6  PSCoreApiService Methods to Inject
Â§7  Screen Specs â€” List as card layout, Detail as form:
    - Card fields (what to show in each card)
    - Detail form layout (1 column, full width)
    - Bottom action bar buttons
Â§8  Navigation & Back Button pattern
Â§9  Touch target sizes (min 44px buttons)
Â§10 Pending Decisions
```

