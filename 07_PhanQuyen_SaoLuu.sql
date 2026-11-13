-- 07_PhanQuyen_SaoLuu.sql: Tạo login, user, role để phân quyền; sao lưu và phục hồi CSDL.
USE master;
GO

USE QL_CAFE_NHAHANG;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_phucvu') DROP USER user_phucvu;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_thungan') DROP USER user_thungan;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_bep') DROP USER user_bep;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_quanly') DROP USER user_quanly;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_PhucVu' AND type = 'R') DROP ROLE role_PhucVu;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_ThuNgan' AND type = 'R') DROP ROLE role_ThuNgan;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_Bep' AND type = 'R') DROP ROLE role_Bep;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_QuanLy' AND type = 'R') DROP ROLE role_QuanLy;
GO

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_phucvu') DROP LOGIN login_phucvu;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_thungan') DROP LOGIN login_thungan;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_bep') DROP LOGIN login_bep;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_quanly') DROP LOGIN login_quanly;
GO

CREATE LOGIN login_phucvu WITH PASSWORD = N'PhucVu@2025!',
    DEFAULT_DATABASE = QL_CAFE_NHAHANG, CHECK_EXPIRATION = OFF, CHECK_POLICY = ON;

CREATE LOGIN login_thungan WITH PASSWORD = N'ThuNgan@2025!',
    DEFAULT_DATABASE = QL_CAFE_NHAHANG, CHECK_EXPIRATION = OFF, CHECK_POLICY = ON;

CREATE LOGIN login_bep WITH PASSWORD = N'BepNuong@2025!',
    DEFAULT_DATABASE = QL_CAFE_NHAHANG, CHECK_EXPIRATION = OFF, CHECK_POLICY = ON;

CREATE LOGIN login_quanly WITH PASSWORD = N'QuanLy@2025!',
    DEFAULT_DATABASE = QL_CAFE_NHAHANG, CHECK_EXPIRATION = OFF, CHECK_POLICY = ON;
GO

USE QL_CAFE_NHAHANG;
GO

CREATE USER user_phucvu FOR LOGIN login_phucvu;
CREATE USER user_thungan FOR LOGIN login_thungan;
CREATE USER user_bep FOR LOGIN login_bep;
CREATE USER user_quanly FOR LOGIN login_quanly;
GO

CREATE ROLE role_PhucVu;
CREATE ROLE role_ThuNgan;
CREATE ROLE role_Bep;
CREATE ROLE role_QuanLy;
GO

ALTER ROLE role_PhucVu ADD MEMBER user_phucvu;
ALTER ROLE role_ThuNgan ADD MEMBER user_thungan;
ALTER ROLE role_Bep ADD MEMBER user_bep;
ALTER ROLE role_QuanLy ADD MEMBER user_quanly;
GO

GRANT EXECUTE ON OBJECT::dbo.sp_GoiMon    TO role_PhucVu;
GRANT EXECUTE ON OBJECT::dbo.sp_MoHoaDon  TO role_PhucVu;

GRANT SELECT ON OBJECT::dbo.v_MonDangBan  TO role_PhucVu;
GRANT SELECT ON OBJECT::dbo.Ban           TO role_PhucVu;

GRANT INSERT ON OBJECT::dbo.ChiTietHoaDon TO role_PhucVu;

DENY SELECT ON OBJECT::dbo.NguyenLieu     TO role_PhucVu;
DENY SELECT ON OBJECT::dbo.NhanVien       TO role_PhucVu;
GO

GRANT EXECUTE ON OBJECT::dbo.sp_ThanhToan  TO role_ThuNgan;
GRANT EXECUTE ON OBJECT::dbo.sp_HuyHoaDon  TO role_ThuNgan;

GRANT SELECT ON OBJECT::dbo.v_DoanhThuHoaDon TO role_ThuNgan;
GRANT SELECT ON OBJECT::dbo.HoaDon           TO role_ThuNgan;
GRANT SELECT ON OBJECT::dbo.ChiTietHoaDon    TO role_ThuNgan;
GRANT SELECT ON OBJECT::dbo.Ban              TO role_ThuNgan;

GRANT UPDATE (TrangThai) ON OBJECT::dbo.HoaDon TO role_ThuNgan;

DENY INSERT ON OBJECT::dbo.Mon        TO role_ThuNgan;
DENY DELETE ON OBJECT::dbo.Mon        TO role_ThuNgan;
DENY INSERT ON OBJECT::dbo.NguyenLieu TO role_ThuNgan;
DENY DELETE ON OBJECT::dbo.NguyenLieu TO role_ThuNgan;
GO

GRANT SELECT ON OBJECT::dbo.v_MonDangBan TO role_Bep;

GRANT SELECT (MaHD, MaMon, SoLuong, TrangThaiCheBien)
    ON OBJECT::dbo.ChiTietHoaDon TO role_Bep;

GRANT SELECT (MaMon, TenMon)
    ON OBJECT::dbo.Mon TO role_Bep;

GRANT SELECT (MaMon, ThoiGianCheBien, CayHayKhong)
    ON OBJECT::dbo.MonAn TO role_Bep;

GRANT UPDATE (TrangThaiCheBien) ON OBJECT::dbo.ChiTietHoaDon TO role_Bep;

DENY SELECT (TongTien)     ON OBJECT::dbo.HoaDon      TO role_Bep;
DENY SELECT (DonGiaNhap)   ON OBJECT::dbo.NguyenLieu  TO role_Bep;
GO

GRANT EXECUTE ON OBJECT::dbo.sp_GoiMon          TO role_QuanLy;
GRANT EXECUTE ON OBJECT::dbo.sp_ThanhToan        TO role_QuanLy;
GRANT EXECUTE ON OBJECT::dbo.sp_MoHoaDon         TO role_QuanLy;
GRANT EXECUTE ON OBJECT::dbo.sp_HuyHoaDon        TO role_QuanLy;
GRANT EXECUTE ON OBJECT::dbo.sp_ThongKeDoanhThu  TO role_QuanLy;

GRANT SELECT ON OBJECT::dbo.v_MonDangBan      TO role_QuanLy;
GRANT SELECT ON OBJECT::dbo.v_TonKhoCanhBao   TO role_QuanLy;
GRANT SELECT ON OBJECT::dbo.v_DoanhThuHoaDon  TO role_QuanLy;

GRANT SELECT ON OBJECT::dbo.Ban               TO role_QuanLy;
GRANT SELECT ON OBJECT::dbo.Mon               TO role_QuanLy;
GRANT SELECT ON OBJECT::dbo.LoaiMon           TO role_QuanLy;
GRANT SELECT ON OBJECT::dbo.NguyenLieu        TO role_QuanLy;
GRANT SELECT ON OBJECT::dbo.NhanVien          TO role_QuanLy;
GRANT SELECT ON OBJECT::dbo.HoaDon            TO role_QuanLy;
GRANT SELECT ON OBJECT::dbo.ChiTietHoaDon     TO role_QuanLy;

GRANT INSERT, UPDATE, DELETE ON OBJECT::dbo.NguyenLieu TO role_QuanLy;
GRANT INSERT, UPDATE, DELETE ON OBJECT::dbo.Mon        TO role_QuanLy;
GRANT INSERT, UPDATE, DELETE ON OBJECT::dbo.LoaiMon    TO role_QuanLy;
GRANT INSERT, UPDATE, DELETE ON OBJECT::dbo.NhanVien   TO role_QuanLy;
GRANT INSERT, UPDATE, DELETE ON OBJECT::dbo.Ban        TO role_QuanLy;

DENY ALTER ON OBJECT::dbo.Ban           TO role_QuanLy;
DENY ALTER ON OBJECT::dbo.Mon           TO role_QuanLy;
DENY ALTER ON OBJECT::dbo.LoaiMon       TO role_QuanLy;
DENY ALTER ON OBJECT::dbo.NguyenLieu    TO role_QuanLy;
DENY ALTER ON OBJECT::dbo.NhanVien      TO role_QuanLy;
DENY ALTER ON OBJECT::dbo.HoaDon        TO role_QuanLy;
DENY ALTER ON OBJECT::dbo.ChiTietHoaDon TO role_QuanLy;
GO

REVOKE INSERT ON OBJECT::dbo.ChiTietHoaDon FROM role_PhucVu;
REVOKE UPDATE (TrangThai) ON OBJECT::dbo.HoaDon FROM role_ThuNgan;
GO

PRINT N'=== Kiểm chứng role_PhucVu ===';
GO

EXECUTE AS USER = 'user_phucvu';
GO

    SELECT TOP 5 * FROM dbo.v_MonDangBan;

    SELECT TOP 5 MaBan, TenBan, TrangThai FROM dbo.Ban;

    BEGIN TRY
        SELECT TOP 1 * FROM dbo.NguyenLieu;
        PRINT N'[FAIL] user_phucvu đọc được NguyenLieu — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_phucvu bị từ chối SELECT NguyenLieu: ' + ERROR_MESSAGE();
    END CATCH;

    BEGIN TRY
        SELECT TOP 1 * FROM dbo.NhanVien;
        PRINT N'[FAIL] user_phucvu đọc được NhanVien — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_phucvu bị từ chối SELECT NhanVien: ' + ERROR_MESSAGE();
    END CATCH;

    BEGIN TRY
        INSERT INTO dbo.ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
        VALUES (1, 1, 1, 1000, N'Chờ');
        PRINT N'[FAIL] user_phucvu INSERT trực tiếp được ChiTietHoaDon — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_phucvu bị từ chối INSERT ChiTietHoaDon: ' + ERROR_MESSAGE();
    END CATCH;

    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @Ban INT = (SELECT TOP 1 MaBan FROM dbo.Ban WHERE TrangThai = N'Trống' ORDER BY MaBan);
        DECLARE @HD INT;
        EXEC dbo.sp_MoHoaDon @MaBan = @Ban, @MaNV = 6, @MaHD = @HD OUTPUT;
        EXEC dbo.sp_GoiMon   @MaHD = @HD, @MaMon = 20, @SoLuong = 1;
        PRINT N'[OK]   user_phucvu mở hóa đơn và gọi món qua stored procedure.';
        ROLLBACK TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT N'[FAIL] user_phucvu không chạy được sp_MoHoaDon/sp_GoiMon: ' + ERROR_MESSAGE();
    END CATCH;
GO
REVERT;
GO

PRINT N'=== Kiểm chứng role_ThuNgan ===';
GO

EXECUTE AS USER = 'user_thungan';
GO

    SELECT TOP 5 * FROM dbo.v_DoanhThuHoaDon;

    SELECT TOP 5 * FROM dbo.HoaDon;

    BEGIN TRY
        INSERT INTO dbo.Mon (TenMon, MaLoai, GiaBan, Nhom, DangBan)
        VALUES (N'Món Test Quyền', 1, 10000, 'A', 1);
        PRINT N'[FAIL] user_thungan INSERT được Mon — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_thungan bị từ chối INSERT Mon: ' + ERROR_MESSAGE();
    END CATCH;

    BEGIN TRY
        DELETE FROM dbo.NguyenLieu WHERE 1 = 0;
        PRINT N'[FAIL] user_thungan DELETE được NguyenLieu — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_thungan bị từ chối DELETE NguyenLieu: ' + ERROR_MESSAGE();
    END CATCH;

    BEGIN TRY
        UPDATE dbo.HoaDon SET TrangThai = N'Đã thanh toán' WHERE 1 = 0;
        PRINT N'[FAIL] user_thungan UPDATE trực tiếp được HoaDon.TrangThai — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_thungan bị từ chối UPDATE HoaDon.TrangThai: ' + ERROR_MESSAGE();
    END CATCH;
GO
REVERT;
GO

PRINT N'=== Kiểm chứng role_Bep ===';
GO

EXECUTE AS USER = 'user_bep';
GO

    SELECT TOP 5 * FROM dbo.v_MonDangBan;

    SELECT TOP 5 MaHD, MaMon, SoLuong, TrangThaiCheBien
    FROM dbo.ChiTietHoaDon;

    BEGIN TRY
        SELECT TOP 1 TongTien FROM dbo.HoaDon;
        PRINT N'[FAIL] user_bep đọc được TongTien — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_bep bị từ chối SELECT TongTien: ' + ERROR_MESSAGE();
    END CATCH;

    BEGIN TRY
        SELECT TOP 1 DonGiaNhap FROM dbo.NguyenLieu;
        PRINT N'[FAIL] user_bep đọc được DonGiaNhap — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_bep bị từ chối SELECT DonGiaNhap: ' + ERROR_MESSAGE();
    END CATCH;
GO
REVERT;
GO

PRINT N'=== Kiểm chứng role_QuanLy ===';
GO

EXECUTE AS USER = 'user_quanly';
GO

    SELECT TOP 5 * FROM dbo.v_MonDangBan;
    SELECT TOP 5 * FROM dbo.v_TonKhoCanhBao;
    SELECT TOP 5 * FROM dbo.v_DoanhThuHoaDon;

    SELECT TOP 3 * FROM dbo.NhanVien;
    SELECT TOP 3 * FROM dbo.NguyenLieu;

    BEGIN TRY
        DECLARE @NamHienTai INT = YEAR(GETDATE());
        EXEC dbo.sp_ThongKeDoanhThu @Nam = @NamHienTai;
        PRINT N'[OK]   user_quanly chạy được sp_ThongKeDoanhThu.';
    END TRY
    BEGIN CATCH
        PRINT N'[FAIL] user_quanly không chạy được sp_ThongKeDoanhThu: ' + ERROR_MESSAGE();
    END CATCH;

    BEGIN TRY
        ALTER TABLE dbo.Ban ADD TestCol INT NULL;
        PRINT N'[FAIL] user_quanly ALTER được Ban — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_quanly bị từ chối ALTER TABLE: ' + ERROR_MESSAGE();
    END CATCH;
GO
REVERT;
GO

USE master;
GO

ALTER DATABASE QL_CAFE_NHAHANG SET RECOVERY FULL;
GO

BACKUP DATABASE QL_CAFE_NHAHANG
TO DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Full.bak'
WITH
    FORMAT,
    INIT,
    NAME = N'QL_CAFE_NHAHANG — Full Backup',
    DESCRIPTION = N'Sao luu toan bo CSDL quan ly cafe nha hang',

    CHECKSUM,
    STATS = 10;
GO

BACKUP DATABASE QL_CAFE_NHAHANG
TO DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Diff.bak'
WITH
    FORMAT,
    INIT,
    DIFFERENTIAL,
    NAME = N'QL_CAFE_NHAHANG — Differential Backup',
    DESCRIPTION = N'Sao luu vi sai tu Full backup cuoi cung',

    CHECKSUM,
    STATS = 10;
GO

BACKUP LOG QL_CAFE_NHAHANG
TO DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Log.bak'
WITH
    FORMAT,
    INIT,
    NAME = N'QL_CAFE_NHAHANG — Log Backup',
    DESCRIPTION = N'Sao luu nhat ky giao dich',

    CHECKSUM,
    STATS = 10;
GO

USE master;
GO

RESTORE HEADERONLY
FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Full.bak';
GO

RESTORE FILELISTONLY
FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Full.bak';
GO

RESTORE VERIFYONLY
FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Full.bak'
WITH CHECKSUM;
GO

IF DB_ID(N'QL_CAFE_RESTORE') IS NOT NULL
BEGIN
    ALTER DATABASE QL_CAFE_RESTORE SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QL_CAFE_RESTORE;
END
GO

RESTORE DATABASE QL_CAFE_RESTORE
FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Full.bak'
WITH
    MOVE N'QL_CAFE_Data'      TO N'C:\SQLData\QL_CAFE_RESTORE.mdf',
    MOVE N'QL_CAFE_Log'       TO N'C:\SQLData\QL_CAFE_RESTORE_log.ldf',
    NORECOVERY,
    REPLACE,
    STATS = 10;
GO

RESTORE DATABASE QL_CAFE_RESTORE
FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Diff.bak'
WITH
    NORECOVERY,
    STATS = 10;
GO

RESTORE LOG QL_CAFE_RESTORE
FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Log.bak'
WITH
    RECOVERY,
    STATS = 10;
GO

USE QL_CAFE_RESTORE;
GO
SELECT
    DB_NAME()           AS [CSDL_PhucHoi],
    GETDATE()           AS [ThoiDiemKiemTra],
    COUNT(*)            AS [SoBan]
FROM dbo.Ban;
GO

USE master;
GO
