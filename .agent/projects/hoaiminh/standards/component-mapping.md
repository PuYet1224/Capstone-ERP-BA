# Component Mapping -- Figma to Angular (Hoai Minh ERP)

> Source of truth for translating Figma design elements into Angular code.
> Used by: ba-pipeline (when creating FE guides), FE developers (when coding).
> Keep in sync with figma-reader/SKILL.md color/component tables.

---

## 1. COLOR TOKENS

> NEVER hardcode hex. Always use SCSS variables.

| Figma HEX | SCSS Variable | Semantic Use |
|-----------|---------------|-------------|
| `#126433` | `$primary` | Main action buttons, links, active states |
| `#e5322b` | `$error` | Error messages, danger buttons, required markers |
| `#CD9000` | `$warning` | Warning badges, pending status |
| `#0074FF` | `$info` | Info badges, help icons |
| `#979B9B` | `$border` | Input borders, dividers |
| `#4dbd74` | `$green` | Success status, approved badges |
| `#ff9200` | `$orange` | Processing status, attention |
| `#f5f5f5` | `$gray-100` | Background, disabled inputs |
| `#ffffff` | `$white` | Cards, modals, form backgrounds |

---

## 2. FORM COMPONENTS

| Figma Element | Angular Component | Key Props | Notes |
|--------------|-------------------|-----------|-------|
| Single-line text input | `<ps-kendo-textbox>` | `[label]` `[required]` `[(ngModel)]` | Custom wrapper with label |
| Number input | `<ps-kendo-numeric-textbox>` | `[format]` `[min]` `[max]` | Supports currency format |
| Textarea | `<kendo-textarea>` | `[rows]` `[(ngModel)]` | Raw Kendo (no wrapper) |
| Dropdown / Select | `<ps-kendo-dropdown-list>` | `[data]` `[textField]` `[valueField]` | Custom wrapper |
| Multi-select | `<ps-kendo-multiselect>` | `[data]` `[textField]` `[valueField]` | Custom wrapper |
| Date picker | `<kendo-datepicker>` | `[format]` `[(value)]` | Raw Kendo |
| Checkbox | `<input kendoCheckBox>` | `[checked]` | Kendo directive |
| Radio group | `<kendo-radiogroup>` | `[data]` `[(value)]` | Raw Kendo |

---

## 3. DATA DISPLAY

| Figma Element | Angular Component | Key Props | Notes |
|--------------|-------------------|-----------|-------|
| Data table / Grid | `<ps-kendo-grid>` | `[data]` `[height]` `[resizable]` | Custom wrapper |
| Grid column | `<kendo-grid-column>` | `[field]` `[title]` `[width]` | Inside ps-kendo-grid |
| Status badge | `<span class="status-badge">` | CSS class per status | SCSS colors from tokens |
| Tabs | `<kendo-tabstrip>` | `<kendo-tabstrip-tab>` children | Raw Kendo |

---

## 4. BUTTONS AND ACTIONS

| Figma Element | Angular Component | Theme | Use |
|--------------|-------------------|-------|-----|
| Primary button (green) | `<ps-kendo-button theme="success">` | success | Save, Submit, Approve |
| Danger button (red) | `<ps-kendo-button theme="error">` | error | Delete, Reject, Cancel |
| Secondary button | `<ps-kendo-button>` | (default) | Close, Back, minor actions |
| Icon button | `<ps-kendo-button>` + icon class | varies | Edit, View, Print |

---

## 5. LAYOUT COMPONENTS

| Figma Element | Angular Component | Notes |
|--------------|-------------------|-------|
| Top toolbar (action buttons) | `<ps-toolbar-top>` | ALWAYS contains action buttons |
| Filter bar | `<ps-filter-bar>` or inline | Search + status + date filters |
| Search text filter | `<ps-filter-textbox>` | Quick search input |
| Status filter | `<ps-filter-status1>` | Status dropdown filter |
| Filter action buttons | `<ps-filter-button>` | Search / Clear buttons |
| Confirm dialog | `<ps-dialog-confirm>` | Confirm before delete/status change |
| Full page layout | `<ps-layout>` | Wraps entire page content |

---

## 6. PRE-BUILT SYSTEM COMPONENTS (DO NOT RE-IMPLEMENT)

> These components exist in the shell layout. BA and FE must NEVER re-specify them.

| Component | Location | Why Skip |
|-----------|----------|----------|
| Sidebar / Navigation | Left side | Already built in AppComponent |
| Header / Top bar | Top | Already built in AppComponent |
| Footer | Bottom | Already built in AppComponent |
| Breadcrumb | Below header | Auto-generated from routing |
| User avatar / logout | Header right | System component |

---

## 7. MOBILE-SPECIFIC COMPONENTS

| Figma Element | Mobile Code | Notes |
|--------------|-------------|-------|
| Card list (not grid) | `<ul><li>` or `<div class="card">` | Mobile uses cards, NOT kendo-grid |
| Bottom action bar | `<div class="bottom-bar">` | Fixed bottom, primary actions |
| Touch target | min 44px height | Accessibility requirement |

---

## 8. STATUS BADGE PATTERN

```typescript
// Standard pattern for all features
getStatusClass(status: number): string {
  return {
    [StatusEnum.Draft]: 'badge badge-warning',
    [StatusEnum.Pending]: 'badge badge-info',
    [StatusEnum.Approved]: 'badge badge-success',
    [StatusEnum.Rejected]: 'badge badge-danger',
    [StatusEnum.Completed]: 'badge badge-primary',
    [StatusEnum.Cancelled]: 'badge badge-secondary',
  }[status] || 'badge badge-secondary';
}
```
