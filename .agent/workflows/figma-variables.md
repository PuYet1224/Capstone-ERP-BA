---
trigger: /figma-variables
description: Create or update Capstone ERP design system variables in Figma. Establishes HM Colors, HM Spacing, HM Typography collections. Usage /figma-variables or /figma-variables --reset
skills:
  - figma-variables
---

# /figma-variables [options]

> Creates all Capstone design tokens as Figma Variables - safe to re-run anytime (idempotent).

## Usage

```
/figma-variables               Create/update all HM variable collections
/figma-variables --colors      Colors only (HM Colors collection)
/figma-variables --spacing     Spacing + radius only (HM Spacing collection)
/figma-variables --typography  Font sizes + family only (HM Typography collection)
/figma-variables --status      List existing HM variables (read-only, no changes)
```

## Steps

1. Read skill: `.agent/skills/figma-variables/SKILL.md`
2. Call `figma_status`  must be `pluginConnected: true`
   - If NOT connected  stop and ask user to open Figma Desktop + plugin
3. Call `figma_docs(section: 'tokens')`  load variable API
4. Based on option (or no option = all):
   - Run **Step 2** from SKILL.md  HM Colors collection
   - Run **Step 3** from SKILL.md  HM Spacing collection
   - Run **Step 4** from SKILL.md  HM Typography collection
5. Report results

## Final Output

```
 HM Design System Variables created:
    HM Colors:     {N} variables (primary, error, gray-600, ...)
    HM Spacing:    {N} variables (spacing/xs  3xl, radius/xs  full)
    HM Typography: {N} variables (font/size-xs  2xl, font/family-primary)

Total: {N} variables in Figma
Note: Figma Free = 1 mode per collection (Light only)
      Figma Pro  = run again  supports Light + Dark modes automatically
```

## Safety

-  **Idempotent** - re-running updates existing variables, never duplicates
-  **Non-destructive** - does NOT delete any existing collections or frames
-  **Figma Free limitation** - only 1 mode per collection (no Light/Dark in same collection)
