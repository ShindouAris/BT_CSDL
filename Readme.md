# Bài tập kết thúc học phần Cơ sở dữ liệu

## Thông tin dự án

| Mục | Nội dung |
|---|---|
| Hệ quản trị cơ sở dữ liệu | SQL Server 2025 |
| Công cụ quản lý mã nguồn | Git |
| Đề tài | **Đề tài 13 – Nhà hàng / quán cà phê** |
| Phạm vi | Bàn, món, thực đơn, nguyên liệu, hóa đơn và tồn kho |

## Mục lục

- [1. Đề tài](#1-đề-tài)
- [2. Lộ trình và sản phẩm theo mốc](#2-lộ-trình-và-sản-phẩm-theo-mốc)
- [3. Yêu cầu chung](#3-yêu-cầu-chung)
  - [3.1. Mô hình dữ liệu](#31-mô-hình-dữ-liệu)
  - [3.2. Cài đặt cơ sở dữ liệu](#32-cài-đặt-cơ-sở-dữ-liệu)
  - [3.3. Dữ liệu mẫu có AI hỗ trợ](#33-dữ-liệu-mẫu-có-ai-hỗ-trợ)
  - [3.4. Truy vấn và view](#34-truy-vấn-và-view)
  - [3.5. Stored procedure và function](#35-stored-procedure-và-function)
  - [3.6. Giao tác và trigger](#36-giao-tác-và-trigger)
  - [3.7. Bảo mật và sao lưu](#37-bảo-mật-và-sao-lưu)
  - [3.8. Tối ưu hiệu năng có AI hỗ trợ](#38-tối-ưu-hiệu-năng-có-ai-hỗ-trợ)
  - [3.9. Sử dụng AI có trách nhiệm](#39-sử-dụng-ai-có-trách-nhiệm)
  - [3.10. Sản phẩm nộp](#310-sản-phẩm-nộp)
  - [3.11. Làm việc nhóm](#311-làm-việc-nhóm)
  - [3.12. Bảo vệ và liêm chính học thuật](#312-bảo-vệ-và-liêm-chính-học-thuật)

## 1. Đề tài

### Đề tài 13: Nhà hàng / quán cà phê

- **Phạm vi:** Bàn, món, thực đơn, nguyên liệu, hóa đơn và tồn kho.
- **Cấu trúc nâng cao:**
  - Món – nguyên liệu: quan hệ N–N có thuộc tính định lượng.
  - Chuyên biệt hóa món: đồ ăn và thức uống.

### Định hướng triển khai

| Hạng mục | Gợi ý |
|---|---|
| Stored procedure | `sp_GoiMon` (trừ nguyên liệu theo định lượng), `sp_ThanhToan` |
| Function | `fn_GiaVonMon` (vô hướng), `fn_NguyenLieuDuoiDinhMuc` (hàm bảng) |
| Trigger và giao tác | Chặn tồn kho âm; chặn bàn đang có khách nhận đặt thêm; gọi món trừ nhiều nguyên liệu và hủy khi thiếu một nguyên liệu |
| Phân quyền | `PhucVu` (gọi món), `ThuNgan` (thanh toán), `Bep` (chỉ xem món cần chế biến), `QuanLy` (xem tồn kho và doanh thu) |
| Truy vấn và tối ưu | Món bán chạy theo khung giờ bằng CTE, `RANK`; nguyên liệu dưới định mức tồn |

## 2. Lộ trình và sản phẩm theo mốc

| Mốc | Thời điểm | Sản phẩm cần nộp | Nội dung học phần liên quan |
|---|---|---|---|
| **M1** | Sau tuần 5 | Mô hình CDM/PDM; script tạo CSDL, bảng và ràng buộc; dữ liệu mẫu bản đầu do AI hỗ trợ sinh và nhật ký AI | Chương 1–3: CSDL, bảng, kiểu dữ liệu, ràng buộc, DML |
| **M2** | Sau tuần 11 | Bộ 20 truy vấn (gồm các câu NL → SQL), các view và stored procedure | Chương 4–6: truy vấn, view, stored procedure |
| **M3** | Tuần 15–16 | Function, trigger, giao tác, phân quyền, sao lưu/phục hồi, tối ưu bằng Execution Plan, báo cáo hoàn chỉnh và bảo vệ | Chương 7–9: function, giao tác, trigger và quản trị |

> Thời điểm các mốc có thể được giảng viên điều chỉnh.

## 3. Yêu cầu chung

### 3.1. Mô hình dữ liệu

**CLO1, CLO2**

- Mỗi nhóm có 3–5 sinh viên và một đề tài riêng, không trùng nhóm khác.
- Có thể kế thừa mô hình từ học phần Cơ sở dữ liệu trước đó nếu được giảng viên cho phép; phải ghi rõ phần kế thừa và phần mở rộng.
- Vẽ ERD (CDM) bằng PowerDesigner với:
  - Ít nhất 8 thực thể.
  - Ít nhất 2 mối kết hợp N–N có thuộc tính riêng.
  - Ít nhất 1 cấu trúc nâng cao được chỉ định trong đề tài.
- Chuyển CDM sang PDM, thể hiện đầy đủ khóa chính, khóa ngoại và kiểu dữ liệu. PDM phải khớp với CDM.

### 3.2. Cài đặt cơ sở dữ liệu

**CLO1**

Trên SQL Server:

- Tạo CSDL với cấu hình file dữ liệu và file log rõ ràng.
- Tạo bảng với khóa chính, khóa ngoại, `CHECK`, `UNIQUE` và `DEFAULT`.
- Có ít nhất một đoạn `ALTER TABLE` để bổ sung hoặc sửa ràng buộc.
- Thực hiện đầy đủ `INSERT`, `UPDATE` và `DELETE`.
- Script phải chạy được từ đầu đến cuối.

### 3.3. Dữ liệu mẫu có AI hỗ trợ

**CLO3**

- Dùng AI để sinh dữ liệu giả lập; không dùng dữ liệu cá nhân thật.
- Có ít nhất 10 dòng cho mỗi bảng danh mục.
- Có ít nhất 1.000 dòng cho tối thiểu 2 bảng giao dịch để phục vụ tối ưu.
- Dữ liệu phải thỏa các ràng buộc và có cả các dòng biên.
- Có một bộ lệnh cố tình vi phạm ràng buộc để chứng minh hệ thống từ chối đúng.

### 3.4. Truy vấn và view

**CLO1, CLO3**

Viết ít nhất 20 truy vấn và ít nhất 3 view. Trong đó, một view phải dùng để giới hạn cột hoặc dòng nhằm phục vụ phân quyền.

| Loại truy vấn | Số lượng tối thiểu | Yêu cầu |
|---|---:|---|
| Đơn giản | 4 | `SELECT` – `FROM` – `WHERE`, có hàm và phép toán |
| Kết nối | 3 | Có ít nhất 1 phép kết ngoài |
| Gom nhóm | 3 | Có `GROUP BY`, `HAVING`, `ORDER BY` |
| Truy vấn con/lồng | 4 | Dùng `IN`, `EXISTS`, `ALL`, `ANY`; có ít nhất 1 câu dạng “tất cả” (phép chia) |
| Phép toán tập hợp | 2 | Dùng `UNION`, `INTERSECT`, `EXCEPT` |
| Common Table Expression | 2 | Dùng CTE đệ quy nếu đề tài có cấu trúc đệ quy |
| Ranking functions | 2 | Dùng `ROW_NUMBER`, `RANK`, `DENSE_RANK` hoặc `NTILE` |

Ít nhất 5 trong 20 truy vấn phải được sinh từ yêu cầu ngôn ngữ tự nhiên bằng Copilot/LLM. Với mỗi truy vấn, ghi lại prompt, mã được sinh, kết quả rà soát và phần đã sửa.

### 3.5. Stored procedure và function

**CLO1**

- Có ít nhất 5 stored procedure, trong đó bao gồm:
  - 1 thủ tục dùng tham số `OUTPUT`.
  - 1 thủ tục dùng phát biểu điều khiển (`IF`, `WHILE` hoặc `CASE`).
  - 1 thủ tục kiểm tra dữ liệu đầu vào và báo lỗi bằng `THROW` hoặc `RAISERROR`.
  - 1 thủ tục thao tác trên nhiều bảng.
- Có ít nhất 3 function, gồm:
  - Hàm vô hướng.
  - Hàm bảng inline.
  - Hàm bảng nhiều câu lệnh.
- Mỗi đối tượng phải có ca chạy thử đúng và ca chạy thử sai.

### 3.6. Giao tác và trigger

**CLO1**

- Có ít nhất 3 trigger, bao gồm cả `AFTER` và `INSTEAD OF`.
- Trigger phải xử lý đúng khi một câu lệnh tác động nhiều dòng bằng bảng `inserted` và `deleted`.
- Có ít nhất 2 kịch bản giao tác dùng `BEGIN TRAN`, `COMMIT`, `ROLLBACK` và `TRY...CATCH`.
- Demo cả trường hợp thành công và thất bại.
- Trigger và giao tác phải gắn với quy tắc nghiệp vụ của đề tài.

### 3.7. Bảo mật và sao lưu

**CLO1**

- Tạo ít nhất 3 login/user và 3 role theo nguyên tắc quyền tối thiểu.
- Phân quyền bằng `GRANT`, `DENY`, `REVOKE` trên bảng, view và thủ tục.
- Kiểm chứng quyền bằng cách đăng nhập hoặc chạy thử với từng vai trò.
- Thực hiện sao lưu Full và ít nhất một loại khác (Differential hoặc Log).
- Phục hồi thành công vào một CSDL mới.
- Trình bày khoảng một trang về phương án tính sẵn sàng cao (HA) phù hợp với đề tài; không bắt buộc triển khai.

### 3.8. Tối ưu hiệu năng có AI hỗ trợ

**CLO3**

- Chọn ít nhất 3 truy vấn nặng trên các bảng có từ 1.000 dòng.
- Xem Execution Plan và nhờ AI phân tích, đề xuất chỉ mục.
- Tạo chỉ mục và so sánh trước/sau bằng `SET STATISTICS IO`, `SET STATISTICS TIME` hoặc kế hoạch thực thi.
- Đánh giá từng đề xuất của AI là chấp nhận hoặc bác bỏ, kèm lý do.

### 3.9. Sử dụng AI có trách nhiệm

**CLO3**

Sinh viên được khuyến khích dùng AI theo đề cương nhưng phải:

1. Ghi nhật ký sử dụng theo mẫu ở cuối tài liệu.
2. Chạy thật và kiểm chứng mọi mã do AI sinh.
3. Không đưa dữ liệu thật hoặc thông tin nhạy cảm vào lời nhắc.
4. Tự giải thích được mọi dòng mã nộp. Mã hoặc nội dung không giải thích được khi vấn đáp không được tính điểm.

### 3.10. Sản phẩm nộp

- Báo cáo Word/PDF.
- File mô hình PowerDesigner: `.cdm` và `.pdm`.
- Các script `.sql`, tách theo thứ tự chạy:

  ```text
  01_CSDL
  02_Bang
  03_DuLieu
  04_TruyVan_View
  05_ThuTuc_Ham
  06_Trigger_GiaoTac
  07_PhanQuyen_SaoLuu
  08_ToiUu
  ```

- Nhật ký sử dụng AI.
- Bảng phân công và nhật ký làm việc trên ePortfolio.

### 3.11. Làm việc nhóm

- Bảng phân công phải nêu rõ vai trò và phần việc của từng thành viên.
- Mỗi thành viên phụ trách và bảo vệ được ít nhất một nhóm đối tượng, ví dụ: truy vấn, thủ tục, trigger hoặc phân quyền.
- Nhật ký ePortfolio được cập nhật theo tuần.

### 3.12. Bảo vệ và liêm chính học thuật

- Thuyết trình khoảng 15 phút.
- Demo chạy script trực tiếp trên SQL Server.
- Vấn đáp từng cá nhân.
- Ghi rõ nguồn tham khảo, bao gồm giáo trình [1], tài liệu [2] và mọi công cụ AI đã sử dụng.
- Mọi thành viên phải giải thích được sản phẩm của nhóm.
