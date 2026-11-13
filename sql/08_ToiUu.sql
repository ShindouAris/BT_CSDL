-- 08_ToiUu.sql: Đo hiệu năng 3 truy vấn nặng trước và sau khi tạo index.
USE QL_CAFE_NHAHANG;
GO

DROP INDEX IF EXISTS IX_HoaDon_TrangThai_NgayLap ON HoaDon;
DROP INDEX IF EXISTS IX_ChiTietHoaDon_MaMon      ON ChiTietHoaDon;
DROP INDEX IF EXISTS IX_DinhLuong_MaNL           ON DinhLuong;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

PRINT '=== TQ01 TRƯỚC ===';
SELECT DATEPART(HOUR, h.NgayLap) AS Gio,
       COUNT(DISTINCT h.MaHD)   AS SoHoaDon,
       SUM(h.TongTien)          AS DoanhThu
FROM   HoaDon h
WHERE  h.TrangThai = N'Đã thanh toán'
  AND  h.NgayLap  >= DATEADD(DAY, -30, GETDATE())
GROUP  BY DATEPART(HOUR, h.NgayLap)
ORDER  BY Gio;
GO

PRINT '=== TQ02 TRƯỚC ===';
SELECT TOP 10
    m.TenMon,
    SUM(ct.SoLuong)              AS TongSoLuong,
    SUM(ct.SoLuong * ct.DonGia) AS DoanhThu
FROM   ChiTietHoaDon ct
JOIN   HoaDon h ON h.MaHD  = ct.MaHD
JOIN   Mon    m ON m.MaMon = ct.MaMon
WHERE  h.TrangThai = N'Đã thanh toán'
GROUP  BY m.MaMon, m.TenMon
ORDER  BY TongSoLuong DESC;
GO

PRINT '=== TQ03 TRƯỚC ===';
WITH TieuThuNgay AS (
    SELECT dl.MaNL,
           SUM(ct.SoLuong * dl.SoLuong) / 30.0 AS TieuThuTBNgay
    FROM   ChiTietHoaDon ct
    JOIN   HoaDon    h  ON h.MaHD  = ct.MaHD
    JOIN   DinhLuong dl ON dl.MaMon = ct.MaMon
    WHERE  h.TrangThai = N'Đã thanh toán'
      AND  h.NgayLap  >= DATEADD(DAY, -30, GETDATE())
    GROUP  BY dl.MaNL
)
SELECT nl.TenNL,
       nl.TonKho,
       nl.DinhMucTon,
       t.TieuThuTBNgay,
       CAST(nl.TonKho / NULLIF(t.TieuThuTBNgay, 0) AS DECIMAL(10,1)) AS NgayConLai
FROM   NguyenLieu nl
LEFT JOIN TieuThuNgay t ON t.MaNL = nl.MaNL
ORDER  BY NgayConLai;
GO

CREATE NONCLUSTERED INDEX IX_HoaDon_TrangThai_NgayLap
    ON HoaDon (TrangThai, NgayLap)
    INCLUDE (TongTien, MaHD);
GO

CREATE NONCLUSTERED INDEX IX_ChiTietHoaDon_MaMon
    ON ChiTietHoaDon (MaMon)
    INCLUDE (SoLuong, DonGia, MaHD);
GO

GO

PRINT '=== TQ01 SAU ===';
SELECT DATEPART(HOUR, h.NgayLap) AS Gio,
       COUNT(DISTINCT h.MaHD)   AS SoHoaDon,
       SUM(h.TongTien)          AS DoanhThu
FROM   HoaDon h
WHERE  h.TrangThai = N'Đã thanh toán'
  AND  h.NgayLap  >= DATEADD(DAY, -30, GETDATE())
GROUP  BY DATEPART(HOUR, h.NgayLap)
ORDER  BY Gio;
GO

PRINT '=== TQ02 SAU ===';
SELECT TOP 10
    m.TenMon,
    SUM(ct.SoLuong)              AS TongSoLuong,
    SUM(ct.SoLuong * ct.DonGia) AS DoanhThu
FROM   ChiTietHoaDon ct
JOIN   HoaDon h ON h.MaHD  = ct.MaHD
JOIN   Mon    m ON m.MaMon = ct.MaMon
WHERE  h.TrangThai = N'Đã thanh toán'
GROUP  BY m.MaMon, m.TenMon
ORDER  BY TongSoLuong DESC;
GO

PRINT '=== TQ03 SAU ===';
WITH TieuThuNgay AS (
    SELECT dl.MaNL,
           SUM(ct.SoLuong * dl.SoLuong) / 30.0 AS TieuThuTBNgay
    FROM   ChiTietHoaDon ct
    JOIN   HoaDon    h  ON h.MaHD  = ct.MaHD
    JOIN   DinhLuong dl ON dl.MaMon = ct.MaMon
    WHERE  h.TrangThai = N'Đã thanh toán'
      AND  h.NgayLap  >= DATEADD(DAY, -30, GETDATE())
    GROUP  BY dl.MaNL
)
SELECT nl.TenNL,
       nl.TonKho,
       nl.DinhMucTon,
       t.TieuThuTBNgay,
       CAST(nl.TonKho / NULLIF(t.TieuThuTBNgay, 0) AS DECIMAL(10,1)) AS NgayConLai
FROM   NguyenLieu nl
LEFT JOIN TieuThuNgay t ON t.MaNL = nl.MaNL
ORDER  BY NgayConLai;
GO

SET STATISTICS IO  OFF;
SET STATISTICS TIME OFF;
GO
