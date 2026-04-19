# 📚 Bách Khoa Toàn Thư — AI Agent System

> **Dự án:** Hoài Minh ERP (Honda HEAD)
> **Ngày cập nhật:** 2026-04-19
> **Tác giả:** Team Lead + AI Agent
> **Áp dụng cho:** Mọi máy — paths linh hoạt qua `WORKSPACE_MAP`

---

## 📋 Mục Lục

0. [Path Portability — Triển Khai Linh Hoạt](#0--path-portability)
0A. [Cơ Chế AI Tự Biết Path — Giải Thích Rõ Ràng](#0a--cơ-chế-ai-tự-biết-path)
0B. [Multi-Project Setup — Nhiều Dự Án Trên 1 Server](#0b--multi-project-setup)
1. [Tổng Quan Hệ Thống](#1--tổng-quan-hệ-thống)
2. [Full Pipeline A→Z](#2--full-pipeline-az)
3. [Nhân Viên 1: BA](#3--nhân-viên-1-ba)
4. [Nhân Viên 2: BE](#4--nhân-viên-2-be)
5. [Nhân Viên 3: FE Web](#5--nhân-viên-3-fe-web)
6. [Nhân Viên 4: FE Mobile](#6--nhân-viên-4-fe-mobile)
7. [Shared Skills (Dùng Chung)](#7--shared-skills)
8. [Xử Lý Tình Huống](#8--xử-lý-tình-huống)
9. [Quy Tắc Vàng](#9--quy-tắc-vàng)
10. [Lỗi Thường Gặp](#10--lỗi-thường-gặp)

---

## 0. 🔧 Path Portability — Triển Khai Linh Hoạt

### Cách Hệ Thống Hoạt Động

Toàn bộ AI skills/workflows **KHÔNG chứa đường dẫn cứng** — thay vào đó dùng **biến** `{BA_ROOT}` và `{PIPELINE_ROOT}`.

Mỗi workspace có **1 file duy nhất** chứa đường dẫn thật: `.agent/GEMINI.md`.

### Cấu Trúc Luồng Path

```
┌─────────────────────────────────────────────────────────┐
│                .agent/GEMINI.md (mỗi workspace)          │
│                                                         │
│   ## WORKSPACE_MAP                                      │
│   BA_ROOT:        C:\Users\lala0\Capstone-ERP-BA  ◄──── │──── CHỈ SỬA Ở ĐÂY
│   PIPELINE_ROOT:  C:\ai-pipeline                  ◄──── │──── KHI ĐỔI MÁY
│                                                         │
└───────────┬─────────────────────────────────────────────┘
            │
            │  AI đọc WORKSPACE_MAP → thay thế biến
            │
            ▼
┌─────────────────────────────────────────────────────────┐
│              SKILL.md / workflow.md                      │
│                                                         │
│   READ: {PIPELINE_ROOT}\requirements\                   │
│   READ: {BA_ROOT}\.agent\projects\hoaiminh\standards\   │
│   WRITE: {PIPELINE_ROOT}\guides\                        │
│                                                         │
│   → AI tự thay {PIPELINE_ROOT} = C:\ai-pipeline         │
│   → AI tự thay {BA_ROOT} = C:\Users\lala0\Capstone-...  │
└─────────────────────────────────────────────────────────┘
```

### Tại Sao Không Hardcode Path?

| Vấn đề | Trước (hardcode) | Sau (WORKSPACE_MAP) |
|--------|-------------------|---------------------|
| Đổi máy | Sửa 50+ files | Sửa **4 files** |
| Tên folder khác | Broken hoàn toàn | Chỉ sửa GEMINI.md |
| Nhiều dev cùng dùng | Conflict paths | Mỗi máy tự config |
| Server vs Local | Code khác nhau | Cùng code, khác config |

---

## 0A. 🔬 Cơ Chế AI Tự Biết Path — Giải Thích Rõ Ràng

### AI biết path từ đâu? (3 nguồn theo thứ tự ưu tiên)

```
NGUỒN 1: Conversation Metadata (tự động, không cần config)
  → Khi bạn mở workspace trong IDE (Gemini Code Assist)
  → Tool inject vào đầu mỗi session:
      "Active workspace: C:\Users\alice\CompanyERP-WEB"   ← [EXAMPLE — thay bằng path thật của bạn]
  → AI biết: đây là FE Web root, đọc GEMINI.md ở đây

NGUỒN 2: .agent/GEMINI.md (bạn config 1 lần)
  → AI đọc .agent/GEMINI.md trong workspace đang mở
  → Tìm block WORKSPACE_MAP → lấy BA_ROOT, PIPELINE_ROOT
  → Dùng cho toàn bộ session đó

NGUỒN 3: Skills/Workflows (biến {X_ROOT})
  → Skill viết: READ {BA_ROOT}\.agent\projects\hoaiminh\standards\
  → AI ghép: {BA_ROOT} = [giá trị thật từ GEMINI.md WORKSPACE_MAP]
            → [path thật resolved tại runtime]
```

### Sơ Đồ Luồng Đầy Đủ (Từ Lúc Bạn Gõ Lệnh)

```
> ⚠️ Các paths bên dưới là [EXAMPLE ONLY] — giá trị thật do IDE inject + GEMINI.md của BẠN quyết định

Bạn gõ: /fe-implement
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│  BƯỚC 1: IDE inject metadata vào context                    │
│                                                             │
│  "Active workspace: {FE_WORKSPACE_ROOT}"  ← IDE inject      │
│  "User workspace corpus: {CORPUS_NAME}"   ← IDE inject      │
├─────────────────────────────────────────────────────────────┤
│  BƯỚC 2: AI đọc .agent/GEMINI.md của workspace đang mở     │
│                                                             │
│  .agent/GEMINI.md:                                          │
│    WORKSPACE_MAP:                                           │
│      BA_ROOT:       {BA_ROOT}       ← bạn điền giá trị thật │
│      PIPELINE_ROOT: {PIPELINE_ROOT} ← bạn điền giá trị thật │
├─────────────────────────────────────────────────────────────┤
│  BƯỚC 3: AI đọc workflow /fe-implement.md → tìm STEP 0     │
│                                                             │
│  workflow nói: "READ {BA_ROOT}\.agent\projects\...\         │
│                      standards\fe-standards.md"             │
│                                                             │
│  AI thay biến:                                              │
│    {BA_ROOT} → giá trị thật từ GEMINI.md                    │
│    → Đọc: [resolved path]                                   │
├─────────────────────────────────────────────────────────────┤
│  BƯỚC 4: AI đọc skill fe-pipeline → tìm guide              │
│                                                             │
│  skill nói: "SCAN {PIPELINE_ROOT}\guides\ for FE_WEB_*"    │
│  AI thay: → [resolved PIPELINE_ROOT]\guides\                │
│    Tìm thấy: FE_WEB_001_Feature.md                          │
│    Đọc guide → implement                                    │
└─────────────────────────────────────────────────────────────┘
```

### Tại Sao AI Không "Bịa" Path?

> AI không đoán mò. Nếu GEMINI.md thiếu `BA_ROOT` hoặc `{BA_ROOT}` không resolve được
> → AI sẽ báo lỗi hoặc đọc nhầm file.

```
❌ SẼ XẢY RA NẾU:
  .agent/GEMINI.md có:  BA_ROOT: {BA_ROOT}   ← chưa điền giá trị thật
  → AI đọc literal "{BA_ROOT}" → không resolve → fail

✅ PHẢI LÀ (điền path thật của máy bạn):
  .agent/GEMINI.md có:  BA_ROOT: D:\Projects\CompanyX\BA     ← ví dụ công ty
  .agent/GEMINI.md có:  BA_ROOT: C:\Dev\HoaiMinh\BA          ← ví dụ local
  → Bất kỳ path nào cũng được, miễn là ĐÚNG đường dẫn thật
```

### Cách Các "Nhân Viên" Nối Với Nhau

```
                KHÔNG PHẢI: nhân viên gọi nhân viên trực tiếp
                ĐÚNG LÀ:    họ dùng CHUNG folder {PIPELINE_ROOT}

  BA (Workspace 1)          BE (Workspace 2)         FE (Workspace 3)
       │                          │                        │
       │ Viết vào                 │ Đọc từ                 │ Đọc từ
       ▼                          ▼                        ▼
  {PIPELINE_ROOT}\guides\BE_001_Receipt.md    ← BE đọc file này
  {PIPELINE_ROOT}\guides\FE_WEB_001_Receipt.md ← FE Web đọc file này
  {PIPELINE_ROOT}\guides\FE_MOBWEB_001.md      ← FE Mobile đọc
       ▲
       │ Đọc yêu cầu từ
  {PIPELINE_ROOT}\requirements\REQ_001.md

  → Pipeline folder = "hộp thư công cộng" giữa 4 nhân viên
  → Mỗi nhân viên chỉ biết đường dẫn cụ thể đến folder đó (qua PIPELINE_ROOT)
  → Họ KHÔNG cần biết workspace của nhau!
```

### Bảng Tóm Tắt: Ai Biết Gì?

| Workspace | Biết workspace của mình | Biết BA_ROOT | Biết PIPELINE_ROOT | Biết workspace BE/FE khác |
|-----------|------------------------|--------------|-------------------|--------------------------|
| BA | ✅ (chính nó) | ❌ (không cần) | ✅ | ❌ |
| BE | ✅ | ✅ | ✅ | ❌ |
| FE Web | ✅ | ✅ | ✅ | ❌ |
| FE Mobile | ✅ | ✅ | ✅ | ❌ |

> **Kết luận:** Các nhân viên không biết nhau. Họ giao tiếp qua folder chung `{PIPELINE_ROOT}`.

---

## 0B. 🏗️ Multi-Project Setup — Nhiều Dự Án Trên 1 Server

### Nguyên Tắc Cốt Lõi

> Mỗi dự án = **bộ 4 workspace riêng biệt** + **1 pipeline folder riêng**.
> AI phân biệt dự án bởi workspace nào đang **MỞ** trong IDE.

### Ví Dụ: 2 Dự Án Trên Server D:\

```
D:\Projects\
├── HoaiMinhERP\                 ← Dự án 1: Honda HEAD
│   ├── BA\                      ← BA workspace
│   ├── BE\                      ← BE workspace
│   ├── FE-Web\                  ← FE Web workspace
│   ├── FE-Mobile\               ← FE Mobile workspace
│   └── ai-pipeline\             ← Shared pipeline (dự án 1 chỉ)
│       ├── requirements\
│       └── guides\
│
└── GarageERP\                   ← Dự án 2: Garage quản lý xe
    ├── BA\                      ← BA workspace
    ├── BE\                      ← BE workspace
    ├── FE-Web\                  ← FE Web workspace
    └── ai-pipeline\             ← Shared pipeline (dự án 2 chỉ)
        ├── requirements\
        └── guides\
```

### Config GEMINI.md Cho Từng Dự Án

```
┌─ HoaiMinhERP\FE-Web\.agent\GEMINI.md ──────────────────────┐
│ WORKSPACE_MAP:                                              │
│   BA_ROOT:        D:\Projects\HoaiMinhERP\BA               │
│   PIPELINE_ROOT:  D:\Projects\HoaiMinhERP\ai-pipeline      │
└─────────────────────────────────────────────────────────────┘

┌─ GarageERP\FE-Web\.agent\GEMINI.md ────────────────────────┐
│ WORKSPACE_MAP:                                              │
│   BA_ROOT:        D:\Projects\GarageERP\BA                 │
│   PIPELINE_ROOT:  D:\Projects\GarageERP\ai-pipeline        │
└─────────────────────────────────────────────────────────────┘
```

### Cách AI Phân Biệt Dự Án Khi Làm Việc

```
Tình huống: Mở FE-Web của GarageERP trong IDE

  IDE inject metadata:
    "Active workspace: D:\Projects\GarageERP\FE-Web"   ← [EXAMPLE — path thật do IDE inject]
                              ↑ AI đọc workspace này
  AI đọc: D:\Projects\GarageERP\FE-Web\.agent\GEMINI.md   ← [EXAMPLE]
    BA_ROOT:       D:\Projects\GarageERP\BA
    PIPELINE_ROOT: D:\Projects\GarageERP\ai-pipeline

  → AI sẽ đọc guide từ: D:\Projects\GarageERP\ai-pipeline\guides\
  → AI sẽ đọc standards từ: D:\Projects\GarageERP\BA\.agent\...
  → Hoàn toàn tách biệt với HoaiMinhERP ✅
```

### Giới Hạn Hiện Tại: Skills Có Nội Dung Cứng

Một số skills viết cứng tên dự án Hoài Minh — đây là giới hạn cần biết:

| Loại content trong skill | Portable? | Giải pháp |
|--------------------------|-----------|----------|
| `{BA_ROOT}`, `{PIPELINE_ROOT}` | ✅ Portable | Chỉ đổi GEMINI.md |
| Tên skill folder `hoaiminh-domain` | ✅ Portable | Skill chỉ là folder name trong workspace |
| DB table names `tbl_SYSFunction` | ❌ Hardcoded | Cần clone + sửa skills cho dự án mới |
| Component tags `ps-kendo-grid` | ❌ Hardcoded | Chỉ đúng nếu dùng cùng UI library |
| DLL namespace pattern | ❌ Hardcoded | Cần sửa nếu kiến trúc BE khác |

### Quy Trình Setup Dự Án Mới (30 phút)

```
Bước 1: Clone 4 workspace repos về máy/server
Bước 2: Copy thư mục .agent/ từ project tương tự (HoaiMinhERP)
Bước 3: Cập nhật GEMINI.md (chỉ 4 files) → thay PIPELINE_ROOT + BA_ROOT
Bước 4: Thay domain-specific content trong skills:
         - hoaiminh-domain/ → rename + update domain knowledge
         - be-pipeline SKILL.md → update DB table names, API patterns
         - fe-pipeline SKILL.md → update DLL namespace, component selectors
Bước 5: Tạo pipeline folder mới với 2 subfolder: requirements/ guides/
Bước 6: Test: gõ /ba-analyst với 1 req đơn giản → verify AI tìm đúng file
```

### Checklist Multi-Project (In Ra Giữ)

```
□ Mỗi dự án có pipeline folder RIÊNG (không share giữa dự án)
□ Mỗi workspace có .agent/GEMINI.md với WORKSPACE_MAP đúng
□ BA_ROOT trỏ đúng BA workspace của DỰ ÁN ĐÓ (không phải dự án khác)
□ PIPELINE_ROOT trỏ đúng pipeline folder của DỰ ÁN ĐÓ
□ Khi làm việc: mở đúng workspace trong IDE (không mở nhầm workspace dự án khác)
□ Không bao giờ share pipeline folder giữa 2 dự án khác nhau
```

---

## 1. 🗺️ Tổng Quan Hệ Thống

### 4 Workspace = 4 Nhân Viên AI

| Nhân viên | Workspace | Stack | Vai trò |
|-----------|-----------|-------|---------| 
| **BA** | `{BA workspace}` | Markdown + Figma MCP | Phân tích yêu cầu → tạo SRS → tạo guide |
| **BE** | `{BE workspace}` | .NET 10 LTS + C# 14 + EF Core | Code API handlers theo guide |
| **FE Web** | `{FE Web workspace}` | Angular 16 + Kendo UI 13 | Code Angular desktop components |
| **FE Mobile** | `{FE Mobile workspace}` | Angular 16 + Kendo UI 13 (mobile) | Code Angular mobile components |

### Shared Infrastructure

```
{PIPELINE_ROOT}\                 ← Thư mục chia sẻ giữa 4 workspace
├── requirements\                ← SRS documents (BA output)
│   └── REQ_001_Receipt.md       ← Ví dụ
├── guides\                      ← Implementation guides (BA output)
│   ├── BE_001_Receipt.md        ← BE đọc file này
│   ├── FE_WEB_001_Receipt.md    ← FE Web đọc file này
│   └── FE_MOBWEB_001_Receipt.md ← FE Mobile đọc file này
```

> ⚠️ `{PIPELINE_ROOT}` là biến — path thật nằm trong GEMINI.md mỗi workspace.

---

## 2. 🚀 Full Pipeline A→Z

### Quy Trình Hoàn Chỉnh Từ Yêu Cầu → Code

```
                    ┌──────────────────────────────────┐
                    │   📝 CUỘC HỌP KHÁCH HÀNG        │
                    │   (Ghi lại notes, yêu cầu)      │
                    └──────────────┬───────────────────┘
                                   │
                    ┌──────────────▼───────────────────┐
       BƯỚC 1      │   🏢 BA Workspace                │
                    │   /clean-requirement              │
                    │   Notes → SRS chuẩn IEEE 29148   │
                    │   Output: {PIPELINE_ROOT}\requirements\REQ_*.md
                    └──────────────┬───────────────────┘
                                   │
                    ┌──────────────▼───────────────────┐
       BƯỚC 2      │   🏢 BA Workspace                │
                    │   /ba-analyst [REQ_xxx]           │
                    │   SRS + Figma → phân tích        │
                    │   Output: BE_*.md + FE_WEB_*.md + FE_MOBWEB_*.md
                    └──────────┬───┬───┬───────────────┘
                               │   │   │
              ┌────────────────┘   │   └────────────────┐
              ▼                    ▼                     ▼
  ┌───────────────────┐ ┌─────────────────┐ ┌───────────────────────┐
  │  🔧 BE Workspace  │ │ 🎨 FE Web WS   │ │ 📱 FE Mobile WS      │
  │  /be-implement     │ │ /fe-implement    │ │ /fe-mobile-implement  │
  │  BE_*.md → .cs     │ │ FE_WEB_*.md     │ │ FE_MOBWEB_*.md        │
  │                    │ │ → .ts/.html/.scss│ │ → .ts/.html/.scss     │
  └────────┬───────────┘ └────────┬────────┘ └────────┬──────────────┘
           │                      │                    │
  BƯỚC 3   ▼                      ▼                    ▼
  ┌───────────────────┐ ┌─────────────────┐ ┌───────────────────────┐
  │  /review Receipt   │ │ /review receipt  │ │ (review manual)       │
  └────────┬───────────┘ └────────┬────────┘ └───────────────────────┘
           │                      │
  BƯỚC 4   ▼                      ▼
  ┌───────────────────┐ ┌─────────────────┐
  │  /enhance sửa X    │ │ /enhance fix Y   │
  └────────┬───────────┘ └─────────────────┘
           │
  BƯỚC 5   ▼
  ┌───────────────────┐
  │  /test Receipt     │
  └────────┬───────────┘
           │
  BƯỚC 6   ▼
  ┌───────────────────────────────┐
  │  🏢 BA Workspace              │
  │  /memorize Receipt            │  ← Lưu memory vĩnh viễn
  │  /clean-pipeline Receipt      │  ← Xóa SRS + guides đã xong
  └───────────────────────────────┘
```

### Bảng Tóm Tắt Pipeline

| Bước | Command | Chạy tại | Input | Output |
|------|---------|----------|-------|--------|
| 1 | `/clean-requirement` | BA | Meeting notes | `REQ_*.md` trong `{PIPELINE_ROOT}\requirements\` |
| 2 | `/ba-analyst` | BA | `REQ_*.md` + Figma MCP | `BE_*.md` + `FE_WEB_*.md` + `FE_MOBWEB_*.md` |
| 3 | `/be-implement` | BE | `BE_*.md` | Handlers `.cs` |
| 3 | `/fe-implement` | FE Web | `FE_WEB_*.md` | Components `.ts/.html/.scss` |
| 3 | `/fe-mobile-implement` | FE Mobile | `FE_MOBWEB_*.md` | Components `.ts/.html/.scss` |
| 4 | `/review [feature]` | BE / FE Web | Source code | Review report |
| 5 | `/enhance [description]` | BE / FE Web | Review report | Fixed code |
| 6 | `/test [feature]` | BE | Handlers | xUnit tests |
| 7 | `/memorize [feature]` | BA | All code + guides | Memory file `.md` |
| 8 | `/clean-pipeline [feature]` | BA | — | Xóa files đã xong |

---

## 3. 🏢 Nhân Viên 1: BA — Business Analyst

> **Workspace:** BA workspace
> **Mở cách nào:** Mở Gemini Code Assist / Antigravity tại folder BA

### Danh Sách Workflows

| Command | Mục đích | Khi nào dùng |
|---------|---------|--------------|
| `/clean-requirement` | Notes → SRS chuẩn 7-Pillar | Sau cuộc họp khách hàng |
| `/ba-analyst` | SRS + Figma → BE + FE guides | Sau khi có SRS |
| `/figma-variables` | Sync design tokens Figma ↔ SCSS | Khi design system thay đổi |
| `/memorize [feature]` | Chưng cất memory từ code + guides | SAU KHI feature đã code xong |
| `/clean-pipeline [feature]` | Xóa SRS + guides đã xong | SAU KHI đã /memorize |

### Danh Sách Skills

| Skill | Chức năng |
|-------|----------|
| `ba-pipeline` | Engine phân tích SRS + Figma → guides |
| `clean-requirement` | Template SRS 7-Pillar (IEEE 29148) |
| `figma-reader` | Đọc Figma MCP live design |
| `hoaiminh-domain` | Domain knowledge Honda HEAD |
| `memorize` | Chưng cất code → memory file |

---

## 4. 🔧 Nhân Viên 2: BE — Backend Developer

> **Workspace:** BE workspace
> **Stack:** .NET 10 LTS + C# 14 + EF Core 10 + HybridCache
> **Architecture:** VSA (Vertical Slice Architecture) + CQRS

### Danh Sách Workflows

| Command | Mục đích | Khi nào dùng |
|---------|---------|--------------|
| `/be-implement` | Đọc `BE_*.md` guide → code handlers | Có guide từ BA |
| `/review [feature]` | Audit code theo coding standard | Sau implement |
| `/enhance [description]` | Fix lỗi cụ thể | Review phát hiện lỗi |
| `/test [feature]` | Generate + run xUnit tests | Sau review |
| `/debug [issue]` | Điều tra bug | API 500, logic sai |

### Danh Sách Skills

| Skill | Chức năng |
|-------|----------|
| `be-pipeline` | 🔴 CORE — Pattern VSA, CQRS, API naming, DB registration |
| `clean-code` | Clean code principles |
| `code-review-checklist` | Checklist review code |
| `hoaiminh-domain` | Domain knowledge (redirect → BA via `{BA_ROOT}`) |
| `testing-patterns` | xUnit test patterns |

---

## 5. 🎨 Nhân Viên 3: FE Web — Frontend Web Developer

> **Workspace:** FE Web workspace
> **Stack:** Angular 16 + Kendo UI 13 + PS Wrapper Components
> **Design Source:** Figma MCP (live) + SCSS variables

### Danh Sách Workflows

| Command | Mục đích | Khi nào dùng |
|---------|---------|--------------|
| `/fe-implement` | Đọc `FE_WEB_*.md` guide → code Angular component | Có guide từ BA |
| `/review [feature]` | Audit FE code (KHÔNG sửa) | Sau implement |
| `/enhance [description]` | Fix lỗi FE | Review phát hiện lỗi |

### Danh Sách Skills

| Skill | Chức năng |
|-------|----------|
| `fe-pipeline` | 🔴 CORE — DLL namespace chain, API integration, color system, placement rules |
| `figma-reader` | Đọc Figma MCP live → extract colors, layout |
| `hoaiminh-domain` | Domain knowledge + local `12-fe-coding-standards.md` |
| `code-review-checklist` | FE code review checklist |

---

## 6. 📱 Nhân Viên 4: FE Mobile — Frontend Mobile Developer

> **Workspace:** FE Mobile workspace
> **Stack:** Angular 16 + Kendo UI 13 (mobile-optimized)
> **⚠️ ĐÂY LÀ ANGULAR WEB TRÊN MOBILE BROWSER — KHÔNG PHẢI React Native!**

### Điểm Khác Biệt Desktop vs Mobile

| | FE Web (Desktop) | FE Mobile |
|--|-----------------|-----------|
| **Guide file** | `FE_WEB_*.md` | `FE_MOBWEB_*.md` |
| **DB Product** | `Product = 1` | `Product = 3` |
| **Pagination** | Kendo Grid paging | IntersectionObserver infinite scroll |
| **Data table** | `<ps-kendo-grid>` | `*ngFor` card list |
| **ChangeDetection** | Default | `OnPush` + `cdr.markForCheck()` |
| **API response** | `res.ObjectReturn.Data` / `.Total` | `res.ObjectReturn` (direct array) |
| **Pipe module** | `shared.module.ts` | `ps-pipe.module.ts` |

---

## 7. 🔧 Shared Skills (Dùng Chung)

| Skill | Có ở | Chức năng |
|-------|------|----------|
| `clean-code` | BE, FE Web, Mobile | Nguyên tắc clean code |
| `code-review-checklist` | BE, FE Web | Checklist kiểm tra code |
| `behavioral-modes` | BE, FE Web | 3 modes: IMPLEMENT, REVIEW, DEBUG |
| `testing-patterns` | BE, FE Web, Mobile | Test patterns |
| `hoaiminh-domain` | Tất cả | Redirect → BA workspace via `{BA_ROOT}` |
| `figma-reader` | BA, FE Web | Đọc Figma MCP live design |

---

## 8. 🆘 Xử Lý Tình Huống

| Tình huống | Workspace | Command |
|------------|-----------|---------|
| Nhận yêu cầu mới | BA | `/clean-requirement` |
| Tạo guides cho dev | BA | `/ba-analyst REQ_001_xxx` |
| Implement BE | BE | `/be-implement` |
| Implement FE Web | FE Web | `/fe-implement` |
| Implement FE Mobile | FE Mobile | `/fe-mobile-implement` |
| Code build lỗi | BE hoặc FE | `/enhance fix build error: [error]` |
| UI không khớp Figma | FE Web | `/enhance fix mtb013 to match Figma` |
| Review trước merge | BE hoặc FE | `/review [feature]` |
| API 500 | BE | `/debug API GetListXxx trả 500` |
| Feature xong, dọn dẹp | BA | `/memorize [feature]` rồi `/clean-pipeline [feature]` |
| Sync design tokens | BA | `/figma-variables` |

---

## 9. ⭐ Quy Tắc Vàng

### Cho Mọi Workspace

| # | Quy tắc | Vi phạm = |
|---|---------|-----------| 
| 1 | **Mỗi workspace = 1 vai trò.** BA không code. BE không làm FE. | Sai scope |
| 2 | **Guide file là source of truth.** Không tự bịa business logic. | Sai nghiệp vụ |
| 3 | **Build PHẢI pass.** Không báo "xong" khi còn errors. | Immediate reject |
| 4 | **Không tạo file rác.** Cấm .txt, .log, INSTRUCTIONS.md | Pollute project |
| 5 | **Đọc reference trước khi code.** Không tự bịa component tags. | Compile errors |
| 6 | **Path dùng biến `{BA_ROOT}`, `{PIPELINE_ROOT}`.** KHÔNG hardcode. | Broken khi đổi máy |

### Cho FE Web & Mobile

| # | Quy tắc |
|---|---------|
| 1 | **Pipe, DTO, Enum KHÔNG được tạo trong view folder** — phải vào `pipes/e-style/`, `models/dtos/e-dtos/`, `models/enums/` |
| 2 | DLL namespace chain PHẢI khớp: DB → Static → API → Component |
| 3 | CẤM hardcode hex color — dùng SCSS `$primary`, `$error`, ... |
| 4 | CẤM magic number — dùng enum |
| 5 | Scan DTOs + enums trước — REUSE nếu có |

---

## 10. ⚠️ Lỗi Thường Gặp

### BA

| Lỗi | Giải pháp |
|-----|-----------|
| `/clean-pipeline` trước `/memorize` | Memory mất! Phải memorize TRƯỚC |
| Figma không kết nối | Mở Figma Desktop → chạy MCP plugin → thử lại |
| Guide file tên sai | Phải là `FE_WEB_*` / `FE_MOBWEB_*` / `BE_*` |

### BE

| Lỗi | Giải pháp |
|-----|-----------|
| 500 error sau implement | Kiểm tra DLL namespace chain → DB `tbl_SYSFunction.DLLPackage` |
| Data leak giữa chi nhánh | Thiếu `WHERE Head = currentUser.HeadCode` |
| `ICacheService` not found | Đổi sang `HybridCache` (.NET 10 standard) |

### FE Web

| Lỗi | Giải pháp |
|-----|-----------|
| Component không hiện | Thiếu đăng ký 1/6 files (module, routing, static, api, router, storage) |
| Grid không load data | DLL namespace mismatch |
| Pipe không hoạt động | Pipe bị tạo trong view folder thay vì `pipes/e-style/` + chưa khai báo `shared.module.ts` |

### FE Mobile

| Lỗi | Giải pháp |
|-----|-----------|
| Data load nhưng UI không update | Thiếu `cdr.markForCheck()` (OnPush strategy) |
| API invisible trên mobile | DB `Product` phải = 3, không phải 1 |
| Pipe không hoạt động | Pipe chưa khai báo trong `ps-pipe.module.ts` |

---

> 📌 **Cập nhật document này khi có skill/workflow mới.** Đây là tài liệu sống, không phải viết xong rồi quên!
> 📌 **Source file:** `{BA_ROOT}\.agent\projects\hoaiminh\standards\encyclopedia.md`
