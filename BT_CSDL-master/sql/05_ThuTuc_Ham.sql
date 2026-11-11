USE QL_CAFE_NHAHANG;
GO
/* =====================================================================
   05_ThuTuc_Ham.sql — STORED PROCEDURE VÀ FUNCTION
   Đề tài 13: Nhà hàng / Quán cà phê
   CSDL: QL_CAFE_NHAHANG
   ===================================================================== */

-- ============================================================
--                  STORED PROCEDURE
-- ============================================================

-- ----------------------------------------------------------------
-- SP01: sp_GoiMon
-- Mô tả: Gọi thêm món vào hóa đơn đang mở.
--        Kiểm tra HĐ tồn tại và 'Mở', món đang bán, nguyên liệu đủ.
--        Nếu thiếu bất kỳ NL → rollback toàn bộ, không ghi gì.
--        Nếu đủ: INSERT/UPDATE ChiTietHoaDon, trừ TonKho, cập nhật TongTien.
-- ----------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_GoiMon
    @MaHD    INT,
    @MaMon   INT,
    @SoLuong INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Kiểm tra hóa đơn tồn tại và đang 'Mở'
        IF NOT EXISTS (
            SELECT 1 FROM HoaDon WHERE MaHD = @MaHD AND TrangThai = N'Mở'
        )
        BEGIN
            THROW 50001, N'Hóa đơn không tồn tại hoặc không ở trạng thái Mở.', 1;
        END

        -- 2. Kiểm tra món đang bán
        IF NOT EXISTS (
            SELECT 1 FROM Mon WHERE MaMon = @MaMon AND DangBan = 1
        )
        BEGIN
            THROW 50002, N'Món không tồn tại hoặc hiện không được bán.', 1;
        END

        -- 3. Kiểm tra nguyên liệu đủ cho SoLuong phần
        --    Nếu bất kỳ NL nào có TonKho - SoLuong*DinhLuong.SoLuong < 0 → báo lỗi
        IF EXISTS (
            SELECT 1
            FROM   DinhLuong   dl
            JOIN   NguyenLieu  nl ON nl.MaNL = dl.MaNL
            WHERE  dl.MaMon = @MaMon
              AND  nl.TonKho - dl.SoLuong * @SoLuong < 0
        )
        BEGIN
            THROW 50003, N'Không đủ nguyên liệu để chế biến số lượng yêu cầu.', 1;
        END

        -- 4. INSERT hoặc UPDATE ChiTietHoaDon và trừ kho
        IF EXISTS (
            SELECT 1 FROM ChiTietHoaDon
            WHERE MaHD = @MaHD AND MaMon = @MaMon
        )
        BEGIN
            UPDATE ChiTietHoaDon
            SET    SoLuong = SoLuong + @SoLuong
            WHERE  MaHD = @MaHD AND MaMon = @MaMon;

            -- Khi UPDATE, trigger TR01 (chỉ AFTER INSERT) không kích hoạt
            -- nên thủ tục tự trừ TonKho cho phần gọi thêm
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

            -- Nếu trigger TR01 (AFTER INSERT) chưa tạo hoặc bị disable,
            -- thủ tục sẽ tự trừ TonKho để đảm bảo tính toàn vẹn (tránh trừ 2 lần)
            IF OBJECT_ID(N'dbo.trg_ChiTietHoaDon_KiemTraNguyenLieu', N'TR') IS NULL
               OR OBJECTPROPERTY(OBJECT_ID(N'dbo.trg_ChiTietHoaDon_KiemTraNguyenLieu'), 'ExecIsTriggerDisabled') = 1
            BEGIN
                UPDATE nl
                SET    nl.TonKho = nl.TonKho - dl.SoLuong * @SoLuong
                FROM   NguyenLieu nl
                JOIN   DinhLuong  dl ON dl.MaNL = nl.MaNL
                WHERE  dl.MaMon = @MaMon;
            END
        END

        -- 5. Cập nhật TongTien hóa đơn
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
        THROW; -- ném lại lỗi để caller biết
    END CATCH
END
GO

-- ✅ Ca đúng sp_GoiMon:
--    Giả sử MaHD=1 đang 'Mở', MaMon=1 đang bán, kho đủ NL
-- EXEC sp_GoiMon @MaHD=1, @MaMon=1, @SoLuong=2;

-- ❌ Ca sai 1 — HĐ không tồn tại (phải báo lỗi 50001):
-- EXEC sp_GoiMon @MaHD=99999, @MaMon=1, @SoLuong=1;

-- ❌ Ca sai 2 — Món không đang bán (phải báo lỗi 50002):
-- EXEC sp_GoiMon @MaHD=1, @MaMon=99999, @SoLuong=1;

-- ❌ Ca sai 3 — Kho không đủ nguyên liệu (phải báo lỗi 50003):
-- EXEC sp_GoiMon @MaHD=1, @MaMon=1, @SoLuong=99999;
GO

-- ----------------------------------------------------------------
-- SP02: sp_ThanhToan
-- Mô tả: Thanh toán hóa đơn.
--        Kiểm tra HĐ 'Mở' và có ít nhất 1 chi tiết.
--        Cập nhật TrangThai HĐ → 'Đã thanh toán', Ban → 'Trống'.
--        OUTPUT: TongTien thực tế của hóa đơn.
-- ----------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_ThanhToan
    @MaHD              INT,
    @TongTienThucThu   DECIMAL(14,0) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Kiểm tra HĐ 'Mở'
        IF NOT EXISTS (
            SELECT 1 FROM HoaDon WHERE MaHD = @MaHD AND TrangThai = N'Mở'
        )
        BEGIN
            THROW 50010, N'Hóa đơn không tồn tại hoặc không ở trạng thái Mở.', 1;
        END

        -- 2. Kiểm tra có ít nhất 1 chi tiết
        IF NOT EXISTS (
            SELECT 1 FROM ChiTietHoaDon WHERE MaHD = @MaHD
        )
        BEGIN
            THROW 50011, N'Hóa đơn chưa có món nào, không thể thanh toán.', 1;
        END

        -- 3. Lấy TongTien thực tế (OUTPUT)
        SELECT @TongTienThucThu = TongTien
        FROM   HoaDon
        WHERE  MaHD = @MaHD;

        -- 4. Cập nhật TrangThai HĐ → 'Đã thanh toán'
        --    Trigger TR02 (trg_HoaDon_CapNhatBan) sẽ tự động cập nhật
        --    Ban.TrangThai → 'Trống' khi TrangThai HĐ đổi sang 'Đã thanh toán'.
        --    Nếu trigger chưa tạo hoặc bị disable, cập nhật Ban thủ công.
        UPDATE HoaDon
        SET    TrangThai = N'Đã thanh toán'
        WHERE  MaHD = @MaHD;

        -- 5. Đảm bảo bàn về 'Trống' nếu trigger TR02 chưa hoạt động
        IF OBJECT_ID(N'dbo.trg_HoaDon_CapNhatBan', N'TR') IS NULL
           OR OBJECTPROPERTY(OBJECT_ID(N'dbo.trg_HoaDon_CapNhatBan'), 'ExecIsTriggerDisabled') = 1
        BEGIN
            UPDATE Ban
            SET    TrangThai = N'Trống'
            WHERE  MaBan = (SELECT MaBan FROM HoaDon WHERE MaHD = @MaHD);
        END

        COMMIT TRANSACTION;
        PRINT N'[sp_ThanhToan] Thanh toán thành công. MaHD=' + CAST(@MaHD AS NVARCHAR)
            + N', TongTien=' + CAST(@TongTienThucThu AS NVARCHAR);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- ✅ Ca đúng sp_ThanhToan:
-- DECLARE @Tien DECIMAL(14,0);
-- EXEC sp_ThanhToan @MaHD=1, @TongTienThucThu=@Tien OUTPUT;
-- SELECT N'Tổng tiền thực thu:' AS [Label], @Tien AS [TongTien];

-- ❌ Ca sai 1 — HĐ không ở trạng thái Mở (phải báo lỗi 50010):
-- DECLARE @Tien DECIMAL(14,0);
-- EXEC sp_ThanhToan @MaHD=99999, @TongTienThucThu=@Tien OUTPUT;

-- ❌ Ca sai 2 — HĐ chưa có món (phải báo lỗi 50011):
--    (giả sử HĐ mã 2 đang 'Mở' nhưng chưa có ChiTietHoaDon)
-- DECLARE @Tien DECIMAL(14,0);
-- EXEC sp_ThanhToan @MaHD=2, @TongTienThucThu=@Tien OUTPUT;
GO

-- ----------------------------------------------------------------
-- SP03: sp_MoHoaDon
-- Mô tả: Mở hóa đơn mới cho bàn.
--        Kiểm tra bàn tồn tại, NV tồn tại và là 'PhucVu', bàn 'Trống'.
--        INSERT HoaDon, cập nhật Ban → 'Có khách'.
--        OUTPUT: @MaHD mới tạo.
-- ----------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_MoHoaDon
    @MaBan  INT,
    @MaNV   INT,
    @MaHD   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Kiểm tra bàn tồn tại
        IF NOT EXISTS (SELECT 1 FROM Ban WHERE MaBan = @MaBan)
        BEGIN
            THROW 50020, N'Bàn không tồn tại.', 1;
        END

        -- 2. Kiểm tra nhân viên tồn tại và là Phục vụ
        IF NOT EXISTS (
            SELECT 1 FROM NhanVien
            WHERE MaNV = @MaNV AND ChucVu = N'PhucVu'
        )
        BEGIN
            THROW 50021, N'Nhân viên không tồn tại hoặc không có chức vụ Phục vụ.', 1;
        END

        -- 3. Kiểm tra bàn 'Trống'
        DECLARE @TrangThaiBan NVARCHAR(20);
        SELECT @TrangThaiBan = TrangThai FROM Ban WHERE MaBan = @MaBan;

        IF @TrangThaiBan <> N'Trống'
        BEGIN
            THROW 50022, N'Bàn hiện không ở trạng thái Trống, không thể mở hóa đơn mới.', 1;
        END

        -- 4. INSERT HoaDon mới
        INSERT INTO HoaDon (MaBan, MaNV, NgayLap, TrangThai, TongTien)
        VALUES (@MaBan, @MaNV, GETDATE(), N'Mở', 0);

        SET @MaHD = SCOPE_IDENTITY();

        -- 5. Cập nhật trạng thái bàn → 'Có khách'
        UPDATE Ban
        SET    TrangThai = N'Có khách'
        WHERE  MaBan = @MaBan;

        COMMIT TRANSACTION;
        PRINT N'[sp_MoHoaDon] Mở hóa đơn thành công. MaHD=' + CAST(@MaHD AS NVARCHAR)
            + N', MaBan=' + CAST(@MaBan AS NVARCHAR);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- ✅ Ca đúng sp_MoHoaDon:
-- DECLARE @NewHD INT;
-- EXEC sp_MoHoaDon @MaBan=1, @MaNV=1, @MaHD=@NewHD OUTPUT;
-- SELECT N'MaHD mới:' AS [Label], @NewHD AS [MaHD];

-- ❌ Ca sai 1 — Bàn không tồn tại (phải báo lỗi 50020):
-- DECLARE @NewHD INT;
-- EXEC sp_MoHoaDon @MaBan=99999, @MaNV=1, @MaHD=@NewHD OUTPUT;

-- ❌ Ca sai 2 — NV không phải PhucVu (phải báo lỗi 50021):
-- DECLARE @NewHD INT;
-- EXEC sp_MoHoaDon @MaBan=1, @MaNV=99, @MaHD=@NewHD OUTPUT;

-- ❌ Ca sai 3 — Bàn đang 'Có khách' (phải báo lỗi 50022):
--    (sau khi đã mở HĐ cho bàn 1 ở ca đúng bên trên)
-- DECLARE @NewHD INT;
-- EXEC sp_MoHoaDon @MaBan=1, @MaNV=1, @MaHD=@NewHD OUTPUT;
GO

-- ----------------------------------------------------------------
-- SP04: sp_HuyHoaDon
-- Mô tả: Hủy hóa đơn — trả lại nguyên liệu cho từng ChiTietHoaDon.
--        Dùng CURSOR để duyệt từng dòng chi tiết → cộng lại TonKho.
--        Cập nhật TrangThai HĐ → 'Hủy', Ban → 'Trống'.
-- ----------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_HuyHoaDon
    @MaHD INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Kiểm tra HĐ tồn tại và đang 'Mở'
        IF NOT EXISTS (
            SELECT 1 FROM HoaDon WHERE MaHD = @MaHD AND TrangThai = N'Mở'
        )
        BEGIN
            THROW 50030, N'Hóa đơn không tồn tại hoặc không ở trạng thái Mở, không thể hủy.', 1;
        END

        -- 2. Dùng CURSOR duyệt từng ChiTietHoaDon → cộng lại nguyên liệu
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
            -- Cộng lại TonKho cho từng nguyên liệu của món này
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

        -- 3. Cập nhật TrangThai HĐ → 'Hủy'
        --    Trigger TR02 (trg_HoaDon_CapNhatBan) sẽ tự động cập nhật
        --    Ban.TrangThai → 'Trống' khi TrangThai HĐ đổi sang 'Hủy'.
        UPDATE HoaDon
        SET    TrangThai = N'Hủy'
        WHERE  MaHD = @MaHD;

        -- 4. Đảm bảo bàn về 'Trống' nếu trigger TR02 chưa hoạt động
        IF OBJECT_ID(N'dbo.trg_HoaDon_CapNhatBan', N'TR') IS NULL
           OR OBJECTPROPERTY(OBJECT_ID(N'dbo.trg_HoaDon_CapNhatBan'), 'ExecIsTriggerDisabled') = 1
        BEGIN
            UPDATE Ban
            SET    TrangThai = N'Trống'
            WHERE  MaBan = (SELECT MaBan FROM HoaDon WHERE MaHD = @MaHD);
        END

        COMMIT TRANSACTION;
        PRINT N'[sp_HuyHoaDon] Hủy hóa đơn thành công. MaHD=' + CAST(@MaHD AS NVARCHAR);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        -- Đóng CURSOR nếu còn mở (tránh resource leak)
        IF CURSOR_STATUS('local', 'cur_ChiTiet') >= 0
        BEGIN
            CLOSE cur_ChiTiet;
            DEALLOCATE cur_ChiTiet;
        END
        THROW;
    END CATCH
END
GO

-- ✅ Ca đúng sp_HuyHoaDon:
--    Giả sử MaHD=3 đang 'Mở'
-- EXEC sp_HuyHoaDon @MaHD=3;
-- SELECT TrangThai FROM HoaDon WHERE MaHD=3; -- Kết quả: 'Hủy'

-- ❌ Ca sai 1 — HĐ không tồn tại (phải báo lỗi 50030):
-- EXEC sp_HuyHoaDon @MaHD=99999;

-- ❌ Ca sai 2 — HĐ đã 'Đã thanh toán' (phải báo lỗi 50030):
-- EXEC sp_HuyHoaDon @MaHD=1; -- (sau khi sp_ThanhToan đã chạy)
GO

-- ----------------------------------------------------------------
-- SP05: sp_ThongKeDoanhThu
-- Mô tả: Thống kê doanh thu theo tháng trong năm @Nam,
--        từ @ThangBatDau đến @ThangKetThuc.
--        Chỉ tính HĐ 'Đã thanh toán'.
--        Trả về: Thang, TongHoaDon, TongMon, DoanhThu
-- ----------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_ThongKeDoanhThu
    @Nam          INT,
    @ThangBatDau  INT = 1,
    @ThangKetThuc INT = 12
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra khoảng tháng hợp lệ
    IF @ThangBatDau > @ThangKetThuc
    BEGIN
        THROW 50040, N'ThangBatDau phải nhỏ hơn hoặc bằng ThangKetThuc.', 1;
    END

    IF @ThangBatDau < 1 OR @ThangKetThuc > 12
    BEGIN
        THROW 50041, N'Tháng phải nằm trong khoảng 1 đến 12.', 1;
    END

    -- Thống kê doanh thu từng tháng
    SELECT
        MONTH(hd.NgayLap)            AS Thang,
        COUNT(DISTINCT hd.MaHD)      AS TongHoaDon,
        SUM(ct.SoLuong)              AS TongMon,
        SUM(ct.SoLuong * ct.DonGia)  AS DoanhThu
    FROM   HoaDon         hd
    JOIN   ChiTietHoaDon  ct ON ct.MaHD  = hd.MaHD
    WHERE  hd.TrangThai = N'Đã thanh toán'
      AND  YEAR(hd.NgayLap)  = @Nam
      AND  MONTH(hd.NgayLap) BETWEEN @ThangBatDau AND @ThangKetThuc
    GROUP BY MONTH(hd.NgayLap)
    ORDER BY Thang;
END
GO

-- ✅ Ca đúng sp_ThongKeDoanhThu — cả năm 2024:
-- EXEC sp_ThongKeDoanhThu @Nam=2024;

-- ✅ Ca đúng sp_ThongKeDoanhThu — quý 1 năm 2024:
-- EXEC sp_ThongKeDoanhThu @Nam=2024, @ThangBatDau=1, @ThangKetThuc=3;

-- ❌ Ca sai — ThangBatDau > ThangKetThuc (phải báo lỗi 50040):
-- EXEC sp_ThongKeDoanhThu @Nam=2024, @ThangBatDau=6, @ThangKetThuc=3;

-- ❌ Ca sai — Tháng ngoài khoảng [1,12] (phải báo lỗi 50041):
-- EXEC sp_ThongKeDoanhThu @Nam=2024, @ThangBatDau=0, @ThangKetThuc=13;
GO


-- ============================================================
--                  FUNCTION
-- ============================================================

-- ----------------------------------------------------------------
-- FN01: fn_GiaVonMon
-- Loại: Hàm vô hướng (Scalar Function)
-- Mô tả: Tính giá vốn của một món = SUM(DinhLuong.SoLuong * NguyenLieu.DonGiaNhap)
--        Nếu không có định lượng → trả về 0.
-- ----------------------------------------------------------------
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

-- ✅ Ca đúng fn_GiaVonMon — món có định lượng:
-- SELECT dbo.fn_GiaVonMon(1) AS GiaVon;

-- ✅ Ca đúng fn_GiaVonMon — món không có định lượng (kết quả = 0):
-- SELECT dbo.fn_GiaVonMon(99999) AS GiaVon; -- Mong đợi: 0.00

-- (Hàm scalar không ném lỗi, giá trị không hợp lệ trả về 0)
GO

-- ----------------------------------------------------------------
-- FN02: fn_NguyenLieuDuoiDinhMuc
-- Loại: Hàm bảng inline (Inline TVF)
-- Mô tả: Trả về các nguyên liệu có TonKho <= DinhMucTon * (@PhanTramNguong / 100)
--        Columns: MaNL, TenNL, DonViTinh, TonKho, DinhMucTon, TyLeTonKho(%)
-- ----------------------------------------------------------------
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

-- ✅ Ca đúng fn_NguyenLieuDuoiDinhMuc — NL còn <= 100% định mức (tất cả dưới/bằng định mức):
-- SELECT * FROM dbo.fn_NguyenLieuDuoiDinhMuc(100.0) ORDER BY [TyLeTonKho(%)];

-- ✅ Ca đúng fn_NguyenLieuDuoiDinhMuc — NL còn <= 50% định mức (cảnh báo khẩn):
-- SELECT * FROM dbo.fn_NguyenLieuDuoiDinhMuc(50.0) ORDER BY [TyLeTonKho(%)];

-- ✅ Ca đúng fn_NguyenLieuDuoiDinhMuc — dùng ngưỡng mặc định:
-- SELECT * FROM dbo.fn_NguyenLieuDuoiDinhMuc(DEFAULT);
GO

-- ----------------------------------------------------------------
-- FN03: fn_DanhSachMonTheoLoai
-- Loại: Hàm bảng nhiều câu lệnh (Multi-statement TVF)
-- Mô tả: Trả danh sách món theo loại.
--        @BaoGomConChau = 0: chỉ lấy mon thuộc loại trực tiếp.
--        @BaoGomConChau = 1: lấy mon thuộc loại đó và tất cả loại con cháu (CTE đệ quy).
--        Columns: MaMon, TenMon, GiaBan, TenLoai, Nhom, DangBan
-- ----------------------------------------------------------------
CREATE OR ALTER FUNCTION fn_DanhSachMonTheoLoai
(
    @MaLoai         INT,
    @BaoGomConChau  BIT = 0
)
RETURNS @KetQua TABLE
(
    MaMon   INT,
    TenMon  NVARCHAR(100),
    GiaBan  DECIMAL(12,0),
    TenLoai NVARCHAR(100),
    Nhom    CHAR(1),
    DangBan BIT
)
AS
BEGIN
    IF @BaoGomConChau = 0
    BEGIN
        -- Chỉ lấy mon thuộc loại trực tiếp
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
        -- Lấy mon thuộc loại đó VÀ tất cả loại con cháu (CTE đệ quy)
        ;WITH CTE_Loai AS
        (
            -- Neo: loại gốc được chọn
            SELECT MaLoai, TenLoai
            FROM   LoaiMon
            WHERE  MaLoai = @MaLoai

            UNION ALL

            -- Đệ quy: lấy các loại con
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

-- ✅ Ca đúng fn_DanhSachMonTheoLoai — chỉ loại trực tiếp (@MaLoai=1, không lấy con):
-- SELECT * FROM dbo.fn_DanhSachMonTheoLoai(1, 0) ORDER BY TenMon;

-- ✅ Ca đúng fn_DanhSachMonTheoLoai — loại đó và tất cả con cháu (@MaLoai=1, lấy cả cây):
-- SELECT * FROM dbo.fn_DanhSachMonTheoLoai(1, 1) ORDER BY TenLoai, TenMon;

-- ✅ Ca đúng fn_DanhSachMonTheoLoai — loại không tồn tại (kết quả rỗng, không lỗi):
-- SELECT * FROM dbo.fn_DanhSachMonTheoLoai(99999, 1); -- Mong đợi: 0 dòng
GO
