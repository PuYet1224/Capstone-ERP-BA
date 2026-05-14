# Roles & Permissions - Honda HEAD Hoài Minh

## Organization Hierarchy

```
Director (G)
-- Sales Director (TPKD)
-- Store Manager HEAD 1 (CHT)
|   -- Sales Staff (NV Sale)
|   -- Cashier / Accountant (Thu ngân / Kế toán)
|   -- Reception Staff (NV Tiếp nhận)
|   -- Technician (KTV)
|   -- Parts Warehouse Manager (QL Kho PT)
|   -- Vehicle Warehouse Manager (QL Kho XM)
|   -- Customer Care Staff (NV CSKH)
|   -- Marketing Staff (NV Marketing)
-- Store Manager HEAD 2 (CHT)
|   -- ... (same structure)
-- ... (up to 10+ HEADs)
```

## HEAD (Branch) Registry

| Code | HeadID | Short Name | Full Name |
|------|--------|------------|-----------|
| 1 | LH | Hoài Minh 1 | Chi nhánh Long Hoa |
| 2 | VX | Hoài Minh 2 | Chi nhánh Vòng Xoay |
| 3 | TP | Hoài Minh 3 | Chi nhánh Thành Phố |
| 4 | CT | Hoài Minh 4 | Chi nhánh Châu Thành |
| 5 | TB | Hoài Minh 5 | Chi nhánh Trảng Bàng |
| 6 | BX | Hoài Minh 6 | Chi nhánh Bến Xe |
| 7 | PQ | Hoài Minh 7 | Chi nhánh Phước Đông |
| 8 | C5 | Hoài Minh 8 | Chi nhánh Cửa 5 |
| 9 | BN | Hoài Minh 9 | Chi nhánh Bàu Năng |
| 22 | AH | Hoài Minh 10 | Chi nhánh Ao Hồ |

> **Note:** `tbl_LSHead.ReportToHead` links to a parent HEAD when a Store Manager oversees multiple branches.

## System Roles (`tbl_SYSRoles`)

| Code | RoleName | Functional Description |
|------|----------|------------------------|
| 1 | Kế toán kho | Warehouse accountant - ledger & stock reconciliation |
| 2 | Trưởng phụ tùng | Parts department lead - manages all parts within HEAD |
| 3 | Nhân viên phụ tùng | Parts staff - handles stock in/out operations |
| 4 | Nhân viên CSKH | Customer care - SMS/Zalo reminders |
| 1006 | Admin | System administrator |

## Permission Matrix By Module

### Sales Module

| Action | G | TPKD | CHT | NV Sale | Cashier |
|--------|:---:|:----:|:---:|:-------:|:-------:|
| Create sales order |  |  |  | x |  |
| Select vehicle for customer |  |  |  | x |  |
| Request discount policy |  |  |  | x (propose) |  |
| Create discount policy voucher |  |  | x (creates) |  |  |
| Final approval on policy | x |  |  |  |  |
| Collect payment |  |  |  | x (if granted) | x |
| Issue receipt |  |  |  |  | x |
| Issue invoice |  |  |  |  | x |

### Service Module (CS)

| Action | G | CHT | KTV | Reception | CSKH |
|--------|:---:|:---:|:---:|:---------:|:----:|
| Create work order |  |  |  | x |  |
| Select parts/services |  |  | x |  |  |
| Perform repair |  |  | x |  |  |
| Complete work order |  |  | x |  |  |
| Send SMS reminders |  |  |  |  | x |

### Warehouse Module

| Action | G | CHT | Parts WH Mgr | Vehicle WH Mgr | WH Accountant |
|--------|:---:|:---:|:----------:|:--------------:|:-------------:|
| Stock in |  |  | x | x |  |
| Stock out |  |  | x | x |  |
| Inter-HEAD transfer |  | x |  |  |  |
| Inventory audit |  |  | x | x |  |
| Stock reconciliation |  |  |  |  | x |

## Permission Mechanism In Database

```
tbl_SYSRoles            Define roles
tbl_SYSStaffInRoles     Assign staff to roles (per HEAD)
tbl_SYSPermissions      Action-level access (per HEAD + Role)
tbl_SYSDataPermissions  Data-level access (per HEAD + Role)
tbl_SYSFunction         Menu functions
tbl_SYSAction           Actions within functions
```

> **Critical Rule:** A staff member can belong to multiple HEADs with different roles. `tbl_SYSStaffInRoles.Head` determines the staff's role at a specific HEAD. Example: An employee could be Sales at HEAD 1 but Cashier at HEAD 2 - this is valid.

## Special: Flexible Roles

In practice at Hoài Minh, role boundaries are NOT rigid:
- **Sales Staff may collect payment** if granted permission  Reduces handoff steps
- **KTV may create work orders** when not busy  Reduces wait time
- **CHT can do everything** within their managed HEAD scope

 **When coding:** Always check permissions via `tbl_SYSPermissions`. NEVER hardcode role names.
