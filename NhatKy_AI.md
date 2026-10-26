# Nhật ký sử dụng AI

> Yêu cầu: [Readme.md](Readme.md) mục 3.9 — *"Ghi nhật ký sử dụng theo mẫu ở cuối tài liệu"*. Readme hiện **không kèm mẫu cụ thể**, nên nhóm tự chốt mẫu dưới đây. Nếu giảng viên có mẫu riêng, thay cột cho khớp.
>
> Nguyên tắc: chỉ ghi những gì **thật sự đã làm**, kể cả khi AI trả lời sai. Mục đích của nhật ký là chứng minh sinh viên **kiểm chứng** đầu ra của AI, không phải chứng minh AI giỏi.

---

## Mẫu ghi

| Trường | Nội dung |
|---|---|
| Ngày | `YYYY-MM-DD`, giờ nếu cần |
| Công cụ | Tên model/dịch vụ AI |
| Việc | Một dòng mô tả mục tiêu |
| Prompt | Nguyên văn (hoặc tóm tắt trung thực nếu prompt dài) |
| AI trả về | Tóm tắt kết quả |
| Rà soát | Đúng / Sai / Chưa kiểm chứng được — kèm **bằng chứng** |
| Đã sửa | Thay đổi thực tế so với bản AI đưa |
| Kiểm chứng | Cách xác nhận (chạy thử, đối chiếu schema, đo đạc…) |

---

## Các mục đã ghi

### #1 — 2026-10-26 · Kiểm tra dữ liệu mẫu so với Readme mục 3.3

**Việc:** Xác định dữ liệu seed hiện có đã đạt yêu cầu Readme 3.3 chưa, trước khi sửa bất cứ thứ gì.

**Prompt (tóm tắt):** *"Đối chiếu từng gạch đầu dòng của Readme 3.3 với 4 file SQL trong repo và với dữ liệu thực tế trong CSDL `QL_CAFE_NHAHANG`."*

**AI trả về:** Dữ liệu đạt 4/5 tiêu chí; thiếu (a) bộ lệnh cố tình vi phạm ràng buộc, (b) chưa có `DELETE` nào trong repo (Readme 3.2 yêu cầu đủ `INSERT`/`UPDATE`/`DELETE`).

**Rà soát:** **Đúng** — kiểm chứng bằng truy vấn trực tiếp trên CSDL đang chạy:
`LoaiMon 11 · Ban 15 · NhanVien 12 · NguyenLieu 28 · Mon 36 · MonAn 18 · ThucUong 18 · DinhLuong 130 · HoaDon 1500 · ChiTietHoaDon 5000`;
trạng thái `1390 / 5 / 105`; 5 hóa đơn rỗng; 0 hóa đơn lệch `TongTien`; 5 bàn "Có khách" ↔ đúng 5 hóa đơn `Mở`.

**Đã sửa:** Không sửa dữ liệu (đã đạt). Ghi nhận 2 điểm thiếu để xử lý ở #2 và #3.

**Kiểm chứng:** Chạy 7 truy vấn `SELECT` chỉ-đọc trên CSDL thật; đối chiếu số dòng từng bảng.

---

### #2 — 2026-10-26 · Sửa lỗi chọn ngẫu nhiên + đơn giản hóa phân bổ chi tiết

**Việc:** Sửa `02_SEED.sql` (nay là `03b_GiaoDich.sql`).

**Prompt (nguyên văn, do sinh viên đưa):**

> Các câu kiểu `SELECT @MaNV = MaNV FROM @DSNV WHERE Id = 1 + ABS(CHECKSUM(NEWID())) % @SoNV;` — `NEWID()` trong WHERE được tính riêng cho từng dòng... Với 4 nhân viên phục vụ, lần chạy đầu có khoảng 30% khả năng `@MaNV = NULL`... Sửa bằng cách chọn số ngẫu nhiên ra biến trước. ... Nên đơn giản hóa phần chia số dòng chi tiết (dòng 204–219 và 358–373)... Thay bằng `SET @SoMon = 1 + ABS(CHECKSUM(NEWID())) % 6;`

**AI trả về:** Sửa theo hướng dẫn; thêm `CAST(... AS BIGINT)` trước `ABS`; thêm chốt chặn chạy lại; thêm 2 bất biến kiểm tra trong transaction.

**Rà soát:** **Nửa đúng — phần quan trọng nhất KHÔNG tái hiện được.**

Đo thực tế trên SQL Server 2025 (17.0.1000.7), bảng 4 dòng, chạy 5.000 lần:

| Công thức | Số lần biến bị `NULL` | Phân bố chọn dòng 1–4 |
|---|---:|---|
| Cũ — `NEWID()` trong `WHERE` | **0 / 5000** | 985 / 1016 / 1043 / 956 |
| Mới — tính `@ChiSo` trước | 0 / 5000 | tương tự |

Chạy thêm trên bảng thật `dbo.Ban` (15 dòng), 5.000 lần: **0 lần NULL**.

**Giải thích:** biểu thức trong `WHERE` **không tham chiếu cột nào**, nên SQL Server đánh giá nó **một lần cho cả câu lệnh** (như một hằng số tại thời điểm chạy) → luôn khớp đúng 1 dòng. Triệu chứng "30% NULL" **không tái hiện**. Chỉ khi biểu thức **có** tham chiếu cột thì mới đánh giá theo từng dòng (đã thử bằng CTE, xác nhận).

**Kết luận rút ra:** vẫn giữ cách viết mới, nhưng **không** ghi vào báo cáo là "đã sửa lỗi NULL". Lý do giữ:
1. Đọc rõ nghĩa hơn, không phải suy luận về optimizer.
2. Không phụ thuộc hành vi lập kế hoạch (có thể đổi giữa các phiên bản).
3. `ABS(INT_MIN)` **thật sự** gây lỗi tràn số — `CAST(... AS BIGINT)` loại bỏ rủi ro này.

**Đã sửa thật:**
- Tách chỉ số ngẫu nhiên ra biến `@ChiSo` (3 chỗ: bàn, nhân viên ở vòng hóa đơn Mở, và nhân viên ở vòng hóa đơn đã đóng).
- Thêm `CAST(... AS BIGINT)` quanh `CHECKSUM` ở **mọi** chỗ sinh số ngẫu nhiên.
- Bỏ hẳn `@TongCT`, `@SoCTConLai`, `@SoHDCoMonConLai`, công thức `@MinMon`/`@MaxMon`, `THROW 50007`, `THROW 50011` → thay bằng 1 món ngẫu nhiên 1–6/hóa đơn (ngắn hơn ~40 dòng).
- Thêm `THROW 50012` chặn chạy lại, `THROW 50013`/`50014` kiểm tra bất biến trước `COMMIT`.

**Kiểm chứng:** chạy toàn chuỗi trong CSDL tạm `QL_CAFE_TEST` → `HoaDon 1500`, `ChiTietHoaDon 5308`, trạng thái `1390/5/105`, hóa đơn rỗng 5, 0 hóa đơn lệch `TongTien`, tồn kho không đổi (2/2/4/20). Chạy lại `03b` → bị chặn bởi `THROW 50012` đúng như thiết kế.

**Trả lời được câu hỏi vấn đáp:** *"Vì sao không dùng `RAND()`?"* → `RAND()` chỉ đánh giá một lần mỗi câu lệnh nên mọi dòng nhận cùng giá trị; `CHECKSUM(NEWID())` cho mỗi dòng một giá trị khác nhau.

---

### #3 — 2026-10-26 · Thêm minh họa INSERT / UPDATE / DELETE

**Việc:** Bù phần thiếu của Readme mục 3.2 (đề bắt buộc "thực hiện đầy đủ `INSERT`, `UPDATE` và `DELETE`").

**Prompt:** *"Thêm UPDATE và DELETE minh họa (đề bắt buộc): ví dụ tăng giá một nhóm món, xóa một hóa đơn rỗng hoặc món chưa bán."*

**AI trả về:** 3 khối trong `03b_GiaoDich.sql` (BƯỚC 6): 6.1 `Mon`+`MonAn`, 6.2 `HoaDon`+`ChiTietHoaDon`, 6.3 `DELETE` rồi `ROLLBACK`.

**Rà soát:** **Đúng về kỹ thuật**, nhưng AI chọn cách **net-zero** (thêm rồi xóa) thay vì để thay đổi vĩnh viễn như prompt gợi ý ("tăng giá một nhóm món"). Lý do: giữ bộ dữ liệu tái lập được, và tránh làm lệch các con số đã cam kết trong tài liệu.

**Đã sửa:** Giữ nguyên cách net-zero; ghi rõ trong comment đầu file để người đọc không tưởng là thiếu sót.

**Kiểm chứng:** sau khi chạy, số dòng 9 bảng **không đổi** so với trước BƯỚC 6 (`Ban 15`, `Mon 36`, `MonAn 18`, `HoaDon 1500`, `ChiTietHoaDon 5308`). Khối 6.3 in ra `SoHoaDon` trước và sau `ROLLBACK` để thấy rõ tác dụng.

---

### #4 — 2026-10-26 · Bộ lệnh cố tình vi phạm ràng buộc

**Việc:** Đáp ứng gạch đầu dòng cuối Readme 3.3.

**Prompt:** *"Khối vi phạm ràng buộc bọc TRY…CATCH (CHECK, UNIQUE, PK, FK, NOT NULL)."*

**AI trả về:** file `04_TEST_VI_PHAM.sql` với 10 ca; dùng biến bảng để giữ kết quả sau `ROLLBACK`; mỗi ca ghi lại `ERROR_NUMBER()` và `ERROR_MESSAGE()` thật.

**Rà soát:** **Có 1 ca sai — phát hiện nhờ chạy thật, không phải nhờ đọc code.**

Ca #3 (trạng thái bàn) ban đầu đặt tên `N'Bàn vi phạm trạng thái'` = **21 ký tự**, vượt `TenBan NVARCHAR(20)`. Kết quả: câu lệnh bị chặn bởi lỗi **2628** ("String or binary data would be truncated") — **không phải** `547` (`CK_Ban_TrangThai`). Nếu chỉ kiểm tra "có lỗi" thì ca này sẽ **pass sai**.

**Đã sửa:** đổi tên thành `N'Bàn VP3'` → lỗi đúng `547` trên `CK_Ban_TrangThai`.

**Bài học:** khi test ràng buộc, phải so **mã lỗi**, không chỉ so "chạy có lỗi hay không".

**Kiểm chứng:** chạy trong `QL_CAFE_TEST`:
`515, 547, 547, 2627, 2601, 2627, 547, 547, 547, 547` → **10/10 bị chặn, 0 lọt**, số dòng các bảng không đổi.

---

### #5 — 2026-10-26 · Đổi tên file theo Readme 3.10 và cập nhật tài liệu

**Việc:** Readme 3.10 yêu cầu tên `03_DuLieu`; repo đang là `01_SEED` / `02_SEED`.

**Prompt:** *"Tên file: đề yêu cầu 03_DuLieu.sql. Bạn đổi hai file thành 03a_DanhMuc.sql và 03b_GiaoDich.sql, hoặc gộp lại thành một file 03_DuLieu.sql."*

**AI trả về:** chọn phương án tách 2 file (`03a_DanhMuc.sql`, `03b_GiaoDich.sql`) bằng `git mv` để giữ lịch sử, thay vì gộp thành 1 file ~800 dòng.

**Rà soát:** **Đúng**, nhưng AI phải sửa lại một hệ quả: file `04_TEST_VI_PHAM.sql` **trùng số** với `04_TruyVan_View` trong Readme. Vấn đề này **chưa được giải quyết**, chỉ được ghi nhận trong tài liệu.

**Đã sửa:** cập nhật toàn bộ tham chiếu tên file trong `WORKING.md`, `Working_TLDR.md`, `Explains.md`, `Explain_TLDR.md`, `03_RESET_DB.sql`.

**Kiểm chứng:** `git status` cho thấy 2 lần `git mv` được ghi nhận là rename (giữ history); grep toàn repo không còn `01_SEED` / `02_SEED`.

---

## Điều chỉnh so với gợi ý của AI

| # | AI đề xuất | Nhóm quyết định | Lý do |
|---|---|---|---|
| 1 | Ghi "đã sửa lỗi `@MaNV = NULL`" | **Không ghi** | Đo 5.000 lần không tái hiện; ghi sai sẽ bị hỏi ngược khi vấn đáp |
| 2 | `UPDATE` tăng giá vĩnh viễn | Dùng net-zero | Giữ số liệu tái lập, không làm lệch báo cáo |
| 3 | Gộp 1 file `03_DuLieu.sql` | Tách `03a` + `03b` | File 800 dòng khó review, dễ xung đột khi 3–5 người cùng sửa |
| 4 | Đặt tên ca test tùy ý | Đổi sang tên ngắn | Tránh lỗi truncate che mất ràng buộc cần test |

## Những gì **không** giao cho AI

- Quyết định dùng bảng nào, quan hệ nào (mô hình dữ liệu do nhóm thiết kế).
- Số liệu đưa vào báo cáo: phải lấy từ **lần chạy thật** của nhóm, kèm ngày.
- Câu trả lời vấn đáp: mọi thành viên phải tự giải thích được từng dòng đã nộp (Readme 3.9 mục 4).

## Việc còn phải làm

- [ ] Bổ sung các mục nhật ký cho **giai đoạn trước 2026-10-26** (khi `01_SEED`/`02_SEED` được sinh lần đầu) — người thực hiện các prompt đó cần điền lại, AI không thể dựng lại chính xác.
- [ ] Ghi mục cho M2 (20 truy vấn, view, thủ tục, hàm) và M3 (trigger, phân quyền, tối ưu) khi làm.
- [ ] Chốt lại cách đánh số file với giảng viên (xem [Explains.md](Explains.md) mục 3.2).
