# 11 - Coding Standards (Ban Buoc Doc Truoc Khi Code)

> **CRITICAL:** Moi nhan vien AI (BA/BE/FE) PHAI doc file nay. Vi pham bat ky rule nao = code FAILED.

## 0. API NAMING - CHI 4 PREFIX DUOC PHEP

| Prefix | Y nghia | Vi du |
|:-------|:--------|:------|
| **Get** | Lay data | `GetListSALReceipt`, `GetSALReceipt` |
| **Update** | Tao moi + sua + doi trang thai | `UpdateSALReceipt`, `UpdateSALReceiptStatus` |
| **Delete** | Xoa | `DeleteSALReceipt` |
| **Add** | Them item vao collection | `AddSALSelectedVehicles` |

**CAM TUYET DOI:** ~~Create~~, ~~Cancel~~, ~~Complete~~, ~~Insert~~, ~~Remove~~, ~~Set~~, ~~Patch~~
- Tao moi = `Update` (Code=0 thi insert, Code>0 thi update)
- Huy = `UpdateStatus` (Status = Cancelled)
- Hoan tat = `UpdateStatus` (Status = Completed)

## 1. CAM TUYET DOI HARD-CODE MAGIC NUMBERS

### Sai (BI CAM)
```csharp
// SAI - hard-code status number
if (receipt.Status == 30) // 30 la gi???
receipt.Status = 10;
var allowed = (10, 30) => true; // magic numbers
order.PaymentMethod == 3; // 3 la gi???
```

### Dung (BAT BUOC)
```csharp
// DUNG - dung constants mapped to tbl_LSStatus TypeData=22
public static class ReceiptStatus
{
    public const int New = 1;        // TypeOfStatus=1, Code=126, "Moi"
    public const int Completed = 2;  // TypeOfStatus=2, Code=127, "Hoan tat"
    public const int Cancelled = 3;  // TypeOfStatus=3, Code=128, "Huy giao dich"
}

// DUNG - su dung constant
if (receipt.Status == ReceiptStatus.Completed)
var allowed = (ReceiptStatus.New, ReceiptStatus.Completed) => true;
```

## 2. CAM DUNG `dynamic Payload` CHO HANDLER MOI

### Sai (pattern cu - chi chap nhan cho handler da ton tai)
```csharp
// SAI - khong type-safe, khong validate duoc
public record UpdateSALReceiptCommand(dynamic Payload) : IRequest<ApiResponse<object>>;
long code = (long)request.Payload.Code; // runtime error neu thieu field
```

### Dung (BAT BUOC cho code moi)
```csharp
// DUNG - strongly-typed request
public record UpdateSALReceiptCommand(
    long OrderMasterCode,
    double CollectedAmount,
    int PaymentType,
    string? Note
) : IRequest<ApiResponse<object>>;

// Access truc tiep - compile-time safe
var order = await db.SALOrderMasters
    .FirstOrDefaultAsync(o => o.Code == request.OrderMasterCode, ct);
```

## 3. STATUS DEFINITIONS (From production DB tbl_LSStatus)

> Values from production DB. BA/BE/FE MUST use these exact values. Column `Status` stores `TypeOfStatus`.

### Receipt Status (SALOrderReceipt, TypeData=22)
| TypeOfStatus | Name | Code (PK) | Description |
|:-------------|:-----|:----------|:------------|
| 1 | New (Moi) | 126 | Receipt created, not yet confirmed |
| 2 | Completed (Hoan tat) | 127 | Payment collected and confirmed |
| 3 | Cancelled (Huy giao dich) | 128 | Receipt cancelled |

### Invoice Status (SALOrderInvoice, TypeData=23)
| TypeOfStatus | Name | Code (PK) | Description |
|:-------------|:-----|:----------|:------------|
| 1 | New (Moi) | 129 | Invoice created |
| 2 | Completed (Hoan tat) | 130 | Invoice issued |
| 3 | Cancelled (Huy giao dich) | 131 | Invoice cancelled |

### Sales Order Status (SALOrderMaster, TypeData=18)
| TypeOfStatus | Name | Code (PK) | Description |
|:-------------|:-----|:----------|:------------|
| 1 | Created (Tao moi) | 92 | Order just created |
| 2 | Returned (Tra ve) | 93 | Order returned for revision |
| 3 | Pending (Cho xu ly) | 94 | Waiting for processing |
| 4 | Processing (Dang xu ly) | 95 | Active order in progress |
| 5 | Completed (Hoan tat) | 96 | Order fulfilled |
| 6 | Cancelled (Huy giao dich) | 133 | Order cancelled |

### Payment Method (SALOrderMaster.PaymentMethod)
| Value | Name | Description |
|:------|:-----|:------------|
| 1 | Cash (Tien mat) | Thanh toan tien mat |
| 2 | Transfer (Chuyen khoan) | Chuyen khoan ngan hang |
| 3 | Installment (Tra gop) | Tra gop qua ngan hang |

## 4. RESPONSE PATTERN

### Dung
```csharp
// DUNG - tra ve typed object
return ApiResponse<object>.Ok(new SALReceiptResponse
{
    Code = receipt.Code,
    OrderMasterCode = receipt.OrderMaster,
    CollectedAmount = receipt.CollectedAmount,
    Status = receipt.Status,
    StatusName = ReceiptStatus.GetName(receipt.Status)
});
```

### Sai
```csharp
// SAI - tra ve anonymous object khong co structure
return ApiResponse<object>.Ok(new { receipt.Code, receipt.Status });
```

## 5. VALIDATION RULES

```csharp
// BAT BUOC validate dau vao
if (request.CollectedAmount <= 0)
    return ApiResponse<object>.BadRequest("So tien phai lon hon 0");

if (string.IsNullOrWhiteSpace(request.CancelReason) && targetStatus == ReceiptStatus.Cancelled)
    return ApiResponse<object>.BadRequest("Huy phieu thu phai co ly do");
```

## 6. MANDATORY BE PATTERNS (BA MUST include in every BE Guide)

### HEAD Filter — ALL queries MUST filter by branch
```csharp
// Every GET handler MUST include:
.Where(x => x.Head == currentUser.HeadCode)
```
BA Guide MUST specify: "All list queries MUST filter by Head (HEAD-01 rule)"

### ICurrentUserService — audit fields MUST use real user context
```csharp
// Every create/update handler MUST inject ICurrentUserService
// NEVER hard-code Head, Cashier, CreatedBy values
receipt.Head = currentUser.HeadCode;
receipt.Cashier = currentUser.EmployeeCode;
receipt.CreatedBy = currentUser.UserName;
```
BA Guide MUST specify: "Inject ICurrentUserService for audit fields"

### Auto-Generated IDs — use tbl_SYSIncrease pattern
BA Guide MUST specify: "ReceiptNo uses tbl_SYSIncrease auto-generation, NOT manual string concat"

## 7. FE CODING STANDARDS

### Angular - Constants (must match tbl_LSStatus TypeData=22)
```typescript
// Values from production DB — use enum, NOT const object
export enum SALReceiptStatusEnum {
  NEW = 1,        // TypeOfStatus=1, Code=126
  COMPLETED = 2,  // TypeOfStatus=2, Code=127
  CANCELLED = 3,  // TypeOfStatus=3, Code=128
}
```

### Angular - NO MAGIC NUMBERS in templates
```html
<!-- WRONG -->
<div *ngIf="item.Status !== 1">

<!-- CORRECT -->
<div *ngIf="item.Status !== ReceiptStatus.NEW">
```
BA Guide MUST specify: "Expose enum in component class, use in HTML template"

