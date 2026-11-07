USE QL_CAFE_NHAHANG;
GO
/* =====================================================================
   06_Trigger_GiaoTac.sql — TRIGGER VÀ GIAO TÁC
   Đề tài 13: Nhà hàng / Quán cà phê
   CSDL: QL_CAFE_NHAHANG
   ===================================================================== */

-- ============================================================
--                        TRIGGER
-- ============================================================

-- ============================================================
-- TR01: trg_ChiTietHoaDon_KiemTraNguyenLieu
-- Mục đích:
--   AFTER INSERT on ChiTietHoaDon.
--   1. Kiểm tra TonKho đủ cho TỪNG nguyên liệu của MỌI món vừa insert.
--      Dùng bảng virtual `inserted` JOIN DinhLuong JOIN NguyenLieu
--      để xử lý multi-row (không dùng vòng lặp CURSOR).
--   2. Nếu BẤT KỲ nguyên liệu nào không đủ → ROLLBACK + ném lỗi
--      kèm tên nguyên liệu thiếu hụt.
--   3. Nếu tất cả đủ → UPDATE NguyenLieu.TonKho trừ đi
--      SUM(DinhLuong.SoLuong * ChiTiet.SoLuong) cho từng nguyên liệu.
-- ============================================================
CREATE OR ALTER TRIGGER trg_ChiTietHoaDon_KiemTraNguyenLieu
ON ChiTietHoaDon
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- ----------------------------------------------------------------
    -- Bước 1 + 2: Tính nhu cầu và tìm nguyên liệu thiếu hụt.
    --   Dùng bảng virtual `inserted` JOIN DinhLuong → tổng SoLuongCan
    --   cho từng nguyên liệu, so sánh với NguyenLieu.TonKho.
    --   Xử lý multi-row: GROUP BY dl.MaNL tổng hợp tất cả dòng INSERT.
    -- ----------------------------------------------------------------
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

    -- ----------------------------------------------------------------
    -- Bước 3: Nếu có nguyên liệu thiếu → THROW (trigger tự ROLLBACK)
    -- ----------------------------------------------------------------
    IF @DsThieu IS NOT NULL
    BEGIN
        DECLARE @Msg NVARCHAR(2000) =
            N'Không đủ nguyên liệu: ' + @DsThieu;
        THROW 50001, @Msg, 1;
    END;

    -- ----------------------------------------------------------------
    -- Bước 4: Đủ nguyên liệu → trừ tồn kho (UPDATE set-based)
    -- ----------------------------------------------------------------
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

-- ============================================================
-- ✅ Ca đúng TR01 — đủ nguyên liệu
-- ============================================================
/*
-- Giả sử HoaDon MaHD=1 đang 'Mở', Mon MaMon=1 cần NguyenLieu đủ tồn.

-- Xem trạng thái trước
SELECT nl.MaNL, nl.TenNL, nl.TonKho
FROM NguyenLieu nl
JOIN DinhLuong dl ON dl.MaNL = nl.MaNL
WHERE dl.MaMon = 1;

SELECT * FROM ChiTietHoaDon WHERE MaHD = 1;

-- Thực hiện INSERT hợp lệ
INSERT INTO ChiTietHoaDon(MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
VALUES (1, 1, 2, 50000, N'Chờ');

-- Xem trạng thái sau → TonKho giảm, dòng ChiTiet thêm thành công
SELECT nl.MaNL, nl.TenNL, nl.TonKho
FROM NguyenLieu nl
JOIN DinhLuong dl ON dl.MaNL = nl.MaNL
WHERE dl.MaMon = 1;

SELECT * FROM ChiTietHoaDon WHERE MaHD = 1;
*/

-- ============================================================
-- ❌ Ca sai TR01 — thiếu nguyên liệu
-- ============================================================
/*
-- Cập nhật TonKho về 0 để giả lập thiếu hụt
UPDATE NguyenLieu SET TonKho = 0
WHERE MaNL IN (SELECT MaNL FROM DinhLuong WHERE MaMon = 1);

-- Thực hiện INSERT → trigger bắt lỗi, ROLLBACK
INSERT INTO ChiTietHoaDon(MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
VALUES (1, 1, 1, 50000, N'Chờ');
-- Expected: Msg 50001 — "Không đủ nguyên liệu: ..."
-- ChiTietHoaDon không thêm dòng mới, TonKho không đổi
*/


-- ============================================================
-- TR02: trg_HoaDon_CapNhatBan
-- Mục đích:
--   AFTER UPDATE on HoaDon.
--   Theo dõi thay đổi TrangThai giữa `deleted` (cũ) và `inserted` (mới).
--   - TrangThai → 'Đã thanh toán' hoặc 'Hủy' : set Ban.TrangThai = 'Trống'
--   - TrangThai → 'Mở'                        : set Ban.TrangThai = 'Có khách'
--   Chỉ xử lý những hóa đơn thực sự đổi TrangThai (deleted <> inserted).
--   Hỗ trợ UPDATE nhiều dòng (JOIN bảng virtual inserted/deleted).
-- ============================================================
CREATE OR ALTER TRIGGER trg_HoaDon_CapNhatBan
ON HoaDon
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Chỉ quan tâm khi cột TrangThai bị cập nhật
    IF NOT UPDATE(TrangThai) RETURN;

    -- ----------------------------------------------------------------
    -- Cập nhật Ban.TrangThai dựa trên TrangThai mới của HoaDon.
    -- Điều kiện: TrangThai thực sự thay đổi (d.TrangThai <> i.TrangThai)
    -- ----------------------------------------------------------------
    UPDATE b
    SET    b.TrangThai =
               CASE i.TrangThai
                   WHEN N'Đã thanh toán' THEN N'Trống'
                   WHEN N'Hủy'           THEN N'Trống'
                   WHEN N'Mở'            THEN N'Có khách'
                   ELSE b.TrangThai          -- trạng thái không xác định → giữ nguyên
               END
    FROM   Ban      AS b
    JOIN   inserted AS i  ON i.MaBan = b.MaBan
    JOIN   deleted  AS d  ON d.MaHD  = i.MaHD
    WHERE  d.TrangThai <> i.TrangThai   -- chỉ khi thực sự thay đổi
    AND    i.TrangThai IN (N'Đã thanh toán', N'Hủy', N'Mở');

END;
GO

-- ============================================================
-- ✅ Ca đúng TR02 — thanh toán hóa đơn → bàn thành 'Trống'
-- ============================================================
/*
-- Trước
SELECT hd.MaHD, hd.TrangThai AS TT_HD, b.MaBan, b.TrangThai AS TT_Ban
FROM HoaDon hd JOIN Ban b ON b.MaBan = hd.MaBan
WHERE hd.MaHD = 1;

-- Thanh toán
UPDATE HoaDon SET TrangThai = N'Đã thanh toán' WHERE MaHD = 1;

-- Sau → Ban phải là 'Trống'
SELECT hd.MaHD, hd.TrangThai AS TT_HD, b.MaBan, b.TrangThai AS TT_Ban
FROM HoaDon hd JOIN Ban b ON b.MaBan = hd.MaBan
WHERE hd.MaHD = 1;
*/

-- ============================================================
-- ❌ Ca sai TR02 — không thay đổi TrangThai → trigger không làm gì
-- ============================================================
/*
-- UPDATE không đổi TrangThai → trigger nhận biết và bỏ qua
UPDATE HoaDon SET TrangThai = N'Đã thanh toán' WHERE MaHD = 1;
-- (HoaDon đã 'Đã thanh toán', update lại cùng giá trị)
-- Expected: Ban.TrangThai không đổi (deleted.TrangThai = inserted.TrangThai)
*/


-- ============================================================
-- TR03: trg_Mon_KiemTraXoa
-- Mục đích:
--   INSTEAD OF DELETE on Mon.
--   Thay vì xóa vật lý:
--   1. Kiểm tra xem món bị xóa có đang được tham chiếu trong HoaDon 'Mở' không.
--      Nếu có → ném lỗi, không xóa/ẩn.
--   2. Nếu không có HĐ Mở → set DangBan = 0 (xóa mềm / ẩn món).
--   3. PRINT thông báo danh sách các món bị ẩn.
-- ============================================================
CREATE OR ALTER TRIGGER trg_Mon_KiemTraXoa
ON Mon
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- ----------------------------------------------------------------
    -- Bước 1: Tìm món đang được dùng trong HoaDon 'Mở'
    -- ----------------------------------------------------------------
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

    -- ----------------------------------------------------------------
    -- Bước 2: Xóa mềm — set DangBan = 0 cho các món hợp lệ
    -- ----------------------------------------------------------------
    UPDATE m
    SET    m.DangBan = 0
    FROM   Mon     AS m
    JOIN   deleted AS d ON d.MaMon = m.MaMon;

    -- ----------------------------------------------------------------
    -- Bước 3: PRINT danh sách các món vừa bị ẩn
    -- ----------------------------------------------------------------
    DECLARE @DsMonAn NVARCHAR(MAX);

    SELECT @DsMonAn = STRING_AGG(
               CONCAT(d.MaMon, ' - ', m.TenMon),
               ', ')
    FROM   deleted AS d
    JOIN   Mon     AS m ON m.MaMon = d.MaMon;

    PRINT N'[TR03] Đã ẩn (DangBan=0) các món: ' + ISNULL(@DsMonAn, N'(không có)');

END;
GO

-- ============================================================
-- ✅ Ca đúng TR03 — món không có HĐ Mở → ẩn thành công
-- ============================================================
/*
-- Giả sử Mon MaMon=99 không có trong HoaDon nào đang 'Mở'
INSERT INTO Mon(MaMon, TenMon, MaLoai, GiaBan, Nhom, DangBan)
VALUES (99, N'Món Test', 1, 10000, N'Mon an', 1);

SELECT MaMon, TenMon, DangBan FROM Mon WHERE MaMon = 99;

DELETE FROM Mon WHERE MaMon = 99;
-- Expected: DangBan = 0, không xóa vật lý, PRINT thông báo

SELECT MaMon, TenMon, DangBan FROM Mon WHERE MaMon = 99;
-- DangBan = 0
*/

-- ============================================================
-- ❌ Ca sai TR03 — món đang trong HĐ 'Mở' → báo lỗi
-- ============================================================
/*
-- Giả sử MaMon=1 đang có trong ChiTietHoaDon của HoaDon MaHD=1 TrangThai='Mở'
DELETE FROM Mon WHERE MaMon = 1;
-- Expected: Msg 50002 — "Không thể ẩn/xóa món đang có trong hóa đơn đang mở: ..."
-- DangBan của MaMon=1 không đổi
*/


-- ============================================================
--                      GIAO TÁC
-- ============================================================

-- ============================================================
-- GT01: Giao tác gọi món — thành công và thất bại
-- Kịch bản:
--   Gọi 2 món cho hóa đơn đang 'Mở'.
--   - Kịch bản A (thành công): cả 2 món đủ nguyên liệu → COMMIT
--   - Kịch bản B (thất bại):  món thứ 2 thiếu nguyên liệu → ROLLBACK
--     toàn bộ (kể cả món 1 đã insert thành công trước đó)
-- ============================================================

-- ============================================================
-- GT01-A: THÀNH CÔNG — cả 2 món đủ nguyên liệu
-- ============================================================
PRINT N'';
PRINT N'=== GT01-A: Gọi 2 món — THÀNH CÔNG ===';

-- Trạng thái trước
PRINT N'--- Trước giao tác ---';
SELECT nl.MaNL, nl.TenNL, nl.TonKho
FROM   NguyenLieu nl
WHERE  nl.MaNL IN (
           SELECT dl.MaNL FROM DinhLuong dl WHERE dl.MaMon IN (1, 2)
       );
SELECT * FROM ChiTietHoaDon WHERE MaHD = 1;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Gọi món 1
    INSERT INTO ChiTietHoaDon(MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
    VALUES (1, 1, 1, 50000, N'Chờ');

    -- Gọi món 2
    INSERT INTO ChiTietHoaDon(MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
    VALUES (1, 2, 2, 35000, N'Chờ');

    COMMIT TRANSACTION;
    PRINT N'[GT01-A] COMMIT thành công — 2 món đã được ghi nhận.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'[GT01-A] LỖI: ' + ERROR_MESSAGE();
END CATCH;

-- Trạng thái sau
PRINT N'--- Sau giao tác (GT01-A) ---';
SELECT nl.MaNL, nl.TenNL, nl.TonKho
FROM   NguyenLieu nl
WHERE  nl.MaNL IN (
           SELECT dl.MaNL FROM DinhLuong dl WHERE dl.MaMon IN (1, 2)
       );
SELECT * FROM ChiTietHoaDon WHERE MaHD = 1;
GO

-- ============================================================
-- GT01-B: THẤT BẠI — món thứ 2 thiếu nguyên liệu → ROLLBACK toàn bộ
-- ============================================================
PRINT N'';
PRINT N'=== GT01-B: Gọi 2 món — THẤT BẠI (thiếu NL ở món 2) ===';

-- Giả lập thiếu nguyên liệu cho món 2
UPDATE NguyenLieu
SET    TonKho = 0
WHERE  MaNL IN (SELECT MaNL FROM DinhLuong WHERE MaMon = 2);

-- Trạng thái trước
PRINT N'--- Trước giao tác ---';
SELECT nl.MaNL, nl.TenNL, nl.TonKho
FROM   NguyenLieu nl
WHERE  nl.MaNL IN (
           SELECT dl.MaNL FROM DinhLuong dl WHERE dl.MaMon IN (1, 2)
       );
SELECT COUNT(*) AS SoDongChiTiet FROM ChiTietHoaDon WHERE MaHD = 1;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Gọi món 1 — sẽ thành công
    INSERT INTO ChiTietHoaDon(MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
    VALUES (1, 1, 1, 50000, N'Chờ');

    PRINT N'[GT01-B] Món 1 insert xong (chưa commit).';

    -- Gọi món 2 — trigger sẽ THROW lỗi
    INSERT INTO ChiTietHoaDon(MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
    VALUES (1, 2, 2, 35000, N'Chờ');

    COMMIT TRANSACTION;
    PRINT N'[GT01-B] COMMIT — (không nên đến đây).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'[GT01-B] ROLLBACK — Lỗi: ' + ERROR_MESSAGE();
END CATCH;

-- Trạng thái sau: TonKho và ChiTietHoaDon phải về trạng thái ban đầu
PRINT N'--- Sau ROLLBACK (GT01-B) — kỳ vọng: TonKho không đổi, không có dòng ChiTiet mới ---';
SELECT nl.MaNL, nl.TenNL, nl.TonKho
FROM   NguyenLieu nl
WHERE  nl.MaNL IN (
           SELECT dl.MaNL FROM DinhLuong dl WHERE dl.MaMon IN (1, 2)
       );
SELECT COUNT(*) AS SoDongChiTiet FROM ChiTietHoaDon WHERE MaHD = 1;
GO


-- ============================================================
-- GT02: Giao tác thanh toán và chuyển trạng thái
-- Kịch bản:
--   Thanh toán hóa đơn đang 'Mở'.
--   - Thành công: HoaDon.TrangThai = 'Đã thanh toán',
--                 Ban.TrangThai = 'Trống' (do trigger TR02) → COMMIT
--   - Thất bại giả lập: điều kiện sai (HĐ đã hủy trước đó) → ROLLBACK TO SAVEPOINT
-- Dùng: BEGIN TRAN, SAVE TRANSACTION, ROLLBACK TRANSACTION <savepoint>,
--        TRY...CATCH
-- ============================================================

PRINT N'';
PRINT N'=== GT02-A: Thanh toán HĐ — THÀNH CÔNG ===';

-- Trạng thái trước
PRINT N'--- Trước giao tác ---';
SELECT hd.MaHD, hd.TrangThai AS TT_HD, b.MaBan, b.TrangThai AS TT_Ban
FROM   HoaDon hd
JOIN   Ban    b  ON b.MaBan = hd.MaBan
WHERE  hd.MaHD = 1;

BEGIN TRY
    BEGIN TRANSACTION GT02;

        -- SAVEPOINT trước khi thực hiện thao tác
        SAVE TRANSACTION sp_ThanhToan;

        -- Thanh toán hóa đơn đang 'Mở'
        UPDATE HoaDon
        SET    TrangThai = N'Đã thanh toán'
        WHERE  MaHD      = 1
        AND    TrangThai = N'Mở';    -- điều kiện đúng → ảnh hưởng 1 dòng

        IF @@ROWCOUNT = 0
        BEGIN
            -- HĐ không ở trạng thái 'Mở' → rollback về savepoint
            ROLLBACK TRANSACTION sp_ThanhToan;
            PRINT N'[GT02-A] Hóa đơn không ở trạng thái Mở — rollback về savepoint.';
            -- vẫn commit transaction rỗng (không có thao tác nào thực thi)
            COMMIT TRANSACTION GT02;
            RETURN;
        END;

    COMMIT TRANSACTION GT02;
    PRINT N'[GT02-A] COMMIT — Hóa đơn đã thanh toán, Bàn chuyển thành Trống.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'[GT02-A] LỖI: ' + ERROR_MESSAGE();
END CATCH;

-- Trạng thái sau
PRINT N'--- Sau giao tác (GT02-A) ---';
SELECT hd.MaHD, hd.TrangThai AS TT_HD, b.MaBan, b.TrangThai AS TT_Ban
FROM   HoaDon hd
JOIN   Ban    b  ON b.MaBan = hd.MaBan
WHERE  hd.MaHD = 1;
GO

-- ============================================================
-- GT02-B: THẤT BẠI GIẢ LẬP — HĐ đã 'Hủy' → không thanh toán được
-- ============================================================
PRINT N'';
PRINT N'=== GT02-B: Thanh toán HĐ đã Hủy — THẤT BẠI (ROLLBACK TO SAVEPOINT) ===';

-- Giả lập: đặt HoaDon MaHD=2 về 'Hủy'
UPDATE HoaDon SET TrangThai = N'Hủy' WHERE MaHD = 2;

-- Trạng thái trước
PRINT N'--- Trước giao tác ---';
SELECT hd.MaHD, hd.TrangThai AS TT_HD, b.MaBan, b.TrangThai AS TT_Ban
FROM   HoaDon hd
JOIN   Ban    b  ON b.MaBan = hd.MaBan
WHERE  hd.MaHD = 2;

BEGIN TRY
    BEGIN TRANSACTION GT02B;

        SAVE TRANSACTION sp_ThanhToan2;

        -- Thử thanh toán HĐ đã 'Hủy' → @@ROWCOUNT = 0 → không hợp lệ
        UPDATE HoaDon
        SET    TrangThai = N'Đã thanh toán'
        WHERE  MaHD      = 2
        AND    TrangThai = N'Mở';     -- điều kiện SAI vì HĐ đang 'Hủy'

        IF @@ROWCOUNT = 0
        BEGIN
            -- Không có dòng nào thay đổi → ném lỗi logic
            ;THROW 50003, N'Hóa đơn không ở trạng thái Mở, không thể thanh toán.', 1;
        END;

    COMMIT TRANSACTION GT02B;
    PRINT N'[GT02-B] COMMIT — (không nên đến đây).';
END TRY
BEGIN CATCH
    -- Rollback về savepoint nếu transaction còn mở và chưa bị abort
    IF @@TRANCOUNT > 0
    BEGIN
        IF XACT_STATE() = -1
        BEGIN
            -- Transaction bị doomed → phải ROLLBACK hoàn toàn
            ROLLBACK TRANSACTION;
            PRINT N'[GT02-B] Transaction bị abort — ROLLBACK hoàn toàn.';
        END
        ELSE
        BEGIN
            -- Rollback về savepoint (giữ transaction, có thể tiếp tục)
            ROLLBACK TRANSACTION sp_ThanhToan2;
            PRINT N'[GT02-B] ROLLBACK TO SAVEPOINT sp_ThanhToan2.';
            -- Có thể thực hiện thao tác khác ở đây nếu cần...
            COMMIT TRANSACTION GT02B;
        END;
    END;
    PRINT N'[GT02-B] LỖI: ' + ERROR_MESSAGE();
END CATCH;

-- Trạng thái sau: HoaDon vẫn 'Hủy', Ban không đổi
PRINT N'--- Sau ROLLBACK (GT02-B) — kỳ vọng: HĐ vẫn Hủy, Bàn không đổi ---';
SELECT hd.MaHD, hd.TrangThai AS TT_HD, b.MaBan, b.TrangThai AS TT_Ban
FROM   HoaDon hd
JOIN   Ban    b  ON b.MaBan = hd.MaBan
WHERE  hd.MaHD = 2;
GO

PRINT N'';
PRINT N'=== Hoàn tất 06_Trigger_GiaoTac.sql ===';
GO
