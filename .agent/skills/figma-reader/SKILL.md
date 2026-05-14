---
skill: figma-reader
role: BA
version: 1.0
trigger: "'analyze design', 'read figma', 'what does screen look like', 'UI', 'screen'"
---

# Figma Reader Skill -- BA Design Analysis (Body Content Only)

## Purpose

Read live Figma Desktop data via MCP bridge, extract body-content specs for FE guides.
Skips sidebar, header, and footer -- analyzes ONLY the main content area.

## Hard Rules

- RULE-FG-01: Figma MCP is the ONLY design source. NEVER fall back to local images.
- RULE-FG-02: NEVER analyze or include sidebar, header, or footer in output specs.
- RULE-FG-03: NEVER output raw hex colors -- always map to SCSS variable.
- RULE-FG-04: NEVER reference raw Kendo component names -- always map to HM wrappers.
- RULE-FG-05: ALWAYS declare source at start: "Reading from Figma Desktop (live)"

## Steps

### Phase 0 -- Connection Check
- Action: Call `figma_status` immediately.
  - CONNECTED -> proceed to Phase 1
  - NOT CONNECTED -> STOP. Tell user: "Figma Desktop not connected. Please open Figma + MCP plugin."
  - DO NOT fall back to archive images. DO NOT proceed without live Figma.
- Gate: figma_status = CONNECTED before any read.

### Phase 1 -- Figma Live Read

1. **Read selected frame**
   - Call: `figma_read operation: "get_selection" depth: 6, detail: "compact"`
   - Output: Full frame tree (includes sidebar, header, body)

2. **Filter -- isolate BODY node only**
   - SKIP nodes matching: "Sidebar", "Nav", "Navigation", "Menu", "Side", "Header", "Top bar", "Navbar", "Footer", "Bottom bar"
   - SKIP nodes positioned at x=0 with narrow width (sidebar)
   - SKIP nodes positioned at y=0 with small height (header)
   - SELECT the LARGEST node by area, positioned right of sidebar and below header
   - Body node name often contains: "Content", "Body", "Main", "Page", or the feature name
   - Gate: Body node identified before any CSS/design read.

3. **Get CSS for body section only**
   - Call: `figma_read operation: "get_css" nodeId: <BODY_NODE_ID>`

4. **Get detailed design for body sections**
   - Call: `figma_read operation: "get_design" nodeId: <BODY_NODE_ID> depth: 6`

5. **Check color variable names** (for each colored element)
   - Call: `figma_read operation: "get_node_detail" nodeId: <node_id>`

### Phase 2 -- Produce Spec Output

- Self-check before writing any spec:
  - "Am I describing sidebar or header?" -> YES -> DELETE that section
  - "Am I describing body content only?" -> YES -> Continue
- Gate: Output contains ONLY body content.

## Color Mapping (Mandatory)

NEVER output raw hex. Always map:

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

Unknown color -> flag: "[!] Unknown color #XXXXXX - needs SCSS variable assignment"

## Component Mapping (Mandatory)

NEVER reference raw Kendo names. Always map to HM wrapper:

| Figma Element | HM Angular Component |
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

## Output Format

For EVERY screen analyzed:

```markdown
## BA Design Analysis: {frame_name}

> Source: Figma Desktop (live) - {timestamp}
> Analysis covers BODY content ONLY - sidebar/header excluded

### A. SCREEN OVERVIEW
- Frame: {name} ({width}x{height})
- Body node: {body_node_name} ({body_width}x{body_height})
- Screen type: List / Detail / Dashboard / Form

### B. LAYOUT STRUCTURE (body only)
- Sections (top to bottom)
- Spacing: {gap between sections}

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
- Required fields, status-driven visibility, navigation links
```
