/* =====================================================================
   CSDL QUẢN LÝ NHÀ HÀNG / QUÁN CÀ PHÊ — 03b: NẠP DỮ LIỆU GIAO DỊCH
   =====================================================================

   VỊ TRÍ TRONG CHUỖI
       01_CAUHINH_CSDL.sql  →  02_Bang.sql  →  03a_DanhMuc.sql  →  [03b]
       (04_TEST_VI_PHAM.sql chạy sau cùng, chỉ để kiểm chứng ràng buộc)

   KẾT QUẢ
       - 1.500 hóa đơn, trong đó:
            5 hóa đơn "Mở"          : mỗi bàn đang "Có khách" đúng 1 hóa đơn
            1.390 hóa đơn "Đã thanh toán"
            105 hóa đơn "Hủy"       : khoảng 7%
       - Khoảng 5.200 dòng ChiTietHoaDon (mỗi hóa đơn 1–6 món, ngẫu nhiên)
       - 5 hóa đơn rỗng (không có chi tiết), nằm ở cuối nhóm hóa đơn đã đóng
       - TongTien của mọi hóa đơn được tính bằng một câu UPDATE ... LEFT JOIN

   ĐÃ SỬA SO VỚI BẢN CŨ (chi tiết xem NhatKy_AI.md)
       1. LỖI CHỌN NGẪU NHIÊN: bản cũ dùng
              WHERE Id = 1 + ABS(CHECKSUM(NEWID())) % @SoNV
          NEWID() trong WHERE được tính lại cho TỪNG DÒNG, nên mỗi dòng so với
          một số ngẫu nhiên khác nhau → có thể không dòng nào khớp, biến giữ
          NULL ở lần đầu và script chết với lỗi "Cannot insert NULL".
          Cách sửa: tính chỉ số ngẫu nhiên ra biến trước, rồi mới WHERE Id = @ChiSo.
       2. BỎ công thức @MinMon/@MaxMon chỉ để ép tổng chi tiết đúng 5.000:
          phức tạp, khó giải thích khi vấn đáp, và làm lệch các hóa đơn ở cuối
          vòng lặp (bị ép còn 1 món). Đề chỉ yêu cầu ≥ 1.000 dòng.
          Thay bằng: mỗi hóa đơn 1–6 món, ngẫu nhiên đều.
       3. Thêm BƯỚC 5 minh họa INSERT / UPDATE / DELETE (Readme mục 3.2).
       4. Thêm chặn chạy lại (THROW 50012) và các kiểm tra bất biến (THROW 50013/50014).

   NGUYÊN TẮC
       - Dữ liệu hư cấu 100%, không dùng thông tin người thật.
       - KHÔNG sửa NguyenLieu.TonKho → giữ nguyên các dòng biên do 03a tạo.
       - Toàn bộ phần nạp dữ liệu nằm trong MỘT transaction: lỗi ở bất kỳ đâu
         thì rollback sạch, không để lại dữ liệu dở dang.
   ===================================================================== */

USE QL_CAFE_NHAHANG;
GO

SET NOCOUNT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* =================================================================
       BƯỚC 0. KIỂM TRA TIỀN ĐỀ + CHẶN CHẠY LẠI
       ================================================================= */

    IF NOT EXISTS (SELECT 1 FROM dbo.Ban)
        THROW 50001, N'Bảng Ban chưa có dữ liệu. Hãy chạy 03a_DanhMuc.sql trước.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.NhanVien WHERE ChucVu = N'PhucVu')
        THROW 50002, N'Không có nhân viên có ChucVu = PhucVu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Mon WHERE DangBan = 1)
        THROW 50003, N'Không có món nào có DangBan = 1.', 1;

    /*
       Bảng HoaDon dùng IDENTITY(MaHD) nên chạy lại script này sẽ sinh THÊM
       1.500 hóa đơn mới chứ không báo trùng. Chặn ngay từ đầu để tránh
       tình trạng mỗi bàn "Có khách" có 2 hóa đơn Mở (sai nghiệp vụ).
    */
    IF EXISTS (SELECT 1 FROM dbo.HoaDon)
        THROW 50012, N'Bảng HoaDon đã có dữ liệu: script này không tự xóa và không chống trùng. Hãy reset (03_RESET_DB.sql → 02_Bang.sql → 03a_DanhMuc.sql) rồi nạp lại.', 1;

    DECLARE @TongHD INT = 1500;          -- Tổng số hóa đơn cần sinh
    DECLARE @SoHDTrong INT = 5;          -- Số hóa đơn rỗng (không có chi tiết)

    /* ---- Danh sách bàn ---- */
    DECLARE @DSBan TABLE
    (
        Id    INT IDENTITY(1, 1) PRIMARY KEY,
        MaBan INT NOT NULL
    );

    INSERT INTO @DSBan (MaBan)
    SELECT MaBan FROM dbo.Ban;

    DECLARE @SoBan INT;
    SET @SoBan = @@ROWCOUNT;

    IF @SoBan = 0
        THROW 50004, N'Bảng Ban không có bản ghi nào.', 1;

    /* ---- Bàn đang có khách: mỗi bàn đúng 1 hóa đơn Mở ---- */
    DECLARE @DSBanMo TABLE
    (
        Id    INT IDENTITY(1, 1) PRIMARY KEY,
        MaBan INT NOT NULL
    );

    INSERT INTO @DSBanMo (MaBan)
    SELECT MaBan FROM dbo.Ban WHERE TrangThai = N'Có khách';

    DECLARE @SoBanMo INT;
    SET @SoBanMo = @@ROWCOUNT;

    /* ---- Nhân viên phục vụ (người lập hóa đơn) ---- */
    DECLARE @DSNV TABLE
    (
        Id   INT IDENTITY(1, 1) PRIMARY KEY,
        MaNV INT NOT NULL
    );

    INSERT INTO @DSNV (MaNV)
    SELECT MaNV FROM dbo.NhanVien WHERE ChucVu = N'PhucVu';

    DECLARE @SoNV INT;
    SET @SoNV = @@ROWCOUNT;

    IF @SoNV = 0
        THROW 50005, N'Không có nhân viên phục vụ.', 1;

    /*
       ---- Món được phép bán ----
       DangBan = 1 và loại 2 món cuối (MaMon 35, 36) để hai món này KHÔNG BAO GIỜ
       phát sinh giao dịch → phục vụ truy vấn "món chưa bán được lần nào".
    */
    DECLARE @MonHopLe TABLE
    (
        MaMon INT PRIMARY KEY,
        GiaBan DECIMAL(12, 0) NOT NULL
    );

    INSERT INTO @MonHopLe (MaMon, GiaBan)
    SELECT MaMon, GiaBan
    FROM dbo.Mon
    WHERE DangBan = 1
      AND MaMon NOT IN
      (
          SELECT TOP (2) MaMon
          FROM dbo.Mon
          ORDER BY MaMon DESC
      );

    DECLARE @SoMonHopLe INT;
    SET @SoMonHopLe = (SELECT COUNT(*) FROM @MonHopLe);

    IF @SoMonHopLe = 0
        THROW 50006, N'Không còn món hợp lệ sau khi loại 2 món cuối.', 1;

    -- Mỗi hóa đơn 1–6 món, nhưng không vượt quá số món hợp lệ đang có
    DECLARE @SoMonToiDa INT =
        CASE WHEN @SoMonHopLe >= 6 THEN 6 ELSE @SoMonHopLe END;

    /* ---- Ảnh chụp tồn kho để cuối script chứng minh phần giao dịch không sửa tồn kho ---- */
    DECLARE @TonKhoTruoc TABLE
    (
        MaNL       INT PRIMARY KEY,
        TonKho     DECIMAL(12, 2) NOT NULL,
        DinhMucTon DECIMAL(12, 2) NOT NULL,
        DonGiaNhap DECIMAL(12, 2) NOT NULL
    );

    INSERT INTO @TonKhoTruoc (MaNL, TonKho, DinhMucTon, DonGiaNhap)
    SELECT MaNL, TonKho, DinhMucTon, DonGiaNhap FROM dbo.NguyenLieu;

    /* =================================================================
       BƯỚC 1. XÁC ĐỊNH SỐ HÓA ĐƠN THEO TRẠNG THÁI
       ================================================================= */

    DECLARE @SoHDDong INT;
    SET @SoHDDong = @TongHD - @SoBanMo;          -- số hóa đơn đã đóng (Đã TT + Hủy)

    IF @SoBanMo > @SoHDDong
        THROW 50008, N'Số bàn đang có khách quá lớn so với số hóa đơn cần sinh.', 1;

    -- Khoảng 7% hóa đơn bị hủy
    DECLARE @SoHDHuy INT;
    SET @SoHDHuy = CAST(ROUND(@TongHD * 0.07, 0) AS INT);

    IF @SoHDHuy > @SoHDDong
        SET @SoHDHuy = @SoHDDong;

    DECLARE @SoHDDaTT INT;
    SET @SoHDDaTT = @SoHDDong - @SoHDHuy;        -- phần còn lại đã thanh toán

    /* =================================================================
       BƯỚC 2. HÓA ĐƠN "MỞ" CHO CÁC BÀN ĐANG CÓ KHÁCH
       ================================================================= */

    DECLARE @i INT;
    DECLARE @j INT;
    DECLARE @ChiSo INT;
    DECLARE @MaHD INT;
    DECLARE @MaBan INT;
    DECLARE @MaNV INT;
    DECLARE @MaMon INT;
    DECLARE @DonGia DECIMAL(12, 0);
    DECLARE @SoMon INT;
    DECLARE @NgayLap DATETIME;
    DECLARE @NgayOffset INT;
    DECLARE @Phut INT;
    DECLARE @R INT;
    DECLARE @TrangThai NVARCHAR(30);

    SET @i = 1;

    WHILE @i <= @SoBanMo
    BEGIN
        -- Bàn đang có khách thứ i
        SELECT @MaBan = MaBan
        FROM @DSBanMo
        WHERE Id = @i;

        /*
           LẤY NGẪU NHIÊN ĐÚNG CÁCH:
           tính chỉ số ra biến TRƯỚC, rồi mới so sánh với Id.
           (Bản cũ đặt CHECKSUM(NEWID()) ngay trong WHERE → mỗi dòng một số khác
            nhau, có thể không dòng nào khớp và @MaNV bị NULL.)
           CHECKSUM trả về INT nên phải CAST sang BIGINT trước khi ABS, tránh
           trường hợp ABS(INT_MIN) gây lỗi tràn số.
        */
        SET @ChiSo = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoNV AS INT);

        SELECT @MaNV = MaNV
        FROM @DSNV
        WHERE Id = @ChiSo;

        -- Hóa đơn Mở lập trong ngày hôm nay, TongTien tạm 0 (tính lại ở BƯỚC 4)
        SET @NgayLap = GETDATE();
        SET @TrangThai = N'Mở';

        INSERT INTO dbo.HoaDon (MaBan, MaNV, NgayLap, TrangThai, TongTien)
        VALUES (@MaBan, @MaNV, @NgayLap, @TrangThai, 0);

        SET @MaHD = CAST(SCOPE_IDENTITY() AS INT);

        -- Số món của hóa đơn: 1–6
        SET @SoMon = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoMonToiDa AS INT);
        SET @j = 1;

        WHILE @j <= @SoMon
        BEGIN
            /*
               Chọn ngẫu nhiên một món CHƯA có trong hóa đơn này.
               ORDER BY NEWID() ở đây là ĐÚNG (khác với @ChiSo ở trên): NEWID()
               nằm ở ORDER BY nên mỗi dòng được gán một khóa sắp xếp riêng,
               TOP (1) lấy ra đúng một dòng bất kỳ.
            */
            SELECT TOP (1)
                @MaMon = m.MaMon,
                @DonGia = m.GiaBan
            FROM @MonHopLe AS m
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM dbo.ChiTietHoaDon AS ct
                WHERE ct.MaHD = @MaHD
                  AND ct.MaMon = m.MaMon
            )
            ORDER BY NEWID();

            IF @@ROWCOUNT = 0
                THROW 50009, N'Không đủ món khác nhau cho một hóa đơn.', 1;

            -- Hóa đơn đang Mở: trạng thái chế biến lẫn "Chờ" và "Đang làm"
            INSERT INTO dbo.ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
            VALUES
            (
                @MaHD,
                @MaMon,
                1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 4 AS INT),
                @DonGia,
                CASE WHEN @j % 2 = 1 THEN N'Chờ' ELSE N'Đang làm' END
            );

            SET @j = @j + 1;
        END;

        SET @i = @i + 1;
    END;

    /* =================================================================
       BƯỚC 3. HÓA ĐƠN "ĐÃ THANH TOÁN" / "HỦY" TRONG 90 NGÀY GẦN NHẤT
       ================================================================= */

    SET @i = 1;

    WHILE @i <= @SoHDDong
    BEGIN
        -- Bàn ngẫu nhiên (cùng cách sửa lỗi như BƯỚC 2)
        SET @ChiSo = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoBan AS INT);
        SELECT @MaBan = MaBan FROM @DSBan WHERE Id = @ChiSo;

        -- Nhân viên phục vụ ngẫu nhiên
        SET @ChiSo = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoNV AS INT);
        SELECT @MaNV = MaNV FROM @DSNV WHERE Id = @ChiSo;

        -- Ngày lập: 0–89 ngày trước
        SET @NgayOffset = CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 90 AS INT);

        /*
           70% hóa đơn rơi vào giờ cao điểm (11h–12h59, 17h–19h59),
           30% còn lại rải đều 7h00–21h59.
        */
        SET @R = CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 100 AS INT);

        IF @R < 70
        BEGIN
            IF CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 2 AS INT) = 0
                SET @Phut = 11 * 60 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 120 AS INT);
            ELSE
                SET @Phut = 17 * 60 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 180 AS INT);
        END
        ELSE
        BEGIN
            SET @Phut = 7 * 60 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 900 AS INT);
        END;

        SET @NgayLap =
            DATEADD
            (
                MINUTE,
                @Phut,
                DATEADD(DAY, -@NgayOffset, CAST(CAST(GETDATE() AS DATE) AS DATETIME))
            );

        -- Không để hóa đơn đã đóng có thời điểm ở tương lai
        IF @NgayLap > GETDATE()
            SET @NgayLap = DATEADD(DAY, -1, @NgayLap);

        -- @SoHDDaTT hóa đơn đầu tiên: đã thanh toán; phần còn lại: hủy
        IF @i <= @SoHDDaTT
            SET @TrangThai = N'Đã thanh toán';
        ELSE
            SET @TrangThai = N'Hủy';

        INSERT INTO dbo.HoaDon (MaBan, MaNV, NgayLap, TrangThai, TongTien)
        VALUES (@MaBan, @MaNV, @NgayLap, @TrangThai, 0);

        SET @MaHD = CAST(SCOPE_IDENTITY() AS INT);

        /*
           5 hóa đơn CUỐI của nhóm đã đóng là hóa đơn rỗng (cố ý, để có dòng biên
           "hóa đơn không có chi tiết"). Các hóa đơn còn lại: 1–6 món.
        */
        IF @i <= @SoHDDong - @SoHDTrong
        BEGIN
            SET @SoMon = 1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % @SoMonToiDa AS INT);
            SET @j = 1;

            WHILE @j <= @SoMon
            BEGIN
                SELECT TOP (1)
                    @MaMon = m.MaMon,
                    @DonGia = m.GiaBan
                FROM @MonHopLe AS m
                WHERE NOT EXISTS
                (
                    SELECT 1
                    FROM dbo.ChiTietHoaDon AS ct
                    WHERE ct.MaHD = @MaHD
                      AND ct.MaMon = m.MaMon
                )
                ORDER BY NEWID();

                IF @@ROWCOUNT = 0
                    THROW 50010, N'Không đủ món khác nhau cho một hóa đơn.', 1;

                -- Hóa đơn đã đóng: mọi chi tiết đều "Xong"
                INSERT INTO dbo.ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
                VALUES
                (
                    @MaHD,
                    @MaMon,
                    1 + CAST(ABS(CAST(CHECKSUM(NEWID()) AS BIGINT)) % 4 AS INT),
                    @DonGia,
                    N'Xong'
                );

                SET @j = @j + 1;
            END;
        END;

        SET @i = @i + 1;
    END;

    /* =================================================================
       BƯỚC 4. TÍNH TongTien BẰNG MỘT CÂU UPDATE ... LEFT JOIN
       ================================================================= */

    UPDATE h
    SET TongTien = CAST(ISNULL(t.TongChiTiet, 0) AS DECIMAL(14, 0))
    FROM dbo.HoaDon AS h
    LEFT JOIN
    (
        SELECT
            MaHD,
            SUM(SoLuong * DonGia) AS TongChiTiet
        FROM dbo.ChiTietHoaDon
        GROUP BY MaHD
    ) AS t
        ON t.MaHD = h.MaHD;

    /* =================================================================
       BƯỚC 5. KIỂM TRA BẤT BIẾN NGAY TRONG TRANSACTION
       (sai thì rollback toàn bộ, không để dữ liệu nửa vời)
       ================================================================= */

    DECLARE @SoHDRongThucTe INT =
    (
        SELECT COUNT(*)
        FROM dbo.HoaDon AS h
        WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = h.MaHD)
    );

    IF @SoHDRongThucTe <> @SoHDTrong
        THROW 50013, N'Số hóa đơn rỗng không đúng cam kết (phải bằng 5).', 1;

    -- Mỗi bàn "Có khách" phải có đúng 1 hóa đơn Mở; bàn khác phải có 0
    IF EXISTS
    (
        SELECT 1
        FROM dbo.Ban AS b
        LEFT JOIN dbo.HoaDon AS h
            ON h.MaBan = b.MaBan
           AND h.TrangThai = N'Mở'
        GROUP BY b.MaBan, b.TrangThai
        HAVING SUM(CASE WHEN h.MaHD IS NOT NULL THEN 1 ELSE 0 END)
             <> CASE WHEN b.TrangThai = N'Có khách' THEN 1 ELSE 0 END
    )
        THROW 50014, N'Bất biến "mỗi bàn có khách đúng 1 hóa đơn Mở" bị vi phạm.', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;      -- ném lại đúng lỗi gốc để người chạy biết script đã hỏng
END CATCH;

/* =====================================================================
   BƯỚC 6. MINH HỌA INSERT / UPDATE / DELETE  (Readme mục 3.2)
   ---------------------------------------------------------------------
   Mỗi nhóm thao tác chạy trong transaction riêng và kết thúc ở trạng thái
   KHÔNG đổi dữ liệu, để bộ dữ liệu mẫu vẫn tái lập được:
     6.1  INSERT + UPDATE + DELETE trên Mon / MonAn (xóa con trước, cha sau)
     6.2  INSERT + UPDATE trên HoaDon / ChiTietHoaDon (nhiều bảng)
     6.3  DELETE rồi ROLLBACK — minh họa cách hủy thay đổi
   ===================================================================== */

DECLARE @MaLoaiDemo INT;
DECLARE @MaMonDemo INT;
DECLARE @MaHDDemo INT;
DECLARE @MonDemo1 INT;
DECLARE @MonDemo2 INT;

/* ---- 6.1. INSERT / UPDATE / DELETE trên bảng món ---- */
BEGIN TRY
    BEGIN TRANSACTION;

    SELECT TOP (1) @MaLoaiDemo = MaLoai
    FROM dbo.LoaiMon
    WHERE MaLoaiCha IS NOT NULL
    ORDER BY MaLoai;

    IF @MaLoaiDemo IS NULL
        THROW 50021, N'Không tìm được loại món để minh họa DML.', 1;

    -- INSERT: thêm 1 món ăn mới (kèm dòng chuyên biệt hóa trong MonAn)
    INSERT INTO dbo.Mon (TenMon, MaLoai, GiaBan, Nhom, DangBan)
    VALUES (N'Món minh họa DML (sẽ xóa)', @MaLoaiDemo, 49000, 'A', 0);

    SET @MaMonDemo = CAST(SCOPE_IDENTITY() AS INT);

    INSERT INTO dbo.MonAn (MaMon, ThoiGianCheBien, CayHayKhong)
    VALUES (@MaMonDemo, 10, 0);

    -- UPDATE: tăng giá món vừa thêm
    UPDATE dbo.Mon
    SET GiaBan = GiaBan + 5000
    WHERE MaMon = @MaMonDemo;

    SELECT N'6.1 — sau INSERT + UPDATE' AS Buoc,
           m.MaMon, m.TenMon, m.GiaBan, a.ThoiGianCheBien
    FROM dbo.Mon AS m
    JOIN dbo.MonAn AS a ON a.MaMon = m.MaMon
    WHERE m.MaMon = @MaMonDemo;

    -- DELETE: phải xóa bảng con (MonAn) trước bảng cha (Mon), nếu không sẽ lỗi FK
    DELETE FROM dbo.MonAn WHERE MaMon = @MaMonDemo;
    DELETE FROM dbo.Mon   WHERE MaMon = @MaMonDemo;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

/* ---- 6.2. INSERT / UPDATE trên nhiều bảng: hóa đơn + chi tiết ---- */
BEGIN TRY
    BEGIN TRANSACTION;

    -- Chọn một hóa đơn rỗng có sẵn để không phá bất biến "bàn có khách ↔ 1 hóa đơn Mở"
    SELECT TOP (1) @MaHDDemo = h.MaHD
    FROM dbo.HoaDon AS h
    WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = h.MaHD)
    ORDER BY h.MaHD;

    IF @MaHDDemo IS NULL
        THROW 50022, N'Không còn hóa đơn rỗng để minh họa DML.', 1;

    SELECT TOP (1) @MonDemo1 = MaMon FROM dbo.Mon WHERE DangBan = 1 ORDER BY MaMon;
    SELECT TOP (1) @MonDemo2 = MaMon FROM dbo.Mon WHERE DangBan = 1 AND MaMon <> @MonDemo1 ORDER BY MaMon;

    -- INSERT 2 dòng chi tiết
    INSERT INTO dbo.ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia, TrangThaiCheBien)
    SELECT @MaHDDemo, MaMon, 2, GiaBan, N'Chờ'
    FROM dbo.Mon
    WHERE MaMon IN (@MonDemo1, @MonDemo2);

    -- UPDATE: tính lại TongTien cho đúng hóa đơn vừa thêm chi tiết
    UPDATE h
    SET TongTien = CAST(ISNULL(t.TongChiTiet, 0) AS DECIMAL(14, 0))
    FROM dbo.HoaDon AS h
    LEFT JOIN
    (
        SELECT MaHD, SUM(SoLuong * DonGia) AS TongChiTiet
        FROM dbo.ChiTietHoaDon
        GROUP BY MaHD
    ) AS t
        ON t.MaHD = h.MaHD
    WHERE h.MaHD = @MaHDDemo;

    UPDATE dbo.ChiTietHoaDon
    SET TrangThaiCheBien = N'Xong'
    WHERE MaHD = @MaHDDemo;

    SELECT N'6.2 — sau INSERT + UPDATE' AS Buoc,
           h.MaHD, h.TrangThai, h.TongTien,
           (SELECT COUNT(*) FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = @MaHDDemo) AS SoDongChiTiet
    FROM dbo.HoaDon AS h
    WHERE h.MaHD = @MaHDDemo;

    -- Dọn về trạng thái ban đầu: xóa chi tiết rồi đưa TongTien về 0
    DELETE FROM dbo.ChiTietHoaDon WHERE MaHD = @MaHDDemo;
    UPDATE dbo.HoaDon SET TongTien = 0 WHERE MaHD = @MaHDDemo;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

/* ---- 6.3. DELETE một hóa đơn rỗng rồi ROLLBACK (minh họa hủy thay đổi) ---- */
BEGIN TRY
    BEGIN TRANSACTION;

    SELECT TOP (1) @MaHDDemo = h.MaHD
    FROM dbo.HoaDon AS h
    WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = h.MaHD)
    ORDER BY h.MaHD;

    DELETE FROM dbo.HoaDon WHERE MaHD = @MaHDDemo;

    SELECT N'6.3 — trong transaction (chưa rollback)' AS Buoc,
           (SELECT COUNT(*) FROM dbo.HoaDon) AS SoHoaDon;

    -- Cố ý hủy: đây chỉ là minh họa nên không để dữ liệu thay đổi
    ROLLBACK TRANSACTION;

    SELECT N'6.3 — sau ROLLBACK' AS Buoc,
           (SELECT COUNT(*) FROM dbo.HoaDon) AS SoHoaDon;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

/* =====================================================================
   BƯỚC 7. CÁC TRUY VẤN KIỂM TRA
   ===================================================================== */

-- 7.1 Số dòng từng bảng
SELECT N'Ban' AS Bang, COUNT(*) AS SoDong FROM dbo.Ban
UNION ALL SELECT N'NhanVien',       COUNT(*) FROM dbo.NhanVien
UNION ALL SELECT N'NguyenLieu',     COUNT(*) FROM dbo.NguyenLieu
UNION ALL SELECT N'Mon',            COUNT(*) FROM dbo.Mon
UNION ALL SELECT N'MonAn',          COUNT(*) FROM dbo.MonAn
UNION ALL SELECT N'ThucUong',       COUNT(*) FROM dbo.ThucUong
UNION ALL SELECT N'DinhLuong',      COUNT(*) FROM dbo.DinhLuong
UNION ALL SELECT N'HoaDon',         COUNT(*) FROM dbo.HoaDon
UNION ALL SELECT N'ChiTietHoaDon',  COUNT(*) FROM dbo.ChiTietHoaDon;

-- 7.2 Số hóa đơn theo trạng thái
SELECT TrangThai, COUNT(*) AS SoHoaDon
FROM dbo.HoaDon
GROUP BY TrangThai
ORDER BY TrangThai;

-- 7.3 Số hóa đơn rỗng (phải bằng 5)
SELECT COUNT(*) AS SoHoaDonRong
FROM dbo.HoaDon AS h
WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaHD = h.MaHD);

-- 7.4 Mỗi bàn có khách phải có đúng 1 hóa đơn Mở (kết quả phải RỖNG)
SELECT b.MaBan, b.TrangThai, COUNT(h.MaHD) AS SoHoaDonMo
FROM dbo.Ban AS b
LEFT JOIN dbo.HoaDon AS h
    ON h.MaBan = b.MaBan
   AND h.TrangThai = N'Mở'
GROUP BY b.MaBan, b.TrangThai
HAVING (b.TrangThai = N'Có khách' AND COUNT(h.MaHD) <> 1)
    OR (b.TrangThai <> N'Có khách' AND COUNT(h.MaHD) <> 0);

-- 7.5 Hóa đơn có TongTien lệch tổng chi tiết (kết quả phải RỖNG)
SELECT h.MaHD, h.TongTien, ISNULL(SUM(ct.SoLuong * ct.DonGia), 0) AS TongChiTiet
FROM dbo.HoaDon AS h
LEFT JOIN dbo.ChiTietHoaDon AS ct ON ct.MaHD = h.MaHD
GROUP BY h.MaHD, h.TongTien
HAVING h.TongTien <> ISNULL(SUM(ct.SoLuong * ct.DonGia), 0);

-- 7.6 Trùng khóa (MaHD, MaMon) — khóa chính đã chặn, kiểm tra cho chắc (phải RỖNG)
SELECT MaHD, MaMon, COUNT(*) AS SoLan
FROM dbo.ChiTietHoaDon
GROUP BY MaHD, MaMon
HAVING COUNT(*) > 1;

-- 7.7 Tồn kho KHÔNG bị thay đổi bởi phần giao dịch (phải bằng 0)
SELECT COUNT(*) AS SoNguyenLieuBiLech
FROM dbo.NguyenLieu AS nl
JOIN @TonKhoTruoc AS t ON t.MaNL = nl.MaNL
WHERE nl.TonKho <> t.TonKho
   OR nl.DinhMucTon <> t.DinhMucTon
   OR nl.DonGiaNhap <> t.DonGiaNhap;

-- 7.8 Các dòng biên tồn kho vẫn còn nguyên
SELECT
    SUM(CASE WHEN TonKho = 0 THEN 1 ELSE 0 END)                         AS TonKho_Bang0,
    SUM(CASE WHEN TonKho = DinhMucTon THEN 1 ELSE 0 END)                AS TonKho_BangDinhMuc,
    SUM(CASE WHEN TonKho > 0 AND TonKho < DinhMucTon THEN 1 ELSE 0 END) AS TonKho_DuoiDinhMuc,
    SUM(CASE WHEN TonKho > DinhMucTon THEN 1 ELSE 0 END)                AS TonKho_TrenDinhMuc
FROM dbo.NguyenLieu;

-- 7.9 Món chưa bán được lần nào (dòng biên cho truy vấn "món chưa phát sinh giao dịch")
SELECT m.MaMon, m.TenMon, m.DangBan
FROM dbo.Mon AS m
WHERE NOT EXISTS (SELECT 1 FROM dbo.ChiTietHoaDon AS ct WHERE ct.MaMon = m.MaMon)
ORDER BY m.MaMon;
