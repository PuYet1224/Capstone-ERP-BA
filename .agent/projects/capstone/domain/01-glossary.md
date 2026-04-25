# Glossary - Capstone Hoài Minh Internal Terminology

## Organization Terms

| Term (Vietnamese) | Abbreviation | Meaning |
|-------------------|-------------|---------|
| HEAD | - | Honda Exclusive Authorized Dealer. Hoài Minh operates multiple HEADs (branches). |
| Chi nhánh | CN | A specific HEAD in the Hoài Minh chain (e.g., CN Long Hoa, CN Vòng Xoay, CN Châu Thành...) |
| Giám đốc | G | Top executive who manages ALL HEADs across the entire Hoài Minh system |
| Cửa hàng trưởng | CHT | Store Manager of 1 HEAD, may be granted authority over additional HEADs |
| Trưởng phòng Kinh doanh | TPKD | Sales Director. Approves sales policies, special promotions |

## Personnel Terms

| Term (Vietnamese) | Abbreviation | Meaning |
|-------------------|-------------|---------|
| Nhân viên Sale | NV Sale | Sales Staff. Greets customers, consults on vehicle selection |
| Thu ngân / Kế toán | TN/KT | Cashier / Accountant. Handles payment collection. May be an NV Sale if granted permission |
| Kỹ thuật viên | KTV | Technician. Performs vehicle repair & maintenance |
| Quản lý Kho phụ tùng | QL Kho PT | Parts Warehouse Manager. Manages Honda genuine parts inventory |
| Quản lý Kho xe máy | QL Kho XM | Vehicle Warehouse Manager. Manages whole-vehicle inventory |
| Bộ phận CSKH | CSKH | Customer Care. Customer service, sends SMS/Zalo maintenance reminders |
| Bộ phận Marketing | MAR | Marketing Staff. Marketing & communications |
| Nhân viên tiếp nhận | NV Tiếp nhận | Reception Staff. Collects customer documents (ID, address, phone...) |

## Sales Terms

| Term (Vietnamese) | Meaning |
|-------------------|---------|
| Phiếu bán hàng / Đơn hàng | `tbl_SALOrderMaster` - Customer's vehicle sales order |
| Bán lẻ | Retail. Direct sale to end-user consumer |
| Bán sỉ | Wholesale. Sale to dealers/businesses |
| Phiếu chính sách | `tbl_POLPromotionMaster` - Policy Voucher. Discount/promotion voucher requiring approval |
| Giỏ hàng | Cart. Selected vehicles in order (`tbl_SALOrderDetail`) |
| Options đi kèm | Add-ons. Parts (`PartItem`), Services (`Service`), Promotions (`Promotion`) |
| Phiếu thu | `tbl_SALOrderReceipt` - Receipt. Confirms payment received |
| Hóa đơn | `tbl_SALOrderInvoice` - Invoice. Legal document when transaction completes |
| Đặt cọc | Deposit. Partial payment, remainder collected on delivery |
| Trả góp | Installment. Payment via 3rd-party (bank), HEAD receives full amount from financier |
| Điều chuyển xe | Vehicle Transfer. Transfer vehicle from HEAD A to HEAD B when current HEAD is out of stock |
| Đặt xe | Vehicle Reservation. Order from Honda factory when out of stock; customer signs contract & waits |

## Service Terms (Maintenance / Repair)

| Term (Vietnamese) | Meaning |
|-------------------|---------|
| Phiếu sửa chữa | `tbl_CSWorkOrderMaster` - Work Order for maintenance/repair |
| Sổ bảo hành | Warranty Book. Tracks Honda warranty history, comes with new vehicles |
| Bảo dưỡng định kỳ | Periodic Maintenance. Based on Km milestones or time intervals (6 months or 4,000km) |
| Khách quen | `tbl_CSLoyalCustomer` - Loyal Customer with purchase/service history at HEAD |
| CS Vehicle | `tbl_CSVehicle` - Customer's vehicle (frame number, engine number, plate number) |
| Quẹt biển số | Plate Scanning. Auto-scan license plate on entry to look up service history |
| Phiếu hẹn lấy xe | Pickup Appointment Slip. Printed slip for customers when repair takes long; includes pickup date/time |
| Tư vấn viên dịch vụ | `Consultant` - Service Consultant. Receives & consults customers on service needs |
| KTV sửa chữa | `TechnicalRepair` - Repair Technician. Technician who performs the actual repair |

## Warehouse Terms

| Term (Vietnamese) | Meaning |
|-------------------|---------|
| Phụ tùng chính hãng | Genuine Parts. Official Honda parts, mandatory for warranty validity |
| DO | `tbl_PURDOMaster` - Delivery Order from supplier |
| Nhập kho / Xuất kho | `tbl_WHIOMaster` - Stock In/Out. Warehouse receipt/issue documents |
| Tồn kho xe | `tbl_LSVehicleColorStock` - Vehicle Stock. Vehicle quantity by color per warehouse |
| Tồn kho phụ tùng | `tbl_LSPartWarehouse` - Parts Stock. Parts quantity per warehouse |
| Kiểm kê | `tbl_WHInventory*` - Inventory Audit. Physical stock count process |
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
