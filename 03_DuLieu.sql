-- 03_DuLieu.sql: Nạp dữ liệu mẫu danh mục và 1.500 hóa đơn giao dịch.
USE QL_CAFE_NHAHANG;
GO

SET NOCOUNT ON;
GO

PRINT N'======================================================';
PRINT N'=== PHẦN 1: NẠP DỮ LIỆU DANH MỤC (03a)            ===';
PRINT N'======================================================';
GO

Use QL_CAFE_NHAHANG;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO LoaiMon (TenLoai, MaLoaiCha) VALUES
        (N'Món ăn',          NULL),
        (N'Cà phê Việt',     NULL),
        (N'Cà phê pha máy',  NULL),
        (N'Trà',             NULL),
        (N'Trà sữa',         NULL),
        (N'Sinh tố',         NULL),
        (N'Nước ép',         NULL),
        (N'Đá xay',          NULL);

    INSERT INTO LoaiMon (TenLoai, MaLoaiCha) VALUES
        (N'Khai vị',          1),
        (N'Món chính',        1),
        (N'Tráng miệng',      1);

    INSERT INTO Ban (TenBan, SucChua, TrangThai) VALUES
        (N'Bàn 01',  4, N'Có khách'),
        (N'Bàn 02',  4, N'Có khách'),
        (N'Bàn 03',  2, N'Có khách'),
        (N'Bàn 04',  6, N'Có khách'),
        (N'Bàn 05',  8, N'Có khách'),
        (N'Bàn 06',  4, N'Đã đặt'),
        (N'Bàn 07',  6, N'Đã đặt'),
        (N'Bàn 08', 10, N'Đã đặt'),
        (N'Bàn 09',  2, N'Trống'),
        (N'Bàn 10',  4, N'Trống'),
        (N'Bàn 11',  4, N'Trống'),
        (N'Bàn 12',  6, N'Trống'),
        (N'Bàn 13',  8, N'Trống'),
        (N'Bàn 14', 10, N'Trống'),
        (N'Bàn 15', 12, N'Trống');

    INSERT INTO NhanVien (HoTen, ChucVu, SoDienThoai, NgayVaoLam) VALUES
        (N'Nguyễn Văn An',     N'QuanLy',  '0901234501', '2019-03-01'),
        (N'Trần Thị Bích',     N'QuanLy',  '0901234502', '2020-07-15'),
        (N'Lê Hoàng Cường',    N'Bep',     '0901234503', '2021-01-10'),
        (N'Phạm Minh Dũng',    N'Bep',     '0901234504', '2021-05-20'),
        (N'Hoàng Thị Em',      N'Bep',     '0901234505', '2022-02-14'),
        (N'Vũ Văn Hùng',       N'PhucVu',  '0901234506', '2022-06-01'),
        (N'Đặng Thị Hoa',      N'PhucVu',  '0901234507', '2022-09-12'),
        (N'Bùi Minh Khang',    N'PhucVu',  '0901234508', '2023-01-05'),
        (N'Ngô Thị Lan',       N'PhucVu',  '0901234509', '2023-04-18'),
        (N'Đỗ Văn Nam',        N'ThuNgan', '0901234510', '2023-08-22'),
        (N'Trịnh Thị Oanh',    N'ThuNgan', '0901234511', '2024-01-08'),
        (N'Lý Văn Phúc',       N'ThuNgan', '0901234512', '2024-03-25');

    INSERT INTO NguyenLieu (TenNL, DonViTinh, TonKho, DinhMucTon, DonGiaNhap) VALUES
        (N'Gạo tẻ',            N'kg',   120.00,  50.00,  20000.00),
        (N'Bánh phở tươi',     N'kg',     4.00,  10.00,  25000.00),
        (N'Bánh tráng',        N'cái',  800.00, 300.00,   1200.00),
        (N'Thịt bò',           N'kg',     0.00,  15.00, 290000.00),
        (N'Thịt heo',          N'kg',    22.00,  12.00, 150000.00),
        (N'Ức gà',             N'kg',    18.00,  10.00, 110000.00),
        (N'Tôm tươi',          N'kg',     2.50,   8.00, 270000.00),
        (N'Trứng gà',          N'quả',  180.00, 180.00,   3500.00),
        (N'Khoai tây',         N'kg',    40.00,  15.00,  28000.00),
        (N'Hành tím',          N'kg',    12.00,   5.00,  32000.00),
        (N'Tỏi',               N'kg',     9.00,   4.00,  45000.00),
        (N'Bơ lạt',            N'kg',     1.20,   4.00, 260000.00),
        (N'Nước mắm',          N'lít',   20.00,   8.00,  65000.00),
        (N'Đường trắng',       N'kg',    35.00,  15.00,  24000.00),
        (N'Dầu ăn',            N'lít',   25.00,  10.00,  55000.00),
        (N'Nước cốt dừa',      N'lít',   12.00,   5.00,  40000.00),
        (N'Chuối sứ',          N'kg',    15.00,   6.00,  22000.00),
        (N'Cà phê Robusta',    N'kg',    30.00,  12.00, 220000.00),
        (N'Cà phê Arabica',    N'kg',     8.00,   5.00, 340000.00),
        (N'Sữa đặc',           N'lon',   96.00,  96.00,  28000.00),
        (N'Sữa tươi',          N'lít',   60.00,  25.00,  35000.00),
        (N'Kem sữa',           N'hộp',    0.00,   6.00,  95000.00),
        (N'Trà đen',           N'kg',    14.00,   5.00, 180000.00),
        (N'Bột matcha',        N'kg',     4.00,   2.00, 480000.00),
        (N'Đá viên',           N'kg',   150.00,  50.00,   6000.00),
        (N'Chanh',             N'kg',     1.50,   4.00,  26000.00),
        (N'Cam',               N'kg',    18.00,   8.00,  32000.00),
        (N'Xoài cát',          N'kg',    12.00,   5.00,  55000.00);

    INSERT INTO Mon (TenMon, MaLoai, GiaBan, Nhom, DangBan) VALUES

        (N'Gỏi cuốn tôm thịt',          9,   59000, 'A', 1),
        (N'Chả giò rế',                 9,   65000, 'A', 1),
        (N'Khoai tây chiên tỏi',        9,   45000, 'A', 1),
        (N'Gà chiên nước mắm',          9,   89000, 'A', 1),
        (N'Tôm chiên giòn',             9,   95000, 'A', 0),
        (N'Cơm gà Hải Nam',            10,   79000, 'A', 1),
        (N'Cơm chiên dương châu',      10,   69000, 'A', 1),
        (N'Bò lúc lắc khoai tây',      10,  129000, 'A', 1),
        (N'Phở bò tái',                10,   75000, 'A', 1),
        (N'Cơm tấm sườn nướng',        10,   72000, 'A', 1),
        (N'Gà kho cốt dừa',            10,   98000, 'A', 1),
        (N'Cháo gà',                   10,   55000, 'A', 1),
        (N'Tôm kho tàu',               10,   99000, 'A', 1),
        (N'Bò xào tỏi',                10,  119000, 'A', 1),
        (N'Bánh flan',                 11,   29000, 'A', 1),
        (N'Kem dừa',                   11,   35000, 'A', 1),
        (N'Chè chuối',                 11,   25000, 'A', 1),
        (N'Chuối chiên',               11,   27000, 'A', 1),

        (N'Cà phê đen đá',              2,   35000, 'U', 1),
        (N'Cà phê sữa đá',              2,   39000, 'U', 1),
        (N'Bạc xỉu',                    2,   42000, 'U', 1),
        (N'Cà phê muối',                2,   45000, 'U', 0),
        (N'Cà phê cốt dừa',             2,   45000, 'U', 1),
        (N'Latte nóng',                 3,   59000, 'U', 1),
        (N'Trà đen chanh',              4,   35000, 'U', 1),
        (N'Trà sữa truyền thống',       5,   45000, 'U', 1),
        (N'Trà sữa cốt dừa',            5,   47000, 'U', 1),
        (N'Trà đá',                     4,   15000, 'U', 1),
        (N'Sinh tố xoài',               6,   49000, 'U', 1),
        (N'Sinh tố chuối',              6,   45000, 'U', 1),
        (N'Sinh tố cốt dừa',            6,   45000, 'U', 1),
        (N'Nước ép cam',                7,   40000, 'U', 1),
        (N'Nước chanh',                 7,   30000, 'U', 1),
        (N'Cà phê đá xay',              8,   55000, 'U', 1),
        (N'Trà sữa nóng',               5,   45000, 'U', 1),
        (N'Cà phê sữa nóng',            2,   39000, 'U', 1);

    INSERT INTO MonAn (MaMon, ThoiGianCheBien, CayHayKhong) VALUES
        ( 1, 10, 0),
        ( 2, 15, 0),
        ( 3, 12, 0),
        ( 4, 20, 0),
        ( 5, 15, 0),
        ( 6, 30, 0),
        ( 7, 18, 0),
        ( 8, 25, 0),
        ( 9, 20, 1),
        (10, 30, 0),
        (11, 35, 1),
        (12, 25, 0),
        (13, 30, 0),
        (14, 15, 0),
        (15, 45, 0),
        (16, 40, 0),
        (17, 35, 0),
        (18, 15, 0);

    INSERT INTO ThucUong (MaMon, Size, CoDa, CoDuong) VALUES
        (19, 'S', 1, 1),
        (20, 'M', 1, 1),
        (21, 'M', 1, 1),
        (22, 'M', 0, 1),
        (23, 'M', 1, 1),
        (24, 'M', 0, 1),
        (25, 'L', 1, 1),
        (26, 'M', 1, 1),
        (27, 'M', 1, 1),
        (28, 'L', 1, 1),
        (29, 'L', 1, 1),
        (30, 'L', 1, 1),
        (31, 'L', 1, 1),
        (32, 'L', 1, 1),
        (33, 'L', 1, 1),
        (34, 'L', 1, 1),
        (35, 'M', 0, 1),
        (36, 'M', 0, 1);

    INSERT INTO DinhLuong (MaMon, MaNL, SoLuong) VALUES

        (1, 3, 3.00), (1, 7, 0.06), (1, 5, 0.05), (1, 10, 0.01),

        (2, 3, 4.00), (2, 5, 0.08), (2, 8, 1.00), (2, 15, 0.03),

        (3, 9, 0.15), (3, 11, 0.01), (3, 15, 0.05),

        (4, 6, 0.20), (4, 13, 0.02), (4, 11, 0.01), (4, 15, 0.05),

        (5, 7, 0.10), (5, 15, 0.05), (5, 11, 0.01),

        (6, 1, 0.15), (6, 6, 0.15), (6, 10, 0.01), (6, 13, 0.015),

        (7, 1, 0.15), (7, 8, 1.00), (7, 7, 0.05), (7, 15, 0.03),

        (8, 4, 0.15), (8, 9, 0.10), (8, 12, 0.02), (8, 13, 0.015),

        (9, 2, 0.20), (9, 4, 0.10), (9, 10, 0.02), (9, 13, 0.02),

        (10, 1, 0.15), (10, 5, 0.15), (10, 13, 0.02), (10, 11, 0.01),

        (11, 6, 0.20), (11, 16, 0.10), (11, 13, 0.02), (11, 14, 0.01),

        (12, 1, 0.08), (12, 6, 0.10), (12, 10, 0.01), (12, 13, 0.01),

        (13, 7, 0.12), (13, 13, 0.02), (13, 14, 0.01), (13, 10, 0.01),

        (14, 4, 0.12), (14, 11, 0.02), (14, 15, 0.03), (14, 13, 0.01),

        (15, 8, 1.00), (15, 20, 0.30), (15, 21, 0.10), (15, 14, 0.02),

        (16, 16, 0.08), (16, 20, 0.20), (16, 22, 0.05), (16, 14, 0.01),

        (17, 17, 0.12), (17, 16, 0.08), (17, 14, 0.02),

        (18, 17, 0.10), (18, 15, 0.05), (18, 14, 0.01),

        (19, 18, 0.018), (19, 14, 0.01), (19, 25, 0.15),

        (20, 18, 0.018), (20, 20, 0.30), (20, 25, 0.15),

        (21, 18, 0.012), (21, 21, 0.12), (21, 25, 0.12),

        (22, 18, 0.018), (22, 20, 0.25), (22, 22, 0.03),

        (23, 18, 0.018), (23, 16, 0.06), (23, 20, 0.20), (23, 25, 0.15),

        (24, 18, 0.018), (24, 21, 0.15), (24, 22, 0.02),

        (25, 23, 0.008), (25, 26, 0.02), (25, 14, 0.015), (25, 25, 0.20),

        (26, 23, 0.01), (26, 20, 0.25), (26, 21, 0.10), (26, 25, 0.18),

        (27, 23, 0.01), (27, 16, 0.06), (27, 20, 0.20), (27, 25, 0.15),

        (28, 23, 0.006), (28, 14, 0.008), (28, 25, 0.20),

        (29, 28, 0.12), (29, 21, 0.08), (29, 20, 0.20), (29, 25, 0.10),

        (30, 17, 0.10), (30, 21, 0.08), (30, 20, 0.20), (30, 25, 0.10),

        (31, 16, 0.08), (31, 21, 0.08), (31, 14, 0.015), (31, 25, 0.10),

        (32, 27, 0.20), (32, 14, 0.01), (32, 25, 0.10),

        (33, 26, 0.04), (33, 14, 0.025), (33, 25, 0.15),

        (34, 18, 0.015), (34, 20, 0.25), (34, 22, 0.04), (34, 25, 0.18),

        (35, 23, 0.01), (35, 21, 0.12), (35, 14, 0.01),

        (36, 18, 0.02), (36, 20, 0.30), (36, 21, 0.05);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

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

USE QL_CAFE_NHAHANG;
GO

SET NOCOUNT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM dbo.Ban)
        THROW 50001, N'Bảng Ban chưa có dữ liệu. Hãy chạy 03_DuLieu.sql (Phần 1) trước.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.NhanVien WHERE ChucVu = N'PhucVu')
        THROW 50002, N'Không có nhân viên có ChucVu = PhucVu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Mon WHERE DangBan = 1)
        THROW 50003, N'Không có món nào có DangBan = 1.', 1;

    IF EXISTS (SELECT 1 FROM dbo.HoaDon)
        THROW 50012, N'Bảng HoaDon đã có dữ liệu: script này không tự xóa và không chống trùng. Hãy chạy lại 02_Bang.sql (xóa và tạo lại bảng) rồi 03_DuLieu.sql để nạp lại.', 1;

    DECLARE @TongHD INT = 1500;
    DECLARE @SoHDTrong INT = 5;

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

    DECLARE @DSBanMo TABLE
    (
        Id    INT IDENTITY(1, 1) PRIMARY KEY,
        MaBan INT NOT NULL
    );

    INSERT INTO @DSBanMo (MaBan)
    SELECT MaBan FROM dbo.Ban WHERE TrangThai = N'Có khách';

    DECLARE @SoBanMo INT;
    SET @SoBanMo = @@ROWCOUNT;

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

    DECLARE @SoMonToiDa INT =
        CASE WHEN @SoMonHopLe >= 6 THEN 6 ELSE @SoMonHopLe END;

    DECLARE @TonKhoTruoc TABLE
    (
        MaNL       INT PRIMARY KEY,
        TonKho     DECIMAL(12, 2) NOT NULL,
        DinhMucTon DECIMAL(12, 2) NOT NULL,
        DonGiaNhap DECIMAL(12, 2) NOT NULL
    );

    INSERT INTO @TonKhoTruoc (MaNL, TonKho, DinhMucTon, DonGiaNhap)
    SELECT MaNL, TonKho, DinhMucTon, DonGiaNhap FROM dbo.NguyenLieu;

    DECLARE @SoHDDong INT;
    SET @SoHDDong = @TongHD - @SoBanMo;

    IF @SoBanMo > @SoHDDong
        THROW 50008, N'Số bàn đang có khách quá lớn so với số hóa đơn cần sinh.', 1;

    DECLARE @SoHDHuy INT;
    SET @SoHDHuy = CAST(ROUND(@TongHD * 0.07, 0) AS INT);

    IF @SoHDHuy > @SoHDDong
        SET @SoHDHuy = @SoHDDong;

    DECLARE @SoHDDaTT INT;
    SET @SoHDDaTT = @SoHDDong - @SoHDHuy;

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

        SELECT @MaBan = MaBan
        FROM @DSBanMo
        WHERE Id = @i;

        SET @ChiSo = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoNV AS INT);

        SELECT @MaNV = MaNV
        FROM @DSNV
        WHERE Id = @ChiSo;

        SET @NgayLap = GETDATE();
        SET @TrangThai = N'Mở';

        INSERT INTO dbo.HoaDon (MaBan, MaNV, NgayLap, TrangThai, TongTien)
        VALUES (@MaBan, @MaNV, @NgayLap, @TrangThai, 0);

        SET @MaHD = CAST(SCOPE_IDENTITY() AS INT);

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
                THROW 50009, N'Không đủ món khác nhau cho một hóa đơn.', 1;

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

    SET @i = 1;

    WHILE @i <= @SoHDDong
    BEGIN

        SET @ChiSo = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoBan AS INT);
        SELECT @MaBan = MaBan FROM @DSBan WHERE Id = @ChiSo;

        SET @ChiSo = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoNV AS INT);
        SELECT @MaNV = MaNV FROM @DSNV WHERE Id = @ChiSo;

        SET @NgayOffset = CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 90 AS INT);

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

        IF @NgayLap > GETDATE()
            SET @NgayLap = DATEADD(DAY, -1, @NgayLap);

        IF @i <= @SoHDDaTT
            SET @TrangThai = N'Đã thanh toán';
        ELSE
            SET @TrangThai = N'Hủy';

        INSERT INTO dbo.HoaDon (MaBan, MaNV, NgayLap, TrangThai, TongTien)
        VALUES (@MaBan, @MaNV, @NgayLap, @TrangThai, 0);

        SET @MaHD = CAST(SCOPE_IDENTITY() AS INT);

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

    DECLARE @SoHDRongThucTe INT =
    (
        SELECT COUNT(*)
        FROM dbo.HoaDon AS h
        WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = h.MaHD)
    );

    IF @SoHDRongThucTe <> @SoHDTrong
        THROW 50013, N'Số hóa đơn rỗng không đúng cam kết (phải bằng 5).', 1;

    IF EXISTS
    (
        SELECT 1 FROM dbo.Ban AS b
        LEFT JOIN dbo.HoaDon AS h ON h.MaBan = b.MaBan AND h.TrangThai = N'Mở'
        GROUP BY b.MaBan, b.TrangThai
        HAVING SUM(CASE WHEN h.MaHD IS NOT NULL THEN 1 ELSE 0 END)
             <> CASE WHEN b.TrangThai = N'Có khách' THEN 1 ELSE 0 END
    ) THROW 50014, N'Bất biến "mỗi bàn có khách đúng 1 hóa đơn Mở" bị vi phạm.', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;

DECLARE @MaLoaiDemo INT;
DECLARE @MaMonDemo INT;
DECLARE @MaHDDemo INT;
DECLARE @MonDemo1 INT;
DECLARE @MonDemo2 INT;

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT TOP (1) @MaLoaiDemo = MaLoai
    FROM dbo.LoaiMon
    WHERE MaLoaiCha IS NOT NULL
    ORDER BY MaLoai;

    IF @MaLoaiDemo IS NULL
        THROW 50021, N'Không tìm được loại món để minh họa DML.', 1;

    INSERT INTO dbo.Mon (TenMon, MaLoai, GiaBan, Nhom, DangBan)
    VALUES (N'Món minh họa DML (sẽ xóa)', @MaLoaiDemo, 49000, 'A', 0);

    SET @MaMonDemo = CAST(SCOPE_IDENTITY() AS INT);

    INSERT INTO dbo.MonAn (MaMon, ThoiGianCheBien, CayHayKhong)
    VALUES (@MaMonDemo, 10, 0);

    UPDATE dbo.Mon
    SET GiaBan = GiaBan + 5000
    WHERE MaMon = @MaMonDemo;

    SELECT N'6.1 — sau INSERT + UPDATE' AS Buoc,
           m.MaMon, m.TenMon, m.GiaBan, a.ThoiGianCheBien
    FROM dbo.Mon AS m
    JOIN dbo.MonAn AS a ON a.MaMon = m.MaMon
    WHERE m.MaMon = @MaMonDemo;

    DELETE FROM dbo.MonAn WHERE MaMon = @MaMonDemo;
    DELETE FROM dbo.Mon   WHERE MaMon = @MaMonDemo;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT TOP (1) @MaHDDemo = h.MaHD
    FROM dbo.HoaDon AS h
    WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = h.MaHD)
    ORDER BY h.MaHD;

    IF @MaHDDemo IS NULL
        THROW 50022, N'Không còn hóa đơn rỗng để minh họa DML.', 1;

    SELECT TOP (1) @MonDemo1 = MaMon FROM dbo.Mon WHERE DangBan = 1 ORDER BY MaMon;
    SELECT TOP (1) @MonDemo2 = MaMon FROM dbo.Mon WHERE DangBan = 1 AND MaMon <> @MonDemo1 ORDER BY MaMon;

    INSERT INTO dbo.ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
    SELECT @MaHDDemo, MaMon, 2, GiaBan, N'Chờ'
    FROM dbo.Mon
    WHERE MaMon IN (@MonDemo1, @MonDemo2);

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

    DELETE FROM dbo.ChiTietHoaDon WHERE MaHD = @MaHDDemo;
    UPDATE dbo.HoaDon SET TongTien = 0 WHERE MaHD = @MaHDDemo;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT TOP (1) @MaHDDemo = h.MaHD
    FROM dbo.HoaDon AS h
    WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = h.MaHD)
    ORDER BY h.MaHD;

    DELETE FROM dbo.HoaDon WHERE MaHD = @MaHDDemo;

    SELECT N'6.3 — trong transaction (chưa rollback)' AS Buoc,
           (SELECT COUNT(*) FROM dbo.HoaDon) AS SoHoaDon;

    ROLLBACK TRANSACTION;

    SELECT N'6.3 — sau ROLLBACK' AS Buoc,
           (SELECT COUNT(*) FROM dbo.HoaDon) AS SoHoaDon;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT N'Ban' AS Bang, COUNT(*) AS SoDong FROM dbo.Ban
UNION ALL SELECT N'NhanVien',       COUNT(*) FROM dbo.NhanVien
UNION ALL SELECT N'NguyenLieu',     COUNT(*) FROM dbo.NguyenLieu
UNION ALL SELECT N'Mon',            COUNT(*) FROM dbo.Mon
UNION ALL SELECT N'MonAn',          COUNT(*) FROM dbo.MonAn
UNION ALL SELECT N'ThucUong',       COUNT(*) FROM dbo.ThucUong
UNION ALL SELECT N'DinhLuong',      COUNT(*) FROM dbo.DinhLuong
UNION ALL SELECT N'HoaDon',         COUNT(*) FROM dbo.HoaDon
UNION ALL SELECT N'ChiTietHoaDon',  COUNT(*) FROM dbo.ChiTietHoaDon;

SELECT TrangThai, COUNT(*) AS SoHoaDon
FROM dbo.HoaDon
GROUP BY TrangThai
ORDER BY TrangThai;

SELECT COUNT(*) AS SoHoaDonRong
FROM dbo.HoaDon AS h
WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = h.MaHD);

SELECT b.MaBan, b.TrangThai, COUNT(h.MaHD) AS SoHoaDonMo
FROM dbo.Ban AS b
LEFT JOIN dbo.HoaDon AS h
    ON h.MaBan = b.MaBan
   AND h.TrangThai = N'Mở'
GROUP BY b.MaBan, b.TrangThai
HAVING (b.TrangThai = N'Có khách' AND COUNT(h.MaHD) <> 1)
    OR (b.TrangThai <> N'Có khách' AND COUNT(h.MaHD) <> 0);

SELECT h.MaHD, h.TongTien, ISNULL(SUM(ct.SoLuong * ct.DonGia), 0) AS TongChiTiet
FROM dbo.HoaDon AS h
LEFT JOIN dbo.ChiTietHoaDon AS ct ON ct.MaHD = h.MaHD
GROUP BY h.MaHD, h.TongTien
HAVING h.TongTien <> ISNULL(SUM(ct.SoLuong * ct.DonGia), 0);

SELECT MaHD, MaMon, COUNT(*) AS SoLan
FROM dbo.ChiTietHoaDon
GROUP BY MaHD, MaMon
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS SoNguyenLieuBiLech
FROM dbo.NguyenLieu AS nl
JOIN @TonKhoTruoc AS t ON t.MaNL = nl.MaNL
WHERE nl.TonKho <> t.TonKho
   OR nl.DinhMucTon <> t.DinhMucTon
   OR nl.DonGiaNhap <> t.DonGiaNhap;

SELECT
    SUM(CASE WHEN TonKho = 0 THEN 1 ELSE 0 END)                         AS TonKho_Bang0,
    SUM(CASE WHEN TonKho = DinhMucTon THEN 1 ELSE 0 END)                AS TonKho_BangDinhMuc,
    SUM(CASE WHEN TonKho > 0 AND TonKho < DinhMucTon THEN 1 ELSE 0 END) AS TonKho_DuoiDinhMuc,
    SUM(CASE WHEN TonKho > DinhMucTon THEN 1 ELSE 0 END)                AS TonKho_TrenDinhMuc
FROM dbo.NguyenLieu;

SELECT m.MaMon, m.TenMon, m.DangBan
FROM dbo.Mon AS m
WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaMon = m.MaMon)
ORDER BY m.MaMon;

PRINT N'';
PRINT N'=== HOÀN TẤT NẠP TOÀN BỘ DỮ LIỆU MẪU (03_DuLieu.sql) ===';
GO
