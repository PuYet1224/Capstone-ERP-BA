# Entity Snapshot: tbl_HREmployee

> Source: src/Domain/Entities/tbl_HREmployee.cs (read 2026-05-13)
> Table: tbl_HREmployee
> FK Navigation: tbl_HRPersonalProfile (ProfileID)

## Columns

| Column | C# Type | Nullable | Notes |
|--------|---------|----------|-------|
| Code | int | NO | PK (int not long) |
| Head | long | NO | Tenant filter |
| ProfileID | int? | YES | FK -> tbl_HRPersonalProfile |
| StaffID | string | NO | Staff string ID |
| JoinDate | DateTime? | YES | |
| CurrentPosition | int? | YES | |
| Department | int? | YES | |
| Location | int? | YES | |
| ProbationFrom | DateTime? | YES | |
| ProbationTo | DateTime? | YES | |
| MemberCardID | int? | YES | |
| SecurityID | string | NO | |
| Email | string | NO | |
| LeaveDate | DateTime? | YES | |
| ConfigEx | string | NO | |
| StatusID | int? | YES | |
| ReportTo | int? | YES | |
| IndirectReportTo | int? | YES | |
| TypeData | int | NO | |
| CreateBy | string | NO | |
| CreateTime | DateTime? | YES | |
| LastModifiedBy | string | NO | |
| LastModifiedTime | DateTime? | YES | |

## Navigation Properties (exclude from projection)

| Property | Type | FK Column |
|----------|------|-----------|
| tbl_HRPersonalProfile | tbl_HRPersonalProfile? | ProfileID |

## CRITICAL NOTES

- PK `Code` is `int` NOT `long` (different from other tables)
- `Head` IS present -- filter: `.Where(x => x.Head == currentUser.CompanyId)`
- No FullName column -- name data is in tbl_HRPersonalProfile via ProfileID
- When displaying staff name: JOIN to tbl_HRPersonalProfile to get name fields

## Common Errors

| Wrong | Correct |
|-------|---------|
| `Code: long` | `Code: int` |
| `FullName` on tbl_HREmployee | Name is in tbl_HRPersonalProfile |
| `Name` | `StaffID` (only string identifier on this table) |
