/* =====================================================================
   03_DuLieu.sql — NẠP DỮ LIỆU MẪU (DANH MỤC & GIAO DỊCH)
   Đề tài 13: Nhà hàng / Quán cà phê
   CSDL: QL_CAFE_NHAHANG
   =====================================================================
   - Chạy SAU: 01_CAUHINH_CSDL.sql -> 02_Bang.sql
   - Gồm 2 phần:
       PHẦN 1: Dữ liệu danh mục nền (>10 dòng/bảng cho 8 bảng danh mục)
       PHẦN 2: Dữ liệu giao dịch lớn (1.500 Hóa đơn + ~5.200 Chi tiết)
   - Toàn bộ dữ liệu là HƯ CẤU, thỏa mãn toàn bộ ràng buộc toàn vẹn.
   ===================================================================== */

USE QL_CAFE_NHAHANG;
GO

SET NOCOUNT ON;
GO

PRINT N'======================================================';
PRINT N'=== PHẦN 1: NẠP DỮ LIỆU DANH MỤC (03a)            ===';
PRINT N'======================================================';
GO

/* =====================================================================
   CSDL QUẢN LÝ NHÀ HÀNG / QUÁN CÀ PHÊ — 03a: DỮ LIỆU DANH MỤC
   (phần 1 của bộ 03_DuLieu; phần 2 là 03_DuLieu.sql (Phần 2))
   ---------------------------------------------------------------------
   - Chạy SAU: sql/01_CAUHINH_CSDL.sql → sql/02_Bang.sql
   - Toàn bộ dữ liệu là HƯ CẤU, không sử dụng thông tin người thật.
   - Chạy trên CSDL rỗng: các cột IDENTITY bắt đầu từ 1.
   - Thứ tự nạp: LoaiMon -> Ban -> NhanVien -> NguyenLieu -> Mon
                 -> MonAn -> ThucUong -> DinhLuong.
   ===================================================================== */
    
Use QL_CAFE_NHAHANG;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* =================================================================
       1) LOẠI MÓN: 11 dòng = 8 loại gốc + 3 loại con (dùng MaLoaiCha)
       ================================================================= */
    INSERT INTO LoaiMon (TenLoai, MaLoaiCha) VALUES
        (N'Món ăn',          NULL),   -- 1  (loại gốc, chứa 3 loại con)
        (N'Cà phê Việt',     NULL),   -- 2
        (N'Cà phê pha máy',  NULL),   -- 3
        (N'Trà',             NULL),   -- 4
        (N'Trà sữa',         NULL),   -- 5
        (N'Sinh tố',         NULL),   -- 6
        (N'Nước ép',         NULL),   -- 7
        (N'Đá xay',          NULL);   -- 8

    INSERT INTO LoaiMon (TenLoai, MaLoaiCha) VALUES
        (N'Khai vị',          1),     -- 9  (con của "Món ăn")
        (N'Món chính',        1),     -- 10 (con của "Món ăn")
        (N'Tráng miệng',      1);     -- 11 (con của "Món ăn")

    /* =================================================================
       2) BÀN: 15 bàn - 5 "Có khách", 3 "Đã đặt", 7 "Trống"
       ================================================================= */
    INSERT INTO Ban (TenBan, SucChua, TrangThai) VALUES
        (N'Bàn 01',  4, N'Có khách'),   -- 1
        (N'Bàn 02',  4, N'Có khách'),   -- 2
        (N'Bàn 03',  2, N'Có khách'),   -- 3
        (N'Bàn 04',  6, N'Có khách'),   -- 4
        (N'Bàn 05',  8, N'Có khách'),   -- 5
        (N'Bàn 06',  4, N'Đã đặt'),     -- 6
        (N'Bàn 07',  6, N'Đã đặt'),     -- 7
        (N'Bàn 08', 10, N'Đã đặt'),     -- 8
        (N'Bàn 09',  2, N'Trống'),      -- 9
        (N'Bàn 10',  4, N'Trống'),      -- 10
        (N'Bàn 11',  4, N'Trống'),      -- 11
        (N'Bàn 12',  6, N'Trống'),      -- 12
        (N'Bàn 13',  8, N'Trống'),      -- 13
        (N'Bàn 14', 10, N'Trống'),      -- 14
        (N'Bàn 15', 12, N'Trống');      -- 15

    /* =================================================================
       3) NHÂN VIÊN: 12 người - QuanLy 2, Bep 3, PhucVu 4, ThuNgan 3
       ================================================================= */
    INSERT INTO NhanVien (HoTen, ChucVu, SoDienThoai, NgayVaoLam) VALUES
        (N'Nguyễn Văn An',     N'QuanLy',  '0901234501', '2019-03-01'),  -- 1
        (N'Trần Thị Bích',     N'QuanLy',  '0901234502', '2020-07-15'),  -- 2
        (N'Lê Hoàng Cường',    N'Bep',     '0901234503', '2021-01-10'),  -- 3
        (N'Phạm Minh Dũng',    N'Bep',     '0901234504', '2021-05-20'),  -- 4
        (N'Hoàng Thị Em',      N'Bep',     '0901234505', '2022-02-14'),  -- 5
        (N'Vũ Văn Hùng',       N'PhucVu',  '0901234506', '2022-06-01'),  -- 6
        (N'Đặng Thị Hoa',      N'PhucVu',  '0901234507', '2022-09-12'),  -- 7
        (N'Bùi Minh Khang',    N'PhucVu',  '0901234508', '2023-01-05'),  -- 8
        (N'Ngô Thị Lan',       N'PhucVu',  '0901234509', '2023-04-18'),  -- 9
        (N'Đỗ Văn Nam',        N'ThuNgan', '0901234510', '2023-08-22'),  -- 10
        (N'Trịnh Thị Oanh',    N'ThuNgan', '0901234511', '2024-01-08'),  -- 11
        (N'Lý Văn Phúc',       N'ThuNgan', '0901234512', '2024-03-25');  -- 12

    /* =================================================================
       4) NGUYÊN LIỆU: 28 dòng
          - 4, 22        : TonKho = 0                 (2 dòng)
          - 8, 20        : TonKho = DinhMucTon        (2 dòng)
          - 2, 7, 12, 26 : 0 < TonKho < DinhMucTon    (4 dòng)
          - 19, 24       : không xuất hiện trong DinhLuong
          - 20 dòng còn lại: TonKho > DinhMucTon
       ================================================================= */
    INSERT INTO NguyenLieu (TenNL, DonViTinh, TonKho, DinhMucTon, DonGiaNhap) VALUES
        (N'Gạo tẻ',            N'kg',   120.00,  50.00,  20000.00),  -- 1
        (N'Bánh phở tươi',     N'kg',     4.00,  10.00,  25000.00),  -- 2  [TK < định mức]
        (N'Bánh tráng',        N'cái',  800.00, 300.00,   1200.00),  -- 3
        (N'Thịt bò',           N'kg',     0.00,  15.00, 290000.00),  -- 4  [TK = 0]
        (N'Thịt heo',          N'kg',    22.00,  12.00, 150000.00),  -- 5
        (N'Ức gà',             N'kg',    18.00,  10.00, 110000.00),  -- 6
        (N'Tôm tươi',          N'kg',     2.50,   8.00, 270000.00),  -- 7  [TK < định mức]
        (N'Trứng gà',          N'quả',  180.00, 180.00,   3500.00),  -- 8  [TK = định mức]
        (N'Khoai tây',         N'kg',    40.00,  15.00,  28000.00),  -- 9
        (N'Hành tím',          N'kg',    12.00,   5.00,  32000.00),  -- 10
        (N'Tỏi',               N'kg',     9.00,   4.00,  45000.00),  -- 11
        (N'Bơ lạt',            N'kg',     1.20,   4.00, 260000.00),  -- 12 [TK < định mức]
        (N'Nước mắm',          N'lít',   20.00,   8.00,  65000.00),  -- 13
        (N'Đường trắng',       N'kg',    35.00,  15.00,  24000.00),  -- 14
        (N'Dầu ăn',            N'lít',   25.00,  10.00,  55000.00),  -- 15
        (N'Nước cốt dừa',      N'lít',   12.00,   5.00,  40000.00),  -- 16
        (N'Chuối sứ',          N'kg',    15.00,   6.00,  22000.00),  -- 17
        (N'Cà phê Robusta',    N'kg',    30.00,  12.00, 220000.00),  -- 18
        (N'Cà phê Arabica',    N'kg',     8.00,   5.00, 340000.00),  -- 19 [không dùng]
        (N'Sữa đặc',           N'lon',   96.00,  96.00,  28000.00),  -- 20 [TK = định mức]
        (N'Sữa tươi',          N'lít',   60.00,  25.00,  35000.00),  -- 21
        (N'Kem sữa',           N'hộp',    0.00,   6.00,  95000.00),  -- 22 [TK = 0]
        (N'Trà đen',           N'kg',    14.00,   5.00, 180000.00),  -- 23
        (N'Bột matcha',        N'kg',     4.00,   2.00, 480000.00),  -- 24 [không dùng]
        (N'Đá viên',           N'kg',   150.00,  50.00,   6000.00),  -- 25
        (N'Chanh',             N'kg',     1.50,   4.00,  26000.00),  -- 26 [TK < định mức]
        (N'Cam',               N'kg',    18.00,   8.00,  32000.00),  -- 27
        (N'Xoài cát',          N'kg',    12.00,   5.00,  55000.00);  -- 28

    /* =================================================================
       5) MÓN: 36 món = 18 món ăn (Nhom 'A') + 18 thức uống (Nhom 'U')
          - 2 món DangBan = 0: 5 (tạm ngưng), 22 (tạm ngưng)
          - 35, 36: món mới, CHƯA phát sinh giao dịch (đặt cuối danh sách)
       ================================================================= */
    INSERT INTO Mon (TenMon, MaLoai, GiaBan, Nhom, DangBan) VALUES
        -- ---- MÓN ĂN (Nhom = 'A') ----
        (N'Gỏi cuốn tôm thịt',          9,   59000, 'A', 1),  -- 1
        (N'Chả giò rế',                 9,   65000, 'A', 1),  -- 2
        (N'Khoai tây chiên tỏi',        9,   45000, 'A', 1),  -- 3
        (N'Gà chiên nước mắm',          9,   89000, 'A', 1),  -- 4
        (N'Tôm chiên giòn',             9,   95000, 'A', 0),  -- 5  tạm ngưng (tôm khan hiếm)
        (N'Cơm gà Hải Nam',            10,   79000, 'A', 1),  -- 6
        (N'Cơm chiên dương châu',      10,   69000, 'A', 1),  -- 7
        (N'Bò lúc lắc khoai tây',      10,  129000, 'A', 1),  -- 8
        (N'Phở bò tái',                10,   75000, 'A', 1),  -- 9
        (N'Cơm tấm sườn nướng',        10,   72000, 'A', 1),  -- 10
        (N'Gà kho cốt dừa',            10,   98000, 'A', 1),  -- 11
        (N'Cháo gà',                   10,   55000, 'A', 1),  -- 12
        (N'Tôm kho tàu',               10,   99000, 'A', 1),  -- 13
        (N'Bò xào tỏi',                10,  119000, 'A', 1),  -- 14
        (N'Bánh flan',                 11,   29000, 'A', 1),  -- 15
        (N'Kem dừa',                   11,   35000, 'A', 1),  -- 16
        (N'Chè chuối',                 11,   25000, 'A', 1),  -- 17
        (N'Chuối chiên',               11,   27000, 'A', 1),  -- 18
        -- ---- THỨC UỐNG (Nhom = 'U') ----
        (N'Cà phê đen đá',              2,   35000, 'U', 1),  -- 19
        (N'Cà phê sữa đá',              2,   39000, 'U', 1),  -- 20
        (N'Bạc xỉu',                    2,   42000, 'U', 1),  -- 21
        (N'Cà phê muối',                2,   45000, 'U', 0),  -- 22 tạm ngưng (thiếu kem sữa)
        (N'Cà phê cốt dừa',             2,   45000, 'U', 1),  -- 23
        (N'Latte nóng',                 3,   59000, 'U', 1),  -- 24
        (N'Trà đen chanh',              4,   35000, 'U', 1),  -- 25
        (N'Trà sữa truyền thống',       5,   45000, 'U', 1),  -- 26
        (N'Trà sữa cốt dừa',            5,   47000, 'U', 1),  -- 27
        (N'Trà đá',                     4,   15000, 'U', 1),  -- 28
        (N'Sinh tố xoài',               6,   49000, 'U', 1),  -- 29
        (N'Sinh tố chuối',              6,   45000, 'U', 1),  -- 30
        (N'Sinh tố cốt dừa',            6,   45000, 'U', 1),  -- 31
        (N'Nước ép cam',                7,   40000, 'U', 1),  -- 32
        (N'Nước chanh',                 7,   30000, 'U', 1),  -- 33
        (N'Cà phê đá xay',              8,   55000, 'U', 1),  -- 34
        (N'Trà sữa nóng',               5,   45000, 'U', 1),  -- 35 MỚI - chưa có giao dịch
        (N'Cà phê sữa nóng',            2,   39000, 'U', 1);  -- 36 MỚI - chưa có giao dịch

    /* =================================================================
       6) MÓN ĂN (MonAn): chỉ 18 món Nhom = 'A' (MaMon 1..18)
       ================================================================= */
    INSERT INTO MonAn (MaMon, ThoiGianCheBien, CayHayKhong) VALUES
        ( 1, 10, 0),   -- Gỏi cuốn tôm thịt
        ( 2, 15, 0),   -- Chả giò rế
        ( 3, 12, 0),   -- Khoai tây chiên tỏi
        ( 4, 20, 0),   -- Gà chiên nước mắm
        ( 5, 15, 0),   -- Tôm chiên giòn
        ( 6, 30, 0),   -- Cơm gà Hải Nam
        ( 7, 18, 0),   -- Cơm chiên dương châu
        ( 8, 25, 0),   -- Bò lúc lắc khoai tây
        ( 9, 20, 1),   -- Phở bò tái (cay)
        (10, 30, 0),   -- Cơm tấm sườn nướng
        (11, 35, 1),   -- Gà kho cốt dừa (cay)
        (12, 25, 0),   -- Cháo gà
        (13, 30, 0),   -- Tôm kho tàu
        (14, 15, 0),   -- Bò xào tỏi
        (15, 45, 0),   -- Bánh flan
        (16, 40, 0),   -- Kem dừa
        (17, 35, 0),   -- Chè chuối
        (18, 15, 0);   -- Chuối chiên

    /* =================================================================
       7) THỨC UỐNG (ThucUong): chỉ 18 món Nhom = 'U' (MaMon 19..36)
       ================================================================= */
    INSERT INTO ThucUong (MaMon, Size, CoDa, CoDuong) VALUES
        (19, 'S', 1, 1),   -- Cà phê đen đá
        (20, 'M', 1, 1),   -- Cà phê sữa đá
        (21, 'M', 1, 1),   -- Bạc xỉu
        (22, 'M', 0, 1),   -- Cà phê muối (nóng)
        (23, 'M', 1, 1),   -- Cà phê cốt dừa
        (24, 'M', 0, 1),   -- Latte nóng
        (25, 'L', 1, 1),   -- Trà đen chanh
        (26, 'M', 1, 1),   -- Trà sữa truyền thống
        (27, 'M', 1, 1),   -- Trà sữa cốt dừa
        (28, 'L', 1, 1),   -- Trà đá
        (29, 'L', 1, 1),   -- Sinh tố xoài
        (30, 'L', 1, 1),   -- Sinh tố chuối
        (31, 'L', 1, 1),   -- Sinh tố cốt dừa
        (32, 'L', 1, 1),   -- Nước ép cam
        (33, 'L', 1, 1),   -- Nước chanh
        (34, 'L', 1, 1),   -- Cà phê đá xay
        (35, 'M', 0, 1),   -- Trà sữa nóng
        (36, 'M', 0, 1);   -- Cà phê sữa nóng

    /* =================================================================
       8) ĐỊNH LƯỢNG (DinhLuong): 130 dòng, mỗi món 3-4 nguyên liệu
          - NL 19 (Cà phê Arabica) và 24 (Bột matcha) KHÔNG xuất hiện
       ================================================================= */
    INSERT INTO DinhLuong (MaMon, MaNL, SoLuong) VALUES
        -- Món 1: Gỏi cuốn tôm thịt
        (1, 3, 3.00), (1, 7, 0.06), (1, 5, 0.05), (1, 10, 0.01),
        -- Món 2: Chả giò rế
        (2, 3, 4.00), (2, 5, 0.08), (2, 8, 1.00), (2, 15, 0.03),
        -- Món 3: Khoai tây chiên tỏi
        (3, 9, 0.15), (3, 11, 0.01), (3, 15, 0.05),
        -- Món 4: Gà chiên nước mắm
        (4, 6, 0.20), (4, 13, 0.02), (4, 11, 0.01), (4, 15, 0.05),
        -- Món 5: Tôm chiên giòn
        (5, 7, 0.10), (5, 15, 0.05), (5, 11, 0.01),
        -- Món 6: Cơm gà Hải Nam
        (6, 1, 0.15), (6, 6, 0.15), (6, 10, 0.01), (6, 13, 0.015),
        -- Món 7: Cơm chiên dương châu
        (7, 1, 0.15), (7, 8, 1.00), (7, 7, 0.05), (7, 15, 0.03),
        -- Món 8: Bò lúc lắc khoai tây
        (8, 4, 0.15), (8, 9, 0.10), (8, 12, 0.02), (8, 13, 0.015),
        -- Món 9: Phở bò tái
        (9, 2, 0.20), (9, 4, 0.10), (9, 10, 0.02), (9, 13, 0.02),
        -- Món 10: Cơm tấm sườn nướng
        (10, 1, 0.15), (10, 5, 0.15), (10, 13, 0.02), (10, 11, 0.01),
        -- Món 11: Gà kho cốt dừa
        (11, 6, 0.20), (11, 16, 0.10), (11, 13, 0.02), (11, 14, 0.01),
        -- Món 12: Cháo gà
        (12, 1, 0.08), (12, 6, 0.10), (12, 10, 0.01), (12, 13, 0.01),
        -- Món 13: Tôm kho tàu
        (13, 7, 0.12), (13, 13, 0.02), (13, 14, 0.01), (13, 10, 0.01),
        -- Món 14: Bò xào tỏi
        (14, 4, 0.12), (14, 11, 0.02), (14, 15, 0.03), (14, 13, 0.01),
        -- Món 15: Bánh flan
        (15, 8, 1.00), (15, 20, 0.30), (15, 21, 0.10), (15, 14, 0.02),
        -- Món 16: Kem dừa
        (16, 16, 0.08), (16, 20, 0.20), (16, 22, 0.05), (16, 14, 0.01),
        -- Món 17: Chè chuối
        (17, 17, 0.12), (17, 16, 0.08), (17, 14, 0.02),
        -- Món 18: Chuối chiên
        (18, 17, 0.10), (18, 15, 0.05), (18, 14, 0.01),
        -- Món 19: Cà phê đen đá
        (19, 18, 0.018), (19, 14, 0.01), (19, 25, 0.15),
        -- Món 20: Cà phê sữa đá
        (20, 18, 0.018), (20, 20, 0.30), (20, 25, 0.15),
        -- Món 21: Bạc xỉu
        (21, 18, 0.012), (21, 21, 0.12), (21, 25, 0.12),
        -- Món 22: Cà phê muối
        (22, 18, 0.018), (22, 20, 0.25), (22, 22, 0.03),
        -- Món 23: Cà phê cốt dừa
        (23, 18, 0.018), (23, 16, 0.06), (23, 20, 0.20), (23, 25, 0.15),
        -- Món 24: Latte nóng
        (24, 18, 0.018), (24, 21, 0.15), (24, 22, 0.02),
        -- Món 25: Trà đen chanh
        (25, 23, 0.008), (25, 26, 0.02), (25, 14, 0.015), (25, 25, 0.20),
        -- Món 26: Trà sữa truyền thống
        (26, 23, 0.01), (26, 20, 0.25), (26, 21, 0.10), (26, 25, 0.18),
        -- Món 27: Trà sữa cốt dừa
        (27, 23, 0.01), (27, 16, 0.06), (27, 20, 0.20), (27, 25, 0.15),
        -- Món 28: Trà đá
        (28, 23, 0.006), (28, 14, 0.008), (28, 25, 0.20),
        -- Món 29: Sinh tố xoài
        (29, 28, 0.12), (29, 21, 0.08), (29, 20, 0.20), (29, 25, 0.10),
        -- Món 30: Sinh tố chuối
        (30, 17, 0.10), (30, 21, 0.08), (30, 20, 0.20), (30, 25, 0.10),
        -- Món 31: Sinh tố cốt dừa
        (31, 16, 0.08), (31, 21, 0.08), (31, 14, 0.015), (31, 25, 0.10),
        -- Món 32: Nước ép cam
        (32, 27, 0.20), (32, 14, 0.01), (32, 25, 0.10),
        -- Món 33: Nước chanh
        (33, 26, 0.04), (33, 14, 0.025), (33, 25, 0.15),
        -- Món 34: Cà phê đá xay
        (34, 18, 0.015), (34, 20, 0.25), (34, 22, 0.04), (34, 25, 0.18),
        -- Món 35: Trà sữa nóng (món mới)
        (35, 23, 0.01), (35, 21, 0.12), (35, 14, 0.01),
        -- Món 36: Cà phê sữa nóng (món mới)
        (36, 18, 0.02), (36, 20, 0.30), (36, 21, 0.05);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

/* =====================================================================
   KIỂM TRA NHANH SAU KHI NẠP
   ===================================================================== */
SELECT
    (SELECT COUNT(*) FROM LoaiMon)   AS SoLoaiMon,
    (SELECT COUNT(*) FROM Ban)       AS SoBan,
    (SELECT COUNT(*) FROM NhanVien)  AS SoNhanVien,
    (SELECT COUNT(*) FROM NguyenLieu) AS SoNguyenLieu,
    (SELECT COUNT(*) FROM Mon)       AS SoMon,
    (SELECT COUNT(*) FROM MonAn)     AS SoMonAn,
    (SELECT COUNT(*) FROM ThucUong)  AS SoThucUong,
    (SELECT COUNT(*) FROM DinhLuong) AS SoDinhLuong;

SELECT
    SUM(CASE WHEN TonKho = 0 THEN 1 ELSE 0 END)                          AS TonKho_Bang0,
    SUM(CASE WHEN TonKho = DinhMucTon THEN 1 ELSE 0 END)                 AS TonKho_BangDinhMuc,
    SUM(CASE WHEN TonKho > 0 AND TonKho < DinhMucTon THEN 1 ELSE 0 END)  AS TonKho_DuoiDinhMuc,
    SUM(CASE WHEN TonKho > DinhMucTon THEN 1 ELSE 0 END)                 AS TonKho_TrenDinhMuc
FROM NguyenLieu;

SELECT nl.MaNL, nl.TenNL
FROM NguyenLieu nl
WHERE NOT EXISTS (SELECT 1 FROM DinhLuong dl WHERE dl.MaNL = nl.MaNL);

PRINT N'';
PRINT N'======================================================';
PRINT N'=== PHẦN 2: NẠP DỮ LIỆU GIAO DỊCH (03b)            ===';
PRINT N'======================================================';
GO

/* =====================================================================
   CSDL QUẢN LÝ NHÀ HÀNG / QUÁN CÀ PHÊ — 03b: NẠP DỮ LIỆU GIAO DỊCH
   =====================================================================

   VỊ TRÍ TRONG CHUỖI
       01_CAUHINH_CSDL.sql  →  02_Bang.sql  →  03_DuLieu.sql (Phần 1)  →  [03b]
       (04_TEST_VI_PHAM.sql chạy sau cùng, chỉ để kiểm chứng ràng buộc)

   KẾT QUẢ
       - 1.500 hóa đơn, trong đó:
            5 hóa đơn "Mở"          : mỗi bàn đang "Có khách" đúng 1 hóa đơn
            1.390 hóa đơn "Đã thanh toán"
            105 hóa đơn "Hủy"       : khoảng 7%
       - Khoảng 5.200 dòng ChiTietHoaDon (mỗi hóa đơn 1–6 món, ngẫu nhiên)
       - 5 hóa đơn rỗng (không có chi tiết), nằm ở cuối nhóm hóa đơn đã đóng
       - TongTien của mọi hóa đơn được tính bằng một câu UPDATE ... LEFT JOIN

   ĐÃ SỬA SO VỚI BẢN CŨ (chi tiết xem NhatKy_AI.md)
       1. LỖI CHỌN NGẪU NHIÊN: bản cũ dùng
              WHERE Id = 1 + ABS(CHECKSUM(NEWID())) % @SoNV
          NEWID() trong WHERE được tính lại cho TỪNG DÒNG, nên mỗi dòng so với
          một số ngẫu nhiên khác nhau → có thể không dòng nào khớp, biến giữ
          NULL ở lần đầu và script chết với lỗi "Cannot insert NULL".
          Cách sửa: tính chỉ số ngẫu nhiên ra biến trước, rồi mới WHERE Id = @ChiSo.
       2. BỎ công thức @MinMon/@MaxMon chỉ để ép tổng chi tiết đúng 5.000:
          phức tạp, khó giải thích khi vấn đáp, và làm lệch các hóa đơn ở cuối
          vòng lặp (bị ép còn 1 món). Đề chỉ yêu cầu ≥ 1.000 dòng.
          Thay bằng: mỗi hóa đơn 1–6 món, ngẫu nhiên đều.
       3. Thêm BƯỚC 5 minh họa INSERT / UPDATE / DELETE (Readme mục 3.2).
       4. Thêm chặn chạy lại (THROW 50012) và các kiểm tra bất biến (THROW 50013/50014).

   NGUYÊN TẮC
       - Dữ liệu hư cấu 100%, không dùng thông tin người thật.
       - KHÔNG sửa NguyenLieu.TonKho → giữ nguyên các dòng biên do 03a tạo.
       - Toàn bộ phần nạp dữ liệu nằm trong MỘT transaction: lỗi ở bất kỳ đâu
         thì rollback sạch, không để lại dữ liệu dở dang.
   ===================================================================== */

USE QL_CAFE_NHAHANG;
GO

SET NOCOUNT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* =================================================================
       BƯỚC 0. KIỂM TRA TIỀN ĐỀ + CHẶN CHẠY LẠI
       ================================================================= */

    IF NOT EXISTS (SELECT 1 FROM dbo.Ban)
        THROW 50001, N'Bảng Ban chưa có dữ liệu. Hãy chạy 03_DuLieu.sql (Phần 1) trước.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.NhanVien WHERE ChucVu = N'PhucVu')
        THROW 50002, N'Không có nhân viên có ChucVu = PhucVu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Mon WHERE DangBan = 1)
        THROW 50003, N'Không có món nào có DangBan = 1.', 1;

    /*
       Bảng HoaDon dùng IDENTITY(MaHD) nên chạy lại script này sẽ sinh THÊM
       1.500 hóa đơn mới chứ không báo trùng. Chặn ngay từ đầu để tránh
       tình trạng mỗi bàn "Có khách" có 2 hóa đơn Mở (sai nghiệp vụ).
    */
    IF EXISTS (SELECT 1 FROM dbo.HoaDon)
        THROW 50012, N'Bảng HoaDon đã có dữ liệu: script này không tự xóa và không chống trùng. Hãy reset (03_RESET_DB.sql → 02_Bang.sql → 03_DuLieu.sql (Phần 1)) rồi nạp lại.', 1;

    DECLARE @TongHD INT = 1500;          -- Tổng số hóa đơn cần sinh
    DECLARE @SoHDTrong INT = 5;          -- Số hóa đơn rỗng (không có chi tiết)

    /* ---- Danh sách bàn ---- */
    DECLARE @DSBan TABLE
    (
        Id    INT IDENTITY(1, 1) PRIMARY KEY,
        MaBan INT NOT NULL
    );

    INSERT INTO @DSBan (MaBan)
    SELECT MaBan FROM dbo.Ban;

    DECLARE @SoBan INT;
    SET @SoBan = @@ROWCOUNT;

    IF @SoBan = 0
        THROW 50004, N'Bảng Ban không có bản ghi nào.', 1;

    /* ---- Bàn đang có khách: mỗi bàn đúng 1 hóa đơn Mở ---- */
    DECLARE @DSBanMo TABLE
    (
        Id    INT IDENTITY(1, 1) PRIMARY KEY,
        MaBan INT NOT NULL
    );

    INSERT INTO @DSBanMo (MaBan)
    SELECT MaBan FROM dbo.Ban WHERE TrangThai = N'Có khách';

    DECLARE @SoBanMo INT;
    SET @SoBanMo = @@ROWCOUNT;

    /* ---- Nhân viên phục vụ (người lập hóa đơn) ---- */
    DECLARE @DSNV TABLE
    (
        Id   INT IDENTITY(1, 1) PRIMARY KEY,
        MaNV INT NOT NULL
    );

    INSERT INTO @DSNV (MaNV)
    SELECT MaNV FROM dbo.NhanVien WHERE ChucVu = N'PhucVu';

    DECLARE @SoNV INT;
    SET @SoNV = @@ROWCOUNT;

    IF @SoNV = 0
        THROW 50005, N'Không có nhân viên phục vụ.', 1;

    /*
       ---- Món được phép bán ----
       DangBan = 1 và loại 2 món cuối (MaMon 35, 36) để hai món này KHÔNG BAO GIỜ
       phát sinh giao dịch → phục vụ truy vấn "món chưa bán được lần nào".
    */
    DECLARE @MonHopLe TABLE
    (
        MaMon INT PRIMARY KEY,
        GiaBan DECIMAL(12, 0) NOT NULL
    );

    INSERT INTO @MonHopLe (MaMon, GiaBan)
    SELECT MaMon, GiaBan
    FROM dbo.Mon
    WHERE DangBan = 1
      AND MaMon NOT IN
      (
          SELECT TOP (2) MaMon
          FROM dbo.Mon
          ORDER BY MaMon DESC
      );

    DECLARE @SoMonHopLe INT;
    SET @SoMonHopLe = (SELECT COUNT(*) FROM @MonHopLe);

    IF @SoMonHopLe = 0
        THROW 50006, N'Không còn món hợp lệ sau khi loại 2 món cuối.', 1;

    -- Mỗi hóa đơn 1–6 món, nhưng không vượt quá số món hợp lệ đang có
    DECLARE @SoMonToiDa INT =
        CASE WHEN @SoMonHopLe >= 6 THEN 6 ELSE @SoMonHopLe END;

    /* ---- Ảnh chụp tồn kho để cuối script chứng minh phần giao dịch không sửa tồn kho ---- */
    DECLARE @TonKhoTruoc TABLE
    (
        MaNL       INT PRIMARY KEY,
        TonKho     DECIMAL(12, 2) NOT NULL,
        DinhMucTon DECIMAL(12, 2) NOT NULL,
        DonGiaNhap DECIMAL(12, 2) NOT NULL
    );

    INSERT INTO @TonKhoTruoc (MaNL, TonKho, DinhMucTon, DonGiaNhap)
    SELECT MaNL, TonKho, DinhMucTon, DonGiaNhap FROM dbo.NguyenLieu;

    /* =================================================================
       BƯỚC 1. XÁC ĐỊNH SỐ HÓA ĐƠN THEO TRẠNG THÁI
       ================================================================= */

    DECLARE @SoHDDong INT;
    SET @SoHDDong = @TongHD - @SoBanMo;          -- số hóa đơn đã đóng (Đã TT + Hủy)

    IF @SoBanMo > @SoHDDong
        THROW 50008, N'Số bàn đang có khách quá lớn so với số hóa đơn cần sinh.', 1;

    -- Khoảng 7% hóa đơn bị hủy
    DECLARE @SoHDHuy INT;
    SET @SoHDHuy = CAST(ROUND(@TongHD * 0.07, 0) AS INT);

    IF @SoHDHuy > @SoHDDong
        SET @SoHDHuy = @SoHDDong;

    DECLARE @SoHDDaTT INT;
    SET @SoHDDaTT = @SoHDDong - @SoHDHuy;        -- phần còn lại đã thanh toán

    /* =================================================================
       BƯỚC 2. HÓA ĐƠN "MỞ" CHO CÁC BÀN ĐANG CÓ KHÁCH
       ================================================================= */

    DECLARE @i INT;
    DECLARE @j INT;
    DECLARE @ChiSo INT;
    DECLARE @MaHD INT;
    DECLARE @MaBan INT;
    DECLARE @MaNV INT;
    DECLARE @MaMon INT;
    DECLARE @DonGia DECIMAL(12, 0);
    DECLARE @SoMon INT;
    DECLARE @NgayLap DATETIME;
    DECLARE @NgayOffset INT;
    DECLARE @Phut INT;
    DECLARE @R INT;
    DECLARE @TrangThai NVARCHAR(30);

    SET @i = 1;

    WHILE @i <= @SoBanMo
    BEGIN
        -- Bàn đang có khách thứ i
        SELECT @MaBan = MaBan
        FROM @DSBanMo
        WHERE Id = @i;

        /*
           LẤY NGẪU NHIÊN ĐÚNG CÁCH:
           tính chỉ số ra biến TRƯỚC, rồi mới so sánh với Id.
           (Bản cũ đặt CHECKSUM(NEWID()) ngay trong WHERE → mỗi dòng một số khác
            nhau, có thể không dòng nào khớp và @MaNV bị NULL.)
           CHECKSUM trả về INT nên phải CAST sang BIGINT trước khi ABS, tránh
           trường hợp ABS(INT_MIN) gây lỗi tràn số.
        */
        SET @ChiSo = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoNV AS INT);

        SELECT @MaNV = MaNV
        FROM @DSNV
        WHERE Id = @ChiSo;

        -- Hóa đơn Mở lập trong ngày hôm nay, TongTien tạm 0 (tính lại ở BƯỚC 4)
        SET @NgayLap = GETDATE();
        SET @TrangThai = N'Mở';

        INSERT INTO dbo.HoaDon (MaBan, MaNV, NgayLap, TrangThai, TongTien)
        VALUES (@MaBan, @MaNV, @NgayLap, @TrangThai, 0);

        SET @MaHD = CAST(SCOPE_IDENTITY() AS INT);

        -- Số món của hóa đơn: 1–6
        SET @SoMon = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoMonToiDa AS INT);
        SET @j = 1;

        WHILE @j <= @SoMon
        BEGIN
            /*
               Chọn ngẫu nhiên một món CHƯA có trong hóa đơn này.
               ORDER BY NEWID() ở đây là ĐÚNG (khác với @ChiSo ở trên): NEWID()
               nằm ở ORDER BY nên mỗi dòng được gán một khóa sắp xếp riêng,
               TOP (1) lấy ra đúng một dòng bất kỳ.
            */
            SELECT TOP (1)
                @MaMon = m.MaMon,
                @DonGia = m.GiaBan
            FROM @MonHopLe AS m
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM dbo.ChiTietHoaDon AS ct
                WHERE ct.MaHD = @MaHD
                  AND ct.MaMon = m.MaMon
            )
            ORDER BY NEWID();

            IF @@ROWCOUNT = 0
                THROW 50009, N'Không đủ món khác nhau cho một hóa đơn.', 1;

            -- Hóa đơn đang Mở: trạng thái chế biến lẫn "Chờ" và "Đang làm"
            INSERT INTO dbo.ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
            VALUES
            (
                @MaHD,
                @MaMon,
                1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 4 AS INT),
                @DonGia,
                CASE WHEN @j % 2 = 1 THEN N'Chờ' ELSE N'Đang làm' END
            );

            SET @j = @j + 1;
        END;

        SET @i = @i + 1;
    END;

    /* =================================================================
       BƯỚC 3. HÓA ĐƠN "ĐÃ THANH TOÁN" / "HỦY" TRONG 90 NGÀY GẦN NHẤT
       ================================================================= */

    SET @i = 1;

    WHILE @i <= @SoHDDong
    BEGIN
        -- Bàn ngẫu nhiên (cùng cách sửa lỗi như BƯỚC 2)
        SET @ChiSo = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoBan AS INT);
        SELECT @MaBan = MaBan FROM @DSBan WHERE Id = @ChiSo;

        -- Nhân viên phục vụ ngẫu nhiên
        SET @ChiSo = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoNV AS INT);
        SELECT @MaNV = MaNV FROM @DSNV WHERE Id = @ChiSo;

        -- Ngày lập: 0–89 ngày trước
        SET @NgayOffset = CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 90 AS INT);

        /*
           70% hóa đơn rơi vào giờ cao điểm (11h–12h59, 17h–19h59),
           30% còn lại rải đều 7h00–21h59.
        */
        SET @R = CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 100 AS INT);

        IF @R < 70
        BEGIN
            IF CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 2 AS INT) = 0
                SET @Phut = 11 * 60 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 120 AS INT);
            ELSE
                SET @Phut = 17 * 60 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 180 AS INT);
        END
        ELSE
        BEGIN
            SET @Phut = 7 * 60 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 900 AS INT);
        END;

        SET @NgayLap =
            DATEADD
            (
                MINUTE,
                @Phut,
                DATEADD(DAY, -@NgayOffset, CAST(CAST(GETDATE() AS DATE) AS DATETIME))
            );

        -- Không để hóa đơn đã đóng có thời điểm ở tương lai
        IF @NgayLap > GETDATE()
            SET @NgayLap = DATEADD(DAY, -1, @NgayLap);

        -- @SoHDDaTT hóa đơn đầu tiên: đã thanh toán; phần còn lại: hủy
        IF @i <= @SoHDDaTT
            SET @TrangThai = N'Đã thanh toán';
        ELSE
            SET @TrangThai = N'Hủy';

        INSERT INTO dbo.HoaDon (MaBan, MaNV, NgayLap, TrangThai, TongTien)
        VALUES (@MaBan, @MaNV, @NgayLap, @TrangThai, 0);

        SET @MaHD = CAST(SCOPE_IDENTITY() AS INT);

        /*
           5 hóa đơn CUỐI của nhóm đã đóng là hóa đơn rỗng (cố ý, để có dòng biên
           "hóa đơn không có chi tiết"). Các hóa đơn còn lại: 1–6 món.
        */
        IF @i <= @SoHDDong - @SoHDTrong
        BEGIN
            SET @SoMon = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoMonToiDa AS INT);
            SET @j = 1;

            WHILE @j <= @SoMon
            BEGIN
                SELECT TOP (1)
                    @MaMon = m.MaMon,
                    @DonGia = m.GiaBan
                FROM @MonHopLe AS m
                WHERE NOT EXISTS
                (
                    SELECT 1
                    FROM dbo.ChiTietHoaDon AS ct
                    WHERE ct.MaHD = @MaHD
                      AND ct.MaMon = m.MaMon
                )
                ORDER BY NEWID();

                IF @@ROWCOUNT = 0
                    THROW 50010, N'Không đủ món khác nhau cho một hóa đơn.', 1;

                -- Hóa đơn đã đóng: mọi chi tiết đều "Xong"
                INSERT INTO dbo.ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
                VALUES
                (
                    @MaHD,
                    @MaMon,
                    1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 4 AS INT),
                    @DonGia,
                    N'Xong'
                );

                SET @j = @j + 1;
            END;
        END;

        SET @i = @i + 1;
    END;

    /* =================================================================
       BƯỚC 4. TÍNH TongTien BẰNG MỘT CÂU UPDATE ... LEFT JOIN
       ================================================================= */

    UPDATE h
    SET TongTien = CAST(ISNULL(t.TongChiTiet, 0) AS DECIMAL(14, 0))
    FROM dbo.HoaDon AS h
    LEFT JOIN
    (
        SELECT
            MaHD,
            SUM(SoLuong * DonGia) AS TongChiTiet
        FROM dbo.ChiTietHoaDon
        GROUP BY MaHD
    ) AS t
        ON t.MaHD = h.MaHD;

    /* =================================================================
       BƯỚC 5. KIỂM TRA BẤT BIẾN NGAY TRONG TRANSACTION
       (sai thì rollback toàn bộ, không để dữ liệu nửa vời)
       ================================================================= */

    DECLARE @SoHDRongThucTe INT =
    (
        SELECT COUNT(*)
        FROM dbo.HoaDon AS h
        WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = h.MaHD)
    );

    IF @SoHDRongThucTe <> @SoHDTrong
        THROW 50013, N'Số hóa đơn rỗng không đúng cam kết (phải bằng 5).', 1;

    -- Mỗi bàn "Có khách" phải có đúng 1 hóa đơn Mở; bàn khác phải có 0
    IF EXISTS
    (
        SELECT 1
        FROM dbo.Ban AS b
        LEFT JOIN dbo.HoaDon AS h
            ON h.MaBan = b.MaBan
           AND h.TrangThai = N'Mở'
        GROUP BY b.MaBan, b.TrangThai
        HAVING SUM(CASE WHEN h.MaHD IS NOT NULL THEN 1 ELSE 0 END)
             <> CASE WHEN b.TrangThai = N'Có khách' THEN 1 ELSE 0 END
    )
        THROW 50014, N'Bất biến "mỗi bàn có khách đúng 1 hóa đơn Mở" bị vi phạm.', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;      -- ném lại đúng lỗi gốc để người chạy biết script đã hỏng
END CATCH;

/* =====================================================================
   BƯỚC 6. MINH HỌA INSERT / UPDATE / DELETE  (Readme mục 3.2)
   ---------------------------------------------------------------------
   Mỗi nhóm thao tác chạy trong transaction riêng và kết thúc ở trạng thái
   KHÔNG đổi dữ liệu, để bộ dữ liệu mẫu vẫn tái lập được:
     6.1  INSERT + UPDATE + DELETE trên Mon / MonAn (xóa con trước, cha sau)
     6.2  INSERT + UPDATE trên HoaDon / ChiTietHoaDon (nhiều bảng)
     6.3  DELETE rồi ROLLBACK — minh họa cách hủy thay đổi
   ===================================================================== */

DECLARE @MaLoaiDemo INT;
DECLARE @MaMonDemo INT;
DECLARE @MaHDDemo INT;
DECLARE @MonDemo1 INT;
DECLARE @MonDemo2 INT;

/* ---- 6.1. INSERT / UPDATE / DELETE trên bảng món ---- */
BEGIN TRY
    BEGIN TRANSACTION;

    SELECT TOP (1) @MaLoaiDemo = MaLoai
    FROM dbo.LoaiMon
    WHERE MaLoaiCha IS NOT NULL
    ORDER BY MaLoai;

    IF @MaLoaiDemo IS NULL
        THROW 50021, N'Không tìm được loại món để minh họa DML.', 1;

    -- INSERT: thêm 1 món ăn mới (kèm dòng chuyên biệt hóa trong MonAn)
    INSERT INTO dbo.Mon (TenMon, MaLoai, GiaBan, Nhom, DangBan)
    VALUES (N'Món minh họa DML (sẽ xóa)', @MaLoaiDemo, 49000, 'A', 0);

    SET @MaMonDemo = CAST(SCOPE_IDENTITY() AS INT);

    INSERT INTO dbo.MonAn (MaMon, ThoiGianCheBien, CayHayKhong)
    VALUES (@MaMonDemo, 10, 0);

    -- UPDATE: tăng giá món vừa thêm
    UPDATE dbo.Mon
    SET GiaBan = GiaBan + 5000
    WHERE MaMon = @MaMonDemo;

    SELECT N'6.1 — sau INSERT + UPDATE' AS Buoc,
           m.MaMon, m.TenMon, m.GiaBan, a.ThoiGianCheBien
    FROM dbo.Mon AS m
    JOIN dbo.MonAn AS a ON a.MaMon = m.MaMon
    WHERE m.MaMon = @MaMonDemo;

    -- DELETE: phải xóa bảng con (MonAn) trước bảng cha (Mon), nếu không sẽ lỗi FK
    DELETE FROM dbo.MonAn WHERE MaMon = @MaMonDemo;
    DELETE FROM dbo.Mon   WHERE MaMon = @MaMonDemo;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

/* ---- 6.2. INSERT / UPDATE trên nhiều bảng: hóa đơn + chi tiết ---- */
BEGIN TRY
    BEGIN TRANSACTION;

    -- Chọn một hóa đơn rỗng có sẵn để không phá bất biến "bàn có khách ↔ 1 hóa đơn Mở"
    SELECT TOP (1) @MaHDDemo = h.MaHD
    FROM dbo.HoaDon AS h
    WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = h.MaHD)
    ORDER BY h.MaHD;

    IF @MaHDDemo IS NULL
        THROW 50022, N'Không còn hóa đơn rỗng để minh họa DML.', 1;

    SELECT TOP (1) @MonDemo1 = MaMon FROM dbo.Mon WHERE DangBan = 1 ORDER BY MaMon;
    SELECT TOP (1) @MonDemo2 = MaMon FROM dbo.Mon WHERE DangBan = 1 AND MaMon <> @MonDemo1 ORDER BY MaMon;

    -- INSERT 2 dòng chi tiết
    INSERT INTO dbo.ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
    SELECT @MaHDDemo, MaMon, 2, GiaBan, N'Chờ'
    FROM dbo.Mon
    WHERE MaMon IN (@MonDemo1, @MonDemo2);

    -- UPDATE: tính lại TongTien cho đúng hóa đơn vừa thêm chi tiết
    UPDATE h
    SET TongTien = CAST(ISNULL(t.TongChiTiet, 0) AS DECIMAL(14, 0))
    FROM dbo.HoaDon AS h
    LEFT JOIN
    (
        SELECT MaHD, SUM(SoLuong * DonGia) AS TongChiTiet
        FROM dbo.ChiTietHoaDon
        GROUP BY MaHD
    ) AS t
        ON t.MaHD = h.MaHD
    WHERE h.MaHD = @MaHDDemo;

    UPDATE dbo.ChiTietHoaDon
    SET TrangThaiCheBien = N'Xong'
    WHERE MaHD = @MaHDDemo;

    SELECT N'6.2 — sau INSERT + UPDATE' AS Buoc,
           h.MaHD, h.TrangThai, h.TongTien,
           (SELECT COUNT(*) FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = @MaHDDemo) AS SoDongChiTiet
    FROM dbo.HoaDon AS h
    WHERE h.MaHD = @MaHDDemo;

    -- Dọn về trạng thái ban đầu: xóa chi tiết rồi đưa TongTien về 0
    DELETE FROM dbo.ChiTietHoaDon WHERE MaHD = @MaHDDemo;
    UPDATE dbo.HoaDon SET TongTien = 0 WHERE MaHD = @MaHDDemo;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

/* ---- 6.3. DELETE một hóa đơn rỗng rồi ROLLBACK (minh họa hủy thay đổi) ---- */
BEGIN TRY
    BEGIN TRANSACTION;

    SELECT TOP (1) @MaHDDemo = h.MaHD
    FROM dbo.HoaDon AS h
    WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = h.MaHD)
    ORDER BY h.MaHD;

    DELETE FROM dbo.HoaDon WHERE MaHD = @MaHDDemo;

    SELECT N'6.3 — trong transaction (chưa rollback)' AS Buoc,
           (SELECT COUNT(*) FROM dbo.HoaDon) AS SoHoaDon;

    -- Cố ý hủy: đây chỉ là minh họa nên không để dữ liệu thay đổi
    ROLLBACK TRANSACTION;

    SELECT N'6.3 — sau ROLLBACK' AS Buoc,
           (SELECT COUNT(*) FROM dbo.HoaDon) AS SoHoaDon;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

/* =====================================================================
   BƯỚC 7. CÁC TRUY VẤN KIỂM TRA
   ===================================================================== */

-- 7.1 Số dòng từng bảng
SELECT N'Ban' AS Bang, COUNT(*) AS SoDong FROM dbo.Ban
UNION ALL SELECT N'NhanVien',       COUNT(*) FROM dbo.NhanVien
UNION ALL SELECT N'NguyenLieu',     COUNT(*) FROM dbo.NguyenLieu
UNION ALL SELECT N'Mon',            COUNT(*) FROM dbo.Mon
UNION ALL SELECT N'MonAn',          COUNT(*) FROM dbo.MonAn
UNION ALL SELECT N'ThucUong',       COUNT(*) FROM dbo.ThucUong
UNION ALL SELECT N'DinhLuong',      COUNT(*) FROM dbo.DinhLuong
UNION ALL SELECT N'HoaDon',         COUNT(*) FROM dbo.HoaDon
UNION ALL SELECT N'ChiTietHoaDon',  COUNT(*) FROM dbo.ChiTietHoaDon;

-- 7.2 Số hóa đơn theo trạng thái
SELECT TrangThai, COUNT(*) AS SoHoaDon
FROM dbo.HoaDon
GROUP BY TrangThai
ORDER BY TrangThai;

-- 7.3 Số hóa đơn rỗng (phải bằng 5)
SELECT COUNT(*) AS SoHoaDonRong
FROM dbo.HoaDon AS h
WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = h.MaHD);

-- 7.4 Mỗi bàn có khách phải có đúng 1 hóa đơn Mở (kết quả phải RỖNG)
SELECT b.MaBan, b.TrangThai, COUNT(h.MaHD) AS SoHoaDonMo
FROM dbo.Ban AS b
LEFT JOIN dbo.HoaDon AS h
    ON h.MaBan = b.MaBan
   AND h.TrangThai = N'Mở'
GROUP BY b.MaBan, b.TrangThai
HAVING (b.TrangThai = N'Có khách' AND COUNT(h.MaHD) <> 1)
    OR (b.TrangThai <> N'Có khách' AND COUNT(h.MaHD) <> 0);

-- 7.5 Hóa đơn có TongTien lệch tổng chi tiết (kết quả phải RỖNG)
SELECT h.MaHD, h.TongTien, ISNULL(SUM(ct.SoLuong * ct.DonGia), 0) AS TongChiTiet
FROM dbo.HoaDon AS h
LEFT JOIN dbo.ChiTietHoaDon AS ct ON ct.MaHD = h.MaHD
GROUP BY h.MaHD, h.TongTien
HAVING h.TongTien <> ISNULL(SUM(ct.SoLuong * ct.DonGia), 0);

-- 7.6 Trùng khóa (MaHD, MaMon) — khóa chính đã chặn, kiểm tra cho chắc (phải RỖNG)
SELECT MaHD, MaMon, COUNT(*) AS SoLan
FROM dbo.ChiTietHoaDon
GROUP BY MaHD, MaMon
HAVING COUNT(*) > 1;

-- 7.7 Tồn kho KHÔNG bị thay đổi bởi phần giao dịch (phải bằng 0)
SELECT COUNT(*) AS SoNguyenLieuBiLech
FROM dbo.NguyenLieu AS nl
JOIN @TonKhoTruoc AS t ON t.MaNL = nl.MaNL
WHERE nl.TonKho <> t.TonKho
   OR nl.DinhMucTon <> t.DinhMucTon
   OR nl.DonGiaNhap <> t.DonGiaNhap;

-- 7.8 Các dòng biên tồn kho vẫn còn nguyên
SELECT
    SUM(CASE WHEN TonKho = 0 THEN 1 ELSE 0 END)                         AS TonKho_Bang0,
    SUM(CASE WHEN TonKho = DinhMucTon THEN 1 ELSE 0 END)                AS TonKho_BangDinhMuc,
    SUM(CASE WHEN TonKho > 0 AND TonKho < DinhMucTon THEN 1 ELSE 0 END) AS TonKho_DuoiDinhMuc,
    SUM(CASE WHEN TonKho > DinhMucTon THEN 1 ELSE 0 END)                AS TonKho_TrenDinhMuc
FROM dbo.NguyenLieu;

-- 7.9 Món chưa bán được lần nào (dòng biên cho truy vấn "món chưa phát sinh giao dịch")
SELECT m.MaMon, m.TenMon, m.DangBan
FROM dbo.Mon AS m
WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaMon = m.MaMon)
ORDER BY m.MaMon;


PRINT N'';
PRINT N'=== HOÀN TẤT NẠP TOÀN BỘ DỮ LIỆU MẪU (03_DuLieu.sql) ===';
GO
