# Glossary - Honda HEAD Hoài Minh Internal Terminology

## Organization Terms

| Term (Vietnamese) | Abbreviation | Meaning |
|-------------------|-------------|---------|
| HEAD | - | Honda Exclusive Authorized Dealer. Hoài Minh operates multiple HEADs (branches). |
| Chi nhánh (Branch) | CN | A specific HEAD in the Hoài Minh chain (e.g., CN Long Hoa, CN Vòng Xoay, CN Châu Thành...) |
| Giám đốc (Director) | GĐ | Top executive who manages ALL HEADs across the entire Hoài Minh system |
| Cửa hàng trưởng (Store Manager) | CHT | Manager of 1 HEAD, may be granted authority over additional HEADs |
| Trưởng phòng Kinh doanh (Sales Director) | TPKD | Approves sales policies, special promotions |

## Personnel Terms

| Term (Vietnamese) | Abbreviation | Meaning |
|-------------------|-------------|---------|
| Nhân viên Sale (Sales Staff) | NV Sale | Greets customers, consults on vehicle selection |
| Thu ngân / Kế toán (Cashier / Accountant) | TN/KT | Handles payment collection. May be an NV Sale if granted permission |
| Kỹ thuật viên (Technician) | KTV | Performs vehicle repair & maintenance |
| Quản lý Kho phụ tùng (Parts Warehouse Manager) | QL Kho PT | Manages Honda genuine parts inventory |
| Quản lý Kho xe máy (Vehicle Warehouse Manager) | QL Kho XM | Manages whole-vehicle inventory |
| Bộ phận CSKH (Customer Care) | CSKH | Customer service, sends SMS/Zalo maintenance reminders |
| Bộ phận Marketing | MAR | Marketing & communications |
| Nhân viên tiếp nhận (Reception Staff) | NV Tiếp nhận | Collects customer documents (ID, address, phone...) |

## Sales Terms

| Term (Vietnamese) | Meaning |
|-------------------|---------|
| Phiếu bán hàng / Đơn hàng (Sales Order) | `tbl_SALOrderMaster` - Customer's vehicle order |
| Bán lẻ (Retail) | Direct sale to end-user consumer |
| Bán sỉ (Wholesale) | Sale to dealers/businesses |
| Phiếu chính sách (Policy Voucher) | `tbl_POLPromotionMaster` - Discount/promotion voucher requiring approval |
| Giỏ hàng (Cart) | Selected vehicles in order (`tbl_SALOrderDetail`) |
| Options đi kèm (Add-ons) | Parts (`PartItem`), Services (`Service`), Promotions (`Promotion`) |
| Phiếu thu (Receipt) | `tbl_SALOrderReceipt` - Confirms payment received |
| Hóa đơn (Invoice) | `tbl_SALOrderInvoice` - Legal document when transaction completes |
| Đặt cọc (Deposit) | Partial payment, remainder collected on delivery |
| Trả góp (Installment) | Payment via 3rd-party (bank), HEAD receives full amount from financier |
| Điều chuyển xe (Vehicle Transfer) | Transfer vehicle from HEAD A -> HEAD B when current HEAD is out of stock |
| Đặt xe (Vehicle Order/Reservation) | Order from Honda factory when out of stock; customer signs contract & waits |

## Service Terms (Maintenance / Repair)

| Term (Vietnamese) | Meaning |
|-------------------|---------|
| Work Order / Phiếu sửa chữa | `tbl_CSWorkOrderMaster` - Maintenance/repair work order |
| Sổ bảo hành (Warranty Book) | Tracks Honda warranty history, comes with new vehicles |
| Bảo dưỡng định kỳ (Periodic Maintenance) | Based on Km milestones or time intervals (6 months or 4,000km) |
| Khách quen (Loyal Customer) | `tbl_CSLoyalCustomer` - Customer with purchase/service history at HEAD |
| CS Vehicle | `tbl_CSVehicle` - Customer's vehicle (frame number, engine number, plate number) |
| Quét biển số (Plate Scanning) | Auto-scan license plate on entry to look up service history |
| Phiếu hẹn lấy xe (Pickup Appointment Slip) | Printed slip for customers when repair takes long; includes pickup date/time |
| Tư vấn viên dịch vụ (Service Consultant) | `Consultant` - Receives & consults customers on service needs |
| KTV sửa chữa (Repair Technician) | `TechnicalRepair` - Technician who performs the actual repair |

## Warehouse Terms

| Term (Vietnamese) | Meaning |
|-------------------|---------|
| Phụ tùng chính hãng (Genuine Parts) | Official Honda parts, mandatory for warranty validity |
| DO (Delivery Order) | `tbl_PURDOMaster` - Delivery order from supplier |
| Nhập kho / Xuất kho (Stock In/Out) | `tbl_WHIOMaster` - Warehouse receipt/issue documents |
| Tồn kho xe (Vehicle Stock) | `tbl_LSVehicleColorStock` - Vehicle quantity by color per warehouse |
| Tồn kho phụ tùng (Parts Stock) | `tbl_LSPartWarehouse` - Parts quantity per warehouse |
| Kiểm kê (Inventory Audit) | `tbl_WHInventory*` - Physical stock count process |
| Zone/Location | Warehouse zones/locations for item positioning |

## Database Table Prefixes

| Prefix | Module | Meaning |
|--------|--------|---------|
| `tbl_SAL` | Sale | Vehicle sales |
| `tbl_CS` | Customer Service | Maintenance, repair, customer care |
| `tbl_WH` | Warehouse | Stock management |
| `tbl_LS` | List/Master | Shared master data (vehicles, parts, partners, addresses) |
| `tbl_HR` | Human Resource | Staff management |
| `tbl_SYS` | System | Roles, permissions, modules, API registry |
| `tbl_POL` | Policy | Promotions & discount policies |
| `tbl_PUR` | Purchase | Purchasing & delivery orders |
| `tbl_SIO` | Stock In/Out (Vehicle) | Vehicle-specific stock movements |
| `tbl_REV` | Revenue | Revenue tracking |
