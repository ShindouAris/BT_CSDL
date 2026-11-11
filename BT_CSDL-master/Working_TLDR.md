# Working_TLDR.md — Bản tóm tắt quy trình làm việc nhóm

> Tóm tắt một trang của [WORKING.md](WORKING.md). Đọc bản này khi đã quen; khi có tình huống khó (xung đột, mất code, sửa bảng) hãy mở [WORKING.md](WORKING.md) đúng mục được ghi ở cuối mỗi phần.

**Dự án:** BT_CSDL — Đề tài 13 (nhà hàng / quán cà phê) · SQL Server · CSDL `QL_CAFE_NHAHANG`
**Repo:** <https://github.com/ShindouAris/BT_CSDL.git>

---

## 1. Hiện trạng repo (đã kiểm tra)

| Hạng mục | Giá trị |
|---|---|
| Nhánh | Chỉ có `master` |
| Tag | Không có |
| CI/CD | Không có |
| `.gitignore` | **Chưa có** |
| `.gitattributes` | **Chưa có** |
| `core.autocrlf` | `true` (Windows) |
| `pull.rebase` | `false` → `git pull` là merge |

> Repo **chưa từng** dùng nhánh phụ: cả 3 commit đều nằm thẳng trên `master`, không có merge commit. Mọi quy ước về nhánh và commit dưới đây là **đề xuất của nhóm**, không phải thiết lập đã có sẵn trong Git.

---

## 2. Sáu quy tắc bất di bất dịch

1. **`git pull` trước khi làm bất cứ điều gì.**
2. **Không commit thẳng lên `master`** — luôn tạo nhánh riêng.
3. **`git add` từng file cụ thể**, không dùng `git add .` khi chưa xem `git status`.
4. **Chạy lại toàn bộ chuỗi script** trước khi báo "xong việc".
5. **Không commit** `.mdf`, `.ldf`, `.bak`, `.trn`, mật khẩu, dữ liệu người thật.
6. **Không dùng `git push --force`** trên `master`.

Ngoài ra: **mỗi file `.sql` chỉ một người sửa tại một thời điểm** — nhắn nhóm trước khi bắt đầu.

---

## 3. Đặt tên nhánh

```text
<loại>/<mô-tả-không-dấu>
```

| Loại | Dùng khi | Ví dụ |
|---|---|---|
| `feature/` | Thêm view, thủ tục, hàm, trigger | `feature/view-doanh-thu` |
| `fix/` | Sửa lỗi | `fix/seed-trung-mamon` |
| `docs/` | Chỉ sửa `.md` | `docs/quy-uoc-commit` |
| `chore/` | Việc phụ trợ | `chore/them-gitignore` |

✅ Chữ thường, gạch ngang, **không dấu tiếng Việt**, dưới ~40 ký tự.
❌ `feature/ThemView`, `feature/them-view-tinh-doanh-thu-theo-ngay-va-thang`, `feature/x`

Một nhánh = một việc. Không cần `hotfix/`, `release/`.

---

## 4. Định dạng commit

```text
<loại>(<phạm-vi>): <mô tả tiếng Việt, thể mệnh lệnh>
```

**`<loại>`:** `feat` · `fix` · `docs` · `refactor` · `data` · `chore`
**`<phạm-vi>`:** `sql` · `seed` · `view` · `query` · `sp` · `func` · `trigger` · `tran` · `security` · `backup` · `perf` · `docs`

```bash
git commit -m "feat(view): thêm view vw_DoanhThuTheoNgay"
git commit -m "fix(seed): sửa lỗi hóa đơn trùng món"
git commit -m "data(seed): thêm 5 nguyên liệu mới"
git commit -m "docs(working): bổ sung quy ước nhánh"
git commit -m "chore(repo): thêm .gitignore chặn file .mdf"
```

Dòng đầu **≤ 72 ký tự**, không dấu chấm cuối. Một commit = một thay đổi có nghĩa.

---

## 5. Quy trình chuẩn

```bash
# 1) Cập nhật master
git switch master
git pull

# 2) Tạo nhánh
git switch -c feature/view-doanh-thu

# 3) Sửa file, rồi kiểm tra
git status
git diff

# 4) Stage đúng file và xem lại
git add sql/04_TruyVan_View.sql
git diff --staged

# 5) Commit
git commit -m "feat(view): thêm view vw_DoanhThuTheoNgay"

# 6) Đẩy nhánh (lần đầu dùng -u)
git push -u origin feature/view-doanh-thu

# 7) Tạo Pull Request trên GitHub, nhờ 1 bạn review, merge

# 8) Dọn nhánh
git switch master
git pull
git branch -d feature/view-doanh-thu
```

**Cập nhật nhánh của mình khi `master` đã có commit mới:**

```bash
git switch master && git pull
git switch feature/view-doanh-thu
git merge master          # giải quyết xung đột nếu có
```

---

## 6. Pull request — checklist

**Người gửi:** mô tả *việc gì / vì sao / đã kiểm tra gì / reviewer cần chú ý gì*.

**Người review phải kiểm:**

- [ ] Đúng phạm vi, không sửa lây file người khác
- [ ] Tiếng Việt trong `N'...'` đúng dấu (`N'Có khách'` ≠ `N'Co khach'`)
- [ ] Nếu thêm bảng: đã thêm cả `DROP TABLE` ở đầu `02_Bang.sql` chưa?
- [ ] Thứ tự `DROP` vẫn là con → cha
- [ ] Không có đường dẫn máy cá nhân, mật khẩu, dữ liệu người thật
- [ ] **Tự chạy lại toàn chuỗi script được chưa**
- [ ] Giải thích được đoạn code nếu bị hỏi

> PR **bắt buộc** khi sửa `sql/02_Bang.sql`, `scripts/03b_GiaoDich.sql`, hoặc thêm đối tượng SQL mới.

---

## 7. Xung đột — 4 bước

```bash
git merge master
git status                        # 1. file nào xung đột?
# 2. mở file, sửa tay phần giữa <<<<<<< và >>>>>>>, xóa cả 3 dòng đánh dấu
git add <file>                    # 3. đánh dấu đã giải quyết
git commit                        # 4. hoàn tất merge
```

Kiểm tra còn sót dấu xung đột không:

```bash
grep -nE '^(<<<<<<<|=======|>>>>>>>)' sql/02_Bang.sql scripts/*.sql
```

Kết quả **rỗng** = sạch.

**Sau khi giải quyết xung đột, bắt buộc chạy lại toàn chuỗi:**

```text
sql/01_CAUHINH_CSDL.sql → sql/02_Bang.sql → scripts/03a_DanhMuc.sql → scripts/03b_GiaoDich.sql
```

> ⚠️ `01_CAUHINH_CSDL.sql` **xóa CSDL `QL_CAFE_NHAHANG`** và tên được viết cứng. Nhắn nhóm trước khi chạy. Muốn kiểm chứng an toàn: copy script ra file tạm (không commit) và đổi tên CSDL thành `QL_CAFE_NHAHANG_TEST`.

Rối quá thì bỏ: `git merge --abort`.

---

## 8. Quy tắc riêng cho SQL

| Việc | Quy tắc |
|---|---|
| **Thứ tự chạy** | `01` → `02` → `03a` → `03b` (→ `04` nếu cần kiểm chứng). Không đổi, không chạy lẻ |
| **Chạy lại dữ liệu** | `03b_GiaoDich.sql` **đã có chốt chặn**: `HoaDon` còn dữ liệu thì `THROW 50012` và dừng trước khi ghi. Muốn nạp lại phải `03_RESET_DB.sql` → `02_Bang.sql` → `03a` → `03b` |
| **`03a_DanhMuc.sql`** | Gán `MaMon` **cứng** 1..36. Chỉ nạp trên CSDL vừa tạo lại từ đầu |
| **Thêm bảng vào `02_Bang.sql`** | Phải sửa **2 chỗ**: `DROP` ở đầu file (con trước, cha sau) + `CREATE` ở thân file. Cập nhật cả `03_RESET_DB.sql` |
| **Đổi tên cột/bảng** | Phải báo cả nhóm — sẽ làm hỏng `scripts/*.sql` và truy vấn của người khác |
| **`HoaDon.TongTien`** | Là dữ liệu dẫn xuất. Sửa `ChiTietHoaDon` thì **phải tính lại** (hiện chưa có trigger) |
| **Encoding** | Lưu `.sql` ở **UTF-8 không BOM**. Sửa sang ANSI sẽ hỏng tiếng Việt và `CHECK` sẽ từ chối dữ liệu đúng |
| **Đường dẫn** | `C:\SQLData` phải tồn tại. Thiếu thì **tạo thư mục**, đừng sửa đường dẫn trong script rồi commit |
| **Dữ liệu ngẫu nhiên** | `CHECKSUM(NEWID())` → mỗi lần chạy ra số khác. **Không so sánh số liệu giữa các máy** |
| **Đặt tên** | `vw_` · `sp_` · `fn_` · `trg_` · `IX_`/`UX_` · `PK_`/`FK_`/`CK_`/`DF_` |

**Dữ liệu kỳ vọng sau khi nạp** (đã đo thật ngày 26/10/2026, SQL Server 2025):

`LoaiMon = 11` · `Ban = 15` · `NhanVien = 12` · `NguyenLieu = 28` · `Mon = 36` · `MonAn = 18` · `ThucUong = 18` · `DinhLuong = 130` · `HoaDon = 1500` (1390 đã TT / 5 Mở / 105 Hủy) · hóa đơn rỗng `= 5` · `ChiTietHoaDon` **≈ 5.300** (1–6 món/hóa đơn, ngẫu nhiên — không cố định)

---

## 9. Checklist trước khi `git push`

- [ ] Đang ở **nhánh riêng**, không phải `master`
- [ ] `git status` — không có file rác (`.mdf`, `.ldf`, `.bak`, `.tmp`, `.vs/`)
- [ ] `git diff --staged` — đúng những gì mình định gửi
- [ ] Đã chạy lại `01` → `02` → `03a` → `03b` (và `04` nếu có sửa ràng buộc), không lỗi
- [ ] `04_TEST_VI_PHAM.sql` báo `10/10 bị chặn`, `0 lọt` nếu bạn có sửa schema
- [ ] Các câu kiểm tra cuối script trả về đúng số dòng, câu kiểm tra lỗi trả về rỗng
- [ ] Không có mật khẩu thật, không có dữ liệu người thật
- [ ] Thông điệp commit đúng định dạng mục 4
- [ ] Nếu sửa cấu trúc: đã cập nhật [Explains.md](Explains.md) tương ứng

---

## 10. ⚠️ Cảnh báo

### Lệnh phá hủy — cân nhắc kỹ

| Lệnh | Hậu quả |
|---|---|
| `git reset --hard` | 🔴 Xóa mọi thay đổi chưa commit, không lấy lại được |
| `git clean -fd` | 🔴 Xóa mọi file chưa được Git theo dõi |
| `git push --force` | 🔴 Ghi đè lịch sử, **xóa commit của người khác** — cấm trên `master` |
| `git restore <file>` | 🟡 Mất phần sửa của file đó (muốn bỏ staging thì dùng `git restore --staged`) |
| `git branch -D` | 🟡 Xóa nhánh dù chưa merge |

Bị mất code sau `reset --hard` → `git reflog` tìm commit cũ rồi `git switch -c cuu-lai <mã>`.
Chi tiết: [WORKING.md](WORKING.md) mục 12.

### File SQL dùng chung

- `sql/01_CAUHINH_CSDL.sql` → **xóa toàn bộ CSDL** rồi tạo lại.
- `sql/02_Bang.sql` → **xóa toàn bộ 10 bảng** và dữ liệu trong đó.
- `scripts/03b_GiaoDich.sql` → **đã có chốt chặn** (`THROW 50012`): chạy lại trên CSDL đang có hóa đơn sẽ dừng ngay, không nhân đôi dữ liệu.
- `scripts/03a_DanhMuc.sql` → dùng `MaMon` cứng, chạy sai thời điểm sẽ trỏ sai món.
- `scripts/04_TEST_VI_PHAM.sql` → chỉ kiểm chứng ràng buộc, kết thúc bằng `ROLLBACK`, không đổi dữ liệu.

👉 Chạy bất kỳ script nào ở trên: **báo nhóm trước**.

---

## 11. Tra nhanh lệnh

```bash
git status                  # đang ở đâu, file nào đổi
git diff                    # xem thay đổi chưa stage
git diff --staged           # xem thay đổi đã stage
git add <file>              # chọn file để commit
git restore --staged <file> # bỏ staging, giữ nội dung (AN TOÀN)
git commit -m "..."         # ghi lại thay đổi
git push                    # đẩy lên GitHub
git pull                    # lấy bản mới nhất (merge)
git switch -c <nhánh>       # tạo + chuyển nhánh
git merge master            # hợp nhất master vào nhánh hiện tại
git log --oneline           # lịch sử gọn
git blame <file>            # ai sửa dòng nào
git reflog                  # cứu code bị mất
```

---

## 12. Còn phải chốt

- [ ] Tên nhánh & định dạng commit (mục 3, 4) — cả nhóm đồng ý chưa?
- [ ] Có bắt buộc PR không? Ai review?
- [ ] Tạo `.gitignore` chưa? (hiện **chưa có**)
- [ ] Chuẩn hóa tên file theo Readme mục 3.10 (`01_CSDL` … `08_ToiUu`)? Hiện `sql/` mới có `01_CAUHINH_CSDL.sql`, `02_Bang.sql`, còn dữ liệu nằm ở `scripts/`
- [ ] Số liệu trong báo cáo lấy từ lần chạy nào (dữ liệu ngẫu nhiên)?
- [ ] Phân công thành viên theo bảng ở [WORKING.md](WORKING.md) mục 4.1

Chi tiết đầy đủ: [WORKING.md](WORKING.md) mục 14.
