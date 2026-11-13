-- 06_Trigger_GiaoTac.sql: Tạo 3 trigger và chạy 2 kịch bản giao tác (GT01, GT02).
USE QL_CAFE_NHAHANG;
GO

CREATE OR ALTER TRIGGER trg_ChiTietHoaDon_KiemTraNguyenLieu
ON ChiTietHoaDon
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DsThieu NVARCHAR(MAX);

    ;WITH CTE_NhuCau AS (
        SELECT
            dl.MaNL,
            SUM(i.SoLuong * dl.SoLuong) AS SoLuongCan
        FROM inserted    AS i
        JOIN DinhLuong   AS dl ON dl.MaMon = i.MaMon
        GROUP BY dl.MaNL
    )
    SELECT
        @DsThieu = STRING_AGG(
            CONCAT(nl.TenNL,
                   ' (cần: ', nc.SoLuongCan,
                   ', còn: ', nl.TonKho, ')'),
            '; ')
    FROM CTE_NhuCau AS nc
    JOIN NguyenLieu AS nl ON nl.MaNL = nc.MaNL
    WHERE nl.TonKho < nc.SoLuongCan;

    IF @DsThieu IS NOT NULL
    BEGIN
        DECLARE @Msg NVARCHAR(2000) =
            N'Không đủ nguyên liệu: ' + @DsThieu;
        THROW 50001, @Msg, 1;
    END;

    ;WITH CTE_TruKho AS (
        SELECT
            dl.MaNL,
            SUM(i.SoLuong * dl.SoLuong) AS SoLuongCan
        FROM inserted    AS i
        JOIN DinhLuong   AS dl ON dl.MaMon = i.MaMon
        GROUP BY dl.MaNL
    )
    UPDATE nl
    SET    nl.TonKho = nl.TonKho - ck.SoLuongCan
    FROM   NguyenLieu  AS nl
    JOIN   CTE_TruKho  AS ck ON ck.MaNL = nl.MaNL;

END;
GO

CREATE OR ALTER TRIGGER trg_HoaDon_CapNhatBan
ON HoaDon
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(TrangThai) RETURN;

    UPDATE b
    SET    b.TrangThai =
               CASE i.TrangThai
                   WHEN N'Đã thanh toán' THEN N'Trống'
                   WHEN N'Hủy'           THEN N'Trống'
                   WHEN N'Mở'            THEN N'Có khách'
                   ELSE b.TrangThai
               END
    FROM   Ban      AS b
    JOIN   inserted AS i  ON i.MaBan = b.MaBan
    JOIN   deleted  AS d  ON d.MaHD  = i.MaHD
    WHERE  d.TrangThai <> i.TrangThai
    AND    i.TrangThai IN (N'Đã thanh toán', N'Hủy', N'Mở');

END;
GO

CREATE OR ALTER TRIGGER trg_Mon_KiemTraXoa
ON Mon
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DsMonDangDung NVARCHAR(MAX);

    SELECT @DsMonDangDung = STRING_AGG(
               CONCAT(m.MaMon, ' - ', m.TenMon),
               '; ')
    FROM   deleted          AS d
    JOIN   Mon              AS m   ON m.MaMon = d.MaMon
    JOIN   ChiTietHoaDon    AS ct  ON ct.MaMon = m.MaMon
    JOIN   HoaDon           AS hd  ON hd.MaHD  = ct.MaHD
    WHERE  hd.TrangThai = N'Mở';

    IF @DsMonDangDung IS NOT NULL
    BEGIN
        DECLARE @Msg NVARCHAR(2000) =
            N'Không thể ẩn/xóa món đang có trong hóa đơn đang mở: '
            + @DsMonDangDung;
        THROW 50002, @Msg, 1;
    END;

    UPDATE m
    SET    m.DangBan = 0
    FROM   Mon     AS m
    JOIN   deleted AS d ON d.MaMon = m.MaMon;

    DECLARE @DsMonAn NVARCHAR(MAX);

    SELECT @DsMonAn = STRING_AGG(
               CONCAT(d.MaMon, ' - ', m.TenMon),
               ', ')
    FROM   deleted AS d
    JOIN   Mon     AS m ON m.MaMon = d.MaMon;

    PRINT N'[TR03] Đã ẩn (DangBan=0) các món: ' + ISNULL(@DsMonAn, N'(không có)');

END;
GO

PRINT N'';
DECLARE @GT01_MaBan INT = (SELECT TOP 1 MaBan FROM Ban WHERE TrangThai = N'Trống' ORDER BY MaBan);
DECLARE @GT01_MaNV  INT = (SELECT TOP 1 MaNV FROM NhanVien WHERE ChucVu = N'PhucVu' ORDER BY MaNV);
DECLARE @GT01_MaHD  INT;

IF @GT01_MaBan IS NULL
BEGIN
    PRINT N'[GT01-A] SKIP — Không có bàn trống để demo.';
END
ELSE
BEGIN

    DECLARE @GT01_TonKhoGoc TABLE (MaNL INT PRIMARY KEY, TonKho DECIMAL(12,2));
    INSERT INTO @GT01_TonKhoGoc (MaNL, TonKho)
    SELECT MaNL, TonKho
    FROM   NguyenLieu
    WHERE  MaNL IN (SELECT MaNL FROM DinhLuong WHERE MaMon IN (1, 2));

    INSERT INTO HoaDon (MaBan, MaNV, NgayLap, TrangThai, TongTien)
    VALUES (@GT01_MaBan, @GT01_MaNV, GETDATE(), N'Mở', 0);
    SET @GT01_MaHD = SCOPE_IDENTITY();
    UPDATE Ban SET TrangThai = N'Có khách' WHERE MaBan = @GT01_MaBan;

    PRINT N'=== GT01-A: Gọi 2 món — THÀNH CÔNG (MaHD=' + CAST(@GT01_MaHD AS NVARCHAR) + N') ===';
    PRINT N'--- Trước giao tác ---';
    SELECT nl.MaNL, nl.TenNL, nl.TonKho
    FROM   NguyenLieu nl
    WHERE  nl.MaNL IN (SELECT MaNL FROM DinhLuong WHERE MaMon IN (1, 2));

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
        SELECT @GT01_MaHD, MaMon, 1, GiaBan, N'Chờ' FROM Mon WHERE MaMon = 1;

        INSERT INTO ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
        SELECT @GT01_MaHD, MaMon, 2, GiaBan, N'Chờ' FROM Mon WHERE MaMon = 2;

        UPDATE HoaDon
        SET    TongTien = (SELECT SUM(SoLuong * DonGia) FROM ChiTietHoaDon WHERE MaHD = @GT01_MaHD)
        WHERE  MaHD = @GT01_MaHD;

        COMMIT TRANSACTION;
        PRINT N'[GT01-A] COMMIT thành công — 2 món đã được ghi nhận.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT N'[GT01-A] LỖI: ' + ERROR_MESSAGE();
    END CATCH;

    PRINT N'--- Sau giao tác (GT01-A) — kỳ vọng: TonKho giảm, có 2 dòng chi tiết ---';
    SELECT nl.MaNL, nl.TenNL, nl.TonKho
    FROM   NguyenLieu nl
    WHERE  nl.MaNL IN (SELECT MaNL FROM DinhLuong WHERE MaMon IN (1, 2));
    SELECT MaHD, MaMon, SoLuong, DonGia FROM ChiTietHoaDon WHERE MaHD = @GT01_MaHD;
    SELECT MaHD, TrangThai, TongTien FROM HoaDon WHERE MaHD = @GT01_MaHD;

    DELETE FROM ChiTietHoaDon WHERE MaHD = @GT01_MaHD;
    DELETE FROM HoaDon        WHERE MaHD = @GT01_MaHD;
    UPDATE Ban SET TrangThai = N'Trống' WHERE MaBan = @GT01_MaBan;
    UPDATE nl
    SET    nl.TonKho = bk.TonKho
    FROM   NguyenLieu nl
    JOIN   @GT01_TonKhoGoc bk ON bk.MaNL = nl.MaNL;
    PRINT N'[GT01-A] Đã dọn dữ liệu demo (xóa hóa đơn, hoàn tồn kho, trả bàn về Trống).';
END
GO

PRINT N'';
PRINT N'=== GT01-B: Gọi 2 món — THẤT BẠI (thiếu NL ở món 2) ===';

DECLARE @GT01B_MaBan INT = (SELECT TOP 1 MaBan FROM Ban WHERE TrangThai = N'Trống' ORDER BY MaBan);
DECLARE @GT01B_MaNV  INT = (SELECT TOP 1 MaNV FROM NhanVien WHERE ChucVu = N'PhucVu' ORDER BY MaNV);
DECLARE @GT01B_MaHD  INT;

IF @GT01B_MaBan IS NULL
BEGIN
    PRINT N'[GT01-B] SKIP — Không có bàn trống để demo.';
END
ELSE
BEGIN
    INSERT INTO HoaDon (MaBan, MaNV, NgayLap, TrangThai, TongTien)
    VALUES (@GT01B_MaBan, @GT01B_MaNV, GETDATE(), N'Mở', 0);
    SET @GT01B_MaHD = SCOPE_IDENTITY();
    UPDATE Ban SET TrangThai = N'Có khách' WHERE MaBan = @GT01B_MaBan;

    DECLARE @TonKhoBackup TABLE (MaNL INT PRIMARY KEY, TonKhoGoc DECIMAL(12,2));
    INSERT INTO @TonKhoBackup (MaNL, TonKhoGoc)
    SELECT MaNL, TonKho
    FROM   NguyenLieu
    WHERE  MaNL IN (SELECT MaNL FROM DinhLuong WHERE MaMon IN (1, 2));

    UPDATE NguyenLieu
    SET    TonKho = 0
    WHERE  MaNL IN (SELECT MaNL FROM DinhLuong WHERE MaMon = 2)
      AND  MaNL NOT IN (SELECT MaNL FROM DinhLuong WHERE MaMon = 1);

    PRINT N'--- Trước giao tác ---';
    SELECT nl.MaNL, nl.TenNL, nl.TonKho
    FROM   NguyenLieu nl
    WHERE  nl.MaNL IN (SELECT MaNL FROM DinhLuong WHERE MaMon IN (1, 2));
    SELECT COUNT(*) AS SoDongChiTiet FROM ChiTietHoaDon WHERE MaHD = @GT01B_MaHD;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
        SELECT @GT01B_MaHD, MaMon, 1, GiaBan, N'Chờ' FROM Mon WHERE MaMon = 1;
        PRINT N'[GT01-B] Món 1 insert xong (chưa commit).';

        INSERT INTO ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
        SELECT @GT01B_MaHD, MaMon, 2, GiaBan, N'Chờ' FROM Mon WHERE MaMon = 2;

        COMMIT TRANSACTION;
        PRINT N'[GT01-B] COMMIT — (không nên đến đây).';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT N'[GT01-B] ROLLBACK — Lỗi: ' + ERROR_MESSAGE();
    END CATCH;

    PRINT N'--- Sau ROLLBACK (GT01-B) — kỳ vọng: TonKho không đổi, KHÔNG có dòng chi tiết nào (kể cả món 1) ---';
    SELECT nl.MaNL, nl.TenNL, nl.TonKho
    FROM   NguyenLieu nl
    WHERE  nl.MaNL IN (SELECT MaNL FROM DinhLuong WHERE MaMon IN (1, 2));
    SELECT COUNT(*) AS SoDongChiTiet FROM ChiTietHoaDon WHERE MaHD = @GT01B_MaHD;

    DELETE FROM ChiTietHoaDon WHERE MaHD = @GT01B_MaHD;
    DELETE FROM HoaDon        WHERE MaHD = @GT01B_MaHD;
    UPDATE Ban SET TrangThai = N'Trống' WHERE MaBan = @GT01B_MaBan;
    UPDATE nl
    SET    nl.TonKho = bk.TonKhoGoc
    FROM   NguyenLieu nl
    JOIN   @TonKhoBackup bk ON bk.MaNL = nl.MaNL;
    PRINT N'[GT01-B] Đã dọn dữ liệu demo và khôi phục TonKho gốc.';
END
GO

PRINT N'';
PRINT N'=== GT02-A: Thanh toán HĐ — THÀNH CÔNG ===';

DECLARE @GT02_MaBan INT = (SELECT TOP 1 MaBan FROM Ban WHERE TrangThai = N'Trống' ORDER BY MaBan);
DECLARE @GT02_MaNV  INT = (SELECT TOP 1 MaNV FROM NhanVien WHERE ChucVu = N'PhucVu' ORDER BY MaNV);
DECLARE @GT02_MaHD  INT;

IF @GT02_MaBan IS NULL
BEGIN
    PRINT N'[GT02-A] SKIP — Không có bàn trống để demo.';
END
ELSE
BEGIN
    INSERT INTO HoaDon (MaBan, MaNV, NgayLap, TrangThai, TongTien)
    VALUES (@GT02_MaBan, @GT02_MaNV, GETDATE(), N'Mở', 0);
    SET @GT02_MaHD = SCOPE_IDENTITY();
    UPDATE Ban SET TrangThai = N'Có khách' WHERE MaBan = @GT02_MaBan;

    PRINT N'--- Trước giao tác ---';
    SELECT hd.MaHD, hd.TrangThai AS TT_HD, b.MaBan, b.TrangThai AS TT_Ban
    FROM   HoaDon hd JOIN Ban b ON b.MaBan = hd.MaBan
    WHERE  hd.MaHD = @GT02_MaHD;

    BEGIN TRY
        BEGIN TRANSACTION GT02;

            SAVE TRANSACTION sp_ThanhToan;

            UPDATE HoaDon
            SET    TrangThai = N'Đã thanh toán'
            WHERE  MaHD      = @GT02_MaHD
            AND    TrangThai = N'Mở';

            IF @@ROWCOUNT = 0
                THROW 50003, N'Hóa đơn không ở trạng thái Mở, không thể thanh toán.', 1;

        COMMIT TRANSACTION GT02;
        PRINT N'[GT02-A] COMMIT — Hóa đơn đã thanh toán, Bàn chuyển thành Trống.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() = 1
        BEGIN
            ROLLBACK TRANSACTION sp_ThanhToan;
            COMMIT TRANSACTION GT02;
            PRINT N'[GT02-A] ROLLBACK TO SAVEPOINT sp_ThanhToan.';
        END
        ELSE IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        PRINT N'[GT02-A] LỖI: ' + ERROR_MESSAGE();
    END CATCH;

    PRINT N'--- Sau giao tác (GT02-A) — kỳ vọng: HĐ Đã thanh toán, Bàn Trống ---';
    SELECT hd.MaHD, hd.TrangThai AS TT_HD, b.MaBan, b.TrangThai AS TT_Ban
    FROM   HoaDon hd JOIN Ban b ON b.MaBan = hd.MaBan
    WHERE  hd.MaHD = @GT02_MaHD;

    DELETE FROM HoaDon WHERE MaHD = @GT02_MaHD;
    UPDATE Ban SET TrangThai = N'Trống' WHERE MaBan = @GT02_MaBan;
    PRINT N'[GT02-A] Đã dọn dữ liệu demo.';
END
GO

PRINT N'';
PRINT N'=== GT02-B: Thanh toán HĐ đã Hủy — THẤT BẠI (ROLLBACK TO SAVEPOINT) ===';

DECLARE @GT02B_MaBan INT = (SELECT TOP 1 MaBan FROM Ban WHERE TrangThai = N'Trống' ORDER BY MaBan);
DECLARE @GT02B_MaNV  INT = (SELECT TOP 1 MaNV FROM NhanVien WHERE ChucVu = N'PhucVu' ORDER BY MaNV);
DECLARE @GT02B_MaHD  INT;

IF @GT02B_MaBan IS NULL
BEGIN
    PRINT N'[GT02-B] SKIP — Không có bàn trống để demo.';
END
ELSE
BEGIN

    INSERT INTO HoaDon (MaBan, MaNV, NgayLap, TrangThai, TongTien)
    VALUES (@GT02B_MaBan, @GT02B_MaNV, GETDATE(), N'Mở', 0);
    SET @GT02B_MaHD = SCOPE_IDENTITY();
    UPDATE Ban SET TrangThai = N'Có khách' WHERE MaBan = @GT02B_MaBan;
    UPDATE HoaDon SET TrangThai = N'Hủy' WHERE MaHD = @GT02B_MaHD;

    PRINT N'--- Trước giao tác ---';
    SELECT hd.MaHD, hd.TrangThai AS TT_HD, b.MaBan, b.TrangThai AS TT_Ban
    FROM   HoaDon hd JOIN Ban b ON b.MaBan = hd.MaBan
    WHERE  hd.MaHD = @GT02B_MaHD;

    BEGIN TRY
        BEGIN TRANSACTION GT02B;

            SAVE TRANSACTION sp_ThanhToan2;

            UPDATE HoaDon
            SET    TrangThai = N'Đã thanh toán'
            WHERE  MaHD      = @GT02B_MaHD
            AND    TrangThai = N'Mở';

            IF @@ROWCOUNT = 0
                THROW 50003, N'Hóa đơn không ở trạng thái Mở, không thể thanh toán.', 1;

        COMMIT TRANSACTION GT02B;
        PRINT N'[GT02-B] COMMIT — (không nên đến đây).';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() = 1
        BEGIN

            ROLLBACK TRANSACTION sp_ThanhToan2;
            COMMIT TRANSACTION GT02B;
            PRINT N'[GT02-B] ROLLBACK TO SAVEPOINT sp_ThanhToan2.';
        END
        ELSE IF @@TRANCOUNT > 0
        BEGIN

            ROLLBACK TRANSACTION;
            PRINT N'[GT02-B] Transaction bị abort — ROLLBACK hoàn toàn.';
        END
        PRINT N'[GT02-B] LỖI: ' + ERROR_MESSAGE();
    END CATCH;

    PRINT N'--- Sau ROLLBACK (GT02-B) — kỳ vọng: HĐ vẫn Hủy, Bàn không đổi ---';
    SELECT hd.MaHD, hd.TrangThai AS TT_HD, b.MaBan, b.TrangThai AS TT_Ban
    FROM   HoaDon hd JOIN Ban b ON b.MaBan = hd.MaBan
    WHERE  hd.MaHD = @GT02B_MaHD;

    DELETE FROM HoaDon WHERE MaHD = @GT02B_MaHD;
    UPDATE Ban SET TrangThai = N'Trống' WHERE MaBan = @GT02B_MaBan;
    PRINT N'[GT02-B] Đã dọn dữ liệu demo.';
END
GO

PRINT N'';
PRINT N'=== Hoàn tất 06_Trigger_GiaoTac.sql ===';
GO
