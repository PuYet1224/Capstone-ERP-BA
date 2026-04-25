# 11 - Coding Standards (Bắt Buộc Đọc Trước Khi Code)

> **CRITICAL:** Mọi nhân viên AI (BA/BE/FE) PHẢI đọc file này. Vi phạm bất kỳ rule nào = code FAILED.

## 0. API NAMING - CHỈ 4 PREFIX ĐƯỢC PHÉP

| Prefix | Ý nghĩa | Ví dụ |
|:-------|:--------|:------|
| **Get** | Lấy data | `GetListSALReceipt`, `GetSALReceipt` |
| **Update** | Tạo mới + sửa + đổi trạng thái | `UpdateSALReceipt`, `UpdateSALReceiptStatus` |
| **Delete** | Xóa | `DeleteSALReceipt` |
| **Add** | Thêm item vào collection | `AddSALSelectedVehicles` |

**CẤM TUYỆT ĐỐI:** ~~Create~~, ~~Cancel~~, ~~Complete~~, ~~Insert~~, ~~Remove~~, ~~Set~~, ~~Patch~~
- Tạo mới = `Update` (Code=0 thì insert, Code>0 thì update)
- Hủy = `UpdateStatus` (Status = Cancelled)
- Hoàn tất = `UpdateStatus` (Status = Completed)

## 1. CẤM TUYỆT ĐỐI HARD-CODE MAGIC NUMBERS

### Sai (BỊ CẤM)
```csharp
// SAI - hard-code status number
if (receipt.Status == 30) // 30 là gì?
receipt.Status = 10;
var allowed = (10, 30) => true; // magic numbers
order.PaymentMethod == 3; // 3 là gì?
```

### Đúng (BẮT BUỘC)
```csharp
// ĐÚNG - dùng constants mapped to tbl_LSStatus TypeData=22
public static class ReceiptStatus
{
    public const int New = 1;        // TypeOfStatus=1, Code=126, "Mới"
    public const int Completed = 2;  // TypeOfStatus=2, Code=127, "Hoàn tất"
    public const int Cancelled = 3;  // TypeOfStatus=3, Code=128, "Hủy giao dịch"
}

// ĐÚNG - sử dụng constant
if (receipt.Status == ReceiptStatus.Completed)
var allowed = (ReceiptStatus.New, ReceiptStatus.Completed) => true;
```

## 2. CẤM DÙNG `dynamic Payload` CHO HANDLER MỚI

### Sai (pattern cũ - chỉ chấp nhận cho handler đã tồn tại)
```csharp
// SAI - không type-safe, không validate được
public record UpdateSALReceiptCommand(dynamic Payload) : IRequest<ApiResponse<object>>;
long code = (long)request.Payload.Code; // runtime error nếu thiếu field
```

### Đúng (BẮT BUỘC cho code mới)
```csharp
// ĐÚNG - strongly-typed request
public record UpdateSALReceiptCommand(
    long OrderMasterCode,
    double CollectedAmount,
    int PaymentType,
    string? Note
) : IRequest<ApiResponse<object>>;

// Access trực tiếp - compile-time safe
var order = await db.SALOrderMasters
    .FirstOrDefaultAsync(o => o.Code == request.OrderMasterCode, ct);
```

## 3. STATUS DEFINITIONS (From production DB tbl_LSStatus)

> Values from production DB. BA/BE/FE MUST use these exact values. Column `Status` stores `TypeOfStatus`.

### Receipt Status (SALOrderReceipt, TypeData=22)
| TypeOfStatus | Name | Code (PK) | Description |
|:-------------|:-----|:----------|:------------|
| 1 | New (Mới) | 126 | Receipt created, not yet confirmed |
| 2 | Completed (Hoàn tất) | 127 | Payment collected and confirmed |
| 3 | Cancelled (Hủy giao dịch) | 128 | Receipt cancelled |

### Invoice Status (SALOrderInvoice, TypeData=23)
| TypeOfStatus | Name | Code (PK) | Description |
|:-------------|:-----|:----------|:------------|
| 1 | New (Mới) | 129 | Invoice created |
| 2 | Completed (Hoàn tất) | 130 | Invoice issued |
| 3 | Cancelled (Hủy giao dịch) | 131 | Invoice cancelled |

### Sales Order Status (SALOrderMaster, TypeData=18)
| TypeOfStatus | Name | Code (PK) | Description |
|:-------------|:-----|:----------|:------------|
| 1 | Created (Tạo mới) | 92 | Order just created |
| 2 | Returned (Trả về) | 93 | Order returned for revision |
| 3 | Pending (Chờ xử lý) | 94 | Waiting for processing |
| 4 | Processing (Đang xử lý) | 95 | Active order in progress |
| 5 | Completed (Hoàn tất) | 96 | Order fulfilled |
| 6 | Cancelled (Hủy giao dịch) | 133 | Order cancelled |

### Payment Method (SALOrderMaster.PaymentMethod)
| Value | Name | Description |
|:------|:-----|:------------|
| 1 | Cash (Tiền mặt) | Thanh toán tiền mặt |
| 2 | Transfer (Chuyển khoản) | Chuyển khoản ngân hàng |
| 3 | Installment (Trả góp) | Trả góp qua ngân hàng |

## 4. RESPONSE PATTERN

### Đúng
```csharp
// ĐÚNG - trả về typed object
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
// SAI - trả về anonymous object không có structure
return ApiResponse<object>.Ok(new { receipt.Code, receipt.Status });
```

## 5. VALIDATION RULES

```csharp
// BẮT BUỘC validate đầu vào
if (request.CollectedAmount <= 0)
    return ApiResponse<object>.BadRequest("Số tiền phải lớn hơn 0");

if (string.IsNullOrWhiteSpace(request.CancelReason) && targetStatus == ReceiptStatus.Cancelled)
    return ApiResponse<object>.BadRequest("Hủy phiếu thu phải có lý do");
```

## 6. MANDATORY BE PATTERNS (BA MUST include in every BE Guide)

### HEAD Filter - ALL queries MUST filter by branch
```csharp
// Every GET handler MUST include:
.Where(x => x.Head == currentUser.HeadCode)
```
BA Guide MUST specify: "All list queries MUST filter by Head (HEAD-01 rule)"

### ICurrentUserService - audit fields MUST use real user context
```csharp
// Every create/update handler MUST inject ICurrentUserService
// NEVER hard-code Head, Cashier, CreatedBy values
receipt.Head = currentUser.HeadCode;
receipt.Cashier = currentUser.EmployeeCode;
receipt.CreatedBy = currentUser.UserName;
```
BA Guide MUST specify: "Inject ICurrentUserService for audit fields"

### Auto-Generated IDs - use tbl_SYSIncrease pattern
BA Guide MUST specify: "ReceiptNo uses tbl_SYSIncrease auto-generation, NOT manual string concat"

## 7. FE CODING STANDARDS

### Angular - Constants (must match tbl_LSStatus TypeData=22)
```typescript
// Values from production DB - use enum, NOT const object
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

