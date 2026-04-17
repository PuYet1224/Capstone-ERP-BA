---
name: figma-variables
description: Create and manage Hoai Minh ERP design token variables in Figma. Establishes the complete color system, spacing, typography, and shape tokens as Figma Variables with Light/Dark mode support. Used by the UI Designer agent.
---

# Figma Variables Skill — Hoai Minh Design System

> **Purpose:** Create and maintain Hoai Minh ERP design tokens as Figma Variables.
> **API:** Uses `figma.setupDesignTokens()` — idempotent, safe to re-run anytime.
> **Result:** All colors, spacing, typography bound to Figma Variables → change once, update everywhere.

---

## 🔴 MANDATORY: Read figma_docs FIRST

Before writing ANY code, call:
```
figma_docs(section: 'tokens')
```

---

## Hoai Minh Design Token Reference

### Color Palette (Source of truth)

| Token Name | Light Mode | Dark Mode | Usage |
|------------|-----------|-----------|-------|
| `color/primary` | `#126433` | `#1a8a47` | Primary actions, links |
| `color/primary-light` | `#e8f5ee` | `#0d3d20` | Primary backgrounds, hover |
| `color/primary-dark` | `#0d4a26` | `#0a2f18` | Primary pressed states |
| `color/error` | `#dc2626` | `#ef4444` | Error, danger, debt amounts |
| `color/error-light` | `#fef2f2` | `#3d0a0a` | Error backgrounds |
| `color/warning` | `#cd9000` | `#e0a010` | Pending, caution |
| `color/warning-light` | `#fffbeb` | `#3d2a00` | Warning backgrounds |
| `color/info` | `#0074ff` | `#3b94ff` | Processing, informational |
| `color/info-light` | `#eff6ff` | `#001d3d` | Info backgrounds |
| `color/success` | `#16a34a` | `#22c55e` | Success, completed |
| `color/success-light` | `#f0fdf4` | `#052e16` | Success backgrounds |
| `color/bg-base` | `#ffffff` | `#0f1117` | Page background |
| `color/bg-surface` | `#f9fafb` | `#1a1d27` | Card, panel background |
| `color/bg-elevated` | `#f3f4f6` | `#242736` | Elevated surfaces |
| `color/text-primary` | `#111827` | `#f9fafb` | Main text |
| `color/text-secondary` | `#6b7280` | `#9ca3af` | Secondary, caption text |
| `color/text-disabled` | `#9ca3af` | `#4b5563` | Disabled text |
| `color/border` | `#e5e7eb` | `#2d3139` | Default borders |
| `color/border-strong` | `#d1d5db` | `#4b5563` | Strong borders, dividers |

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `spacing/xs` | 4 | Icon gaps, tiny padding |
| `spacing/sm` | 8 | Small padding, close items |
| `spacing/md` | 12 | Default field padding |
| `spacing/lg` | 16 | Card padding, section gaps |
| `spacing/xl` | 24 | Section margins |
| `spacing/2xl` | 32 | Large section gaps |
| `spacing/3xl` | 48 | Page margins |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius/xs` | 4 | Small tags, badges |
| `radius/sm` | 6 | Buttons, inputs |
| `radius/md` | 8 | Cards, dropdowns |
| `radius/lg` | 10 | Modals, panels |
| `radius/xl` | 16 | Large cards |
| `radius/full` | 9999 | Pills, avatars |

### Typography

| Token | Value | Usage |
|-------|-------|-------|
| `font/family-primary` | `Mulish` | All ERP text |
| `font/size-xs` | 11 | Captions, badges |
| `font/size-sm` | 12 | Secondary labels |
| `font/size-body` | 13 | Default body |
| `font/size-md` | 14 | Standard text |
| `font/size-lg` | 16 | Section headings |
| `font/size-xl` | 18 | Page sub-titles |
| `font/size-2xl` | 24 | Page titles |

---

## Execution Steps

### Step 1: Check connection
```js
// Always check figma_status first
figma_status → must be pluginConnected: true
```

### Step 2: Create Color Variables (Light + Dark)
```js
await figma.setupDesignTokens({
  collectionName: "HM Colors",
  modes: ["Light", "Dark"],
  colors: {
    "color/primary":        { Light: "#126433", Dark: "#1a8a47" },
    "color/primary-light":  { Light: "#e8f5ee", Dark: "#0d3d20" },
    "color/primary-dark":   { Light: "#0d4a26", Dark: "#0a2f18" },
    "color/error":          { Light: "#dc2626", Dark: "#ef4444" },
    "color/error-light":    { Light: "#fef2f2", Dark: "#3d0a0a" },
    "color/warning":        { Light: "#cd9000", Dark: "#e0a010" },
    "color/warning-light":  { Light: "#fffbeb", Dark: "#3d2a00" },
    "color/info":           { Light: "#0074ff", Dark: "#3b94ff" },
    "color/info-light":     { Light: "#eff6ff", Dark: "#001d3d" },
    "color/success":        { Light: "#16a34a", Dark: "#22c55e" },
    "color/success-light":  { Light: "#f0fdf4", Dark: "#052e16" },
    "color/bg-base":        { Light: "#ffffff", Dark: "#0f1117" },
    "color/bg-surface":     { Light: "#f9fafb", Dark: "#1a1d27" },
    "color/bg-elevated":    { Light: "#f3f4f6", Dark: "#242736" },
    "color/text-primary":   { Light: "#111827", Dark: "#f9fafb" },
    "color/text-secondary": { Light: "#6b7280", Dark: "#9ca3af" },
    "color/text-disabled":  { Light: "#9ca3af", Dark: "#4b5563" },
    "color/border":         { Light: "#e5e7eb", Dark: "#2d3139" },
    "color/border-strong":  { Light: "#d1d5db", Dark: "#4b5563" },
  }
});
```

### Step 3: Create Spacing & Radius Variables
```js
await figma.setupDesignTokens({
  collectionName: "HM Spacing",
  numbers: {
    "spacing/xs":  4,  "spacing/sm":  8,  "spacing/md":  12,
    "spacing/lg":  16, "spacing/xl":  24, "spacing/2xl": 32, "spacing/3xl": 48,
    "radius/xs":   4,  "radius/sm":   6,  "radius/md":   8,
    "radius/lg":   10, "radius/xl":   16, "radius/full": 9999,
  }
});
```

### Step 4: Create Typography Variables
```js
await figma.setupDesignTokens({
  collectionName: "HM Typography",
  fonts: {
    "font/family-primary": "Mulish",
  },
  fontSizes: {
    "font/size-xs":   11, "font/size-sm":  12, "font/size-body": 13,
    "font/size-md":   14, "font/size-lg":  16, "font/size-xl":   18,
    "font/size-2xl":  24,
  }
});
```

---

## When to Re-run

- ✅ **Always safe** — `setupDesignTokens` is idempotent (updates existing, creates new)
- Run after design system color updates
- Run when adding new token categories

## Applying Variables to Nodes

After creating variables, bind them to frames/components:
```js
await figma.applyVariable({ nodeId: card.id, field: "fill", variableName: "color/bg-surface" });
await figma.applyVariable({ nodeId: card.id, field: "cornerRadius", variableName: "radius/md" });
await figma.applyVariable({ nodeId: text.id, field: "fill", variableName: "color/text-primary" });
```

## Switching Modes per Frame
```js
await figma.setFrameVariableMode({ nodeId: frame.id, collectionId: colId, modeName: "Dark" });
```
