"""
test_csdl.py - Kiểm thử nhanh CSDL QL_CAFE_NHAHANG bằng Python (pyodbc)

Cài đặt:   pip install pyodbc
Chạy:      python test_csdl.py

Cấu hình kết nối (sửa hằng số bên dưới hoặc đặt biến môi trường):
  DB_SERVER   (mặc định: localhost)      ví dụ: localhost\\SQLEXPRESS
  DB_USER / DB_PASSWORD                  nếu dùng SQL Login (bỏ trống = Windows Authentication)
  DB_DRIVER   (mặc định: ODBC Driver 18 for SQL Server)

Script chia làm 4 nhóm kiểm tra:
  A. Số lượng dòng theo yêu cầu đề
  B. Tính nhất quán và dòng biên của dữ liệu
  C. Các lệnh cố tình vi phạm ràng buộc phải bị từ chối
  D. Đối tượng của nhóm (SP, function, trigger, view): có thì kiểm tra, chưa có thì bỏ qua
Mọi lệnh ghi dữ liệu trong script đều được ROLLBACK, không làm thay đổi CSDL.
"""
import os
import sys
from decimal import Decimal

import pyodbc

sys.stdout.reconfigure(encoding="utf-8")

SERVER = os.getenv("DB_SERVER", "localhost")
DATABASE = "QL_CAFE_NHAHANG"
USER = os.getenv("DB_USER")
PASSWORD = os.getenv("DB_PASSWORD")
DRIVER = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")

results = []  # (trạng thái, tên, chi tiết)


def connect():
    if USER:
        auth = f"UID={USER};PWD={PASSWORD}"
    else:
        auth = "Trusted_Connection=yes"
    conn_str = (
        f"DRIVER={{{DRIVER}}};SERVER={SERVER};DATABASE={DATABASE};"
        f"{auth};TrustServerCertificate=yes"
    )
    return pyodbc.connect(conn_str, autocommit=False)


def scalar(cur, sql):
    cur.execute(sql)
    return cur.fetchone()[0]


def record(status, name, detail=""):
    results.append((status, name, detail))
    icon = {"PASS": "[ OK ]", "FAIL": "[LỖI ]", "SKIP": "[BỎ QUA]"}[status]
    print(f"{icon} {name}" + (f"  ->  {detail}" if detail else ""))


def check(name, ok, detail=""):
    record("PASS" if ok else "FAIL", name, detail)


# ---------------------------------------------------------------- A. Số lượng
def test_so_luong(cur):
    print("\n=== A. SỐ LƯỢNG DÒNG ===")
    yeu_cau = {
        "LoaiMon": 10, "Ban": 10, "NhanVien": 10, "NguyenLieu": 10, "Mon": 10,
        "DinhLuong": 10, "HoaDon": 1000, "ChiTietHoaDon": 1000,
    }
    for bang, toi_thieu in yeu_cau.items():
        n = scalar(cur, f"SELECT COUNT(*) FROM {bang}")
        check(f"{bang} có >= {toi_thieu} dòng", n >= toi_thieu, f"hiện có {n}")


# ---------------------------------------------------------------- B. Nhất quán
def test_nhat_quan(cur):
    print("\n=== B. NHẤT QUÁN VÀ DÒNG BIÊN ===")

    n = scalar(cur, """
        SELECT COUNT(*) FROM Mon m
        WHERE (m.Nhom = 'A' AND NOT EXISTS (SELECT 1 FROM MonAn a WHERE a.MaMon = m.MaMon))
           OR (m.Nhom = 'U' AND NOT EXISTS (SELECT 1 FROM ThucUong t WHERE t.MaMon = m.MaMon))
           OR (m.Nhom = 'A' AND EXISTS (SELECT 1 FROM ThucUong t WHERE t.MaMon = m.MaMon))
           OR (m.Nhom = 'U' AND EXISTS (SELECT 1 FROM MonAn a WHERE a.MaMon = m.MaMon))""")
    check("Mon.Nhom khớp bảng con (MonAn / ThucUong)", n == 0, f"{n} món sai")

    n = scalar(cur, """
        SELECT COUNT(*) FROM (
            SELECT h.MaHD FROM HoaDon h
            LEFT JOIN ChiTietHoaDon ct ON ct.MaHD = h.MaHD
            GROUP BY h.MaHD, h.TongTien
            HAVING h.TongTien <> ISNULL(SUM(ct.SoLuong * ct.DonGia), 0)) x""")
    check("HoaDon.TongTien = tổng chi tiết", n == 0, f"{n} hóa đơn lệch")

    n = scalar(cur, """
        SELECT COUNT(*) FROM Ban b
        WHERE (b.TrangThai = N'Có khách' AND
               (SELECT COUNT(*) FROM HoaDon h WHERE h.MaBan = b.MaBan AND h.TrangThai = N'Mở') <> 1)
           OR (b.TrangThai <> N'Có khách' AND
               EXISTS (SELECT 1 FROM HoaDon h WHERE h.MaBan = b.MaBan AND h.TrangThai = N'Mở'))""")
    check("Bàn 'Có khách' có đúng 1 hóa đơn Mở, bàn khác không có", n == 0, f"{n} bàn sai")

    ty_le = scalar(cur, """
        SELECT 100.0 * SUM(CASE WHEN DATEPART(HOUR, NgayLap) IN (11,12,17,18,19) THEN 1 ELSE 0 END)
               / COUNT(*) FROM HoaDon WHERE TrangThai <> N'Mở'""")
    check("Hóa đơn tập trung giờ cao điểm (55%-85%)", 55 <= ty_le <= 85, f"{ty_le:.1f}%")

    # Dòng biên: mỗi truy vấn phải trả về >= 1
    bien = {
        "Có nguyên liệu TonKho = 0": "SELECT COUNT(*) FROM NguyenLieu WHERE TonKho = 0",
        "Có nguyên liệu TonKho = DinhMucTon": "SELECT COUNT(*) FROM NguyenLieu WHERE TonKho = DinhMucTon AND TonKho > 0",
        "Có nguyên liệu 0 < TonKho < DinhMucTon": "SELECT COUNT(*) FROM NguyenLieu WHERE TonKho > 0 AND TonKho < DinhMucTon",
        "Có nguyên liệu không dùng trong món nào": "SELECT COUNT(*) FROM NguyenLieu n WHERE NOT EXISTS (SELECT 1 FROM DinhLuong d WHERE d.MaNL = n.MaNL)",
        "Có món chưa từng được bán": "SELECT COUNT(*) FROM Mon m WHERE NOT EXISTS (SELECT 1 FROM ChiTietHoaDon c WHERE c.MaMon = m.MaMon)",
        "Có món DangBan = 0": "SELECT COUNT(*) FROM Mon WHERE DangBan = 0",
        "Có hóa đơn không có món": "SELECT COUNT(*) FROM HoaDon h WHERE NOT EXISTS (SELECT 1 FROM ChiTietHoaDon c WHERE c.MaHD = h.MaHD)",
        "Có hóa đơn Hủy": "SELECT COUNT(*) FROM HoaDon WHERE TrangThai = N'Hủy'",
        "Có bàn Trống, Có khách, Đã đặt": "SELECT COUNT(DISTINCT TrangThai) FROM Ban",
    }
    for ten, sql in bien.items():
        n = scalar(cur, sql)
        nguong = 3 if "Trống" in ten else 1
        check(ten, n >= nguong, f"kết quả {n}")

    # Kiểm tra DECIMAL(10,3) đã giữ đúng 0.018 (không bị làm tròn thành 0.02)
    cur.execute("SELECT SoLuong FROM DinhLuong WHERE MaMon = 20 AND MaNL = 18")
    row = cur.fetchone()
    if row is None:
        record("SKIP", "Định lượng không bị làm tròn (món 20, NL 18)", "không có dòng này trong dữ liệu")
    else:
        check("Định lượng không bị làm tròn (cà phê sữa đá = 0.018 kg)",
              row[0] == Decimal("0.018"), f"hiện là {row[0]}")


# ---------------------------------------------------------------- C. Vi phạm ràng buộc
VI_PHAM = [
    # (tên, danh sách lệnh, tên ràng buộc phải xuất hiện trong thông báo lỗi)
    ("CHECK: TonKho âm",
     ["INSERT INTO NguyenLieu (TenNL, DonViTinh, TonKho) VALUES (N'ZZ test', N'kg', -5)"],
     "CK_NL_TonKho"),
    ("CHECK: định lượng = 0",
     ["INSERT INTO DinhLuong (MaMon, MaNL, SoLuong) SELECT TOP 1 m.MaMon, n.MaNL, 0 "
      "FROM Mon m CROSS JOIN NguyenLieu n WHERE NOT EXISTS "
      "(SELECT 1 FROM DinhLuong d WHERE d.MaMon = m.MaMon AND d.MaNL = n.MaNL)"],
     "CK_DinhLuong_SoLuong"),
    ("CHECK: giá bán = 0 (sau ALTER phải > 0)",
     ["INSERT INTO Mon (TenMon, MaLoai, GiaBan, Nhom) VALUES (N'ZZ test', 1, 0, 'A')"],
     "CK_Mon_GiaBan"),
    ("CHECK: Size thức uống = 'X'",
     ["INSERT INTO Mon (TenMon, MaLoai, GiaBan, Nhom) VALUES (N'ZZ test', 1, 10000, 'U')",
      "INSERT INTO ThucUong (MaMon, Size) SELECT MaMon, 'X' FROM Mon WHERE TenMon = N'ZZ test'"],
     "CK_ThucUong_Size"),
    ("CHECK: trạng thái bàn sai",
     ["INSERT INTO Ban (TenBan, SucChua, TrangThai) VALUES (N'ZZ test', 4, N'Hỏng')"],
     "CK_Ban_TrangThai"),
    ("UNIQUE: trùng tên bàn",
     ["INSERT INTO Ban (TenBan, SucChua) SELECT TOP 1 TenBan, 4 FROM Ban"],
     "UQ_Ban_Ten"),
    ("UNIQUE: trùng tên món",
     ["INSERT INTO Mon (TenMon, MaLoai, GiaBan, Nhom) SELECT TOP 1 TenMon, MaLoai, GiaBan, Nhom FROM Mon"],
     "UQ_Mon_Ten"),
    ("PK: trùng (MaHD, MaMon) trong chi tiết hóa đơn",
     ["INSERT INTO ChiTietHoaDon (MaHD, MaMon, SoLuong, DonGia) "
      "SELECT TOP 1 MaHD, MaMon, 1, 1000 FROM ChiTietHoaDon"],
     "PK_ChiTietHoaDon"),
    ("FK: hóa đơn cho bàn không tồn tại",
     ["INSERT INTO HoaDon (MaBan, MaNV) VALUES (999999, 1)"],
     "FK_HoaDon_Ban"),
    ("NOT NULL: tên món rỗng",
     ["INSERT INTO Mon (TenMon, MaLoai, GiaBan, Nhom) VALUES (NULL, 1, 10000, 'A')"],
     "TenMon"),
]


def test_vi_pham(conn):
    print("\n=== C. VI PHẠM RÀNG BUỘC (phải bị từ chối) ===")
    cur = conn.cursor()
    for ten, lenh, rang_buoc in VI_PHAM:
        thong_bao = None
        try:
            for sql in lenh:
                cur.execute(sql)
        except pyodbc.Error as e:
            thong_bao = str(e)
        finally:
            conn.rollback()
        if thong_bao is None:
            record("FAIL", ten, "lệnh sai vẫn được chấp nhận!")
        elif rang_buoc in thong_bao:
            record("PASS", ten, f"bị từ chối bởi {rang_buoc}")
        else:
            record("FAIL", ten, f"bị từ chối nhưng không phải do {rang_buoc}: {thong_bao[:120]}")


# ---------------------------------------------------------------- D. Đối tượng của nhóm
DOI_TUONG = {
    "procedure": ["sp_GoiMon", "sp_ThanhToan", "sp_NhapKho", "sp_BaoCaoDoanhThu", "sp_HuyHoaDon"],
    "function": ["fn_GiaVonMon", "fn_MonBanTheoNgay", "fn_NguyenLieuDuoiDinhMuc"],
    "trigger": ["trg_ChanTonAm", "trg_BanCoKhach", "trg_CapNhatTrangThaiBan"],
    "view": ["vw_MonCanCheBien"],
}
LOAI = {"procedure": "P", "function": "FN','IF','TF", "trigger": "TR", "view": "V"}


def ton_tai(cur, ten, loai):
    n = scalar(cur, f"SELECT COUNT(*) FROM sys.objects WHERE name = '{ten}' AND type IN ('{LOAI[loai]}')")
    return n > 0


def test_doi_tuong(conn):
    print("\n=== D. ĐỐI TƯỢNG CỦA NHÓM (chưa có thì bỏ qua) ===")
    cur = conn.cursor()
    co = set()
    for loai, ds in DOI_TUONG.items():
        for ten in ds:
            if ton_tai(cur, ten, loai):
                record("PASS", f"Có {loai} {ten}")
                co.add(ten)
            else:
                record("SKIP", f"Chưa có {loai} {ten}")

    # fn_GiaVonMon (vô hướng): so với phép tính trực tiếp bằng SQL
    if "fn_GiaVonMon" in co:
        mong_doi = scalar(cur, """
            SELECT SUM(d.SoLuong * n.DonGiaNhap) FROM DinhLuong d
            JOIN NguyenLieu n ON n.MaNL = d.MaNL WHERE d.MaMon = 20""")
        thuc_te = scalar(cur, "SELECT dbo.fn_GiaVonMon(20)")
        check("fn_GiaVonMon(20) khớp phép tính tay",
              abs(Decimal(thuc_te) - Decimal(mong_doi)) < Decimal("0.01"),
              f"hàm = {thuc_te}, tính tay = {mong_doi}")

    # fn_NguyenLieuDuoiDinhMuc (bảng): số dòng = số nguyên liệu có TonKho < DinhMucTon
    if "fn_NguyenLieuDuoiDinhMuc" in co:
        mong_doi = scalar(cur, "SELECT COUNT(*) FROM NguyenLieu WHERE TonKho < DinhMucTon")
        thuc_te = scalar(cur, "SELECT COUNT(*) FROM dbo.fn_NguyenLieuDuoiDinhMuc()")
        check("fn_NguyenLieuDuoiDinhMuc trả đúng số nguyên liệu dưới định mức",
              mong_doi == thuc_te,
              f"hàm = {thuc_te}, truy vấn tay = {mong_doi} (đổi '<' thành '<=' nếu nhóm tính cả bằng định mức)")

    # Trigger chặn tồn âm: UPDATE nhiều dòng, trong đó có dòng làm tồn âm -> phải bị chặn
    if "trg_ChanTonAm" in co:
        loi = None
        try:
            cur.execute("UPDATE NguyenLieu SET TonKho = TonKho - 1000000")
        except pyodbc.Error as e:
            loi = str(e)
        finally:
            conn.rollback()
        check("trg_ChanTonAm chặn UPDATE nhiều dòng làm tồn âm", loi is not None,
              "đã bị chặn" if loi else "UPDATE vẫn chạy được!")

    # Tồn kho phải còn nguyên sau các thử nghiệm trên (do đã rollback)
    n = scalar(cur, "SELECT COUNT(*) FROM NguyenLieu WHERE TonKho < 0")
    check("Không có nguyên liệu nào tồn âm sau khi test", n == 0, f"{n} dòng âm")

    # ----- Mẫu thử sp_GoiMon: CHỈNH THAM SỐ THEO CHỮ KÝ THỦ TỤC CỦA NHÓM -----
    # if "sp_GoiMon" in co:
    #     # Ca sai: món 9 (phở bò) cần thịt bò, mà thịt bò tồn = 0 -> phải lỗi và tồn kho không đổi
    #     truoc = scalar(cur, "SELECT SUM(TonKho) FROM NguyenLieu")
    #     try:
    #         cur.execute("EXEC sp_GoiMon @MaHD = ?, @MaMon = ?, @SoLuong = ?", (MA_HD_MO, 9, 1))
    #         loi = None
    #     except pyodbc.Error as e:
    #         loi = str(e)
    #     finally:
    #         conn.rollback()
    #     sau = scalar(cur, "SELECT SUM(TonKho) FROM NguyenLieu")
    #     check("sp_GoiMon từ chối khi thiếu nguyên liệu và không trừ kho", loi is not None and truoc == sau)


def main():
    try:
        conn = connect()
    except pyodbc.Error as e:
        print("Không kết nối được SQL Server:", e)
        print("Kiểm tra DB_SERVER / DB_DRIVER và xem CSDL đã được tạo chưa.")
        sys.exit(2)

    cur = conn.cursor()
    test_so_luong(cur)
    test_nhat_quan(cur)
    test_vi_pham(conn)
    test_doi_tuong(conn)
    conn.close()

    dat = sum(1 for s, _, _ in results if s == "PASS")
    loi = [r for r in results if r[0] == "FAIL"]
    bo_qua = sum(1 for s, _, _ in results if s == "SKIP")
    print(f"\n=== TỔNG KẾT: {dat} đạt, {len(loi)} lỗi, {bo_qua} bỏ qua ===")
    for _, ten, chi_tiet in loi:
        print(f"  - {ten}: {chi_tiet}")
    sys.exit(1 if loi else 0)


if __name__ == "__main__":
    main()