# FE Mobile Guide Template

> Used by ba-pipeline STEP 9. Mobile-specific rules for Hoai Minh.

```markdown
# FE Mobile Implementation Guide: {FeatureName}
> **Platform:** Mobile (Angular 16, Responsive)
> **Key differences from Web:** No Kendo Grid, card-based lists, bottom action bar, touch targets 44px+

> ---
> **MODULE METADATA (SSoT — FE agent reads from here, no separate lookup needed):**
> - **Module:** {ModuleCode} / {SubModule}  _(e.g., MTB / M.Sale)_
> - **FE Mobile Abbr:** {feAbbr}  _(e.g., sal, cs, wh, crm, hrm, prt, rpt)_
> - **Route prefix:** {routePrefix}  _(e.g., /sale/ — read from tbl_SYSAPI URL column)_
> - **DLL Package:** {dllpackage}  _(from module-map.md DLLPackage table — e.g., 'receipt' NOT 'sal-receipt')_
> - **FE Namespace:** {feNamespace}  _(from module-map.md — e.g., CASE A: 'fpayment' | CASE B: new namespace)_
> - **DB Product:** Mobile=3
> ---

---

## ⛔ CRITICAL RULES FOR FE AGENT

1. **NO MOCK DATA** — Call real API from Day 1. NEVER create `USE_MOCK`, `loadMockData()`, or hardcoded arrays (including hardcoded paymentMethods, statusList, etc.)
2. **API names from BE guide** — Copy-paste exactly (e.g., `GetListSALOrderReceipt`, NOT `GetListSALReceipt`)
3. **Field names from entity** — Use exact DTO field names (e.g., `CellPhone`, `CollectedAmount`, `EffDate`)
4. **No lucide-icon** — Use `<span class="material-icons">icon_name</span>` instead
5. **5 standard services** — Router, MtbikeApiService, PsCache, PsKendoNotificationService, SystemLoaderService
6. **NO direct HTTP** — NEVER use `this.http.get/post/put/delete`. Use `this.post({namespace}.{APIID}, payload)` via MtbikeApiService (e.g., `this.post(fpayment.GetListSALOrderReceipt, payload)` — {namespace} = full variable name like `fpayment`, NOT `f` + `fpayment`)
7. **Response format** — ALWAYS `res.StatusCode === 0` (not `res.Success`), `res.ObjectReturn` (not `res.Data`), `res.ErrorString` (not `res.Message`)
8. **Wrong service names = compile error** — `NotificationService` and `LoaderService` DO NOT EXIST. Use `PsKendoNotificationService` and `SystemLoaderService`

---

## 1. Component Architecture

> ALL mobile features go inside the `mtbike` module. NEVER create new modules.

```text
src/app/views/mtbike/
|-- mtbike.module.ts              <- register component here
|-- mtbike.routing.ts             <- add route here
|-- services/
|   |-- mtbike-api-static.service.ts  <- API keys (EXISTING namespaces only)
|   |-- mtbike-api.service.ts         <- API methods
|-- views/
    |-- mtb{NNN}-{abbr}-{feature}/       <- NNN = next sequential number, {abbr} from MODULE METADATA above
        |-- mtb{NNN}-{abbr}-{feature}.component.ts
        |-- mtb{NNN}-{abbr}-{feature}.component.html
        |-- mtb{NNN}-{abbr}-{feature}.component.scss
```

**BANNED:**
- NEVER create views/sal/ or any new module folder
- NEVER create new module/routing files
- NEVER use sal001 naming -- ALWAYS mtb0XX
- NEVER create new service classes -- use existing MtbikeApiService

---

## 2. Component TS Pattern (MUST FOLLOW EXACTLY)

```typescript
import { Component, OnDestroy, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { State } from '@progress/kendo-data-query';
import { Subscription } from 'rxjs';
import { KeyLocalStorageEnum } from 'src/app/models/enums/key-local-storage.enum';
import { PsCache } from 'src/app/services/utilities/ps-cache';
import { PsKendoNotificationService } from 'src/app/services/core/ps-kendo-notification.service';
import { SystemLoaderService } from 'src/app/views/system/services/system-loader.service';
import { MtbikeApiService } from '../../services/mtbike-api.service';

@Component({
  selector: 'mtb{NNN}-{abbr}-{feature}',           // {abbr} from MODULE METADATA
  templateUrl: './mtb{NNN}-{abbr}-{feature}.component.html',
  styleUrls: ['./mtb{NNN}-{abbr}-{feature}.component.scss']
})
export class Mtb{NNN}{Abbr}{Feature}Component implements OnInit, OnDestroy {
  private arrUnsubscribe: Subscription[] = [];
  public listData: any[] = [];
  public totalCount = 0;
  public filter: State = { sort: [{ field: 'Code', dir: 'desc' }] };

  constructor(
    private router: Router,
    private api: MtbikeApiService,
    private cache: PsCache,
    private notification: PsKendoNotificationService,
    private loader: SystemLoaderService,
  ) {}

  ngOnInit(): void { this.loadData(); }
  ngOnDestroy(): void {
    this.loader.reset();
    this.arrUnsubscribe.forEach(s => s.unsubscribe());
    this.arrUnsubscribe = [];
  }

  private loadData(): void {
    this.loader.loader(true);
    const sub = this.api.{GetListAPIName}(this.filter).subscribe(
      (res) => {
        if (res.StatusCode === 0) {
          this.listData = res.ObjectReturn.Data || res.ObjectReturn || [];
          this.totalCount = res.ObjectReturn.Total || this.listData.length;
        } else {
          this.notification.onError('Error: ' + res.ErrorString);
        }
        this.loader.loader(false);
      },
      (err) => {
        this.loader.loader(false);
        this.notification.onError('Error: ' + err.message);
      }
    );
    this.arrUnsubscribe.push(sub);
  }

  onSetItem(item: any): void {
    this.cache.setItem(KeyLocalStorageEnum.{FEATURE}_DETAIL, item);
    this.router.navigate(['/mtbike/{dllpackage}-detail']);
  }

  onBack(): void { this.router.navigate(['/mtbike']); }
}
```

### List HTML Pattern (MANDATORY -- card-based, NO kendo-grid)
```html
<div class="mtb{NNN}-{abbr}-{feature}">
  <ps-header-back>
    <div class="left-side">
      <div class="func-title1">{Module}</div>
      <div class="func-title2">{FeatureVietnamese}</div>
    </div>
  </ps-header-back>

  <div class="list-body">
    <div class="card-item" *ngFor="let item of listData" (click)="onSetItem(item)">
      <div class="card-row">
        <span class="card-label">Mã</span>
        <span class="card-value">{{ item.Code }}</span>
      </div>
      <div class="card-row">
        <span class="card-label">{VietnameseLabel1}</span>
        <span class="card-value">{{ item.{Field1} }}</span>
      </div>
      <div class="card-row">
        <span class="card-label">{VietnameseLabel2}</span>
        <span class="card-value">{{ item.{Field2} }}</span>
      </div>
      <!-- Include 3-4 key fields using EXACT DTO field names from entity snapshot -->
    </div>
    <div class="empty-state" *ngIf="listData.length === 0">Không có dữ liệu</div>
  </div>

  <ps-footer-action>
    <ps-kendo-button (onClick)="onBack()">
      <span class="material-icons">arrow_back</span>
    </ps-kendo-button>
  </ps-footer-action>
</div>
```
> BA agent: Replace `{Field1}`, `{Field2}` with EXACT DTO field names from entity snapshot. Use top 3-4 most meaningful display fields (not Code alone).

---

## 3. Service Registration (2 files -- MUST follow namespace pattern)

> ⚠️ BANNED: `this.http.get/post/put/delete` -- direct HTTP is FORBIDDEN (R1).
> ALL calls go through the namespace-based service pattern below.

### 3a. mtbike-api-static.service.ts (APIID keys + namespaceMap -- BOTH required)

> ⚠️ READ `mtbike-api-static.service.ts` FIRST. Check if DLLPackage already exists in namespaceMap.
> assignApi() fills namespace keys with real URLs on login. Wrong namespace = silent 404 forever.

**CASE A -- DLLPackage already in namespaceMap (e.g. 'receipt' -> fpayment):**
```typescript
// DO NOT create new namespace. DO NOT modify namespaceMap.
// ADD keys to the EXISTING namespace object only:
export const fpayment = {
  loader: false,
  // ... existing keys stay as-is ...
  GetList{TableName}: '',    // ADD to existing object
  Get{TableName}: '',
  Update{TableName}: '',
  Delete{TableName}: '',
};
```

**CASE B -- DLLPackage NOT in namespaceMap (brand new feature area):**
```typescript
// Step 1: Create new namespace
export const f{namespace} = {
  loader: false,
  GetList{TableName}: '',
  Get{TableName}: '',
  Update{TableName}: '',
  Delete{TableName}: '',
};

// Step 2: MANDATORY -- add to namespaceMap (missing = silent 404)
const namespaceMap = {
  // ... existing entries ...
  '{dllpackage}': f{namespace},
};
```
> DLLPackage value comes from BE guide Section 8 `tbl_SYSFunction` INSERT. Key must match exactly.

### 3b. mtbike-api.service.ts (add Observable methods using namespace key)
```typescript
// Inside MtbikeApiService class
// CORRECT pattern: new Observable wrapping this.api.post() via getNamespace()
// WRONG: return this.post(...) -- this.post() does NOT exist
// WRONG: return this.api.post(...) directly -- must wrap in Observable

GetList{TableName}(filter: State): Observable<ResponseDTO> {
  return new Observable<ResponseDTO>((obs) => {
    this.api.post(MtbikeApiStaticService.getNamespace(this.dll).GetList{TableName}, toDataSourceRequest(filter))
      .subscribe((res: ResponseDTO) => { obs.next(res); obs.complete(); },
        (err) => { obs.error(err); obs.complete(); });
  });
}
Get{TableName}(payload: object): Observable<ResponseDTO> {
  return new Observable<ResponseDTO>((obs) => {
    this.api.post(MtbikeApiStaticService.getNamespace(this.dll).Get{TableName}, payload)
      .subscribe((res: ResponseDTO) => { obs.next(res); obs.complete(); },
        (err) => { obs.error(err); obs.complete(); });
  });
}
Update{TableName}(payload: object): Observable<ResponseDTO> {
  return new Observable<ResponseDTO>((obs) => {
    this.api.post(MtbikeApiStaticService.getNamespace(this.dll).Update{TableName}, payload)
      .subscribe((res: ResponseDTO) => { obs.next(res); obs.complete(); },
        (err) => { obs.error(err); obs.complete(); });
  });
}
Delete{TableName}(payload: object): Observable<ResponseDTO> {
  return new Observable<ResponseDTO>((obs) => {
    this.api.post(MtbikeApiStaticService.getNamespace(this.dll).Delete{TableName}, payload)
      .subscribe((res: ResponseDTO) => { obs.next(res); obs.complete(); },
        (err) => { obs.error(err); obs.complete(); });
  });
}
```
> Import required in mtbike-api.service.ts: `import { MtbikeApiStaticService } from "./mtbike-api-static.service";`
> `this.dll` = `config.GetDLL()` stored in constructor (already present in the service)

> Response format is always: `res.StatusCode === 0` (success), `res.ObjectReturn` (data), `res.ErrorString` (error)
> NEVER: `res.Success`, `res.Data`, `res.Message` -- those are wrong and will cause silent failures.

## 4. Screen Specs (Mobile-specific)

- List: card layout (div) -- NOT kendo-grid
- Card shows: top 3-4 key fields using **exact DTO field names**
- Card tap -> navigate to detail route via PsCache
- Sticky bottom action bar for primary actions
- Loading spinner via `SystemLoaderService.loader(true/false)`
- Error handling via `PsKendoNotificationService.onError()`

## 5. SCSS Rule (MANDATORY)

```scss
@import "../../../../../assets/scss/colors";
::ng-deep {
  mtb{NNN}-{abbr}-{feature} {        // {abbr} from MODULE METADATA
    .mtb{NNN}-{abbr}-{feature} {
      height: 100%;
    }
  }
}
```
NEVER use hardcoded hex -- use $primary, $error, $grey-600, etc.

## 6. Detail Component Pattern (MANDATORY -- List and Detail are SEPARATE components)

> DO NOT toggle `isDetailView` in the list component. Create a new mtb{NNN+1} component for detail.

### Navigation: List -> Detail
```typescript
// In list component, on card tap:
onSetItem(item: any): void {
  this.cache.setItem(KeyLocalStorageEnum.{FEATURE}_DETAIL, item);
  this.router.navigate(['/mtbike/{dllpackage}-detail']);
}
```

### Detail Component TS (mtb{NNN+1}-{abbr}-{feature}-detail)
```typescript
@Component({
  selector: 'mtb{NNN+1}-{abbr}-{feature}-detail',           // {abbr} from MODULE METADATA
  templateUrl: './mtb{NNN+1}-{abbr}-{feature}-detail.component.html',
  styleUrls: ['./mtb{NNN+1}-{abbr}-{feature}-detail.component.scss']
})
export class Mtb{NNN+1}{Abbr}{Feature}DetailComponent implements OnInit, OnDestroy {
  public item: any = null;
  // Declare one property per dropdown list needed in the form:
  public {dropdownFieldName}List: any[] = [];  // e.g. paymentMethodList, statusList

  constructor(
    private router: Router,
    private api: MtbikeApiService,
    private cache: PsCache,
    private notification: PsKendoNotificationService,
    private loader: SystemLoaderService,
  ) {}

  ngOnInit(): void {
    this.item = this.cache.getItem(KeyLocalStorageEnum.{FEATURE}_DETAIL);
    if (this.item?.Code) { this.loadDetail(this.item.Code); }
    this.load{DropdownFieldName}List();  // call ALL dropdown loaders here
  }

  ngOnDestroy(): void {
    this.loader.reset();
    this.arrUnsubscribe.forEach(s => s.unsubscribe());
    this.arrUnsubscribe = [];
  }

  private arrUnsubscribe: Subscription[] = [];

  // Dropdown loader pattern (repeat for each lookup list needed)
  private load{DropdownFieldName}List(): void {
    const sub = this.api.GetListLSList({ TypeData: {N} }).subscribe(
      (res) => {
        if (res.StatusCode === 0) {
          this.{dropdownFieldName}List = res.ObjectReturn || [];
        }
      }
    );
    this.arrUnsubscribe.push(sub);
  }
  // ⚠️ tbl_LSList dropdown valueField/textField:
  //   - Entity column stores: TypeOfList (integer 1, 2, 3...)
  //   - [valueField]="'TypeOfList'"  ← the stored value in the entity
  //   - [textField]="'ListName'"     ← the display name
  //   - NEVER [valueField]="'Code'"  for tbl_LSList-sourced dropdowns

  private loadDetail(code: number): void {
    this.loader.loader(true);
    const sub = this.api.Get{Feature}({ Code: code }).subscribe(
      (res) => {
        if (res.StatusCode === 0) { this.item = res.ObjectReturn; }
        else { this.notification.onError('Error: ' + res.ErrorString); }
        this.loader.loader(false);
      },
      (err) => { this.loader.loader(false); this.notification.onError('Error: ' + err.message); }
    );
    this.arrUnsubscribe.push(sub);
  }

  onSave(): void {
    this.loader.loader(true);
    const sub = this.api.Update{Feature}({ DTO: this.item, Properties: ['{Field1}', '{Field2}'] }).subscribe(
      (res) => {
        if (res.StatusCode === 0) {
          this.notification.onSuccess('Lưu thành công');
          this.router.navigate(['/mtbike/{dllpackage}']);
        } else { this.notification.onError('Error: ' + res.ErrorString); }
        this.loader.loader(false);
      },
      (err) => { this.loader.loader(false); this.notification.onError('Error: ' + err.message); }
    );
    this.arrUnsubscribe.push(sub);
  }

  onBack(): void { this.router.navigate(['/mtbike/{dllpackage}']); }
}
```

### Detail HTML Pattern
> Use the correct input component for each field type. Match field names EXACTLY to entity columns.
```html
<div class="mtb{NNN+1}-{abbr}-{feature}-detail">
  <ps-header-back (onBack)="onBack()">
    <div class="left-side">
      <div class="func-title1">{Module}</div>
      <div class="func-title2">Chi tiết {FeatureVietnamese}</div>
    </div>
  </ps-header-back>

  <div class="detail-body" *ngIf="item">
    <!-- string field: ps-kendo-textbox -->
    <div class="form-group">
      <label>{VietnameseLabel}</label>
      <ps-kendo-textbox [(value)]="item.{StringFieldName}"></ps-kendo-textbox>
    </div>
    <!-- number/amount field: ps-kendo-numerictextbox -->
    <div class="form-group">
      <label>{VietnameseLabel}</label>
      <ps-kendo-numerictextbox [(value)]="item.{DoubleFieldName}" [format]="'n0'"></ps-kendo-numerictextbox>
    </div>
    <!-- lookup/enum field: ps-kendo-dropdown-list -->
    <!-- BA agent: replace {enumFieldList} with a component property (e.g. paymentMethodList) loaded via API in ngOnInit -->
    <!-- ⚠️ valueField/textField depend on the data source:
         - Source = tbl_LSList (GetListLSList): [valueField]="'TypeOfList'" [textField]="'ListName'"
         - Source = tbl_LSStatus (GetListStatus): [valueField]="'Code'" [textField]="'StatusName'"
         - Source = other entity tables: [valueField]="'Code'" [textField]="'Name'"
         Match valueField to what the ENTITY COLUMN actually stores (check entity snapshot Notes column). -->
    <div class="form-group">
      <label>{VietnameseLabel}</label>
      <ps-kendo-dropdown-list
        [(value)]="item.{EnumFieldName}"
        [data]="{enumFieldList}"
        [valueField]="'{valueField}'"
        [textField]="'{textField}'">
      </ps-kendo-dropdown-list>
    </div>
    <!-- date field: ps-kendo-datepicker -->
    <div class="form-group">
      <label>{VietnameseLabel}</label>
      <ps-kendo-datepicker [(value)]="item.{DateFieldName}"></ps-kendo-datepicker>
    </div>
    <!-- readonly display field -->
    <div class="form-group">
      <label>{VietnameseLabel}</label>
      <span class="read-only-value">{{ item.{ReadonlyField} }}</span>
    </div>
  </div>

  <ps-footer-action>
    <ps-kendo-button (onClick)="onBack()">
      <span class="material-icons">arrow_back</span>
    </ps-kendo-button>
    <ps-kendo-button (onClick)="onSave()">
      <span class="material-icons">save</span>
    </ps-kendo-button>
  </ps-footer-action>
</div>
```
> BA agent: Replace each `{...}` with concrete values from entity snapshot. Include ONLY fields the user can edit (per SRS FR-xx). Read-only fields (Code, Head, CreatedBy, CreatedTime) use `<span>` not input.

### KeyLocalStorageEnum entry (MANDATORY)
Add to `src/app/models/enums/key-local-storage.enum.ts`:
```typescript
{FEATURE}_DETAIL = '{feature}-detail',
```

### Routing for Detail (add to mtbike.routing.ts)
```typescript
{ path: '{dllpackage}-detail', component: Mtb{NNN+1}{Abbr}{Feature}DetailComponent }
```

---

## 7. Registration Checklist (ALL in mtbike/ -- for BOTH List + Detail components)

| # | File | Action |
|---|------|--------|
| 1 | mtbike.module.ts | import + declare BOTH list and detail components |
| 2 | mtbike.routing.ts | add route for list (`{dllpackage}`) and detail (`{dllpackage}-detail`) |
| 3 | mtbike-api-static.service.ts | add APIID keys to EXISTING namespace |
| 4 | mtbike-api.service.ts | add Observable methods for GetList, Get, Update, Delete |
| 5 | key-local-storage.enum.ts | add `{FEATURE}_DETAIL` key for cache navigation |

## 7. Build Verify

Run `ng build` on server -- MUST pass with 0 errors before commit.
```
