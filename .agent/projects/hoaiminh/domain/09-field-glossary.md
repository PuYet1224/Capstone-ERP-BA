# Field Glossary -- Business Meaning of Technical Field Names

> AI MUST read this file before writing code for any feature.
> If a field is NOT in this glossary and its meaning is unclear -> ASK user.
> NEVER guess business meaning from technical name alone.

---

## Purpose

Database columns in Hoai Minh ERP often use abbreviated or domain-specific names
that do NOT convey their business meaning to outsiders. This glossary bridges
the gap between "what the column is called" and "what it actually means".

---

## How to Read This File

| Column | Meaning |
|--------|---------|
| Table | Database table name |
| Field | Column name in the table |
| Type | SQL data type |
| Business Meaning | Plain-language explanation (Vietnamese context in English) |
| Values | Allowed values or examples (if applicable) |

---

## Module: Sales (SAL)

### tbl_SALOrderMaster

| Field | Type | Business Meaning | Values |
|-------|------|-----------------|--------|
| TypeData | int | Order type discriminator | 1=Retail (individual buyer), 3=Wholesale (dealer/partner) |
| IsNewCustomer | bit | First-time buyer flag -- customer has no record in tbl_CSLoyalCustomer | 0=Returning, 1=New |
| HeadOut | bigint | The HEAD (branch) that SELLS the vehicle -- not the HEAD that owns the stock | FK to tbl_LSHead |
| WHOut | bigint | The warehouse that ISSUES the vehicle for this order | FK to tbl_LSWarehouse |
| SIOMasterVehicle | bigint | Link to Stock-In-Out (SIO) record -- the physical stock movement document | FK to tbl_WHSIOMasterVehicle |
| AmountPaid | float | Cumulative amount the customer has paid so far (sum of all receipts) | Updated on each receipt |
| PaymentCount | int | Number of payment receipts created for this order | Auto-incremented |
| CustomerNeeds | nvarchar(MAX) | Sale staff notes about what the customer is looking for | Free text |
| CustomerCharacteristics | nvarchar(MAX) | Personality/behavior notes to help future interactions | Free text |
| CustomerExpectation | nvarchar(MAX) | What the customer expects from the purchase | Free text |

### tbl_SALOrderReceipt

| Field | Type | Business Meaning | Values |
|-------|------|-----------------|--------|
| CollectedAmount | float | The actual money received in THIS specific payment | Not cumulative |
| Signature | nvarchar(MAX) | Base64-encoded digital signature image from customer | PNG base64 |
| Cashier | int | The employee who collected the payment | FK to tbl_HREmployee |

---

## Module: Customer Service (CS)

### tbl_CSVehicle

| Field | Type | Business Meaning | Values |
|-------|------|-----------------|--------|
| IsLock | bit | **Vehicle reservation lock** -- vehicle is held for a specific sales order and cannot be sold to anyone else | 0=Available, 1=Reserved/Locked |
| CurrentKm | int | Latest odometer reading -- updated every time the vehicle enters the service workshop | Kilometers |
| CurrentPoint | float | Loyalty points accumulated from service visits -- 1 service visit = 1 point | Running total |
| WarrantyKm | int | Maximum km covered by manufacturer warranty (e.g., 30000) | Km limit |
| WarrantyDate | datetime | Warranty expiration date -- vehicle is no longer covered after this date | Date |
| TradeDate | datetime | Date the vehicle was SOLD to the customer (not the date it was imported into stock) | Sale date |
| FrameSeri | nvarchar(50) | Chassis/frame number -- unique identifier stamped on the vehicle frame | Unique per vehicle |
| EngineSeri | nvarchar(50) | Engine serial number -- unique identifier stamped on the engine block | Unique per vehicle |

### tbl_CSLoyalCustomer

| Field | Type | Business Meaning | Values |
|-------|------|-----------------|--------|
| CardNo | nvarchar(10) | Physical loyalty card number issued to customer | Printed on card |
| FirstHead | bigint | The HEAD (branch) where the customer FIRST visited or purchased | FK to tbl_LSHead |
| MyHonda | int | Whether customer has installed the MyHonda mobile app | 0=No, 1=Yes |
| OA | int | Whether customer follows the Honda Official Account (Zalo OA) | 0=No, 1=Yes |
| Zalo | nvarchar(15) | Customer Zalo phone number (may differ from main phone) | Phone format |
| CitizenCardNo | nvarchar(20) | Vietnamese citizen ID card number (CCCD/CMND) | 9 or 12 digits |

---

## Module: Master Data (LS)

### tbl_LSVehicleColorStock

| Field | Type | Business Meaning | Values |
|-------|------|-----------------|--------|
| Lock | int | Number of units currently RESERVED for pending sales orders | Count |
| Quantity | int | Total units physically in the warehouse (includes locked units) | Count |
| Available | computed | Quantity - Lock = units actually available for sale | Computed |

### tbl_LSHead

| Field | Type | Business Meaning | Values |
|-------|------|-----------------|--------|
| ReportToHead | bigint | Parent HEAD in the organizational hierarchy -- for multi-level reporting | FK to self |
| BriefName | nvarchar | Short name used in UI dropdowns and reports | e.g., "HM-HCM", "HM-DN" |
| TradeName | nvarchar | Full legal trade name of the branch | Official name |

### tbl_LSStatus

| Field | Type | Business Meaning | Values |
|-------|------|-----------------|--------|
| TypeOfStatus | int | Which MODULE this status belongs to | Groups statuses by module |
| TypeData | int | Which FEATURE within the module this status applies to | Sub-groups within module |

### tbl_LSList

| Field | Type | Business Meaning | Values |
|-------|------|-----------------|--------|
| Parent | bigint | Parent item in the hierarchy -- used for cascading dropdowns | FK to self |
| TypeList | int | Category of the list (e.g., Gender, Occupation, Payment Method) | Grouping key |

---

## Module: Warehouse (WH)

### tbl_WHSIOMasterVehicle (Stock-In-Out)

| Field | Type | Business Meaning | Values |
|-------|------|-----------------|--------|
| TypeData | int | Type of stock movement | 1=Import (Honda factory), 2=Transfer In, 3=Transfer Out, 4=Sale Out |
| HeadIn | bigint | The HEAD receiving the vehicle | FK to tbl_LSHead |
| HeadOut | bigint | The HEAD sending the vehicle | FK to tbl_LSHead |
| WHIn | bigint | Destination warehouse | FK to tbl_LSWarehouse |
| WHOut | bigint | Source warehouse | FK to tbl_LSWarehouse |

---

## Common Patterns

### Prefix Patterns

| Prefix | Meaning | Example |
|--------|---------|---------|
| Is{X} | Boolean flag (bit) | IsLock, IsActive, IsNewCustomer |
| {Entity}Master | FK to parent/header table | OrderMaster, SIOMasterVehicle |
| {X}In / {X}Out | Inbound/Outbound of a transfer | HeadIn/HeadOut, WHIn/WHOut |
| Current{X} | Latest/running value | CurrentKm, CurrentPoint |
| {X}Date | Date field | TradeDate, SaleDate, WarrantyDate |
| {X}No | Display number/code | CardNo, InvoiceNo, PlateNo |
| {X}Seri | Serial/unique identifier | FrameSeri, EngineSeri |

### TypeData Values by Module

| Table | TypeData | Meaning |
|-------|---------|---------|
| tbl_SALOrderMaster | 1 | Retail sale (individual) |
| tbl_SALOrderMaster | 3 | Wholesale (partner/dealer) |
| tbl_WHSIOMasterVehicle | 1 | Import from Honda factory |
| tbl_WHSIOMasterVehicle | 2 | Transfer in from another HEAD |
| tbl_WHSIOMasterVehicle | 3 | Transfer out to another HEAD |
| tbl_WHSIOMasterVehicle | 4 | Sale out to customer |
