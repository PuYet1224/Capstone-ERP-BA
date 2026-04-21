---
description: Create or audit agent skills following the open standard (agentskills.io). Enforces English-only, YAML frontmatter, progressive disclosure, <500 lines. Usage /create-skill [skill-name] or /create-skill --audit
---

# /create-skill -- Skill Factory & Auditor

> **Purpose:** Create new skills or audit existing ones against the open standard.
> **Standard:** agentskills.io + Gemini CLI conventions
> **Language Rule:** ALL skills/workflows/standards MUST be in English. Vietnamese is ONLY for human-facing output (reports, encyclopedia).

---

## Sub-commands

```
/create-skill [skill-name]       -- Create a new skill interactively
/create-skill --audit            -- Audit ALL skills in current workspace
/create-skill --audit [name]     -- Audit a specific skill
/create-skill --fix [name]       -- Audit + auto-fix a specific skill
```

---

## PART A: Create New Skill

### Step 1: Gather Requirements

Ask user for:

| Field | Required | Rule |
|-------|----------|------|
| `name` | YES | Lowercase + hyphens only, max 64 chars, e.g. `api-patterns` |
| `purpose` | YES | What does this skill do? When should AI trigger it? |
| `target workspace(s)` | YES | BA / BE / FE Web / FE Mobile / All |
| `negative triggers` | YES | When should AI NOT use this skill? |
| `references needed?` | NO | Does the skill need a `references/` folder for large docs? |

### Step 2: Validate Name

```
 VALID:   api-patterns, clean-code, be-pipeline, mobile-design
 INVALID: ApiPatterns (no uppercase)
 INVALID: clean pipeline (no spaces)
 INVALID: -my-skill- (no leading/trailprintg hyphens)
 INVALID: my_skill (no underscores -- use hyphens)
```

Name MUST match the parent directory name exactly.

### Step 3: Generate SKILL.md

Follow this template EXACTLY:

```markdown
---
name: {skill-name}
description: {1-2 sentences: what it does + when to trigger. Max 1024 chars. Include negative triggers.}
---

# {Skill Title}

> **Role:** {What role does this skill give the AI?}
> **Trigger:** {When should this skill activate?}
> **Do NOT use when:** {Negative triggers -- when to skip this skill}

---

## 1. Prerequisites

{What must be loaded/read before this skill runs?}

---

## 2. Core Rules

{Numbered list of rules the AI must follow}

---

## 3. Step-by-Step Procedure

{Numbered imperative steps -- clear, unambiguous, not vague pronouns}

---

## 4. Output Format

{Expected output structure -- use code blocks for templates}

---

## 5. Constraints & Guardrails

{What the AI must NOT do -- negative constraints are critical for LLMs}

---

## 6. References

{If content exceeds 500 lines, use progressive disclosure:}
> For detailed API specs, read `references/api-spec.md`
> For schema details, read `references/schema.md`
```

### Step 4: Quality Checklist (MANDATORY before saving)

| # | Check | Rule |
|---|-------|------|
| 1 | Language |  English ONLY -- zero Vietnamese text |
| 2 | YAML frontmatter | `name` + `description` present and valid |
| 3 | Name match | `name` field = parent directory name |
| 4 | Description quality | Actionable: describes WHEN to trigger + WHEN NOT to trigger |
| 5 | Line count | < 500 lines (offload to `references/` if larger) |
| 6 | Imperative style | Steps use imperative verbs: "Read", "Check", "Create" |
| 7 | No vague pronouns | No "it", "this", "that" without explicit noun |
| 8 | Code blocks labeled | All fenced code blocks have language tag (```csharp, ```typescript) |
| 9 | Constraints section | Explicit "DO NOT" rules present |
| 10 | No hardcoded paths | Use relative paths or clearly marked absolute paths |

### Step 5: Save and Report

```
 Skill Created:
    Path: .agent/skills/{skill-name}/SKILL.md
    Lines: {N} (limit: 500)
    Language: English 
    Checklist: {passed}/{total}
    Target: {workspace(s)}

   Copy to other workspaces? (y/n)
```

If user says yes -> copy to specified workspace `.agent/skills/` folders.

---

## PART B: Audit Existing Skills

### `/create-skill --audit`

Scan ALL `*.md` files in `.agent/skills/` and `.agent/workflows/`:

#### Check 1: YAML Frontmatter
```
PASS: Has --- delimited YAML with 'name' and 'description'
FAIL: Missing frontmatter, missing 'name', or missing 'description'
```

#### Check 2: Language (CRITICAL)
```
Scan for Vietnamese characters: [?at?]
PASS: Zero matches (English only)
FAIL: Vietnamese text found -- list lines with Vietnamese
EXCEPTION: Vietnamese business terms inside backticks are OK (e.g., `"Receipt"`)
```

#### Check 3: Name Consistency
```
PASS: YAML 'name' field matches parent directory name
FAIL: Mismatch between directory name and YAML name
```

#### Check 4: Line Count
```
PASS: < 500 lines
WARN: 500-800 lines (consider refactoring)
FAIL: > 800 lines (MUST split into references/)
```

#### Check 5: Description Quality
```
PASS: Description contains trigger words (when/use/activate) AND negative triggers (not/never/skip)
WARN: Missing negative triggers
FAIL: Description is too vague or too short (< 20 chars)
```

#### Check 6: Encoding
```
PASS: UTF-8 without BOM artifacts (no --, ?, etc.)
FAIL: Garbled characters detected -- re-save as UTF-8
```

#### Check 7: Deprecated Content
```
FAIL: References to legacy architectures (e.g., Capstone, monolithic MVC).
FAIL: References to removed/moved paths
```

### Audit Output Template

```
 Skill Audit Report -- {Workspace Name}
   Date: {YYYY-MM-DD}
   Total skills: {N} | Total workflows: {N}

 FAIL ({N}):
   | # | File | Issue | Rule |
   |---|------|-------|------|
   | 1 | skills/xyz/SKILL.md | Vietnamese text on lines 12,15,23 | Language |
   | 2 | workflows/abc.md | Missing YAML frontmatter | Frontmatter |

 WARN ({N}):
   | # | File | Issue | Rule |
   |---|------|-------|------|

 PASS ({N}):
   | File | Lines | Description Quality |
   |------|-------|---------------------|

Score: {passed}/{total} ({%})
```

---

## PART C: Auto-Fix (`--fix`)

When `--fix` is specified, automatically:

1. Replace Vietnamese instruction text with English equivalent
2. Add missing YAML frontmatter
3. Fix encoding (re-save as UTF-8 not BOM)
4. Trim to < 500 lines (move excess to `references/`)
5. After fix -> re-run audit to verify

>  Auto-fix NEVER changes business logic or domain terms.
>  Auto-fix ALWAYS shows diff before saving -- user must confirm.

---

## Rules for ALL Skills/Workflows

### Language Rules (NON-NEGOTIABLE)

```
ENGLISH ONLY in:
   SKILL.md files
   workflow.md files
   standards/*.md files
   GEMINI.md
   domain/*.md (instruction frame)
   memory/*.md

VIETNAMESE ALLOWED in:
   Human-facing reports/artifacts (review_*.md)
   Encyclopedia/manual documents
   Vietnamese business terms inside backticks: `"Receipt"` (Receipt)
   Status labels that exist in DB as Vietnamese: `"New"`, `"Completed"`
```

### Structural Rules

```
skill-name/               lowercase + hyphens, matches YAML 'name'
|--- SKILL.md              REQUIRED: YAML frontmatter + instructions
|--- references/           OPTIONAL: large docs, schemas, specs
|--- scripts/              OPTIONAL: executable helpers
`--- assets/               OPTIONAL: templates, images
```

### Content Rules

```
1. YAML frontmatter is MANDATORY (name + description)
2. Description must state WHEN to trigger AND when NOT to trigger
3. Use imperative verbs in steps: "Read", "Check", "Create"
4. No vague pronouns -- always use explicit nouns
5. All code blocks must have language labels
6. Max 500 lines -- use references/ for overflow
7. Include "Constraints" or "DO NOT" section
8. No hardcoded absolute paths without clear marking
```
