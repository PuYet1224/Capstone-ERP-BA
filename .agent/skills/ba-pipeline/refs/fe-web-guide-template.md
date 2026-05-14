# FE Web Guide Template

> Used by ba-pipeline STEP 8. Fill ALL sections with concrete values.

```markdown
# FE Web Implementation Guide: {FeatureName}
> **Generated from:** REQ_{SEQ}_{Name}.md + Figma Analysis
> **Generated at:** {ISO timestamp}
> **Platform:** Web (Angular 16 + Kendo UI 13, Product = 1)

> ---
> **MODULE METADATA (SSoT — FE Desktop agent reads from here):**
> - **Module:** {ModuleCode} / {SubModule}  _(e.g., MTB / M.Sale)_
> - **Route prefix:** {routePrefix}  _(e.g., /sale/ — from tbl_SYSAPI URL column)_
> - **DLL Package:** {dllpackage}  _(FE routing key, matches PSMtbikeApiStaticService field)_
> - **DB Product:** Desktop=1
> ---

---

## 1. Overview

{Brief description. List all screens.}

| Screen ID | Component Name | Route | File Path |
|---|---|---|---|
| SCR-01 | {Module}{Seq}{Feature}Component | /{module}/{seq}-{feature} | views/{module}/views/{module}{seq}-{feature}/ |

---

## 2. Service Files

### {module}-api-static.service.ts
```typescript
export class {Module}ApiStaticService {
  static readonly {DLL_KEY} = {
    GetList{Feature}: 'api/{module}/{Action}',
    Get{Feature}: 'api/{module}/{Action}',
    Update{Feature}: 'api/{module}/{Action}',
    Delete{Feature}: 'api/{module}/{Action}',
  };
}
```

### {module}-api.service.ts
```typescript
GetList{Feature}(param: State): Observable<ResponseDTO> { /* PSAPIService pattern */ }
Get{Feature}(param: {Module}{Feature}CusDTO): Observable<ResponseDTO> { }
Update{Feature}(param: UpdatePropertiesInterface<{Module}{Feature}CusDTO>): Observable<ResponseDTO> { }
Delete{Feature}(param: {Module}{Feature}CusDTO): Observable<ResponseDTO> { }
```

---

## 3. DTO Files

### {module}-{feature}.dto.ts
```typescript
export interface {Module}{Feature}DTO {
  Code: number;
  {field}: {type};   // SRS Sec. 6.2
  Status: number;
  StatusName: string;
}

export interface {Module}{Feature}CusDTO {
  Code: number;
}
```

---

## 4. Enum Files

### e-status/{module}-{feature}-status.enum.ts
```typescript
export enum {Module}{Feature}StatusEnum {
  {Name1} = {N},  // "{Display1}"
  {Name2} = {N},  // "{Display2}" TERMINAL
}
```

---

## 5. Shared Core Services

| Data | FE Method | Param | Load When |
|---|---|---|---|
| {label} | coreApi.{Method}({param}) | {value} | {trigger} |

---

## 6. Screen Specifications

### SCR-01: List Screen

**Grid Columns:**
| field | title | width | format | sortable |
|---|---|---|---|---|
| {field} | "{label}" | {px} | {format} | true |

**Filter Bar:**
| Component | Binding | API | Label |
|---|---|---|---|
| kendo-daterangepicker | dateFrom/dateTo | - | "From - To" |

**Toolbar Buttons:**
| Button | Label | Visible When | Action |
|---|---|---|---|
| Add | "{label}" | Always | openDialog(null) |

### SCR-02: Detail Screen

**Form Fields:**
| Field | Label | Component | Editable When Status = |
|---|---|---|---|
| {field} | "{label}" | ps-input | {StatusName1} |

**Action Buttons:**
| Button | Label | Show When | Action |
|---|---|---|---|
| Save | "{label}" | Status={Name1} | callUpdate() |

---

## 7. Status Badge

```typescript
getStatusClass(status: number): string {
  return {
    [{Module}{Feature}StatusEnum.{Name1}]: 'badge badge-warning',
    [{Module}{Feature}StatusEnum.{Name2}]: 'badge badge-success',
  }[status] || 'badge badge-secondary';
}
```

---

## 8. Validation (Reactive Forms)

```typescript
this.form = this.fb.group({
  {field}: [null, [Validators.required]],    // AC-{nn}
  {amount}: [null, [Validators.min(1)]],     // BR-{nn}
});
```

---

## 9. Layout Rules

1. ps-layout -> ps-toolbar-top -> ps-table / form
2. Scroll: overflow-x: auto
3. Buttons: ONLY inside ps-toolbar
4. Loading: kendo-loader for all API calls
5. Empty grid: show "No data available"

---

## 10. Figma -- SRS Discrepancies

| Type | Element | Details | Action |
|---|---|---|---|
| {type} | {element} | {details} | {action} |

---

## 11. Pending Decisions

| TBD | Question | Blocks | Temp Fix |
|---|---|---|---|
| TBD-{nn} | {question} | FR-{nn} | {workaround} |
```
