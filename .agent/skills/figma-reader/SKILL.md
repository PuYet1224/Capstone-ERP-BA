---
name: figma-reader
description: |
  Figma MCP live reader for BA design analysis.
  Reads live Figma Desktop data via MCP bridge → analyzes BODY content only (no sidebar/header).
  Maps colors to SCSS variables, components to Hoài Minh wrappers.
  NEVER reads from local images or archives.
triggers:
  - "analyze"
  - "design"
  - "figma"
  - "screen"
  - "UI"
---

# Figma Reader Skill — BA Analysis (Figma MCP Only)

> 🔴 **Figma MCP is the ONLY design source.** No local images, no archives, no fallbacks.
> If Figma is not connected → STOP. Do NOT read local images.

---

## PHASE 0 — CONNECTION CHECK

```
1. Call figma_status IMMEDIATELY
   ├── CONNECTED → Run PHASE 1 (Figma Read)
   └── NOT CONNECTED → STOP. Tell user:
       "❌ Figma Desktop not connected. Please open Figma + MCP plugin and try again."
       DO NOT fall back to archive images. DO NOT proceed without Figma.
```

---

## PHASE 1 — FIGMA LIVE READ (When connected)

### Step 1.1: Read the currently selected frame
```
figma_read → operation: "get_selection" → depth: 6, detail: "compact"
```
→ Gets: frame name, dimensions, main child node structure

### Step 1.2: Scan the full design
```
figma_read → operation: "scan_design"
```
→ Gets: all text, colors (hex), fonts, icons, sections — structured summary

### Step 1.3: Get CSS for each body section
```
figma_read → operation: "get_css" → nodeId: <section_node_id>
```
→ Gets: padding, gap, width, border-radius, font-size values in exact px

### Step 1.4: Check color variable names
```
figma_read → operation: "get_node_detail" → nodeId: <node_id>
```
→ Gets: fillStyle.name, boundVariables for design token identification

---

## PHASE 2 — BODY CONTENT ONLY

```
🚫 IGNORE (layout system handles these):
   - Sidebar navigation
   - Top header / navbar
   - Page footer / copyright

✅ FOCUS ON (body content only):
   - Breadcrumb structure
   - Toolbar (ps-toolbar-top) — action buttons
   - Filter bar — search, status dropdowns, date range, toggles
   - Grid — columns, widths, cell templates, master-detail
   - Form sections — field groups, labels, input types
   - Status badges — text, colors, conditions
   - Special components — QR codes, signatures, progress bars
   - Financial summaries — amounts, totals, remaining
   - Dialogs / modals
```

---

## COLOR MAPPING (MANDATORY)

> 🔴 NEVER output raw hex. Always map to SCSS variable.

| Figma HEX | SCSS Variable |
|---|---|
| `#126433` | `$primary` |
| `#e5322b` | `$error` |
| `#CD9000` | `$warning` |
| `#0074FF` | `$info` |
| `#979B9B` | `$border` |
| `#4dbd74` | `$green` |
| `#ff9200` | `$orange` |
| `#f5f5f5` | `$gray-100` |
| `#ffffff` | `$white` |

If a color is NOT in this table → flag it: "⚠️ Unknown color #XXXXXX — needs SCSS variable assignment"

---

## COMPONENT MAPPING (MANDATORY)

> 🔴 NEVER reference raw Kendo component names in guides. Always map to Hoài Minh wrappers.

| Figma Element | Correct Angular Component |
|---|---|
| Single-line text input | `<ps-kendo-textbox>` |
| Number input | `<ps-kendo-numeric-textbox>` |
| Dropdown / Select | `<ps-kendo-dropdown-list>` |
| Date picker | `<kendo-datepicker>` |
| Textarea | `<kendo-textarea>` |
| Checkbox | `<input kendoCheckBox>` |
| Data table / Grid | `<ps-kendo-grid>` + `<kendo-grid-column>` |
| Tabs | `<kendo-tabstrip>` |
| Button (primary) | `<ps-kendo-button theme="success">` |
| Button (danger) | `<ps-kendo-button theme="error">` |
| Dialog / Confirm | `<ps-dialog-confirm>` |
| Status badge | `<span class="status-badge">` + SCSS |
| Toolbar actions | `<ps-toolbar-top>` |
| Search filter | `<ps-filter-textbox>` |
| Status filter | `<ps-filter-status1>` |
| Filter buttons | `<ps-filter-button>` |

---

## STRUCTURED OUTPUT FORMAT

For EVERY screen analyzed, produce:

```markdown
## 📊 BA Design Analysis: {frame_name}
> Source: **Figma Desktop (live)** — {timestamp}

### A. SCREEN OVERVIEW
- Frame: {name} ({width}x{height})
- Screen type: List / Detail / Dashboard / Form

### B. LAYOUT STRUCTURE
- Sections (top to bottom)
- Spacing: {gap between sections}

### C. COMPONENT INVENTORY
| # | Figma Element | HM Component | Label | Data Source |
|---|---|---|---|---|

### D. GRID COLUMNS (if list screen)
| # | Header | Width | Cell Template | Field |
|---|---|---|---|---|

### E. COLOR USAGE
| Element | Figma Color | SCSS Variable |
|---|---|---|

### F. BUSINESS RULES (Visual Clues)
- Required fields, status-driven visibility, navigation links
```
