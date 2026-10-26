USE QL_CAFE_NHAHANG;
GO

DROP TABLE IF EXISTS ChiTietHoaDon;
DROP TABLE IF EXISTS HoaDon;
DROP TABLE IF EXISTS DinhLuong;
DROP TABLE IF EXISTS MonAn;
DROP TABLE IF EXISTS ThucUong;
DROP TABLE IF EXISTS Mon;
DROP TABLE IF EXISTS NguyenLieu;
DROP TABLE IF EXISTS NhanVien;
DROP TABLE IF EXISTS Ban;
DROP TABLE IF EXISTS LoaiMon;
GO

-- Loại Món
CREATE TABLE LoaiMon (
    MaLoai      INT IDENTITY(1,1) NOT NULL,
    TenLoai     NVARCHAR(50) NOT NULL,
    MaLoaiCha   INT NULL, -- Mã loại (Cha) - FK tự tham chiếu hoặc Null nếu là loại gốc
    CONSTRAINT PK_LoaiMon PRIMARY KEY (MaLoai),
    CONSTRAINT UQ_LoaiMon_Ten UNIQUE (TenLoai),
    CONSTRAINT FK_LoaiMon_Cha FOREIGN KEY (MaLoaiCha) REFERENCES LoaiMon(MaLoai)
);
-- Bàn
CREATE TABLE Ban (
    MaBan       INT IDENTITY(1,1) NOT NULL,
    TenBan      NVARCHAR(20) NOT NULL,
    SucChua     TINYINT NOT NULL,
    TrangThai   NVARCHAR(10) NOT NULL CONSTRAINT DF_Ban_TrangThai DEFAULT N'Trống',
    CONSTRAINT PK_Ban PRIMARY KEY (MaBan),
    CONSTRAINT UQ_Ban_Ten UNIQUE (TenBan),
    CONSTRAINT CK_Ban_SucChua CHECK (SucChua > 0),
    CONSTRAINT CK_Ban_TrangThai CHECK (TrangThai IN (N'Trống', N'Có khách', N'Đã đặt'))
);
-- Nhân Viên
CREATE TABLE NhanVien (
    MaNV        INT IDENTITY(1,1) NOT NULL,
    HoTen       NVARCHAR(100) NOT NULL,
    ChucVu      NVARCHAR(20) NOT NULL,
    SoDienThoai VARCHAR(15) NULL,
    CONSTRAINT PK_NhanVien PRIMARY KEY (MaNV),
    CONSTRAINT CK_NhanVien_ChucVu CHECK (ChucVu IN (N'PhucVu', N'ThuNgan', N'Bep', N'QuanLy'))
);
-- Nguyên liệu
CREATE TABLE NguyenLieu (
    MaNL        INT IDENTITY(1,1) NOT NULL,
    TenNL       NVARCHAR(100) NOT NULL,
    DonViTinh   NVARCHAR(10) NOT NULL,
    TonKho      DECIMAL(12,2) NOT NULL CONSTRAINT DF_NL_TonKho DEFAULT 0,
    DinhMucTon  DECIMAL(12,2) NOT NULL CONSTRAINT DF_NL_DinhMuc DEFAULT 0,
    DonGiaNhap  DECIMAL(12,2) NOT NULL CONSTRAINT DF_NL_DonGia DEFAULT 0,
    CONSTRAINT PK_NguyenLieu PRIMARY KEY (MaNL),
    CONSTRAINT UQ_NguyenLieu_Ten UNIQUE (TenNL),
    CONSTRAINT CK_NL_TonKho CHECK (TonKho >= 0),
    CONSTRAINT CK_NL_DonGia CHECK (DonGiaNhap >= 0)
);
GO

-- ---------- 2. Món và chuyên biệt hóa (đồ ăn / thức uống) ----------
-- Món
CREATE TABLE Mon (
    MaMon       INT IDENTITY(1,1) NOT NULL,
    TenMon      NVARCHAR(100) NOT NULL,
    MaLoai      INT NOT NULL,
    GiaBan      DECIMAL(12,0) NOT NULL,
    Nhom        CHAR(1) NOT NULL,           -- 'A' = đồ ăn, 'U' = thức uống
    DangBan     BIT NOT NULL CONSTRAINT DF_Mon_DangBan DEFAULT 1,
    CONSTRAINT PK_Mon PRIMARY KEY (MaMon),
    CONSTRAINT UQ_Mon_Ten UNIQUE (TenMon),
    CONSTRAINT FK_Mon_LoaiMon FOREIGN KEY (MaLoai) REFERENCES LoaiMon(MaLoai),
    CONSTRAINT CK_Mon_GiaBan CHECK (GiaBan >= 0),
    CONSTRAINT CK_Mon_Nhom CHECK (Nhom IN ('A', 'U'))
);

-- Món Ăn
CREATE TABLE MonAn (
    MaMon           INT NOT NULL,
    ThoiGianCheBien INT NOT NULL,           -- phút
    CayHayKhong     BIT NOT NULL CONSTRAINT DF_MonAn_Cay DEFAULT 0,
    CONSTRAINT PK_MonAn PRIMARY KEY (MaMon),
    CONSTRAINT FK_MonAn_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon),
    CONSTRAINT CK_MonAn_ThoiGian CHECK (ThoiGianCheBien > 0)
);
-- Thức uống
CREATE TABLE ThucUong (
    MaMon       INT NOT NULL,
    Size        CHAR(1) NOT NULL CONSTRAINT DF_ThucUong_Size DEFAULT 'M',
    CoDa        BIT NOT NULL CONSTRAINT DF_ThucUong_Da DEFAULT 1,
    CoDuong     BIT NOT NULL CONSTRAINT DF_ThucUong_Duong DEFAULT 1,
    CONSTRAINT PK_ThucUong PRIMARY KEY (MaMon),
    CONSTRAINT FK_ThucUong_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon),
    CONSTRAINT CK_ThucUong_Size CHECK (Size IN ('S', 'M', 'L'))
);
GO

-- ---------- 3. Định lượng (Món - Nguyên liệu, N-N) ----------

CREATE TABLE DinhLuong (
    MaMon       INT NOT NULL,
    MaNL        INT NOT NULL,
    SoLuong     DECIMAL(12,3) NOT NULL,     -- lượng nguyên liệu cho 1 phần món
    CONSTRAINT PK_DinhLuong PRIMARY KEY (MaMon, MaNL),
    CONSTRAINT FK_DinhLuong_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon),
    CONSTRAINT FK_DinhLuong_NL FOREIGN KEY (MaNL) REFERENCES NguyenLieu(MaNL),
    CONSTRAINT CK_DinhLuong_SoLuong CHECK (SoLuong > 0)
);
GO

-- ---------- 4. Quản lý giao dịch ----------
-- Hoá đơn
CREATE TABLE HoaDon (
    MaHD        INT IDENTITY(1,1) NOT NULL,
    MaBan       INT NOT NULL,
    MaNV        INT NOT NULL,
    NgayLap     DATETIME NOT NULL CONSTRAINT DF_HoaDon_NgayLap DEFAULT GETDATE(),
    TrangThai   NVARCHAR(15) NOT NULL CONSTRAINT DF_HoaDon_TrangThai DEFAULT N'Mở',
    TongTien    DECIMAL(14,0) NOT NULL CONSTRAINT DF_HoaDon_TongTien DEFAULT 0,
    CONSTRAINT PK_HoaDon PRIMARY KEY (MaHD),
    CONSTRAINT FK_HoaDon_Ban FOREIGN KEY (MaBan) REFERENCES Ban(MaBan),
    CONSTRAINT FK_HoaDon_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    CONSTRAINT CK_HoaDon_TrangThai CHECK (TrangThai IN (N'Mở', N'Đã thanh toán', N'Hủy')),
    CONSTRAINT CK_HoaDon_TongTien CHECK (TongTien >= 0)
);
-- CHi tiết hoá đơn 
CREATE TABLE ChiTietHoaDon (
    MaHD             INT NOT NULL,
    MaMon            INT NOT NULL,
    SoLuong          INT NOT NULL,
    DonGia           DECIMAL(12,0) NOT NULL,   -- chép giá bán tại thời điểm gọi
    TrangThaiCheBien NVARCHAR(15) NOT NULL CONSTRAINT DF_CTHD_TrangThai DEFAULT N'Chờ',
    CONSTRAINT PK_ChiTietHoaDon PRIMARY KEY (MaHD, MaMon),
    CONSTRAINT FK_CTHD_HoaDon FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD),
    CONSTRAINT FK_CTHD_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon),
    CONSTRAINT CK_CTHD_SoLuong CHECK (SoLuong > 0),
    CONSTRAINT CK_CTHD_DonGia CHECK (DonGia >= 0),
    CONSTRAINT CK_CTHD_TrangThai CHECK (TrangThaiCheBien IN (N'Chờ', N'Đang làm', N'Xong'))
);
GO

ALTER TABLE NguyenLieu
    ADD CONSTRAINT CK_NL_DinhMuc CHECK (DinhMucTon >= 0);

ALTER TABLE NhanVien
    ADD NgayVaoLam DATE NOT NULL CONSTRAINT DF_NhanVien_NgayVaoLam DEFAULT GETDATE();

CREATE UNIQUE INDEX UX_NhanVien_SDT ON NhanVien(SoDienThoai) WHERE SoDienThoai IS NOT NULL;

ALTER TABLE Mon DROP CONSTRAINT CK_Mon_GiaBan;
ALTER TABLE Mon ADD CONSTRAINT CK_Mon_GiaBan CHECK (GiaBan > 0);
GO
