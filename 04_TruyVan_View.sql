-- 04_TruyVan_View.sql: Kiểm thử 10 ca vi phạm ràng buộc, 20 truy vấn T-SQL và 3 view.
USE QL_CAFE_NHAHANG;
GO

SET NOCOUNT ON;
GO

PRINT N'======================================================';
PRINT N'=== PHẦN 1: KIỂM THỬ RÀNG BUỘC (10 CA VI PHẠM)    ===';
PRINT N'======================================================';
GO

USE QL_CAFE_NHAHANG;
GO

SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon) OR NOT EXISTS (SELECT 1 FROM dbo.NhanVien)
    THROW 51001, N'Chưa có dữ liệu để kiểm chứng. Hãy chạy 03_DuLieu.sql trước.', 1;

DECLARE @ViPham TABLE
(
    LanThu    INT IDENTITY(1, 1) PRIMARY KEY,
    RangBuoc  NVARCHAR(30)  NOT NULL,
    TruongHop NVARCHAR(120) NOT NULL,
    MaLoi     INT           NOT NULL,
    KetQua    NVARCHAR(20)  NOT NULL,
    ThongDiep NVARCHAR(4000) NULL
);

DECLARE @SdtTrung VARCHAR(15);
DECLARE @MaHDTrung INT;
DECLARE @MaMonTrung INT;
DECLARE @DonGiaTrung DECIMAL(12, 0);
DECLARE @MaNVHopLe INT;
DECLARE @MaNLNhoNhat INT;

SELECT TOP (1) @SdtTrung = SoDienThoai
FROM dbo.NhanVien
WHERE SoDienThoai IS NOT NULL
ORDER BY MaNV;

SELECT TOP (1) @MaHDTrung = MaHD, @MaMonTrung = MaMon, @DonGiaTrung = DonGia
FROM dbo.ChiTietHoaDon
ORDER BY MaHD, MaMon;

SELECT TOP (1) @MaNVHopLe = MaNV FROM dbo.NhanVien ORDER BY MaNV;
SELECT @MaNLNhoNhat = MIN(MaNL) FROM dbo.NguyenLieu;

BEGIN TRANSACTION;

BEGIN TRY
    INSERT INTO dbo.NhanVien (HoTen, ChucVu) VALUES (NULL, N'Bep');
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'NOT NULL', N'Chèn nhân viên với HoTen = NULL', 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 515');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'NOT NULL', N'Chèn nhân viên với HoTen = NULL', ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Ban (TenBan, SucChua) VALUES (N'Bàn vi phạm 0 chỗ', 0);
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'CHECK', N'Chèn bàn có SucChua = 0', 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 547 (CK_Ban_SucChua)');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'CHECK', N'Chèn bàn có SucChua = 0', ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Ban (TenBan, SucChua, TrangThai)
    VALUES (N'Bàn VP3', 4, N'Bảo trì');
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'CHECK', N'Chèn bàn có TrangThai = N''Bảo trì'' (ngoài 3 giá trị)', 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 547 (CK_Ban_TrangThai)');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'CHECK', N'Chèn bàn có TrangThai = N''Bảo trì'' (ngoài 3 giá trị)', ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Ban (TenBan, SucChua) VALUES (N'Bàn 01', 4);
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'UNIQUE', N'Chèn bàn trùng TenBan = N''Bàn 01''', 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 2627 (UQ_Ban_Ten)');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'UNIQUE', N'Chèn bàn trùng TenBan = N''Bàn 01''', ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

BEGIN TRY
    INSERT INTO dbo.NhanVien (HoTen, ChucVu, SoDienThoai)
    VALUES (N'Nhân viên vi phạm SĐT', N'Bep', @SdtTrung);
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'UNIQUE (index)', CONCAT(N'Chèn nhân viên trùng SoDienThoai = ', @SdtTrung), 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 2601 (UX_NhanVien_SDT)');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'UNIQUE (index)', CONCAT(N'Chèn nhân viên trùng SoDienThoai = ', @SdtTrung), ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

BEGIN TRY
    INSERT INTO dbo.ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
    VALUES (@MaHDTrung, @MaMonTrung, 1, @DonGiaTrung, N'Chờ');
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'PRIMARY KEY', CONCAT(N'Chèn trùng cặp (MaHD, MaMon) = (', @MaHDTrung, N', ', @MaMonTrung, N')'), 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 2627 (PK_ChiTietHoaDon)');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'PRIMARY KEY', CONCAT(N'Chèn trùng cặp (MaHD, MaMon) = (', @MaHDTrung, N', ', @MaMonTrung, N')'), ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

BEGIN TRY
    INSERT INTO dbo.HoaDon (MaBan, MaNV, NgayLap, TrangThai, TongTien)
    VALUES (9999, @MaNVHopLe, GETDATE(), N'Mở', 0);
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'FOREIGN KEY', N'Chèn hóa đơn với MaBan = 9999 (không tồn tại)', 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 547 (FK_HoaDon_Ban)');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'FOREIGN KEY', N'Chèn hóa đơn với MaBan = 9999 (không tồn tại)', ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Mon (TenMon, MaLoai, GiaBan, Nhom, DangBan)
    VALUES (N'Món vi phạm loại', 9999, 10000, 'A', 0);
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'FOREIGN KEY', N'Chèn món với MaLoai = 9999 (không tồn tại)', 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 547 (FK_Mon_LoaiMon)');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'FOREIGN KEY', N'Chèn món với MaLoai = 9999 (không tồn tại)', ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

BEGIN TRY
    INSERT INTO dbo.LoaiMon (TenLoai, MaLoaiCha) VALUES (N'Loại vi phạm cha', 9999);
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'FOREIGN KEY', N'Chèn loại món với MaLoaiCha = 9999 (không tồn tại)', 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 547 (FK_LoaiMon_Cha)');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'FOREIGN KEY', N'Chèn loại món với MaLoaiCha = 9999 (không tồn tại)', ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

BEGIN TRY
    UPDATE dbo.NguyenLieu SET TonKho = -1 WHERE MaNL = @MaNLNhoNhat;
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'CHECK', N'Cập nhật TonKho = -1', 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 547 (CK_NL_TonKho)');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'CHECK', N'Cập nhật TonKho = -1', ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

IF XACT_STATE() <> 0
    ROLLBACK TRANSACTION;

SELECT
    LanThu,
    RangBuoc,
    TruongHop,
    MaLoi,
    KetQua,
    ThongDiep
FROM @ViPham
ORDER BY LanThu;

SELECT
    COUNT(*)                                                    AS TongSoLanThu,
    SUM(CASE WHEN KetQua = N'BỊ CHẶN'       THEN 1 ELSE 0 END)  AS SoLanBiChan,
    SUM(CASE WHEN KetQua = N'KHÔNG BỊ CHẶN' THEN 1 ELSE 0 END)  AS SoLanKhongBiChan,
    CASE
        WHEN SUM(CASE WHEN KetQua = N'KHÔNG BỊ CHẶN' THEN 1 ELSE 0 END) = 0
            THEN N'ĐẠT: mọi lệnh sai đều bị chặn'
        ELSE N'KHÔNG ĐẠT: có ràng buộc bị thiếu, xem lại schema'
    END                                                         AS KetLuan
FROM @ViPham;

SELECT N'Ban' AS Bang, COUNT(*) AS SoDong FROM dbo.Ban
UNION ALL SELECT N'NhanVien',      COUNT(*) FROM dbo.NhanVien
UNION ALL SELECT N'NguyenLieu',    COUNT(*) FROM dbo.NguyenLieu
UNION ALL SELECT N'Mon',           COUNT(*) FROM dbo.Mon
UNION ALL SELECT N'LoaiMon',       COUNT(*) FROM dbo.LoaiMon
UNION ALL SELECT N'HoaDon',        COUNT(*) FROM dbo.HoaDon
UNION ALL SELECT N'ChiTietHoaDon', COUNT(*) FROM dbo.ChiTietHoaDon;

PRINT N'';
PRINT N'======================================================';
PRINT N'=== PHẦN 2 & 3: 20 CÂU TRUY VẤN T-SQL VÀ VIEW      ===';
PRINT N'======================================================';
GO

USE QL_CAFE_NHAHANG;
GO

SELECT
    m.MaMon,
    m.TenMon,
    m.Nhom,
    m.GiaBan,
    lm.TenLoai
FROM Mon m
    INNER JOIN LoaiMon lm ON m.MaLoai = lm.MaLoai
WHERE m.DangBan = 1
ORDER BY m.GiaBan DESC;
GO

SELECT
    MaNV,
    HoTen,
    ChucVu,
    SoDienThoai,
    NgayVaoLam,
    DATEDIFF(YEAR, NgayVaoLam, GETDATE()) AS SoNamLamViec
FROM NhanVien
WHERE YEAR(NgayVaoLam) = 2022
ORDER BY NgayVaoLam;
GO

SELECT
    MaNL,
    TenNL,
    DonViTinh,
    TonKho,
    DinhMucTon,
    (DinhMucTon - TonKho) AS MucThieuHut,
    DonGiaNhap,
    CAST((DinhMucTon - TonKho) * DonGiaNhap AS DECIMAL(18,2)) AS UocTinhCanMua
FROM NguyenLieu
WHERE TonKho < DinhMucTon
ORDER BY MucThieuHut DESC;
GO

SELECT
    hd.MaHD,
    b.TenBan,
    nv.HoTen        AS TenNhanVien,
    hd.NgayLap,
    hd.TrangThai,
    hd.TongTien,
    DATEDIFF(DAY, hd.NgayLap, GETDATE()) AS SoNgayTuNgayLap
FROM HoaDon hd
    INNER JOIN Ban b   ON hd.MaBan = b.MaBan
    INNER JOIN NhanVien nv ON hd.MaNV = nv.MaNV
WHERE hd.NgayLap >= DATEADD(DAY, -7, GETDATE())
ORDER BY hd.NgayLap DESC;
GO

SELECT
    m.MaMon,
    m.TenMon,
    m.GiaBan,
    m.Nhom,
    lm.TenLoai          AS TenLoaiCon,
    lmcha.TenLoai       AS TenLoaiCha,
    m.DangBan
FROM Mon m
    INNER JOIN LoaiMon lm      ON m.MaLoai = lm.MaLoai
    LEFT  JOIN LoaiMon lmcha   ON lm.MaLoaiCha = lmcha.MaLoai
ORDER BY ISNULL(lmcha.TenLoai, lm.TenLoai), lm.TenLoai, m.TenMon;
GO

SELECT
    b.MaBan,
    b.TenBan,
    b.SucChua,
    b.TrangThai         AS TrangThaiBan,
    hd.MaHD,
    hd.NgayLap,
    hd.TongTien,
    hd.TrangThai        AS TrangThaiHoaDon
FROM Ban b
    LEFT JOIN HoaDon hd ON b.MaBan = hd.MaBan
                       AND hd.TrangThai = N'Mở'
ORDER BY b.MaBan;
GO

SELECT
    m.MaMon,
    m.TenMon,
    ma.ThoiGianCheBien,
    ma.CayHayKhong,
    nl.TenNL            AS TenNguyenLieu,
    nl.DonViTinh,
    dl.SoLuong          AS SoLuongDung
FROM MonAn ma
    INNER JOIN Mon m        ON ma.MaMon = m.MaMon
    LEFT  JOIN DinhLuong dl ON m.MaMon  = dl.MaMon
    LEFT  JOIN NguyenLieu nl ON dl.MaNL = nl.MaNL
ORDER BY m.MaMon, nl.TenNL;
GO

SELECT
    YEAR(hd.NgayLap)    AS Nam,
    MONTH(hd.NgayLap)   AS Thang,
    FORMAT(MIN(hd.NgayLap), 'MM/yyyy') AS ThangNam,
    COUNT(hd.MaHD)      AS SoHoaDon,
    SUM(hd.TongTien)    AS TongDoanhThu,
    AVG(hd.TongTien)    AS TrungBinhHoaDon
FROM HoaDon hd
WHERE hd.TrangThai = N'Đã thanh toán'
  AND hd.NgayLap >= DATEADD(MONTH, -3, GETDATE())
GROUP BY YEAR(hd.NgayLap), MONTH(hd.NgayLap)
ORDER BY Nam DESC, Thang DESC;
GO

SELECT TOP 10
    m.MaMon,
    m.TenMon,
    m.Nhom,
    lm.TenLoai,
    SUM(ct.SoLuong)     AS TongSoLuongBan,
    COUNT(DISTINCT ct.MaHD) AS SoHoaDonXuatHien,
    SUM(ct.SoLuong * ct.DonGia) AS TongDoanhThu
FROM ChiTietHoaDon ct
    INNER JOIN HoaDon hd ON ct.MaHD = hd.MaHD
    INNER JOIN Mon m     ON ct.MaMon = m.MaMon
    INNER JOIN LoaiMon lm ON m.MaLoai = lm.MaLoai
WHERE hd.TrangThai = N'Đã thanh toán'
GROUP BY m.MaMon, m.TenMon, m.Nhom, lm.TenLoai
ORDER BY TongSoLuongBan DESC;
GO

SELECT
    lm.MaLoai,
    lm.TenLoai,
    COUNT(DISTINCT dl.MaNL) AS SoNguyenLieu
FROM LoaiMon lm
    INNER JOIN Mon m        ON m.MaLoai = lm.MaLoai
    INNER JOIN DinhLuong dl ON dl.MaMon = m.MaMon
GROUP BY lm.MaLoai, lm.TenLoai
HAVING COUNT(DISTINCT dl.MaNL) > 5
ORDER BY SoNguyenLieu DESC;
GO

SELECT
    m.MaMon,
    m.TenMon,
    m.Nhom,
    m.GiaBan,
    lm.TenLoai
FROM Mon m
    INNER JOIN LoaiMon lm ON m.MaLoai = lm.MaLoai
WHERE NOT EXISTS (
    SELECT 1
    FROM ChiTietHoaDon ct
    WHERE ct.MaMon = m.MaMon
)
ORDER BY m.Nhom, m.MaMon;
GO

SELECT
    hd.MaHD,
    b.TenBan,
    nv.HoTen        AS TenNhanVien,
    hd.NgayLap,
    hd.TrangThai,
    hd.TongTien
FROM HoaDon hd
    INNER JOIN Ban b       ON hd.MaBan = b.MaBan
    INNER JOIN NhanVien nv ON hd.MaNV  = nv.MaNV
WHERE EXISTS (
    SELECT 1
    FROM ChiTietHoaDon ct
    WHERE ct.MaHD = hd.MaHD
      AND ct.TrangThaiCheBien = N'Chờ'
)
ORDER BY hd.NgayLap DESC;
GO

SELECT
    MaNL,
    TenNL,
    DonViTinh,
    TonKho,
    DonGiaNhap
FROM NguyenLieu
WHERE DonViTinh <> N'lít'
  AND DonGiaNhap > ALL (
        SELECT DonGiaNhap
        FROM NguyenLieu
        WHERE DonViTinh = N'lít'
  )
ORDER BY DonGiaNhap DESC;
GO

SELECT
    nv.MaNV,
    nv.HoTen,
    nv.ChucVu
FROM NhanVien nv
WHERE nv.ChucVu = N'PhucVu'
  AND NOT EXISTS (
        SELECT 1
        FROM Ban b
        WHERE NOT EXISTS (
            SELECT 1
            FROM HoaDon hd
            WHERE hd.MaNV  = nv.MaNV
              AND hd.MaBan = b.MaBan
        )
  )
ORDER BY nv.MaNV;
GO

SELECT ma.MaMon, m.TenMon, N'Món ăn' AS PhanLoai
FROM MonAn ma
    INNER JOIN Mon m ON ma.MaMon = m.MaMon
UNION
SELECT dl_miss.MaMon, m2.TenMon, N'Chưa có định lượng' AS PhanLoai
FROM (
    SELECT MaMon FROM Mon
    EXCEPT
    SELECT MaMon FROM DinhLuong
) dl_miss
    INNER JOIN Mon m2 ON dl_miss.MaMon = m2.MaMon
ORDER BY PhanLoai, MaMon;
GO

SELECT m.MaMon, m.TenMon, m.GiaBan, m.Nhom
FROM Mon m
WHERE m.MaMon IN (
    SELECT ct1.MaMon
    FROM ChiTietHoaDon ct1
        INNER JOIN HoaDon hd1 ON ct1.MaHD = hd1.MaHD
    WHERE hd1.TrangThai = N'Đã thanh toán'
    INTERSECT
    SELECT ct2.MaMon
    FROM ChiTietHoaDon ct2
        INNER JOIN HoaDon hd2 ON ct2.MaHD = hd2.MaHD
    WHERE hd2.TrangThai = N'Hủy'
)
ORDER BY m.MaMon;
GO

;WITH CTE_LoaiMon AS (

    SELECT
        MaLoai,
        TenLoai,
        MaLoaiCha,
        CAST(TenLoai AS NVARCHAR(500))  AS DuongDan,
        0                               AS Cap
    FROM LoaiMon
    WHERE MaLoaiCha IS NULL

    UNION ALL

    SELECT
        lm.MaLoai,
        lm.TenLoai,
        lm.MaLoaiCha,
        CAST(cte.DuongDan + N' > ' + lm.TenLoai AS NVARCHAR(500)),
        cte.Cap + 1
    FROM LoaiMon lm
        INNER JOIN CTE_LoaiMon cte ON lm.MaLoaiCha = cte.MaLoai
)
SELECT
    MaLoai,
    TenLoai,
    MaLoaiCha,
    Cap,
    DuongDan
FROM CTE_LoaiMon
ORDER BY DuongDan;
GO

;WITH CTE_DoanhThuBan AS (
    SELECT
        hd.MaBan,
        COUNT(hd.MaHD)      AS SoHoaDon,
        SUM(hd.TongTien)    AS TongDoanhThu,
        AVG(hd.TongTien)    AS TrungBinhHoaDon,
        MAX(hd.NgayLap)     AS LanCuoiCo
    FROM HoaDon hd
    WHERE hd.TrangThai = N'Đã thanh toán'
    GROUP BY hd.MaBan
)
SELECT
    b.MaBan,
    b.TenBan,
    b.SucChua,
    ISNULL(cte.SoHoaDon,    0)    AS SoHoaDon,
    ISNULL(cte.TongDoanhThu, 0)   AS TongDoanhThu,
    ISNULL(cte.TrungBinhHoaDon,0) AS TrungBinhHoaDon,
    cte.LanCuoiCo
FROM Ban b
    LEFT JOIN CTE_DoanhThuBan cte ON b.MaBan = cte.MaBan
ORDER BY TongDoanhThu DESC;
GO

SELECT
    KhungGio,
    MaMon,
    TenMon,
    TongSoLuong,
    RANK() OVER (PARTITION BY KhungGio ORDER BY TongSoLuong DESC) AS HangTrongKhung
FROM (
    SELECT
        CASE
            WHEN DATEPART(HOUR, hd.NgayLap) BETWEEN 6  AND 10 THEN N'Sáng (6h-11h)'
            WHEN DATEPART(HOUR, hd.NgayLap) BETWEEN 11 AND 13 THEN N'Trưa (11h-14h)'
            WHEN DATEPART(HOUR, hd.NgayLap) BETWEEN 14 AND 17 THEN N'Chiều (14h-18h)'
            WHEN DATEPART(HOUR, hd.NgayLap) BETWEEN 18 AND 22 THEN N'Tối (18h-23h)'
            ELSE N'Khác'
        END AS KhungGio,
        m.MaMon,
        m.TenMon,
        SUM(ct.SoLuong) AS TongSoLuong
    FROM ChiTietHoaDon ct
        INNER JOIN HoaDon hd ON ct.MaHD = hd.MaHD
        INNER JOIN Mon m     ON ct.MaMon = m.MaMon
    WHERE hd.TrangThai = N'Đã thanh toán'
    GROUP BY
        CASE
            WHEN DATEPART(HOUR, hd.NgayLap) BETWEEN 6  AND 10 THEN N'Sáng (6h-11h)'
            WHEN DATEPART(HOUR, hd.NgayLap) BETWEEN 11 AND 13 THEN N'Trưa (11h-14h)'
            WHEN DATEPART(HOUR, hd.NgayLap) BETWEEN 14 AND 17 THEN N'Chiều (14h-18h)'
            WHEN DATEPART(HOUR, hd.NgayLap) BETWEEN 18 AND 22 THEN N'Tối (18h-23h)'
            ELSE N'Khác'
        END,
        m.MaMon, m.TenMon
) ranked
ORDER BY KhungGio, HangTrongKhung;
GO

SELECT
    nv.MaNV,
    nv.HoTen,
    nv.ChucVu,
    SoHoaDon,
    TongDoanhSo,
    NTILE(4) OVER (ORDER BY TongDoanhSo DESC) AS NhomTuPhanVi,
    CASE NTILE(4) OVER (ORDER BY TongDoanhSo DESC)
        WHEN 1 THEN N'Top 25% — Xuất sắc'
        WHEN 2 THEN N'25-50%  — Khá'
        WHEN 3 THEN N'50-75%  — Trung bình'
        WHEN 4 THEN N'Bottom 25% — Cần cải thiện'
    END AS PhanLoaiHieuSuat,
    ROW_NUMBER()  OVER (ORDER BY TongDoanhSo DESC) AS STT,
    RANK()        OVER (ORDER BY TongDoanhSo DESC) AS Rank_,
    DENSE_RANK()  OVER (ORDER BY TongDoanhSo DESC) AS DenseRank_
FROM NhanVien nv
    LEFT JOIN (
        SELECT
            MaNV,
            COUNT(*)        AS SoHoaDon,
            SUM(TongTien)   AS TongDoanhSo
        FROM HoaDon
        WHERE TrangThai = N'Đã thanh toán'
        GROUP BY MaNV
    ) ds ON nv.MaNV = ds.MaNV
ORDER BY TongDoanhSo DESC;
GO

CREATE OR ALTER VIEW v_MonDangBan AS
SELECT
    m.MaMon,
    m.TenMon,
    lm.TenLoai,
    lmcha.TenLoai   AS TenLoaiCha,
    m.GiaBan,
    CASE m.Nhom
        WHEN 'A' THEN N'Đồ ăn'
        WHEN 'U' THEN N'Thức uống'
        ELSE m.Nhom
    END             AS NhomMoTa,

    ma.ThoiGianCheBien,
    ma.CayHayKhong,

    tu.Size,
    tu.CoDa,
    tu.CoDuong
FROM Mon m
    INNER JOIN LoaiMon lm        ON m.MaLoai     = lm.MaLoai
    LEFT  JOIN LoaiMon lmcha     ON lm.MaLoaiCha = lmcha.MaLoai
    LEFT  JOIN MonAn ma          ON m.MaMon       = ma.MaMon
    LEFT  JOIN ThucUong tu       ON m.MaMon       = tu.MaMon
WHERE m.DangBan = 1;
GO

CREATE OR ALTER VIEW v_TonKhoCanhBao AS
SELECT
    nl.MaNL,
    nl.TenNL,
    nl.DonViTinh,
    nl.TonKho,
    nl.DinhMucTon,
    (nl.DinhMucTon - nl.TonKho)         AS MucThieuHut,
    nl.DonGiaNhap,
    CAST((nl.DinhMucTon - nl.TonKho) * nl.DonGiaNhap AS DECIMAL(18,2)) AS UocTinhTienMua,
    CASE
        WHEN nl.TonKho = 0              THEN N'Hết hàng'
        WHEN nl.TonKho <= nl.DinhMucTon THEN N'Dưới định mức'
    END AS MucCanhBao
FROM NguyenLieu nl
WHERE nl.TonKho <= nl.DinhMucTon;
GO

CREATE OR ALTER VIEW v_DoanhThuHoaDon AS
SELECT
    hd.MaHD,
    b.MaBan,
    b.TenBan,
    nv.MaNV,
    nv.HoTen        AS TenNhanVien,
    nv.ChucVu,
    hd.NgayLap,
    YEAR(hd.NgayLap)    AS Nam,
    MONTH(hd.NgayLap)   AS Thang,
    hd.TongTien,
    COUNT(ct.MaMon) AS SoDongChiTiet
FROM HoaDon hd
    INNER JOIN Ban b            ON hd.MaBan = b.MaBan
    INNER JOIN NhanVien nv      ON hd.MaNV  = nv.MaNV
    INNER JOIN ChiTietHoaDon ct ON hd.MaHD  = ct.MaHD
WHERE hd.TrangThai = N'Đã thanh toán'
GROUP BY
    hd.MaHD, b.MaBan, b.TenBan,
    nv.MaNV, nv.HoTen, nv.ChucVu,
    hd.NgayLap, hd.TongTien;
GO
