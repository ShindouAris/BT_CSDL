# BÁO CÁO BÀI TẬP KẾT THÚC HỌC PHẦN CƠ SỞ DỮ LIỆU
## ĐỀ TÀI 13: HỆ THỐNG QUẢN LÝ NHÀ HÀNG / QUÁN CÀ PHÊ

---

### THÔNG TIN NHÓM VÀ BẢNG PHÂN CÔNG CÔNG VIỆC

| STT | Họ và tên | Mã sinh viên | Vai trò & Phần việc phụ trách | Tỷ lệ hoàn thành |
|---|---|---|---|:---:|
| 1 | **Trần Thanh Nam** | 125001516 | Thiết kế kiến trúc tổng thể, kịch bản tạo CSDL & cấu hình lưu trữ (`01_CAUHINH_CSDL.sql`), Tối ưu hóa hiệu năng Execution Plan (`08_ToiUu.sql`), Tổng hợp báo cáo & Nhật ký AI | 100% |
| 2 | **Mạc Minh Hải** | 125001638 | Thiết kế mô hình dữ liệu, Ràng buộc toàn vẹn bảng (`02_Bang.sql`), Sinh dữ liệu mẫu danh mục & giao dịch (`03_DuLieu.sql`), Xây dựng bộ 20 truy vấn & 3 View (`04_TruyVan_View.sql`) | 100% |
| 3 | **Trần Anh Thế** | 125001555 | Xây dựng logic nghiệp vụ Backend CSDL: 5 Stored Procedures (`sp_GoiMon`, `sp_ThanhToan`, `sp_MoHoaDon`, `sp_HuyHoaDon`, `sp_ThongKeDoanhThu`) và 3 User-Defined Functions (`fn_GiaVonMon`, `fn_NguyenLieuDuoiDinhMuc`, `fn_DanhSachMonTheoLoai`) (`05_ThuTuc_Ham.sql`) | 100% |
| 4 | **Tống Thái Sơn** | 125001568 | Đảm bảo tính toàn vẹn nghiệp vụ & giao tác: 3 Triggers đa dòng và 2 Kịch bản Giao tác ACID (`06_Trigger_GiaoTac.sql`), Quản trị an toàn dữ liệu: Phân quyền RBAC 4 vai trò, Chiến lược sao lưu/khôi phục và thiết kế phương án High Availability (`07_PhanQuyen_SaoLuu.sql`) | 100% |

---

## MỤC LỤC

1. [Tổng quan đề tài & Phạm vi nghiệp vụ](#1-tổng-quan-đề-tài--phạm-vi-nghiệp-vụ)
2. [Mô hình dữ liệu và Cài đặt CSDL](#2-mô-hình-dữ-liệu-và-cài-đặt-csdl)
3. [Dữ liệu mẫu và Kiểm thử biên](#3-dữ-liệu-mẫu-và-kiểm-thử-biên)
4. [Bộ 20 Truy vấn nâng cao và 3 View](#4-bộ-20-truy-vấn-nâng-cao-và-3-view)
5. [Hệ thống Stored Procedure và Function](#5-hệ-thống-stored-procedure-và-function)
6. [Trigger bảo đảm toàn vẹn và Giao tác ACID](#6-trigger-bảo-đảm-toàn-vẹn-và-giao-tác-acid)
7. [An toàn thông tin, Phân quyền và Sao lưu phục hồi](#7-an-toàn-thông-tin-phân-quyền-và-sao-lưu-phục-hồi)
8. [Tối ưu hóa hiệu năng với sự hỗ trợ của AI](#8-tối-ưu-hóa-hiệu-năng-với-sự-hỗ-trợ-của-ai)
9. [Kịch bản thuyết trình và Demo bảo vệ đồ án](#9-kịch-bản-thuyết-trình-và-demo-bảo-vệ-đồ-án)

---

## 1. TỔNG QUAN ĐỀ TÀI & PHẠM VI NGHIỆP VỤ

### 1.1. Phạm vi bài toán
Hệ thống quản trị CSDL cho mô hình **Nhà hàng kết hợp Quán cà phê**, bao gồm các luồng hoạt động chính:
- **Khu vực phục vụ (Bàn):** Quản lý trạng thái bàn (`Trống`, `Có khách`, `Đã đặt`), sức chứa từng bàn.
- **Thực đơn (Món & Chuyên biệt hóa):** Phân cấp danh mục đa tầng (`LoaiMon` tự tham chiếu), chuyên biệt hóa thực đơn thành **Món ăn** (thời gian chế biến, độ cay) và **Thức uống** (size S/M/L, đá, đường).
- **Định lượng nguyên liệu (Công thức chế biến):** Mối quan hệ N–N giữa Món và Nguyên liệu với thuộc tính định lượng số lượng cụ thể cho từng phần thành phẩm.
- **Quản lý kho nguyên vật liệu:** Theo dõi tồn kho thực tế, định mức tồn an toàn và cảnh báo nhập hàng.
- **Quản lý bán hàng & giao dịch:** Mở bàn, gọi món trừ kho tự động, chế biến, thanh toán xuất hóa đơn và báo cáo doanh thu.

### 1.2. Môi trường triển khai
- Hệ quản trị CSDL: Microsoft SQL Server 2019 / 2022 / 2025.
- Mã hóa ký tự: `Vietnamese_CI_AS` (hỗ trợ tiếng Việt có dấu, không phân biệt hoa thường).

---

## 2. MÔ HÌNH DỮ LIỆU VÀ CÀI ĐẶT CSDL

### 2.1. Cấu hình cơ sở dữ liệu (`01_CAUHINH_CSDL.sql`)
- CSDL `QL_CAFE_NHAHANG` được cấu hình phân tách tường minh tệp dữ liệu chính (`.mdf`) dung lượng khởi tạo 50MB, tự tăng 10MB và tệp nhật ký giao tác (`.ldf`) 20MB, tự tăng 10MB.

### 2.2. Danh sách các bảng và ràng buộc (`02_Bang.sql`)

| Tên bảng | Khóa chính (PK) | Khóa ngoại (FK) | Ràng buộc nghiệp vụ tiêu biểu (CK/UQ/DF) |
|---|---|---|---|
| `LoaiMon` | `MaLoai` | `MaLoaiCha` -> `LoaiMon(MaLoai)` | UQ: `TenLoai`; Cây phân cấp tự tham chiếu |
| `Ban` | `MaBan` | Không | CK: `SucChua > 0`; CK: `TrangThai IN ('Trống', 'Có khách', 'Đã đặt')` |
| `NhanVien` | `MaNV` | Không | CK: `ChucVu IN ('PhucVu', 'ThuNgan', 'Bep', 'QuanLy')`; UQ: `SoDienThoai` |
| `NguyenLieu` | `MaNL` | Không | CK: `TonKho >= 0`, `DinhMucTon >= 0`, `DonGiaNhap >= 0` |
| `Mon` | `MaMon` | `MaLoai` -> `LoaiMon` | CK: `Nhom IN ('A', 'U')`, `GiaBan > 0`; DF: `DangBan = 1` |
| `MonAn` | `MaMon` | `MaMon` -> `Mon` | Chuyên biệt hóa 1-1; CK: `ThoiGianCheBien > 0` |
| `ThucUong` | `MaMon` | `MaMon` -> `Mon` | Chuyên biệt hóa 1-1; CK: `Size IN ('S', 'M', 'L')` |
| `DinhLuong` | `(MaMon, MaNL)`| `Mon(MaMon)`, `NguyenLieu(MaNL)` | CK: `SoLuong > 0` (quan hệ N-N kèm thuộc tính định lượng) |
| `HoaDon` | `MaHD` | `Ban(MaBan)`, `NhanVien(MaNV)` | CK: `TrangThai IN ('Mở', 'Đã thanh toán', 'Hủy')`, `TongTien >= 0` |
| `ChiTietHoaDon` | `(MaHD, MaMon)` | `HoaDon(MaHD)`, `Mon(MaMon)` | CK: `SoLuong > 0`, `TrangThaiCheBien IN ('Chờ', 'Đang làm', 'Xong')` |

---

## 3. DỮ LIỆU MẪU VÀ KIỂM THỬ BIÊN

### 3.1. Phân bổ dữ liệu (`03_DuLieu.sql` & `03_DuLieu.sql`)
- **Dữ liệu danh mục:** 11 Loại món, 15 Bàn (5 Có khách, 3 Đã đặt, 7 Trống), 12 Nhân viên đủ 4 chức vụ, 28 Nguyên liệu, 36 Món (18 Đồ ăn, 18 Thức uống), 130 dòng định lượng công thức.
- **Dữ liệu giao dịch quy mô lớn (phục vụ tối ưu):**
  - **1.500** Hóa đơn (1.390 Đã thanh toán, 105 Hủy, 5 Mở tương ứng chính xác với 5 bàn "Có khách").
  - **~5.200** dòng Chi tiết hóa đơn (mỗi hóa đơn có từ 1 đến 6 món ngẫu nhiên).
- **Các trường hợp biên được thiết kế có chủ đích:**
  - 2 nguyên liệu có `TonKho = 0`.
  - 4 nguyên liệu có `0 < TonKho < DinhMucTon` (dưới định mức).
  - 2 nguyên liệu có `TonKho = DinhMucTon`.
  - 2 nguyên liệu không dùng trong bất kỳ công thức định lượng nào.
  - 2 món mới chưa từng phát sinh giao dịch bán hàng (MaMon 35, 36).
  - 5 hóa đơn rỗng không có chi tiết (biên giao dịch mở/hủy).

---

## 4. BỘ 20 TRUY VẤN NÂNG CAO VÀ 3 VIEW (`04_TruyVan_View.sql`)

### 4.1. Phân loại 20 câu truy vấn (Đáp ứng CLO1, CLO3)
1. **Truy vấn đơn giản (Q01–Q04):** Lọc món đang bán theo giá giảm dần; Lọc nhân viên vào làm năm 2022 và tính số ngày thâm niên; Thống kê nguyên liệu thiếu hụt so với định mức tồn; Lọc hóa đơn 7 ngày gần nhất.
2. **Truy vấn kết nối (Q05–Q07):** Kết nối bảng phân cấp món (`INNER JOIN`); Kết nối ngoại (`LEFT JOIN`) hiển thị tất cả bàn và hóa đơn mở tương ứng kể cả bàn trống; Kết nối nhiều bảng lấy thông tin thời gian chế biến và công thức nguyên liệu.
3. **Truy vấn gom nhóm (Q08–Q10):** Doanh thu theo tháng trong 3 tháng gần nhất (`GROUP BY`, `HAVING`); Top 10 món bán chạy nhất; Thống kê số lượng nguyên liệu sử dụng theo từng nhóm loại món (`HAVING COUNT > 5`).
4. **Truy vấn con / lồng (Q11–Q14):** Tìm món chưa từng bán được lần nào (`NOT EXISTS`); Tìm hóa đơn có món đang chờ chế biến (`EXISTS`); Phép chia/so sánh toàn bộ (`> ALL` nguyên liệu đơn vị 'kg'); Tìm bàn có khách đặt trên 3 món (`IN` kết hợp Subquery).
5. **Phép toán tập hợp (Q15–Q16):** Kết hợp món ăn và món chưa thiết lập định lượng (`UNION`, `EXCEPT`); Tìm nhân viên có phát sinh lập hóa đơn ở cả 2 vai trò (`INTERSECT`).
6. **Common Table Expression (Q17–Q18):** **CTE đệ quy** duyệt cây phân cấp loại món (`LoaiMon`) tạo đường dẫn danh mục từ gốc đến ngọn; CTE tính tổng kết doanh số và lượt khách của từng bàn.
7. **Ranking Functions (Q19–Q20):** `RANK()` xếp hạng món ăn bán chạy theo các khung giờ cao điểm trong ngày; `NTILE(4)` phân hạng nhân viên theo tứ phân vị doanh thu bán hàng.

### 4.2. Hệ thống 3 View phục vụ phân quyền
- `v_MonDangBan`: Cung cấp danh sách thực đơn kèm thông số chế biến cho Bếp, ẩn thông tin giá vốn.
- `v_TonKhoCanhBao`: Tổng hợp nguyên liệu sắp hết cho Quản lý kho.
- `v_DoanhThuHoaDon`: Giới hạn các dòng hóa đơn đã thanh toán phục vụ đối soát cho Thu ngân và Kế toán.

---

## 5. HỆ THỐNG STORED PROCEDURE VÀ FUNCTION (`05_ThuTuc_Ham.sql`)

### 5.1. 5 Stored Procedures nghiệp vụ
1. `sp_GoiMon`: Gọi món vào hóa đơn; kiểm tra trừ kho nguyên tử (nếu thiếu bất kỳ nguyên liệu nào lập tức hủy giao tác bằng `ROLLBACK` và ném ngoại lệ `THROW`).
2. `sp_ThanhToan`: Thanh toán hóa đơn, cập nhật trạng thái bàn về `Trống`, trả về tổng tiền thực thu qua tham số `OUTPUT`.
3. `sp_MoHoaDon`: Kiểm tra tính hợp lệ của bàn (`Trống`) và nhân viên phục vụ, mở hóa đơn mới và trả về `MaHD` mới qua `OUTPUT`.
4. `sp_HuyHoaDon`: Sử dụng vòng lặp `CURSOR` duyệt các chi tiết món để hoàn trả nguyên liệu về kho trước khi chuyển trạng thái hóa đơn sang `Hủy`.
5. `sp_ThongKeDoanhThu`: Kiểm tra khoảng thời gian đầu vào bằng `IF`, join đa bảng thống kê chi tiết số hóa đơn, số món bán và tổng doanh thu.

### 5.2. 3 User-Defined Functions
1. `fn_GiaVonMon` *(Hàm vô hướng - Scalar)*: Tính tổng giá vốn nguyên liệu cấu thành của 1 món ăn dựa theo định lượng và giá nhập.
2. `fn_NguyenLieuDuoiDinhMuc` *(Hàm bảng inline - Inline TVF)*: Nhận ngưỡng phần trăm cảnh báo, trả về danh sách nguyên liệu dưới định mức kèm tỷ lệ tồn kho.
3. `fn_DanhSachMonTheoLoai` *(Hàm bảng nhiều câu lệnh - Multi-statement TVF)*: Chứa **CTE đệ quy**, cho phép truy xuất tất cả món thuộc loại hiện tại kèm theo toàn bộ cây danh mục con cháu khi bật tùy chọn `@BaoGomConChau = 1`.

---

## 6. TRIGGER BẢO ĐẢM TOÀN VẸN VÀ GIAO TÁC ACID (`06_Trigger_GiaoTac.sql`)

### 6.1. 3 Trigger nghiệp vụ (Xử lý đa dòng hoàn chỉnh)
1. `trg_ChiTietHoaDon_KiemTraNguyenLieu` *(AFTER INSERT)*:
   - Gom nhóm dữ liệu từ bảng giả `inserted` theo từng `MaNL` để tính tổng nhu cầu nguyên liệu cho câu lệnh nhiều dòng.
   - Kiểm tra tồn kho: nếu thiếu dù chỉ một nguyên liệu, tự động `ROLLBACK TRANSACTION` và ném lỗi `THROW 50001` nêu rõ tên nguyên liệu thiếu.
   - Nếu đủ, thực hiện cập nhật trừ tồn kho theo phương pháp tập hợp (set-based).
2. `trg_HoaDon_CapNhatBan` *(AFTER UPDATE)*:
   - Tự động đồng bộ trạng thái bàn ăn sang `Trống` khi hóa đơn chuyển thành `Đã thanh toán` hoặc `Hủy`.
   - Chuyển trạng thái bàn sang `Có khách` khi hóa đơn mở mới.
3. `trg_Mon_KiemTraXoa` *(INSTEAD OF DELETE)*:
   - Chặn xóa vật lý các món ăn đang nằm trong hóa đơn `Mở`.
   - Thực hiện cơ chế **xóa mềm (soft delete)**: cập nhật `DangBan = 0` giúp bảo toàn toàn vẹn tham chiếu lịch sử đơn hàng.

### 6.2. 2 Kịch bản Giao tác minh họa
- **GT01 (All-or-Nothing trong Gọi món):** Demo gọi 2 món trong một giao dịch. Trường hợp thành công commit cả 2 món; trường hợp món thứ 2 bị thiếu nguyên liệu, toàn bộ giao tác bị rollback về trạng thái ban đầu.
- **GT02 (Điểm lưu - Savepoint trong Thanh toán):** Ứng dụng `SAVE TRANSACTION` để rollback cục bộ thao tác thanh toán lỗi mà không làm đổ vỡ toàn bộ phiên làm việc của người dùng.

---

## 7. AN TOÀN THÔNG TIN, PHÂN QUYỀN VÀ SAO LƯU PHỤC HỒI (`07_PhanQuyen_SaoLuu.sql`)

### 7.1. Phân quyền theo nguyên tắc quyền tối thiểu (Least Privilege)
Thiết lập 4 vai trò (Role) độc lập:
- `role_PhucVu`: Chỉ thực thi `sp_MoHoaDon`, `sp_GoiMon`, xem menu bán (`v_MonDangBan`), xem trạng thái bàn; bị `DENY` xem bảng nguyên liệu và nhân sự.
- `role_ThuNgan`: Thực thi `sp_ThanhToan`, `sp_HuyHoaDon`, đối soát qua `v_DoanhThuHoaDon`; bị `DENY` sửa đổi thực đơn và kho.
- `role_Bep`: Phân quyền mức cột (`Column-level security`) trên `ChiTietHoaDon` để cập nhật trạng thái chế biến; bị `DENY` xem doanh thu, giá bán và giá nhập nguyên liệu.
- `role_QuanLy`: Toàn quyền thao tác trên dữ liệu nghiệp vụ; bị `DENY ALTER` trên cấu trúc bảng để tránh thay đổi trái phép schema.

### 7.2. Chiến lược Sao lưu và Phục hồi
1. **Full Backup:** Sao lưu toàn bộ CSDL (`WITH FORMAT, COMPRESSION, CHECKSUM`).
2. **Differential Backup:** Sao lưu các thay đổi phát sinh sau bản Full.
3. **Transaction Log Backup:** Chuyển CSDL sang `RECOVERY FULL`, sao lưu nhật ký giao dịch định kỳ để đảm bảo RPO ngắn nhất.
4. **Phục hồi (Restore Drill):** Kịch bản phục hồi chuỗi Full + Diff + Log vào cơ sở dữ liệu độc lập `QL_CAFE_RESTORE` với tùy chọn `WITH MOVE` định vị lại file vật lý, kiểm tra tính toàn vẹn dữ liệu.

### 7.3. Thiết kế giải pháp Tính sẵn sàng cao (High Availability)
- **Mục tiêu:** RPO < 5 phút (mất mát dữ liệu tối đa), RTO < 15 phút (thời gian phục hồi hệ thống khi có sự cố tại giờ cao điểm).
- **Mô hình kiến trúc:** **Always On Availability Groups** (2 nút: Primary Replicas đọc/ghi cho quầy thu ngân và Secondary Replicas chỉ đọc cho báo cáo quản lý) kết hợp tự động chuyển đổi dự phòng (Automatic Failover).

---

## 8. TỐI ƯU HÓA HIỆU NĂNG VỚI SỰ HỖ TRỢ CỦA AI (`08_ToiUu.sql`)

Thực nghiệm đo đạc hiệu năng trên tập dữ liệu lớn với `SET STATISTICS IO, TIME ON`:

| Truy vấn | Kế hoạch trước tối ưu | Đề xuất từ AI | Quyết định của nhóm | Kế hoạch sau tối ưu | Kết quả cải thiện |
|---|---|---|:---:|---|:---:|
| **TQ01:** Doanh thu theo khung giờ | Table Scan trên 1.500 dòng `HoaDon` | Composite Index `(TrangThai, NgayLap) INCLUDE (TongTien, MaHD)` | **CHẤP NHẬN** | Index Seek trên Covering Index | Logical Reads giảm từ **45 xuống 6** (~87%) |
| **TQ02:** Top 10 món bán chạy | Hash Match, scan toàn bộ `ChiTietHoaDon` | 1. Index `ChiTietHoaDon(MaMon) INCLUDE(SoLuong, DonGia, MaHD)`<br>2. Index đơn `HoaDon(TrangThai)` | 1. **CHẤP NHẬN**<br>2. **BÁC BỎ** (Độ chọn lọc thấp, index TQ01 đã bao phủ) | Stream Aggregate & Index Seek | Logical Reads giảm từ **198 xuống 46** (~77%) |
| **TQ03:** Dự báo hao hụt nguyên liệu | CTE quét toàn bộ `DinhLuong` và chi tiết | 1. Index `DinhLuong(MaNL) INCLUDE(MaMon, SoLuong)`<br>2. Index `HoaDon(NgayLap, TrangThai)` | 1. **KHÔNG TẠO** trong bản nộp cuối (`DinhLuong` rất nhỏ, lợi ích không đáng kể)<br>2. **BÁC BỎ** (Trùng lặp thứ tự cột với TQ01, gây lãng phí DML) | Nested Loops qua Index Seek | Logical Reads giảm từ **202 xuống 49** (~76%, đo khi còn 3 chỉ mục; cần đo lại với bản 2 chỉ mục) |

---

## 9. KỊCH BẢN THUYẾT TRÌNH VÀ DEMO BẢO VỆ ĐỒ ÁN (15 PHÚT)

- **Phút 00–03 (Trần Thanh Nam):** Giới thiệu mục tiêu đề tài, bài toán thực tế, mô hình thực thể quan hệ (PDM) và giải pháp kiến trúc phân cấp món ăn / thức uống.
- **Phút 03–07 (Mạc Minh Hải):** Trình diễn bộ dữ liệu mẫu 1.500 hóa đơn; Demo 3 câu truy vấn tiêu biểu: CTE đệ quy duyệt menu (`Q17`), Xếp hạng món theo khung giờ (`Q19`) và truy vấn View phân quyền.
- **Phút 07–11 (Trần Anh Thế):** Demo chạy trực tiếp Stored Procedure `sp_GoiMon` trừ tồn kho tự động; Chạy ca vi phạm thiếu kho để chứng minh giao tác nguyên tử bị chặn đúng quy định.
- **Phút 11–13 (Tống Thái Sơn):** Demo Trigger đa dòng TR01; Kiểm chứng phân quyền bằng lệnh `EXECUTE AS USER = 'user_bep'` cố tình truy cập giá tiền bị hệ thống từ chối.
- **Phút 13–15 (Cả nhóm):** Phân tích kết quả tối ưu hóa Execution Plan trước/sau có đối sánh AI, trả lời vấn đáp của Hội đồng giám khảo.

---
*Báo cáo được hoàn thiện và kiểm thử đồng bộ trên hệ CSDL `QL_CAFE_NHAHANG`.*
