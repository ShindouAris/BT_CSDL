USE master;
GO
/* =====================================================================
   07_PhanQuyen_SaoLuu.sql — PHÂN QUYỀN VÀ SAO LƯU
   Đề tài 13: Nhà hàng / Quán cà phê
   CSDL: QL_CAFE_NHAHANG
   ===================================================================== */

USE QL_CAFE_NHAHANG;
GO

-- ============================================================
-- PHẦN 1: TẠO LOGIN / USER / ROLE
-- ============================================================

-- ----------------------------------------------------------------
-- 1.1  ROLE_PHUCVU — Nhân viên phục vụ (gọi món)
-- ----------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_phucvu')
    CREATE LOGIN login_phucvu WITH PASSWORD = N'PhucVu@2025!',
        DEFAULT_DATABASE = QL_CAFE_NHAHANG,
        CHECK_EXPIRATION = OFF, CHECK_POLICY = ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_phucvu')
    CREATE USER user_phucvu FOR LOGIN login_phucvu;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_PhucVu' AND type = 'R')
    CREATE ROLE role_PhucVu;
GO

ALTER ROLE role_PhucVu ADD MEMBER user_phucvu;
GO

-- ----------------------------------------------------------------
-- 1.2  ROLE_THUNGAN — Thu ngân (thanh toán)
-- ----------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_thungan')
    CREATE LOGIN login_thungan WITH PASSWORD = N'ThuNgan@2025!',
        DEFAULT_DATABASE = QL_CAFE_NHAHANG,
        CHECK_EXPIRATION = OFF, CHECK_POLICY = ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_thungan')
    CREATE USER user_thungan FOR LOGIN login_thungan;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_ThuNgan' AND type = 'R')
    CREATE ROLE role_ThuNgan;
GO

ALTER ROLE role_ThuNgan ADD MEMBER user_thungan;
GO

-- ----------------------------------------------------------------
-- 1.3  ROLE_BEP — Bếp (xem món cần chế biến)
-- ----------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_bep')
    CREATE LOGIN login_bep WITH PASSWORD = N'BepNuong@2025!',
        DEFAULT_DATABASE = QL_CAFE_NHAHANG,
        CHECK_EXPIRATION = OFF, CHECK_POLICY = ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_bep')
    CREATE USER user_bep FOR LOGIN login_bep;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_Bep' AND type = 'R')
    CREATE ROLE role_Bep;
GO

ALTER ROLE role_Bep ADD MEMBER user_bep;
GO

-- ----------------------------------------------------------------
-- 1.4  ROLE_QUANLY — Quản lý (xem tất cả)
-- ----------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_quanly')
    CREATE LOGIN login_quanly WITH PASSWORD = N'QuanLy@2025!',
        DEFAULT_DATABASE = QL_CAFE_NHAHANG,
        CHECK_EXPIRATION = OFF, CHECK_POLICY = ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_quanly')
    CREATE USER user_quanly FOR LOGIN login_quanly;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_QuanLy' AND type = 'R')
    CREATE ROLE role_QuanLy;
GO

ALTER ROLE role_QuanLy ADD MEMBER user_quanly;
GO


-- ============================================================
-- PHẦN 2: PHÂN QUYỀN
-- ============================================================

-- ----------------------------------------------------------------
-- 2.1  Quyền cho ROLE_PHUCVU
-- ----------------------------------------------------------------
-- EXECUTE stored procedures
GRANT EXECUTE ON OBJECT::dbo.sp_GoiMon    TO role_PhucVu;
GRANT EXECUTE ON OBJECT::dbo.sp_MoHoaDon  TO role_PhucVu;

-- SELECT views & bảng
GRANT SELECT ON OBJECT::dbo.v_MonDangBan  TO role_PhucVu;
GRANT SELECT ON OBJECT::dbo.Ban           TO role_PhucVu;

-- INSERT trực tiếp vào chi tiết hóa đơn (gọi thêm món)
GRANT INSERT ON OBJECT::dbo.ChiTietHoaDon TO role_PhucVu;

-- DENY xem tồn kho và nhân sự
DENY SELECT ON OBJECT::dbo.NguyenLieu     TO role_PhucVu;
DENY SELECT ON OBJECT::dbo.NhanVien       TO role_PhucVu;
GO

-- ----------------------------------------------------------------
-- 2.2  Quyền cho ROLE_THUNGAN
-- ----------------------------------------------------------------
-- EXECUTE stored procedures
GRANT EXECUTE ON OBJECT::dbo.sp_ThanhToan  TO role_ThuNgan;
GRANT EXECUTE ON OBJECT::dbo.sp_HuyHoaDon  TO role_ThuNgan;

-- SELECT views & bảng
GRANT SELECT ON OBJECT::dbo.v_DoanhThuHoaDon TO role_ThuNgan;
GRANT SELECT ON OBJECT::dbo.HoaDon           TO role_ThuNgan;
GRANT SELECT ON OBJECT::dbo.ChiTietHoaDon    TO role_ThuNgan;
GRANT SELECT ON OBJECT::dbo.Ban              TO role_ThuNgan;

-- UPDATE chỉ cột TrangThai của HoaDon
GRANT UPDATE (TrangThai) ON OBJECT::dbo.HoaDon TO role_ThuNgan;

-- DENY INSERT/DELETE trên Mon và NguyenLieu
DENY INSERT ON OBJECT::dbo.Mon        TO role_ThuNgan;
DENY DELETE ON OBJECT::dbo.Mon        TO role_ThuNgan;
DENY INSERT ON OBJECT::dbo.NguyenLieu TO role_ThuNgan;
DENY DELETE ON OBJECT::dbo.NguyenLieu TO role_ThuNgan;
GO

-- ----------------------------------------------------------------
-- 2.3  Quyền cho ROLE_BEP
-- ----------------------------------------------------------------
-- SELECT views
GRANT SELECT ON OBJECT::dbo.v_MonDangBan TO role_Bep;

-- SELECT một số cột của ChiTietHoaDon (cột cần thiết cho bếp)
GRANT SELECT (MaHD, MaMon, SoLuong, TrangThaiCheBien)
    ON OBJECT::dbo.ChiTietHoaDon TO role_Bep;

-- SELECT cột cần thiết của Mon (xem tên món) và MonAn (xem thời gian chế biến, độ cay)
GRANT SELECT (MaMon, TenMon)
    ON OBJECT::dbo.Mon TO role_Bep;

GRANT SELECT (MaMon, ThoiGianCheBien, CayHayKhong)
    ON OBJECT::dbo.MonAn TO role_Bep;

-- UPDATE trạng thái chế biến
GRANT UPDATE (TrangThaiCheBien) ON OBJECT::dbo.ChiTietHoaDon TO role_Bep;

-- DENY xem giá trên HoaDon và giá nhập NguyenLieu
DENY SELECT (TongTien)     ON OBJECT::dbo.HoaDon      TO role_Bep;
DENY SELECT (DonGiaNhap)   ON OBJECT::dbo.NguyenLieu  TO role_Bep;
GO

-- ----------------------------------------------------------------
-- 2.4  Quyền cho ROLE_QUANLY
-- ----------------------------------------------------------------
-- EXECUTE tất cả stored procedures
GRANT EXECUTE ON OBJECT::dbo.sp_GoiMon          TO role_QuanLy;
GRANT EXECUTE ON OBJECT::dbo.sp_ThanhToan        TO role_QuanLy;
GRANT EXECUTE ON OBJECT::dbo.sp_MoHoaDon         TO role_QuanLy;
GRANT EXECUTE ON OBJECT::dbo.sp_HuyHoaDon        TO role_QuanLy;
GRANT EXECUTE ON OBJECT::dbo.sp_ThongKeDoanhThu  TO role_QuanLy;

-- SELECT tất cả bảng và view
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

-- INSERT / UPDATE / DELETE trên các bảng nghiệp vụ chính
GRANT INSERT, UPDATE, DELETE ON OBJECT::dbo.NguyenLieu TO role_QuanLy;
GRANT INSERT, UPDATE, DELETE ON OBJECT::dbo.Mon        TO role_QuanLy;
GRANT INSERT, UPDATE, DELETE ON OBJECT::dbo.LoaiMon    TO role_QuanLy;
GRANT INSERT, UPDATE, DELETE ON OBJECT::dbo.NhanVien   TO role_QuanLy;
GRANT INSERT, UPDATE, DELETE ON OBJECT::dbo.Ban        TO role_QuanLy;

-- DENY ALTER / DROP (không cho sửa cấu trúc CSDL)
DENY ALTER ON OBJECT::dbo.Ban           TO role_QuanLy;
DENY ALTER ON OBJECT::dbo.Mon           TO role_QuanLy;
DENY ALTER ON OBJECT::dbo.LoaiMon       TO role_QuanLy;
DENY ALTER ON OBJECT::dbo.NguyenLieu    TO role_QuanLy;
DENY ALTER ON OBJECT::dbo.NhanVien      TO role_QuanLy;
DENY ALTER ON OBJECT::dbo.HoaDon        TO role_QuanLy;
DENY ALTER ON OBJECT::dbo.ChiTietHoaDon TO role_QuanLy;
GO


-- ============================================================
-- PHẦN 3: KIỂM CHỨNG QUYỀN (EXECUTE AS)
-- ============================================================

-- ----------------------------------------------------------------
-- 3.1  Kiểm chứng role_PhucVu
-- ----------------------------------------------------------------
PRINT N'=== Kiểm chứng role_PhucVu ===';
GO

EXECUTE AS USER = 'user_phucvu';
GO
    -- Phải thành công: xem menu
    SELECT TOP 5 * FROM dbo.v_MonDangBan;

    -- Phải thành công: xem trạng thái bàn
    SELECT TOP 5 MaBan, TenBan, TrangThai FROM dbo.Ban;

    -- Phải bị từ chối: xem tồn kho
    BEGIN TRY
        SELECT TOP 1 * FROM dbo.NguyenLieu;
        PRINT N'[FAIL] user_phucvu đọc được NguyenLieu — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_phucvu bị từ chối SELECT NguyenLieu: ' + ERROR_MESSAGE();
    END CATCH;

    -- Phải bị từ chối: xem nhân sự
    BEGIN TRY
        SELECT TOP 1 * FROM dbo.NhanVien;
        PRINT N'[FAIL] user_phucvu đọc được NhanVien — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_phucvu bị từ chối SELECT NhanVien: ' + ERROR_MESSAGE();
    END CATCH;
GO
REVERT;
GO

-- ----------------------------------------------------------------
-- 3.2  Kiểm chứng role_ThuNgan
-- ----------------------------------------------------------------
PRINT N'=== Kiểm chứng role_ThuNgan ===';
GO

EXECUTE AS USER = 'user_thungan';
GO
    -- Phải thành công: xem hóa đơn đã thanh toán
    SELECT TOP 5 * FROM dbo.v_DoanhThuHoaDon;

    -- Phải thành công: xem chi tiết hóa đơn
    SELECT TOP 5 * FROM dbo.HoaDon;

    -- Phải bị từ chối: INSERT vào Mon
    BEGIN TRY
        INSERT INTO dbo.Mon (TenMon, MaLoai, GiaBan, Nhom, DangBan)
        VALUES (N'Món Test Quyền', 1, 10000, 'A', 1);
        PRINT N'[FAIL] user_thungan INSERT được Mon — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_thungan bị từ chối INSERT Mon: ' + ERROR_MESSAGE();
    END CATCH;

    -- Phải bị từ chối: DELETE trên NguyenLieu
    BEGIN TRY
        DELETE FROM dbo.NguyenLieu WHERE 1 = 0;
        PRINT N'[FAIL] user_thungan DELETE được NguyenLieu — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_thungan bị từ chối DELETE NguyenLieu: ' + ERROR_MESSAGE();
    END CATCH;
GO
REVERT;
GO

-- ----------------------------------------------------------------
-- 3.3  Kiểm chứng role_Bep
-- ----------------------------------------------------------------
PRINT N'=== Kiểm chứng role_Bep ===';
GO

EXECUTE AS USER = 'user_bep';
GO
    -- Phải thành công: xem danh sách món đang bán
    SELECT TOP 5 * FROM dbo.v_MonDangBan;

    -- Phải thành công: xem chi tiết cần chế biến
    SELECT TOP 5 MaHD, MaMon, SoLuong, TrangThaiCheBien
    FROM dbo.ChiTietHoaDon;

    -- Phải bị từ chối: xem TongTien trên HoaDon
    BEGIN TRY
        SELECT TOP 1 TongTien FROM dbo.HoaDon;
        PRINT N'[FAIL] user_bep đọc được TongTien — phải bị từ chối!';
    END TRY
    BEGIN CATCH
        PRINT N'[OK]   user_bep bị từ chối SELECT TongTien: ' + ERROR_MESSAGE();
    END CATCH;

    -- Phải bị từ chối: xem DonGiaNhap trên NguyenLieu
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

-- ----------------------------------------------------------------
-- 3.4  Kiểm chứng role_QuanLy
-- ----------------------------------------------------------------
PRINT N'=== Kiểm chứng role_QuanLy ===';
GO

EXECUTE AS USER = 'user_quanly';
GO
    -- Phải thành công: xem mọi view
    SELECT TOP 5 * FROM dbo.v_MonDangBan;
    SELECT TOP 5 * FROM dbo.v_TonKhoCanhBao;
    SELECT TOP 5 * FROM dbo.v_DoanhThuHoaDon;

    -- Phải thành công: xem mọi bảng nghiệp vụ
    SELECT TOP 3 * FROM dbo.NhanVien;
    SELECT TOP 3 * FROM dbo.NguyenLieu;

    -- Phải thành công: execute stored procedure thống kê
    BEGIN TRY
        EXEC dbo.sp_ThongKeDoanhThu @Nam = 2026;
        PRINT N'[OK]   user_quanly chạy được sp_ThongKeDoanhThu.';
    END TRY
    BEGIN CATCH
        PRINT N'[FAIL] user_quanly không chạy được sp_ThongKeDoanhThu: ' + ERROR_MESSAGE();
    END CATCH;

    -- Phải bị từ chối: ALTER TABLE (thay đổi cấu trúc)
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


-- ============================================================
-- PHẦN 4: SAO LƯU (BACKUP)
-- ============================================================

USE master;
GO

-- Đảm bảo thư mục đích tồn tại trước khi chạy backup
-- (Chạy lệnh sau trong PowerShell nếu cần: New-Item -ItemType Directory -Path "C:\SQLBackup")

-- ----------------------------------------------------------------
-- 4.1  Sao lưu FULL — toàn bộ CSDL
-- ----------------------------------------------------------------
BACKUP DATABASE QL_CAFE_NHAHANG
TO DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Full.bak'
WITH
    FORMAT,                                     -- ghi đè media set hiện tại
    INIT,                                       -- khởi tạo lại file backup
    NAME = N'QL_CAFE_NHAHANG — Full Backup',
    DESCRIPTION = N'Sao luu toan bo CSDL quan ly cafe nha hang',
    COMPRESSION,                                -- nén để tiết kiệm dung lượng
    CHECKSUM,                                   -- kiểm tra tính toàn vẹn
    STATS = 10;                                 -- hiển thị tiến độ mỗi 10%
GO

-- ----------------------------------------------------------------
-- 4.2  Sao lưu DIFFERENTIAL — chỉ thay đổi từ lần Full backup cuối
-- ----------------------------------------------------------------
BACKUP DATABASE QL_CAFE_NHAHANG
TO DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Diff.bak'
WITH
    DIFFERENTIAL,
    NAME = N'QL_CAFE_NHAHANG — Differential Backup',
    DESCRIPTION = N'Sao luu vi sai tu Full backup cuoi cung',
    COMPRESSION,
    CHECKSUM,
    STATS = 10;
GO

-- ----------------------------------------------------------------
-- 4.3  Sao lưu LOG — transaction log (cần Recovery Model = FULL)
-- ----------------------------------------------------------------
-- Bước 1: Chuyển sang Recovery Model FULL (nếu chưa)
ALTER DATABASE QL_CAFE_NHAHANG SET RECOVERY FULL;
GO

-- Bước 2: Lấy full backup mới (bắt buộc sau khi đổi Recovery Model)
-- (Bỏ qua nếu vừa thực hiện bước 4.1)

-- Bước 3: Backup Transaction Log
BACKUP LOG QL_CAFE_NHAHANG
TO DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Log.bak'
WITH
    NAME = N'QL_CAFE_NHAHANG — Log Backup',
    DESCRIPTION = N'Sao luu nhat ky giao dich',
    COMPRESSION,
    CHECKSUM,
    STATS = 10;
GO


-- ============================================================
-- PHẦN 5: PHỤC HỒI (RESTORE)
-- ============================================================

-- ----------------------------------------------------------------
-- 5.1  Xác minh backup trước khi phục hồi
-- ----------------------------------------------------------------
-- Kiểm tra thông tin file backup Full
RESTORE HEADERONLY
FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Full.bak';
GO

-- Kiểm tra danh sách file bên trong backup
RESTORE FILELISTONLY
FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Full.bak';
GO

-- Kiểm tra tính toàn vẹn backup
RESTORE VERIFYONLY
FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Full.bak'
WITH CHECKSUM;
GO

-- ----------------------------------------------------------------
-- 5.2  Phục hồi FULL vào CSDL mới (QL_CAFE_RESTORE) — NORECOVERY
-- ----------------------------------------------------------------
-- Lưu ý: điều chỉnh đường dẫn .mdf/.ldf theo cấu hình SQL Server thực tế
RESTORE DATABASE QL_CAFE_RESTORE
FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Full.bak'
WITH
    MOVE N'QL_CAFE_Data'      TO N'C:\SQLData\QL_CAFE_RESTORE.mdf',
    MOVE N'QL_CAFE_Log'       TO N'C:\SQLData\QL_CAFE_RESTORE_log.ldf',
    NORECOVERY,                              -- giữ trạng thái restoring để áp Differential/Log tiếp
    REPLACE,                                 -- ghi đè nếu CSDL đích đã tồn tại
    STATS = 10;
GO

-- ----------------------------------------------------------------
-- 5.3  Áp Differential backup (tiếp theo Full) — NORECOVERY
-- ----------------------------------------------------------------
RESTORE DATABASE QL_CAFE_RESTORE
FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Diff.bak'
WITH
    NORECOVERY,
    STATS = 10;
GO

-- ----------------------------------------------------------------
-- 5.4  Áp Transaction Log backup — RECOVERY (đưa DB online)
-- ----------------------------------------------------------------
RESTORE LOG QL_CAFE_RESTORE
FROM DISK = N'C:\SQLBackup\QL_CAFE_NHAHANG_Log.bak'
WITH
    RECOVERY,       -- đưa CSDL về trạng thái online sau khi áp log
    STATS = 10;
GO

-- ----------------------------------------------------------------
-- 5.5  Xác nhận phục hồi thành công
-- ----------------------------------------------------------------
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


/*
   ============================================================
   PHẦN 6: PHƯƠNG ÁN HIGH AVAILABILITY (HA)
   Dành cho hệ thống Nhà hàng / Quán cà phê
   ============================================================

   1. PHÂN TÍCH RTO VÀ RPO
   ------------------------
   - RTO (Recovery Time Objective — Thời gian phục hồi tối đa chấp nhận):
       Giờ cao điểm (11h-14h, 17h-21h): RTO ≤ 5 phút.
       Giờ thấp điểm: RTO ≤ 30 phút.
       Mục tiêu: hệ thống tính tiền, gọi món phải hoạt động liên tục.

   - RPO (Recovery Point Objective — Mất dữ liệu tối đa chấp nhận):
       RPO ≤ 1 phút cho giao dịch thanh toán (mất hóa đơn gây tranh chấp).
       RPO ≤ 5 phút cho dữ liệu gọi món / chế biến.
       Nghiệp vụ nhà hàng không chấp nhận mất dữ liệu hóa đơn đã thanh toán.

   2. ĐỀ XUẤT: ALWAYS ON AVAILABILITY GROUPS
   ------------------------------------------
   - Tại sao phù hợp cho nhà hàng / quán cà phê:
       * Synchronous commit với Secondary ở cùng địa điểm (ví dụ: máy phụ
         trong kho) → RPO ~ 0, dữ liệu không mất khi primary sập.
       * Automatic Failover: khi Primary gặp sự cố, Secondary tự động
         lên làm Primary trong vòng vài giây → đáp ứng RTO ≤ 5 phút.
       * Secondary readable: có thể cấu hình đọc báo cáo doanh thu từ
         Secondary mà không tốn tài nguyên Primary (phục vụ real-time POS).
       * Hỗ trợ từ SQL Server 2016 Standard (cơ bản) trở lên.

   3. PHƯƠNG ÁN BACKUP TỰ ĐỘNG (SQL SERVER AGENT JOB)
   ----------------------------------------------------
   Lịch đề xuất (3-2-1 Backup Rule):
       - Full Backup   : 2:00 AM hàng ngày (sau khi quán đóng cửa)
       - Differential  : Mỗi 4 giờ trong ngày (06:00, 10:00, 14:00, 18:00, 22:00)
       - Log Backup    : Mỗi 5 phút (đáp ứng RPO ≤ 5 phút)

   Cấu hình SQL Server Agent Job mẫu:
       Step 1 — Backup (T-SQL như Phần 4 ở trên)
       Step 2 — Xóa file backup cũ hơn 7 ngày (dùng xp_delete_file hoặc
                Maintenance Plan "Clean Up Task")
       Step 3 — Gửi email cảnh báo nếu backup thất bại
                (cần cấu hình Database Mail)

   4. LƯU Ý VỀ CHI PHÍ VÀ HẠ TẦNG THỰC TẾ
   -----------------------------------------
   - Always On AG yêu cầu Windows Server Failover Cluster (WSFC) và ít nhất
     2 máy chủ chạy SQL Server Enterprise (hoặc Standard với giới hạn 2 node).
   - Chi phí ước tính: 2 máy chủ vật lý/VM + bản quyền SQL Server Enterprise
     → phù hợp chuỗi nhà hàng quy mô vừa và lớn.
   - Với quán nhỏ (1-2 chi nhánh): có thể thay bằng Log Shipping + tự động
     Restore trên máy dự phòng, chi phí thấp hơn nhiều.
   - Backup nên được lưu ra ổ đĩa ngoài hoặc Cloud Storage (Azure Blob) để
     đảm bảo nguyên tắc 3-2-1 (3 bản, 2 thiết bị, 1 bản off-site).
   - Kiểm tra phục hồi (Restore Drill) ít nhất 1 lần/tháng để xác nhận
     backup còn hợp lệ và quy trình phục hồi hoạt động đúng.

   ============================================================
*/
