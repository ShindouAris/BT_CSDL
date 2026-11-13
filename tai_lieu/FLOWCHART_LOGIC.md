# Flowchart logic nghiệp vụ

Sơ đồ luồng xử lý của các đối tượng chính trong CSDL `QL_CAFE_NHAHANG`, vẽ từ mã trong
[`sql/05_ThuTuc_Ham.sql`](../sql/05_ThuTuc_Ham.sql) và [`sql/06_Trigger_GiaoTac.sql`](../sql/06_Trigger_GiaoTac.sql).
Các sơ đồ dùng Mermaid, hiển thị trực tiếp trên GitHub.

Quy ước: hình thoi là điều kiện kiểm tra; ô đỏ nhạt là lỗi (`THROW`, kèm mã lỗi); ô xanh nhạt là kết thúc thành công.

## Mục lục

1. [Vòng đời hóa đơn và trạng thái bàn](#1-vòng-đời-hóa-đơn-và-trạng-thái-bàn)
2. [`sp_MoHoaDon`](#2-sp_mohoadon)
3. [`sp_GoiMon`](#3-sp_goimon)
4. [`sp_ThanhToan`](#4-sp_thanhtoan)
5. [`sp_HuyHoaDon`](#5-sp_huyhoadon)
6. [`sp_ThongKeDoanhThu`](#6-sp_thongkedoanhthu)
7. [`fn_DanhSachMonTheoLoai`](#7-fn_danhsachmontheoloai)
8. [Trigger `trg_ChiTietHoaDon_KiemTraNguyenLieu` (TR01)](#8-trigger-trg_chitiethoadon_kiemtranguyenlieu-tr01)
9. [Trigger `trg_HoaDon_CapNhatBan` (TR02)](#9-trigger-trg_hoadon_capnhatban-tr02)
10. [Trigger `trg_Mon_KiemTraXoa` (TR03)](#10-trigger-trg_mon_kiemtraxoa-tr03)
11. [Giao tác GT01: gọi nhiều món (all-or-nothing)](#11-giao-tác-gt01-gọi-nhiều-món-all-or-nothing)
12. [Giao tác GT02: thanh toán có SAVEPOINT](#12-giao-tác-gt02-thanh-toán-có-savepoint)

---

## 1. Vòng đời hóa đơn và trạng thái bàn

Tổng quan cách các thủ tục và trigger phối hợp. Trạng thái bàn do `sp_*` và trigger `trg_HoaDon_CapNhatBan` cùng giữ đồng bộ.

```mermaid
stateDiagram-v2
    direction LR
    [*] --> BanTrong
    BanTrong: Bàn Trống
    BanCoKhach: Bàn Có khách
    HDMo: Hóa đơn Mở
    HDThanhToan: Hóa đơn Đã thanh toán
    HDHuy: Hóa đơn Hủy

    BanTrong --> BanCoKhach: sp_MoHoaDon
    BanCoKhach --> HDMo: tạo hóa đơn Mở
    HDMo --> HDMo: sp_GoiMon (trừ kho)
    HDMo --> HDThanhToan: sp_ThanhToan
    HDMo --> HDHuy: sp_HuyHoaDon (hoàn kho)
    HDThanhToan --> BanTrong: bàn về Trống
    HDHuy --> BanTrong: bàn về Trống
```

---

## 2. `sp_MoHoaDon`

Mở hóa đơn mới cho một bàn. Tham số: `@MaBan`, `@MaNV`, `@MaHD OUTPUT`.

```mermaid
flowchart TD
    A([Bắt đầu]) --> B[BEGIN TRANSACTION]
    B --> C{Bàn có tồn tại?}
    C -- Không --> E1[/"THROW 50020: Bàn không tồn tại"/]
    C -- Có --> D{"Nhân viên tồn tại<br/>và ChucVu = PhucVu?"}
    D -- Không --> E2[/"THROW 50021: Nhân viên không hợp lệ"/]
    D -- Có --> F{"Bàn đang ở trạng thái Trống?"}
    F -- Không --> E3[/"THROW 50022: Bàn không Trống"/]
    F -- Có --> G["INSERT HoaDon<br/>(TrangThai = Mở, TongTien = 0)"]
    G --> H["@MaHD = SCOPE_IDENTITY()"]
    H --> I["UPDATE Ban → Có khách"]
    I --> J[COMMIT]
    J --> K([Kết thúc, trả @MaHD])

    E1 --> R
    E2 --> R
    E3 --> R
    R["CATCH: ROLLBACK nếu còn giao tác<br/>rồi THROW lại lỗi"] --> Z([Kết thúc với lỗi])

    classDef loi fill:#fde2e2,stroke:#c0392b,color:#000;
    classDef ok fill:#e1f5e1,stroke:#27ae60,color:#000;
    class E1,E2,E3,R,Z loi;
    class K ok;
```

---

## 3. `sp_GoiMon`

Gọi một món vào hóa đơn đang mở. Tham số: `@MaHD`, `@MaMon`, `@SoLuong`.
Hai nhánh cuối khác nhau cách trừ kho: nếu **dòng chi tiết mới**, trigger TR01 tự trừ kho khi `INSERT`;
nếu **món đã có** trong hóa đơn thì thủ tục tự cộng số lượng và trừ kho.

```mermaid
flowchart TD
    A([Bắt đầu]) --> B[BEGIN TRANSACTION]
    B --> C{"Hóa đơn tồn tại<br/>và TrangThai = Mở?"}
    C -- Không --> E1[/"THROW 50001"/]
    C -- Có --> D{"Món tồn tại<br/>và DangBan = 1?"}
    D -- Không --> E2[/"THROW 50002"/]
    D -- Có --> F{"Mọi nguyên liệu đủ?<br/>TonKho - định lượng × SL ≥ 0"}
    F -- Không --> E3[/"THROW 50003: Không đủ nguyên liệu"/]
    F -- Có --> G{"Món đã có trong<br/>ChiTietHoaDon?"}
    G -- Có --> H["UPDATE ChiTietHoaDon:<br/>SoLuong += @SoLuong"]
    H --> I["UPDATE NguyenLieu:<br/>trừ TonKho theo DinhLuong"]
    G -- Không --> J["INSERT ChiTietHoaDon<br/>(DonGia = GiaBan, TrangThaiCheBien = Chờ)"]
    J --> K["Trigger TR01 tự trừ kho"]
    I --> L
    K --> L["UPDATE HoaDon.TongTien =<br/>SUM(SoLuong × DonGia)"]
    L --> M[COMMIT]
    M --> N([Kết thúc: gọi món thành công])

    E1 --> R
    E2 --> R
    E3 --> R
    R["CATCH: ROLLBACK, THROW lại"] --> Z([Kết thúc với lỗi])

    classDef loi fill:#fde2e2,stroke:#c0392b,color:#000;
    classDef ok fill:#e1f5e1,stroke:#27ae60,color:#000;
    class E1,E2,E3,R,Z loi;
    class N ok;
```

---

## 4. `sp_ThanhToan`

Tham số: `@MaHD`, `@TongTienThucThu OUTPUT`.

```mermaid
flowchart TD
    A([Bắt đầu]) --> B[BEGIN TRANSACTION]
    B --> C{"Hóa đơn tồn tại<br/>và TrangThai = Mở?"}
    C -- Không --> E1[/"THROW 50010"/]
    C -- Có --> D{"Hóa đơn có ít nhất<br/>một dòng chi tiết?"}
    D -- Không --> E2[/"THROW 50011: Chưa có món"/]
    D -- Có --> F["Gán @TongTienThucThu = HoaDon.TongTien"]
    F --> G["UPDATE HoaDon → Đã thanh toán"]
    G --> H["UPDATE Ban → Trống"]
    H --> I[COMMIT]
    I --> J([Kết thúc: trả @TongTienThucThu])

    E1 --> R
    E2 --> R
    R["CATCH: ROLLBACK, THROW lại"] --> Z([Kết thúc với lỗi])

    classDef loi fill:#fde2e2,stroke:#c0392b,color:#000;
    classDef ok fill:#e1f5e1,stroke:#27ae60,color:#000;
    class E1,E2,R,Z loi;
    class J ok;
```

---

## 5. `sp_HuyHoaDon`

Hủy hóa đơn đang mở và hoàn trả nguyên liệu bằng con trỏ.

```mermaid
flowchart TD
    A([Bắt đầu]) --> B[BEGIN TRANSACTION]
    B --> C{"Hóa đơn tồn tại<br/>và TrangThai = Mở?"}
    C -- Không --> E1[/"THROW 50030"/]
    C -- Có --> D["Mở CURSOR cur_ChiTiet<br/>trên ChiTietHoaDon của hóa đơn"]
    D --> F["FETCH dòng đầu tiên"]
    F --> G{"@@FETCH_STATUS = 0?"}
    G -- Có --> H{"Món có định lượng<br/>trong DinhLuong?"}
    H -- Có --> I["UPDATE NguyenLieu:<br/>TonKho += định lượng × SoLuong"]
    H -- Không --> J
    I --> J["FETCH dòng kế tiếp"]
    J --> G
    G -- Không --> K["CLOSE và DEALLOCATE cursor"]
    K --> L["UPDATE HoaDon → Hủy"]
    L --> M["UPDATE Ban → Trống"]
    M --> N[COMMIT]
    N --> O([Kết thúc: hủy thành công])

    E1 --> R
    R["CATCH: ROLLBACK;<br/>nếu cursor còn mở thì CLOSE + DEALLOCATE;<br/>THROW lại"] --> Z([Kết thúc với lỗi])

    classDef loi fill:#fde2e2,stroke:#c0392b,color:#000;
    classDef ok fill:#e1f5e1,stroke:#27ae60,color:#000;
    class E1,R,Z loi;
    class O ok;
```

---

## 6. `sp_ThongKeDoanhThu`

Tham số: `@Nam`, `@ThangBatDau = 1`, `@ThangKetThuc = 12`. Chỉ đọc dữ liệu, không dùng giao tác.

```mermaid
flowchart TD
    A([Bắt đầu]) --> B{"@ThangBatDau ≤ @ThangKetThuc?"}
    B -- Không --> E1[/"THROW 50040"/]
    B -- Có --> C{"Tháng nằm trong 1 đến 12?"}
    C -- Không --> E2[/"THROW 50041"/]
    C -- Có --> D["SELECT: nối HoaDon, ChiTietHoaDon, Mon, NhanVien"]
    D --> F["Lọc: TrangThai = Đã thanh toán,<br/>đúng năm, tháng trong khoảng"]
    F --> G["GROUP BY tháng:<br/>số hóa đơn, tổng món, doanh thu"]
    G --> H([Trả bảng kết quả theo tháng])

    classDef loi fill:#fde2e2,stroke:#c0392b,color:#000;
    classDef ok fill:#e1f5e1,stroke:#27ae60,color:#000;
    class E1,E2 loi;
    class H ok;
```

---

## 7. `fn_DanhSachMonTheoLoai`

Hàm bảng nhiều câu lệnh. Tham số: `@MaLoai`, `@BaoGomConChau = 0`.

```mermaid
flowchart TD
    A([Bắt đầu]) --> B{"@BaoGomConChau = 0?"}
    B -- Có --> C["INSERT vào @KetQua:<br/>món có MaLoai = @MaLoai"]
    B -- Không --> D["CTE đệ quy CTE_Loai:<br/>mốc = loại @MaLoai"]
    D --> E["Phần đệ quy: nối LoaiMon<br/>với MaLoaiCha = MaLoai của vòng trước"]
    E --> F["INSERT vào @KetQua:<br/>món thuộc mọi loại trong CTE_Loai"]
    C --> G([RETURN bảng @KetQua])
    F --> G
```

---

## 8. Trigger `trg_ChiTietHoaDon_KiemTraNguyenLieu` (TR01)

`AFTER INSERT` trên `ChiTietHoaDon`, xử lý nhiều dòng một lần. Gom nhu cầu theo nguyên liệu trước khi so với tồn kho,
để tránh sót trường hợp nhiều món cùng dùng một nguyên liệu trong một lệnh `INSERT`.

```mermaid
flowchart TD
    A(["INSERT vào ChiTietHoaDon<br/>(1 hoặc nhiều dòng)"]) --> B["CTE_NhuCau:<br/>inserted JOIN DinhLuong,<br/>GROUP BY MaNL, SUM(SoLuong × định lượng)"]
    B --> C["So sánh với NguyenLieu.TonKho:<br/>liệt kê nguyên liệu có TonKho nhỏ hơn nhu cầu"]
    C --> D{"Có nguyên liệu thiếu?"}
    D -- Có --> E[/"THROW 50001: Không đủ nguyên liệu<br/>(kèm danh sách cần/còn)"/]
    E --> F(["Lệnh INSERT bị hủy"])
    D -- Không --> G["CTE_TruKho: tính lại tổng nhu cầu"]
    G --> H["UPDATE NguyenLieu:<br/>TonKho -= tổng nhu cầu (set-based)"]
    H --> I(["INSERT hoàn tất"])

    classDef loi fill:#fde2e2,stroke:#c0392b,color:#000;
    classDef ok fill:#e1f5e1,stroke:#27ae60,color:#000;
    class E,F loi;
    class I ok;
```

---

## 9. Trigger `trg_HoaDon_CapNhatBan` (TR02)

`AFTER UPDATE` trên `HoaDon`. Đồng bộ trạng thái bàn khi trạng thái hóa đơn đổi.

```mermaid
flowchart TD
    A(["UPDATE HoaDon"]) --> B{"Cột TrangThai có bị sửa?"}
    B -- Không --> Z(["Thoát, không làm gì"])
    B -- Có --> C["Với mỗi hóa đơn có<br/>deleted.TrangThai khác inserted.TrangThai<br/>và trạng thái mới thuộc Đã thanh toán, Hủy, Mở"]
    C --> D{"Trạng thái mới của hóa đơn"}
    D -- "Đã thanh toán" --> E["Ban → Trống"]
    D -- "Hủy" --> F["Ban → Trống"]
    D -- "Mở" --> G["Ban → Có khách"]
    E --> H([Xong])
    F --> H
    G --> H
```

---

## 10. Trigger `trg_Mon_KiemTraXoa` (TR03)

`INSTEAD OF DELETE` trên `Mon`: không xóa thật, chỉ ẩn món (xóa mềm).

```mermaid
flowchart TD
    A(["DELETE FROM Mon"]) --> B["Tìm món trong deleted<br/>đang có trong hóa đơn TrangThai = Mở"]
    B --> C{"Có món đang được dùng?"}
    C -- Có --> D[/"THROW 50002: Không thể ẩn/xóa món<br/>đang có trong hóa đơn đang mở"/]
    D --> E(["DELETE bị từ chối"])
    C -- Không --> F["UPDATE Mon SET DangBan = 0<br/>cho các món trong deleted"]
    F --> G["PRINT danh sách món đã ẩn"]
    G --> H(["Hoàn tất: dòng vẫn còn trong bảng"])

    classDef loi fill:#fde2e2,stroke:#c0392b,color:#000;
    classDef ok fill:#e1f5e1,stroke:#27ae60,color:#000;
    class D,E loi;
    class H ok;
```

---

## 11. Giao tác GT01: gọi nhiều món (all-or-nothing)

Kịch bản minh họa tính nguyên tử: gọi món 1 và món 2 trong cùng một giao tác.
Ở GT01-A đủ nguyên liệu nên `COMMIT`. Ở GT01-B món 2 thiếu nguyên liệu nên trigger TR01 báo lỗi và `ROLLBACK` cả món 1.

```mermaid
flowchart TD
    A(["Bắt đầu kịch bản"]) --> B["Lấy một bàn Trống và một nhân viên PhucVu"]
    B --> C{"Có bàn Trống?"}
    C -- Không --> S(["SKIP: không có bàn để demo"])
    C -- Có --> D["Sao lưu TonKho các nguyên liệu của món 1, 2"]
    D --> D2["GT01-B: đặt TonKho nguyên liệu riêng của món 2 về 0"]
    D2 --> E["Tạo hóa đơn Mở, bàn → Có khách"]
    E --> F[BEGIN TRANSACTION]
    F --> G["INSERT chi tiết món 1"]
    G --> H["INSERT chi tiết món 2"]
    H --> I{"Trigger TR01<br/>báo thiếu nguyên liệu?"}
    I -- "Không (GT01-A)" --> J["UPDATE HoaDon.TongTien"]
    J --> K[COMMIT]
    K --> L["Kết quả: TonKho giảm,<br/>có 2 dòng chi tiết"]
    I -- "Có (GT01-B)" --> M["Nhảy vào CATCH"]
    M --> N[ROLLBACK]
    N --> O["Kết quả: TonKho không đổi,<br/>0 dòng chi tiết, kể cả món 1"]
    L --> P["Dọn dữ liệu demo:<br/>xóa hóa đơn, khôi phục TonKho, bàn → Trống"]
    O --> P
    P --> Q(["Kết thúc kịch bản"])

    classDef loi fill:#fde2e2,stroke:#c0392b,color:#000;
    classDef ok fill:#e1f5e1,stroke:#27ae60,color:#000;
    class M,N,O loi;
    class K,L ok;
```

---

## 12. Giao tác GT02: thanh toán có SAVEPOINT

Minh họa phục hồi một phần với `SAVE TRANSACTION`.

```mermaid
flowchart TD
    A(["Bắt đầu kịch bản"]) --> B["Tạo hóa đơn Mở trên một bàn Trống<br/>(nếu không có bàn Trống thì SKIP)"]
    B --> C["BEGIN TRANSACTION GT02"]
    C --> D["SAVE TRANSACTION sp_ThanhToan"]
    D --> E["UPDATE HoaDon → Đã thanh toán<br/>WHERE TrangThai = Mở"]
    E --> F{"@@ROWCOUNT = 0?"}
    F -- Không --> G["COMMIT TRANSACTION GT02"]
    G --> H["Trigger TR02: Ban → Trống"]
    H --> I["Kết quả: HĐ Đã thanh toán, Bàn Trống"]
    F -- Có --> J[/"THROW 50003: HĐ không ở trạng thái Mở"/]
    J --> K{"XACT_STATE = 1?"}
    K -- Có --> L["ROLLBACK TO SAVEPOINT sp_ThanhToan<br/>rồi COMMIT GT02"]
    K -- Không --> M["ROLLBACK toàn bộ giao tác"]
    L --> N["Báo lỗi bằng PRINT"]
    M --> N
    I --> O["Dọn dữ liệu demo"]
    N --> O
    O --> P(["Kết thúc kịch bản"])

    classDef loi fill:#fde2e2,stroke:#c0392b,color:#000;
    classDef ok fill:#e1f5e1,stroke:#27ae60,color:#000;
    class J,L,M,N loi;
    class G,H,I ok;
```
