/* =====================================================================
   CSDL QUẢN LÝ NHÀ HÀNG / QUÁN CÀ PHÊ — 04: KIỂM CHỨNG RÀNG BUỘC
   =====================================================================
   MỤC ĐÍCH (Readme mục 3.3, gạch đầu dòng cuối)
       "Có một bộ lệnh cố tình vi phạm ràng buộc để chứng minh hệ thống
        từ chối đúng."

   File này chứa 10 lệnh cố tình SAI, mỗi lệnh bọc trong TRY...CATCH.
   Lệnh đúng phải bị SQL Server chặn; nếu một lệnh lọt qua thì cột KetQua
   sẽ ghi "KHÔNG BỊ CHẶN" — tức là ràng buộc bị thiếu, cần sửa schema.

   CHẠY KHI NÀO
       Sau khi đã nạp dữ liệu:  02_Bang.sql → 03a_DanhMuc.sql → 03b_GiaoDich.sql → [04]
       (cần dữ liệu sẵn có để thử trùng khóa / trùng số điện thoại)

   AN TOÀN
       Toàn bộ nằm trong MỘT transaction và kết thúc bằng ROLLBACK, nên dù
       có lệnh nào lọt qua thì dữ liệu vẫn về nguyên trạng. Cuối file có
       truy vấn chứng minh số dòng không đổi.
   ===================================================================== */

USE QL_CAFE_NHAHANG;
GO

SET NOCOUNT ON;
GO

/* ---------------------------------------------------------------------
   KIỂM TRA TIỀN ĐỀ: phải có dữ liệu thì mới thử được trùng khóa
   --------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon) OR NOT EXISTS (SELECT 1 FROM dbo.NhanVien)
    THROW 51001, N'Chưa có dữ liệu để kiểm chứng. Hãy chạy 03b_GiaoDich.sql trước.', 1;

/* ---------------------------------------------------------------------
   BẢNG GHI NHẬN KẾT QUẢ
   Dùng biến bảng (@ViPham) chứ không dùng bảng tạm (#ViPham), vì biến bảng
   KHÔNG bị ROLLBACK xóa — nếu dùng bảng tạm thì toàn bộ kết quả sẽ mất
   khi ta rollback ở cuối.
   --------------------------------------------------------------------- */
DECLARE @ViPham TABLE
(
    LanThu    INT IDENTITY(1, 1) PRIMARY KEY,
    RangBuoc  NVARCHAR(30)  NOT NULL,
    TruongHop NVARCHAR(120) NOT NULL,
    MaLoi     INT           NOT NULL,
    KetQua    NVARCHAR(20)  NOT NULL,
    ThongDiep NVARCHAR(4000) NULL
);

-- Các giá trị "có thật" để tạo ra vi phạm trùng lặp
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

/* ---------------------------------------------------------------------
   1. NOT NULL — bỏ trống họ tên nhân viên
   --------------------------------------------------------------------- */
BEGIN TRY
    INSERT INTO dbo.NhanVien (HoTen, ChucVu) VALUES (NULL, N'Bep');
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'NOT NULL', N'Chèn nhân viên với HoTen = NULL', 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 515');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'NOT NULL', N'Chèn nhân viên với HoTen = NULL', ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

/* ---------------------------------------------------------------------
   2. CHECK — sức chứa bàn phải > 0
   --------------------------------------------------------------------- */
BEGIN TRY
    INSERT INTO dbo.Ban (TenBan, SucChua) VALUES (N'Bàn vi phạm 0 chỗ', 0);
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'CHECK', N'Chèn bàn có SucChua = 0', 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 547 (CK_Ban_SucChua)');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'CHECK', N'Chèn bàn có SucChua = 0', ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

/* ---------------------------------------------------------------------
   3. CHECK — trạng thái bàn không nằm trong danh sách cho phép
   --------------------------------------------------------------------- */
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

/* ---------------------------------------------------------------------
   4. UNIQUE — trùng tên bàn
   --------------------------------------------------------------------- */
BEGIN TRY
    INSERT INTO dbo.Ban (TenBan, SucChua) VALUES (N'Bàn 01', 4);
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'UNIQUE', N'Chèn bàn trùng TenBan = N''Bàn 01''', 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 2627 (UQ_Ban_Ten)');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'UNIQUE', N'Chèn bàn trùng TenBan = N''Bàn 01''', ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

/* ---------------------------------------------------------------------
   5. UNIQUE INDEX CÓ ĐIỀU KIỆN — trùng số điện thoại
      (UX_NhanVien_SDT chỉ áp dụng cho dòng có số điện thoại khác NULL,
       nên nhiều nhân viên NULL vẫn hợp lệ, nhưng không được trùng số)
   --------------------------------------------------------------------- */
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

/* ---------------------------------------------------------------------
   6. PRIMARY KEY — trùng cặp (MaHD, MaMon) trong chi tiết hóa đơn
   --------------------------------------------------------------------- */
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

/* ---------------------------------------------------------------------
   7. FOREIGN KEY — hóa đơn trỏ tới bàn không tồn tại
   --------------------------------------------------------------------- */
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

/* ---------------------------------------------------------------------
   8. FOREIGN KEY — món trỏ tới loại món không tồn tại
   --------------------------------------------------------------------- */
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

/* ---------------------------------------------------------------------
   9. FOREIGN KEY TỰ THAM CHIẾU — loại món có loại cha không tồn tại
   --------------------------------------------------------------------- */
BEGIN TRY
    INSERT INTO dbo.LoaiMon (TenLoai, MaLoaiCha) VALUES (N'Loại vi phạm cha', 9999);
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'FOREIGN KEY', N'Chèn loại món với MaLoaiCha = 9999 (không tồn tại)', 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 547 (FK_LoaiMon_Cha)');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'FOREIGN KEY', N'Chèn loại món với MaLoaiCha = 9999 (không tồn tại)', ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

/* ---------------------------------------------------------------------
   10. CHECK — tồn kho âm (dùng UPDATE để khác các ca INSERT ở trên)
   --------------------------------------------------------------------- */
BEGIN TRY
    UPDATE dbo.NguyenLieu SET TonKho = -1 WHERE MaNL = @MaNLNhoNhat;
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'CHECK', N'Cập nhật TonKho = -1', 0, N'KHÔNG BỊ CHẶN', N'Mong đợi: lỗi 547 (CK_NL_TonKho)');
END TRY
BEGIN CATCH
    INSERT INTO @ViPham (RangBuoc, TruongHop, MaLoi, KetQua, ThongDiep)
    VALUES (N'CHECK', N'Cập nhật TonKho = -1', ERROR_NUMBER(), N'BỊ CHẶN', ERROR_MESSAGE());
END CATCH;

/* ---------------------------------------------------------------------
   HỦY TOÀN BỘ: dù có lệnh nào lọt qua, dữ liệu vẫn về nguyên trạng
   --------------------------------------------------------------------- */
IF XACT_STATE() <> 0
    ROLLBACK TRANSACTION;

/* =====================================================================
   KẾT QUẢ
   ===================================================================== */

-- Bảng chi tiết: mỗi lần thử phải có KetQua = N'BỊ CHẶN'
SELECT
    LanThu,
    RangBuoc,
    TruongHop,
    MaLoi,
    KetQua,
    ThongDiep
FROM @ViPham
ORDER BY LanThu;

-- Tổng hợp: SoLanKhongBiChan phải bằng 0
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

-- Chứng minh dữ liệu KHÔNG thay đổi sau khi rollback
SELECT N'Ban' AS Bang, COUNT(*) AS SoDong FROM dbo.Ban
UNION ALL SELECT N'NhanVien',      COUNT(*) FROM dbo.NhanVien
UNION ALL SELECT N'NguyenLieu',    COUNT(*) FROM dbo.NguyenLieu
UNION ALL SELECT N'Mon',           COUNT(*) FROM dbo.Mon
UNION ALL SELECT N'LoaiMon',       COUNT(*) FROM dbo.LoaiMon
UNION ALL SELECT N'HoaDon',        COUNT(*) FROM dbo.HoaDon
UNION ALL SELECT N'ChiTietHoaDon', COUNT(*) FROM dbo.ChiTietHoaDon;
