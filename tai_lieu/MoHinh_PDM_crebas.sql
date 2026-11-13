/*==============================================================*/
/* DBMS name:      Microsoft SQL Server 2016                    */
/* Created on:     12/11/2026 11:12:01 CH                       */
/*==============================================================*/


if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('CHITIETHOADON') and o.name = 'FK_CTHD_HoaDon')
alter table CHITIETHOADON
   drop constraint FK_CTHD_HoaDon
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('CHITIETHOADON') and o.name = 'FK_CTHD_Mon')
alter table CHITIETHOADON
   drop constraint FK_CTHD_Mon
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('DINHLUONG') and o.name = 'FK_DinhLuong_NL')
alter table DINHLUONG
   drop constraint FK_DinhLuong_NL
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('DINHLUONG') and o.name = 'FK_DinhLuong_Mon')
alter table DINHLUONG
   drop constraint FK_DinhLuong_Mon
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('HOADON') and o.name = 'FK_HoaDon_NhanVien')
alter table HOADON
   drop constraint FK_HoaDon_NhanVien
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('HOADON') and o.name = 'FK_HoaDon_Ban')
alter table HOADON
   drop constraint FK_HoaDon_Ban
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('LOAIMON') and o.name = 'FK_LoaiMon_Cha')
alter table LOAIMON
   drop constraint FK_LoaiMon_Cha
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('MON') and o.name = 'FK_Mon_LoaiMon')
alter table MON
   drop constraint FK_Mon_LoaiMon
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('MONAN') and o.name = 'FK_MonAn_Mon')
alter table MONAN
   drop constraint FK_MonAn_Mon
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('THUCUONG') and o.name = 'FK_ThucUong_Mon')
alter table THUCUONG
   drop constraint FK_ThucUong_Mon
go

if exists (select 1
            from  sysobjects
           where  id = object_id('BAN')
            and   type = 'U')
   drop table BAN
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('CHITIETHOADON')
            and   name  = 'CHITIETHOADON2_FK'
            and   indid > 0
            and   indid < 255)
   drop index CHITIETHOADON.CHITIETHOADON2_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('CHITIETHOADON')
            and   type = 'U')
   drop table CHITIETHOADON
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('DINHLUONG')
            and   name  = 'DINHLUONG2_FK'
            and   indid > 0
            and   indid < 255)
   drop index DINHLUONG.DINHLUONG2_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('DINHLUONG')
            and   type = 'U')
   drop table DINHLUONG
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('HOADON')
            and   name  = 'LAP_FK'
            and   indid > 0
            and   indid < 255)
   drop index HOADON.LAP_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('HOADON')
            and   name  = 'PHUCVU_FK'
            and   indid > 0
            and   indid < 255)
   drop index HOADON.PHUCVU_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('HOADON')
            and   type = 'U')
   drop table HOADON
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('LOAIMON')
            and   name  = 'COCHA_FK'
            and   indid > 0
            and   indid < 255)
   drop index LOAIMON.COCHA_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('LOAIMON')
            and   type = 'U')
   drop table LOAIMON
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('MON')
            and   name  = 'PHANLOAI_FK'
            and   indid > 0
            and   indid < 255)
   drop index MON.PHANLOAI_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('MON')
            and   type = 'U')
   drop table MON
go

if exists (select 1
            from  sysobjects
           where  id = object_id('MONAN')
            and   type = 'U')
   drop table MONAN
go

if exists (select 1
            from  sysobjects
           where  id = object_id('NGUYENLIEU')
            and   type = 'U')
   drop table NGUYENLIEU
go

if exists (select 1
            from  sysobjects
           where  id = object_id('NHANVIEN')
            and   type = 'U')
   drop table NHANVIEN
go

if exists (select 1
            from  sysobjects
           where  id = object_id('THUCUONG')
            and   type = 'U')
   drop table THUCUONG
go

/*==============================================================*/
/* Table: BAN                                                   */
/*==============================================================*/
create table BAN (
   MABAN                int                  identity,
   TENBAN               nvarchar(20)         not null,
   SUCCHUA              tinyint              not null,
   TRANGTHAI            nvarchar(10)         not null,
   constraint PK_BAN primary key (MABAN)
)
go

/*==============================================================*/
/* Table: CHITIETHOADON                                         */
/*==============================================================*/
create table CHITIETHOADON (
   MAHD                 int                  not null,
   MAMON                int                  not null,
   DONGIA               decimal(12,0)        not null,
   TRANGTHAICHEBIEN     nvarchar(15)         not null,
   SOLUONG              int                  not null,
   constraint PK_CHITIETHOADON primary key (MAHD, MAMON)
)
go

/*==============================================================*/
/* Index: CHITIETHOADON2_FK                                     */
/*==============================================================*/




create nonclustered index CHITIETHOADON2_FK on CHITIETHOADON (MAMON ASC)
go

/*==============================================================*/
/* Table: DINHLUONG                                             */
/*==============================================================*/
create table DINHLUONG (
   MAMON                int                  not null,
   MANL                 int                  not null,
   SOLUONG              decimal(12,3)        not null,
   constraint PK_DINHLUONG primary key (MANL, MAMON)
)
go

/*==============================================================*/
/* Index: DINHLUONG2_FK                                         */
/*==============================================================*/




create nonclustered index DINHLUONG2_FK on DINHLUONG (MAMON ASC)
go

/*==============================================================*/
/* Table: HOADON                                                */
/*==============================================================*/
create table HOADON (
   MAHD                 int                  identity,
   MABAN                int                  not null,
   MANV                 int                  not null,
   NGAYLAP              datetime             not null,
   TONGTIEN             decimal(14,0)        not null,
   TRANGTHAI            nvarchar(15)         not null,
   constraint PK_HOADON primary key (MAHD)
)
go

/*==============================================================*/
/* Index: PHUCVU_FK                                             */
/*==============================================================*/




create nonclustered index PHUCVU_FK on HOADON (MABAN ASC)
go

/*==============================================================*/
/* Index: LAP_FK                                                */
/*==============================================================*/




create nonclustered index LAP_FK on HOADON (MANV ASC)
go

/*==============================================================*/
/* Table: LOAIMON                                               */
/*==============================================================*/
create table LOAIMON (
   MALOAI               int                  identity,
   MALOAICHA            int                  null,
   TENLOAI              nvarchar(50)         not null,
   constraint PK_LOAIMON primary key (MALOAI)
)
go

/*==============================================================*/
/* Index: COCHA_FK                                              */
/*==============================================================*/




create nonclustered index COCHA_FK on LOAIMON (MALOAICHA ASC)
go

/*==============================================================*/
/* Table: MON                                                   */
/*==============================================================*/
create table MON (
   MAMON                int                  identity,
   MALOAI               int                  not null,
   TENMON               nvarchar(100)        not null,
   GIABAN               decimal(12,0)        not null,
   NHOM                 char(1)              not null,
   DANGBAN              bit                  not null,
   constraint PK_MON primary key (MAMON)
)
go

/*==============================================================*/
/* Index: PHANLOAI_FK                                           */
/*==============================================================*/




create nonclustered index PHANLOAI_FK on MON (MALOAI ASC)
go

/*==============================================================*/
/* Table: MONAN                                                 */
/*==============================================================*/
create table MONAN (
   MAMON                int                  not null,
   THOIGIANCHEBIEN      int                  not null,
   CAYHAYKHONG          bit                  not null,
   constraint PK_MONAN primary key (MAMON)
)
go

/*==============================================================*/
/* Table: NGUYENLIEU                                            */
/*==============================================================*/
create table NGUYENLIEU (
   MANL                 int                  identity,
   TENNL                nvarchar(100)        not null,
   DONVITINH            nvarchar(10)         not null,
   TONKHO               decimal(12,2)        not null,
   DINHMUCTON           decimal(12,2)        not null,
   DONGIANHAP           decimal(12,2)        not null,
   constraint PK_NGUYENLIEU primary key (MANL)
)
go

/*==============================================================*/
/* Table: NHANVIEN                                              */
/*==============================================================*/
create table NHANVIEN (
   MANV                 int                  identity,
   HOTEN                nvarchar(100)        not null,
   CHUCVU               nvarchar(20)         not null,
   SODIENTHOAI          varchar(15)          null,
   NGAYVAOLAM           date                 not null,
   constraint PK_NHANVIEN primary key (MANV)
)
go

/*==============================================================*/
/* Table: THUCUONG                                              */
/*==============================================================*/
create table THUCUONG (
   MAMON                int                  not null,
   SIZE                 char(1)              not null,
   CODA                 bit                  not null,
   CODUONG              bit                  not null,
   constraint PK_THUCUONG primary key (MAMON)
)
go

alter table CHITIETHOADON
   add constraint FK_CTHD_HoaDon foreign key (MAHD)
      references HOADON (MAHD)
go

alter table CHITIETHOADON
   add constraint FK_CTHD_Mon foreign key (MAMON)
      references MON (MAMON)
go

alter table DINHLUONG
   add constraint FK_DinhLuong_NL foreign key (MANL)
      references NGUYENLIEU (MANL)
go

alter table DINHLUONG
   add constraint FK_DinhLuong_Mon foreign key (MAMON)
      references MON (MAMON)
go

alter table HOADON
   add constraint FK_HoaDon_NhanVien foreign key (MANV)
      references NHANVIEN (MANV)
go

alter table HOADON
   add constraint FK_HoaDon_Ban foreign key (MABAN)
      references BAN (MABAN)
go

alter table LOAIMON
   add constraint FK_LoaiMon_Cha foreign key (MALOAICHA)
      references LOAIMON (MALOAI)
go

alter table MON
   add constraint FK_Mon_LoaiMon foreign key (MALOAI)
      references LOAIMON (MALOAI)
go

alter table MONAN
   add constraint FK_MonAn_Mon foreign key (MAMON)
      references MON (MAMON)
go

alter table THUCUONG
   add constraint FK_ThucUong_Mon foreign key (MAMON)
      references MON (MAMON)
go

