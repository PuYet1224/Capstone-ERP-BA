---
name: debug
description: >-
  Systematic debugging workflow for Hoai Minh ERP. Use when tests fail, builds break,
  runtime behavior is unexpected, or a bug report arrives. Guides the agent through
  Stop -> Reproduce -> Localize -> Fix Root Cause -> Guard -> Verify.
  Do NOT use for feature implementation (use ba-analyst + implement workflows instead).
---

# Debug Skill — Systematic Bug Fix v1.0

> **Purpose:** Find and fix root causes systematically. No guessing.
> **Quality bar:** Bug is fixed, root cause is understood, and recurrence is prevented.
> **Trigger:** User reports a bug, build fails, or runtime error occurs.

---

## 1. The Stop-the-Line Rule

When anything unexpected happens:

```
1. STOP — Do NOT continue adding features or making other changes
2. PRESERVE — Save error output, logs, screenshots, repro steps
3. DIAGNOSE — Follow the triage checklist below
4. FIX — Address the root cause, not the symptom
5. GUARD — Add validation or fix pattern to prevent recurrence
6. RESUME — Only after verification passes
```

> **Don't push past a failing build to work on the next feature.** Errors compound.

---

## 2. Triage Checklist (Follow in Order)

### STEP 1: Reproduce

Make the failure happen reliably.

```
Can you reproduce the failure?
├── YES → Proceed to Step 2
└── NO
    ├── Gather more context (logs, environment, user steps)
    ├── Try reproducing in a clean environment
    └── If truly non-reproducible → document conditions and monitor
```

**For Angular (FE):**
```powershell
ng serve                    # Does the error appear?
ng build --configuration production   # Does it compile?
```

**For .NET (BE):**
```powershell
dotnet build                # Does it compile?
dotnet run                  # Does the API respond correctly?
```

### STEP 2: Localize

Narrow down WHERE the failure happens:

```
Which layer is failing?
├── FE Angular
│   ├── Template error     → Check console, component HTML
│   ├── TypeScript error   → Check .ts file at line cited
│   ├── Service/API call   → Check Network tab, service method
│   ├── Kendo UI component → Check binding, data format
│   └── Routing            → Check module imports, lazy loading
├── BE .NET
│   ├── Compile error      → Check .cs file at line cited
│   ├── Runtime exception  → Check handler logic, null checks
│   ├── SQL/EF Core        → Check query, joins, schema mismatch
│   ├── API not found      → Check tbl_SYSFunction registration (Product=3 for mobile)
│   └── Auth/Permission    → Check tbl_SYSPermissions, JWT token
├── API Contract
│   ├── FE sends wrong DTO → Compare FE DTO vs BE Request record
│   ├── BE returns wrong shape → Check Response record vs FE interface
│   └── Status code mismatch → Check ApiResponse wrapper
└── Environment
    ├── CORS               → Check server CORS config
    ├── IIS App Pool        → Restart if DLL locked
    └── Database            → Check connection string, schema
```

### STEP 3: Reduce

Create the minimal failing case:

- Remove unrelated code until only the bug remains
- Simplify input to the smallest example that triggers failure
- Isolate: is it THIS component or a shared service?

### STEP 4: Fix Root Cause (NOT Symptom)

```
Symptom fix (BAD):
  → Add `|| ''` to suppress undefined error
  → Add `try/catch` that swallows the error
  → Comment out the failing line

Root cause fix (GOOD):
  → Data is null because API returns empty when HEAD filter missing
  → Fix: add HEAD filter to the query (BR-HEAD-01)
```

**Ask "Why?" until you reach the actual cause:**
```
Why does the list show 0 items?
→ Because the API returns empty array
Why does the API return empty?
→ Because the query has no results
Why no results?
→ Because HeadCode filter doesn't match
Why doesn't it match?
→ Because ICurrentUserService returns null HeadCode
→ ROOT CAUSE: User session doesn't have HeadCode assigned
```

### STEP 5: Guard Against Recurrence

After fixing, add protection:

**FE Angular:**
- Add null check / safe navigation (`?.`) where data could be undefined
- Add error state UI (not just blank screen)
- Verify `ng build` passes

**BE .NET:**
- Add validation in handler (return BadRequest with clear message)
- Add null check before accessing entity properties
- Verify `dotnet build` passes

### STEP 6: Verify End-to-End

```powershell
# FE: Must pass
ng build --configuration production

# BE: Must pass
dotnet build

# Manual: Test the exact scenario that was broken
# Confirm the fix works AND nothing else broke
```

---

## 3. Common HM ERP Bug Patterns

| Bug Pattern | Likely Root Cause | Fix Location |
|-------------|-------------------|--------------|
| API returns 404 | `tbl_SYSFunction` missing or `Product != 3` (mobile) | Database registration |
| List shows 0 items | Missing HEAD filter or wrong DLL namespace | BE Handler query |
| Form fields not saving | DTO field name mismatch (FE vs BE) | Check DTO/interface |
| Kendo Grid empty | `res.ObjectReturn.Data` path wrong | FE service response mapping |
| Status button not showing | Wrong enum value or status guard logic | FE component / BE StatusConstants |
| Permission denied | `tbl_SYSPermissions` missing for StaffID | Database registration |
| Page loads blank | Angular module not imported or route not registered | FE module/routing |
| Build fails after merge | Conflicting imports or duplicate declarations | FE module imports |

---

## 4. Anti-Rationalization Table

| AI Excuse | Reality |
|-----------|---------|
| "I know what the bug is, I'll just fix it" | Reproduce first. You're right 70% of the time. The other 30% costs hours. |
| "It's probably a typo" | Check systematically. "Probably" is not a diagnosis. |
| "Let me rewrite the whole component" | Fix the bug. Don't refactor during debugging. One change at a time. |
| "The error message is misleading" | Read it carefully. Error messages are usually accurate. |
| "It works in my build" | Check the EXACT scenario the user reported. Same data, same status, same role. |
| "I'll add a try/catch" | That hides the bug, doesn't fix it. Find the root cause. |

---

## 5. Red Flags

- ❌ Guessing at fixes without reproducing the bug
- ❌ Fixing symptoms instead of root causes (adding `|| ''` everywhere)
- ❌ Making multiple unrelated changes while debugging
- ❌ "It works now" without understanding what changed
- ❌ Swallowing errors with empty try/catch blocks
- ❌ Refactoring code during a debug session

---

## 6. Verification Checklist

After fixing a bug, confirm ALL of these:

- [ ] Root cause is identified and explained to user
- [ ] Fix addresses the root cause, not just symptoms
- [ ] `ng build` (FE) or `dotnet build` (BE) passes
- [ ] The original bug scenario is verified working
- [ ] No other functionality is broken by the fix
