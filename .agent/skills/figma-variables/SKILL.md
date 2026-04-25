---
name: figma-variables
description: Knowledge base for Capstone ERP design tokens - colors, spacing, typography, and radius values. Reference for the /figma-variables workflow when creating Figma Variables.
---

# Figma Variables Skill - Capstone Design System

> **Purpose:** Create and maintain Capstone ERP design tokens as Figma Variables.
> **API:** Uses `figma.setupDesignTokens()` - idempotent, safe to re-run anytime.
> **Result:** All colors, spacing, typography bound to Figma Variables  change once, update everywhere.

---

##  MANDATORY: Read figma_docs FIRST

Before writing ANY code, call:
```
figma_docs(section: 'tokens')
```

---

## Capstone Design Token Reference

> **Source of truth:** `src/assets/scss/_colors.scss`
>  **CRITICAL RULE:** The Figma Variable names MUST EXACTLY match the SCSS Variable names (without the `$`). NEVER invent new names like `text-secondary` or `bg-surface`. If it doesn't exist in `_colors.scss`, do not create it in Figma.

### Color Palette (Exact mapping to `_colors.scss`)

| Figma Variable Name | SCSS Variable ($) | Hex Value |
|---------------------|-------------------|-----------|
| `primary` | `$primary` | `#126433` |
| `secondary` | `$secondary` | `#3c4858` |
| `success` | `$success` | `#126433` |
| `error` | `$error` | `#e5322b` |
| `warning` | `$warning` | `#CD9000` |
| `info` | `$info` | `#0074FF` |
| `light` | `$light` | `#f8f9fa` |
| `dark` | `$dark` | `#343a40` |
| `white` | `$white` | `#ffffff` |
| `black` | `$black` | `#000000` |
| `border` | `$border` | `#979B9B` |
| `hover` | `$hover` | `#f0f0f0` |
| `placeholder` | `$placeholder` | `#979B9B` |
| `disable-input` | `$disable-input` | `#F2F2F2` |
| `background-primary` | `$background-primary`| `#EEEEEE` |
| `gray-100` | `$gray-100` | `#f0f3f5` |
| `gray-200` | `$gray-200` | `#e4e7ea` |
| `gray-300` | `$gray-300` | `#c8ced3` |
| `gray-400` | `$gray-400` | `#acb4bc` |
| `gray-500` | `$gray-500` | `#8f9ba6` |
| `gray-600` | `$gray-600` | `#73818f` |
| `gray-700` | `$gray-700` | `#5c6873` |
| `gray-800` | `$gray-800` | `#2f353a` |
| `gray-850` | `$gray-850` | `#26282e` |
| `gray-900` | `$gray-900` | `#23282c` |
| `gray-color` | `$gray-color` | `#999999` |
| `black-color` | `$black-color` | `#3C4858` |
| `Capstone-primary` | `$Capstone-primary` | `#e5322b` |
| `Capstone-secondary` | `$Capstone-secondary` | `#fff00d` |
| `logo-primary` | `$logo-primary` | `#891728` |

---

## Execution Steps

### Step 1: Check connection
```js
// Always check figma_status first
figma_status  must be pluginConnected: true
```

### Step 2: Create Color Variables (Light Only for Free Plan)
```js
await figma.setupDesignTokens({
  collectionName: "HM Colors",
  colors: {
    // Brand & Status
    "primary":   "#126433",
    "secondary": "#3c4858",
    "success":   "#126433",
    "error":     "#e5322b",
    "warning":   "#CD9000",
    "info":      "#0074FF",
    "light":     "#f8f9fa",
    "dark":      "#343a40",
    "white":     "#ffffff",
    "black":     "#000000",
    
    // UI Elements
    "border":             "#979B9B",
    "hover":              "#f0f0f0",
    "placeholder":        "#979B9B",
    "disable-input":      "#F2F2F2",
    "background-primary": "#EEEEEE",
    
    // Grays
    "gray-100": "#f0f3f5",
    "gray-200": "#e4e7ea",
    "gray-300": "#c8ced3",
    "gray-400": "#acb4bc",
    "gray-500": "#8f9ba6",
    "gray-600": "#73818f",
    "gray-700": "#5c6873",
    "gray-800": "#2f353a",
    "gray-850": "#26282e",
    "gray-900": "#23282c",
    "gray-color": "#999999",
    "black-color": "#3C4858",
    
    // Brand Specific
    "Capstone-primary": "#e5322b",
    "Capstone-secondary": "#fff00d",
    "logo-primary": "#891728"
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

-  **Always safe** - `setupDesignTokens` is idempotent (updates existing, creates new)
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
