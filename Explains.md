# Explains.md — Giải thích chi tiết thư mục `sql/`

> Tài liệu dành cho sinh viên năm 2 đã biết SQL cơ bản (`CREATE TABLE`, `SELECT`, `JOIN`) nhưng chưa quen đọc một script CSDL hoàn chỉnh.
> **Dự án:** BT_CSDL — Đề tài 13: Nhà hàng / quán cà phê · SQL Server 2025 · CSDL `QL_CAFE_NHAHANG`
> **Tài liệu liên quan:** [Readme.md](Readme.md) (đề bài) · [WORKING.md](WORKING.md) (quy trình làm việc nhóm) · [Explain_TLDR.md](Explain_TLDR.md) (bản tóm tắt)

---

## Mục lục

1. [Mục đích và phạm vi tài liệu](#1-mục-đích-và-phạm-vi-tài-liệu)
2. [Cách đọc tài liệu này](#2-cách-đọc-tài-liệu-này)
3. [Tổng quan thư mục `sql/`](#3-tổng-quan-thư-mục-sql)
4. [Thứ tự thực thi và quan hệ phụ thuộc](#4-thứ-tự-thực-thi-và-quan-hệ-phụ-thuộc)
5. [File `sql/01_CAUHINH_CSDL.sql`](#5-file-sql01_cauhinh_csdlsql)
6. [File `sql/02_Bang.sql`](#6-file-sql02_bangsql)
7. [Dữ liệu mẫu nằm ngoài `sql/` — thư mục `scripts/`](#7-dữ-liệu-mẫu-nằm-ngoài-sql--thư-mục-scripts)
8. [Những điểm thiết kế cần hiểu trước khi sửa](#8-những-điểm-thiết-kế-cần-hiểu-trước-khi-sửa)
9. [Câu hỏi tự kiểm tra](#9-câu-hỏi-tự-kiểm-tra)
10. [Điều chưa xác định hoặc chưa kiểm chứng](#10-điều-chưa-xác-định-hoặc-chưa-kiểm-chứng)

---

## 1. Mục đích và phạm vi tài liệu

Tài liệu này giải thích **từng file trong thư mục `sql/`** của dự án: nó dùng để làm gì, chạy khi nào, tạo ra đối tượng gì, các ràng buộc có ý nghĩa gì, và điều gì sẽ hỏng nếu bạn sửa sai.

Phạm vi:

| Trong phạm vi | Ngoài phạm vi |
|---|---|
| Toàn bộ file và thư mục con của `sql/` (hiện có 2 file, không có thư mục con) | Truy vấn, view, thủ tục, trigger — **chưa tồn tại trong repo** |
| Thư mục `scripts/` — giải thích ở mức tổng quan, vì đây là phần "dữ liệu mẫu" của cùng một chuỗi chạy (mục 7) | Báo cáo, file PowerDesigner `.cdm`/`.pdm` — **chưa có** |
| Cấu trúc CSDL và ràng buộc | Quy trình làm việc Git — xem [WORKING.md](WORKING.md) |

---

## 2. Cách đọc tài liệu này

### 2.1. Hai nhãn thông tin

| Nhãn | Nghĩa |
|---|---|
| **Đã kiểm tra** | Đọc trực tiếp từ file trong repo, hoặc kiểm tra trên máy khảo sát |
| **Suy luận** | Là kết luận hợp lý từ code, nhưng file không ghi rõ ý đồ của tác giả |
| **Chưa kiểm chứng** | Chưa chạy thử, chưa quan sát được kết quả thực tế |

> ⚠️ **Trạng thái kiểm chứng (cập nhật 26/10/2026):** `02_Bang.sql`, `03a_DanhMuc.sql`, `03b_GiaoDich.sql`, `04_TEST_VI_PHAM.sql` **đã được chạy thật** trên SQL Server 2025 (17.0.1000.7) trong một CSDL tạm `QL_CAFE_TEST` — cả 4 chạy không lỗi, các con số ở mục 6.10 và 7 là **kết quả đo**, không còn là suy luận. Riêng `01_CAUHINH_CSDL.sql` **chưa chạy** vì nó `DROP DATABASE` CSDL thật đang dùng. CSDL `QL_CAFE_NHAHANG` trên máy vẫn giữ nguyên dữ liệu cũ (1.500 hóa đơn / 5.000 chi tiết — bản `03b` trước khi sửa).

### 2.2. Cách đọc một script SQL dài

Khi mở một file `.sql` dài, đừng đọc từng dòng từ trên xuống. Đọc theo thứ tự sau:

1. **Đọc comment đầu file** — thường nói rõ file làm gì, chạy trên CSDL nào.
2. **Tìm `USE` và `GO`** — biết ngữ cảnh CSDL và ranh giới các lô lệnh (batch).
3. **Liệt kê các `CREATE`/`ALTER`/`INSERT`** — đó là danh sách đối tượng sẽ sinh ra.
4. **Đọc `BEGIN TRY ... COMMIT ... CATCH`** — biết toàn bộ khối có phải một đơn vị nguyên tử không.
5. **Đọc phần kiểm tra ở cuối** — đó là "bài test" sẵn có của tác giả.

Tài liệu này đi theo đúng thứ tự đó.

---

## 3. Tổng quan thư mục `sql/`

### 3.1. Cây thư mục (đã kiểm tra)

```text
sql/
├── 01_CAUHINH_CSDL.sql     29 dòng  → Tạo CSDL, cấu hình file dữ liệu và file log
└── 02_Bang.sql            151 dòng  → Tạo 10 bảng, khóa, ràng buộc, chỉ mục
```

Thư mục `sql/` **không có thư mục con** và **không có file nào khác**.

### 3.2. Quan hệ giữa `sql/` và `scripts/`

Đây là điểm dễ nhầm nhất khi mới xem repo:

| Thư mục | Chứa gì | Vai trò |
|---|---|---|
| `sql/` | `01_CAUHINH_CSDL.sql`, `02_Bang.sql` | **Cấu trúc** — tạo CSDL rỗng và các bảng |
| `scripts/` | `03a_DanhMuc.sql`, `03b_GiaoDich.sql`, `04_TEST_VI_PHAM.sql` (+ `03_RESET_DB.sql` tiện ích) | **Nội dung** — đổ dữ liệu mẫu, minh họa DML, kiểm chứng ràng buộc |

Các file trên thuộc **cùng một chuỗi chạy liên tục**; dữ liệu không chạy được nếu chưa có bảng.

> **Hiện trạng:** Readme mục 3.10 quy định bộ script nộp bài tên `01_CSDL`, `02_Bang`, `03_DuLieu`, `04_TruyVan_View`, `05_ThuTuc_Ham`, `06_Trigger_GiaoTac`, `07_PhanQuyen_SaoLuu`, `08_ToiUu`. Repo đã đưa dữ liệu về đúng số `03` nhưng **tách làm 2 file** (`03a_DanhMuc` + `03b_GiaoDich`) và dùng thêm `04_TEST_VI_PHAM` — trùng số với `04_TruyVan_View` trong Readme. Nhóm cần chốt cách đánh số cuối cùng (xem [WORKING.md](WORKING.md) mục 14).

### 3.3. Điều kiện tiên quyết

| Điều kiện | Chi tiết | Trạng thái |
|---|---|---|
| Hệ quản trị | SQL Server 2016 trở lên (do dùng `DROP TABLE IF EXISTS`) | Máy khảo sát: instance `MSSQLSERVER` `17.0.1000.7` (SQL Server 2025), dịch vụ đang chạy |
| Quyền | Tài khoản phải có `CREATE DATABASE` và `DROP DATABASE` | **Chưa kiểm chứng** quyền của tài khoản sẽ dùng |
| Thư mục | `C:\SQLData` phải tồn tại | Máy khảo sát: **đã có** |
| Công cụ | SSMS, hoặc `sqlcmd` | Trên `PATH` của máy khảo sát **không có** `sqlcmd` |
| Mã hóa file | UTF-8 không BOM, CRLF | Đã kiểm tra: cả 4 file `.sql` đúng như vậy |

---

## 4. Thứ tự thực thi và quan hệ phụ thuộc

### 4.1. Thứ tự bắt buộc

```text
┌────────────────────────────────┐
│ 1. sql/01_CAUHINH_CSDL.sql     │  Tạo CSDL rỗng QL_CAFE_NHAHANG
└───────────────┬────────────────┘
                ▼
┌────────────────────────────────┐
│ 2. sql/02_Bang.sql             │  Tạo 10 bảng + ràng buộc + chỉ mục
└───────────────┬────────────────┘
                ▼
┌────────────────────────────────┐
│ 3. scripts/03a_DanhMuc.sql     │  Nạp danh mục: 11 loại, 15 bàn, 12 NV,
│                                │  28 NL, 36 món, 18+18 chuyên biệt, 130 định lượng
└───────────────┬────────────────┘
                ▼
┌────────────────────────────────┐
│ 4. scripts/03b_GiaoDich.sql    │  1.500 hóa đơn + ≈5.300 chi tiết, tính TongTien,
│                                │  minh họa INSERT/UPDATE/DELETE
└───────────────┬────────────────┘
                ▼
┌────────────────────────────────┐
│ 5. scripts/04_TEST_VI_PHAM.sql │  (tùy chọn) 10 lệnh sai → phải bị chặn 10/10
└────────────────────────────────┘
```

### 4.2. Vì sao không được đảo thứ tự

| Script | Phụ thuộc gì | Lỗi nếu chạy sai thứ tự |
|---|---|---|
| `02_Bang.sql` | CSDL `QL_CAFE_NHAHANG` phải tồn tại (dòng 1: `USE QL_CAFE_NHAHANG;`) | `Cannot open database "QL_CAFE_NHAHANG" requested by the login` |
| `03a_DanhMuc.sql` | 10 bảng đã tồn tại **và đang rỗng** (`IDENTITY` bắt đầu từ 1) | Vi phạm khóa chính/khóa ngoại, hoặc dữ liệu tham chiếu trỏ sang món khác |
| `03b_GiaoDich.sql` | Dữ liệu danh mục đã có, đặc biệt: ≥1 nhân viên `PhucVu`, ≥1 món `DangBan = 1`, bảng `Ban` không rỗng | `THROW 50001` / `50002` / `50003` — script tự dừng |
| `04_TEST_VI_PHAM.sql` | `03b` đã nạp xong (cần dữ liệu thật để thử trùng khóa) | `THROW 51001` — script tự dừng |

### 4.3. Phụ thuộc ẩn quan trọng nhất: `MaMon` cứng

Trong `scripts/03a_DanhMuc.sql`, các bảng con dùng **số cứng**:

- `MonAn` → `MaMon` từ **1 đến 18**
- `ThucUong` → `MaMon` từ **19 đến 36**
- `DinhLuong` → tham chiếu `MaMon` 1..36 và `MaNL` 1..28

Nghĩa là: dòng `ThucUong` số 19 giả định `Mon` có `MaMon = 19` là "Cà phê đen đá". Điều này **chỉ đúng khi bảng `Mon` đang rỗng lúc nạp** (vì `Mon.MaMon` là `IDENTITY(1,1)`).

> **Quy tắc rút ra:** dữ liệu mẫu chỉ được nạp trên CSDL **vừa được tạo lại từ đầu**. Nếu bạn `DELETE` một món rồi `INSERT` lại, `MaMon` mới sẽ là 37 — toàn bộ `DinhLuong` của món đó trỏ sai.

### 4.4. Các bước thực thi cụ thể

**Cách 1 — SQL Server Management Studio (SSMS):**

1. `File` → `Open` → `File…` → chọn `sql/01_CAUHINH_CSDL.sql`.
2. Kiểm tra thanh trạng thái / ô chọn database: với file `01`, **không cần** chọn CSDL (script tự `USE master`).
3. Nhấn `Execute` (F5).
4. Lặp lại với `02_Bang.sql`, rồi `scripts/03a_DanhMuc.sql`, `scripts/03b_GiaoDich.sql` — **đúng thứ tự**.
5. Với file `02_Bang.sql` và các file seed: chọn đúng database `QL_CAFE_NHAHANG` ở dropdown (dù script đã có `USE`, chọn đúng giúp tránh lỗi khi mở nhầm file).

**Cách 2 — `sqlcmd` (dòng lệnh):**

```bat
sqlcmd -S localhost -E -f 65001 -i sql\01_CAUHINH_CSDL.sql
sqlcmd -S localhost -E -f 65001 -i sql\02_Bang.sql
sqlcmd -S localhost -E -f 65001 -i scripts\03a_DanhMuc.sql
sqlcmd -S localhost -E -f 65001 -i scripts\03b_GiaoDich.sql
```

Giải thích từng tham số:

- `-S localhost`: tên server.
- `-E`: dùng Windows Authentication (đăng nhập bằng tài khoản Windows hiện tại).
- `-f 65001`: **bắt buộc** — khai báo file vào là UTF-8. Thiếu tham số này, `sqlcmd` đọc theo code page của Windows và **toàn bộ tiếng Việt sẽ hỏng**, khiến các `CHECK` so sánh chuỗi từ chối dữ liệu đúng.
- `-i <file>`: file input.

> **Hiện trạng máy khảo sát:** `sqlcmd` không có trên `PATH`. Muốn dùng cách 2, phải gọi bằng đường dẫn đầy đủ (ví dụ `C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\...\sqlcmd.exe`) hoặc thêm vào `PATH`.

---

## 5. File `sql/01_CAUHINH_CSDL.sql`

### 5.1. Mục đích

Tạo ra **một CSDL rỗng** tên `QL_CAFE_NHAHANG`, có cấu hình file dữ liệu và file log rõ ràng, với collation tiếng Việt.

Đây là script **đầu tiên** phải chạy. Nó không tạo bảng nào — chỉ tạo "cái thùng chứa".

### 5.2. Giải thích từng phần

File có 29 dòng, chia làm 4 phần logic:

#### Phần 1 — Chuyển sang `master` (dòng 1–2)

```sql
USE master;
GO
```

- `USE master` chuyển ngữ cảnh làm việc sang CSDL hệ thống `master`.
- **Vì sao phải làm vậy:** không thể `DROP DATABASE` một CSDL trong khi chính bạn đang đứng trong nó. Nếu đang `USE QL_CAFE_NHAHANG` mà chạy `DROP DATABASE QL_CAFE_NHAHANG`, SQL Server sẽ báo lỗi.
- `GO` là **lệnh của công cụ** (SSMS/`sqlcmd`), **không phải câu lệnh T-SQL**. Nó chia script thành từng "lô" (batch) và gửi lần lượt. Biến khai báo trong một lô **không** nhìn thấy được ở lô sau — đây là lý do các script dùng `GO` ở những chỗ rất cụ thể.

#### Phần 2 — Xóa CSDL cũ nếu đã tồn tại (dòng 4–9)

```sql
IF DB_ID(N'QL_CAFE_NHAHANG') IS NOT NULL
BEGIN
    ALTER DATABASE QL_CAFE_NHAHANG SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QL_CAFE_NHAHANG;
END
GO
```

Ba câu này là phần **nguy hiểm nhất** của cả file:

| Câu lệnh | Việc gì | Hệ quả |
|---|---|---|
| `DB_ID(N'...') IS NOT NULL` | Kiểm tra CSDL có tồn tại không | Trả về mã ID hoặc `NULL` |
| `SET SINGLE_USER WITH ROLLBACK IMMEDIATE` | Ép CSDL chỉ còn 1 kết nối, **ngắt ngay** mọi kết nối khác | Mọi giao dịch đang chạy bị **rollback**, người khác đang kết nối bị **đá ra** |
| `DROP DATABASE` | Xóa CSDL | **Mất toàn bộ** bảng và dữ liệu, không hoàn tác được |

> 🔴 **Rủi ro: mất dữ liệu vĩnh viễn.** Chạy script này trong khi có ai đang demo hoặc đang chạy thử sẽ làm hỏng việc của họ ngay lập tức. Hãy nhắn nhóm trước.
>
> Kỹ thuật `SINGLE_USER WITH ROLLBACK IMMEDIATE` là **mẹo chuẩn** để `DROP DATABASE` không bị chặn bởi kết nối còn mở (lỗi thường gặp: *"Cannot drop database because it is currently in use"*). Đây là lý do nó xuất hiện ở đây, không phải để "cho oai".

#### Phần 3 — Tạo CSDL với cấu hình file (dòng 11–28)

```sql
CREATE DATABASE QL_CAFE_NHAHANG
ON PRIMARY
(
    NAME       = N'QL_CAFE_Data',
    FILENAME   = N'C:\SQLData\QL_CAFE_NHAHANG.mdf',
    SIZE       = 50MB,
    MAXSIZE    = 500MB,
    FILEGROWTH = 10MB
)
LOG ON
(
    NAME       = N'QL_CAFE_Log',
    FILENAME   = N'C:\SQLData\QL_CAFE_NHAHANG_log.ldf',
    SIZE       = 20MB,
    MAXSIZE    = 200MB,
    FILEGROWTH = 10MB
)
COLLATE Vietnamese_CI_AS;
GO
```

Cấu trúc: một CSDL gồm **ít nhất hai file** — file dữ liệu (`.mdf`) và file log (`.ldf`).

| Tham số | Ý nghĩa | Giá trị trong dự án |
|---|---|---|
| `NAME` | Tên logic của file **bên trong** SQL Server | `QL_CAFE_Data`, `QL_CAFE_Log` |
| `FILENAME` | Đường dẫn vật lý trên đĩa | `C:\SQLData\...` |
| `SIZE` | Kích thước ban đầu | 50MB (dữ liệu), 20MB (log) |
| `MAXSIZE` | Kích thước tối đa | 500MB / 200MB |
| `FILEGROWTH` | Mỗi lần tự mở rộng thì thêm bao nhiêu | 10MB |

**Vì sao cần đặt `SIZE`/`MAXSIZE`/`FILEGROWTH` thay vì để mặc định?** Vì mặc định thường là *tự tăng theo tỉ lệ phần trăm*, khi CSDL lớn dần thì mỗi lần tăng lại chiếm một khối lớn → gây giật và phân mảnh. Đặt cố định theo MB là thực hành tốt, và đây cũng là yêu cầu của Readme mục 3.2 ("cấu hình file dữ liệu và file log rõ ràng").

**`MAXSIZE = 500MB` là một giới hạn thật.** Với dự án này (1.500 hóa đơn) dung lượng rất nhỏ, nhưng nếu sau này chèn hàng triệu dòng, CSDL sẽ báo lỗi *"The database ... has reached its maximum size"*.

**`COLLATE Vietnamese_CI_AS`** — đây là điểm rất dễ bị bỏ qua nhưng ảnh hưởng đến **mọi so sánh chuỗi** trong CSDL:

| Hậu tố | Nghĩa |
|---|---|
| `CI` | Case-insensitive: **không** phân biệt hoa/thường |
| `AS` | Accent-sensitive: **có** phân biệt dấu |

Hệ quả cụ thể:

```sql
-- So sánh 1: chỉ khác hoa/thường → ĐƯỢC coi là BẰNG nhau
WHERE TrangThai = N'có khách'    -- ✅ khớp N'Có khách'

-- So sánh 2: khác dấu → KHÔNG bằng nhau
WHERE TrangThai = N'co khach'    -- ❌ KHÔNG khớp N'Có khách'

-- Hệ quả với UNIQUE:
-- N'Bàn 01' và N'bàn 01' bị coi là TRÙNG → vi phạm UQ_Ban_Ten
-- N'Bàn 01' và N'Ban 01' là KHÁC nhau → không vi phạm
```

Điều này giải thích vì sao mọi chuỗi tiếng Việt trong repo đều viết dạng `N'...'` (tiền tố `N` = Unicode) và **đúng dấu**. Nếu bạn gõ thiếu dấu, dữ liệu sẽ bị `CHECK` constraint từ chối — đó là hệ thống bảo vệ đúng, không phải lỗi.

### 5.3. Bảng tham số cấu hình

| Hạng mục | Giá trị |
|---|---|
| Tên CSDL | `QL_CAFE_NHAHANG` |
| Tên logic file dữ liệu | `QL_CAFE_Data` |
| Đường dẫn file dữ liệu | `C:\SQLData\QL_CAFE_NHAHANG.mdf` |
| Kích thước đầu / tối đa / bước tăng | 50MB / 500MB / 10MB |
| Tên logic file log | `QL_CAFE_Log` |
| Đường dẫn file log | `C:\SQLData\QL_CAFE_NHAHANG_log.ldf` |
| Kích thước đầu / tối đa / bước tăng | 20MB / 200MB / 10MB |
| Collation | `Vietnamese_CI_AS` |

### 5.4. Kết quả mong đợi

Sau khi chạy thành công:

- Trong `Object Explorer` xuất hiện database `QL_CAFE_NHAHANG`.
- Hai file `C:\SQLData\QL_CAFE_NHAHANG.mdf` và `QL_CAFE_NHAHANG_log.ldf` được tạo.
- **Không có bảng nào** (0 bảng) — đây là CSDL rỗng.
- Nếu chạy lại: CSDL cũ bị xóa và tạo lại rỗng, **mọi dữ liệu cũ mất hết**.

Kiểm tra nhanh sau khi chạy:

```sql
SELECT name, physical_name, size * 8 / 1024 AS SizeMB
FROM sys.master_files
WHERE database_id = DB_ID(N'QL_CAFE_NHAHANG');
```

### 5.5. Rủi ro

| Rủi ro | Mức | Cách phòng |
|---|---|---|
| **Xóa mất CSDL đang dùng** | 🔴 Cao | Nhắn nhóm trước; sao lưu nếu có dữ liệu quan trọng |
| **Đá người khác ra khỏi CSDL** (`ROLLBACK IMMEDIATE`) | 🟠 Trung bình | Không chạy khi người khác đang demo |
| **Thiếu thư mục `C:\SQLData`** | 🟠 Trung bình | Tạo thư mục bằng quyền Administrator; **không sửa đường dẫn rồi commit** |
| **Thiếu quyền `CREATE DATABASE`** | 🟠 Trung bình | Dùng tài khoản có quyền `sysadmin` hoặc `dbcreator` |
| **Sai collation** | 🟡 Thấp nhưng khó sửa về sau | Không đổi `COLLATE`; nếu buộc phải đổi, đó là quyết định của cả nhóm |

Lỗi hay gặp khi chạy file này:

```text
Directory lookup for the file "C:\SQLData\QL_CAFE_NHAHANG.mdf" failed
with the operating system error 2 (The system cannot find the file specified.)
```

→ Nguyên nhân: thư mục `C:\SQLData` chưa tồn tại. Cách sửa: tạo thư mục, **không** sửa script.

```text
Cannot drop database "QL_CAFE_NHAHANG" because it is currently in use.
```

→ Nguyên nhân: có kết nối khác đang mở và `SINGLE_USER ... ROLLBACK IMMEDIATE` không đủ (hiếm), hoặc bạn đang đứng trong CSDL đó. Cách sửa: đóng cửa sổ query đang kết nối, rồi chạy lại.

### 5.6. Bài học rút ra

`01_CAUHINH_CSDL.sql` là ví dụ điển hình của một script **idempotent có chủ đích**: chạy bao nhiêu lần cũng cho cùng trạng thái (một CSDL rỗng), nhờ bước "xóa nếu tồn tại". Nhưng cái giá là **mất dữ liệu**. Trong môi trường thật, người ta thường không làm vậy — họ dùng migration. Với bài tập, đây là cách đơn giản và chấp nhận được.

---

## 6. File `sql/02_Bang.sql`

### 6.1. Mục đích và bố cục

Tạo toàn bộ **10 bảng** của mô hình dữ liệu, cùng khóa chính, khóa ngoại, các ràng buộc `CHECK`/`UNIQUE`/`DEFAULT`, một chỉ mục duy nhất có điều kiện, và một đoạn `ALTER TABLE` để chứng minh yêu cầu Readme mục 3.2.

Bố cục file (151 dòng):

| Phần | Dòng | Nội dung |
|---|---|---|
| Mở đầu | 1–2 | `USE QL_CAFE_NHAHANG` |
| 0. Xóa bảng cũ | 4–14 | 10 lệnh `DROP TABLE IF EXISTS` theo thứ tự con → cha |
| 1. Bảng danh mục | 16–58 | `LoaiMon`, `Ban`, `NhanVien`, `NguyenLieu` |
| 2. Món + chuyên biệt hóa | 60–95 | `Mon`, `MonAn`, `ThucUong` |
| 3. Định lượng (N–N) | 97–108 | `DinhLuong` |
| 4. Giao dịch | 110–139 | `HoaDon`, `ChiTietHoaDon` |
| 5. Bổ sung bằng `ALTER` | 141–151 | Thêm ràng buộc, thêm cột, thêm chỉ mục, đổi ràng buộc |

### 6.2. Phần 0 — Xóa bảng theo đúng thứ tự (dòng 4–14)

```sql
DROP TABLE IF EXISTS ChiTietHoaDon;
DROP TABLE IF EXISTS HoaDon;
DROP TABLE IF EXISTS DinhLuong;
DROP TABLE IF EXISTS MonAn;
DROP TABLE IF EXISTS ThucUong;
DROP TABLE IF EXISTS Mon;
DROP TABLE IF EXISTS NguyenLieu;
DROP TABLE IF EXISTS NhanVien;
DROP TABLE IF EXISTS Ban;
DROP TABLE IF EXISTS LoaiMon;
GO
```

**Vì sao thứ tự này quan trọng:** một bảng có khóa ngoại trỏ tới bảng khác **không thể bị xóa** khi bảng được trỏ tới vẫn còn. Phải xóa **con trước, cha sau**.

Ví dụ: `ChiTietHoaDon` có khóa ngoại tới `HoaDon`. Nếu xóa `HoaDon` trước, SQL Server báo:

```text
Could not drop object 'dbo.HoaDon' because it is referenced by a FOREIGN KEY constraint.
```

Sơ đồ phụ thuộc khi xóa (mũi tên = "phải xóa trước"):

```text
ChiTietHoaDon ──► HoaDon ──► Ban, NhanVien
      │
      └──────────► Mon ──► LoaiMon
                     ▲
        DinhLuong ───┘         (DinhLuong phải xóa trước cả Mon và NguyenLieu)
             │
             └───► NguyenLieu
```

Thứ tự đúng trong file xử lý được toàn bộ chuỗi này. **Nếu bạn thêm bảng mới, phải thêm dòng `DROP` vào đúng vị trí** — nếu không, lần chạy sau sẽ lỗi, và nếu đặt sai vị trí cũng lỗi.

`DROP TABLE IF EXISTS` cần SQL Server **2016 trở lên**. Trên bản cũ hơn, câu này báo lỗi cú pháp.

> 🔴 **Rủi ro:** phần này **xóa toàn bộ 10 bảng và mọi dữ liệu trong đó**. Đây là script "làm lại từ đầu", không phải script cập nhật.

### 6.3. Nhóm 1 — Bốn bảng danh mục

#### 6.3.1. `LoaiMon` — loại món, có quan hệ đệ quy

```sql
CREATE TABLE LoaiMon (
    MaLoai      INT IDENTITY(1,1) NOT NULL,
    TenLoai     NVARCHAR(50) NOT NULL,
    MaLoaiCha   INT NULL,
    CONSTRAINT PK_LoaiMon PRIMARY KEY (MaLoai),
    CONSTRAINT UQ_LoaiMon_Ten UNIQUE (TenLoai),
    CONSTRAINT FK_LoaiMon_Cha FOREIGN KEY (MaLoaiCha) REFERENCES LoaiMon(MaLoai)
);
```

| Cột | Kiểu | Ý nghĩa |
|---|---|---|
| `MaLoai` | `INT IDENTITY(1,1)` | Khóa chính, tự tăng từ 1, mỗi lần +1 |
| `TenLoai` | `NVARCHAR(50) NOT NULL` | Tên loại, **bắt buộc** và **không trùng** |
| `MaLoaiCha` | `INT NULL` | Loại cha; `NULL` = loại gốc |

Đây là **cấu trúc đệ quy** (self-reference): bảng tham chiếu chính nó. `FK_LoaiMon_Cha` đảm bảo `MaLoaiCha` phải là một `MaLoai` có thật.

**Quy tắc thực thi — cực kỳ dễ sai:**

```sql
-- ✅ ĐÚNG: chèn loại cha trước
INSERT INTO LoaiMon (TenLoai, MaLoaiCha) VALUES (N'Món ăn', NULL);   -- MaLoai = 1
INSERT INTO LoaiMon (TenLoai, MaLoaiCha) VALUES (N'Khai vị', 1);       -- con của 1

-- ❌ SAI: chèn con khi cha chưa có
INSERT INTO LoaiMon (TenLoai, MaLoaiCha) VALUES (N'Khai vị', 99);
-- Lỗi: The INSERT statement conflicted with the FOREIGN KEY constraint "FK_LoaiMon_Cha"
```

Dữ liệu mẫu làm đúng: chèn 8 loại gốc trước (dòng 19–27), rồi 3 loại con (dòng 29–32).

**`IDENTITY(1,1)` là gì:** cột tự sinh giá trị, bắt đầu từ 1, mỗi dòng +1. Bạn **không được** `INSERT` giá trị cho cột này, trừ khi bật `SET IDENTITY_INSERT ON`. Đây là lý do vì sao việc nạp lại dữ liệu trên bảng không rỗng lại nguy hiểm (mục 4.3).

#### 6.3.2. `Ban` — bàn

```sql
CREATE TABLE Ban (
    MaBan       INT IDENTITY(1,1) NOT NULL,
    TenBan      NVARCHAR(20) NOT NULL,
    SucChua     TINYINT NOT NULL,
    TrangThai   NVARCHAR(10) NOT NULL CONSTRAINT DF_Ban_TrangThai DEFAULT N'Trống',
    CONSTRAINT PK_Ban PRIMARY KEY (MaBan),
    CONSTRAINT UQ_Ban_Ten UNIQUE (TenBan),
    CONSTRAINT CK_Ban_SucChua CHECK (SucChua > 0),
    CONSTRAINT CK_Ban_TrangThai CHECK (TrangThai IN (N'Trống', N'Có khách', N'Đã đặt'))
);
```

| Ràng buộc | Nội dung | Vì sao |
|---|---|---|
| `UQ_Ban_Ten` | Tên bàn không trùng | Không thể có hai "Bàn 01" |
| `CK_Ban_SucChua` | `SucChua > 0` | Bàn 0 chỗ là vô nghĩa |
| `CK_Ban_TrangThai` | Chỉ 3 giá trị | Chặn lỗi gõ thiếu/sai dấu (`N'co khach'`, `N'Có khach'`…). Lưu ý: vì collation là `CI`, `N'CÓ KHÁCH'` **vẫn hợp lệ** |
| `DF_Ban_TrangThai` | Mặc định `N'Trống'` | Bàn mới tạo mặc định là trống |

`TINYINT` là số nguyên 0–255, đủ cho sức chứa bàn và tiết kiệm 3 byte so với `INT`.

**Tại sao dùng `CHECK ... IN (...)` thay vì bảng tra cứu?** Với tập giá trị nhỏ, cố định, ít thay đổi thì `CHECK` đơn giản hơn. Nhược điểm: thêm trạng thái mới phải `ALTER TABLE`, và không lưu được mô tả/thứ tự hiển thị.

**Ví dụ: ràng buộc hoạt động thế nào**

```sql
INSERT INTO Ban (TenBan, SucChua) VALUES (N'Bàn 20', 4);          -- ✅ TrangThai = N'Trống'
INSERT INTO Ban (TenBan, SucChua) VALUES (N'Bàn 21', 0);          -- ❌ CK_Ban_SucChua
UPDATE Ban SET TrangThai = N'Co khach' WHERE TenBan = N'Bàn 20';   -- ❌ CK_Ban_TrangThai (thiếu dấu)
INSERT INTO Ban (TenBan, SucChua) VALUES (N'bàn 20', 4);          -- ❌ UQ_Ban_Ten (CI: trùng)
```

#### 6.3.3. `NhanVien` — nhân viên

```sql
CREATE TABLE NhanVien (
    MaNV        INT IDENTITY(1,1) NOT NULL,
    HoTen       NVARCHAR(100) NOT NULL,
    ChucVu      NVARCHAR(20) NOT NULL,
    SoDienThoai VARCHAR(15) NULL,
    CONSTRAINT PK_NhanVien PRIMARY KEY (MaNV),
    CONSTRAINT CK_NhanVien_ChucVu CHECK (ChucVu IN (N'PhucVu', N'ThuNgan', N'Bep', N'QuanLy'))
);
```

Lưu ý: **cột `NgayVaoLam` không có ở đây** — nó được thêm sau bằng `ALTER TABLE` ở dòng 144–145 (xem mục 6.7). Đây là chủ ý: Readme mục 3.2 yêu cầu có ít nhất một đoạn `ALTER TABLE`.

`ChucVu` chỉ nhận 4 giá trị **không dấu** (`PhucVu`, `ThuNgan`, `Bep`, `QuanLy`) — khác với `TrangThai` của `Ban` là **có dấu**. Đây là điểm không nhất quán về phong cách, nhưng **không phải lỗi**: nó phản ánh việc `ChucVu` đóng vai trò "mã" còn `TrangThai` đóng vai trò "nhãn hiển thị". Khi làm phân quyền M3, bốn giá trị này sẽ ánh xạ thành tên role.

`SoDienThoai` cho phép `NULL` (nhân viên có thể chưa có số). `VARCHAR(15)` đủ cho số Việt Nam (10 chữ số) và không cần Unicode vì chỉ chứa số.

#### 6.3.4. `NguyenLieu` — nguyên liệu và tồn kho

```sql
CREATE TABLE NguyenLieu (
    MaNL        INT IDENTITY(1,1) NOT NULL,
    TenNL       NVARCHAR(100) NOT NULL,
    DonViTinh   NVARCHAR(10) NOT NULL,
    TonKho      DECIMAL(12,2) NOT NULL CONSTRAINT DF_NL_TonKho DEFAULT 0,
    DinhMucTon  DECIMAL(12,2) NOT NULL CONSTRAINT DF_NL_DinhMuc DEFAULT 0,
    DonGiaNhap  DECIMAL(12,2) NOT NULL CONSTRAINT DF_NL_DonGia DEFAULT 0,
    CONSTRAINT PK_NguyenLieu PRIMARY KEY (MaNL),
    CONSTRAINT UQ_NguyenLieu_Ten UNIQUE (TenNL),
    CONSTRAINT CK_NL_TonKho CHECK (TonKho >= 0),
    CONSTRAINT CK_NL_DonGia CHECK (DonGiaNhap >= 0)
);
```

| Cột | Ý nghĩa |
|---|---|
| `TonKho` | Số lượng đang có trong kho |
| `DinhMucTon` | **Định mức tồn** — ngưỡng tối thiểu cần duy trì. **Suy luận:** tên đọc là "định mức" + cách dùng trong các truy vấn kiểm tra (`TonKho < DinhMucTon` = "dưới định mức") cho thấy đây là **ngưỡng cảnh báo**, không phải "số lượng tối đa" |
| `DonGiaNhap` | Đơn giá nhập, dùng để tính giá vốn món (Readme gợi ý `fn_GiaVonMon`) |

`DECIMAL(12,2)` = tối đa 12 chữ số, trong đó 2 chữ số thập phân. Ví dụ `120.00`, `0.06`. Dùng `DECIMAL` cho số đo lường là **bắt buộc** — `FLOAT` gây sai số khi tính tiền.

`CK_NL_TonKho CHECK (TonKho >= 0)` là ràng buộc chặn **tồn kho âm**. Theo Readme mục 1, ở M3 sẽ có trigger chặn tồn kho âm ở mức giao dịch (trừ nguyên liệu khi gọi món) — ràng buộc này là **lớp bảo vệ thứ hai**, ở mức từng dòng.

### 6.4. Nhóm 2 — `Mon` và chuyên biệt hóa

Đây là **cấu trúc nâng cao thứ nhất** mà đề tài yêu cầu: "chuyên biệt hóa món: đồ ăn và thức uống".

#### 6.4.1. `Mon` — bảng cha

```sql
CREATE TABLE Mon (
    MaMon       INT IDENTITY(1,1) NOT NULL,
    TenMon      NVARCHAR(100) NOT NULL,
    MaLoai      INT NOT NULL,
    GiaBan      DECIMAL(12,0) NOT NULL,
    Nhom        CHAR(1) NOT NULL,           -- 'A' = đồ ăn, 'U' = thức uống
    DangBan     BIT NOT NULL CONSTRAINT DF_Mon_DangBan DEFAULT 1,
    CONSTRAINT PK_Mon PRIMARY KEY (MaMon),
    CONSTRAINT UQ_Mon_Ten UNIQUE (TenMon),
    CONSTRAINT FK_Mon_LoaiMon FOREIGN KEY (MaLoai) REFERENCES LoaiMon(MaLoai),
    CONSTRAINT CK_Mon_GiaBan CHECK (GiaBan >= 0),
    CONSTRAINT CK_Mon_Nhom CHECK (Nhom IN ('A', 'U'))
);
```

| Cột | Ý nghĩa |
|---|---|
| `GiaBan` | `DECIMAL(12,0)` — giá bán là **số nguyên đồng**, không có phần lẻ (phù hợp thực tế quán Việt Nam) |
| `Nhom CHAR(1)` | Phân nhóm: `'A'` (ăn) hoặc `'U'` (uống). `CHAR(1)` cố định 1 byte — đúng cho mã ASCII 1 ký tự |
| `DangBan BIT` | `1` = đang bán, `0` = tạm ngưng. `BIT` là kiểu boolean của SQL Server (0/1) |

`CK_Mon_Nhom` chỉ cho phép 2 giá trị — đây là điểm **nối** giữa bảng cha và hai bảng con (xem cảnh báo ngay dưới).

#### 6.4.2. `MonAn` — món ăn

```sql
CREATE TABLE MonAn (
    MaMon           INT NOT NULL,
    ThoiGianCheBien INT NOT NULL,           -- phút
    CayHayKhong     BIT NOT NULL CONSTRAINT DF_MonAn_Cay DEFAULT 0,
    CONSTRAINT PK_MonAn PRIMARY KEY (MaMon),
    CONSTRAINT FK_MonAn_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon),
    CONSTRAINT CK_MonAn_ThoiGian CHECK (ThoiGianCheBien > 0)
);
```

Điểm quan trọng: **`MaMon` vừa là khóa chính, vừa là khóa ngoại.** Đây là kỹ thuật kinh điển để biểu diễn chuyên biệt hóa trong CSDL quan hệ.

```text
Mon                      MonAn
┌─────────┐              ┌─────────────────────┐
│ MaMon=1 │◄──FK,PK─────►│ MaMon=1 (bắt buộc)  │
│ TenMon  │              │ ThoiGianCheBien     │
└─────────┘              └─────────────────────┘
```

- Vì `MaMon` là `PRIMARY KEY` của `MonAn`, mỗi món chỉ có **tối đa 1** dòng trong `MonAn`.
- Vì `MaMon` là `FOREIGN KEY`, mỗi dòng `MonAn` **phải** ứng với một `Mon` có thật.
- Kết quả: quan hệ **1–0..1** — đúng bản chất "món nào là đồ ăn thì có thêm thông tin riêng của đồ ăn".

`ThoiGianCheBien > 0`: món ăn phải có thời gian chế biến dương (đơn vị: phút).

> ⚠️ **Lỗ hổng thiết kế cần biết:** không có ràng buộc nào đảm bảo `MonAn` chỉ trỏ tới `Mon` có `Nhom = 'A'`. Câu này **hợp lệ** về mặt CSDL:
>
> ```sql
> -- Mon 19 là "Cà phê đen đá" (Nhom='U') nhưng vẫn có thể được thêm vào MonAn
> INSERT INTO MonAn (MaMon, ThoiGianCheBien) VALUES (19, 5);   -- ✅ không bị chặn
> ```
>
> Muốn chặn, cần **trigger** kiểm tra `Mon.Nhom`. Readme xếp trigger vào M3 — đây là một ứng viên tốt để làm. Hiện tại, tính đúng đắn **chỉ được đảm bảo bởi dữ liệu mẫu**, không bởi CSDL.

#### 6.4.3. `ThucUong` — thức uống

```sql
CREATE TABLE ThucUong (
    MaMon       INT NOT NULL,
    Size        CHAR(1) NOT NULL CONSTRAINT DF_ThucUong_Size DEFAULT 'M',
    CoDa        BIT NOT NULL CONSTRAINT DF_ThucUong_Da DEFAULT 1,
    CoDuong     BIT NOT NULL CONSTRAINT DF_ThucUong_Duong DEFAULT 1,
    CONSTRAINT PK_ThucUong PRIMARY KEY (MaMon),
    CONSTRAINT FK_ThucUong_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon),
    CONSTRAINT CK_ThucUong_Size CHECK (Size IN ('S', 'M', 'L'))
);
```

Cấu trúc hoàn toàn song song với `MonAn`: `MaMon` là PK + FK, quan hệ 1–0..1 với `Mon`.

Ba cột riêng của thức uống: `Size` (S/M/L), `CoDa` (có đá), `CoDuong` (có đường). Đây là các thuộc tính **chỉ thức uống mới có** — chính là lý do phải tách bảng thay vì nhét hết vào `Mon`.

> ⚠️ **Cùng lỗ hổng như `MonAn`:** không có gì chặn việc thêm một "món ăn" vào `ThucUong`.

**Vì sao tách `MonAn`/`ThucUong` thay vì thêm cột vào `Mon`?**

| Cách tách bảng (đang dùng) | Cách gộp cột |
|---|---|
| Không lãng phí: món ăn không có cột `Size` | Nhiều cột `NULL` ở mọi dòng |
| Thêm thuộc tính riêng dễ, không ảnh hưởng bảng khác | Mỗi lần thêm thuộc tính phải sửa bảng lớn |
| Đúng lý thuyết chuyên biệt hóa | Đơn giản hơn khi truy vấn |

Nhược điểm của cách tách: muốn lấy **tất cả** thuộc tính của một món phải `JOIN` thêm. Đây là đánh đổi có chủ ý.

### 6.5. Nhóm 3 — `DinhLuong` (quan hệ N–N có thuộc tính định lượng)

Đây là **cấu trúc nâng cao thứ hai**: "Món – nguyên liệu: quan hệ N–N có thuộc tính định lượng".

```sql
CREATE TABLE DinhLuong (
    MaMon       INT NOT NULL,
    MaNL        INT NOT NULL,
    SoLuong     DECIMAL(10,2) NOT NULL,     -- lượng nguyên liệu cho 1 phần món
    CONSTRAINT PK_DinhLuong PRIMARY KEY (MaMon, MaNL),
    CONSTRAINT FK_DinhLuong_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon),
    CONSTRAINT FK_DinhLuong_NL FOREIGN KEY (MaNL) REFERENCES NguyenLieu(MaNL),
    CONSTRAINT CK_DinhLuong_SoLuong CHECK (SoLuong > 0)
);
```

**Đọc bảng này thế nào:** mỗi dòng nghĩa là *"để làm 1 phần món `MaMon`, cần `SoLuong` đơn vị nguyên liệu `MaNL`"*.

Ví dụ thật từ `scripts/03a_DanhMuc.sql`:

```sql
(1, 3, 3.00), (1, 7, 0.06), (1, 5, 0.05), (1, 10, 0.01),
```

Dịch: món 1 (Gỏi cuốn tôm thịt) cần 3 cái bánh tráng (NL 3), 0.06 kg tôm (NL 7), 0.05 kg thịt heo (NL 5), 0.01 kg hành tím (NL 10) — cho **một** phần.

**Vì sao khóa chính là `(MaMon, MaNL)` (khóa ghép)?**

Vì mỗi cặp (món, nguyên liệu) chỉ được xuất hiện **một lần**. Nếu muốn 2 phần thì tăng cột `SoLuong`, **không** thêm dòng thứ hai.

```sql
-- ✅ Đúng: một dòng, số lượng 2
INSERT INTO DinhLuong VALUES (1, 3, 2.00);

-- ❌ Sai: vi phạm PK_DinhLuong (cặp đã tồn tại)
INSERT INTO DinhLuong VALUES (1, 3, 1.00);
```

**Vì sao không cần cột `MaDL` tự tăng?** Vì `(MaMon, MaNL)` đã **duy nhất** và **đủ nhỏ**. Thêm cột `IDENTITY` chỉ làm nặng bảng mà không thêm thông tin. Đây là lựa chọn đúng theo chuẩn thiết kế.

**Quan hệ N–N được hiện thực hóa thế nào:**

```text
Mon (1) ──── (N) DinhLuong (N) ──── (1) NguyenLieu
        "một món cần nhiều nguyên liệu"
        "một nguyên liệu dùng cho nhiều món"
```

`DinhLuong` là **bảng trung gian** (junction table) có thêm thuộc tính `SoLuong` — đây chính là "thuộc tính định lượng" mà đề bài yêu cầu.

**Ứng dụng thực tế — đây là nền của `fn_GiaVonMon` (M2):**

```sql
-- Giá vốn nguyên liệu cho 1 phần món số 1
SELECT m.MaMon, m.TenMon,
       SUM(dl.SoLuong * nl.DonGiaNhap) AS GiaVon
FROM Mon AS m
JOIN DinhLuong AS dl ON dl.MaMon = m.MaMon
JOIN NguyenLieu AS nl ON nl.MaNL = dl.MaNL
WHERE m.MaMon = 1
GROUP BY m.MaMon, m.TenMon;
```

**Ứng dụng thực tế — đây là nền của `sp_GoiMon` (M2):** khi gọi 1 phần món, phải trừ `SoLuong` của từng nguyên liệu tương ứng khỏi `NguyenLieu.TonKho`.

### 6.6. Nhóm 4 — Bảng giao dịch

#### 6.6.1. `HoaDon` — hóa đơn

```sql
CREATE TABLE HoaDon (
    MaHD        INT IDENTITY(1,1) NOT NULL,
    MaBan       INT NOT NULL,
    MaNV        INT NOT NULL,
    NgayLap     DATETIME NOT NULL CONSTRAINT DF_HoaDon_NgayLap DEFAULT GETDATE(),
    TrangThai   NVARCHAR(15) NOT NULL CONSTRAINT DF_HoaDon_TrangThai DEFAULT N'Mở',
    TongTien    DECIMAL(14,0) NOT NULL CONSTRAINT DF_HoaDon_TongTien DEFAULT 0,
    CONSTRAINT PK_HoaDon PRIMARY KEY (MaHD),
    CONSTRAINT FK_HoaDon_Ban FOREIGN KEY (MaBan) REFERENCES Ban(MaBan),
    CONSTRAINT FK_HoaDon_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    CONSTRAINT CK_HoaDon_TrangThai CHECK (TrangThai IN (N'Mở', N'Đã thanh toán', N'Hủy')),
    CONSTRAINT CK_HoaDon_TongTien CHECK (TongTien >= 0)
);
```

| Cột | Ý nghĩa |
|---|---|
| `NgayLap` | `DEFAULT GETDATE()` — tự lấy thời điểm hiện tại nếu không truyền |
| `TrangThai` | Vòng đời hóa đơn: `Mở` → `Đã thanh toán`, hoặc → `Hủy` |
| `TongTien` | Tổng tiền — **dữ liệu dẫn xuất**, không phải nhập tay |

`DECIMAL(14,0)` cho `TongTien` rộng hơn `GiaBan` (`DECIMAL(12,0)`) vì tổng của nhiều dòng có thể lớn hơn từng dòng.

**`TongTien` là dữ liệu dẫn xuất — điểm cần hiểu rõ nhất.** Về lý thuyết, `TongTien` **luôn** phải bằng:

```sql
SELECT SUM(SoLuong * DonGia) FROM ChiTietHoaDon WHERE MaHD = ?
```

Nhưng CSDL **không tự đảm bảo** điều này. Không có `COMPUTED COLUMN`, không có trigger. `scripts/03b_GiaoDich.sql` tính nó bằng một câu `UPDATE` duy nhất ở BƯỚC 4.

> **Quy tắc:** mọi thao tác thêm/sửa/xóa `ChiTietHoaDon` phải kèm theo việc tính lại `TongTien`. Đây là ứng viên tự nhiên cho trigger ở M3.

**Vì sao cần `TongTien` khi có thể tính lại?** Vì tính lại mỗi lần đọc rất tốn kém khi có hàng nghìn hóa đơn (phải `GROUP BY` toàn bảng). Lưu sẵn là kỹ thuật **phi chuẩn hóa có kiểm soát** — đánh đổi dung lượng và rủi ro lệch, lấy tốc độ đọc.

**Vì sao `MaBan` và `MaNV` đều `NOT NULL`?** Mỗi hóa đơn **bắt buộc** gắn với một bàn và một nhân viên lập. Ngay cả hóa đơn hủy cũng phải có bàn (thực tế: khách ngồi rồi mới hủy).

#### 6.6.2. `ChiTietHoaDon` — chi tiết hóa đơn

```sql
CREATE TABLE ChiTietHoaDon (
    MaHD             INT NOT NULL,
    MaMon            INT NOT NULL,
    SoLuong          INT NOT NULL,
    DonGia           DECIMAL(12,0) NOT NULL,   -- chép giá bán tại thời điểm gọi
    TrangThaiCheBien NVARCHAR(15) NOT NULL CONSTRAINT DF_CTHD_TrangThai DEFAULT N'Chờ',
    CONSTRAINT PK_ChiTietHoaDon PRIMARY KEY (MaHD, MaMon),
    CONSTRAINT FK_CTHD_HoaDon FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD),
    CONSTRAINT FK_CTHD_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon),
    CONSTRAINT CK_CTHD_SoLuong CHECK (SoLuong > 0),
    CONSTRAINT CK_CTHD_DonGia CHECK (DonGia >= 0),
    CONSTRAINT CK_CTHD_TrangThai CHECK (TrangThaiCheBien IN (N'Chờ', N'Đang làm', N'Xong'))
);
```

| Cột | Ý nghĩa | Ghi chú thiết kế |
|---|---|---|
| `MaHD` + `MaMon` | Khóa chính ghép | Mỗi món chỉ xuất hiện **1 lần** trong một hóa đơn |
| `SoLuong` | Số phần | Muốn 3 phần thì tăng số này, không thêm dòng |
| `DonGia` | Giá **tại thời điểm gọi** | **Sao chép** từ `Mon.GiaBan`, không tham chiếu |
| `TrangThaiCheBien` | Trạng thái chế biến | Phục vụ vai trò `Bep` (chỉ xem món cần làm) |

**Ba điểm thiết kế quan trọng, cần hiểu trước khi sửa:**

**① Khóa chính ghép `(MaHD, MaMon)`** — cùng lý do như `DinhLuong`: một món chỉ một dòng/hóa đơn.

**② `DonGia` được sao chép, không tham chiếu.** Đây là quyết định rất quan trọng:

```text
Nếu ChiTietHoaDon chỉ lưu MaMon và JOIN sang Mon để lấy GiaBan:
  - Hôm nay bán phở 75.000đ → hóa đơn ghi 75.000đ
  - Tháng sau chủ quán tăng giá thành 85.000đ
  - Mở lại hóa đơn cũ → hiển thị 85.000đ  ❌ SAI LỊCH SỬ

Với DonGia sao chép:
  - Hóa đơn cũ vẫn ghi 75.000đ          ✅ ĐÚNG
```

Đây gọi là **lưu ảnh chụp giá** (price snapshot) — nguyên tắc bắt buộc với mọi hệ thống kế toán/bán hàng. **Đừng "tối ưu" bằng cách bỏ cột này.**

**③ `CK_CTHD_DonGia CHECK (DonGia >= 0)`** — lưu ý là `>=`, cho phép giá 0 (món tặng/khuyến mãi). Trong khi đó `Mon.GiaBan` sau khi `ALTER` lại yêu cầu `> 0` (xem 6.7). Sự khác biệt này là **có chủ ý**: giá niêm yết phải dương, nhưng giá bán thực tế có thể 0.

### 6.7. Phần 5 — `ALTER TABLE` và chỉ mục (dòng 141–151)

Đây là phần chứng minh yêu cầu Readme mục 3.2: *"Có ít nhất một đoạn `ALTER TABLE` để bổ sung hoặc sửa ràng buộc"*.

```sql
ALTER TABLE NguyenLieu
    ADD CONSTRAINT CK_NL_DinhMuc CHECK (DinhMucTon >= 0);
```

**Thêm ràng buộc còn thiếu.** `NguyenLieu` ban đầu chỉ có `CK_NL_TonKho` và `CK_NL_DonGia`; ràng buộc cho `DinhMucTon` được bổ sung sau. Ý nghĩa: định mức tồn không được âm.

```sql
ALTER TABLE NhanVien
    ADD NgayVaoLam DATE NOT NULL CONSTRAINT DF_NhanVien_NgayVaoLam DEFAULT GETDATE();
```

**Thêm cột vào bảng đã có dữ liệu.** Đây là kỹ thuật đáng chú ý:

- Cột được khai báo `NOT NULL` **và** có `DEFAULT` → SQL Server điền `GETDATE()` cho mọi dòng hiện có, nên lệnh thành công.
- Nếu bỏ `DEFAULT`, lệnh sẽ **thất bại**: `ALTER TABLE only allows columns to be added that can contain nulls...`. Đây là lỗi rất hay gặp.
- Hệ quả dữ liệu: mọi nhân viên đã có sẽ nhận `NgayVaoLam` = thời điểm chạy `ALTER`, **không phải** ngày vào làm thật. Với dự án này không sao vì `ALTER` chạy trước khi nạp dữ liệu (`scripts/03a_DanhMuc.sql` chèn tường minh `NgayVaoLam`).

```sql
CREATE UNIQUE INDEX UX_NhanVien_SDT ON NhanVien(SoDienThoai) WHERE SoDienThoai IS NOT NULL;
```

**Chỉ mục duy nhất có điều kiện** (filtered unique index) — kỹ thuật tinh tế nhất trong file:

| Nếu dùng `UNIQUE` thường | Với filtered unique index |
|---|---|
| Chỉ cho phép **1** nhân viên có `SoDienThoai = NULL` | Cho phép **nhiều** nhân viên `NULL` |
| Không hợp lý: 5 người chưa có số điện thoại sẽ xung đột | Hợp lý: `NULL` = "chưa biết", không phải một giá trị |

Giải thích: `UNIQUE` thường coi hai `NULL` là **trùng nhau** (theo chuẩn SQL, `NULL` không bằng `NULL`, nhưng unique index lại xử lý theo cách riêng). Thêm `WHERE SoDienThoai IS NOT NULL` để chỉ áp dụng ràng buộc cho dòng **có** số điện thoại.

> **Yêu cầu phiên bản:** filtered index cần SQL Server **2008 trở lên** — không vấn đề với dự án.

```sql
ALTER TABLE Mon DROP CONSTRAINT CK_Mon_GiaBan;
ALTER TABLE Mon ADD CONSTRAINT CK_Mon_GiaBan CHECK (GiaBan > 0);
```

**Sửa ràng buộc đã có** — thay `GiaBan >= 0` bằng `GiaBan > 0`.

**Vì sao?** Một món trong thực đơn **phải có giá dương**. Món 0đ là dữ liệu vô nghĩa (khác với `DonGia` trong chi tiết hóa đơn, nơi 0đ là món tặng hợp lý).

**Vì sao phải `DROP` rồi `ADD` mà không sửa trực tiếp?** T-SQL không có cú pháp `ALTER CONSTRAINT`. Muốn đổi nội dung một `CHECK`, bắt buộc phải xóa và tạo lại.

> ⚠️ **Cảnh báo:** giữa hai lệnh này, bảng `Mon` **không có** ràng buộc giá. Nếu có ai `INSERT` giá âm đúng lúc đó, dữ liệu bẩn sẽ lọt vào và lệnh `ADD` sau sẽ **thất bại** (`ALTER TABLE ... conflicted with the CHECK constraint`). Trong thực tế nên gói hai lệnh vào một transaction.

> ⚠️ **Thay đổi hành vi:** sau khi chạy phần này, **không thể** tạo món giá 0. Nếu sau này cần món khuyến mãi 0đ trong thực đơn, phải `ALTER` lại. Đây là thay đổi **có ảnh hưởng**, cần báo nhóm.

### 6.8. Sơ đồ quan hệ

```text
                          ┌──────────────┐
                          │   LoaiMon    │
                          │ PK MaLoai    │◄──┐ MaLoaiCha (tự tham chiếu)
                          │ UQ TenLoai   │───┘
                          └──────┬───────┘
                                 │ 1
                                 │
                                 ▼ N
   ┌──────────┐          ┌──────────────┐          ┌──────────────┐
   │ NguyenLieu│          │     Mon      │          │   NhanVien   │
   │ PK MaNL  │          │ PK MaMon     │          │ PK MaNV      │
   │ UQ TenNL │          │ UQ TenMon    │          │ CK ChucVu    │
   └────┬─────┘          │ CK GiaBan>0  │          └──────┬───────┘
        │ 1              │ CK Nhom A/U  │                 │ 1
        │                └──┬────────┬──┘                 │
        │ N                 │1       │1                   │ N
   ┌────▼────────┐   ┌──────▼────┐ ┌─▼──────────┐  ┌──────▼───────┐
   │  DinhLuong  │   │   MonAn   │ │ ThucUong   │  │   HoaDon     │
   │ PK(MaMon,   │   │ PK/FK     │ │ PK/FK      │  │ PK MaHD      │
   │    MaNL)    │   │  MaMon    │ │  MaMon     │  │ CK TrangThai │
   └─────────────┘   └───────────┘ └────────────┘  └──────┬───────┘
        ▲ N                                                │ 1
        │                                                  │
        └──────────── Mon (N) ◄──────────────┐             │ N
                                             │      ┌──────▼────────┐
                                    ┌────────┴──────┤ ChiTietHoaDon │
                                    │  Ban          │ PK(MaHD,MaMon)│
                                    │ PK MaBan      │ CK SoLuong>0  │
                                    │ CK TrangThai  │ CK TrangThai  │
                                    └───────▲───────┴───────────────┘
                                            │ N
                                          HoaDon ──► Ban
```

### 6.9. Bảng tổng hợp ràng buộc

| Bảng | PK | FK (→ bảng) | UNIQUE | CHECK | DEFAULT |
|---|---|---|---|---|---|
| `LoaiMon` | `MaLoai` | `MaLoaiCha` → `LoaiMon` | `TenLoai` | — | — |
| `Ban` | `MaBan` | — | `TenBan` | `SucChua > 0`; `TrangThai IN (3 gt)` | `TrangThai = N'Trống'` |
| `NhanVien` | `MaNV` | — | — | `ChucVu IN (4 gt)` | `NgayVaoLam = GETDATE()` *(thêm sau)* |
| `NguyenLieu` | `MaNL` | — | `TenNL` | `TonKho >= 0`; `DonGiaNhap >= 0`; `DinhMucTon >= 0` *(thêm sau)* | 3 cột số = 0 |
| `Mon` | `MaMon` | `MaLoai` → `LoaiMon` | `TenMon` | `GiaBan > 0` *(sửa sau)*; `Nhom IN ('A','U')` | `DangBan = 1` |
| `MonAn` | `MaMon` | `MaMon` → `Mon` | — | `ThoiGianCheBien > 0` | `CayHayKhong = 0` |
| `ThucUong` | `MaMon` | `MaMon` → `Mon` | — | `Size IN ('S','M','L')` | `Size='M'`, `CoDa=1`, `CoDuong=1` |
| `DinhLuong` | `(MaMon, MaNL)` | `MaMon` → `Mon`; `MaNL` → `NguyenLieu` | — | `SoLuong > 0` | — |
| `HoaDon` | `MaHD` | `MaBan` → `Ban`; `MaNV` → `NhanVien` | — | `TrangThai IN (3 gt)`; `TongTien >= 0` | `NgayLap=GETDATE()`, `TrangThai=N'Mở'`, `TongTien=0` |
| `ChiTietHoaDon` | `(MaHD, MaMon)` | `MaHD` → `HoaDon`; `MaMon` → `Mon` | — | `SoLuong > 0`; `DonGia >= 0`; `TrangThaiCheBien IN (3 gt)` | `TrangThaiCheBien = N'Chờ'` |

Chỉ mục bổ sung: `UX_NhanVien_SDT` — unique, filtered `WHERE SoDienThoai IS NOT NULL`.

### 6.10. Kết quả mong đợi

Sau khi chạy thành công:

- **10 bảng** được tạo trong `QL_CAFE_NHAHANG` (bảng hệ thống không tính).
- **10 khóa ngoại**, chia làm hai nhóm:
  - Nhóm danh mục và món (4): `FK_LoaiMon_Cha`, `FK_Mon_LoaiMon`, `FK_MonAn_Mon`, `FK_ThucUong_Mon`.
  - Nhóm định lượng và giao dịch (6): `FK_DinhLuong_Mon`, `FK_DinhLuong_NL`, `FK_HoaDon_Ban`, `FK_HoaDon_NhanVien`, `FK_CTHD_HoaDon`, `FK_CTHD_Mon`.
- **4 ràng buộc `UNIQUE`**: `UQ_LoaiMon_Ten`, `UQ_Ban_Ten`, `UQ_NguyenLieu_Ten`, `UQ_Mon_Ten`.
- **1 chỉ mục bổ sung**: `UX_NhanVien_SDT` (unique, có điều kiện).
- Tất cả bảng **rỗng** (0 dòng) — dữ liệu do `scripts/` nạp.

Câu kiểm tra:

```sql
SELECT COUNT(*) AS SoBang
FROM sys.tables
WHERE name IN ('LoaiMon','Ban','NhanVien','NguyenLieu','Mon',
               'MonAn','ThucUong','DinhLuong','HoaDon','ChiTietHoaDon');
-- Mong đợi: 10
```

### 6.11. Rủi ro

| Rủi ro | Mức | Chi tiết |
|---|---|---|
| **Xóa toàn bộ bảng và dữ liệu** | 🔴 Cao | 10 lệnh `DROP TABLE` ở đầu file |
| **Chạy sai thứ tự `DROP` sau khi thêm bảng** | 🔴 Cao | Lỗi FK, script dừng giữa chừng |
| **Đổi kiểu `NVARCHAR` → `VARCHAR`** | 🔴 Cao | Mất dấu tiếng Việt, `CHECK` từ chối dữ liệu đúng |
| **Đổi tên cột/bảng** | 🟠 Trung bình | Làm hỏng `scripts/*.sql` (dùng nhiều `dbo.` + tên cột) |
| **Bỏ `DEFAULT` khi thêm cột `NOT NULL`** | 🟠 Trung bình | `ALTER TABLE` thất bại |
| **Chạy phần `ALTER` nhiều lần** | 🟠 Trung bình | `CK_NL_DinhMuc`, `NgayVaoLam`, `UX_NhanVien_SDT` đã tồn tại → lỗi "already exists" |
| **Khoảng trống giữa `DROP` và `ADD` của `CK_Mon_GiaBan`** | 🟡 Thấp | Có thể lọt dữ liệu giá âm nếu chạy đồng thời |
| **Không chặn `MonAn` trỏ tới món `Nhom='U'`** | 🟡 Thấp | Lỗ hổng thiết kế, cần trigger ở M3 |
| **Không chặn 2 hóa đơn `Mở` trên cùng một bàn** | 🟡 Thấp | Hiện chỉ dữ liệu mẫu đảm bảo; cần trigger ở M3 |

---

## 7. Dữ liệu mẫu nằm ngoài `sql/` — thư mục `scripts/`

Hai file này **không nằm trong `sql/`** nhưng thuộc cùng chuỗi chạy, nên cần biết để hiểu trạng thái CSDL sau bước 2. Phần này giải thích ở mức **tổng quan logic**, không đi từng dòng.

### 7.1. `scripts/03a_DanhMuc.sql` — nạp dữ liệu danh mục

**Mục đích:** đổ dữ liệu giả lập (hư cấu, không dùng người thật) vào 8 bảng danh mục, theo đúng thứ tự phụ thuộc khóa ngoại.

**Cấu trúc:** một `BEGIN TRANSACTION ... COMMIT` trong `TRY...CATCH` — nghĩa là hoặc **tất cả** được nạp, hoặc **không dòng nào**.

```sql
BEGIN TRY
    BEGIN TRANSACTION;
        -- 8 khối INSERT theo thứ tự
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;          -- ném lại lỗi để người chạy biết đã hỏng
END CATCH;
```

Điểm đáng học trong đoạn `CATCH`:

- `IF XACT_STATE() <> 0` — chỉ rollback khi còn giao dịch đang mở. Nếu giao dịch đã tự rollback vì lỗi nặng, gọi `ROLLBACK` sẽ báo lỗi mới. Đây là **mẫu chuẩn**.
- `THROW;` (không tham số) — ném lại đúng lỗi gốc, giữ nguyên số hiệu và thông điệp. Nếu không có nó, script "nuốt" lỗi và người chạy tưởng là thành công.

**Dữ liệu thực tế (đã đếm trong file):**

| Bảng | Số dòng | Đặc điểm có chủ ý |
|---|---:|---|
| `LoaiMon` | 11 | 8 loại gốc + 3 loại con (đệ quy) |
| `Ban` | 15 | 5 "Có khách", 3 "Đã đặt", 7 "Trống" |
| `NhanVien` | 12 | 2 `QuanLy`, 3 `Bep`, 4 `PhucVu`, 3 `ThuNgan` |
| `NguyenLieu` | 28 | 2 dòng tồn = 0, 2 dòng tồn = định mức, 4 dòng dưới định mức, 2 dòng không dùng |
| `Mon` | 36 | 18 món ăn + 18 thức uống; 2 món `DangBan = 0` |
| `MonAn` | 18 | chỉ các món `Nhom = 'A'` |
| `ThucUong` | 18 | chỉ các món `Nhom = 'U'` |
| `DinhLuong` | 130 | 36 món × 3–4 nguyên liệu; 26/28 nguyên liệu được dùng |

**Các "dòng biên" được cài có chủ ý** (đây là yêu cầu Readme mục 3.3):

- Nguyên liệu `TonKho = 0`: **Thịt bò** (NL 4) và **Kem sữa** (NL 22). Cả hai đều đang được dùng trong `DinhLuong` → khi làm `sp_GoiMon` (M2) và trigger chặn tồn kho âm (M3), các món này **phải bị chặn**: Bò lúc lắc, Phở bò tái, Bò xào tỏi (dùng thịt bò), Kem dừa / Cà phê muối / Latte / Cà phê đá xay (dùng kem sữa).
- Nguyên liệu không xuất hiện trong `DinhLuong`: **Cà phê Arabica** (NL 19), **Bột matcha** (NL 24) → dùng để kiểm tra hàm `fn_NguyenLieuDuoiDinhMuc` và truy vấn `NOT EXISTS`.
- Món `DangBan = 0`: Tôm chiên giòn (5), Cà phê muối (22) → dùng để kiểm tra ràng buộc "chỉ gọi món đang bán".
- Món 35, 36 là món **chưa từng phát sinh giao dịch** → dùng cho truy vấn "món chưa bán được lần nào".

**Phần kiểm tra ở cuối file** (dòng 289–308) là 3 câu `SELECT` cho ra:

1. Số dòng 8 bảng danh mục.
2. Phân loại tồn kho: bằng 0 / bằng định mức / dưới định mức / trên định mức.
3. Danh sách nguyên liệu **không** được dùng trong `DinhLuong`.

### 7.2. `scripts/03b_GiaoDich.sql` — sinh giao dịch

**Mục đích:** sinh 1.500 hóa đơn và khoảng 5.300 dòng chi tiết, phân bố theo trạng thái và khung giờ, rồi tính `TongTien`; cuối file minh họa `INSERT`/`UPDATE`/`DELETE`.

**Cấu trúc 7 bước** (theo comment trong file):

| Bước | Nội dung |
|---|---|
| 0 | Kiểm tra tiền đề + **chặn chạy lại** (`THROW 50001..50003`, `50012`) |
| 1 | Tính số hóa đơn theo trạng thái: 7% hủy, phần còn lại "Đã thanh toán" |
| 2 | Sinh hóa đơn **Mở** cho các bàn đang "Có khách" (mỗi bàn đúng 1 hóa đơn) |
| 3 | Sinh hóa đơn đã thanh toán / hủy, phân bố ngày và khung giờ |
| 4 | `UPDATE` tính `TongTien` cho **tất cả** hóa đơn bằng một câu `LEFT JOIN` |
| 5 | Kiểm tra bất biến ngay trong transaction (`THROW 50013`, `50014` → rollback) |
| 6 | **Minh họa `INSERT` / `UPDATE` / `DELETE`** (Readme mục 3.2), net-zero |
| 7 | Các câu `SELECT` kiểm tra |

**Hai kỹ thuật đáng học:**

**① Sinh số ngẫu nhiên đúng cách — và lỗi đã sửa:**

Bản cũ chọn bàn/nhân viên bằng cách đặt `NEWID()` **ngay trong `WHERE`**:

```sql
-- BẢN CŨ (đã bỏ)
SELECT @MaNV = MaNV FROM @DSNV
WHERE Id = 1 + ABS(CHECKSUM(NEWID())) % @SoNV;
```

Bản mới tách thành hai bước: tính chỉ số ra biến trước, rồi mới so sánh.

```sql
-- BẢN MỚI
SET @ChiSo = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoNV AS INT);
SELECT @MaNV = MaNV FROM @DSNV WHERE Id = @ChiSo;
```

Vì sao vẫn nên viết như bản mới:

- **Đọc là hiểu**: "lấy chỉ số ngẫu nhiên 1..N, rồi lấy dòng thứ đó" — không phải suy luận xem `WHERE` được đánh giá mấy lần.
- **Không phụ thuộc optimizer**: biểu thức trong `WHERE` mà **không tham chiếu cột nào** hiện được SQL Server đánh giá **một lần cho cả câu lệnh**. Nhưng đó là hành vi của *cách lập kế hoạch*, không phải hợp đồng ngôn ngữ — đổi phiên bản, đổi dạng truy vấn là có thể khác.
- **`BIGINT` tránh tràn số**: `CHECKSUM` trả về `INT`, và `ABS(INT_MIN)` sẽ **ném lỗi tràn số**. `CAST(... AS BIGINT)` loại bỏ rủi ro này (xác suất rất nhỏ nhưng có thật).

> **Số đo thật (26/10/2026, SQL Server 2025):** chạy mô phỏng 5.000 lần với bảng 4 dòng, công thức **cũ cho 0 lần NULL** (mỗi lần khớp đúng 1 dòng, phân bố chọn 1..4 là 985/1016/1043/956 — khá đều). Nghĩa là **triệu chứng "30% NULL" không tái hiện được** trên phiên bản này. Việc sửa vẫn giữ vì các lý do ở trên, nhưng đừng ghi vào báo cáo là "đã sửa lỗi NULL" khi chưa chứng minh được.

- **Vì sao không dùng `RAND()`?** `RAND()` được đánh giá **một lần** cho mỗi câu lệnh, nên mọi dòng trong cùng lệnh nhận **cùng một giá trị**. Đây là lỗi kinh điển; cả bản cũ và mới đều tránh đúng bằng `CHECKSUM(NEWID())`.
- Hệ quả: **mỗi lần chạy cho dữ liệu khác nhau**. Không thể tái lập chính xác.

**② Số món mỗi hóa đơn: đã đơn giản hóa**

Bản cũ có một công thức `@MinMon` / `@MaxMon` chỉ để ép tổng chi tiết **đúng bằng 5.000**, kèm biến đếm `@TongCT`, `@SoCTConLai`, `@SoHDCoMonConLai` và hai mã lỗi `50007`, `50011`. Công thức đó:

- Khó giải thích (là đoạn phức tạp nhất file, dễ bị hỏi khi vấn đáp).
- Gây **lệch dữ liệu**: các hóa đơn ở **cuối** vòng lặp (đúng 5 hóa đơn rỗng + phần lớn hóa đơn `Hủy`) bị ép còn 1 món vì "quỹ" dòng đã gần hết.

Bản mới thay bằng một dòng, và `5.000` không còn là mục tiêu:

```sql
SET @SoMon = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoMonToiDa AS INT);  -- 1..6 món
```

Tổng số dòng vì thế **dao động quanh 5.250** (trung bình 3,5 món × 1.495 hóa đơn có món). Lần đo thực tế: **5.308**. Điều này vẫn vượt xa yêu cầu Readme ("≥ 1.000 dòng cho tối thiểu 2 bảng giao dịch"), nên không cần ép về một con số cố định.

> **Hệ quả khi làm báo cáo:** không được ghi cứng "ChiTietHoaDon có 5.000 dòng". Hãy ghi "khoảng 5.300 dòng" hoặc dẫn lại số đo kèm ngày chạy.


**Phân bố trạng thái mong đợi** (tính từ code, với dữ liệu `Ban` hiện tại có 5 bàn "Có khách"):

| Trạng thái | Số lượng | Cách tính |
|---|---:|---|
| `Mở` | 5 | = số bàn "Có khách" |
| `Đã thanh toán` | 1.390 | `(1500 − 5) − 105` |
| `Hủy` | 105 | `ROUND(1500 × 0.07)` |
| **Tổng** | **1.500** | |

Và **5 hóa đơn rỗng** (không có chi tiết) rơi vào nhóm 5 hóa đơn **cuối** của nhóm đã đóng — theo cách tính trên, đó là các hóa đơn `Hủy`. Tức là: **cả 5 hóa đơn rỗng đều ở trạng thái "Hủy"**.

> **Lưu ý quan trọng:** các con số trên **phụ thuộc vào dữ liệu `Ban`**. Nếu bạn sửa `scripts/03a_DanhMuc.sql` để có 8 bàn "Có khách", số hóa đơn `Mở` sẽ là 8 và `Đã thanh toán` giảm còn 1.387.

**Một chi tiết dễ bỏ qua nhưng ảnh hưởng tới báo cáo:** BƯỚC 4 tính `TongTien` cho **tất cả** hóa đơn, **kể cả hóa đơn `Hủy`**. Nghĩa là hóa đơn đã hủy vẫn có `TongTien > 0`. Vì vậy **mọi truy vấn doanh thu phải lọc** `WHERE TrangThai = N'Đã thanh toán'`, nếu không sẽ cộng cả tiền của hóa đơn hủy.

### 7.3. `scripts/04_TEST_VI_PHAM.sql` — kiểm chứng ràng buộc

**Mục đích:** đáp ứng gạch đầu dòng cuối của Readme mục 3.3 — chứng minh hệ thống **từ chối đúng** dữ liệu sai.

**Cách làm:** 10 lệnh cố tình sai, mỗi lệnh bọc trong `TRY…CATCH`. Lệnh nào lọt qua sẽ bị ghi `KetQua = 'KHÔNG BỊ CHẶN'` — tức là schema đang thiếu ràng buộc.

| # | Loại | Lệnh cố tình sai | Mã lỗi |
|---|---|---|---|
| 1 | `NOT NULL` | Chèn nhân viên với `HoTen = NULL` | 515 |
| 2 | `CHECK` | Bàn có `SucChua = 0` | 547 |
| 3 | `CHECK` | Bàn có `TrangThai = N'Bảo trì'` | 547 |
| 4 | `UNIQUE` | Bàn trùng `TenBan` | 2627 |
| 5 | `UNIQUE (index)` | Nhân viên trùng `SoDienThoai` | 2601 |
| 6 | `PRIMARY KEY` | Trùng cặp `(MaHD, MaMon)` | 2627 |
| 7 | `FOREIGN KEY` | Hóa đơn có `MaBan = 9999` | 547 |
| 8 | `FOREIGN KEY` | Món có `MaLoai = 9999` | 547 |
| 9 | `FOREIGN KEY` (tự tham chiếu) | `LoaiMon.MaLoaiCha = 9999` | 547 |
| 10 | `CHECK` | `UPDATE` đặt `TonKho = -1` | 547 |

**Ba kỹ thuật đáng học trong file này:**

1. **Dùng biến bảng `@ViPham` thay vì bảng tạm `#ViPham`.** Biến bảng **không bị `ROLLBACK` xóa**, nên kết quả kiểm chứng vẫn còn sau khi rollback cuối file.
2. **Một transaction bao trùm + `ROLLBACK` cuối file.** Nếu có lệnh nào lọt qua, dữ liệu vẫn về nguyên trạng. Cuối file có truy vấn đếm số dòng để chứng minh.
3. **Ca 3 từng bị chặn vì lý do SAI.** Ban đầu tên bàn dài 21 ký tự, vượt `TenBan NVARCHAR(20)`, nên lỗi nhận được là `2628` (truncate) chứ không phải `547` (`CK_Ban_TrangThai`). Đã sửa tên xuống `N'Bàn VP3'`. **Bài học:** khi viết test cho ràng buộc, phải kiểm tra **mã lỗi**, không chỉ kiểm tra "có lỗi".

**Kết quả đo thật:** 10 lần thử → 10 bị chặn, 0 lọt; số dòng các bảng không đổi.

### 7.4. Rủi ro của các script dữ liệu

| Rủi ro | Chi tiết |
|---|---|
| **Chống chạy lại (đã xử lý)** | `03b_GiaoDich.sql` `THROW 50012` nếu `HoaDon` đã có dòng → không thể nhân đôi dữ liệu. `03a_DanhMuc.sql` không có chốt, nhưng vi phạm khóa chính sẽ làm nó rollback (an toàn) |
| **Dữ liệu ngẫu nhiên** | Mỗi lần chạy khác nhau → số liệu báo cáo khác nhau giữa các máy |
| **Phụ thuộc `MaMon` cứng** | `03a_DanhMuc.sql` gán `MaMon` 1..36; chỉ đúng khi `Mon` đang rỗng |
| **Phụ thuộc dữ liệu `Ban`** | Số hóa đơn `Mở` = số bàn "Có khách"; sửa `Ban` sẽ đổi phân bố |
| **Chạy một phần** | Phần nạp dữ liệu bọc trong transaction, lỗi giữa chừng → rollback toàn bộ (an toàn). Nhưng nếu chạy **từng khối** bằng tay thì có thể dở dang |
| **Minh họa DML làm nhảy `IDENTITY`** | Bước 6.1 thêm rồi xóa một món → `Mon.MaMon` kế tiếp bị nhảy số. Không ảnh hưởng dữ liệu, nhưng đừng ngạc nhiên khi thấy `IDENT_CURRENT` lớn hơn 36 |

---

## 8. Những điểm thiết kế cần hiểu trước khi sửa

Tổng hợp các quyết định thiết kế quan trọng, để bạn không vô tình phá vỡ chúng:

| # | Quyết định | Lý do | Nếu phá vỡ |
|---|---|---|---|
| 1 | `MaMon` là PK + FK ở `MonAn`/`ThucUong` | Biểu diễn chuyên biệt hóa 1–0..1 | Thêm cột `MaMonAn` riêng → mất tính "mỗi món tối đa 1 dòng" |
| 2 | `DinhLuong` dùng PK ghép | Mỗi cặp (món, NL) duy nhất | Thêm cột ID → có thể trùng cặp, tính giá vốn sai |
| 3 | `ChiTietHoaDon` lưu `DonGia` sao chép | Giữ lịch sử giá | Bỏ cột → hóa đơn cũ hiển thị sai giá |
| 4 | `TongTien` lưu sẵn | Tốc độ đọc | Không tính lại khi sửa chi tiết → số liệu sai |
| 5 | `NVARCHAR` cho mọi chuỗi tiếng Việt | Giữ dấu | Dùng `VARCHAR` → mất dấu, `CHECK` từ chối dữ liệu |
| 6 | `DECIMAL` cho tiền và số lượng | Chính xác | Dùng `FLOAT` → sai số khi cộng tiền |
| 7 | Collation `Vietnamese_CI_AS` | So sánh tiếng Việt đúng | Đổi sang `_AI` → `N'co khach'` khớp `N'Có khách'`, ràng buộc mất tác dụng |
| 8 | `DangBan BIT` thay vì xóa món | Giữ lịch sử hóa đơn cũ | Xóa món → vi phạm FK từ `ChiTietHoaDon` |
| 9 | `TrangThai` dùng `CHECK` thay bảng tra cứu | Đơn giản | — (đánh đổi hợp lý cho quy mô bài tập) |
| 10 | Filtered unique index cho SĐT | Cho phép nhiều `NULL` | Dùng `UNIQUE` thường → chỉ 1 nhân viên được không có SĐT |

### 8.1. Ba lỗ hổng đã biết (chưa được xử lý)

Đây là các điểm **chưa có gì bảo vệ ở mức CSDL**, chỉ dựa vào dữ liệu mẫu hoặc quy ước:

1. **Không ràng buộc `MonAn`/`ThucUong` khớp `Mon.Nhom`.**
   Có thể thêm một thức uống vào `MonAn`. Cách sửa: trigger `INSTEAD OF INSERT` hoặc trigger `AFTER INSERT` kiểm tra `Mon.Nhom` (Readme xếp vào M3).

2. **Không chặn 2 hóa đơn `Mở` trên cùng một bàn.**
   Đây là quy tắc nghiệp vụ mà Readme mục 1 nêu rõ ("chặn bàn đang có khách nhận đặt thêm"). Hiện `scripts/03b_GiaoDich.sql` có câu kiểm tra phát hiện vi phạm, nhưng **không có ràng buộc nào ngăn chặn**. Cách sửa: trigger hoặc unique filtered index trên `HoaDon(MaBan) WHERE TrangThai = N'Mở'` *(gợi ý — cần nhóm bàn, vì unique index có điều kiện không cho phép nhiều hơn 1 dòng thỏa điều kiện)*.

3. **`Ban.TrangThai = N'Đã đặt'` chưa có dữ liệu hỗ trợ.**
   Trong mô hình **không có bảng đặt bàn** (reservation). Vậy trạng thái "Đã đặt" hiện chỉ là nhãn, không có thông tin ai đặt, đặt lúc nào, cho mấy người. Đây là **khoảng trống thiết kế** cần nhóm quyết định: giữ nguyên (chấp nhận hạn chế) hay bổ sung bảng `DatBan` ở M2/M3.

4. **`HoaDon` không có cột `MaKH`, `GiamGia`, `Thue`, `PhuongThucTT`.**
   Phù hợp phạm vi đề bài (không yêu cầu khách hàng/thuế), nhưng cần biết để không mô tả sai trong báo cáo.

---

## 9. Câu hỏi tự kiểm tra

Trả lời được những câu này nghĩa là bạn hiểu thư mục `sql/`, không chỉ chép lại:

1. Vì sao `01_CAUHINH_CSDL.sql` phải `USE master` trước khi `DROP DATABASE`?
2. Nếu xóa thư mục `C:\SQLData` rồi chạy lại script 01, chuyện gì xảy ra? Sửa thế nào cho **đúng**?
3. Vì sao `DROP TABLE` phải xóa `ChiTietHoaDon` trước `HoaDon`?
4. `MonAn.MaMon` vừa là `PRIMARY KEY` vừa là `FOREIGN KEY` — điều này cho phép và ngăn điều gì?
5. Vì sao `ChiTietHoaDon` phải lưu `DonGia` riêng thay vì `JOIN` sang `Mon` để lấy giá?
6. `COLLATE Vietnamese_CI_AS` có cho phép `N'co khach'` khớp `N'Có khách'` không? Vì sao?
7. Vì sao `ALTER TABLE NhanVien ADD NgayVaoLam DATE NOT NULL` cần kèm `DEFAULT`?
8. Chạy `scripts/03b_GiaoDich.sql` hai lần trên cùng CSDL sẽ ra bao nhiêu hóa đơn? Vì sao?
9. Hóa đơn `Hủy` có `TongTien > 0` không? Điều đó ảnh hưởng gì đến truy vấn doanh thu?
10. Nếu bạn thêm bảng `DatBan` vào `02_Bang.sql`, phải sửa những chỗ nào?

---

## 10. Điều chưa xác định hoặc chưa kiểm chứng

Trung thực về giới hạn của tài liệu:

| # | Nội dung | Trạng thái |
|---|---|---|
| 1 | **Kiểm chứng năm 2026-10-26:** `02`, `03a`, `03b`, `04` đã chạy thật trong CSDL tạm `QL_CAFE_TEST` (SQL Server 2025) và cho kết quả ở mục 7 | **Đã kiểm chứng** |
| 2 | Riêng `01_CAUHINH_CSDL.sql` chưa chạy (nó `DROP DATABASE` CSDL thật) | Chưa kiểm chứng |
| 3 | Quyền của tài khoản SQL Server dùng để chạy script (`CREATE DATABASE`, `DROP DATABASE`) | Chưa kiểm chứng |
| 4 | Có công cụ SSMS trên máy hay không; `sqlcmd` không có trên `PATH` | Đã kiểm tra một phần |
| 5 | `.cdm` / `.pdm` của PowerDesigner | **Không tồn tại** trong repo — Readme mục 3.10 vẫn yêu cầu nộp hai file này |
| 6 | Truy vấn, view, stored procedure, function, trigger | **Không tồn tại** — thuộc M2/M3 |
| 7 | Báo cáo, bảng phân công | **Không tồn tại** — Readme mục 3.9–3.12 yêu cầu. Nhật ký AI: xem `NhatKy_AI.md` |
| 8 | Việc đặt tên file có được chuẩn hóa theo Readme mục 3.10 hay không | **Một phần**: dữ liệu đã về `03a`/`03b`, nhưng `04_TEST_VI_PHAM` trùng số với `04_TruyVan_View`; `01_CAUHINH_CSDL` chưa đổi thành `01_CSDL` |
| 9 | Ý đồ gốc của `DinhMucTon` | **Suy luận** từ tên và cách dùng là "ngưỡng tồn tối thiểu", không có comment xác nhận |
| 10 | Có nên bổ sung bảng đặt bàn (`DatBan`) hay không | **Chưa có quyết định** — phụ thuộc phạm vi nhóm chọn |
| 11 | Thứ tự thực thi sau này khi có `04_TruyVan_View`–`08_ToiUu` | **Chưa xác định** — các file chưa tồn tại |
| 12 | Nội dung Readme mục 3.1 (Mô hình dữ liệu) | **Đang bị thay đổi**: tại thời điểm khảo sát, phần yêu cầu ERD/CDM/PDM trong mục 3.1 đã được thay bằng dòng `--- Bỏ qua`. Mục 3.10 **vẫn** yêu cầu nộp `.cdm`/`.pdm`. Chưa rõ đây là chủ ý hay đang sửa dở — nhóm cần xác nhận với giảng viên |

---

## Ghi nhớ nhanh

| Điều | Nội dung |
|---|---|
| Thứ tự chạy | `sql/01` → `sql/02` → `scripts/01` → `scripts/02` |
| Câu nguy hiểm nhất | `ALTER DATABASE ... SET SINGLE_USER WITH ROLLBACK IMMEDIATE` + `DROP DATABASE` |
| Điều kiện tiên quyết | SQL Server 2016+ · thư mục `C:\SQLData` · quyền `CREATE/DROP DATABASE` |
| Bảng quan trọng nhất | `ChiTietHoaDon` (giao dịch), `DinhLuong` (giá vốn), `Mon` (trung tâm) |
| Ràng buộc dễ quên | `TongTien` không tự cập nhật; `MonAn` không kiểm `Nhom`; 2 hóa đơn `Mở`/bàn không bị chặn |
| Khi sửa | Thêm bảng → sửa **2 chỗ** trong `02_Bang.sql`; không đổi `NVARCHAR`; không đổi collation |

Bản rút gọn: [Explain_TLDR.md](Explain_TLDR.md).
