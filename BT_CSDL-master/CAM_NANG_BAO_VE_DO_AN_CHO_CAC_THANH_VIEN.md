# CẨM NANG VẤN ĐÁP & BẢO VỆ ĐỒ ÁN HỆ QUẢN TRỊ CSDL
## ĐỀ TÀI 13: HỆ THỐNG QUẢN LÝ NHÀ HÀNG / QUÁN CÀ PHÊ (`QL_CAFE_NHAHANG`)
**Đơn vị đào tạo:** Khoa Công nghệ Thông tin — Đại học Lạc Hồng  
**Mục tiêu tài liệu:** Giúp **TẤT CẢ THÀNH VIÊN TRONG NHÓM** nắm chắc toàn bộ kiến trúc dự án, tự tin trả lời xuất sắc mọi câu hỏi vấn đáp của Giảng viên và đạt điểm tối đa (9.0 - 10.0).

---

# PHẦN 1: TỔNG QUAN HỆ THỐNG (MỌI THÀNH VIÊN ĐỀU PHẢI THUỘC LÒNG)

### 1.1. Mục tiêu và phạm vi đề tài
* **Đề tài:** Quản lý hoạt động kinh doanh của Nhà hàng / Quán cà phê kết hợp.
* **Quy mô CSDL:** Gồm **10 bảng** chuẩn hóa 3NF, chia thành 2 nhóm rõ rệt:
  1. **Nhóm Danh mục (8 bảng):** `LoaiMon`, `Ban`, `NhanVien`, `NguyenLieu`, `Mon`, `MonAn`, `ThucUong`, `DinhLuong`.
  2. **Nhóm Giao dịch (2 bảng):** `HoaDon` (>1.500 dòng), `ChiTietHoaDon` (>5.200 dòng).

### 1.2. Ba đặc trưng thiết kế nâng cao bắt buộc của đề tài (Giảng viên rất hay hỏi)
1. **Quan hệ N-N có thuộc tính (Định lượng nguyên liệu):**
   * Mối quan hệ giữa `Mon` và `NguyenLieu` là **N-N** thông qua bảng trung gian `DinhLuong`.
   * Bảng `DinhLuong` chứa thuộc tính quan trọng là `SoLuong` (định mức nguyên liệu tiêu hao cho 1 đơn vị món, ví dụ: 1 ly cà phê sữa cần 0.02kg cà phê hạt và 0.04 lít sữa đặc).
2. **Chuyên biệt hóa món ăn & thức uống (Inheritance - Kế thừa):**
   * Bảng cha: `Mon` (chứa các thuộc tính chung: `MaMon`, `TenMon`, `GiaBan`, `Nhom`, `DangBan`).
   * Bảng con 1: `MonAn` (chuyên biệt hóa với `ThoiGianCheBien`, `CayHayKhong`).
   * Bảng con 2: `ThucUong` (chuyên biệt hóa với `Size`, `CoDa`, `CoDuong`).
   * **Bản chất kỹ thuật:** Kế thừa rời rạc không giao nhau (`MutuallyExclusive = 1`, ràng buộc `CHECK (Nhom IN ('A', 'U'))`). Khóa chính của bảng con cũng chính là khóa ngoại trỏ về bảng cha (`1 - 0..1`).
3. **Cấu trúc cây danh mục đệ quy (Self-referencing FK):**
   * Bảng `LoaiMon` có cột `MaLoaiCha INT NULL REFERENCES LoaiMon(MaLoai)`.
   * Cho phép tổ chức danh mục cha - con không giới hạn cấp độ (Ví dụ: "Món ăn" [loại gốc] $\rightarrow$ "Món chính", "Khai vị" [loại con]).

### 1.3. Luồng nghiệp vụ cốt lõi từ đầu đến cuối
$$\text{Khách vào bàn} \xrightarrow[\text{sp\_MoHoaDon}]{\text{Bàn: Trống} \rightarrow \text{Có khách}} \text{Mở HĐ (Trạng thái: Mở)}$$
$$\downarrow$$
$$\text{Khách gọi món} \xrightarrow[\text{sp\_GoiMon / TR01}]{\text{Kiểm tra tồn kho \& Định lượng}} \text{Ghi ChiTietHoaDon, Trừ kho NguyenLieu}$$
$$\downarrow$$
$$\text{Khách thanh toán} \xrightarrow[\text{sp\_ThanhToan / TR02}]{\text{Tính tổng tiền thực tế}} \text{HĐ: Đã thanh toán} \rightarrow \text{Bàn tự động: Trống}$$

---

# PHẦN 2: PHÂN CÔNG BẢO VỆ CHI TIẾT TỪNG THÀNH VIÊN

---

##  THÀNH VIÊN 1: TRẦN THANH NAM (NHÓM TRƯỞNG)
* **Phụ trách chính:** Cấu hình CSDL (`01_CAUHINH_CSDL.sql`), Bảo mật & Sao lưu phục hồi (`07_PhanQuyen_SaoLuu.sql`), Tối ưu hóa hiệu năng (`08_ToiUu.sql`).

###  Nội dung Nam cần trình bày:
1. **Cấu hình CSDL (`01`):** CSDL tạo với Collation `Vietnamese_CI_AS` (hỗ trợ tiếng Việt không phân biệt hoa thường), tách file dữ liệu `QL_CAFE_Data.mdf` (50MB) và log `QL_CAFE_Log.ldf` (20MB) với tự động tăng trưởng `FILEGROWTH`.
2. **Bảo mật & Phân quyền (`07`):**
   * Thiết kế 4 Roles theo nguyên tắc **Đặc quyền tối thiểu (Least Privilege)**:
     * `role_PhucVu`: Chỉ SELECT menu, bàn; EXECUTE `sp_MoHoaDon`, `sp_GoiMon`. Bị DENY đọc lương, doanh thu, tồn kho.
     * `role_ThuNgan`: Chỉ xem hóa đơn, EXECUTE `sp_ThanhToan`. Bị DENY sửa menu, xóa nguyên liệu.
     * `role_Bep`: Chỉ xem món cần làm (`ChiTietHoaDon`), cập nhật `TrangThaiCheBien`. Bị DENY xem giá tiền (`TongTien`, `DonGiaNhap`).
     * `role_QuanLy`: Full quyền nghiệp vụ, nhưng bị **DENY ALTER/DROP** trên mọi bảng để tránh phá hỏng cấu trúc CSDL.
3. **Sao lưu & Phục hồi (`07`):**
   * Mô hình phục hồi: Chuyển sang **FULL Recovery Model**.
   * Chuỗi sao lưu chuẩn 3 bước: `BACKUP DATABASE FULL` $\rightarrow$ `DIFFERENTIAL` $\rightarrow$ `LOG`.
   * Phục hồi: Dùng kỹ thuật `NORECOVERY` qua từng chặng và kết thúc bằng `RECOVERY` đưa CSDL mới `QL_CAFE_RESTORE` online hoàn chỉnh.
4. **Tối ưu hiệu năng (`08`):**
   * Sử dụng Execution Plan, `STATISTICS IO`, `STATISTICS TIME`.
   * Thực hiện 3 ca tối ưu (TQ01, TQ02, TQ03). Chấp nhận các Covering Index giúp chuyển **Table Scan $\rightarrow$ Index Seek**, loại bỏ Key Lookup, giảm logical reads từ ~87% đến ~74%.
   * **Điểm sáng:** Bác bỏ 2 đề xuất của AI (Index đơn `TrangThai` và Index trùng lặp `NgayLap, TrangThai`) do low cardinality và lãng phí tài nguyên.

###  Câu hỏi Giảng viên hay hỏi Nam:
* **Hỏi:** *Tại sao em lại DENY ALTER TABLE đối với Role Quản lý?*
  * **Đáp:** Vì Quản lý chỉ quản trị dữ liệu kinh doanh (DML), không phải DBA hệ thống. Nếu cấp ALTER/DROP, họ có thể vô tình xóa cột, xóa ràng buộc làm sập ứng dụng POS.
* **Hỏi:** *Tại sao phục hồi Full và Diff lại phải dùng tùy chọn `NORECOVERY`?*
  * **Đáp:** `NORECOVERY` giữ CSDL ở trạng thái tiếp tục nhận các file backup tiếp theo (Diff hoặc Log). Nếu để `RECOVERY` ngay từ bản Full, CSDL sẽ mở online ngay và không thể nạp thêm bản Diff/Log được nữa.
* **Hỏi:** *Covering Index là gì? Trong bài em dùng ở đâu?*
  * **Đáp:** Là Index chứa đầy đủ tất cả các cột mà câu truy vấn cần (bằng mệnh đề `INCLUDE`), giúp SQL Server lấy dữ liệu trực tiếp từ cây B-Tree của Index mà không cần tốn chi phí **Key Lookup** về bảng dữ liệu gốc. Trong bài em dùng `IX_HoaDon_TrangThai_NgayLap INCLUDE (TongTien, MaHD)` ở bài 8.

---

##  THÀNH VIÊN 2: MẠC MINH HẢI
* **Phụ trách chính:** Thiết kế mô hình CDM/PDM, Tạo bảng & Ràng buộc toàn vẹn (`02_Bang.sql`), Dữ liệu mẫu (`03_DuLieu.sql`), Bộ 20 Truy vấn & 3 View (`04_TruyVan_View.sql`).

###  Nội dung Hải cần trình bày:
1. **Thiết kế CSDL & Ràng buộc (`02`):**
   * 10 bảng đạt chuẩn 3NF.
   * Đầy đủ các ràng buộc: Khóa chính (`PK`), Khóa ngoại (`FK`), Duy nhất (`UNIQUE` tên món, tên bàn, tên nguyên liệu), Mặc định (`DEFAULT`), và Ràng buộc miền giá trị (`CHECK` số lượng > 0, đơn giá $\ge$ 0, chức vụ nhân viên, trạng thái bàn...).
   * Kỹ thuật **Filtered Index:** `UX_NhanVien_SDT` trên cột `SoDienThoai` có `WHERE SoDienThoai IS NOT NULL` (cho phép nhiều nhân viên chưa có SĐT mà vẫn đảm bảo tính duy nhất khi đã nhập).
2. **Dữ liệu mẫu (`03`):**
   * Danh mục: Mỗi bảng có hơn 10 dòng chuẩn ngữ cảnh ẩm thực Việt Nam.
   * Giao dịch: Dùng thuật toán T-SQL sinh tự động >1.500 Hóa đơn và >5.200 Chi tiết hóa đơn ngẫu nhiên theo phân phối thời gian thực tế. Có cài đặt chặn chạy trùng lặp (`THROW 50012`).
3. **Kiểm thử vi phạm ràng buộc (`04` - Phần 1):**
   * Xây dựng **10 ca cố tình nhập sai** (nhập bàn trùng tên, sức chứa âm, tồn kho âm, chức vụ sai, giá tiền âm...). Toàn bộ 10 ca đều bị hệ thống chặn chính xác và ghi nhận kết quả tự động.
4. **Truy vấn T-SQL & View (`04` - Phần 2 & 3):**
   * Đầy đủ 20 câu truy vấn đa dạng: Đơn giản, Kết ngoài (`LEFT JOIN`), Gom nhóm `HAVING`, Truy vấn lồng (`EXISTS`, `IN`), Phép chia (tìm món được gọi trong tất cả hóa đơn của ngày), Phép tập hợp (`INTERSECT`), Window Function (`RANK`, `DENSE_RANK`), CTE đệ quy duyệt cây danh mục.
   * 3 View: `v_MonDangBan` (lọc menu), `v_TonKhoCanhBao` (lọc nguyên liệu nguy cấp), `v_DoanhThuHoaDon` (ẩn thông tin nhạy cảm để phục vụ thu ngân/báo cáo).

###  Câu hỏi Giảng viên hay hỏi Hải:
* **Hỏi:** *Câu truy vấn nào trong bài của em thể hiện phép chia đại số quan hệ?*
  * **Đáp:** Là câu **Q13** (Tìm món được gọi trong tất cả các hóa đơn của một ngày cụ thể). Em hiện thực bằng kỹ thuật **2 lần NOT EXISTS** (Không có hóa đơn nào trong ngày mà món đó không xuất hiện).
* **Hỏi:** *Tại sao câu Q05 lại phải dùng `LEFT JOIN` thay vì `INNER JOIN` đối với bảng LoaiMon?*
  * **Đáp:** Vì các loại món gốc (như "Cà phê Việt", "Trà") có `MaLoaiCha IS NULL`. Nếu dùng `INNER JOIN`, điều kiện nối sẽ loại bỏ toàn bộ các loại gốc này và làm mất các món thuộc loại đó. Dùng `LEFT JOIN` đảm bảo hiển thị đủ mọi món.
* **Hỏi:** *CTE đệ quy trong câu Q17 hoạt động như thế nào?*
  * **Đáp:** Gồm 2 phần nối nhau bằng `UNION ALL`: Phần Neo (Anchor member) chọn danh mục gốc cần tra cứu, và phần Đệ quy (Recursive member) tự kết nối lại bảng `LoaiMon` theo điều kiện `lm.MaLoaiCha = CTE.MaLoai` để duyệt qua toàn bộ các nhánh con cháu.

---

##  THÀNH VIÊN 3: TRẦN ANH THẾ
* **Phụ trách chính:** 5 Stored Procedure & 3 Function (`05_ThuTuc_Ham.sql`).

###  Nội dung Thế cần trình bày:
1. **5 Stored Procedure cốt lõi:**
   * **`sp_GoiMon`:** Nhận `@MaHD`, `@MaMon`, `@SoLuong`. Kiểm tra HĐ 'Mở', món đang bán, kiểm tra kho đủ nguyên liệu. Nếu hợp lệ: INSERT/UPDATE chi tiết, trừ kho, tính lại `TongTien`. **Đặc biệt:** Có cơ chế thông minh kiểm tra Trigger TR01 để tránh trừ trùng lặp tồn kho!
   * **`sp_ThanhToan`:** Nhận `@MaHD`, trả về `@TongTienThucThu` bằng tham số **`OUTPUT`**. Đổi trạng thái HĐ $\rightarrow$ 'Đã thanh toán', bàn tự đổi $\rightarrow$ 'Trống'.
   * **`sp_MoHoaDon`:** Kiểm tra bàn tồn tại, trạng thái bàn 'Trống', nhân viên là 'PhucVu'. Tạo HĐ mới, trả về `@MaHD` mới tạo qua `OUTPUT`, đổi bàn sang 'Có khách'.
   * **`sp_HuyHoaDon`:** Dùng **CURSOR** duyệt qua từng chi tiết của hóa đơn bị hủy để **cộng hoàn trả lại tồn kho** nguyên liệu cho nhà hàng, đổi trạng thái HĐ $\rightarrow$ 'Hủy'.
   * **`sp_ThongKeDoanhThu`:** Thống kê doanh thu theo từng tháng trong năm, có kiểm tra khoảng tháng `@ThangBatDau` $\le$ `@ThangKetThuc`.
2. **3 Function nghiệp vụ:**
   * **`fn_GiaVonMon` (Scalar Function):** Tính tổng giá vốn nguyên vật liệu cấu thành nên một món dựa vào bảng `DinhLuong` nhân với `DonGiaNhap` của `NguyenLieu`.
   * **`fn_NguyenLieuDuoiDinhMuc` (Inline Table-Valued Function):** Trả về danh sách các nguyên liệu có lượng tồn kho dưới ngưỡng % định mức cảnh báo, kèm tỷ lệ tồn kho tính toán tự động.
   * **`fn_DanhSachMonTheoLoai` (Multi-Statement TVF):** Trả về bảng danh sách món ăn, hỗ trợ tham số `@BaoGomConChau` để lấy món trực tiếp hoặc dùng CTE đệ quy lấy toàn bộ cây con cháu.

###  Câu hỏi Giảng viên hay hỏi Thế:
* **Hỏi:** *Tại sao trong `sp_GoiMon` lại có đoạn kiểm tra `ExecIsTriggerDisabled`?*
  * **Đáp:** Đây là giải pháp xử lý **xung đột nghiệp vụ giữa Procedure và Trigger**. Khi gọi món mới (INSERT), Trigger TR01 đã tự động trừ tồn kho. Procedure sẽ kiểm tra nếu Trigger đang bật thì SP không trừ kho nữa để tránh bị trừ 2 lần. Nhưng nếu là gọi thêm số lượng (UPDATE), trigger TR01 không bắt (chỉ bắt AFTER INSERT) thì chính SP sẽ tự trừ phần tăng thêm.
* **Hỏi:** *Khác biệt giữa Inline Table-Valued Function và Multi-Statement Table-Valued Function là gì?*
  * **Đáp:** 
    * Inline TVF (`fn_NguyenLieuDuoiDinhMuc`) chỉ chứa duy nhất một câu lệnh `RETURN (SELECT ...)`, không có thân `BEGIN...END`, SQL Server tối ưu như một View có tham số, hiệu năng rất cao.
    * Multi-Statement TVF (`fn_DanhSachMonTheoLoai`) có định nghĩa biến bảng trả về `@KetQua TABLE (...)`, có khối `BEGIN...END`, cho phép viết nhiều câu lệnh logic phức tạp (IF/ELSE, INSERT nhiều lần), nhưng chi phí tài nguyên cao hơn.
* **Hỏi:** *Tại sao trong `sp_HuyHoaDon` em lại phải đóng và deallocate CURSOR ở cả khối CATCH?*
  * **Đáp:** Để phòng ngừa trường hợp đang duyệt CURSOR mà xảy ra lỗi bất ngờ (như đứt kết nối hoặc vi phạm khóa), code sẽ nhảy vào khối CATCH. Nếu không giải phóng CURSOR trong CATCH, CURSOR sẽ bị treo ngầm trong bộ nhớ của session, gây rò rỉ tài nguyên (resource leak).

---

##  THÀNH VIÊN 4: TỐNG THÁI SƠN
* **Phụ trách chính:** 3 Trigger & 2 Kịch bản Giao tác Transaction (`06_Trigger_GiaoTac.sql`).

###  Nội dung Sơn cần trình bày:
1. **3 Trigger xử lý chuẩn Set-based:**
   * **`trg_ChiTietHoaDon_KiemTraNguyenLieu` (AFTER INSERT on `ChiTietHoaDon`):**
     * Không dùng CURSOR. Sử dụng bảng ảo `inserted` kết hợp CTE gom nhóm nhu cầu nguyên liệu theo `MaNL`.
     * Nếu thiếu bất kỳ nguyên liệu nào: Gom danh sách các nguyên liệu bị thiếu bằng hàm `STRING_AGG()` và phát sinh lỗi `THROW`, giao tác tự động ROLLBACK.
     * Nếu đủ nguyên liệu: Tự động trừ tồn kho `NguyenLieu.TonKho` bằng một câu lệnh `UPDATE ... FROM CTE` (Set-based, tối ưu tuyệt đối khi chèn nhiều dòng cùng lúc).
   * **`trg_HoaDon_CapNhatBan` (AFTER UPDATE on `HoaDon`):**
     * Theo dõi sự thay đổi của cột `TrangThai` bằng cách so sánh giữa bảng `deleted` (giá trị cũ) và `inserted` (giá trị mới).
     * Khi HĐ chuyển thành 'Đã thanh toán' hoặc 'Hủy' $\rightarrow$ tự động giải phóng `Ban.TrangThai = N'Trống'`. Khi HĐ 'Mở' $\rightarrow$ chuyển `Ban.TrangThai = N'Có khách'`.
   * **`trg_Mon_KiemTraXoa` (INSTEAD OF DELETE on `Mon`):**
     * Triển khai kỹ thuật **Xóa mềm (Soft Delete)**.
     * Khi người dùng phát lệnh DELETE món: Trigger kiểm tra nếu món đang có trong hóa đơn 'Mở' thì chặn lại (`THROW`). Nếu không, trigger thay thế lệnh xóa vật lý bằng lệnh cập nhật `DangBan = 0` (ẩn món khỏi menu).
2. **2 Kịch bản Giao tác (Transactions):**
   * **GT01 (Gọi nhiều món đồng thời):** Minh họa tính toàn vẹn **All-or-Nothing (Nguyên tử - Atomicity)**. Gọi món 1 đủ kho, món 2 thiếu kho $\rightarrow$ Cả giao tác bị ROLLBACK toàn bộ, không có dữ liệu rác lưu lại.
   * **GT02 (Thanh toán & Chuyển trạng thái):** Sử dụng điểm lưu **`SAVE TRANSACTION`**. Mô phỏng thanh toán hóa đơn hợp lệ (COMMIT) và hóa đơn sai trạng thái (ROLLBACK TO SAVEPOINT mà không hủy toàn bộ phiên làm việc).

###  Câu hỏi Giảng viên hay hỏi Sơn:
* **Hỏi:** *Tại sao viết Trigger trong SQL Server tuyệt đối không nên dùng CURSOR?*
  * **Đáp:** Vì câu lệnh INSERT/UPDATE của người dùng có thể tác động lên hàng ngàn dòng cùng lúc. Nếu dùng CURSOR, trigger phải duyệt tuần tự từng dòng (RBAR - Row-By-Agonizing-Row) làm khóa bảng và nghẽn hệ thống. Phải viết theo hướng **Set-based** (dùng tập hợp `inserted`/`deleted` kết hợp CTE/JOIN) để SQL Server xử lý song song trong bộ nhớ chỉ với 1 phép toán.
* **Hỏi:** *Bảng ảo `inserted` và `deleted` nằm ở đâu trong hệ thống?*
  * **Đáp:** Chúng là các bảng tạm đặc biệt do SQL Server tự động tạo và lưu trữ trong bộ nhớ RAM (thuộc tempdb), có cấu trúc hệt như bảng gốc đang gắn trigger. Khi kết thúc trigger, các bảng này tự động được giải phóng.
* **Hỏi:** *`INSTEAD OF Trigger` khác gì so với `AFTER Trigger`?*
  * **Đáp:** 
    * `AFTER Trigger` chỉ thực thi sau khi thao tác dữ liệu (INSERT/UPDATE/DELETE) đã vượt qua các ràng buộc và ghi tạm vào bảng.
    * `INSTEAD OF Trigger` sẽ chặn và **thay thế hoàn toàn** thao tác gốc. Lệnh gốc không hề được thực thi lên bảng mà hành động bên trong trigger sẽ chạy thay thế. Do đó em dùng `INSTEAD OF DELETE` để biến lệnh xóa vật lý thành cập nhật ẩn `DangBan = 0`.

---

# PHẦN 3: BỘ CÂU HỎI VẤN ĐÁP "BẪY" CHUNG CỦA GIẢNG VIÊN (CẢ NHÓM CẦN BIẾT)

1. **Hỏi:** *CSDL này có bị dư thừa dữ liệu (Redundancy) ở cột `TongTien` của bảng `HoaDon` không? Tại sao lại lưu `TongTien` khi đã có bảng `ChiTietHoaDon`?*
   * **Trả lời chuẩn:** Về mặt lý thuyết chuẩn hóa thuần túy, `TongTien` là dữ liệu dẫn xuất. Tuy nhiên trong thiết kế thực tế hệ thống bán hàng (OLTP), việc lưu sẵn `TongTien` là kỹ thuật **Bán chuẩn hóa (Denormalization)** có chủ đích:
     * Giúp các truy vấn xem danh sách hóa đơn, phân tích doanh thu hàng ngày chạy ngay lập tức mà không phải liên tục `SUM` hàng triệu dòng từ `ChiTietHoaDon`.
     * Để đảm bảo tính nhất quán, nhóm kiểm soát chặt chẽ bằng Stored Procedure và Trigger cập nhật tự động.
2. **Hỏi:** *Tại sao bảng `DinhLuong` và `ChiTietHoaDon` không dùng cột ID tự tăng làm khóa chính mà dùng Khóa chính phức hợp (Composite PK)?*
   * **Trả lời chuẩn:** Vì đây là các bảng liên kết đại diện cho mối quan hệ N-N. Dùng khóa chính phức hợp `(MaHD, MaMon)` hoặc `(MaMon, MaNL)` vừa làm khóa chính, vừa tự động ngăn chặn hoàn toàn việc chèn trùng lặp cùng 1 món vào 1 hóa đơn mà không cần phải tốn thêm chỉ mục phụ.
3. **Hỏi:** *Nếu quán mất điện đột ngột khi đang thanh toán hóa đơn, dữ liệu có bị hỏng hoặc mất tiền không?*
   * **Trả lời chuẩn:** Hoàn toàn không. Vì mọi thao tác thanh toán đều nằm trong một giao tác tường minh (`BEGIN TRANSACTION`). Khi có sự cố nguồn điện, tính năng **ACID (Atomicity & Durability)** và cơ chế Write-Ahead Logging (WAL) của SQL Server sẽ tự động quét file `.ldf` khi khởi động lại và ROLLBACK các giao tác đang dang dở về trạng thái an toàn ban đầu.

---

# PHẦN 4: KỊCH BẢN CHẠY DEMO TRỰC TIẾP TRÊN SSMS KHI BẢO VỆ

Nếu Giảng viên yêu cầu mở máy tính lên và chạy demo, nhóm thực hiện đúng quy trình 4 bước sau:

* **Bước 1 (Chuẩn bị CSDL):** Mở và chạy tuần tự `01_CAUHINH_CSDL.sql` $\rightarrow$ `02_Bang.sql` $\rightarrow$ `03_DuLieu.sql`.
* **Bước 2 (Chứng minh ràng buộc & dữ liệu):** Mở `04_TruyVan_View.sql`, bấm F5 chạy Phần 1: Màn hình sẽ hiện ra bảng kết quả **10 ca vi phạm bị chặn 10/10 (100% ĐẠT)**.
* **Bước 3 (Demo gọi món & trừ kho):** Mở `05_ThuTuc_Ham.sql` và `06_Trigger_GiaoTac.sql`:
  * Chạy câu SELECT xem tồn kho một nguyên liệu (ví dụ Cà phê hạt).
  * Chạy `EXEC sp_GoiMon` gọi 2 ly cà phê.
  * Chạy lại câu SELECT: Chỉ rõ cho Giảng viên thấy tồn kho cà phê hạt đã giảm chính xác đúng định lượng!
* **Bước 4 (Demo tối ưu Index):** Mở `08_ToiUu.sql`, bật phím tắt **`Ctrl + M` (Include Actual Execution Plan)**, chạy so sánh truy vấn trước và sau tối ưu: Chỉ vào thông số **Logical Reads giảm từ ~45 xuống còn ~6 reads (giảm ~87%)**.

---
*Tài liệu này được biên soạn bám sát 100% mã nguồn thực tế và Rubric chấm điểm của Đề tài 13. Chúc cả nhóm bảo vệ xuất sắc và đạt điểm tối đa!*
