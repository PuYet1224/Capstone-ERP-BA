# FE Coding Standards -- Hoai Minh ERP

> Summary for BA reference when generating FE guides.

## Stack

| Layer | Technology |
|-------|-----------|
| Framework | Angular 16 |
| UI Library | Kendo UI 13 |
| Styling | SCSS with design tokens |
| HTTP | PSAPIService (custom wrapper) |
| Core APIs | PSCoreApiService (shared lookups) |

## Component Naming

- Web: `{Module}{Seq}{Feature}Component` in `views/{module}/views/{module}{seq}-{feature}/`
- Mobile: `Mtb{NNN}{Abbr}{Feature}Component` in `views/mtbike/views/mtb{NNN}-{abbr}-{feature}/`
  - `{abbr}` = module abbreviation from guide MODULE METADATA (sal=Sale, cs=Repair, wh=Warehouse, crm=CRM, hrm=HRM, prt=Parts, rpt=Report)
  - WRONG: `Mtb028ReceiptComponent` (missing abbr), CORRECT: `Mtb028SalReceiptComponent`

## Service Pattern

```typescript
// Static service: URL constants
export class {Module}ApiStaticService {
  static readonly {KEY} = {
    GetList{Feature}: 'api/{module}/{Action}',
  };
}

// API service: Observable methods
GetList{Feature}(param: State): Observable<ResponseDTO> {
  return this.api.callService(
    {Module}ApiStaticService.{KEY}.GetList{Feature}, param
  );
}
```

## DTO Pattern

```typescript
// File: models/dtos/e-dtos/{module}-{feature}.dto.ts
export interface {Module}{Feature}DTO {
  Code: number;
  // ... all fields FE displays
}

export interface {Module}{Feature}CusDTO {
  Code: number;  // identifies record
}
```

## SCSS Rules

- NEVER hardcode hex colors -- use `$primary`, `$error`, `$grey-600`
- Mobile: `@import "../../../../../assets/scss/colors";`
- Mobile: `::ng-deep { mtb{NNN}-{abbr}-{feature} { .mtb{NNN}-{abbr}-{feature} { ... } } }` wrapper

## Shared Kendo Wrappers (HM-specific)

| Element | Use This (NOT raw Kendo) |
|---------|-------------------------|
| Text input | `<ps-kendo-textbox>` |
| Dropdown | `<ps-kendo-dropdown-list>` |
| Grid | `<ps-kendo-grid>` + `<kendo-grid-column>` |
| Button | `<ps-kendo-button theme="success">` |
| Toolbar | `<ps-toolbar-top>` |
| Confirm dialog | `<ps-dialog-confirm>` |
