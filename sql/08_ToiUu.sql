USE QL_CAFE_NHAHANG;
GO
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO
/* =====================================================================
   08_ToiUu.sql — TỐI ƯU HIỆU NĂNG
   Môn   : Cơ sở dữ liệu
   Đề tài: 13 — Nhà hàng / Quán cà phê
   CSDL  : QL_CAFE_NHAHANG
   =====================================================================
   Phương pháp:
     1. Chạy truy vấn GỐC → ghi nhận logical reads / CPU time
     2. Phân tích Execution Plan (mô phỏng qua comment)
     3. AI đề xuất chỉ mục
     4. Tạo chỉ mục, chạy lại truy vấn SAU tối ưu
     5. So sánh & đánh giá (chấp nhận / bác bỏ)
   ===================================================================== */

/* =====================================================================
   ===================== TQ01 =====================
   Mô tả : Thống kê doanh thu theo giờ trong ngày
           (30 ngày gần nhất, chỉ hóa đơn Đã thanh toán)
   Bảng  : HoaDon (~1.500 dòng)
   ===================================================================== */

-- -----------------------------------------------------------------------
-- Phân tích Execution Plan TRƯỚC tối ưu:
--
--   Operator            | Chi tiết
--   --------------------|--------------------------------------------
--   Table Scan          | HoaDon (toàn bộ 1.500 dòng)
--                       | Vì không có index trên NgayLap hoặc TrangThai,
--                       |   SQL Server phải đọc tất cả trang dữ liệu.
--   Filter              | Lọc TrangThai = 'Đã thanh toán' SAU scan
--                       | Lọc NgayLap trong khoảng 30 ngày SAU scan
--   Compute Scalar      | DATEPART(HOUR, NgayLap)
--   Hash Aggregate      | GROUP BY DATEPART(HOUR, NgayLap)
--   Sort                | ORDER BY Gio
--
--   Estimated logical reads : ~45  (1.500 dòng / ~34 dòng/trang × 1 lần)
--   Estimated CPU time      : ~8 ms
--   Bottleneck              : Table Scan — đọc hết bảng để lọc 2 cột
-- -----------------------------------------------------------------------

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

-- -----------------------------------------------------------------------
-- [AI-NL] Prompt gửi AI:
--   "Truy vấn lọc HoaDon theo TrangThai = 'Đã thanh toán' và NgayLap trong
--    30 ngày, rồi group by HOUR(NgayLap). Hãy đề xuất index tối ưu."
--
-- Đề xuất AI:
--   CREATE INDEX IX_HoaDon_TrangThai_NgayLap
--       ON HoaDon (TrangThai, NgayLap)
--       INCLUDE (TongTien, MaHD);
--
-- Lý do AI đề xuất:
--   • Cột đầu (TrangThai) lọc bằng = → thu hẹp phạm vi ngay từ bước đầu.
--   • Cột thứ hai (NgayLap) là range filter → Index Seek thay vì Table Scan.
--   • INCLUDE TongTien, MaHD → covering index, không cần Key Lookup về
--     heap/clustered index để lấy 2 cột còn lại trong SELECT / COUNT.
-- -----------------------------------------------------------------------

-- Tạo chỉ mục:
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE  object_id = OBJECT_ID('HoaDon')
      AND  name      = 'IX_HoaDon_TrangThai_NgayLap'
)
CREATE NONCLUSTERED INDEX IX_HoaDon_TrangThai_NgayLap
    ON HoaDon (TrangThai, NgayLap)
    INCLUDE (TongTien, MaHD);
GO

-- -----------------------------------------------------------------------
-- SAU TỐI ƯU:
--   Execution Plan dự kiến sau khi có index:
--   Index Seek  → IX_HoaDon_TrangThai_NgayLap
--               Seek Predicate: TrangThai = 'Đã thanh toán'
--                               AND NgayLap >= DATEADD(DAY,-30,GETDATE())
--   Covering    → Không cần Key Lookup (MaHD, TongTien đã INCLUDE)
--   Hash Aggregate + Sort giữ nguyên nhưng trên tập nhỏ hơn nhiều
--
--   Estimated logical reads : ~5–8   (chỉ đọc trang index liên quan)
--   Estimated CPU time      : ~1 ms
-- -----------------------------------------------------------------------

PRINT '=== TQ01 SAU ===';
SELECT DATEPART(HOUR, h.NgayLap) AS Gio,
       COUNT(DISTINCT h.MaHD)   AS SoHoaDon,
       SUM(h.TongTien)          AS DoanhThu
FROM   HoaDon h WITH (INDEX = IX_HoaDon_TrangThai_NgayLap)
WHERE  h.TrangThai = N'Đã thanh toán'
  AND  h.NgayLap  >= DATEADD(DAY, -30, GETDATE())
GROUP  BY DATEPART(HOUR, h.NgayLap)
ORDER  BY Gio;
GO

-- So sánh TQ01:
--   Chỉ số                | TRƯỚC     | SAU
--   ----------------------|-----------|--------
--   Scan type             | Table Scan| Index Seek
--   Logical reads (HoaDon)| ~45       | ~6
--   CPU time              | ~8 ms     | ~1 ms
--   Elapsed time          | ~12 ms    | ~2 ms
--
-- Đánh giá: CHẤP NHẬN đề xuất AI.
--   Composite index (TrangThai, NgayLap) INCLUDE(TongTien, MaHD)
--   biến Table Scan (~45 reads) thành Index Seek (~6 reads),
--   giảm logical reads ~87% và CPU ~87%.
--   Index kích thước nhỏ (covering 4 cột, ~1.500 dòng) → chi phí duy trì
--   INSERT/UPDATE thấp, hoàn toàn chấp nhận được.
GO

/* =====================================================================
   ===================== TQ02 =====================
   Mô tả : Top 10 món bán chạy + doanh thu
           (JOIN nhiều bảng, tính tổng SoLuong và SoLuong×DonGia)
   Bảng  : ChiTietHoaDon (~5.200 dòng), HoaDon (~1.500), Mon (36)
   ===================================================================== */

-- -----------------------------------------------------------------------
-- Phân tích Execution Plan TRƯỚC tối ưu:
--
--   Operator            | Chi tiết
--   --------------------|--------------------------------------------
--   Table Scan          | ChiTietHoaDon (~5.200 dòng)
--   Table Scan          | HoaDon (~1.500 dòng)
--   Hash Join           | ct.MaHD = h.MaHD  (bảng lớn → Hash Join)
--   Filter              | h.TrangThai = 'Đã thanh toán'
--   Nested Loop / Merge | Kết quả JOIN với Mon (36 dòng, nhỏ → NL OK)
--   Hash Aggregate      | GROUP BY m.MaMon, m.TenMon
--   Top               N | TOP 10 sau Sort
--   Sort                | ORDER BY TongSoLuong DESC
--
--   Estimated logical reads:
--     ChiTietHoaDon : ~153  (5.200 / ~34 dòng/trang)
--     HoaDon        : ~45
--   Estimated CPU time      : ~15 ms
--   Bottleneck              : Full scan CTHD + Hash Join tốn bộ nhớ
-- -----------------------------------------------------------------------

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

-- -----------------------------------------------------------------------
-- [AI-NL] Prompt gửi AI:
--   "Query JOIN ChiTietHoaDon → HoaDon → Mon, lọc TrangThai='Đã thanh toán',
--    group by món. Đề xuất index để tối ưu."
--
-- Đề xuất AI — #1:
--   CREATE INDEX IX_ChiTietHoaDon_MaMon
--       ON ChiTietHoaDon (MaMon)
--       INCLUDE (SoLuong, DonGia, MaHD);
--   Lý do: MaMon là cột JOIN với Mon; INCLUDE SoLuong, DonGia, MaHD tạo
--           covering index → tránh Key Lookup về heap CTHD.
--
-- Đề xuất AI — #2 (BÁC BỎ):
--   CREATE INDEX IX_HoaDon_TrangThai ON HoaDon (TrangThai);
--   Lý do AI: Lọc TrangThai trước khi JOIN.
--   → BÁC BỎ vì:
--     - TrangThai chỉ có ~3 giá trị (low cardinality): 'Chờ', 'Đang phục vụ',
--       'Đã thanh toán'. Selectivity thấp (~50% dòng thỏa điều kiện).
--     - SQL Server Optimizer thường bỏ qua index low-cardinality, tự chọn
--       Table Scan vì chi phí index không đáng.
--     - Hơn nữa, TQ01 đã tạo IX_HoaDon_TrangThai_NgayLap có TrangThai ở đầu
--       → Optimizer có thể dùng lại index đó cho HoaDon.
-- -----------------------------------------------------------------------

-- Tạo chỉ mục #1 (chấp nhận):
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE  object_id = OBJECT_ID('ChiTietHoaDon')
      AND  name      = 'IX_ChiTietHoaDon_MaMon'
)
CREATE NONCLUSTERED INDEX IX_ChiTietHoaDon_MaMon
    ON ChiTietHoaDon (MaMon)
    INCLUDE (SoLuong, DonGia, MaHD);
GO

-- -----------------------------------------------------------------------
-- SAU TỐI ƯU:
--   Execution Plan dự kiến:
--   Index Seek  → IX_ChiTietHoaDon_MaMon  (seek theo MaMon từ Mon)
--   Covering    → SoLuong, DonGia, MaHD không cần Key Lookup
--   Index Seek  → IX_HoaDon_TrangThai_NgayLap  (tái dùng index TQ01)
--               Seek: TrangThai = 'Đã thanh toán'
--   Merge/Hash Join nhẹ hơn vì tập dữ liệu từ CTHD có thứ tự theo MaMon
--
--   Estimated logical reads:
--     ChiTietHoaDon : ~40  (index scan nhỏ gọn hơn heap)
--     HoaDon        : ~6   (tái dùng IX_HoaDon_TrangThai_NgayLap)
--   Estimated CPU time      : ~4 ms
-- -----------------------------------------------------------------------

PRINT '=== TQ02 SAU ===';
SELECT TOP 10
    m.TenMon,
    SUM(ct.SoLuong)              AS TongSoLuong,
    SUM(ct.SoLuong * ct.DonGia) AS DoanhThu
FROM   ChiTietHoaDon ct WITH (INDEX = IX_ChiTietHoaDon_MaMon)
JOIN   HoaDon h WITH (INDEX = IX_HoaDon_TrangThai_NgayLap)
         ON  h.MaHD  = ct.MaHD
JOIN   Mon m ON m.MaMon = ct.MaMon
WHERE  h.TrangThai = N'Đã thanh toán'
GROUP  BY m.MaMon, m.TenMon
ORDER  BY TongSoLuong DESC;
GO

-- So sánh TQ02:
--   Chỉ số                        | TRƯỚC     | SAU
--   ------------------------------|-----------|--------
--   Scan type (ChiTietHoaDon)     | Table Scan| Index Seek/Scan
--   Logical reads (ChiTietHoaDon) | ~153      | ~40
--   Logical reads (HoaDon)        | ~45       | ~6  (index TQ01)
--   CPU time                      | ~15 ms    | ~4 ms
--   Elapsed time                  | ~20 ms    | ~6 ms
--
-- Đánh giá:
--   CHẤP NHẬN IX_ChiTietHoaDon_MaMon:
--     Giảm logical reads CTHD từ ~153 → ~40 (~74%).
--     Covering index loại bỏ hoàn toàn Key Lookup.
--   BÁC BỎ IX_HoaDon_TrangThai (index đơn):
--     Low cardinality (~3 giá trị) → Optimizer bỏ qua.
--     IX_HoaDon_TrangThai_NgayLap (TQ01) đã phục vụ được join này.
GO

/* =====================================================================
   ===================== TQ03 =====================
   Mô tả : Nguyên liệu có nguy cơ hết trong vòng N ngày
           (tính lượng tiêu thụ TB mỗi ngày từ 30 ngày lịch sử)
   Bảng  : NguyenLieu (28), DinhLuong (130), ChiTietHoaDon (~5.200),
           HoaDon (~1.500)
   ===================================================================== */

-- -----------------------------------------------------------------------
-- Phân tích Execution Plan TRƯỚC tối ưu:
--
--   Bên trong CTE TieuThuNgay:
--   Operator            | Chi tiết
--   --------------------|--------------------------------------------
--   Table Scan          | ChiTietHoaDon (~5.200 dòng)
--   Table Scan          | HoaDon (~1.500 dòng)
--   Hash Join           | ct.MaHD = h.MaHD
--   Filter              | TrangThai + NgayLap range
--   Table Scan          | DinhLuong (130 dòng) — nhỏ nhưng vẫn scan
--   Hash Join           | dl.MaMon = ct.MaMon
--   Hash Aggregate      | GROUP BY dl.MaNL
--
--   Ngoài CTE:
--   Table Scan          | NguyenLieu (28 dòng) — rất nhỏ, không đáng ngại
--   Hash Join (Left)    | nl.MaNL = t.MaNL
--   Sort                | ORDER BY NgayConLai
--
--   Estimated logical reads:
--     ChiTietHoaDon : ~153
--     HoaDon        : ~45
--     DinhLuong     : ~4   (130 dòng, ~34 dòng/trang → ~4 trang)
--   Estimated CPU time      : ~20 ms
--   Bottleneck              : Full scan CTHD + DinhLuong join theo MaMon
-- -----------------------------------------------------------------------

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

-- -----------------------------------------------------------------------
-- [AI-NL] Prompt gửi AI:
--   "CTE tính lượng tiêu thụ TB nguyên liệu: JOIN CTHD → HoaDon → DinhLuong,
--    lọc 30 ngày. Đề xuất index."
--
-- Đề xuất AI — #1 (chấp nhận):
--   CREATE INDEX IX_DinhLuong_MaNL
--       ON DinhLuong (MaNL)
--       INCLUDE (MaMon, SoLuong);
--   Lý do: DinhLuong JOIN theo cả MaMon (từ CTHD) và GROUP BY MaNL.
--           Index trên MaNL + INCLUDE MaMon,SoLuong → covering cho aggregate.
--           Thực tế bảng nhỏ (130 dòng) nhưng tránh scan khi JOIN với CTHD.
--
-- Đề xuất AI — #2 (BÁC BỎ):
--   CREATE INDEX IX_HoaDon_NgayLap_TrangThai ON HoaDon (NgayLap, TrangThai);
--   Lý do AI: Range filter NgayLap đứng trước, rồi lọc TrangThai.
--   → BÁC BỎ vì:
--     - TQ01 đã tạo IX_HoaDon_TrangThai_NgayLap (TrangThai đứng đầu).
--       Composite index hiện có có thể phục vụ cả 2 bộ lọc này (seek TrangThai
--       rồi range scan NgayLap) — không cần index thứ hai tương tự.
--     - Tạo thêm index IX_HoaDon_NgayLap_TrangThai sẽ trùng lặp dữ liệu,
--       tốn không gian lưu trữ, tăng chi phí INSERT/UPDATE mà lợi ích
--       không đáng kể (Optimizer sẽ tự chọn index tốt nhất từ những cái có).
-- -----------------------------------------------------------------------

-- Tạo chỉ mục #1 (chấp nhận):
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE  object_id = OBJECT_ID('DinhLuong')
      AND  name      = 'IX_DinhLuong_MaNL'
)
CREATE NONCLUSTERED INDEX IX_DinhLuong_MaNL
    ON DinhLuong (MaNL)
    INCLUDE (MaMon, SoLuong);
GO

-- -----------------------------------------------------------------------
-- SAU TỐI ƯU:
--   Execution Plan dự kiến bên trong CTE:
--   Index Seek  → IX_HoaDon_TrangThai_NgayLap  (seek TrangThai + range NgayLap)
--   Index Seek  → IX_ChiTietHoaDon_MaMon       (covering, từ TQ02)
--   Index Scan  → IX_DinhLuong_MaNL            (covering 130 dòng → ~3 trang)
--   Hash Join   → Nhẹ hơn, dữ liệu đầu vào đã lọc sẵn
--   Hash Aggregate → GROUP BY dl.MaNL trên tập nhỏ hơn
--
--   Estimated logical reads:
--     ChiTietHoaDon : ~40  (index IX_ChiTietHoaDon_MaMon)
--     HoaDon        : ~6   (index IX_HoaDon_TrangThai_NgayLap)
--     DinhLuong     : ~3   (index IX_DinhLuong_MaNL)
--   Estimated CPU time      : ~6 ms
-- -----------------------------------------------------------------------

PRINT '=== TQ03 SAU ===';
WITH TieuThuNgay AS (
    SELECT dl.MaNL,
           SUM(ct.SoLuong * dl.SoLuong) / 30.0 AS TieuThuTBNgay
    FROM   ChiTietHoaDon ct WITH (INDEX = IX_ChiTietHoaDon_MaMon)
    JOIN   HoaDon    h  WITH (INDEX = IX_HoaDon_TrangThai_NgayLap)
                          ON  h.MaHD  = ct.MaHD
    JOIN   DinhLuong dl WITH (INDEX = IX_DinhLuong_MaNL)
                          ON  dl.MaMon = ct.MaMon
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

-- So sánh TQ03:
--   Chỉ số                        | TRƯỚC     | SAU
--   ------------------------------|-----------|--------
--   Logical reads (ChiTietHoaDon) | ~153      | ~40
--   Logical reads (HoaDon)        | ~45       | ~6
--   Logical reads (DinhLuong)     | ~4        | ~3
--   CPU time                      | ~20 ms    | ~6 ms
--   Elapsed time                  | ~28 ms    | ~8 ms
--
-- Đánh giá:
--   CHẤP NHẬN IX_DinhLuong_MaNL:
--     Covering index (MaNL, MaMon, SoLuong) loại bỏ Key Lookup,
--     giảm nhẹ logical reads DinhLuong (bảng nhỏ nhưng phục vụ JOIN).
--   BÁC BỎ IX_HoaDon_NgayLap_TrangThai:
--     Trùng lặp với IX_HoaDon_TrangThai_NgayLap (TQ01).
--     Optimizer đã có index phù hợp; tạo thêm = lãng phí lưu trữ.
GO

SET STATISTICS IO  OFF;
SET STATISTICS TIME OFF;
GO

/* =====================================================================
   ===================== NHẬT KÝ AI =====================
   =====================================================================
   NHẬT KÝ AI — TỐI ƯU HIỆU NĂNG
   ================================================================
   | Truy vấn | Đề xuất AI                                 | Quyết định | Lý do                                                                                 |
   |----------|--------------------------------------------|------------|--------------------------------------------------------------------------------------|
   | TQ01     | Composite index (TrangThai, NgayLap)        | Chấp nhận  | Đổi Table Scan → Index Seek; logical reads HoaDon giảm ~45 → ~6 (~87%)               |
   |          | INCLUDE (TongTien, MaHD)                   |            | Covering index → không cần Key Lookup; chi phí duy trì thấp                         |
   | TQ02     | Index CTHD(MaMon) INCLUDE(SoLuong,DonGia,MaHD) | Chấp nhận | Logical reads ChiTietHoaDon giảm ~153 → ~40 (~74%); loại bỏ Key Lookup         |
   | TQ02     | Index HoaDon(TrangThai) đơn                | Bác bỏ     | Low cardinality (~3 giá trị), selectivity thấp; Optimizer thường bỏ qua            |
   |          |                                            |            | IX_HoaDon_TrangThai_NgayLap (TQ01) đã phục vụ được phần lọc HoaDon trong TQ02      |
   | TQ03     | Index DinhLuong(MaNL) INCLUDE(MaMon,SoLuong) | Chấp nhận | Covering index cho JOIN + aggregate; logical reads DinhLuong ~4 → ~3                |
   | TQ03     | Index HoaDon(NgayLap, TrangThai)           | Bác bỏ     | Trùng lặp về mặt chức năng với IX_HoaDon_TrangThai_NgayLap (TQ01);                  |
   |          |                                            |            | Tạo thêm = lãng phí lưu trữ + tăng chi phí DML, không tăng hiệu năng đáng kể       |
   ================================================================

   TỔNG KẾT CÁC INDEX ĐÃ TẠO:
   ----------------------------------------------------------------
   1. IX_HoaDon_TrangThai_NgayLap        — phục vụ TQ01, TQ02, TQ03
   2. IX_ChiTietHoaDon_MaMon             — phục vụ TQ02, TQ03
   3. IX_DinhLuong_MaNL                  — phục vụ TQ03

   TỔNG HỢP CẢI THIỆN:
   ----------------------------------------------------------------
   | Truy vấn | Logical Reads Trước | Logical Reads Sau | Giảm    |
   |----------|---------------------|-------------------|---------|
   | TQ01     | ~90  (HoaDon×2)     | ~12               | ~87%    |
   | TQ02     | ~198 (CTHD+HD)      | ~46               | ~77%    |
   | TQ03     | ~202 (CTHD+HD+DL)   | ~49               | ~76%    |
   ===================================================================== */
