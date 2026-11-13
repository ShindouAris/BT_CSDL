-- 05_ThuTuc_Ham.sql: Tạo 5 stored procedure và 3 function nghiệp vụ.
USE QL_CAFE_NHAHANG;
GO

CREATE OR ALTER PROCEDURE sp_GoiMon
    @MaHD    INT,
    @MaMon   INT,
    @SoLuong INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM HoaDon WHERE MaHD = @MaHD AND TrangThai = N'Mở'
        )
        BEGIN
            ;THROW 50001, N'Hóa đơn không tồn tại hoặc không ở trạng thái Mở.', 1;
        END

        IF NOT EXISTS (
            SELECT 1 FROM Mon WHERE MaMon = @MaMon AND DangBan = 1
        )
        BEGIN
            ;THROW 50002, N'Món không tồn tại hoặc hiện không được bán.', 1;
        END

        IF EXISTS (
            SELECT 1
            FROM   DinhLuong   dl
            JOIN   NguyenLieu  nl ON nl.MaNL = dl.MaNL
            WHERE  dl.MaMon = @MaMon
              AND  nl.TonKho - dl.SoLuong * @SoLuong < 0
        )
        BEGIN
            ;THROW 50003, N'Không đủ nguyên liệu để chế biến số lượng yêu cầu.', 1;
        END

        IF EXISTS (
            SELECT 1 FROM ChiTietHoaDon
            WHERE MaHD = @MaHD AND MaMon = @MaMon
        )
        BEGIN
            UPDATE ChiTietHoaDon
            SET    SoLuong = SoLuong + @SoLuong
            WHERE  MaHD = @MaHD AND MaMon = @MaMon;

            UPDATE nl
            SET    nl.TonKho = nl.TonKho - dl.SoLuong * @SoLuong
            FROM   NguyenLieu nl
            JOIN   DinhLuong  dl ON dl.MaNL = nl.MaNL
            WHERE  dl.MaMon = @MaMon;
        END
        ELSE
        BEGIN
            INSERT INTO ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
            SELECT @MaHD, @MaMon, @SoLuong, m.GiaBan, N'Chờ'
            FROM   Mon m
            WHERE  m.MaMon = @MaMon;
        END

        UPDATE hd
        SET    hd.TongTien = (
                   SELECT ISNULL(SUM(ct.SoLuong * ct.DonGia), 0)
                   FROM   ChiTietHoaDon ct
                   WHERE  ct.MaHD = @MaHD
               )
        FROM   HoaDon hd
        WHERE  hd.MaHD = @MaHD;

        COMMIT TRANSACTION;
        PRINT N'[sp_GoiMon] Gọi món thành công. MaHD=' + CAST(@MaHD AS NVARCHAR)
            + N', MaMon=' + CAST(@MaMon AS NVARCHAR)
            + N', SoLuong=' + CAST(@SoLuong AS NVARCHAR);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ;THROW;
    END CATCH
END
GO

GO

CREATE OR ALTER PROCEDURE sp_ThanhToan
    @MaHD              INT,
    @TongTienThucThu   DECIMAL(14,0) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM HoaDon WHERE MaHD = @MaHD AND TrangThai = N'Mở'
        )
        BEGIN
            ;THROW 50010, N'Hóa đơn không tồn tại hoặc không ở trạng thái Mở.', 1;
        END

        IF NOT EXISTS (
            SELECT 1 FROM ChiTietHoaDon WHERE MaHD = @MaHD
        )
        BEGIN
            ;THROW 50011, N'Hóa đơn chưa có món nào, không thể thanh toán.', 1;
        END

        SELECT @TongTienThucThu = TongTien
        FROM   HoaDon
        WHERE  MaHD = @MaHD;

        UPDATE HoaDon
        SET    TrangThai = N'Đã thanh toán'
        WHERE  MaHD = @MaHD;

        UPDATE Ban
        SET    TrangThai = N'Trống'
        WHERE  MaBan = (SELECT MaBan FROM HoaDon WHERE MaHD = @MaHD);

        COMMIT TRANSACTION;
        PRINT N'[sp_ThanhToan] Thanh toán thành công. MaHD=' + CAST(@MaHD AS NVARCHAR)
            + N', TongTien=' + CAST(@TongTienThucThu AS NVARCHAR);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ;THROW;
    END CATCH
END
GO

GO

CREATE OR ALTER PROCEDURE sp_MoHoaDon
    @MaBan  INT,
    @MaNV   INT,
    @MaHD   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Ban WHERE MaBan = @MaBan)
        BEGIN
            ;THROW 50020, N'Bàn không tồn tại.', 1;
        END

        IF NOT EXISTS (
            SELECT 1 FROM NhanVien
            WHERE MaNV = @MaNV AND ChucVu = N'PhucVu'
        )
        BEGIN
            ;THROW 50021, N'Nhân viên không tồn tại hoặc không có chức vụ Phục vụ.', 1;
        END

        DECLARE @TrangThaiBan NVARCHAR(20);
        SELECT @TrangThaiBan = TrangThai FROM Ban WHERE MaBan = @MaBan;

        IF @TrangThaiBan <> N'Trống'
        BEGIN
            ;THROW 50022, N'Bàn hiện không ở trạng thái Trống, không thể mở hóa đơn mới.', 1;
        END

        INSERT INTO HoaDon (MaBan, MaNV, NgayLap, TrangThai, TongTien)
        VALUES (@MaBan, @MaNV, GETDATE(), N'Mở', 0);

        SET @MaHD = SCOPE_IDENTITY();

        UPDATE Ban
        SET    TrangThai = N'Có khách'
        WHERE  MaBan = @MaBan;

        COMMIT TRANSACTION;
        PRINT N'[sp_MoHoaDon] Mở hóa đơn thành công. MaHD=' + CAST(@MaHD AS NVARCHAR)
            + N', MaBan=' + CAST(@MaBan AS NVARCHAR);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ;THROW;
    END CATCH
END
GO

GO

CREATE OR ALTER PROCEDURE sp_HuyHoaDon
    @MaHD INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM HoaDon WHERE MaHD = @MaHD AND TrangThai = N'Mở'
        )
        BEGIN
            ;THROW 50030, N'Hóa đơn không tồn tại hoặc không ở trạng thái Mở, không thể hủy.', 1;
        END

        DECLARE @CurMaMon  INT;
        DECLARE @CurSoLuong INT;

        DECLARE cur_ChiTiet CURSOR LOCAL FAST_FORWARD FOR
            SELECT MaMon, SoLuong
            FROM   ChiTietHoaDon
            WHERE  MaHD = @MaHD;

        OPEN cur_ChiTiet;
        FETCH NEXT FROM cur_ChiTiet INTO @CurMaMon, @CurSoLuong;

        WHILE @@FETCH_STATUS = 0
        BEGIN

            IF EXISTS (SELECT 1 FROM DinhLuong WHERE MaMon = @CurMaMon)
            BEGIN
                UPDATE nl
                SET    nl.TonKho = nl.TonKho + dl.SoLuong * @CurSoLuong
                FROM   NguyenLieu nl
                JOIN   DinhLuong  dl ON dl.MaNL = nl.MaNL
                WHERE  dl.MaMon = @CurMaMon;
            END

            FETCH NEXT FROM cur_ChiTiet INTO @CurMaMon, @CurSoLuong;
        END

        CLOSE cur_ChiTiet;
        DEALLOCATE cur_ChiTiet;

        UPDATE HoaDon
        SET    TrangThai = N'Hủy'
        WHERE  MaHD = @MaHD;

        UPDATE Ban
        SET    TrangThai = N'Trống'
        WHERE  MaBan = (SELECT MaBan FROM HoaDon WHERE MaHD = @MaHD);

        COMMIT TRANSACTION;
        PRINT N'[sp_HuyHoaDon] Hủy hóa đơn thành công. MaHD=' + CAST(@MaHD AS NVARCHAR);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        IF CURSOR_STATUS('local', 'cur_ChiTiet') >= 0
        BEGIN
            CLOSE cur_ChiTiet;
            DEALLOCATE cur_ChiTiet;
        END;

        ;THROW;
    END CATCH
END
GO

GO

CREATE OR ALTER PROCEDURE sp_ThongKeDoanhThu
    @Nam          INT,
    @ThangBatDau  INT = 1,
    @ThangKetThuc INT = 12
AS
BEGIN
    SET NOCOUNT ON;

    IF @ThangBatDau > @ThangKetThuc
    BEGIN
        ;THROW 50040, N'ThangBatDau phải nhỏ hơn hoặc bằng ThangKetThuc.', 1;
    END

    IF @ThangBatDau < 1 OR @ThangKetThuc > 12
    BEGIN
        ;THROW 50041, N'Tháng phải nằm trong khoảng 1 đến 12.', 1;
    END

    SELECT
        MONTH(hd.NgayLap)            AS Thang,
        COUNT(DISTINCT hd.MaHD)      AS TongHoaDon,
        SUM(ct.SoLuong)              AS TongMon,
        SUM(ct.SoLuong * ct.DonGia)  AS DoanhThu
    FROM   HoaDon         hd
    JOIN   ChiTietHoaDon  ct ON ct.MaHD  = hd.MaHD
    JOIN   Mon             m  ON m.MaMon  = ct.MaMon
    JOIN   NhanVien        nv ON nv.MaNV  = hd.MaNV
    WHERE  hd.TrangThai = N'Đã thanh toán'
      AND  YEAR(hd.NgayLap)  = @Nam
      AND  MONTH(hd.NgayLap) BETWEEN @ThangBatDau AND @ThangKetThuc
    GROUP BY MONTH(hd.NgayLap)
    ORDER BY Thang;
END
GO

GO

CREATE OR ALTER FUNCTION fn_GiaVonMon
(
    @MaMon INT
)
RETURNS DECIMAL(14,2)
AS
BEGIN
    DECLARE @GiaVon DECIMAL(14,2);

    SELECT @GiaVon = ISNULL(SUM(dl.SoLuong * nl.DonGiaNhap), 0)
    FROM   DinhLuong  dl
    JOIN   NguyenLieu nl ON nl.MaNL = dl.MaNL
    WHERE  dl.MaMon = @MaMon;

    RETURN @GiaVon;
END
GO

GO

CREATE OR ALTER FUNCTION fn_NguyenLieuDuoiDinhMuc
(
    @PhanTramNguong DECIMAL(5,2) = 100.0
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        nl.MaNL,
        nl.TenNL,
        nl.DonViTinh,
        nl.TonKho,
        nl.DinhMucTon,
        CASE
            WHEN nl.DinhMucTon = 0 THEN NULL
            ELSE CAST(nl.TonKho * 100.0 / nl.DinhMucTon AS DECIMAL(7,2))
        END AS [TyLeTonKho(%)]
    FROM   NguyenLieu nl
    WHERE  nl.DinhMucTon > 0
      AND  nl.TonKho <= nl.DinhMucTon * (@PhanTramNguong / 100.0)
);
GO

GO

CREATE OR ALTER FUNCTION fn_DanhSachMonTheoLoai
(
    @MaLoai         INT,
    @BaoGomConChau  BIT = 0
)
RETURNS @KetQua TABLE
(
    MaMon   INT,
    TenMon  NVARCHAR(100),
    GiaBan  DECIMAL(14,0),
    TenLoai NVARCHAR(100),
    Nhom    CHAR(1),
    DangBan BIT
)
AS
BEGIN
    IF @BaoGomConChau = 0
    BEGIN

        INSERT INTO @KetQua (MaMon, TenMon, GiaBan, TenLoai, Nhom, DangBan)
        SELECT
            m.MaMon,
            m.TenMon,
            m.GiaBan,
            lm.TenLoai,
            m.Nhom,
            m.DangBan
        FROM   Mon     m
        JOIN   LoaiMon lm ON lm.MaLoai = m.MaLoai
        WHERE  m.MaLoai = @MaLoai;
    END
    ELSE
    BEGIN

        ;WITH CTE_Loai AS
        (

            SELECT MaLoai, TenLoai
            FROM   LoaiMon
            WHERE  MaLoai = @MaLoai

            UNION ALL

            SELECT lm.MaLoai, lm.TenLoai
            FROM   LoaiMon lm
            JOIN   CTE_Loai cl ON cl.MaLoai = lm.MaLoaiCha
        )
        INSERT INTO @KetQua (MaMon, TenMon, GiaBan, TenLoai, Nhom, DangBan)
        SELECT
            m.MaMon,
            m.TenMon,
            m.GiaBan,
            cl.TenLoai,
            m.Nhom,
            m.DangBan
        FROM   Mon      m
        JOIN   CTE_Loai cl ON cl.MaLoai = m.MaLoai;
    END

    RETURN;
END
GO

GO
