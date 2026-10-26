# Explain_TLDR.md — Tra nhanh thư mục `sql/`

> Bản tóm tắt của [Explains.md](Explains.md). Đọc bản này để nắm nhanh; cần hiểu sâu thì mở đúng mục được ghi cuối mỗi phần.

**Dự án:** BT_CSDL — Đề tài 13 (nhà hàng / quán cà phê) · SQL Server · CSDL `QL_CAFE_NHAHANG`

---

## 1. `sql/` là gì

Thư mục **định nghĩa cấu trúc** CSDL. Dữ liệu mẫu thì nằm ở thư mục khác (`scripts/`), nhưng cả hai thuộc cùng một chuỗi chạy.

```text
sql/
├── 01_CAUHINH_CSDL.sql     29 dòng   Tạo CSDL + cấu hình file .mdf/.ldf
└── 02_Bang.sql            151 dòng   Tạo 10 bảng + khóa + ràng buộc + chỉ mục
```

Không có thư mục con, không có file nào khác. → chi tiết: [Explains.md](Explains.md) mục 3

---

## 2. Từng file làm gì

| File | Mục đích | Đối tượng tạo ra | Mục chi tiết |
|---|---|---|---|
| `01_CAUHINH_CSDL.sql` | Xóa CSDL cũ (nếu có) → tạo CSDL `QL_CAFE_NHAHANG`, collation `Vietnamese_CI_AS`, tách file dữ liệu 50MB và file log 20MB | 1 database, 2 file vật lý | [mục 5](Explains.md#5-file-sql01_cauhinh_csdlsql) |
| `02_Bang.sql` | Xóa 10 bảng cũ → tạo 10 bảng, khóa chính/ngoại, `CHECK`, `UNIQUE`, `DEFAULT`; cuối file thêm `ALTER TABLE` + chỉ mục | 10 bảng, 10 FK, 4 UNIQUE, ~20 CHECK, 1 filtered index | [mục 6](Explains.md#6-file-sql02_bangsql) |

---

## 3. Thứ tự chạy (bắt buộc)

```text
1. sql/01_CAUHINH_CSDL.sql
2. sql/02_Bang.sql
3. scripts/01_SEED.sql
4. scripts/02_SEED.sql
```

**Không được đảo.** Lý do ngắn gọn:

| Script | Cần gì trước | Sai thứ tự → |
|---|---|---|
| `02_Bang.sql` | CSDL đã tồn tại (`USE QL_CAFE_NHAHANG`) | `Cannot open database` |
| `scripts/01_SEED.sql` | 10 bảng tồn tại **và rỗng** (`IDENTITY` từ 1) | `MaMon` lệch → `DinhLuong` trỏ sai món |
| `scripts/02_SEED.sql` | Dữ liệu danh mục đã có | `THROW 50001/50002/50003`, script dừng |

→ chi tiết: [Explains.md](Explains.md) mục 4

**Chạy bằng `sqlcmd` phải có `-f 65001`**, nếu không tiếng Việt hỏng và `CHECK` sẽ từ chối dữ liệu đúng:

```bat
sqlcmd -S localhost -E -f 65001 -i sql\01_CAUHINH_CSDL.sql
```

---

## 4. 10 bảng và quan hệ cốt lõi

```text
LoaiMon ──< Mon ──< DinhLuong >── NguyenLieu     (N–N có thuộc tính SoLuong)
   │         │
   │         ├── MonAn      (1–0..1, chuyên biệt hóa: đồ ăn)
   │         └── ThucUong   (1–0..1, chuyên biệt hóa: thức uống)
   │
   └── LoaiMon.MaLoaiCha → LoaiMon (đệ quy)

Ban ──< HoaDon ──< ChiTietHoaDon >── Mon
         ▲
      NhanVien
```

| Bảng | Vai trò | Điểm cần nhớ |
|---|---|---|
| `LoaiMon` | Loại món | Tự tham chiếu `MaLoaiCha` → **chèn cha trước con** |
| `Ban` | Bàn | `TrangThai` 3 giá trị; `UQ_Ban_Ten` **không** phân biệt hoa/thường |
| `NhanVien` | Nhân viên | `ChucVu` 4 giá trị **không dấu**; `NgayVaoLam` thêm bằng `ALTER` |
| `NguyenLieu` | Nguyên liệu + tồn kho | `TonKho >= 0`; `DinhMucTon` = ngưỡng cảnh báo |
| `Mon` | Món (bảng cha) | `Nhom` = `'A'`/`'U'`; `GiaBan > 0` (sau `ALTER`) |
| `MonAn` | Món ăn | `MaMon` **vừa PK vừa FK** → mỗi món tối đa 1 dòng |
| `ThucUong` | Thức uống | Như trên; thêm `Size`, `CoDa`, `CoDuong` |
| `DinhLuong` | Công thức định lượng | PK ghép `(MaMon, MaNL)`; là nền của `fn_GiaVonMon` |
| `HoaDon` | Hóa đơn | `TrangThai`: `Mở`/`Đã thanh toán`/`Hủy` |
| `ChiTietHoaDon` | Chi tiết | PK ghép `(MaHD, MaMon)`; **`DonGia` là ảnh chụp giá** |

→ chi tiết từng cột: [Explains.md](Explains.md) mục 6.3–6.6 · sơ đồ + bảng ràng buộc: [mục 6.8–6.9](Explains.md#68-sơ-đồ-quan-hệ)

---

## 5. Bốn điều dễ hiểu sai nhất

| # | Điều | Giải thích ngắn |
|---|---|---|
| 1 | **`TongTien` không tự cập nhật** | Là dữ liệu dẫn xuất. Sửa `ChiTietHoaDon` → **phải tính lại** (hiện chưa có trigger) |
| 2 | **Hóa đơn `Hủy` vẫn có `TongTien > 0`** | Bước 4 của seed tính cho **mọi** hóa đơn. Truy vấn doanh thu **phải lọc** `TrangThai = N'Đã thanh toán'` |
| 3 | **`MonAn` không kiểm `Mon.Nhom`** | Có thể thêm thức uống vào `MonAn` mà không bị chặn — cần trigger M3 |
| 4 | **Không chặn 2 hóa đơn `Mở` / 1 bàn** | Chỉ dữ liệu mẫu đảm bảo, CSDL không có ràng buộc |

→ chi tiết: [Explains.md](Explains.md) mục 8.1

---

## 6. ⚠️ Cảnh báo an toàn

### Script phá hủy — mất dữ liệu, không hoàn tác

| Script | Tác động |
|---|---|
| `01_CAUHINH_CSDL.sql` | 🔴 `SINGLE_USER WITH ROLLBACK IMMEDIATE` + **`DROP DATABASE`** → xóa toàn bộ CSDL, đá mọi kết nối khác ra |
| `02_Bang.sql` | 🔴 **10 lệnh `DROP TABLE`** → xóa toàn bộ bảng và dữ liệu |
| `scripts/01_SEED.sql` | 🟠 Không xóa dữ liệu cũ, dùng `MaMon` **cứng** → chạy khi bảng không rỗng sẽ hỏng dữ liệu |
| `scripts/02_SEED.sql` | 🟠 **Không chống trùng** → chạy 2 lần ra **3.000** hóa đơn, mỗi bàn có 2 hóa đơn `Mở` |

👉 Chạy bất kỳ script nào ở trên: **báo nhóm trước.**

### Khi sửa script

- **Thêm bảng mới** → phải sửa **2 chỗ** trong `02_Bang.sql`: `DROP` ở đầu file (con trước, cha sau) + `CREATE` ở thân file. Thiếu một chỗ là script hỏng.
- **Không đổi `NVARCHAR` → `VARCHAR`** → mất dấu tiếng Việt, `CHECK` từ chối dữ liệu đúng.
- **Không đổi `COLLATE`** → `Vietnamese_CI_AS` = không phân biệt hoa/thường nhưng **có** phân biệt dấu. Đổi sang `_AI` thì `N'co khach'` sẽ khớp `N'Có khách'` và ràng buộc mất tác dụng.
- **Không đổi tên cột/bảng đã có** mà chưa báo nhóm → làm hỏng `scripts/*.sql` và truy vấn của người khác.
- **Không bỏ cột `ChiTietHoaDon.DonGia`** → đó là ảnh chụp giá, giữ lịch sử hóa đơn.
- **Không sửa `C:\SQLData` trong script** khi máy thiếu thư mục → hãy **tạo thư mục**, đừng commit đường dẫn riêng.
- Phần `ALTER TABLE` ở cuối `02_Bang.sql` **chỉ chạy được một lần** trên mỗi CSDL (chạy lại báo "already exists").

→ chi tiết: [Explains.md](Explains.md) mục 6.11 và 8

---

## 7. Điều kiện tiên quyết

- [ ] SQL Server **2016+** (do `DROP TABLE IF EXISTS`, filtered index)
- [ ] Thư mục **`C:\SQLData`** tồn tại (nếu chưa: tạo bằng quyền Administrator)
- [ ] Tài khoản có quyền **`CREATE DATABASE`** và **`DROP DATABASE`**
- [ ] File `.sql` giữ nguyên **UTF-8 không BOM**
- [ ] Nếu dùng `sqlcmd`: có tham số **`-f 65001`**

---

## 8. Kết quả mong đợi sau khi chạy đủ 4 script

> Các con số dưới đây là **giá trị script tự khai báo**, chưa được chạy thử và xác nhận trên môi trường này.

| Bảng | Số dòng |
|---|---:|
| `LoaiMon` | 11 |
| `Ban` | 15 |
| `NhanVien` | 12 |
| `NguyenLieu` | 28 |
| `Mon` | 36 |
| `MonAn` / `ThucUong` | 18 / 18 |
| `DinhLuong` | 130 |
| `HoaDon` | 1.500 (5 `Mở`, 1.390 `Đã thanh toán`, 105 `Hủy`) |
| `ChiTietHoaDon` | 5.000 |

Hóa đơn rỗng: **5** (đều ở trạng thái `Hủy`). Số `Mở` phụ thuộc số bàn `"Có khách"`.

Câu kiểm tra nhanh:

```sql
SELECT (SELECT COUNT(*) FROM dbo.Ban)      AS Ban,
       (SELECT COUNT(*) FROM dbo.Mon)      AS Mon,
       (SELECT COUNT(*) FROM dbo.HoaDon)   AS HoaDon,
       (SELECT COUNT(*) FROM dbo.ChiTietHoaDon) AS ChiTiet;
```

→ chi tiết: [Explains.md](Explains.md) mục 6.10 và 7

---

## 9. Những gì **chưa có** trong repo

Đừng tìm những thứ này — chúng chưa tồn tại:

- Không có view, stored procedure, function, trigger (thuộc **M2–M3**).
- Không có truy vấn nghiệp vụ.
- Không có file `.cdm`/`.pdm` (PowerDesigner), không có báo cáo, không có nhật ký AI.
- Không có script phân quyền, sao lưu, tối ưu.
- Tên file **chưa** theo danh sách `01_CSDL … 08_ToiUu` mà Readme mục 3.10 yêu cầu.

→ chi tiết: [Explains.md](Explains.md) mục 10

---

## 10. Mục lục tương ứng

| Cần tìm | Mở [Explains.md](Explains.md) |
|---|---|
| Cấu trúc thư mục, điều kiện tiên quyết | mục 3 |
| Thứ tự chạy, lý do, cách chạy SSMS/sqlcmd | mục 4 |
| Giải thích từng dòng `01_CAUHINH_CSDL.sql` | mục 5 |
| Giải thích từng dòng `02_Bang.sql` | mục 6 |
| Sơ đồ quan hệ + bảng tổng hợp ràng buộc | mục 6.8, 6.9 |
| Dữ liệu mẫu ở `scripts/` | mục 7 |
| Quyết định thiết kế + lỗ hổng đã biết | mục 8 |
| Câu hỏi tự kiểm tra | mục 9 |
| Giới hạn, điều chưa kiểm chứng | mục 10 |
