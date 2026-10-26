-- Script này dùng để reset cơ sở dữ liệu về trạng thái ban đầu (xóa tất cả các bảng và dữ liệu)
-- Chạy lại 02_Bang.sql và 01_SEED.sql, 02_SEED.sql để tạo lại các bảng và dữ liệu mẫu.

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