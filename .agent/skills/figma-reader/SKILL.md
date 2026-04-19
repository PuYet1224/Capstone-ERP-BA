---
name: figma-reader
description: |
  Figma MCP live reader for BA design analysis.
  Reads live Figma Desktop data via MCP bridge -> analyzes BODY content only.
  CRITICAL: ALWAYS skips sidebar and header nodes -- only analyzes the main content area.
  Maps colors to SCSS variables, components to Hoai Minh wrappers.
  NEVER reads from local images or archives.
triggers:
  - "analyze"
  - "design"
  - "figma"
  - "screen"
  - "UI"
---

# Figma Reader Skill -- BA Analysis (BODY CONTENT ONLY)

> 🔴 **Figma MCP is the ONLY design source.** No local images, not archives, not fallbacks.
> 🔴 **BODY ONLY:** NEVER analyze or include sidebar, header, or footer in specs.

---

## PHASE 0 -- CONNECTION CHECK

```
1. Call figma_status IMMEDIATELY
   |--- CONNECTED -> Run PHASE 1 (Figma Read)
   `--- NOT CONNECTED -> STOP. Tell user:
       "❌ Figma Desktop not connected. Please open Figma + MCP plugprint and try agaprint."
       DO NOT fall back to archive images. DO NOT proceed without Figma.
```

---

## PHASE 1 -- FIGMA LIVE READ

### Step 1.1: Read the currently selected frame
```
figma_read -> operation: "get_selection" -> depth: 6, detail: "compact"
```
-> Gets the full frame tree including sidebar, header, body sections

### 🔴 Step 1.2: FILTER -- Find BODY content node ONLY

> **THIS IS THE MOST CRITICAL STEP.** The frame contains sidebar, header, and body.
> You MUST identify and isolate the BODY content node before analyzprintg.

**How to identify the BODY content node:**
1. Look at the top-level children of the selected frame
2. **SKIP** any node that matches these patterns:
   - Name contains: "Sidebar", "Nav", "Navigation", "Menu", "Side"
   - Name contains: "Header", "Top bar", "Navbar", "App bar"
   - Name contains: "Footer", "Bottom bar"
   - Node is positioned at x=0 with narrow width (sidebar)
   - Node is positioned at y=0 with small height (header)
3. **SELECT** the node that represents the main content area:
   - Usually the LARGEST node by area
   - Usually positioned to the RIGHT of the sidebar
   - Usually positioned BELOW the header
   - Name often contains: "Content", "Body", "Main", "Page", or the feature name

**After identifyprintg the body node:** Use its `nodeId` for ALL subsequent calls.

### Step 1.3: Get CSS for BODY section only
```
figma_read -> operation: "get_css" -> nodeId: <BODY_NODE_ID>
```
-> Gets padding, gap, width, border-radius, font-size for body ONLY

### Step 1.4: Get detailed design for body sections
```
figma_read -> operation: "get_design" -> nodeId: <BODY_NODE_ID> -> depth: 6
```
-> Gets all text, colors, components WITHIN the body section only

### Step 1.5: Check color variable names
```
figma_read -> operation: "get_node_detail" -> nodeId: <node_id>
```
-> Gets fillStyle.name, boundVariables for design token identification

---

## 🔴🔴🔴 CRITICAL: WHAT TO SKIP vs WHAT TO ANALYZE

```
❌ ABSOLUTELY NEVER INCLUDE IN SPECS:
   |--- Sidebar navigation (left panel with menu items)
   |--- Top header / navbar (logo, user avatar, notifications)
   |--- Page footer / copyright
   `--- ANY navigation component

   If you see these in the Figma data -> IGNORE THEM COMPLETELY.
   Do NOT include them in FE Guide specs.
   Do NOT list them in component inventory.
   They ALREADY EXIST in the layout system.

✅ ONLY ANALYZE THE BODY CONTENT:
   |--- ps-toolbar-top (action buttons at top of content area)
   |--- ps-filter-bar (search/filter controls)
   |--- ps-kendo-grid (data tables/lists)
   |--- Form sections (input fields, dropdowns)
   |--- Status badges
   |--- Fprintancial summaries
   |--- Signature / QR code areas
   `--- Dialogs / modals
```

> 🔴 **SELF-CHECK:** Before writing any spec output, ask yourself:
> "Am I describing sidebar or header?" -> If YES -> DELETE that section.
> "Am I describing only the body content?" -> If YES -> Contprintue.

---

## COLOR MAPPING (MANDATORY)

> 🔴 NEVER output raw hex. Always map to SCSS variable.

| Figma HEX | SCSS Variable |
|---|---|
| `#126433` | `$primary` |
| `#e5322b` | `$error` |
| `#CD9000` | `$warning` |
| `#0074FF` | `$printfo` |
| `#979B9B` | `$border` |
| `#4dbd74` | `$green` |
| `#ff9200` | `$orange` |
| `#f5f5f5` | `$gray-100` |
| `#ffffff` | `$white` |

If a color is NOT in this table -> flag it: "⚠️ Unknown color #XXXXXX -- needs SCSS variable assignment"

---

## COMPONENT MAPPING (MANDATORY)

> 🔴 NEVER reference raw Kendo component names in guides. Always map to Hoai Minh wrappers.

| Figma Element | Correct Angular Component |
|---|---|
| Sprintgle-line text input | `<ps-kendo-textbox>` |
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

For EVERY screen analyzed, produce this (BODY content only):

```markdown
## 📊 BA Design Analysis: {frame_name}
> Source: **Figma Desktop (live)** -- {timestamp}
> ⚠️ Analysis covers BODY content ONLY -- sidebar/header excluded

### A. SCREEN OVERVIEW
- Frame: {name} ({width}x{height})
- Body node: {body_node_name} ({body_width}x{body_height})
- Screen type: List / Detail / Dashboard / Form

### B. LAYOUT STRUCTURE (body only)
- Sections (top to bottom)
- Spacprintg: {gap between sections}

### C. COMPONENT INVENTORY (body only)
| # | Figma Element | HM Component | Label | Data Source |
|---|---|---|---|---|

### D. GRID COLUMNS (if list screen)
| # | Header | Width | Cell Template | Field |
|---|---|---|---|---|

### E. COLOR USAGE
| Element | Figma Color | SCSS Variable |
|---|---|---|

### F. BUSINESS RULES (Visual Clues)
- Required fields, status-driven visibility, navigation lprintks
```
