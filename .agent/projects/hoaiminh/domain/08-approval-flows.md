# Approval Flows - Multi-Level Approval at Honda HEAD Hoài Minh

## Overview

Several business operations at Hoài Minh require multi-level approval before execution. This document defines each approval flow, the actors involved, and the status transitions.

## Flow 1: Sales Policy / Special Discount Approval

**Trigger:** Customer requests a discount not covered by active promotions (e.g., "Display bike has scratches, give me VND 2M off")

```mermaid
stateDiagram-v2
    [*] --> Draft: Sale requests discount
    Draft --> PendingCHT: Sales Staff submits to Store Manager
    PendingCHT --> PendingTPKD: CHT creates policy voucher & forwards
    PendingTPKD --> PendingGD: TPKD reviews & may adjust, forwards to Director
    PendingGD --> Approved: Director approves
    PendingGD --> Rejected: Director rejects with reason
    PendingTPKD --> Rejected: TPKD rejects with reason
    PendingCHT --> Rejected: CHT rejects with reason
    Approved --> Applied: Voucher applied to sales order
    Rejected --> [*]
    Applied --> [*]
```

### Actors & Responsibilities

| Step | Actor | Action | DB Operation |
|------|-------|--------|--------------|
| 1 | Sales Staff | Verbally requests discount from CHT | None (offline) |
| 2 | CHT | Creates `tbl_POLPromotionMaster` with Status=`Draft` | INSERT |
| 3 | CHT | Submits to TPKD | UPDATE Status -> `Pending` |
| 4 | TPKD | Reviews, may adjust amounts | UPDATE fields + forward |
| 5 | Director (G) | Final approval or rejection | UPDATE Status -> `Approved` or `Rejected` |
| 6 | Sales Staff | Applies approved voucher to order | INSERT `tbl_SALOrderDetailPromotion` |

### Status Values (`tbl_LSStatus`, TypeData=1)

| Code | Status | Meaning |
|------|--------|---------|
| 1 | Draft | Draft - Just created |
| 2 | Pending | Submitted for approval |
| 3 | Approved | Approved |
| 4 | Suspended | Suspended/Deactivated |
| 5 | Returned | Returned for revision |
| 20 | Rejected | Rejected |

### Business Rules

- Sales Staff **CANNOT** see `Draft` status policies
- Only `Approved` + within `StartDate`/`EndDate` policies are visible to Sales Staff
- Rejection **MUST** include a reason (stored in Description)
- Approved policies are **IMMUTABLE** - to change, create new version

## Flow 2: Purchase Order Approval (DO - Delivery Order)

**Trigger:** HEAD needs to order vehicles from Honda distributor

```mermaid
stateDiagram-v2
    [*] --> Created: HEAD creates PO request
    Created --> PendingApproval: Submit for approval
    PendingApproval --> Approved: Management approves
    PendingApproval --> Rejected: Management rejects
    Approved --> InTransit: Vehicles dispatched
    InTransit --> Received: Vehicles arrive at HEAD
    Received --> [*]
```

### Status Values (`tbl_LSStatus`, TypeData=4)

| Code | Status | Meaning |
|------|--------|---------|
| 15 | Created | Created |
| 16 | Pending | Pending approval |
| 17 | Waiting Delivery | Waiting for delivery |
| 18 | In Delivery | In delivery |
| 19 | Completed | Completed |

## Flow 3: Warehouse Transfer Approval

**Trigger:** HEAD A requests vehicles from HEAD B

```mermaid
stateDiagram-v2
    [*] --> Requested: HEAD A requests transfer
    Requested --> PendingSourceHEAD: Source HEAD reviews
    PendingSourceHEAD --> Approved: Source CHT approves
    PendingSourceHEAD --> Rejected: Source CHT rejects
    Approved --> InTransit: Vehicle leaving source
    InTransit --> Received: Vehicle arrives at destination
    Received --> [*]
```

## Flow 4: Sales Order Status Flow

**The main order lifecycle:**

```mermaid
stateDiagram-v2
    [*] --> Created: Order created with customer name
    Created --> InProgress: Vehicle selected, add-ons configured
    InProgress --> DocumentReady: Customer info collected
    DocumentReady --> PaymentPending: Awaiting payment
    PaymentPending --> ReceiptIssued: Payment received
    ReceiptIssued --> InvoiceIssued: Invoice generated
    InvoiceIssued --> Delivered: Vehicle delivered to customer
    Delivered --> Completed: All done 
    
    PaymentPending --> Cancelled: Customer cancels
    InProgress --> Cancelled: Customer changes mind
```

### Sales Order Status Values (`tbl_LSStatus`, TypeData=7)

| Code | Status | Meaning |
|------|--------|---------|
| 27 | Created | Order created |
| 28 | Waiting Delivery | Waiting for vehicle delivery |
| 30 | Completed | Completed |
| 31 | Cancelled | Cancelled |

## Flow 5: Work Order (Service) Status Flow

```mermaid
stateDiagram-v2
    [*] --> VehicleReceived: Vehicle enters HEAD
    VehicleReceived --> CustomerReceived: Customer info completed
    CustomerReceived --> WaitingDelivery: In repair
    WaitingDelivery --> Completed: Done, vehicle returned
```

### Work Order Status Values (`tbl_LSStatus`, TypeData=13)

| Code | Status | Meaning |
|------|--------|---------|
| 69 | Vehicle Received | Vehicle received |
| 70 | Customer Received | Customer received |
| 71 | Pending Return | Pending vehicle return |
| 72 | Completed | Completed |

## Flow 6: SMS/Notification Campaign Approval

```mermaid
stateDiagram-v2
    [*] --> Created: Campaign created
    Created --> PendingReview: Submit for review
    PendingReview --> Approved: Approved for sending
    PendingReview --> Rejected: Rejected
    Approved --> Sending: Messages being sent
    Sending --> Completed: All sent
    Sending --> PartialFail: Some failed
```

### SMS Status Values (`tbl_LSStatus`, TypeData=14)

| Code | Status | Meaning |
|------|--------|---------|
| 73 | Created | Created |
| 74 | Pending Review | Submitted for review |
| 75 | Rejected | Rejected |
| 76 | Waiting Send | Waiting to send |
| 77 | Stopped | Stopped |
| 78 | Completed | Completed |

## General Approval Principles

1. **Hierarchy must be respected:** Lower levels cannot bypass higher-level approvals
2. **Every status change must be auditable:** `LastModifiedBy` + `LastModifiedTime` recorded
3. **Rejections require reasons:** Always store rejection rationale
4. **Approved items are immutable:** Create new versions instead of modifying
5. **Status transitions are one-directional:** Cannot go backwards except via explicit "Return" action
