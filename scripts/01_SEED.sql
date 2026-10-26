/* =====================================================================
   CSDL QUẢN LÝ NHÀ HÀNG / QUÁN CÀ PHÊ - SCRIPT NẠP DỮ LIỆU GIẢ LẬP
   ---------------------------------------------------------------------
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