-- Script này dùng để reset cơ sở dữ liệu về trạng thái ban đầu (xóa tất cả các bảng và dữ liệu)
-- Sau khi chạy file này, chạy lại theo đúng thứ tự:
--   02_Bang.sql  ->  03a_DanhMuc.sql  ->  03b_GiaoDich.sql  ->  04_TEST_VI_PHAM.sql
-- Lưu ý: danh sách DROP dưới đây phải khớp với danh sách bảng trong 02_Bang.sql.
--        Khi thêm bảng mới, cập nhật CẢ HAI file.

use QL_CAFE_NHAHANG;
GO

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