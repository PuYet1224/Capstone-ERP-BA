# Context Memory: Receipt
> Analyzed: 2026-04-10 | Requirement: REQ_001
> Module: SAL

## 1. Business Context Summary
Receipts (Phiu Thu) securely record incoming currency to resolve a linked Sales Order's remaining debt. It strictly safeguards cash validation workflows, verifying signatures and enforcing valid bounds before locking in financial milestones to the general Sales and Invoicing modules.

## 2. Key Decisions & Rationale
- **Enforced Single Status System**: Hard requirement to use integers `1`, `2`, `3` tracking against TypeOfStatus `126`, `127`, `128` uniformly mapped across the architecture logic instead of database primary keys.
- **Debt Validation Constraint**: Business logic (BR-02/BR-05) imposes that an isolated partial collection cannot overrun the overarching remaining debt `Total Amount - AmountPaid`.
- **Installment Refusal**: Isolated exception (BR-03) that pure installment operations do not generate receipts, effectively sidestepping out-of-band payment logic.
- **Eventual Consistency & Concurrency**: The step from `New -> Completed` mutates the parent `AmountPaid`. This transaction must be atomic via ExecutionStrategy to avoid race condition state desync.

## 3. State Machine
| # | From | To | Action | Condition |
|---|------|-----|--------|----------|
| T1 | - | New (1) | Save receipt | BR-01~BR-05 pass |
| T2 | New (1) | Completed (2) | Confirm payment | Must have customer signature (BR-12) |
| T3 | New (1) | Cancelled (3) | Cancel | Must enter cancel reason (BR-10) |
*Invalid transitions*: Completed -> any, Cancelled -> any. (BR-13, BR-14)

## 4. Database Tables & Relationships
- **Primary**: `tbl_SALOrderReceipt` - the primary target schema recording collection metadata and status.
- **Related**: `tbl_SALOrderMaster` - yields the limits constraining receipt sums through `TotalAmount` and `AmountPaid` columns.

## 5. Business Rules Applied
- **BR-01**: Link invariant. Exists solely attached to `tbl_SALOrderMaster`.
- **BR-02 & BR-05**: Cannot collect outside the bounds of defined `RemainingDebt`.
- **BR-03**: Payment type logic branch bypasses Receipts for pure Installments.
- **BR-10**: System refuses to alter state to Cancelled without audited `CancelReason` parameter payload mapping to `Description`.
- **BR-12**: System refuses to alter state to Completed without valid payload `Signature`.
- **BR-13/BR-14**: Mutator lockdown when Status exists in 2 or 3.

## 6. Cross-Module Dependencies
- The `Sales` module triggers dependency by reading `AmountPaid`.
- The `Invoice` module triggers dependency by ensuring `Completed` receipts exist to authorize Invoice generation.

## 7. Edge Cases & Gotchas
- Must track race condition where multiple receipts submitted exceeding total debt simultaneously (requires EF Core RowVersioning or db execution strategy during state completion).
- The payment type introduces `PaymentMethod = 4` (Cash + Transfer). Constants must reflect `1`, `2`, and `4` explicitly.

## 8. User Flow Summary
1. (Cashier) Retrieve Order Data limits -> Validate constraints -> Submit base manual Cash amounts -> Saves New (1).
2. (Cashier) Receive Customer Signature -> Submit status update -> Validates signature -> Updates `tbl_SALOrderMaster` atomically -> Locks state to Completed (2).
3. (Chief Accountant) Initiate Cancel workflow -> Submits reason block -> Updates `tbl_SALOrderReceipt` -> Locks state to Cancelled (3).

## 9. Interface Contracts
- **ReceiptStatus**: 1=New, 2=Completed, 3=Cancelled
- **PaymentMethods**: 1=Cash, 2=Transfer, 4=Cash+Transfer

## 10. Revision History
- 2026-04-10: Pipeline Auto-Analysis processing REQ_001_Receipt.md against Hoai Minh Database rules. Overwrote isolated legacy tracking memory file with updated deep-analysis schema mappings.
