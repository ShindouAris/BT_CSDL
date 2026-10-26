Use QL_CAFE_NHAHANG;
GO


BEGIN TRY
    BEGIN TRANSACTION;

    /* ============================================================
       BƯỚC 0. KIỂM TRA DANH MỤC VÀ CHUẨN BỊ DỮ LIỆU NGUỒN
       ============================================================ */

    -- Kiểm tra các bảng danh mục bắt buộc phải có dữ liệu
    IF NOT EXISTS (SELECT 1 FROM dbo.Ban)
        THROW 50001, N'Bảng Ban chưa có dữ liệu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.NhanVien WHERE ChucVu = N'PhucVu')
        THROW 50002, N'Không có nhân viên có ChucVu = PhucVu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Mon WHERE DangBan = 1)
        THROW 50003, N'Không có món nào có DangBan = 1.', 1;

    DECLARE @TongHD INT = 1500;       -- Tổng số hóa đơn cần sinh
    DECLARE @SoHDTrong INT = 5;       -- Số hóa đơn rỗng
    DECLARE @TongCT INT = 5000;       -- Tổng số dòng chi tiết

    /*
       Lưu danh sách bàn, nhân viên phục vụ và món hợp lệ vào bảng tạm.
       Món hợp lệ: DangBan = 1 và không thuộc 2 món cuối theo MaMon.
    */
    DECLARE @DSBan TABLE
    (
        Id INT IDENTITY(1, 1) PRIMARY KEY,
        MaBan INT NOT NULL
    );

    INSERT INTO @DSBan (MaBan)
    SELECT MaBan
    FROM dbo.Ban;

    DECLARE @SoBan INT;
    SET @SoBan = @@ROWCOUNT;

    IF @SoBan = 0
        THROW 50004, N'Bảng Ban không có bản ghi nào.', 1;

    -- Danh sách bàn đang có khách: mỗi bàn sẽ có đúng 1 hóa đơn Mở
    DECLARE @DSBanMo TABLE
    (
        Id INT IDENTITY(1, 1) PRIMARY KEY,
        MaBan INT NOT NULL
    );

    INSERT INTO @DSBanMo (MaBan)
    SELECT MaBan
    FROM dbo.Ban
    WHERE TrangThai = N'Có khách';

    DECLARE @SoBanMo INT;
    SET @SoBanMo = @@ROWCOUNT;

    -- Chỉ lấy nhân viên có chức vụ PhucVu
    DECLARE @DSNV TABLE
    (
        Id INT IDENTITY(1, 1) PRIMARY KEY,
        MaNV INT NOT NULL
    );

    INSERT INTO @DSNV (MaNV)
    SELECT MaNV
    FROM dbo.NhanVien
    WHERE ChucVu = N'PhucVu';

    DECLARE @SoNV INT;
    SET @SoNV = @@ROWCOUNT;

    IF @SoNV = 0
        THROW 50005, N'Không có nhân viên phục vụ.', 1;

    -- Danh sách món được phép bán
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

    DECLARE @SoMonToiDa INT;
    SET @SoMonToiDa = (SELECT COUNT(*) FROM @MonHopLe);

    IF @SoMonToiDa = 0
        THROW 50006, N'Không còn món hợp lệ sau khi loại 2 món cuối.', 1;

    -- Mỗi hóa đơn tối đa 6 món
    IF @SoMonToiDa > 6
        SET @SoMonToiDa = 6;

    -- Số hóa đơn có chi tiết = 1500 - 5 hóa đơn rỗng
    DECLARE @SoHDCoMonConLai INT;
    SET @SoHDCoMonConLai = @TongHD - @SoHDTrong;

    -- Kiểm tra khả năng phân bổ đủ 5000 dòng chi tiết
    IF @TongCT < @SoHDCoMonConLai
       OR @TongCT > @SoHDCoMonConLai * @SoMonToiDa
        THROW 50007, N'Không thể phân bổ đủ số dòng chi tiết.', 1;

    -- Không thể vừa đủ 1500 hóa đơn, vừa có 5 hóa đơn rỗng
    IF @SoBanMo > @TongHD - @SoHDTrong
        THROW 50008, N'Số bàn đang có khách quá lớn so với số hóa đơn cần sinh.', 1;

    DECLARE @SoHDDong INT;
    SET @SoHDDong = @TongHD - @SoBanMo;

    /* ============================================================
       BƯỚC 1. XÁC ĐỊNH SỐ HÓA ĐƠN THEO TRẠNG THÁI
       ============================================================ */

    -- Khoảng 7% hóa đơn bị hủy
    DECLARE @SoHDHuy INT;
    SET @SoHDHuy = CAST(ROUND(@TongHD * 0.07, 0) AS INT);

    IF @SoHDHuy > @SoHDDong
        SET @SoHDHuy = @SoHDDong;

    -- Phần còn lại của các hóa đơn không Mở là Đã thanh toán
    DECLARE @SoHDDaTT INT;
    SET @SoHDDaTT = @SoHDDong - @SoHDHuy;

    /* ============================================================
       BƯỚC 2. SINH HÓA ĐƠN MỞ CHO CÁC BÀN ĐANG CÓ KHÁCH
       ============================================================ */

    DECLARE @i INT;
    DECLARE @j INT;
    DECLARE @MaHD INT;
    DECLARE @MaBan INT;
    DECLARE @MaNV INT;
    DECLARE @MaMon INT;
    DECLARE @DonGia DECIMAL(12, 0);
    DECLARE @SoMon INT;
    DECLARE @MinMon INT;
    DECLARE @MaxMon INT;
    DECLARE @NgayLap DATETIME;
    DECLARE @NgayOffset INT;
    DECLARE @Phut INT;
    DECLARE @R INT;
    DECLARE @TrangThai NVARCHAR(30);

    DECLARE @SoCTConLai INT;
    SET @SoCTConLai = @TongCT;

    SET @i = 1;

    WHILE @i <= @SoBanMo
    BEGIN
        -- Lấy bàn đang có khách thứ i
        SELECT @MaBan = MaBan
        FROM @DSBanMo
        WHERE Id = @i;

        -- Chọn ngẫu nhiên một nhân viên phục vụ
        SELECT @MaNV = MaNV
        FROM @DSNV
        WHERE Id = 1 + ABS(CHECKSUM(NEWID())) % @SoNV;

        -- Hóa đơn Mở lập trong ngày hôm nay
        SET @NgayLap = GETDATE();
        SET @TrangThai = N'Mở';

        -- Insert trực tiếp hóa đơn Mở, TongTien tạm thời bằng 0
        INSERT INTO dbo.HoaDon
        (
            MaBan,
            MaNV,
            NgayLap,
            TrangThai,
            TongTien
        )
        VALUES
        (
            @MaBan,
            @MaNV,
            @NgayLap,
            @TrangThai,
            0
        );

        SET @MaHD = CAST(SCOPE_IDENTITY() AS INT);

        /*
           Chọn số món cho hóa đơn.
           Công thức bảo đảm sau khi sinh hết 1495 hóa đơn có món,
           tổng số dòng chi tiết vừa đúng 5000.
        */
        SET @MinMon =
            CASE
                WHEN @SoCTConLai - @SoMonToiDa * (@SoHDCoMonConLai - 1) < 1
                    THEN 1
                ELSE @SoCTConLai - @SoMonToiDa * (@SoHDCoMonConLai - 1)
            END;

        SET @MaxMon =
            CASE
                WHEN @SoCTConLai - (@SoHDCoMonConLai - 1) > @SoMonToiDa
                    THEN @SoMonToiDa
                ELSE @SoCTConLai - (@SoHDCoMonConLai - 1)
            END;

        SET @SoMon =
            @MinMon + ABS(CHECKSUM(NEWID())) % (@MaxMon - @MinMon + 1);

        -- Sinh chi tiết cho hóa đơn Mở
        SET @j = 1;

        WHILE @j <= @SoMon
        BEGIN
            -- Chọn ngẫu nhiên món chưa xuất hiện trong hóa đơn hiện tại
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

            -- Hóa đơn Mở: trạng thái chế biến lẫn Chờ và Đang làm
            INSERT INTO dbo.ChiTietHoaDon
            (
                MaHD,
                MaMon,
                SoLuong,
                DonGia,
                TrangThaiCheBien
            )
            VALUES
            (
                @MaHD,
                @MaMon,
                1 + ABS(CHECKSUM(NEWID())) % 4,
                @DonGia,
                CASE
                    WHEN @j % 2 = 1 THEN N'Chờ'
                    ELSE N'Đang làm'
                END
            );

            SET @j = @j + 1;
        END;

        SET @SoCTConLai = @SoCTConLai - @SoMon;
        SET @SoHDCoMonConLai = @SoHDCoMonConLai - 1;
        SET @i = @i + 1;
    END;

    /* ============================================================
       BƯỚC 3. SINH CÁC HÓA ĐƠN ĐÃ THANH TOÁN / HỦY
       ============================================================ */

    SET @i = 1;

    WHILE @i <= @SoHDDong
    BEGIN
        -- Chọn bàn ngẫu nhiên
        SELECT @MaBan = MaBan
        FROM @DSBan
        WHERE Id = 1 + ABS(CHECKSUM(NEWID())) % @SoBan;

        -- Chọn nhân viên phục vụ ngẫu nhiên
        SELECT @MaNV = MaNV
        FROM @DSNV
        WHERE Id = 1 + ABS(CHECKSUM(NEWID())) % @SoNV;

        -- Ngày lập: 90 ngày gần nhất (0 đến 89 ngày trước)
        SET @NgayOffset = ABS(CHECKSUM(NEWID())) % 90;

        /*
           70% hóa đơn rơi vào giờ cao điểm:
           - 11h00 - 12h59
           - 17h00 - 19h59
           Còn 30% rải đều từ 7h00 đến 21h59.
        */
        SET @R = ABS(CHECKSUM(NEWID())) % 100;

        IF @R < 70
        BEGIN
            IF ABS(CHECKSUM(NEWID())) % 2 = 0
                SET @Phut = 11 * 60 + ABS(CHECKSUM(NEWID())) % 120;
            ELSE
                SET @Phut = 17 * 60 + ABS(CHECKSUM(NEWID())) % 180;
        END
        ELSE
        BEGIN
            SET @Phut = 7 * 60 + ABS(CHECKSUM(NEWID())) % 900;
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

        -- 7% hủy, phần còn lại đã thanh toán
        IF @i <= @SoHDDaTT
            SET @TrangThai = N'Đã thanh toán';
        ELSE
            SET @TrangThai = N'Hủy';

        -- Insert trực tiếp hóa đơn
        INSERT INTO dbo.HoaDon
        (
            MaBan,
            MaNV,
            NgayLap,
            TrangThai,
            TongTien
        )
        VALUES
        (
            @MaBan,
            @MaNV,
            @NgayLap,
            @TrangThai,
            0
        );

        SET @MaHD = CAST(SCOPE_IDENTITY() AS INT);

        /*
           5 hóa đơn cuối cùng của nhóm hóa đơn đóng là hóa đơn rỗng.
           Các hóa đơn còn lại được sinh 1 - 6 món.
        */
        IF @i <= @SoHDDong - @SoHDTrong
        BEGIN
            -- Chọn số món, bảo đảm tổng chi tiết cuối cùng là 5000
            SET @MinMon =
                CASE
                    WHEN @SoCTConLai - @SoMonToiDa * (@SoHDCoMonConLai - 1) < 1
                        THEN 1
                    ELSE @SoCTConLai - @SoMonToiDa * (@SoHDCoMonConLai - 1)
                END;

            SET @MaxMon =
                CASE
                    WHEN @SoCTConLai - (@SoHDCoMonConLai - 1) > @SoMonToiDa
                        THEN @SoMonToiDa
                    ELSE @SoCTConLai - (@SoHDCoMonConLai - 1)
                END;

            SET @SoMon =
                @MinMon + ABS(CHECKSUM(NEWID())) % (@MaxMon - @MinMon + 1);

            SET @j = 1;

            WHILE @j <= @SoMon
            BEGIN
                -- Chọn món chưa dùng trong hóa đơn này
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

                -- Hóa đơn đã thanh toán hoặc hủy: tất cả chi tiết đều Xong
                INSERT INTO dbo.ChiTietHoaDon
                (
                    MaHD,
                    MaMon,
                    SoLuong,
                    DonGia,
                    TrangThaiCheBien
                )
                VALUES
                (
                    @MaHD,
                    @MaMon,
                    1 + ABS(CHECKSUM(NEWID())) % 4,
                    @DonGia,
                    N'Xong'
                );

                SET @j = @j + 1;
            END;

            SET @SoCTConLai = @SoCTConLai - @SoMon;
            SET @SoHDCoMonConLai = @SoHDCoMonConLai - 1;
        END;

        SET @i = @i + 1;
    END;

    -- Kiểm tra việc phân bổ số dòng chi tiết
    IF @SoCTConLai <> 0 OR @SoHDCoMonConLai <> 0
        THROW 50011, N'Phân bổ số dòng chi tiết không khớp.', 1;

    /* ============================================================
       BƯỚC 4. TÍNH TỔNG TIỀN BẰNG MỘT CÂU UPDATE
       ============================================================ */

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

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;

/* ================================================================
   BƯỚC 5. CÁC TRUY VẤN KIỂM TRA
   ================================================================ */

-- 1) Đếm số dòng của từng bảng
SELECT N'HoaDon' AS Bang, COUNT(*) AS SoDong
FROM dbo.HoaDon
UNION ALL
SELECT N'ChiTietHoaDon', COUNT(*)
FROM dbo.ChiTietHoaDon;

-- Thống kê số hóa đơn theo trạng thái
SELECT TrangThai, COUNT(*) AS SoHoaDon
FROM dbo.HoaDon
GROUP BY TrangThai;

-- 2) Kiểm tra trùng khóa (MaHD, MaMon)
SELECT MaHD, MaMon, COUNT(*) AS SoLan
FROM dbo.ChiTietHoaDon
GROUP BY MaHD, MaMon
HAVING COUNT(*) > 1;

-- 3) Kiểm tra mỗi bàn có tối đa 1 hóa đơn Mở
SELECT MaBan, COUNT(*) AS SoHoaDonMo
FROM dbo.HoaDon
WHERE TrangThai = N'Mở'
GROUP BY MaBan
HAVING COUNT(*) > 1;

-- Kiểm tra bàn có khách phải có đúng 1 hóa đơn Mở,
-- bàn không có khách phải không có hóa đơn Mở
SELECT
    b.MaBan,
    b.TrangThai,
    COUNT(h.MaHD) AS SoHoaDonMo
FROM dbo.Ban AS b
LEFT JOIN dbo.HoaDon AS h
    ON h.MaBan = b.MaBan
   AND h.TrangThai = N'Mở'
GROUP BY b.MaBan, b.TrangThai
HAVING (b.TrangThai = N'Có khách' AND COUNT(h.MaHD) <> 1)
    OR (b.TrangThai <> N'Có khách' AND COUNT(h.MaHD) <> 0);

-- 4) Kiểm tra hóa đơn có TongTien khác tổng chi tiết
SELECT
    h.MaHD,
    h.TongTien,
    ISNULL(SUM(ct.SoLuong * ct.DonGia), 0) AS TongChiTiet
FROM dbo.HoaDon AS h
LEFT JOIN dbo.ChiTietHoaDon AS ct
    ON ct.MaHD = h.MaHD
GROUP BY h.MaHD, h.TongTien
HAVING h.TongTien <> ISNULL(SUM(ct.SoLuong * ct.DonGia), 0);

-- Kiểm tra số hóa đơn rỗng (phải bằng 5)
SELECT COUNT(*) AS SoHoaDonRong
FROM dbo.HoaDon AS h
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.ChiTietHoaDon AS ct
    WHERE ct.MaHD = h.MaHD
);