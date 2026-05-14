# Business Rules - Hard Constraints for Honda HEAD Hoài Minh

>  **WARNING:** These rules are HARD CONSTRAINTS. Code that violates ANY of these rules is considered a **critical bug**. Always validate these before generating business logic.

## Rule Category: Identity & Authentication

| ID | Rule | Consequence if Violated |
|----|------|------------------------|
| AUTH-01 | **NEVER create User/Account tables.** User authentication is handled by an external Identity Server. | Duplicate identity system, security risk |
| AUTH-02 | ERP only stores `UserProfiles` mapped via `ExternalIdentityId` from JWT `sub` claim. | Cannot link actions to users |
| AUTH-03 | All permission checks MUST use `tbl_SYSPermissions`, NEVER hardcode role names. | Breaks when roles change |

## Rule Category: Sales

| ID | Rule | Consequence if Violated |
|----|------|------------------------|
| SAL-01 | **A Sales Order can be created with ONLY a customer name.** Phone/address NOT required at creation time. | UX failure - customers feel pressured |
| SAL-02 | **Receipt MUST be issued BEFORE Invoice** for Cash/Transfer payments. Invoice cannot exist without a completed receipt. | Accounting violation |
| SAL-03 | **Installment payments: Invoice is issued IMMEDIATELY** (HEAD receives full amount from bank). No receipt needed from customer. | Delayed revenue recording |
| SAL-04 | **Deposit creates a partial Receipt.** Full Invoice only after total payment equals order amount. | Premature invoice generation |
| SAL-05 | **Only `Approved` promotions within valid date range** can be applied to orders. `Draft` promotions are INVISIBLE to Sales Staff. | Unauthorized discounts |
| SAL-06 | **Special discount vouchers require multi-level approval:** Sale -> CHT -> TPKD -> G. Skipping levels is NOT allowed. | Unauthorized financial commitment |
| SAL-07 | **Customer documentation MUST be completed BEFORE payment collection.** | Legal/compliance failure |
| SAL-08 | **Vehicle must exist in stock (`LSVehicleColorStock.Quantity - Lock > 0`)** before adding to order. | Selling non-existent inventory |

## Rule Category: Service (Maintenance/Repair)

| ID | Rule | Consequence if Violated |
|----|------|------------------------|
| SVC-01 | **If vehicle PlateNo exists in `tbl_CSVehicle`, auto-load its history.** Never ask customer to re-enter known information. | Poor UX, data duplication |
| SVC-02 | **New vehicles (not in system) REQUIRE: FrameSeri, EngineSeri, PlateNo, VehicleColor.** These are mandatory fields. | Cannot track vehicle properly |
| SVC-03 | **Work Order MUST record `CurrentKm` and `FuelAmount`** at reception. | Cannot calculate next maintenance milestone |
| SVC-04 | **Parts used in repair MUST decrement warehouse stock.** Every `tbl_CSWorkOrderPart` with `StatusChecked=true` must have a corresponding stock-out. | Inventory discrepancy |
| SVC-05 | **Periodic maintenance intervals:** 4,000 km OR 6 months (whichever comes first). | Incorrect maintenance reminders |
| SVC-06 | **Only Honda genuine parts maintain warranty validity.** System should flag/warn if non-genuine parts are selected. | Customer warranty voided |

## Rule Category: Warehouse

| ID | Rule | Consequence if Violated |
|----|------|------------------------|
| WH-01 | **Stock quantity can NEVER go negative.** Validate `Quantity - Lock >= requested amount` before any stock-out. | Phantom inventory |
| WH-02 | **Vehicle transfer between HEADs requires:** 1) Source HEAD stock-out, 2) Destination HEAD stock-in. Both records must be created atomically. | Stock vanishes or duplicates |
| WH-03 | **Inventory audit counts MUST be compared against system stock.** Discrepancies must be flagged, not silently adjusted. | Audit trail destroyed |
| WH-04 | **`Lock` field tracks reserved-but-not-delivered vehicles.** Available = `Quantity - Lock`. | Double-selling same vehicle |
| WH-05 | **`ConfirmQuantity` and `ReceivedQuantity` in `WHIODetail`** track ordered vs actually received parts. They may differ and both must be recorded. | Supplier dispute unresolvable |

## Rule Category: Approval Workflows

| ID | Rule | Consequence if Violated |
|----|------|------------------------|
| APR-01 | **Promotion/Policy status lifecycle:** `Draft -> Pending -> Approved/Rejected`. Cannot skip states. | Unauthorized promotions |
| APR-02 | **Only users with Manager role or above** can change status from `Draft` to `Approved`. | Security breach |
| APR-03 | **Rejected promotions MUST include a rejection reason.** | No audit trail |
| APR-04 | **Approved promotions are IMMUTABLE.** To change, create a new version and deprecate the old one. | Retroactive changes affect past orders |

## Rule Category: Multi-HEAD Data Isolation

| ID | Rule | Consequence if Violated |
|----|------|------------------------|
| HEAD-01 | **All queries MUST filter by HEAD** unless user has cross-HEAD permission. A Sale staff at HEAD 1 must NOT see HEAD 2's orders. | Data leak between branches |
| HEAD-02 | **Stock is per-warehouse, warehouse is per-HEAD.** Never aggregate stock across HEADs without explicit cross-HEAD context. | Incorrect stock reporting |
| HEAD-03 | **Employee permissions are per-HEAD.** Same employee may have different roles at different HEADs (via `tbl_SYSStaffInRoles`). | Over-permissioned access |

## Rule Category: Data Integrity

| ID | Rule | Consequence if Violated |
|----|------|------------------------|
| DATA-01 | **`TypeData` field is a discriminator.** Same table may store different entity types. Always include `TypeData` in queries. | Mixed-type results |
| DATA-02 | **Status codes are defined in `tbl_LSStatus`** with `TypeOfStatus` (sequence) and `TypeData` (which module). Always resolve status from this table. | Hardcoded magic numbers |
| DATA-03 | **All monetary values use `float` type** in current schema. Be aware of floating-point precision issues for financial calculations. | Rounding errors in payments |
| DATA-04 | **`tbl_SYSGUID` and `tbl_SYSIncrease`** manage auto-generated IDs and sequences. Use these instead of DB-level identity when business-formatted IDs are needed. | Duplicate ID generation |
