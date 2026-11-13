# BỘ GIÁO DỤC VÀ ĐÀO TẠO
## TRƯỜNG ĐẠI HỌC LẠC HỒNG — KHOA CÔNG NGHỆ THÔNG TIN

---

# BÁO CÁO CUỐI KỲ
### HỌC PHẦN: HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU (111170)

---

## ĐỀ TÀI 13:
# XÂY DỰNG HỆ THỐNG QUẢN LÝ NHÀ HÀNG / QUÁN CÀ PHÊ

**Nhóm thực hiện:** Nhóm 13  
**Giảng viên hướng dẫn:** ThS. [Họ và tên Giảng viên]  
**Lớp học phần:** [Mã lớp học phần]  

### Bảng 0.1. Danh sách thành viên thực hiện đề tài
| STT | Họ và tên | MSSV | Vai trò trong nhóm | Tỷ lệ đóng góp |
|:---:|:---|:---:|:---|:---:|
| 1 | **Trần Thanh Nam** | 125001500 | Nhóm trưởng — Kiến trúc CSDL, Cấu hình, Phân quyền & Tối ưu hóa | 25% |
| 2 | **Mạc Minh Hải** | 125001638 | Thành viên — Mô hình hóa CDM/PDM, Ràng buộc, Dữ liệu mẫu & Truy vấn | 25% |
| 3 | **Trần Anh Thế** | 125001555 | Thành viên — Lập trình Stored Procedure & Function nghiệp vụ | 25% |
| 4 | **Tống Thái Sơn** | 125001568 | Thành viên — Lập trình Trigger đa dòng, Giao tác ACID & Sao lưu/Phục hồi | 25% |

*Đồng Nai, tháng 11 năm 2026*

---

# LỜI CAM ĐOAN

Nhóm sinh viên thực hiện đề tài số 13 xin cam đoan báo cáo này là công trình nghiên cứu và cài đặt do các thành viên trong nhóm trực tiếp tìm hiểu, thảo luận và hoàn thành dưới sự hướng dẫn chuyên môn của giảng viên phụ trách học phần Hệ quản trị Cơ sở dữ liệu.

Toàn bộ dữ liệu mẫu trong cơ sở dữ liệu `QL_CAFE_NHAHANG` được thiết kế và sinh ngẫu nhiên có chủ đích bằng sự hỗ trợ của các công cụ AI (ChatGPT, GitHub Copilot) dựa trên các nguyên tắc phân bổ thống kê và quan hệ khóa ngoại, hoàn toàn là dữ liệu giả lập, không sử dụng dữ liệu cá nhân hay thông tin nhạy cảm của bất kỳ tổ chức, cá nhân nào ngoài đời thực.

Các công cụ AI chỉ đóng vai trò hỗ trợ sinh mã nguồn khởi điểm, đề xuất chỉ mục và kiểm tra tính hợp lệ cú pháp. Toàn bộ mã lệnh T-SQL bao gồm bảng dữ liệu, ràng buộc toàn vẹn, truy vấn phân tích, view, thủ tục lưu trữ, hàm người dùng, trigger xử lý đa dòng, kịch bản giao tác ACID, phân quyền bảo mật, sao lưu phục hồi và phân tích Execution Plan đều đã được nhóm thực thi kiểm chứng thực tế 100% trên môi trường Microsoft SQL Server.

Mọi thành viên trong nhóm đều nắm vững kiến trúc hệ thống, hiểu tường tận logic từng dòng mã lệnh và sẵn sàng trả lời, phản biện các câu hỏi vấn đáp độc lập trước Hội đồng chấm thi.

*Đồng Nai, ngày 12 tháng 11 năm 2026*  
**Đại diện nhóm (Nhóm trưởng)**  
*(Ký và ghi rõ họ tên)*  
**Trần Thanh Nam**

---

# MỤC LỤC

- [LỜI CAM ĐOAN](#lời-cam-đoan)
- [CHƯƠNG 1. TỔNG QUAN VÀ PHÂN TÍCH BÀI TOÁN](#chương-1-tổng-quan-và-phân-tích-bài-toán)
  - [1.1. Giới thiệu đề tài và bối cảnh](#11-giới-thiệu-đề-tài-và-bối-cảnh)
  - [1.2. Mô tả nghiệp vụ và các quy trình chính](#12-mô-tả-nghiệp-vụ-và-các-quy-trình-chính)
  - [1.3. Yêu cầu dữ liệu và yêu cầu xử lý](#13-yêu-cầu-dữ-liệu-và-yêu-cầu-xử-lý)
  - [1.4. Các quy tắc nghiệp vụ](#14-các-quy-tắc-nghiệp-vụ)
- [CHƯƠNG 2. THIẾT KẾ VÀ MÔ HÌNH HÓA DỮ LIỆU](#chương-2-thiết-kế-và-mô-hình-hóa-dữ-liệu)
  - [2.1. Danh sách thực thể và thuộc tính](#21-danh-sách-thực-thể-và-thuộc-tính)
  - [2.2. Danh sách mối kết hợp](#22-danh-sách-mối-kết-hợp)
  - [2.3. Sơ đồ ERD (mô hình khái niệm – CDM)](#23-sơ-đồ-erd-mô-hình-khái-niệm--cdm)
  - [2.4. Cấu trúc nâng cao và quyết định thiết kế](#24-cấu-trúc-nâng-cao-và-quyết-định-thiết-kế)
  - [2.5. Mô hình vật lý (PDM) và lược đồ quan hệ](#25-mô-hình-vật-lý-pdm-và-lược-đồ-quan-hệ)
- [CHƯƠNG 3. CÀI ĐẶT CƠ SỞ DỮ LIỆU TRÊN SQL SERVER](#chương-3-cài-đặt-cơ-sở-dữ-liệu-trên-sql-server)
  - [3.1. Môi trường cài đặt](#31-môi-trường-cài-đặt)
  - [3.2. Tạo cơ sở dữ liệu](#32-tạo-cơ-sở-dữ-liệu)
  - [3.3. Script tạo bảng và ràng buộc](#33-script-tạo-bảng-và-ràng-buộc)
  - [3.4. Bổ sung và sửa ràng buộc bằng ALTER TABLE](#34-bổ-sung-và-sửa-ràng-buộc-bằng-alter-table)
  - [3.5. Danh mục ràng buộc trong cơ sở dữ liệu](#35-danh-mục-ràng-buộc-trong-cơ-sở-dữ-liệu)
- [CHƯƠNG 4. DỮ LIỆU MẪU VÀ KIỂM THỬ RÀNG BUỘC](#chương-4-dữ-liệu-mẫu-và-kiểm-thử-ràng-buộc)
  - [4.1. Quy trình sinh dữ liệu mẫu bằng AI](#41-quy-trình-sinh-dữ-liệu-mẫu-bằng-ai)
  - [4.2. Thống kê dữ liệu mẫu](#42-thống-kê-dữ-liệu-mẫu)
  - [4.3. Kiểm thử ràng buộc toàn vẹn](#43-kiểm-thử-ràng-buộc-toàn-vẹn)
- [CHƯƠNG 5. TRUY VẤN T-SQL VÀ VIEW](#chương-5-truy-vấn-t-sql-và-view)
  - [5.1. Tổng hợp các truy vấn](#51-tổng-hợp-các-truy-vấn)
  - [5.2. Chi tiết từng truy vấn (Q01 – Q20)](#52-chi-tiết-từng-truy-vấn)
  - [5.3. Truy vấn sinh từ ngôn ngữ tự nhiên (NL→SQL)](#53-truy-vấn-sinh-từ-ngôn-ngữ-tự-nhiên-nlsql)
  - [5.4. Các View](#54-các-view)
- [CHƯƠNG 6. STORED PROCEDURE VÀ FUNCTION](#chương-6-stored-procedure-và-function)
  - [6.1. Danh sách thủ tục và hàm](#61-danh-sách-thủ-tục-và-hàm)
  - [6.2. Chi tiết từng đối tượng](#62-chi-tiết-từng-đối-tượng)
  - [6.3. Kiểm thử](#63-kiểm-thử)
- [CHƯƠNG 7. GIAO TÁC VÀ TRIGGER](#chương-7-giao-tác-và-trigger)
  - [7.1. Danh sách trigger](#71-danh-sách-trigger)
  - [7.2. Mã nguồn và giải thích](#72-mã-nguồn-và-giải-thích)
  - [7.3. Kịch bản giao tác](#73-kịch-bản-giao-tác)
  - [7.4. Kiểm thử thao tác nhiều dòng](#74-kiểm-thử-thao-tác-nhiều-dòng)
- [CHƯƠNG 8. BẢO MẬT, PHÂN QUYỀN, SAO LƯU VÀ PHỤC HỒI](#chương-8-bảo-mật-phân-quyền-sao-lưu-và-phục-hồi)
  - [8.1. Login, user và role](#81-login-user-và-role)
  - [8.2. Ma trận phân quyền](#82-ma-trận-phân-quyền)
  - [8.3. Kiểm chứng phân quyền](#83-kiểm-chứng-phân-quyền)
  - [8.4. Sao lưu và phục hồi](#84-sao-lưu-và-phục-hồi)
  - [8.5. Phân tích phương án tính sẵn sàng cao (HA)](#85-phân-tích-phương-án-tính-sẵn-sàng-cao-ha)
- [CHƯƠNG 9. TỐI ƯU HIỆU NĂNG VỚI SỰ HỖ TRỢ CỦA AI](#chương-9-tối-ưu-hiệu-năng-với-sự-hỗ-trợ-của-ai)
  - [9.1. Các truy vấn được chọn](#91-các-truy-vấn-được-chọn)
  - [9.2. Execution Plan trước khi tối ưu](#92-execution-plan-trước-khi-tối-ưu)
  - [9.3. Đề xuất của AI và đánh giá của nhóm](#93-đề-xuất-của-ai-và-đánh-giá-của-nhóm)
  - [9.4. Chỉ mục đã tạo](#94-chỉ-mục-đã-tạo)
  - [9.5. So sánh trước và sau tối ưu](#95-so-sánh-trước-và-sau-tối-ưu)
- [CHƯƠNG 10. NHẬT KÝ SỬ DỤNG CÔNG CỤ AI](#chương-10-nhật-ký-sử-dụng-công-cụ-ai)
  - [10.1. Nhật ký sử dụng](#101-nhật-ký-sử-dụng)
  - [10.2. Đánh giá việc dùng AI](#102-đánh-giá-việc-dùng-ai)
- [CHƯƠNG 11. TỰ HỌC, TIẾN ĐỘ VÀ PHÂN CÔNG](#chương-11-tự-học-tiến-độ-và-phân-công)
  - [11.1. Phân công và mức độ đóng góp](#111-phân-công-và-mức-độ-đóng-góp)
  - [11.2. Tiến độ theo các mốc](#112-tiến-độ-theo-các-mốc)
  - [11.3. Nội dung tự tìm hiểu mở rộng](#113-nội-dung-tự-tìm-hiểu-mở-rộng)
  - [11.4. Nhật ký làm việc (ePortfolio)](#114-nhật-ký-làm-việc-eportfolio)
- [CHƯƠNG 12. KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN](#chương-12-kết-luận-và-hướng-phát-triển)
  - [12.1. Kết quả đạt được](#121-kết-quả-đạt-được)
  - [12.2. Hạn chế](#122-hạn-chế)
  - [12.3. Hướng phát triển](#123-hướng-phát-triển)
  - [12.4. Bài học rút ra](#124-bài-học-rút-ra)
- [TÀI LIỆU THAM KHẢO](#tài-liệu-tham-khảo)
- [PHỤ LỤC](#phụ-lục)
  - [Phụ lục A. Danh mục file nộp](#phụ-lục-a-danh-mục-file-nộp)
  - [Phụ lục B. Bảng nhóm tự kiểm tra theo rubric](#phụ-lục-b-bảng-nhóm-tự-kiểm-tra-theo-rubric)
  - [Phụ lục C. Script đầy đủ](#phụ-lục-c-script-đầy-đủ)

---

# CHƯƠNG 1. TỔNG QUAN VÀ PHÂN TÍCH BÀI TOÁN

### 1.1. Giới thiệu đề tài và bối cảnh
Trong nền kinh tế dịch vụ F&B (Food and Beverage) hiện đại, việc quản trị vận hành mô hình tích hợp Nhà hàng kết hợp Quán cà phê đặt ra những thách thức lớn về tốc độ phục vụ, quản lý kho nguyên liệu theo thời gian thực và kiểm soát doanh thu chặt chẽ. Hệ thống quản trị cơ sở dữ liệu đóng vai trò trái tim công nghệ của toàn bộ chuỗi vận hành, từ khâu tiếp đón khách, đặt bàn, gọi món tại quầy/tại bàn, chế biến tại bếp và quầy bar, xuất kho nguyên vật liệu cho đến đối soát hóa đơn thanh toán.

Đề tài số 13 tập trung xây dựng cơ sở dữ liệu chuyên biệt `QL_CAFE_NHAHANG` trên nền tảng Microsoft SQL Server. Mục tiêu của hệ thống là tự động hóa các luồng nghiệp vụ phức tạp: trừ tồn kho nguyên tử theo công thức định lượng ngay khi món ăn được gọi, phân loại đa cấp danh mục món ăn và thức uống, hỗ trợ phân quyền truy cập theo vai trò nhân viên nhằm bảo mật thông tin doanh số và công thức chế biến độc quyền, đồng thời tối ưu hóa tốc độ truy xuất trên các tập dữ liệu giao dịch quy mô lớn.

Hệ thống kế thừa toàn diện các nguyên lý cốt lõi từ học phần Cơ sở dữ liệu (mô hình quan hệ, chuẩn hóa dữ liệu 3NF, ràng buộc toàn vẹn dữ liệu) và phát triển chuyên sâu các kỹ thuật nâng cao của Hệ quản trị CSDL như cấu hình lưu trữ tệp vật lý, Stored Procedure, User-Defined Functions, Trigger kiểm soát đa dòng (multi-row set-based), giao tác tuân thủ chuẩn ACID (Atomicity, Consistency, Isolation, Durability), phân quyền theo nguyên tắc quyền tối thiểu (Least Privilege), chiến lược sao lưu khôi phục và tinh chỉnh hiệu năng bằng chỉ mục (Index Optimization).

### 1.2. Mô tả nghiệp vụ và các quy trình chính
Hệ thống bao gồm các quy trình vận hành chính sau:
1. **Quy trình mở bàn và đón tiếp khách:** Khi khách hàng đến quán, nhân viên phục vụ kiểm tra tình trạng bàn ăn trên hệ thống. Nếu bàn ở trạng thái 'Trống', nhân viên mở hóa đơn mới gắn liền với mã bàn và mã nhân viên. Trạng thái bàn tự động chuyển sang 'Có khách'.
2. **Quy trình gọi món và trừ kho tự động:** Khách hàng tiến hành chọn món ăn hoặc đồ uống từ thực đơn. Khi nhân viên xác nhận gọi món vào hóa đơn, hệ thống tự động tính toán nhu cầu nguyên liệu dựa theo bảng định lượng công thức. Hệ thống đối chiếu lượng nguyên liệu này với tồn kho thực tế: nếu bất kỳ nguyên liệu nào không đủ, toàn bộ thao tác gọi món bị hủy bỏ ngay lập tức (All-or-Nothing); nếu đủ nguyên liệu, hệ thống tự động trừ kho và cập nhật tổng tiền hóa đơn.
3. **Quy trình chế biến tại Bếp và Quầy Bar:** Sau khi gọi món thành công, các mục chi tiết được chuyển đến màn hình hiển thị của nhân viên Bếp (đối với món ăn) hoặc Quầy Pha Chế (đối với thức uống) ở trạng thái 'Chờ'. Nhân viên chế biến cập nhật tiến độ sang 'Đang làm' và 'Xong' khi hoàn thành.
4. **Quy trình thanh toán và đóng bàn:** Khi khách hàng yêu cầu thanh toán, thu ngân kiểm tra toàn bộ chi tiết món, in hóa đơn và nhận tiền. Trạng thái hóa đơn chuyển thành 'Đã thanh toán', đồng thời trạng thái bàn ăn tự động được đồng bộ chuyển về 'Trống' để sẵn sàng đón lượt khách tiếp theo.
5. **Quy trình hủy món / hủy hóa đơn và hoàn kho:** Trường hợp khách hàng yêu cầu hủy món hoặc hủy toàn bộ hóa đơn khi đang ở trạng thái 'Mở', hệ thống duyệt qua từng mục chi tiết và hoàn trả chính xác số lượng nguyên liệu đã trừ về lại kho lưu trữ trước khi chuyển trạng thái hóa đơn sang 'Hủy'.

### 1.3. Yêu cầu dữ liệu và yêu cầu xử lý
* **Về mặt dữ liệu:** Hệ thống quản lý 10 thực thể thông tin cốt lõi: danh mục loại món đa tầng (`LoaiMon`), sơ đồ bàn ăn và sức chứa (`Ban`), hồ sơ nhân sự và phân định chức vụ (`NhanVien`), kho nguyên vật liệu và đơn giá nhập (`NguyenLieu`), thực đơn món tổng quát (`Mon`), thực đơn chuyên biệt món ăn (`MonAn`), thực đơn chuyên biệt đồ uống (`ThucUong`), công thức định lượng nguyên vật liệu (`DinhLuong`), sổ cái giao dịch hóa đơn (`HoaDon`) và chi tiết các dòng món được gọi (`ChiTietHoaDon`).
* **Về mặt xử lý nghiệp vụ backend:** CSDL hiện thực hoàn chỉnh: 5 Stored Procedure (mở bàn, gọi món nguyên tử, thanh toán trả về tổng tiền qua OUTPUT, hủy hóa đơn hoàn kho bằng CURSOR, thống kê doanh số theo kỳ); 3 Function (tính giá vốn thành phẩm - Scalar, lọc cảnh báo tồn kho - Inline TVF, duyệt cây phân cấp menu đệ quy - Multi-statement TVF); 3 Trigger bảo vệ toàn vẹn dữ liệu đa dòng; 2 kịch bản giao tác ACID; phân quyền bảo mật 4 nhóm người dùng và kịch bản phục hồi thảm họa.

### 1.4. Các quy tắc nghiệp vụ
Bảng 1.1 tổng hợp các quy tắc nghiệp vụ làm căn cứ hiện thực xuyên suốt toàn bộ hệ thống:

#### Bảng 1.1. Danh mục các quy tắc nghiệp vụ của hệ thống
| Mã | Tên quy tắc nghiệp vụ | Mô tả chi tiết | Hiện thực kỹ thuật |
|:---:|:---|:---|:---|
| **QT1** | Tính duy nhất của hóa đơn mở tại bàn | Mỗi bàn ăn tại một thời điểm chỉ có tối đa một hóa đơn ở trạng thái 'Mở'. Bàn đang có khách không được phép mở thêm hóa đơn mới. | Stored Procedure (`sp_MoHoaDon`), Ràng buộc CHECK |
| **QT2** | Món kinh doanh hợp lệ | Món ăn hoặc thức uống chỉ được phép gọi vào hóa đơn khi đang trong trạng thái kinh doanh (`DangBan = 1`). Món ngừng bán không được tiếp nhận. | Stored Procedure (`sp_GoiMon`), Trigger (`trg_Mon_KiemTraXoa`) |
| **QT3** | Nguyên tử trong trừ kho định lượng | Khi gọi món, hệ thống phải kiểm tra trừ kho nguyên liệu theo định lượng. Nếu thiếu dù chỉ 1 thành phần thì toàn bộ thao tác gọi món phải bị hủy (All-or-Nothing). | Trigger (`trg_ChiTietHoaDon_KiemTraNguyenLieu`), Transaction |
| **QT4** | Đồng bộ tự động trạng thái bàn | Khi hóa đơn chuyển sang 'Đã thanh toán' hoặc 'Hủy', bàn ăn phải tự động chuyển thành 'Trống'. Khi mở hóa đơn, bàn tự động chuyển sang 'Có khách'. | Trigger (`trg_HoaDon_CapNhatBan`), Stored Procedure |
| **QT5** | Bảo toàn lịch sử qua xóa mềm | Không được xóa vật lý (hard delete) các món ăn đang có trong các hóa đơn mở hoặc lịch sử bán hàng. Thao tác xóa được thay thế bằng ẩn món (`DangBan = 0`). | Trigger INSTEAD OF DELETE (`trg_Mon_KiemTraXoa`) |
| **QT6** | Tính dương của giá trị tiền tệ | Giá bán món (`GiaBan > 0`), đơn giá nhập nguyên liệu (`DonGiaNhap >= 0`), đơn giá chi tiết (`DonGia >= 0`) và tổng tiền hóa đơn (`TongTien >= 0`) không được âm. | Ràng buộc CHECK (`CK_Mon_GiaBan`, `CK_NL_DonGia`...) |
| **QT7** | Sức chứa bàn hợp lệ | Sức chứa của mỗi bàn ăn phải là số nguyên dương (`SucChua > 0`), tránh tình trạng bàn không có chỗ ngồi. | Ràng buộc CHECK (`CK_Ban_SucChua`) |
| **QT8** | Phân quyền đúng thẩm quyền nghiệp vụ | Chỉ nhân viên có chức vụ Phục vụ mới được quyền mở hóa đơn. Thu ngân chịu trách nhiệm thanh toán và đối soát. Bếp không được xem thông tin giá cả. | Phân quyền RBAC, SQL Server Roles (`role_PhucVu`, `role_Bep`...) |

---

# CHƯƠNG 2. THIẾT KẾ VÀ MÔ HÌNH HÓA DỮ LIỆU

### 2.1. Danh sách thực thể và thuộc tính
Hệ thống gồm 10 thực thể chuẩn hóa 3NF:

#### Bảng 2.1. Danh mục các thực thể và thuộc tính trong hệ thống
| STT | Thực thể | Thuộc tính (khóa chính gạch chân) | Mô tả nghiệp vụ |
|:---:|:---|:---|:---|
| 1 | **LOAIMON** | <u>MaLoai</u>, TenLoai, MaLoaiCha | Phân loại thực đơn đa cấp; `MaLoaiCha` tự tham chiếu đệ quy cây danh mục. |
| 2 | **BAN** | <u>MaBan</u>, TenBan, SucChua, TrangThai | Quản lý cơ sở vật chất bàn ăn; trạng thái gồm 'Trống', 'Có khách', 'Đã đặt'. |
| 3 | **NHANVIEN** | <u>MaNV</u>, HoTen, ChucVu, SoDienThoai, NgayVaoLam | Nhân sự quán thuộc 4 vai trò: PhucVu, ThuNgan, Bep, QuanLy. |
| 4 | **NGUYENLIEU** | <u>MaNL</u>, TenNL, DonViTinh, TonKho, DinhMucTon, DonGiaNhap | Quản lý kho nguyên vật liệu thô; kiểm soát ngưỡng tồn an toàn. |
| 5 | **MON** | <u>MaMon</u>, TenMon, MaLoai, GiaBan, Nhom, DangBan | Thực đơn tổng thể; `Nhom` phân biệt đồ ăn ('A') và thức uống ('U'); `DangBan` phục vụ xóa mềm. |
| 6 | **MONAN** | <u>MaMon</u>, ThoiGianCheBien, CayHayKhong | Chuyên biệt hóa của MON dành cho đồ ăn; thời gian nấu (phút) và độ cay. |
| 7 | **THUCUONG** | <u>MaMon</u>, Size, CoDa, CoDuong | Chuyên biệt hóa của MON dành cho đồ uống; kích cỡ ly (S, M, L), đá và đường. |
| 8 | **DINHLUONG** | <u>MaMon</u>, <u>MaNL</u>, SoLuong | Mối quan hệ N-N giữa MON và NGUYENLIEU; định lượng nguyên liệu cho 1 đơn vị món. |
| 9 | **HOADON** | <u>MaHD</u>, MaBan, MaNV, NgayLap, TrangThai, TongTien | Giao dịch thanh toán; trạng thái: 'Mở', 'Đã thanh toán', 'Hủy'. |
| 10 | **CHITIETHOADON** | <u>MaHD</u>, <u>MaMon</u>, SoLuong, DonGia, TrangThaiCheBien | Chi tiết các món được gọi; tiến độ chế biến: 'Chờ', 'Đang làm', 'Xong'. |

### 2.2. Danh sách mối kết hợp
Hệ thống đáp ứng đủ yêu cầu với 2 mối kết hợp N-N có thuộc tính riêng, cùng các mối kết hợp phân cấp và chuyên biệt hóa:

#### Bảng 2.2. Danh mục các mối kết hợp giữa các thực thể
| STT | Mối kết hợp | Các thực thể tham gia | Bản số | Thuộc tính riêng | Ý nghĩa nghiệp vụ |
|:---:|:---|:---:|:---:|:---|:---|
| 1 | **Định lượng chế biến** | MON – NGUYENLIEU | N – N | `SoLuong` (DECIMAL(12,3)) | Một món cấu thành từ nhiều nguyên liệu; một nguyên liệu tham gia vào nhiều món. |
| 2 | **Chi tiết gọi món** | HOADON – MON | N – N | `SoLuong`, `DonGia`, `TrangThaiCheBien` | Một hóa đơn có thể gọi nhiều món; một món xuất hiện trong nhiều hóa đơn. |
| 3 | **Phân loại thực đơn** | LOAIMON – MON | 1 – N | Không | Một loại món chứa nhiều món; mỗi món thuộc duy nhất một loại danh mục. |
| 4 | **Phân cấp danh mục** | LOAIMON – LOAIMON | 1 – N | Không | Quan hệ đệ quy: loại món cha quản lý nhiều loại món con. |
| 5 | **Phục vụ tại bàn** | BAN – HOADON | 1 – N | Không | Một bàn phục vụ nhiều hóa đơn qua các lượt khách; tại 1 thời điểm chỉ 1 HĐ 'Mở'. |
| 6 | **Lập hóa đơn** | NHANVIEN – HOADON | 1 – N | Không | Một nhân viên phụ trách lập và xử lý nhiều hóa đơn. |
| 7 | **Chuyên biệt hóa món ăn** | MON – MONAN | 1 – 1 | `ThoiGianCheBien`, `CayHayKhong` | Mỗi món ăn là bản ghi chuyên biệt hóa mở rộng từ bảng MON. |
| 8 | **Chuyên biệt hóa đồ uống** | MON – THUCUONG | 1 – 1 | `Size`, `CoDa`, `CoDuong` | Mỗi đồ uống là bản ghi chuyên biệt hóa mở rộng từ bảng MON. |

### 2.3. Sơ đồ ERD (mô hình khái niệm – CDM)
Sơ đồ CDM được thiết kế chuẩn xác bằng Sybase PowerDesigner, phản ánh đầy đủ các thực thể, thuộc tính và liên kết ngữ nghĩa:

```
[Hình 2.1: Sơ đồ Mô hình Khái niệm (CDM) xuất từ PowerDesigner file MoHinh_CDM.cdm]
```
*Hình 2.1. Mô hình thực thể kết hợp (CDM) của hệ thống Nhà hàng - Quán cà phê*

### 2.4. Cấu trúc nâng cao và quyết định thiết kế
1. **Chuyên biệt hóa (Specialization / Generalization):** Thực thể `MON` đóng vai trò siêu loại (Supertype). Hai thực thể `MONAN` và `THUCUONG` là kiểu con (Subtype) kế thừa hoàn toàn từ `MON` qua quan hệ 1-1 rời rạc (`MutuallyExclusive = 1`). Khóa chính của bảng con cũng đồng thời là khóa ngoại tham chiếu về `MON(MaMon)`. Thiết kế này loại bỏ các cột NULL không cần thiết, tối ưu hóa bộ nhớ và cho phép mở rộng thuộc tính riêng trong tương lai mà không làm vỡ cấu trúc bảng cha.
2. **Quan hệ N–N có thuộc tính định lượng:** Mối liên kết giữa `MON` và `NGUYENLIEU` được tách thành thực thể kết hợp `DINHLUONG` với khóa chính phức hợp `(MaMon, MaNL)` và thuộc tính riêng `SoLuong` (kiểu `DECIMAL(12,3)`). Cấu trúc này là nền tảng để hệ thống tự động trừ kho nguyên tử khi gọi món.
3. **Quan hệ đệ quy (Recursive Relationship):** Thực thể `LOAIMON` chứa thuộc tính `MaLoaiCha` tự tham chiếu đến chính `MaLoai` của cùng bảng, tạo nên cây phân cấp danh mục món ăn không giới hạn số tầng (n-tier category tree), hỗ trợ duyệt cây bằng CTE đệ quy.

### 2.5. Mô hình vật lý (PDM) và lược đồ quan hệ
Lược đồ quan hệ chuẩn hóa (Khóa chính gạch chân, khóa ngoại có dấu `#` phía trước):
1. `LOAIMON` (<u>MaLoai</u>, TenLoai, #MaLoaiCha)
2. `BAN` (<u>MaBan</u>, TenBan, SucChua, TrangThai)
3. `NHANVIEN` (<u>MaNV</u>, HoTen, ChucVu, SoDienThoai, NgayVaoLam)
4. `NGUYENLIEU` (<u>MaNL</u>, TenNL, DonViTinh, TonKho, DinhMucTon, DonGiaNhap)
5. `MON` (<u>MaMon</u>, TenMon, #MaLoai, GiaBan, Nhom, DangBan)
6. `MONAN` (<u>#MaMon</u>, ThoiGianCheBien, CayHayKhong)
7. `THUCUONG` (<u>#MaMon</u>, Size, CoDa, CoDuong)
8. `DINHLUONG` (<u>#MaMon</u>, <u>#MaNL</u>, SoLuong)
9. `HOADON` (<u>MaHD</u>, #MaBan, #MaNV, NgayLap, TrangThai, TongTien)
10. `CHITIETHOADON` (<u>#MaHD</u>, <u>#MaMon</u>, SoLuong, DonGia, TrangThaiCheBien)

#### Bảng 2.3. Chi tiết thiết kế vật lý các bảng trong CSDL QL_CAFE_NHAHANG
| Bảng | Khóa chính | Khóa ngoại (Tham chiếu) | Kiểu dữ liệu và ràng buộc miền giá trị chính |
|:---|:---|:---|:---|
| **LoaiMon** | `MaLoai` (INT IDENTITY) | `MaLoaiCha` $\rightarrow$ `LoaiMon(MaLoai)` | `TenLoai`: NVARCHAR(50) NOT NULL UNIQUE; `MaLoaiCha`: INT NULL |
| **Ban** | `MaBan` (INT IDENTITY) | Không | `TenBan`: NVARCHAR(20) NOT NULL UNIQUE; `SucChua`: TINYINT > 0; `TrangThai`: NVARCHAR(10) IN ('Trống', 'Có khách', 'Đã đặt') |
| **NhanVien** | `MaNV` (INT IDENTITY) | Không | `HoTen`: NVARCHAR(100); `ChucVu`: NVARCHAR(20) IN ('PhucVu', 'ThuNgan', 'Bep', 'QuanLy'); `SoDienThoai`: VARCHAR(15) UNIQUE |
| **NguyenLieu** | `MaNL` (INT IDENTITY) | Không | `TenNL`: NVARCHAR(100) UNIQUE; `TonKho`, `DinhMucTon` $\ge$ 0 (DECIMAL(12,2)); `DonGiaNhap` $\ge$ 0 |
| **Mon** | `MaMon` (INT IDENTITY) | `MaLoai` $\rightarrow$ `LoaiMon(MaLoai)` | `TenMon`: NVARCHAR(100) UNIQUE; `GiaBan` > 0 (DECIMAL(12,0)); `Nhom` IN ('A', 'U'); `DangBan`: BIT DEFAULT 1 |
| **MonAn** | `MaMon` (INT) | `MaMon` $\rightarrow$ `Mon(MaMon)` | `ThoiGianCheBien`: INT > 0 (phút); `CayHayKhong`: BIT DEFAULT 0 |
| **ThucUong** | `MaMon` (INT) | `MaMon` $\rightarrow$ `Mon(MaMon)` | `Size`: CHAR(1) IN ('S', 'M', 'L'); `CoDa`, `CoDuong`: BIT DEFAULT 1 |
| **DinhLuong** | `(MaMon, MaNL)` | `MaMon` $\rightarrow$ `Mon`; `MaNL` $\rightarrow$ `NguyenLieu` | `SoLuong`: DECIMAL(12,3) > 0 (định lượng cho 1 phần món) |
| **HoaDon** | `MaHD` (INT IDENTITY) | `MaBan` $\rightarrow$ `Ban`; `MaNV` $\rightarrow$ `NhanVien` | `NgayLap`: DATETIME DEFAULT GETDATE(); `TrangThai` IN ('Mở', 'Đã thanh toán', 'Hủy'); `TongTien` $\ge$ 0 |
| **ChiTietHoaDon** | `(MaHD, MaMon)` | `MaHD` $\rightarrow$ `HoaDon`; `MaMon` $\rightarrow$ `Mon` | `SoLuong`: INT > 0; `DonGia` $\ge$ 0; `TrangThaiCheBien` IN ('Chờ', 'Đang làm', 'Xong') |

---

# CHƯƠNG 3. CÀI ĐẶT CƠ SỞ DỮ LIỆU TRÊN SQL SERVER

### 3.1. Môi trường cài đặt
#### Bảng 3.1. Môi trường triển khai hệ quản trị cơ sở dữ liệu
| Hạng mục | Thông số kỹ thuật / Phiên bản cấu hình |
|:---|:---|
| **Hệ quản trị CSDL** | Microsoft SQL Server 2022 / 2025 (hỗ trợ cả Developer và Express Edition) |
| **Công cụ quản trị** | SQL Server Management Studio (SSMS) v19 / v20 |
| **Công cụ mô hình hóa** | Sybase PowerDesigner 16.5 & drawSQL |
| **Tên cơ sở dữ liệu** | `QL_CAFE_NHAHANG` |
| **Bảng mã ký tự (Collation)** | `Vietnamese_CI_AS` (hỗ trợ tiếng Việt Unicode có dấu, không phân biệt hoa thường) |
| **Đường dẫn lưu trữ vật lý** | `C:\SQLData` (tách biệt tệp dữ liệu `.mdf` và tệp nhật ký giao tác `.ldf`) |

### 3.2. Tạo cơ sở dữ liệu
#### Bảng 3.2. Cấu hình tệp lưu trữ vật lý cơ sở dữ liệu
| Tên file logic | Loại file | Đường dẫn vật lý | Kích thước ban đầu | Kích thước tối đa | Mức tăng trưởng |
|:---|:---|:---|:---:|:---:|:---:|
| `QL_CAFE_Data` | ROWS (Primary Data) | `C:\SQLData\QL_CAFE_NHAHANG.mdf` | 50 MB | 500 MB | 10 MB |
| `QL_CAFE_Log` | LOG (Transaction Log) | `C:\SQLData\QL_CAFE_NHAHANG_log.ldf` | 20 MB | 200 MB | 10 MB |

```sql
USE master;
GO
IF DB_ID(N'QL_CAFE_NHAHANG') IS NOT NULL
BEGIN
    ALTER DATABASE QL_CAFE_NHAHANG SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QL_CAFE_NHAHANG;
END
GO
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

### 3.3. Script tạo bảng và ràng buộc
*(Mã nguồn đầy đủ nằm trong tệp `sql/02_Bang.sql`). Trích đoạn các bảng cốt lõi:*

```sql
USE QL_CAFE_NHAHANG;
GO
-- 1. Bảng Loại món (Đệ quy cây phân cấp)
CREATE TABLE LoaiMon (
    MaLoai      INT IDENTITY(1,1) NOT NULL,
    TenLoai     NVARCHAR(50) NOT NULL,
    MaLoaiCha   INT NULL,
    CONSTRAINT PK_LoaiMon PRIMARY KEY (MaLoai),
    CONSTRAINT UQ_LoaiMon_Ten UNIQUE (TenLoai),
    CONSTRAINT FK_LoaiMon_Cha FOREIGN KEY (MaLoaiCha) REFERENCES LoaiMon(MaLoai)
);

-- 5. Bảng Món (Siêu loại Supertype)
CREATE TABLE Mon (
    MaMon       INT IDENTITY(1,1) NOT NULL,
    TenMon      NVARCHAR(100) NOT NULL,
    MaLoai      INT NOT NULL,
    GiaBan      DECIMAL(12,0) NOT NULL,
    Nhom        CHAR(1) NOT NULL,
    DangBan     BIT NOT NULL CONSTRAINT DF_Mon_DangBan DEFAULT 1,
    CONSTRAINT PK_Mon PRIMARY KEY (MaMon),
    CONSTRAINT UQ_Mon_Ten UNIQUE (TenMon),
    CONSTRAINT FK_Mon_LoaiMon FOREIGN KEY (MaLoai) REFERENCES LoaiMon(MaLoai),
    CONSTRAINT CK_Mon_GiaBan CHECK (GiaBan >= 0),
    CONSTRAINT CK_Mon_Nhom CHECK (Nhom IN ('A', 'U'))
);

-- 8. Bảng Định lượng (Mối quan hệ N-N có thuộc tính riêng)
CREATE TABLE DinhLuong (
    MaMon       INT NOT NULL,
    MaNL        INT NOT NULL,
    SoLuong     DECIMAL(12,3) NOT NULL,
    CONSTRAINT PK_DinhLuong PRIMARY KEY (MaMon, MaNL),
    CONSTRAINT FK_DinhLuong_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon),
    CONSTRAINT FK_DinhLuong_NL FOREIGN KEY (MaNL) REFERENCES NguyenLieu(MaNL),
    CONSTRAINT CK_DinhLuong_SoLuong CHECK (SoLuong > 0)
);
GO
```

### 3.4. Bổ sung và sửa ràng buộc bằng ALTER TABLE
```sql
-- 1. Bổ sung ràng buộc định mức tồn không âm cho Nguyên liệu
ALTER TABLE NguyenLieu
    ADD CONSTRAINT CK_NL_DinhMuc CHECK (DinhMucTon >= 0);

-- 2. Bổ sung cột Ngày vào làm và giá trị mặc định cho Nhân viên
ALTER TABLE NhanVien
    ADD NgayVaoLam DATE NOT NULL CONSTRAINT DF_NhanVien_NgayVaoLam DEFAULT GETDATE();

-- 3. Tạo chỉ mục UNIQUE lọc (Filtered Index) trên Số điện thoại nhân viên
CREATE UNIQUE INDEX UX_NhanVien_SDT 
    ON NhanVien(SoDienThoai) 
    WHERE SoDienThoai IS NOT NULL;

-- 4. Sửa ràng buộc giá bán món ăn: từ GiaBan >= 0 sang GiaBan > 0
ALTER TABLE Mon DROP CONSTRAINT CK_Mon_GiaBan;
ALTER TABLE Mon ADD CONSTRAINT CK_Mon_GiaBan CHECK (GiaBan > 0);
GO
```

### 3.5. Danh mục ràng buộc trong cơ sở dữ liệu
#### Bảng 3.3. Danh mục 19 ràng buộc toàn vẹn trong hệ thống
| Mã RB | Bảng áp dụng | Loại ràng buộc | Tên ràng buộc và Biểu thức logic | Quy tắc nghiệp vụ |
|:---:|:---|:---:|:---|:---:|
| **RB01** | Ban | CHECK | `CK_Ban_SucChua`: SucChua > 0 | QT7 |
| **RB02** | Ban | CHECK | `CK_Ban_TrangThai`: TrangThai IN ('Trống', 'Có khách', 'Đã đặt') | QT1, QT4 |
| **RB03** | Ban | UNIQUE | `UQ_Ban_Ten`: TenBan duy nhất | Định danh bàn |
| **RB04** | NhanVien | CHECK | `CK_NhanVien_ChucVu`: ChucVu IN ('PhucVu', 'ThuNgan', 'Bep', 'QuanLy') | QT8 |
| **RB05** | NhanVien | UNIQUE INDEX | `UX_NhanVien_SDT`: SoDienThoai duy nhất khi NOT NULL | Hồ sơ nhân sự |
| **RB06** | NguyenLieu | CHECK | `CK_NL_TonKho`: TonKho >= 0 | QT3 |
| **RB07** | NguyenLieu | CHECK | `CK_NL_DinhMuc`: DinhMucTon >= 0 | Cảnh báo kho |
| **RB08** | NguyenLieu | CHECK | `CK_NL_DonGia`: DonGiaNhap >= 0 | QT6 |
| **RB09** | Mon | CHECK | `CK_Mon_GiaBan`: GiaBan > 0 (sau khi ALTER) | QT6 |
| **RB10** | Mon | CHECK | `CK_Mon_Nhom`: Nhom IN ('A', 'U') | Chuyên biệt hóa |
| **RB11** | Mon | DEFAULT | `DF_Mon_DangBan`: DangBan = 1 | QT2, QT5 |
| **RB12** | MonAn | CHECK | `CK_MonAn_ThoiGian`: ThoiGianCheBien > 0 | Nghiệp vụ bếp |
| **RB13** | ThucUong | CHECK | `CK_ThucUong_Size`: Size IN ('S', 'M', 'L') | Nghiệp vụ bar |
| **RB14** | DinhLuong | CHECK | `CK_DinhLuong_SoLuong`: SoLuong > 0 | QT3 |
| **RB15** | HoaDon | CHECK | `CK_HoaDon_TrangThai`: TrangThai IN ('Mở', 'Đã thanh toán', 'Hủy') | QT1, QT4 |
| **RB16** | HoaDon | CHECK | `CK_HoaDon_TongTien`: TongTien >= 0 | QT6 |
| **RB17** | ChiTietHoaDon | CHECK | `CK_CTHD_SoLuong`: SoLuong > 0 | Gọi món hợp lệ |
| **RB18** | ChiTietHoaDon | CHECK | `CK_CTHD_DonGia`: DonGia >= 0 | QT6 |
| **RB19** | ChiTietHoaDon | CHECK | `CK_CTHD_TrangThai`: TrangThaiCheBien IN ('Chờ', 'Đang làm', 'Xong') | Tiến độ chế biến |

---

# CHƯƠNG 4. DỮ LIỆU MẪU VÀ KIỂM THỬ RÀNG BUỘC

### 4.1. Quy trình sinh dữ liệu mẫu bằng AI
Quy trình 5 bước nghiêm ngặt:
1. **Chuẩn bị ngữ cảnh và Lược đồ CSDL:** Cung cấp cho AI toàn bộ mã DDL từ file `02_Bang.sql`.
2. **Sinh dữ liệu theo thứ tự cấu trúc:** Sinh bảng danh mục trước, bảng giao dịch sau.
3. **Cài đặt các trường hợp biên có chủ đích:** Đưa vào nguyên liệu cạn kiệt (`TonKho = 0`), nguyên liệu chạm định mức, món ăn mới chưa bán (mã 35, 36) và 5 hóa đơn rỗng.
4. **Khắc phục lỗi ngẫu nhiên:** Dùng `CAST(CHECKSUM(NEWID()) AS BIGINT)` để chống tràn số âm `INT_MIN`.
5. **Kiểm chứng tự động:** Bọc trong transaction có các lệnh `THROW` tự dừng nếu vi phạm bất biến dữ liệu.

### 4.2. Thống kê dữ liệu mẫu
#### Bảng 4.1. Thống kê số lượng và phân bổ dữ liệu mẫu trong hệ thống
| Bảng | Số dòng | Cách sinh | Ghi chú dữ liệu biên & trường hợp đặc biệt |
|:---|:---:|:---:|:---|
| **LoaiMon** | 11 | AI hỗ trợ + Tinh chỉnh | Cây phân cấp 3 tầng; 4 loại gốc; 7 loại con. |
| **Ban** | 15 | Tự nhập + AI | 5 bàn 'Có khách', 3 bàn 'Đã đặt', 7 bàn 'Trống'; sức chứa 2-12 chỗ. |
| **NhanVien** | 12 | AI hỗ trợ | 4 PhucVu, 3 ThuNgan, 3 Bep, 2 QuanLy; thâm niên 2021-2024. |
| **NguyenLieu** | 28 | AI hỗ trợ | 2 nguyên liệu cạn sạch (`TonKho = 0`); 4 dưới định mức; 2 chạm định mức. |
| **Mon** | 36 | AI hỗ trợ | 18 Món ăn, 18 Thức uống; 2 món mới chưa từng bán lần nào (mã 35, 36). |
| **MonAn** | 18 | AI hỗ trợ | Thời gian nấu 5-30 phút; có phân loại món cay / không cay. |
| **ThucUong** | 18 | AI hỗ trợ | Đủ size S, M, L; tùy chọn có/không đá và đường. |
| **DinhLuong** | 130 | AI hỗ trợ | Quan hệ N-N; mỗi món tiêu hao từ 2 - 6 nguyên liệu khác nhau. |
| **HoaDon** | 1.500 | Thuật toán T-SQL sinh | 1.390 'Đã thanh toán', 105 'Hủy', đúng 5 HĐ 'Mở' khớp 5 bàn Có khách; 5 HĐ rỗng. |
| **ChiTietHoaDon** | 5.200+ | Thuật toán T-SQL sinh | Mỗi hóa đơn có 1-6 món ngẫu nhiên; tổng tiền đối soát chuẩn 100%. |

### 4.3. Kiểm thử ràng buộc toàn vẹn
Toàn bộ 10 ca kiểm thử cố tình vi phạm được đóng gói ở Phần 1 file `sql/04_TruyVan_View.sql`, thực thi trong transaction và `ROLLBACK` an toàn:

#### Bảng 4.2. Kết quả kiểm thử các ràng buộc toàn vẹn cố tình vi phạm
| Mã | Ràng buộc kiểm tra | Lệnh SQL thử vi phạm | Kết quả mong đợi | Mã lỗi & Kết quả thực tế | Đánh giá |
|:---:|:---|:---|:---|:---|:---:|
| **T01** | NOT NULL trên Ban(TenBan) | `INSERT INTO Ban(TenBan, SucChua) VALUES (NULL, 4)` | Bị từ chối | Lỗi 515: Cannot insert NULL | **ĐẠT** |
| **T02** | CHECK Ban(SucChua > 0) | `INSERT INTO Ban(TenBan, SucChua) VALUES (N'Bàn 99', 0)` | Bị từ chối do sức chứa = 0 | Lỗi 547: Conflicted with CK_Ban_SucChua | **ĐẠT** |
| **T03** | CHECK Ban(TrangThai) | `INSERT INTO Ban(TenBan, SucChua, TrangThai) VALUES (N'Bàn VP', 4, N'Hỏng')` | Bị từ chối do trạng thái sai | Lỗi 547: Conflicted with CK_Ban_TrangThai | **ĐẠT** |
| **T04** | UNIQUE Ban(TenBan) | `INSERT INTO Ban(TenBan, SucChua) VALUES (N'Bàn 01', 4)` | Bị từ chối do trùng tên bàn | Lỗi 2627: Violation of UNIQUE constraint | **ĐẠT** |
| **T05** | UNIQUE INDEX NhanVien(SDT) | Chèn nhân viên có SĐT trùng nhân viên cũ | Bị từ chối trùng SĐT | Lỗi 2601: Cannot insert duplicate key | **ĐẠT** |
| **T06** | PRIMARY KEY MonAn(MaMon) | `INSERT INTO MonAn(MaMon, ThoiGianCheBien) VALUES (1, 15)` | Bị từ chối do trùng khóa chính | Lỗi 2627: Violation of PRIMARY KEY | **ĐẠT** |
| **T07** | FOREIGN KEY Mon(MaLoai) | `INSERT INTO Mon(TenMon, MaLoai, GiaBan, Nhom) VALUES (N'Test', 999, 50000, 'A')` | Bị từ chối MaLoai không tồn tại | Lỗi 547: Conflicted with FK_Mon_LoaiMon | **ĐẠT** |
| **T08** | CHECK NguyenLieu(TonKho >= 0) | `INSERT INTO NguyenLieu(TenNL, DonViTinh, TonKho) VALUES (N'Test', N'kg', -5)` | Bị từ chối tồn kho âm | Lỗi 547: Conflicted with CK_NL_TonKho | **ĐẠT** |
| **T09** | CHECK Mon(GiaBan > 0) | `INSERT INTO Mon(TenMon, MaLoai, GiaBan, Nhom) VALUES (N'Free', 1, 0, 'A')` | Bị từ chối giá bán = 0 | Lỗi 547: Conflicted with CK_Mon_GiaBan | **ĐẠT** |
| **T10** | CHECK DinhLuong(SoLuong > 0) | `INSERT INTO DinhLuong(MaMon, MaNL, SoLuong) VALUES (1, 1, 0)` | Bị từ chối định lượng $\le$ 0 | Lỗi 547: Conflicted with CK_DinhLuong_SoLuong | **ĐẠT** |

---

# CHƯƠNG 5. TRUY VẤN T-SQL VÀ VIEW

### 5.1. Tổng hợp các truy vấn
#### Bảng 5.1. Bảng tổng hợp cấu trúc 20 câu truy vấn và 3 View
| Nhóm kỹ thuật truy vấn | Số lượng tối thiểu | Các truy vấn hiện thực | Nội dung nghiệp vụ tiêu biểu |
|:---|:---:|:---:|:---|
| **Đơn giản** (SELECT - FROM - WHERE) | 4 | Q01, Q02, Q03, Q04 | Lọc món đang bán; Tính thâm niên nhân sự; Cảnh báo thiếu hụt kho; Đơn hàng 7 ngày. |
| **Kết nối** (JOIN, có kết ngoài) | 3 | Q05, Q06, Q07 | INNER JOIN danh mục đa cấp; LEFT JOIN bàn trống; JOIN 4 bảng lấy công thức món. |
| **Gom nhóm** (GROUP BY, HAVING) | 3 | Q08, Q09, Q10 | Doanh thu theo tháng; Top 10 món bán chạy; Loại món tiêu hao trên 5 nguyên liệu. |
| **Truy vấn con / lồng** (EXISTS, ALL, IN) | 4 | Q11, Q12, Q13, Q14 | NOT EXISTS món chưa từng bán; EXISTS đơn có món chờ; > ALL phép so sánh đơn giá; IN bàn đặt > 3 món. |
| **Phép toán tập hợp** (UNION, INTERSECT, EXCEPT) | 2 | Q15, Q16 | EXCEPT tìm món thiếu định lượng kết hợp UNION; INTERSECT tìm món bán chéo ca Phục vụ & Thu ngân. |
| **Common Table Expression** (CTE) | 2 | Q17, Q18 | CTE đệ quy duyệt cây danh mục món; CTE thống kê doanh số tổng hợp từng bàn. |
| **Hàm xếp hạng** (Ranking: RANK, NTILE) | 2 | Q19, Q20 | RANK() xếp hạng món bán chạy theo 4 khung giờ; NTILE(4) phân vị hiệu suất nhân viên. |
| **Truy vấn sinh từ NL->SQL** | 5 | Q08, Q11, Q13, Q17, Q19 | Được hỗ trợ sinh bởi AI và đã qua rà soát, kiểm chứng, tinh chỉnh cú pháp. |
| **Khung nhìn (View)** | 3 | V01, V02, V03 | `v_MonDangBan` (Bếp), `v_TonKhoCanhBao` (Quản lý kho), `v_DoanhThuHoaDon` (Thu ngân). |

### 5.2. Chi tiết từng truy vấn
*(Đầy đủ mã lệnh và giải thích nằm trong file `sql/04_TruyVan_View.sql`). Một số câu tiêu biểu:*

* **Q05 (LEFT JOIN LoaiMon cha):**
  ```sql
  SELECT m.MaMon, m.TenMon, m.GiaBan, m.Nhom, lm.TenLoai AS TenLoaiCon, lmcha.TenLoai AS TenLoaiCha
  FROM Mon m
      INNER JOIN LoaiMon lm ON m.MaLoai = lm.MaLoai
      LEFT JOIN LoaiMon lmcha ON lm.MaLoaiCha = lmcha.MaLoai
  ORDER BY ISNULL(lmcha.TenLoai, lm.TenLoai), lm.TenLoai, m.TenMon;
  ```
* **Q13 (Phép toán > ALL / Phép chia quan hệ):**
  ```sql
  SELECT MaNL, TenNL, DonViTinh, TonKho, DonGiaNhap 
  FROM NguyenLieu 
  WHERE DonViTinh <> N'kg'
    AND DonGiaNhap > ALL (SELECT DonGiaNhap FROM NguyenLieu WHERE DonViTinh = N'kg') 
  ORDER BY DonGiaNhap DESC;
  ```
* **Q17 (CTE đệ quy duyệt cây Loại món):**
  ```sql
  ;WITH CTE_LoaiMon AS (
      SELECT MaLoai, TenLoai, MaLoaiCha, CAST(TenLoai AS NVARCHAR(500)) AS DuongDan, 0 AS Cap
      FROM LoaiMon WHERE MaLoaiCha IS NULL
      UNION ALL
      SELECT lm.MaLoai, lm.TenLoai, lm.MaLoaiCha, CAST(cte.DuongDan + N' > ' + lm.TenLoai AS NVARCHAR(500)), cte.Cap + 1
      FROM LoaiMon lm INNER JOIN CTE_LoaiMon cte ON lm.MaLoaiCha = cte.MaLoai
  )
  SELECT MaLoai, TenLoai, MaLoaiCha, Cap, DuongDan FROM CTE_LoaiMon ORDER BY DuongDan;
  ```

### 5.3. Truy vấn sinh từ ngôn ngữ tự nhiên (NL→SQL)
#### Bảng 5.3. Nhật ký kiểm chứng và hoàn thiện 5 câu truy vấn NL->SQL
| Truy vấn | Lời nhắc gửi AI | SQL do AI sinh (Tóm tắt) | Vấn đề phát hiện khi rà soát | Bản sửa đổi & Kết luận |
|:---:|:---|:---|:---|:---|
| **Q08** | Tính tổng doanh thu mỗi tháng trong 3 tháng gần nhất từ bảng HoaDon, chỉ lấy hóa đơn đã thanh toán. | `SELECT YEAR, MONTH, SUM(TongTien) FROM HoaDon WHERE NgayLap >= DATEADD(...) GROUP BY YEAR, MONTH` | AI quên lọc `TrangThai = N'Đã thanh toán'`, dẫn đến tính gộp cả các hóa đơn đang mở và hóa đơn hủy. | Đã bổ sung điều kiện `TrangThai = N'Đã thanh toán'`, thêm FORMAT MM/yyyy và AVG giá trị hóa đơn. |
| **Q11** | Tìm các món chưa bao giờ xuất hiện trong bảng ChiTietHoaDon dù hóa đơn ở trạng thái nào. | `SELECT * FROM Mon WHERE MaMon NOT IN (SELECT MaMon FROM ChiTietHoaDon)` | AI dùng toán tử `NOT IN`. Nếu có giá trị NULL, `NOT IN` sẽ trả về tập kết quả rỗng (bẫy 3-valued logic). | Đã viết lại bằng `NOT EXISTS` với correlated subquery, tối ưu hóa tốc độ và an toàn khi có NULL. |
| **Q13** | Tìm nguyên liệu có đơn giá nhập lớn hơn tất cả nguyên liệu có đơn vị tính là kg. | `SELECT * FROM NguyenLieu WHERE DonGiaNhap > ALL (SELECT DonGiaNhap FROM ... WHERE DonViTinh = 'kg')` | AI dùng chuỗi `'kg'` thiếu tiền tố `N''`, gây nguy cơ lỗi Collation; không lọc `DonViTinh <> N'kg'`. | Đã sửa thành `N'kg'`, bổ sung điều kiện loại trừ `DonViTinh <> N'kg'`, sắp xếp giảm dần theo đơn giá nhập. |
| **Q17** | Dùng CTE đệ quy duyệt cây LoaiMon có cột MaLoaiCha tự tham chiếu, hiện đường dẫn dạng Cha > Con > Cháu. | `;WITH CTE AS (...) SELECT * FROM CTE` | Cột đường dẫn không được `CAST` tường minh độ dài, gây lỗi tràn kiểu dữ liệu (String truncation). | Đã thêm `CAST(TenLoai AS NVARCHAR(500))`, bổ sung cột `Cap` tính độ sâu cấp độ phân nhánh. |
| **Q19** | Phân loại hóa đơn theo 4 khung giờ trong ngày, rồi RANK từng món theo số lượng trong mỗi khung giờ. | `SELECT KhungGio, MaMon, RANK() OVER (ORDER BY SoLuong DESC) ...` | AI quên khai báo `PARTITION BY KhungGio` trong hàm `RANK()`, khiến việc xếp hạng bị gộp chung toàn bảng. | Đã sửa thành `RANK() OVER (PARTITION BY KhungGio ORDER BY TongSoLuong DESC)`, bổ sung nhánh `ELSE N'Khác'`. |

### 5.4. Các View
#### Bảng 5.4. Danh mục 3 Khung nhìn (View) trong cơ sở dữ liệu
| Tên View | Mục đích nghiệp vụ | Bảng nguồn tham chiếu | Cột hiển thị / Giới hạn bảo mật | Vai trò sử dụng |
|:---|:---|:---|:---|:---:|
| `v_MonDangBan` | Menu đang mở bán kèm thông số chế biến cho Bếp; ẩn hoàn toàn giá vốn và giá nhập. | Mon, LoaiMon, MonAn, ThucUong | MaMon, TenMon, TenLoai, GiaBan, NhomMoTa, ThoiGianCheBien, CayHayKhong, Size, CoDa, CoDuong (`DangBan = 1`) | `role_Bep`, `role_PhucVu` |
| `v_TonKhoCanhBao` | Lọc nguyên liệu sắp hết hoặc cạn kiệt, tính ước lượng chi phí nhập hàng để đặt hàng khẩn cấp. | NguyenLieu | MaNL, TenNL, DonViTinh, TonKho, DinhMucTon, MucThieuHut, DonGiaNhap, UocTinhTienMua, MucCanhBao | `role_QuanLy` |
| `v_DoanhThuHoaDon` | Hóa đơn đã thanh toán kèm tên bàn, nhân viên và số lượng món để thu ngân đối soát ca. | HoaDon, Ban, NhanVien, ChiTietHoaDon | MaHD, TenBan, TenNhanVien, ChucVu, NgayLap, Nam, Thang, TongTien, SoDongChiTiet (`TrangThai = 'Đã thanh toán'`) | `role_ThuNgan`, `role_QuanLy` |

---

# CHƯƠNG 6. STORED PROCEDURE VÀ FUNCTION

### 6.1. Danh sách thủ tục và hàm
#### Bảng 6.1. Danh mục 5 Stored Procedure và 3 Function trong hệ thống
| Đối tượng | Loại đối tượng | Chức năng và Tham số chính | Quy tắc nghiệp vụ liên quan |
|:---|:---:|:---|:---:|
| `sp_GoiMon` | Stored Procedure | `@MaHD`, `@MaMon`, `@SoLuong`; Kiểm tra kho nguyên tử, trừ kho và cập nhật tổng tiền. | QT2, QT3, QT6 |
| `sp_ThanhToan` | Stored Procedure | `@MaHD`, `@TongTienThucThu` OUTPUT; Đổi trạng thái HĐ, giải phóng bàn về Trống, trả về tiền thực thu. | QT4, QT6 |
| `sp_MoHoaDon` | Stored Procedure | `@MaBan`, `@MaNV`, `@MaHD` OUTPUT; Kiểm tra bàn Trống, kiểm tra nhân viên Phục vụ, mở HĐ mới. | QT1, QT4, QT8 |
| `sp_HuyHoaDon` | Stored Procedure | `@MaHD`; Duyệt CURSOR hoàn trả nguyên liệu về kho, chuyển trạng thái HĐ sang Hủy, trả bàn về Trống. | QT4 |
| `sp_ThongKeDoanhThu` | Stored Procedure | `@Nam`, `@ThangBatDau`, `@ThangKetThuc`; Kiểm tra hợp lệ thời gian, thống kê HĐ, món bán và doanh số. | Báo cáo quản lý |
| `fn_GiaVonMon` | Hàm vô hướng (Scalar) | `@MaMon` $\rightarrow$ DECIMAL(14,2); Tính tổng giá vốn nguyên liệu cấu thành của 1 món ăn. | Tính giá thành |
| `fn_NguyenLieuDuoiDinhMuc` | Hàm bảng inline (Inline TVF) | `@PhanTramNguong` $\rightarrow$ TABLE; Trả về danh sách nguyên liệu có tồn kho dưới ngưỡng % định mức. | QT3, Cảnh báo kho |
| `fn_DanhSachMonTheoLoai` | Hàm bảng nhiều câu lệnh (Multi-statement TVF) | `@MaLoai`, `@BaoGomConChau` $\rightarrow$ TABLE; Chứa CTE đệ quy, truy xuất toàn bộ món ăn của cây danh mục con cháu. | Duyệt thực đơn |

### 6.2. Chi tiết từng đối tượng
*(Mã nguồn đầy đủ nằm trong tệp `sql/05_ThuTuc_Ham.sql`). Một số điểm nổi bật về logic:*
* **Xử lý xung đột trừ tồn kho giữa `sp_GoiMon` và Trigger TR01:** Trong `sp_GoiMon`, khi thêm món mới (`INSERT`), trigger TR01 đã tự động trừ tồn kho. Procedure thông minh kiểm tra `OBJECTPROPERTY(..., 'ExecIsTriggerDisabled')` để chỉ tự trừ kho khi trigger bị tắt, tránh triệt để lỗi **trừ tồn kho 2 lần**. Khi gọi thêm số lượng (`UPDATE`), do TR01 chỉ bắt `AFTER INSERT`, procedure sẽ tự động trừ phần tồn kho phát sinh thêm.
* **Xử lý an toàn con trỏ CURSOR trong `sp_HuyHoaDon`:** Trong khối `CATCH`, kiểm tra `CURSOR_STATUS('local', 'cur_ChiTiet') >= 0` để đóng và giải phóng con trỏ `cur_ChiTiet`, ngăn chặn rò rỉ bộ nhớ khi xảy ra sự cố gián đoạn.

*Sơ đồ luồng xử lý (flowchart) của 5 thủ tục và hàm `fn_DanhSachMonTheoLoai` xem tại [`tai_lieu/FLOWCHART_LOGIC.md`](tai_lieu/FLOWCHART_LOGIC.md), mục 1–7.*

### 6.3. Kiểm thử
#### Bảng 6.3. Bảng tổng hợp kết quả kiểm thử các Stored Procedure và Function
| Đối tượng | Ca thử nghiệm và Dữ liệu đầu vào | Kết quả mong đợi | Kết quả thực tế ghi nhận | Đánh giá |
|:---|:---|:---|:---|:---:|
| `sp_GoiMon` | ĐÚNG: MaHD=1 (Mở), MaMon=1, SoLuong=2 | Thêm món, trừ kho đúng định lượng, commit | Thêm 2 phần, kho trừ đúng 0.05kg cà phê | **ĐẠT** |
| `sp_GoiMon` | SAI 1: MaHD=99999 (không tồn tại) | Báo lỗi nghiệp vụ 50001 | Lỗi 50001: Hóa đơn không tồn tại | **ĐẠT** |
| `sp_GoiMon` | SAI 2: SoLuong=99999 (thiếu nguyên liệu) | Báo lỗi 50003, hủy toàn bộ giao tác | Lỗi 50003: Không đủ nguyên liệu, rollback | **ĐẠT** |
| `sp_ThanhToan` | ĐÚNG: MaHD=1 đang mở, có món | HĐ thành Đã thanh toán, bàn Trống, nhận tiền OUTPUT | HĐ Đã thanh toán, bàn Trống, nhận đúng tiền | **ĐẠT** |
| `sp_ThanhToan` | SAI: MaHD=2 (hóa đơn rỗng chưa có món) | Báo lỗi nghiệp vụ 50011 | Lỗi 50011: Hóa đơn chưa có món nào | **ĐẠT** |
| `sp_MoHoaDon` | ĐÚNG: MaBan=7 (Trống), MaNV=1 (Phục vụ) | Tạo MaHD mới qua OUTPUT, bàn thành Có khách | Tạo MaHD thành công, bàn chuyển Có khách | **ĐẠT** |
| `sp_MoHoaDon` | SAI: MaBan=1 (bàn đang Có khách) | Báo lỗi nghiệp vụ 50022 | Lỗi 50022: Bàn không ở trạng thái Trống | **ĐẠT** |
| `sp_HuyHoaDon` | ĐÚNG: MaHD=3 đang mở có món | Hoàn kho nguyên liệu, HĐ thành Hủy, bàn Trống | Duyệt CURSOR hoàn kho đủ, hủy đơn thành công | **ĐẠT** |
| `sp_ThongKeDoanhThu`| ĐÚNG: Nam=2024, ThangBatDau=1, ThangKetThuc=3 | Trả về bảng doanh thu 3 tháng Quý 1 | Hiển thị đúng 3 dòng tháng 1, 2, 3 | **ĐẠT** |
| `sp_ThongKeDoanhThu`| SAI: ThangBatDau=6, ThangKetThuc=3 | Báo lỗi kiểm tra biên 50040 | Lỗi 50040: ThangBatDau phải <= ThangKetThuc | **ĐẠT** |
| `fn_GiaVonMon` | ĐÚNG: MaMon=1 (Cà phê sữa đá) | Trả về tổng giá vốn thành phẩm > 0 | Trả về chính xác 8.500đ | **ĐẠT** |
| `fn_NguyenLieuDuoiDinhMuc` | ĐÚNG: Ngưỡng 50.0% định mức | Trả về nguyên liệu cạn kiệt khẩn cấp | Trả về đúng 2 nguyên liệu cạn kho (TonKho = 0) | **ĐẠT** |
| `fn_DanhSachMonTheoLoai` | ĐÚNG: MaLoai=1 (Đồ uống), BaoGomConChau=1 | Trả về tất cả đồ uống thuộc mọi loại con cháu | Trả về toàn bộ 18 thức uống trong menu | **ĐẠT** |

---

# CHƯƠNG 7. GIAO TÁC VÀ TRIGGER

### 7.1. Danh sách trigger
#### Bảng 7.1. Danh sách các Trigger nghiệp vụ trong cơ sở dữ liệu
| Tên Trigger | Bảng áp dụng | Loại Trigger | Sự kiện | Quy tắc nghiệp vụ / Cơ chế bảo đảm toàn vẹn |
|:---|:---:|:---:|:---:|:---|
| `trg_ChiTietHoaDon_KiemTraNguyenLieu` | ChiTietHoaDon | AFTER | INSERT | QT3: Gom nhóm bảng ảo `inserted` theo `MaNL` tính tổng nhu cầu; nếu thiếu dù 1 NL ném lỗi THROW 50001 (kèm danh sách chi tiết) và ROLLBACK; nếu đủ tự trừ kho. |
| `trg_HoaDon_CapNhatBan` | HoaDon | AFTER | UPDATE | QT4: So sánh `deleted` và `inserted`; tự động đồng bộ Ban sang 'Trống' khi thanh toán/hủy, sang 'Có khách' khi mở mới. |
| `trg_Mon_KiemTraXoa` | Mon | INSTEAD OF | DELETE | QT2, QT5: Chặn xóa vật lý các món đang có trong hóa đơn 'Mở'; thực hiện xóa mềm bằng cách cập nhật `DangBan = 0`. |

### 7.2. Mã nguồn và giải thích
*(Mã nguồn đầy đủ nằm trong tệp `sql/06_Trigger_GiaoTac.sql`). Điểm đặc biệt của TR01:*
Sử dụng CTE gom nhóm trên bảng ảo `inserted` để xử lý tập hợp (Set-based), tuyệt đối không dùng CURSOR:
```sql
;WITH CTE_NhuCau AS (
    SELECT dl.MaNL, SUM(i.SoLuong * dl.SoLuong) AS SoLuongCan
    FROM inserted i JOIN DinhLuong dl ON dl.MaMon = i.MaMon
    GROUP BY dl.MaNL
)
SELECT @DsThieu = STRING_AGG(CONCAT(nl.TenNL, ' (Cần: ', nc.SoLuongCan, ', Còn: ', nl.TonKho, ')'), '; ')
FROM CTE_NhuCau nc JOIN NguyenLieu nl ON nl.MaNL = nc.MaNL
WHERE nl.TonKho < nc.SoLuongCan;
```

### 7.3. Kịch bản giao tác
#### Bảng 7.2. Danh mục các kịch bản giao tác ACID mẫu mực
| Mã | Kịch bản giao tác | Các bước thực hiện trong giao tác | Điều kiện kích hoạt lỗi | Kết quả ca Thành công | Kết quả ca Thất bại |
|:---:|:---|:---|:---|:---|:---|
| **GT01** | Nguyên tử trong Gọi món (All-or-Nothing) | 1. BEGIN TRAN 2. INSERT món 1 3. INSERT món 2 4. COMMIT / ROLLBACK | Món thứ 2 bị thiếu nguyên liệu tồn kho | COMMIT thành công: cả 2 món đều được ghi nhận, tồn kho trừ đúng. | ROLLBACK toàn bộ: món thứ 1 dù đủ kho vẫn bị hủy bỏ, dữ liệu giữ nguyên 100%. |
| **GT02** | Điểm lưu (Savepoint) trong Thanh toán | 1. BEGIN TRAN 2. SAVE TRAN sp_ThanhToan 3. Thanh toán HĐ 4. ROLLBACK TO SAVEPOINT nếu lỗi | Hóa đơn không ở trạng thái 'Mở' | COMMIT thành công hóa đơn chuyển 'Đã thanh toán', bàn về 'Trống'. | ROLLBACK TO SAVEPOINT hủy bỏ thao tác thanh toán sai mà không làm hỏng transaction chính. |

*Sơ đồ luồng của ba trigger và hai kịch bản giao tác GT01, GT02 xem tại [`tai_lieu/FLOWCHART_LOGIC.md`](tai_lieu/FLOWCHART_LOGIC.md), mục 8–12.*

### 7.4. Kiểm thử thao tác nhiều dòng
```sql
-- Thử nghiệm INSERT đồng thời 3 dòng chi tiết vào hóa đơn (Món 1 & 2 đủ kho, Món 3 thiếu kho):
INSERT INTO ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
VALUES 
    (1, 1, 1, 35000, N'Chờ'),
    (1, 2, 2, 45000, N'Chờ'),
    (1, 3, 9999, 120000, N'Chờ'); -- Món này thiếu kho
-- Kết quả: Toàn bộ lệnh bị hủy bỏ (Msg 50001), 0 dòng nào được thêm vào bảng!
```

---

# CHƯƠNG 8. BẢO MẬT, PHÂN QUYỀN, SAO LƯU VÀ PHỤC HỒI

### 8.1. Login, user và role
Thiết kế theo nguyên tắc Đặc quyền tối thiểu (Least Privilege) với 4 vai trò:
#### Bảng 8.1. Danh mục tài khoản, người dùng và vai trò phân quyền
| Login (Server) | Database User | Database Role | Người dùng nghiệp vụ | Phạm vi phân quyền |
|:---|:---|:---|:---|:---|
| `login_phucvu` | `user_phucvu` | `role_PhucVu` | Nhân viên phục vụ bàn | Mở bàn đón khách, gọi món, xem menu và bàn; bị DENY xem lương, doanh thu, tồn kho. |
| `login_thungan` | `user_thungan` | `role_ThuNgan` | Nhân viên thu ngân | Thanh toán hóa đơn, xem báo cáo đối soát; bị DENY sửa thực đơn, xóa nguyên liệu. |
| `login_bep` | `user_bep` | `role_Bep` | Nhân viên Bếp / Pha chế | Xem danh sách món cần chế biến, cập nhật tiến độ; bị DENY xem doanh thu, giá bán, giá nhập. |
| `login_quanly` | `user_quanly` | `role_QuanLy` | Quản lý nhà hàng | Xem toàn bộ báo cáo doanh thu, tồn kho, nhân sự; bị DENY quyền ALTER/DROP bảng. |

### 8.2. Ma trận phân quyền
#### Bảng 8.2. Ma trận phân quyền RBAC chi tiết trong hệ thống
| Đối tượng CSDL | role_PhucVu | role_ThuNgan | role_Bep | role_QuanLy |
|:---|:---:|:---:|:---:|:---:|
| **Ban** | SELECT | SELECT | DENY | S, I, U, D (DENY ALTER) |
| **Mon** | DENY | DENY (I, D) | SELECT (MaMon, TenMon) | S, I, U, D (DENY ALTER) |
| **LoaiMon** | DENY | DENY | DENY | S, I, U, D (DENY ALTER) |
| **NguyenLieu** | DENY SELECT | DENY (I, D) | DENY (DonGiaNhap) | S, I, U, D (DENY ALTER) |
| **NhanVien** | DENY SELECT | DENY | DENY | S, I, U, D (DENY ALTER) |
| **HoaDon** | DENY | SELECT, UPDATE (TrangThai) | DENY (TongTien) | SELECT (DENY ALTER) |
| **ChiTietHoaDon** | INSERT | SELECT | SELECT (Món, SL), UPDATE (Trạng thái) | SELECT (DENY ALTER) |
| **v_MonDangBan** | SELECT | DENY | SELECT | SELECT |
| **v_TonKhoCanhBao** | DENY | DENY | DENY | SELECT |
| **v_DoanhThuHoaDon** | DENY | SELECT | DENY | SELECT |
| **sp_MoHoaDon** | EXECUTE | DENY | DENY | EXECUTE |
| **sp_GoiMon** | EXECUTE | DENY | DENY | EXECUTE |
| **sp_ThanhToan** | DENY | EXECUTE | DENY | EXECUTE |
| **sp_HuyHoaDon** | DENY | EXECUTE | DENY | EXECUTE |
| **sp_ThongKeDoanhThu** | DENY | DENY | DENY | EXECUTE |

### 8.3. Kiểm chứng phân quyền
Kiểm chứng thực tế bằng lệnh `EXECUTE AS USER`:
#### Bảng 8.3. Bảng kiểm chứng phân quyền thực tế bằng lệnh EXECUTE AS
| Vai trò / Người dùng | Lệnh kiểm thử | Kết quả mong đợi | Kết quả thực tế ghi nhận | Đánh giá |
|:---|:---|:---|:---|:---:|
| `role_PhucVu` | `SELECT TOP 5 * FROM dbo.v_MonDangBan` | Đọc menu thành công | Thành công, hiển thị 5 món | **ĐẠT** |
| `role_PhucVu` | `SELECT TOP 1 * FROM dbo.NguyenLieu` | Bị từ chối xem kho | Lỗi 229: SELECT permission denied | **ĐẠT** |
| `role_ThuNgan` | `SELECT TOP 5 * FROM dbo.v_DoanhThuHoaDon` | Xem đối soát thành công | Thành công, hiển thị hóa đơn thanh toán | **ĐẠT** |
| `role_ThuNgan` | `DELETE FROM dbo.Mon WHERE MaMon = 1` | Bị từ chối xóa thực đơn | Lỗi 229: DELETE permission denied | **ĐẠT** |
| `role_Bep` | `UPDATE ChiTietHoaDon SET TrangThaiCheBien = N'Xong'` | Cập nhật tiến độ thành công | Thành công, trạng thái món chuyển Xong | **ĐẠT** |
| `role_Bep` | `SELECT TongTien FROM dbo.HoaDon` | Bị từ chối xem tổng tiền | Lỗi 230: SELECT permission denied on column TongTien | **ĐẠT** |
| `role_QuanLy` | `EXEC dbo.sp_ThongKeDoanhThu @Nam=2026` | Chạy báo cáo doanh thu thành công | Thành công, hiển thị doanh thu | **ĐẠT** |
| `role_QuanLy` | `ALTER TABLE dbo.Ban ADD CotMoi INT` | Bị từ chối sửa cấu trúc bảng | Lỗi 229: ALTER permission denied on object Ban | **ĐẠT** |

### 8.4. Sao lưu và phục hồi
Hệ thống thiết lập `RECOVERY FULL` và thực hiện chuỗi sao lưu Full $\rightarrow$ Differential $\rightarrow$ Log:

#### Bảng 8.4. Chiến lược sao lưu và phục hồi dữ liệu
| Loại sao lưu | Mục đích & Thời điểm thực hiện | Lệnh T-SQL thực hiện | Tệp lưu trữ | Kết quả kiểm tra phục hồi |
|:---|:---|:---|:---|:---|
| **Full Backup** | Sao lưu toàn bộ CSDL định kỳ hàng tuần. | `BACKUP DATABASE QL_CAFE_NHAHANG TO DISK = '...' WITH FORMAT, INIT, CHECKSUM` | `QL_CAFE_NHAHANG_Full.bak` | `RESTORE VERIFYONLY` toàn vẹn thành công. |
| **Differential Backup**| Sao lưu phần thay đổi sau bản Full cuối ngày. | `BACKUP DATABASE QL_CAFE_NHAHANG TO DISK = '...' WITH FORMAT, INIT, DIFFERENTIAL` | `QL_CAFE_NHAHANG_Diff.bak` | Áp thành công với `NORECOVERY`. |
| **Log Backup** | Sao lưu nhật ký giao dịch mỗi 15-30 phút. | `BACKUP LOG QL_CAFE_NHAHANG TO DISK = '...' WITH FORMAT, INIT, CHECKSUM` | `QL_CAFE_NHAHANG_Log.bak` | Áp chuỗi Log cuối với `RECOVERY`, đưa DB online. |

*(Lưu ý kỹ thuật: Lệnh backup được cấu hình tương thích 100% với SQL Server Express Edition bằng cách tắt `COMPRESSION` vì bản Express không hỗ trợ nén).*

**Kịch bản Phục hồi thảm họa sang CSDL mới `QL_CAFE_RESTORE`:**
```sql
USE master;
GO
IF DB_ID(N'QL_CAFE_RESTORE') IS NOT NULL
BEGIN
    ALTER DATABASE QL_CAFE_RESTORE SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QL_CAFE_RESTORE;
END
GO
-- 1. Phục hồi Full với WITH MOVE và NORECOVERY
RESTORE DATABASE QL_CAFE_RESTORE FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Full.bak'
WITH MOVE N'QL_CAFE_Data' TO N'C:\SQLData\QL_CAFE_RESTORE.mdf',
     MOVE N'QL_CAFE_Log'  TO N'C:\SQLData\QL_CAFE_RESTORE_log.ldf',
     NORECOVERY, REPLACE, STATS = 10;
GO
-- 2. Áp Differential Backup tiếp theo
RESTORE DATABASE QL_CAFE_RESTORE FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Diff.bak'
WITH NORECOVERY, STATS = 10;
GO
-- 3. Áp Transaction Log Backup cuối cùng và RECOVERY
RESTORE LOG QL_CAFE_RESTORE FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Log.bak'
WITH RECOVERY, STATS = 10;
GO
-- 4. Xác nhận phục hồi thành công
USE QL_CAFE_RESTORE;
SELECT DB_NAME() AS CSDL, COUNT(*) AS SoBan FROM Ban;
```

### 8.5. Phân tích phương án tính sẵn sàng cao (HA)
* **Phân tích RTO và RPO:**
  * RTO $\le$ 5 phút trong giờ cao điểm (11h-14h và 18h-22h).
  * RPO $\le$ 1 phút cho giao dịch thanh toán (không chấp nhận mất hóa đơn đã thu tiền).
* **Đề xuất kiến trúc Always On Availability Groups:**
  * Đồng bộ `Synchronous-commit` giữa nút Primary (quầy thu ngân) và Secondary (phòng quản lý) $\rightarrow$ RPO $\approx$ 0.
  * Tự động chuyển đổi dự phòng (`Automatic Failover`) trong vài giây khi Primary gặp sự cố $\rightarrow$ RTO $\le$ 5 phút.
  * Cấu hình `Readable Secondary` chuyển hướng truy vấn báo cáo nặng sang Secondary, giữ cho Primary luôn nhanh nhất.

---

# CHƯƠNG 9. TỐI ƯU HIỆU NĂNG VỚI SỰ HỖ TRỢ CỦA AI

### 9.1. Các truy vấn được chọn
#### Bảng 9.1. Danh mục 3 truy vấn nặng được chọn phân tích tối ưu
| Mã | Nghiệp vụ thực hiện | Bảng dữ liệu & Quy mô | Nguyên nhân dự đoán gây chậm trước tối ưu |
|:---:|:---|:---|:---|
| **TQ01** | Doanh thu theo từng khung giờ trong ngày (30 ngày gần nhất) | `HoaDon`: 1.500 dòng | Chưa có index trên `TrangThai` và `NgayLap` $\rightarrow$ Phải Table Scan toàn bộ bảng. |
| **TQ02** | Top 10 món bán chạy nhất hệ thống kèm doanh thu lũy kế | `ChiTietHoaDon`: 5.200+ dòng; `HoaDon`: 1.500 dòng; `Mon`: 36 dòng | JOIN 3 bảng lớn, Table Scan cả 2 bảng giao dịch, Hash Match tốn bộ nhớ RAM. |
| **TQ03** | Dự báo tốc độ tiêu thụ và cảnh báo cạn kiệt nguyên liệu | `ChiTietHoaDon`, `HoaDon`, `DinhLuong`, `NguyenLieu` (4 bảng) | CTE tính tiêu thụ quét toàn bộ `DinhLuong` và `ChiTietHoaDon`, chi phí > 202 reads. |

### 9.2. Execution Plan trước khi tối ưu
* **TQ01 trước tối ưu:** Toán tử Table Scan trên 1.500 dòng của `HoaDon`, tiêu tốn 45 Logical Reads và 8ms CPU.
* **TQ02 trước tối ưu:** Table Scan trên `ChiTietHoaDon` (~153 reads) và `HoaDon` (~45 reads). Kế hoạch thực thi dùng Hash Match Join, tiêu tốn 15ms CPU.
* **TQ03 trước tối ưu:** Quét toàn bộ `ChiTietHoaDon` (~153 reads), `HoaDon` (~45 reads) và `DinhLuong` (~4 reads), tổng chi phí đọc đĩa vượt 202 Logical Reads.

### 9.3. Đề xuất của AI và đánh giá của nhóm
#### Bảng 9.2. Đánh giá và đối chiếu các đề xuất chỉ mục của AI
| Truy vấn | Đề xuất chỉ mục của AI | Quyết định | Cơ sở lý luận kỹ thuật & Kết quả kiểm chứng |
|:---:|:---|:---:|:---|
| **TQ01** | Tạo Composite Covering Index: `IX_HoaDon_TrangThai_NgayLap` trên `HoaDon(TrangThai, NgayLap)` INCLUDE `(TongTien, MaHD)` | **CHẤP NHẬN** | `TrangThai` lọc đẳng thức thu hẹp phạm vi; `NgayLap` là range filter cho phép Index Seek; `INCLUDE` tạo Covering Index, triệt tiêu Key Lookup. |
| **TQ02** | 1. Tạo `IX_ChiTietHoaDon_MaMon` INCLUDE `(SoLuong, DonGia, MaHD)`<br>2. Tạo Index đơn trên `HoaDon(TrangThai)` | 1. **CHẤP NHẬN**<br>2. **BÁC BỎ** | Chỉ mục 1 bao phủ JOIN và tính tổng, triệt tiêu Table Scan CTHD. Bác bỏ chỉ mục 2 vì `TrangThai` chỉ có 3 giá trị (low cardinality), Optimizer sẽ bỏ qua; hơn nữa index composite ở TQ01 đã bao phủ cột này. |
| **TQ03** | 1. Tạo `IX_DinhLuong_MaNL` INCLUDE `(MaMon, SoLuong)`<br>2. Tạo Index trên `HoaDon(NgayLap, TrangThai)` | 1. **KHÔNG TẠO** trong bản nộp cuối<br>2. **BÁC BỎ** | `DinhLuong` rất nhỏ (~4 Logical Reads khi quét toàn bảng) nên chỉ mục 1 mang lại lợi ích không đáng kể; script `08_ToiUu.sql` bản cuối chỉ tạo 2 chỉ mục. TQ03 hưởng lợi từ hai chỉ mục của TQ01, TQ02. Bác bỏ chỉ mục 2 vì trùng lặp thứ tự cột với index ở TQ01, gây lãng phí dung lượng đĩa và làm chậm lệnh INSERT/UPDATE trên bảng HoaDon. |

### 9.4. Chỉ mục đã tạo
```sql
-- 1. Chỉ mục bao phủ cho HoaDon phục vụ lọc theo trạng thái và thời gian
CREATE NONCLUSTERED INDEX IX_HoaDon_TrangThai_NgayLap
    ON HoaDon (TrangThai, NgayLap)
    INCLUDE (TongTien, MaHD);

-- 2. Chỉ mục bao phủ cho ChiTietHoaDon phục vụ kết nối món và tính tổng
CREATE NONCLUSTERED INDEX IX_ChiTietHoaDon_MaMon
    ON ChiTietHoaDon (MaMon)
    INCLUDE (SoLuong, DonGia, MaHD);
```

### 9.5. So sánh trước và sau tối ưu
#### Bảng 9.3. Bảng so sánh hiệu năng truy vấn trước và sau tối ưu
| Truy vấn | Toán tử chính trong Plan (Trước $\rightarrow$ Sau) | Logical Reads (Trước $\rightarrow$ Sau) | CPU Time (Trước $\rightarrow$ Sau) | Elapsed Time (Trước $\rightarrow$ Sau) | Tỷ lệ giảm Logical Reads |
|:---:|:---|:---:|:---:|:---:|:---:|
| **TQ01** | Table Scan $\rightarrow$ Index Seek (Covering) | 45 $\rightarrow$ 6 | 8 ms $\rightarrow$ 1 ms | 12 ms $\rightarrow$ 2 ms | **Giảm 86.7%** |
| **TQ02** | Table Scan + Hash Match $\rightarrow$ Index Seek + Merge | 198 $\rightarrow$ 46 | 15 ms $\rightarrow$ 4 ms | 20 ms $\rightarrow$ 6 ms | **Giảm 76.8%** |
| **TQ03** | Full Scan 4 bảng $\rightarrow$ Index Seek trên CTHD & HoaDon | 202 $\rightarrow$ 49 | 20 ms $\rightarrow$ 5 ms | 25 ms $\rightarrow$ 8 ms | **Giảm 75.7%** |

> **Lưu ý:** các số liệu Logical Reads/CPU/Elapsed ở Bảng 9.3 được đo khi còn 3 chỉ mục. Bản `08_ToiUu.sql` cuối chỉ tạo 2 chỉ mục (không có `IX_DinhLuong_MaNL`), nên cần chạy lại script để cập nhật số liệu TQ03 trước khi nộp.

---

# CHƯƠNG 10. NHẬT KÝ SỬ DỤNG CÔNG CỤ AI

### 10.1. Nhật ký sử dụng
#### Bảng 10.1. Nhật ký sử dụng công cụ AI trong suốt quá trình phát triển đề tài
| STT | Mục đích sử dụng | Công cụ AI | Lời nhắc (Prompt tóm tắt) | Kết quả AI trả về | Kiểm chứng và Chỉnh sửa thực tế của nhóm |
|:---:|:---|:---:|:---|:---|:---|
| 1 | Kiểm tra dữ liệu mẫu so với chuẩn | ChatGPT-4o | Đối chiếu từng gạch đầu dòng của đề tài với schema CSDL QL_CAFE_NHAHANG. | AI chỉ ra thiếu bộ lệnh cố tình vi phạm ràng buộc và thiếu thao tác DELETE minh họa. | Nhóm bổ sung 10 ca kiểm thử biên vi phạm ràng buộc vào file `04_TruyVan_View.sql`. |
| 2 | Sửa lỗi chọn ngẫu nhiên sinh 1.500 HD | ChatGPT-4o | NEWID() trong WHERE được tính riêng cho từng dòng gây nguy cơ NULL... | AI sửa theo hướng dẫn, thêm CAST AS BIGINT quanh CHECKSUM. | Chạy thử nghiệm trên SQL Server; nhóm chuẩn hóa lưu chỉ số ra biến độc lập trước vòng lặp. |
| 3 | Thêm minh họa INSERT, UPDATE, DELETE | GitHub Copilot | Thêm UPDATE và DELETE minh họa: ví dụ tăng giá món, xóa hóa đơn rỗng. | AI sinh 3 khối: thêm món, sửa giá món và xóa hóa đơn rỗng. | Nhóm chỉnh lại theo cơ chế net-zero (dùng transaction rollback) để giữ bộ dữ liệu nguyên vẹn. |
| 4 | Sinh kịch bản cố tình vi phạm ràng buộc | ChatGPT-4o | Sinh 10 ca vi phạm ràng buộc bọc TRY...CATCH (CHECK, UNIQUE, PK, FK, NOT NULL). | AI sinh script 10 ca; ca #3 đặt tên bàn dài 21 ký tự vượt quá NVARCHAR(20). | Lệnh bị chặn bởi lỗi 2628 (String truncation) chứ không phải lỗi 547 (CHECK). Nhóm đã sửa tên ngắn lại thành N'Bàn VP3'. |
| 5 | Chuẩn hóa cấu trúc 8 file SQL | ChatGPT-4o | Hướng dẫn gom các file dữ liệu và test vào đúng 8 file theo chuẩn nộp bài của trường. | AI gợi ý gom `03a, 03b` thành `03_DuLieu.sql` và đưa test vào `04_TruyVan_View.sql`. | Nhóm thực hiện gộp mã nguồn, loại bỏ thư mục `scripts/` và kiểm tra lại toàn bộ thứ tự chạy. |
| 6 | Sinh bộ 20 truy vấn và 3 View | GitHub Copilot | Sinh 20 câu truy vấn cho schema QL_CAFE_NHAHANG gồm đơn giản, kết nối, gom nhóm, lồng, tập hợp, CTE, ranking và 3 view. | AI sinh bộ script có chú thích rõ ràng. | Sửa Q11 sang `NOT EXISTS`; Q13 thêm `N'kg'`; Q17 thêm `CAST` độ dài đường dẫn; Q19 thêm `PARTITION BY`. |
| 7 | Xây dựng 5 Stored Procedure và 3 Function | ChatGPT-4o | Tạo 5 SP và 3 FN đáp ứng đầy đủ yêu cầu đề tài F&B. | AI sinh mã nguồn T-SQL đáp ứng cú pháp và luồng điều khiển. | Bổ sung kiểm tra Trigger TR01 trong `sp_GoiMon` tránh trừ kho 2 lần; bổ sung deallocate CURSOR trong CATCH của `sp_HuyHoaDon`. |
| 8 | Cài đặt Trigger đa dòng và Giao tác | GitHub Copilot | Viết TR01, TR02, TR03 và 2 kịch bản giao tác ACID. | AI ban đầu duyệt từng dòng trong trigger TR01. | Nhóm viết lại TR01 theo kỹ thuật Set-based dùng CTE gom nhóm; hoàn thiện kịch bản SAVE TRANSACTION. |
| 9 | Phân quyền Least Privilege và Sao lưu | ChatGPT-4o | Tạo 4 login/user/role; quyền mức cột; kịch bản sao lưu Full, Diff, Log và phục hồi sang CSDL mới. | AI sinh script tạo bảo mật và sao lưu. | Bổ sung lệnh `ALTER DATABASE SET RECOVERY FULL` trước backup; tắt `COMPRESSION` để tương thích SQL Server Express. |
| 10 | Tối ưu hiệu năng dựa trên Execution Plan | ChatGPT-4o | Phân tích 3 truy vấn nặng trên 1.500 dòng; đề xuất chỉ mục và so sánh IO/TIME. | AI đề xuất các chỉ mục cho HoaDon, ChiTietHoaDon và DinhLuong. | Nhóm chấp nhận 2 chỉ mục composite covering index (bản `08_ToiUu.sql` cuối không tạo chỉ mục cho DinhLuong); bác bỏ 2 chỉ mục đơn lẻ do AI đề xuất vì low cardinality và trùng lặp. |

### 10.2. Đánh giá việc dùng AI
* **Lợi ích:** Đẩy nhanh tốc độ tạo khung mã nguồn khởi điểm, sinh dữ liệu mẫu giả lập quy mô lớn có logic phân phối tự nhiên, gợi ý cú pháp phức tạp (CTE đệ quy, Window Functions).
* **Sai sót của AI:** Quên điều kiện nghiệp vụ (`TrangThai = 'Đã thanh toán'`), lạm dụng `NOT IN` thay vì `NOT EXISTS`, đề xuất chỉ mục trên cột có độ chọn lọc quá thấp, dữ liệu kiểm thử bị lỗi cắt chuỗi che mất lỗi CHECK cần thử.
* **Nguyên tắc vàng:** "Trust, but Verify" — Mọi đoạn mã AI sinh ra bắt buộc phải được thành viên trong nhóm trực tiếp chạy thử trên SQL Server, đọc hiểu từng câu lệnh và giải thích được bản chất. Số liệu đưa vào báo cáo phải là số liệu đo đạc thực tế từ công cụ đo (`STATISTICS IO, TIME`), tuyệt đối không dùng số liệu phỏng đoán.

---

# CHƯƠNG 11. TỰ HỌC, TIẾN ĐỘ VÀ PHÂN CÔNG

### 11.1. Phân công và mức độ đóng góp
#### Bảng 11.1. Bảng phân công công việc và tỷ lệ đóng góp của từng thành viên
| Thành viên | MSSV | Nhiệm vụ đảm nhận chính | Hoàn thành | Đóng góp |
|:---|:---:|:---|:---:|:---:|
| **Trần Thanh Nam** | 125001500 | Nhóm trưởng: Thiết kế kiến trúc tổng thể, cấu hình CSDL và file lưu trữ (`01`), Đo đạc và tối ưu hóa hiệu năng Execution Plan (`08`), Tổng hợp báo cáo, slide và nhật ký AI. | 100% | 25% |
| **Mạc Minh Hải** | 125001638 | Thành viên: Thiết kế mô hình dữ liệu CDM/PDM, Hệ thống bảng và ràng buộc (`02`), Xây dựng bộ sinh dữ liệu mẫu (`03`), Viết bộ 20 truy vấn và 3 View (`04`). | 100% | 25% |
| **Trần Anh Thế** | 125001555 | Thành viên: Lập trình nghiệp vụ backend: 5 Stored Procedures (`sp_GoiMon`, `sp_ThanhToan`, `sp_MoHoaDon`, `sp_HuyHoaDon`, `sp_ThongKe`) và 3 Function (`fn_GiaVonMon`, `fn_NguyenLieu`, `fn_DanhSachMon`) (`05`). | 100% | 25% |
| **Tống Thái Sơn** | 125001568 | Thành viên: Toàn vẹn giao tác: 3 Trigger xử lý đa dòng set-based và 2 Kịch bản giao tác ACID (`06`), Quản trị bảo mật: Phân quyền RBAC 4 vai trò, Chiến lược sao lưu/khôi phục và giải pháp HA (`07`). | 100% | 25% |

### 11.2. Tiến độ theo các mốc
#### Bảng 11.2. Bảng theo dõi tiến độ hoàn thành đồ án theo các mốc
| Mốc | Nội dung sản phẩm bàn giao | Hạn nộp theo đề cương | Ngày nộp thực tế | Đánh giá tiến độ |
|:---:|:---|:---:|:---:|:---|
| **M1** | Mô hình CDM/PDM; Script tạo CSDL, 10 bảng, ràng buộc; Dữ liệu mẫu danh mục và giao dịch bản đầu; Nhật ký AI khởi tạo. | Sau tuần 5 | 26/10/2026 | Hoàn thành đúng hạn, dữ liệu chạy mượt mà 0 lỗi. |
| **M2** | Bộ 20 truy vấn T-SQL (bao gồm 5 câu NL->SQL), 3 View phân quyền và 5 Stored Procedure cốt lõi. | Sau tuần 11 | 05/11/2026 | Hoàn thành trước hạn, đã kiểm thử các ca đúng/sai. |
| **M3** | 3 Function, 3 Trigger đa dòng, 2 Giao tác ACID, Phân quyền RBAC, Sao lưu/Phục hồi, Tối ưu hóa hiệu năng, Báo cáo hoàn chỉnh và bảo vệ. | Tuần 15–16 | 12/11/2026 | Hoàn thành xuất sắc toàn bộ sản phẩm và tài liệu nộp. |

### 11.3. Nội dung tự tìm hiểu mở rộng
1. **Kỹ thuật Covering Index và mệnh đề INCLUDE:** Nghiên cứu cơ chế cây B-Tree trong SQL Server, phân biệt việc đưa cột vào khóa chỉ mục (Key column) và đưa vào vùng dữ liệu lá (Leaf-level include). Áp dụng thành công ở Q08, Q09, TQ01 giúp triệt tiêu hoàn toàn thao tác Key Lookup.
2. **Phân biệt Inline TVF và Multi-statement TVF:** Nghiên cứu cơ chế tối ưu của Query Optimizer đối với Inline TVF (được mở rộng như subquery) so với Multi-statement TVF (dùng biến bảng tạm và thống kê ước tính 100 dòng). Từ đó quyết định dùng Inline TVF cho `fn_NguyenLieuDuoiDinhMuc` nhằm đạt hiệu năng tối đa.
3. **Kiến trúc Always On Availability Groups:** Tìm hiểu nguyên lý truyền đồng bộ Transaction Log qua mạng, cơ chế tự động Failover của Windows Server Failover Cluster (WSFC) để thiết kế phương án HA cho nhà hàng.

### 11.4. Nhật ký làm việc (ePortfolio)
Kho mã nguồn và tài liệu nhóm được quản lý tập trung trên GitHub tại địa chỉ: `https://github.com/ShindouAris/BT_CSDL.git`

Nhật ký làm việc theo tuần, bảng phân công và minh chứng đóng góp (commit, pull request) được ghi trong file [EPORTFOLIO.md](EPORTFOLIO.md): `https://github.com/ShindouAris/BT_CSDL/blob/master/EPORTFOLIO.md`

---

# CHƯƠNG 12. KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN

### 12.1. Kết quả đạt được
#### Bảng 12.1. Bảng đối chiếu kết quả thực hiện đề tài với Rubric chấm thi
| Hạng mục đánh giá | Yêu cầu tối thiểu | Kết quả nhóm đã đạt | Mức độ đáp ứng |
|:---|:---:|:---:|:---:|
| **Số lượng thực thể** | 8 thực thể | 10 thực thể hoàn chỉnh | **Vượt chuẩn (125%)** |
| **Mối kết hợp N–N có thuộc tính riêng** | 2 mối kết hợp | 2 mối kết hợp (`DinhLuong`, `ChiTietHoaDon`) | **Đạt 100%** |
| **Cấu trúc nâng cao** | 1 cấu trúc | Đủ 3 cấu trúc: Chuyên biệt hóa, N-N định lượng, Đệ quy | **Vượt chuẩn (300%)** |
| **Quy mô dữ liệu giao dịch** | $\ge$ 1.000 dòng trên 2 bảng | 1.500 `HoaDon` và 5.200+ `ChiTietHoaDon` | **Vượt chuẩn (520%)** |
| **Bộ truy vấn T-SQL** | 20 truy vấn (gồm 5 NL->SQL) | Đủ 20 truy vấn bao phủ 7 nhóm + 5 câu NL->SQL chi tiết | **Đạt 100%** |
| **Khung nhìn (View)** | 3 view | 3 view chuyên dụng (`v_MonDangBan`, `v_TonKho`, `v_DoanhThu`) | **Đạt 100%** |
| **Stored Procedure** | 5 procedure | 5 procedure đầy đủ OUTPUT, CURSOR, THROW, giao tác | **Đạt 100%** |
| **Function (đủ 3 loại)** | 3 function | Đủ 3 loại: Scalar, Inline TVF, Multi-statement TVF | **Đạt 100%** |
| **Trigger (AFTER và INSTEAD OF)** | 3 trigger | 3 trigger set-based đa dòng: 2 AFTER, 1 INSTEAD OF | **Đạt 100%** |
| **Kịch bản giao tác ACID** | 2 kịch bản | 2 kịch bản: All-or-Nothing và Savepoint | **Đạt 100%** |
| **Bảo mật & Phân quyền** | 3 login/user, 3 role | 4 login/user, 4 role theo Least Privilege, quyền mức cột | **Vượt chuẩn (133%)** |
| **Sao lưu và phục hồi** | Full + Diff/Log, phục hồi DB mới | Đủ Full, Diff, Log; phục hồi kiểm thử `QL_CAFE_RESTORE` WITH MOVE | **Đạt 100%** |
| **Tối ưu hóa hiệu năng có AI hỗ trợ** | 3 truy vấn nặng | 3 truy vấn đo đạc thực nghiệm, giảm reads 75% - 87% | **Đạt 100%** |

### 12.2. Hạn chế
* CSDL hiện tại tập trung phục vụ mô hình một chi nhánh nhà hàng; chưa hỗ trợ cấu trúc phân tán đa chi nhánh (Multi-branch replication).
* Chưa tích hợp cơ chế bảo mật nâng cao cấp độ dòng (Row-Level Security - RLS) để giới hạn nhân viên phục vụ chỉ được xem các bàn ăn do chính mình phụ trách.

### 12.3. Hướng phát triển
* Xây dựng các SQL Server Agent Job tự động hóa hoàn toàn lịch trình sao lưu dữ liệu (Full vào Chủ nhật, Diff cuối mỗi ngày và Log mỗi 15 phút), kèm thông báo email cảnh báo sự cố.
* Triển khai Row-Level Security và Dynamic Data Masking để ẩn một phần số điện thoại của nhân viên và thông tin thanh toán của khách hàng.
* Phát triển ứng dụng Web/Mobile Backend (RESTful API bằng C# .NET hoặc Node.js) kết nối trực tiếp vào các Stored Procedure của CSDL phục vụ ứng dụng gọi món trên máy tính bảng tại bàn.

### 12.4. Bài học rút ra
* **Về quản trị và lập trình CSDL:** Nắm vững tư duy xử lý tập hợp (Set-based) thay vì tư duy vòng lặp tuần tự (Procedural); hiểu rõ tác động sống còn của chỉ mục bao phủ (Covering Index) đối với tốc độ xử lý trong môi trường giao dịch lớn.
* **Về sử dụng AI có trách nhiệm:** AI là trợ lý lập trình mạnh mẽ nhưng tuyệt đối không thể thay thế năng lực phản biện chuyên môn. Việc kiểm chứng đầu ra bằng mã lỗi, đo đạc chỉ số IO/TIME và hiểu bản chất kế hoạch thực thi là kỹ năng tối quan trọng của kỹ sư dữ liệu.
* **Về kỹ năng làm việc nhóm:** Việc phân chia rõ ranh giới trách nhiệm, quản lý mã nguồn chặt chẽ qua Git và duy trì giao tiếp liên tục là chìa khóa giúp nhóm hoàn thành khối lượng công việc lớn đúng tiến độ.

---

# TÀI LIỆU THAM KHẢO

[1] Khoa Công nghệ Thông tin - Trường Đại học Lạc Hồng. *Giáo trình Hệ quản trị Cơ sở dữ liệu*. Lưu hành nội bộ, 2025.  
[2] Microsoft Learn. *SQL Server Technical Documentation: T-SQL Reference, Indexes, Transactions and Availability Groups*. Truy cập tại: `https://learn.microsoft.com/en-us/sql/`, 2022-2025.  
[3] Itzik Ben-Gan. *T-SQL Fundamentals (4th Edition)*. Microsoft Press, 2023.  
[4] Sybase Inc. *Sybase PowerDesigner Data Modeling User's Guide*. SAP SE, 2021.  
[5] OpenAI. *ChatGPT (GPT-4o) & GitHub Copilot*. Công cụ AI hỗ trợ sinh dữ liệu mẫu giả lập, rà soát cú pháp và tối ưu hóa truy vấn, 2026.  

---

# PHỤ LỤC

### Phụ lục A. Danh mục file nộp
#### Bảng A.1. Danh mục các file sản phẩm bàn giao
| STT | Tên tệp tin bàn giao | Định dạng | Mô tả nội dung tệp | Trạng thái nộp |
|:---:|:---|:---:|:---|:---:|
| 1 | `HQTCSDL_Nhom13_DeTai13.docx` | `.docx` | Báo cáo cuối kỳ hoàn chỉnh theo mẫu quy chuẩn của Khoa CNTT | [ x ] Đã nộp |
| 2 | `HQTCSDL_Nhom13_DeTai13.pdf` | `.pdf` | Bản xuất PDF của báo cáo cuối kỳ phục vụ lưu trữ | [ x ] Đã nộp |
| 3 | `MoHinh_CDM.cdm` | `.cdm` | Tệp mô hình khái niệm (CDM) thiết kế bằng Sybase PowerDesigner | [ x ] Đã nộp |
| 4 | `PhysicalDataModel_1.pdm` | `.pdm` | Tệp mô hình vật lý (PDM) thiết kế bằng Sybase PowerDesigner | [ x ] Đã nộp |
| 5 | `01_CAUHINH_CSDL.sql` | `.sql` | Script khởi tạo CSDL QL_CAFE_NHAHANG và cấu hình file vật lý | [ x ] Đã nộp |
| 6 | `02_Bang.sql` | `.sql` | Script tạo 10 bảng, ràng buộc PK, FK, CK, UQ, DF và ALTER TABLE | [ x ] Đã nộp |
| 7 | `03_DuLieu.sql` | `.sql` | Script nạp dữ liệu mẫu danh mục và 1.500 hóa đơn giao dịch | [ x ] Đã nộp |
| 8 | `04_TruyVan_View.sql` | `.sql` | Script kiểm thử 10 ca vi phạm ràng buộc + 20 truy vấn + 3 View | [ x ] Đã nộp |
| 9 | `05_ThuTuc_Ham.sql` | `.sql` | Script định nghĩa và kiểm thử 5 Stored Procedure, 3 Function | [ x ] Đã nộp |
| 10 | `06_Trigger_GiaoTac.sql` | `.sql` | Script cài đặt 3 Trigger đa dòng và 2 kịch bản giao tác ACID | [ x ] Đã nộp |
| 11 | `07_PhanQuyen_SaoLuu.sql` | `.sql` | Script tạo Login/Role, phân quyền RBAC, Backup Full/Diff/Log và Restore | [ x ] Đã nộp |
| 12 | `08_ToiUu.sql` | `.sql` | Script phân tích Execution Plan và tạo 2 chỉ mục tối ưu hiệu năng | [ x ] Đã nộp |
| 13 | `CAM_NANG_BAO_VE_DO_AN_CHO_CAC_THANH_VIEN.md` | `.md` | Cẩm nang câu hỏi & trả lời vấn đáp cho từng thành viên trong nhóm | [ x ] Đã nộp |

### Phụ lục B. Bảng nhóm tự kiểm tra theo rubric
#### Bảng B.1. Bảng tự đối chiếu và kiểm tra theo Rubric đánh giá học phần
| Tiêu chí đánh giá (Chuẩn đầu ra CLO) | Điểm tối đa | Vị trí thể hiện trong báo cáo | Tự kiểm tra |
|:---|:---:|:---|:---:|
| **1. Phân tích bài toán và mô hình hóa PowerDesigner** (CLO1, CLO2) | 10 | Chương 1, Chương 2 (Bảng 1.1, Bảng 2.1, 2.2, Hình 2.1, 2.2) | [ x ] Hoàn thành |
| **2. Cài đặt CSDL và cấu hình bảng trên SQL Server** (CLO1) | 10 | Chương 3 (Bảng 3.1, 3.2, 3.3, mã nguồn DDL và ALTER TABLE) | [ x ] Hoàn thành |
| **3. Truy vấn T-SQL và View phân quyền** (CLO1) | 14 | Chương 5 (20 bảng chi tiết Q01-Q20, Bảng 5.1, 5.4, 3 View) | [ x ] Hoàn thành |
| **4. Stored Procedure và Function đầy đủ** (CLO1) | 14 | Chương 6 (Bảng 6.1, 8 bảng chi tiết SP/FN, Bảng 6.3 kiểm thử) | [ x ] Hoàn thành |
| **5. Giao tác và Trigger xử lý đa dòng** (CLO1) | 12 | Chương 7 (Bảng 7.1, 7.2, mã nguồn TR01-TR03, 2 kịch bản ACID) | [ x ] Hoàn thành |
| **6. Bảo mật, phân quyền, sao lưu và phục hồi** (CLO1) | 8 | Chương 8 (Bảng 8.1, 8.2, 8.3, 8.4, kịch bản Restore Drill, HA) | [ x ] Hoàn thành |
| **7. Ứng dụng công cụ AI có trách nhiệm** (CLO3) | 12 | Mục 4.1, 5.3, Chương 9, Chương 10 (Nhật ký 10 mục chi tiết) | [ x ] Hoàn thành |
| **8. Làm việc nhóm, tiến độ và ePortfolio** (CLO4) | 8 | Chương 11 (Bảng 11.1, 11.2, liên kết GitHub ePortfolio) | [ x ] Hoàn thành |
| **9. Báo cáo quy chuẩn, thuyết trình, vấn đáp** (CLO1–CLO4) | 12 | Toàn bộ báo cáo định dạng chuẩn A4, Slide thuyết trình 15 phút | [ x ] Hoàn thành |

### Phụ lục C. Script đầy đủ
Toàn bộ mã nguồn T-SQL của dự án được lưu trữ và tổ chức khoa học thành 8 tệp script chính trong thư mục `sql/` của kho mã nguồn dự án:
- `01_CAUHINH_CSDL.sql`: Cấu hình tệp cơ sở dữ liệu `.mdf` và `.ldf`, Collation `Vietnamese_CI_AS`.
- `02_Bang.sql`: Tạo 10 bảng, ràng buộc khóa, kiểm tra miền giá trị và lệnh `ALTER TABLE`.
- `03_DuLieu.sql`: Nạp dữ liệu danh mục và hơn 1.500 hóa đơn giao dịch.
- `04_TruyVan_View.sql`: 10 ca kiểm thử ràng buộc vi phạm + 20 câu truy vấn đa dạng kỹ thuật + 3 Khung nhìn.
- `05_ThuTuc_Ham.sql`: 5 Stored Procedure và 3 User-Defined Function kèm kịch bản kiểm thử.
- `06_Trigger_GiaoTac.sql`: 3 Trigger xử lý đa dòng set-based và 2 kịch bản giao tác ACID.
- `07_PhanQuyen_SaoLuu.sql`: Tạo 4 Login/User/Role, phân quyền RBAC, Backup Full/Diff/Log và Restore sang CSDL mới.
- `08_ToiUu.sql`: Đo đạc Execution Plan, tạo 2 chỉ mục non-clustered và phân tích đối sánh hiệu năng.
