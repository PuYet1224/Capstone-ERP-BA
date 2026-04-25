---
trigger: always_on
---

# BA Workspace -- Capstone ERP Business Analysis

> Rules for all agents working on the BA workspace.
> **Purpose:** Read requirements, analyze business logic, produce BE + FE implementation guides.
> **Scope:** This workspace does NOT write source code, modify databases, or deploy.

---

## P0 -- DATA SOURCE TRANSPARENCY (NEVER VIOLATE)

> **Why this rule exists:** AI previously read local PNG files but presented findings as if reading from live Figma. This is misleading and strictly prohibited.
> This rule is **higher priority than all other instructions.**

### Before EVERY design/data analysis, MUST declare the data source:

| Reading from | Must state |
|---|---|
| `figma_read` Figma Desktop live | "Reading from **Figma Desktop (live)**" |
| `{PROJECT_PIPELINE}\designs\{feature}\*.png` | "Reading from **pipeline design images**" |
| `{PIPELINE_ROOT}\designs\*.png` | "Reading from **pipeline images**" |
| Current code files | "Reading from **current code**" |
| Requirements / documents | "Reading from **requirements input** at `{PIPELINE_ROOT}\requirements\`" |

### ABSOLUTELY FORBIDDEN:

- `figma_read` fails -> silently reading local files without informing the user
- Analyzing archive images but saying "per Figma" or "from Figma"
- Skipping the source declaration step before analysis
- Returning analysis results without stating where data came from

### When figma_read fails -- required procedure:

```
1. State clearly: "figma_read failed - Figma Desktop not connected."
2. Ask user: "Use images from {PROJECT_PIPELINE}\designs\ as fallback?"
3. ONLY use local images AFTER user confirms.
4. Always label: "[Analysis from pipeline design images - not live Figma]"
```

---

## P1 -- ENGLISH-ONLY + ASCII-ONLY POLICY (MANDATORY)

> **Every agent working on this workspace MUST write all `.agent/` files in English.**

| Applies To | Rule |
|------------|------|
| **Skills** (`.agent/skills/**/*.md`) | Write and edit in English only |
| **Workflows** (`.agent/workflows/*.md`) | Write and edit in English only |
| **GEMINI.md** | Write and edit in English only |
| **AI responses** | English preferred; Vietnamese allowed ONLY when user writes in Vietnamese |

**When creating or editing any `.agent/` file:**
- NEVER write instructions, comments, section headers, or labels in Vietnamese
- NEVER mix Vietnamese and English in the same skill/workflow file
- If a file has existing Vietnamese content -> translate it to English during that edit session
- Vietnamese is acceptable ONLY as sample data (e.g. field labels, customer names)

### ASCII-ONLY ENFORCEMENT (NO EXCEPTIONS)

> ALL `.agent/` files MUST contain only ASCII characters (0x20-0x7E + newlines).

**FORBIDDEN characters in .agent/ files:**
- Unicode arrows: use `->` instead
- Em/en dashes: use `--` instead
- Smart quotes: use `'` and `"` instead
- Emoji: use `[!]` `[OK]` `[NO]` text labels instead
- Box-drawing chars: use `+--` `|--` `|` instead
- Section sign, multiplication sign, ellipsis: use `S` `x` `...` instead

**Why:** Non-ASCII characters render as mojibake on different systems, editors, and servers.

### Self-Check (MANDATORY before every file save):

```
Before saving any `.agent/` file, verify:
1. Zero non-ASCII characters (no Unicode arrows, smart quotes, emoji)
2. No Vietnamese text outside of backtick-quoted sample data
3. All section headers and labels are in English
```

---

## P2 -- WORKSPACE CONFIGURATION

### WORKSPACE_MAP -- Change here when deploying to new machine

```
PIPELINE_ROOT:      C:\ai.pipeline
PROJECT_PIPELINE:   {PIPELINE_ROOT}\Capstone-ERP-Project
```

> Deploy to new machine? Update PIPELINE_ROOT above.
> New project? Create a new folder under PIPELINE_ROOT and update PROJECT_PIPELINE.

### External Paths (SECURITY BOUNDARY)

```
READ ONLY:
  Requirements Input:  {PROJECT_PIPELINE}\requirements\     (REQ_*.md from user/PM)

WRITE ONLY:
  Guides Output:       {PROJECT_PIPELINE}\guides\            (BE_*.md + FE_*.md for dev teams)

FORBIDDEN:
   Any source code repository
   Any path not listed above (except your own workspace)
```

### Internal Paths (your own workspace)

```
Project Knowledge:  .agent\projects\capstone\domain\      (business flows, schema, rules)
Project Standards:  .agent\projects\capstone\standards\    (BE + FE coding standards)
Project Memory:     .agent\projects\capstone\memory\       (feature analysis history)
```

---

## P2 -- SKILLS AND WORKFLOWS

### Skills

- `capstone-domain` - domain knowledge (glossary, flows, schema, rules, architecture)
- `ba-pipeline` - core workflow for analyzing requirements and creating guides
- `clean-requirement` - transform messy meeting notes into structured SRS (7 pillars)
- `memorize` - distill SRS + code + guides into permanent memory file
- `clean-pipeline` - remove completed feature artifacts from pipeline folder
- `figma-reader` - read live Figma design via MCP bridge (BODY content only)

### Workflows

- `/ba-analyst` - trigger analysis pipeline: auto-scan requirements -> analyze -> create guides
- `/clean-requirement` - transform raw notes into SRS -> save to shared folder
- `/memorize` - distill feature knowledge before cleanup
- `/clean-pipeline` - remove completed artifacts from pipeline
- `/figma-variables` - sync design tokens to Figma

---

## P3 -- TOOL RELIABILITY RULES (CRITICAL)

1. **`view_file` first** -- If you know the file path, use `view_file`. Do NOT grep for it.
2. **NEVER `grep_search` on root folders or `node_modules`** -- `grep_search` WILL HANG and cause context freeze. Use PowerShell `Select-String` instead.
3. **Tool timeout = abort** -- If a tool call times out, do NOT retry. Use alternative approach.

---

## P4 -- LANGUAGE AND QUALITY

### Response Language

- Respond in Vietnamese (match user's language)
- Technical terms in English
- Guide content in English (for developer consumption)

### Guide Quality Standard

Your guides must be **complete enough that BE/FE developers can implement without asking questions**. Minimum 100 lines per guide. Think like a Tech Lead writing a detailed specification.

### Error Handling

| Situation | Required Action |
|---|---|
| SRS file not found | State: "No SRS found at {path}. Run /clean-requirement first." |
| Multiple SRS files, no argument given | List all files, ask user which to process. NEVER auto-select. |
| Figma MCP not connected | Follow P0 Figma fallback procedure above. |
| SRS contradicts domain knowledge | SRS wins (newer, more specific). Note the override in memory file. |
| SRS contradicts itself | Ask user for clarification. Do NOT guess. |
| Guide output path not writable | State error clearly. Do NOT write to alternative paths. |
