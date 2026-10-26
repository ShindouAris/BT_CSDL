# WORKING.md — Hướng dẫn làm việc nhóm và quy trình Git

> **Dự án:** Bài tập kết thúc học phần Cơ sở dữ liệu — Đề tài 13: Nhà hàng / quán cà phê
> **CSDL làm việc:** `QL_CAFE_NHAHANG` (SQL Server)
> **Kho mã nguồn:** <https://github.com/ShindouAris/BT_CSDL.git>
> **Tài liệu liên quan:** [Readme.md](Readme.md) (đề bài gốc) · [Working_TLDR.md](Working_TLDR.md) (bản tóm tắt) · [Explains.md](Explains.md) (giải thích thư mục `sql/`)

Tài liệu này dành cho sinh viên năm 2 đã biết Git ở mức cơ bản (`clone`, `add`, `commit`, `push`). Mục tiêu không phải là dạy lại Git, mà là **thống nhất cách cả nhóm làm việc trên đúng repository này**, để không ai ghi đè bài của ai và không ai làm hỏng CSDL dùng chung.

---

## Mục lục

1. [Mục đích và cách đọc tài liệu](#1-mục-đích-và-cách-đọc-tài-liệu)
2. [Tổng quan dự án](#2-tổng-quan-dự-án)
3. [Hiện trạng repository tại thời điểm khảo sát](#3-hiện-trạng-repository-tại-thời-điểm-khảo-sát)
4. [Quy ước làm việc nhóm](#4-quy-ước-làm-việc-nhóm)
5. [Quy trình Git hằng ngày](#5-quy-trình-git-hằng-ngày)
6. [Quy ước đặt tên nhánh](#6-quy-ước-đặt-tên-nhánh)
7. [Quy ước thông điệp commit](#7-quy-ước-thông-điệp-commit)
8. [Pull request và review chéo](#8-pull-request-và-review-chéo)
9. [Giải quyết xung đột (conflict)](#9-giải-quyết-xung-đột-conflict)
10. [Cộng tác trên các file SQL](#10-cộng-tác-trên-các-file-sql)
11. [Quy định riêng của dự án](#11-quy-định-riêng-của-dự-án)
12. [Lỗi thường gặp và cách cứu](#12-lỗi-thường-gặp-và-cách-cứu)
13. [Ví dụ thực hành theo kịch bản](#13-ví-dụ-thực-hành-theo-kịch-bản)
14. [Những điều nhóm còn phải thống nhất](#14-những-điều-nhóm-còn-phải-thống-nhất)
15. [Phụ lục: bảng tra lệnh Git](#15-phụ-lục-bảng-tra-lệnh-git)

---

## 1. Mục đích và cách đọc tài liệu

### 1.1. Ba loại thông tin trong tài liệu này

Để tránh hiểu nhầm, tài liệu dùng ba nhãn phân biệt rõ:

| Nhãn | Ý nghĩa | Ví dụ |
|---|---|---|
| **Hiện trạng** | Sự thật đã kiểm tra trực tiếp từ repository | "Repo chỉ có một nhánh `master`" |
| **Đề xuất** | Quy ước nhóm **nên** thống nhất, hiện repo **chưa** có | "Nhánh đặt tên `feature/...`" |
| **Bắt buộc (Readme)** | Yêu cầu đã ghi trong đề bài | "Có ít nhất 3 trigger" |

Những chỗ ghi **Đề xuất**, cả nhóm phải họp chốt rồi mới áp dụng. Không được coi đó là quy định đã có hiệu lực.

### 1.2. Tài liệu này **không** nói gì

- Không mô tả CI/CD, pipeline, hay tự động kiểm thử: **repo hiện không có** thư mục `.github/`, không có cấu hình CI nào.
- Không mô tả quy trình review bắt buộc của GitHub (branch protection): chưa bật, và tài liệu này không hướng dẫn bật.
- Không có tên thành viên cụ thể: Readme chỉ yêu cầu nhóm 3–5 sinh viên, chưa ghi tên ai.

---

## 2. Tổng quan dự án

### 2.1. Bài toán

Xây dựng CSDL cho một nhà hàng / quán cà phê, phục vụ các nghiệp vụ: **bàn, món, thực đơn, nguyên liệu, hóa đơn và tồn kho**.

Ba cấu trúc bắt buộc theo đề tài (đã có trong script):

- **Chuyên biệt hóa món**: `Mon` là bảng cha, `MonAn` (đồ ăn) và `ThucUong` (thức uống) là hai bảng con.
- **Quan hệ N–N có thuộc tính định lượng**: `DinhLuong(MaMon, MaNL, SoLuong)` — một món cần bao nhiêu nguyên liệu cho một phần.
- **Quan hệ đệ quy**: `LoaiMon.MaLoaiCha` — loại món cha ↔ loại món con.

### 2.2. Cấu trúc thư mục hiện có

```text
BT_CSDL/
├── Readme.md                   ← Đề bài, lộ trình M1–M3, yêu cầu chấm điểm
├── WORKING.md                  ← Tài liệu này (quy trình làm việc nhóm)
├── Working_TLDR.md             ← Bản tóm tắt của tài liệu này
├── Explains.md                 ← Giải thích chi tiết thư mục sql/
├── Explain_TLDR.md             ← Bản tóm tắt của Explains.md
├── sql/                        ← Định nghĩa CSDL (cấu trúc)
│   ├── 01_CAUHINH_CSDL.sql     ← Tạo CSDL, cấu hình file .mdf/.ldf
│   └── 02_Bang.sql             ← Tạo 10 bảng, khóa, ràng buộc, chỉ mục
└── scripts/                    ← Dữ liệu mẫu (nội dung)
    ├── 01_SEED.sql             ← Nạp dữ liệu danh mục (bàn, món, nguyên liệu…)
    └── 02_SEED.sql             ← Sinh 1.500 hóa đơn + 5.000 dòng chi tiết
```

### 2.3. Lộ trình bàn giao

Theo [Readme.md](Readme.md) mục 2, có ba mốc. Hiện repo **mới hoàn thành phần M1** (chưa có mô hình PowerDesigner, chưa có truy vấn / view / thủ tục / trigger / phân quyền).

| Mốc | Sản phẩm | Trạng thái hiện tại |
|---|---|---|
| **M1** | Mô hình CDM/PDM, script tạo CSDL + bảng, dữ liệu mẫu, nhật ký AI | Script và dữ liệu **đã có**; `.cdm`/`.pdm` và nhật ký AI **chưa có** |
| **M2** | 20 truy vấn, ≥3 view, ≥5 stored procedure, ≥3 function | **Chưa bắt đầu** |
| **M3** | Trigger, giao tác, phân quyền, sao lưu/phục hồi, tối ưu, báo cáo | **Chưa bắt đầu** |

### 2.4. Công nghệ và môi trường

| Hạng mục | Giá trị |
|---|---|
| Hệ quản trị | SQL Server 2025 (**hiện trạng máy khảo sát:** instance `MSSQLSERVER` phiên bản `17.0.1000.7`, dịch vụ đang chạy) |
| Công cụ chạy script | SQL Server Management Studio (SSMS) hoặc `sqlcmd` |
| Nơi lưu file CSDL | `C:\SQLData\` — **đường dẫn được viết cứng trong `sql/01_CAUHINH_CSDL.sql`** |
| Collation | `Vietnamese_CI_AS` (không phân biệt hoa/thường, **phân biệt dấu**) |
| Mã hóa file `.sql` | UTF-8 **không BOM**, xuống dòng CRLF trên Windows (**đã kiểm tra**) |
| Quản lý mã nguồn | Git + GitHub |

---

## 3. Hiện trạng repository tại thời điểm khảo sát

Bảng dưới là số liệu **thật**, dùng để bạn biết mình đang làm việc trên cái gì:

| Hạng mục | Giá trị thực tế |
|---|---|
| Nhánh | Chỉ có `master` (cả local và `origin/master`) |
| Nhánh khác / tag | Không có |
| Remote | `origin` → `https://github.com/ShindouAris/BT_CSDL.git` |
| Số commit | 3, commit gần nhất `ae0841e upload seed data` |
| File được Git theo dõi | 6 file (4 file `.sql` + 2 file `.md`) |
| `.gitignore` | **Chưa có** |
| `.gitattributes` | **Chưa có** |
| CI / GitHub Actions | **Chưa có** |
| Git hook | Chưa bật (chỉ có file `.sample`) |
| `core.autocrlf` | `true` (cấu hình cấp hệ thống) |
| `pull.rebase` | `false` → `git pull` mặc định **merge** |
| `init.defaultbranch` | `master` |

### 3.1. Ba hệ quả trực tiếp cần nhớ

1. **`master` là nhánh duy nhất và đang là "bản nộp".** Nếu commit thẳng lên `master` rồi đẩy lên, cả nhóm lấy về ngay lập tức — kể cả khi code còn sai. Vì vậy mục 5 khuyến nghị luôn làm trên nhánh riêng.
2. **`core.autocrlf = true`** nghĩa là Git tự đổi CRLF → LF khi lưu và đổi ngược lại khi lấy về. Nếu một bạn dùng Linux/macOS, hoặc lỡ cấu hình khác, có thể xuất hiện diff "đổi toàn bộ file" dù nội dung không đổi. Cách nhận biết và xử lý ở mục 12.
3. **Chưa có `.gitignore`.** Đây là lỗ hổng lớn nhất: rất dễ commit nhầm file `.mdf`, `.ldf`, `.bak`, `.trn` hoặc thư mục `.vs/` của Visual Studio. Mục 11.4 có danh sách cần chặn.

---

## 4. Quy ước làm việc nhóm

### 4.1. Phân vai

Readme mục 3.11 yêu cầu: *"Mỗi thành viên phụ trách và bảo vệ được ít nhất một nhóm đối tượng"*. Dưới đây là cách chia **bám theo đúng danh mục sản phẩm** trong Readme mục 3.10.

> **Đề xuất — nhóm cần điền tên và chốt.** Bảng này chưa có tên thật vì repo không ghi nhận ai phụ trách phần nào.

| Mảng công việc | File phụ trách | Sản phẩm | Người phụ trách |
|---|---|---|---|
| Cấu trúc CSDL | `sql/01_CAUHINH_CSDL.sql`, `sql/02_Bang.sql` | CSDL + 10 bảng + ràng buộc | ………… |
| Dữ liệu mẫu | `scripts/01_SEED.sql`, `scripts/02_SEED.sql` | Dữ liệu danh mục + giao dịch | ………… |
| Truy vấn & view | `sql/04_TruyVan_View.sql` (*chưa có*) | 20 truy vấn, ≥3 view | ………… |
| Thủ tục & hàm | `sql/05_ThuTuc_Ham.sql` (*chưa có*) | ≥5 SP, ≥3 function | ………… |
| Trigger & giao tác | `sql/06_Trigger_GiaoTac.sql` (*chưa có*) | ≥3 trigger, ≥2 kịch bản | ………… |
| Phân quyền & sao lưu | `sql/07_PhanQuyen_SaoLuu.sql` (*chưa có*) | ≥3 login/user, ≥3 role, backup | ………… |
| Tối ưu hiệu năng | `sql/08_ToiUu.sql` (*chưa có*) | ≥3 truy vấn nặng + chỉ mục | ………… |

Lưu ý dễ nhầm: bốn vai trò `PhucVu / ThuNgan / Bep / QuanLy` trong Readme mục 1 là **vai trò trong CSDL** (dùng cho phân quyền M3), **không phải** phân công thành viên trong nhóm.

### 4.2. Nguyên tắc "một vùng — một người"

Đây là quy tắc quan trọng nhất để giảm xung đột, **đề xuất** áp dụng:

> Tại một thời điểm, **mỗi file `.sql` chỉ có đúng một người được sửa**.

Muốn sửa file đang có người khác làm → nhắn trong nhóm trước, hoặc chờ họ merge xong. Lý do: file SQL rất khó merge tự động. Một dấu phẩy sai vị trí sau khi merge có thể làm cả file không chạy được, trong khi Git vẫn báo "merge thành công".

### 4.3. Kênh liên lạc và nhịp làm việc

> **Đề xuất — nhóm cần chốt kênh cụ thể.**

| Nội dung | Cách làm |
|---|---|
| Trao đổi nhanh, hỏi lỗi | Nhóm chat chung (Zalo/Messenger/Discord) — nhóm tự chốt |
| Thông báo "tôi đang sửa file X" | Nhắn trong nhóm chat **trước khi** bắt đầu sửa |
| Thay đổi ảnh hưởng người khác (đổi tên cột, xóa bảng) | Phải được **cả nhóm đồng ý** trước khi commit |
| Rà soát tiến độ | Một buổi/tuần, đối chiếu với mốc M1–M3 |
| Lưu vết công việc | Cập nhật ePortfolio theo tuần (Readme mục 3.11) |

### 4.4. Ai được làm gì với CSDL dùng chung

Repo không có CSDL server dùng chung; mỗi bạn chạy SQL Server trên máy mình. Tuy vậy vẫn có hai rủi ro: (a) chạy script phá hủy làm mất dữ liệu bạn khác đang demo, (b) số liệu trong báo cáo khác nhau giữa các máy.

| Việc | Ai được làm |
|---|---|
| Chạy `sql/01_CAUHINH_CSDL.sql` (xóa + tạo lại CSDL) | Chỉ khi bạn tự chấp nhận mất dữ liệu trên máy mình. **Phải nhắn nhóm** nếu đang demo chung |
| Chạy `sql/02_Bang.sql` (xóa + tạo lại bảng) | Như trên |
| Chạy `scripts/02_SEED.sql` trên CSDL đã có dữ liệu | **Không** — script này không tự xóa dữ liệu cũ, chạy lại sẽ nhân đôi số hóa đơn (xem mục 11.3) |
| Sửa `sql/02_Bang.sql` | Người phụ trách cấu trúc CSDL; thay đổi lớn phải báo nhóm |

---

## 5. Quy trình Git hằng ngày

### 5.1. Sơ đồ tổng quát

```text
master (trên GitHub)  ──①  git switch master / git pull
        │
        ├──②  git switch -c feature/view-doanh-thu
        │        │
        │        ├── sửa file → ③ git add → ④ git commit
        │        │
        │        ├── ⑤ git push -u origin feature/view-doanh-thu
        │        │
        │        └── ⑥ tạo Pull Request trên GitHub
        │
        └──⑦  review chéo → merge vào master → ⑧ xóa nhánh
```

### 5.2. Bước 0 — Lần đầu: lấy mã nguồn và cấu hình

```bash
git clone https://github.com/ShindouAris/BT_CSDL.git
cd BT_CSDL
```

Sau khi clone, **mỗi người tự đặt danh tính Git của mình** (đây là cấu hình trên máy, không nằm trong repo, nên không ai giúp bạn đặt hộ):

```bash
git config user.name  "Họ Tên Của Bạn"
git config user.email "email-cua-ban@example.com"
```

Kiểm tra lại:

```bash
git config --get user.name
git config --get user.email
```

> **Lưu ý riêng của máy khảo sát:** máy này đang bật ký commit tự động (`commit.gpgsign = true`). Nếu máy bạn cũng bật mà chưa có khóa GPG, `git commit` sẽ báo lỗi. Kiểm tra bằng `git config --get commit.gpgsign`; nếu ra `true` mà bạn không dùng GPG, hãy tắt ở mức repo:
>
> ```bash
> git config --local commit.gpgsign false
> ```

### 5.3. Bước 1 — Cập nhật `master` trước khi làm việc mới

**Luôn làm bước này**, kể cả khi bạn chắc là không ai sửa gì.

```bash
git switch master
git pull
```

- `git switch master` đưa bạn về nhánh chính.
- `git pull` = `git fetch` (tải commit mới về) + merge vào nhánh hiện tại. Vì máy đang đặt `pull.rebase = false`, lệnh này sẽ **merge** — phù hợp với quy ước ở mục 9.

> Nếu `git switch` báo `Your local changes would be overwritten`, nghĩa là bạn đang có thay đổi chưa commit. Chọn một trong hai: commit vào nhánh riêng, hoặc `git stash` (cất tạm) — xem mục 12.

### 5.4. Bước 2 — Tạo nhánh riêng

```bash
git switch -c feature/view-doanh-thu
```

`-c` = create: tạo nhánh mới **và** chuyển sang nhánh đó ngay. Từ đây mọi commit của bạn nằm trên nhánh này, `master` không bị ảnh hưởng.

### 5.5. Bước 3–4 — Sửa file, xem lại, commit

```bash
git status                       # file nào đã đổi?
git diff                          # đổi những dòng nào (chưa stage)?
git add sql/04_TruyVan_View.sql  # chọn đúng file cần commit
git diff --staged                 # xem lại đúng những gì sắp commit
git commit -m "feat(sql): thêm 5 truy vấn gom nhóm theo khung giờ"
```

Quy tắc vàng: **`git add` theo từng file cụ thể, không dùng `git add .`** khi chưa xem `git status`. Thói quen `git add .` là nguyên nhân số một khiến người ta commit nhầm file rác.

### 5.6. Bước 5 — Đẩy nhánh lên GitHub

```bash
git push -u origin feature/view-doanh-thu
```

- `-u` (viết tắt của `--set-upstream`) chỉ cần dùng **lần đầu**. Nó ghi nhớ nhánh local này đi với nhánh nào trên `origin`, các lần sau chỉ cần `git push`.
- Tuyệt đối **không** dùng `git push --force` cho nhánh `master`.

### 5.7. Bước 6–8 — Pull request, review, merge, dọn nhánh

Tạo Pull Request trên GitHub (mục 8), nhờ một bạn review, merge xong thì xóa nhánh:

```bash
git switch master
git pull                                  # lấy bản đã merge
git branch -d feature/view-doanh-thu      # xóa nhánh local (đã merge an toàn)
git push origin --delete feature/view-doanh-thu   # xóa nhánh trên GitHub (tùy chọn)
```

`git branch -d` (chữ thường) **từ chối xóa** nếu nhánh chưa được merge — đây là chốt an toàn. Đừng dùng `-D` trừ khi bạn thật sự muốn bỏ phần việc đó.

---

## 6. Quy ước đặt tên nhánh

> **Toàn bộ mục này là ĐỀ XUẤT.** Repo hiện chỉ có `master`, chưa từng dùng nhánh nào. Nhóm cần chốt trước mốc M2.

### 6.1. Định dạng

```text
<loại>/<mô-tả-ngắn>
```

| Loại nhánh | Dùng khi | Ví dụ |
|---|---|---|
| `feature/` | Thêm chức năng mới (view, thủ tục, hàm, trigger…) | `feature/view-doanh-thu` |
| `fix/` | Sửa lỗi trong phần đã có | `fix/seed-trung-mamon` |
| `docs/` | Chỉ sửa tài liệu `.md` | `docs/working-quy-uoc-commit` |
| `chore/` | Việc lặt vặt: thêm `.gitignore`, sắp xếp file | `chore/them-gitignore` |

**Không cần** `hotfix/` hay nhánh `release/`: dự án học tập không có môi trường production, thêm vào chỉ làm phức tạp.

### 6.2. Quy tắc viết tên

- **Không dấu tiếng Việt.** `feature/view-doanh-thu` ✅, `feature/view-doanhthu` ✅, `feature/view-doanh-thụ` ❌.
  Lý do: tên nhánh có dấu gây lỗi hiển thị và lỗi URL trên GitHub, và một số công cụ Windows xử lý sai.
- **Chữ thường, nối bằng gạch ngang.** `feature/them-view` ✅, `feature/ThemView` ❌.
- **Ngắn nhưng đủ nghĩa**, dưới ~40 ký tự. `feature/x` ❌ (không ai hiểu), `feature/them-mot-view-nua-de-tinh-doanh-thu-theo-ngay-va-theo-thang` ❌.
- **Một nhánh = một việc.** Nếu đang làm view mà phát hiện lỗi dữ liệu, tạo nhánh `fix/...` riêng, đừng gộp.

### 6.3. Nhánh `master` trông như thế nào

`master` phải luôn ở trạng thái **chạy được từ đầu đến cuối**: `01_CAUHINH_CSDL.sql` → `02_Bang.sql` → `01_SEED.sql` → `02_SEED.sql` không lỗi. Đây là điều kiện để cuối kỳ lấy bản trên `master` đi nộp.

> **Đề xuất:** trước khi merge vào `master`, người review phải tự chạy lại toàn bộ chuỗi script trên máy mình.

---

## 7. Quy ước thông điệp commit

> **Đề xuất.** Repo hiện có 3 commit với thông điệp tự do (`upload seed data`, `Refactor SQL scripts…`). Chưa có quy ước thống nhất.

### 7.1. Định dạng

```text
<loại>(<phạm-vi>): <mô tả ngắn, thể mệnh lệnh>

<phần thân tùy chọn: giải thích VÌ SAO, không phải CÁI GÌ>
```

### 7.2. Các `<loại>` được dùng

| Loại | Ý nghĩa |
|---|---|
| `feat` | Thêm đối tượng mới: bảng, view, thủ tục, hàm, trigger |
| `fix` | Sửa lỗi |
| `docs` | Chỉ thay đổi tài liệu |
| `refactor` | Đổi cách viết, không đổi hành vi (ví dụ đổi tên biến, tách file) |
| `data` | Thay đổi dữ liệu mẫu trong `scripts/` |
| `chore` | Việc phụ trợ: `.gitignore`, sắp xếp thư mục |

### 7.3. Các `<phạm-vi>` được dùng

Bám theo đúng thư mục và mốc bàn giao của repo:

| Phạm vi | Áp dụng cho |
|---|---|
| `sql` | `sql/01_CAUHINH_CSDL.sql`, `sql/02_Bang.sql` |
| `seed` | `scripts/01_SEED.sql`, `scripts/02_SEED.sql` |
| `view`, `query` | Truy vấn và view (M2) |
| `sp`, `func` | Stored procedure và function (M2) |
| `trigger`, `tran` | Trigger và giao tác (M3) |
| `security`, `backup` | Phân quyền và sao lưu (M3) |
| `perf` | Tối ưu, chỉ mục (M3) |
| `docs` | Các file `.md` |

### 7.4. Ví dụ cụ thể

```text
feat(view): thêm view vw_DoanhThuTheoNgay

View tổng hợp doanh thu từ HoaDon và ChiTietHoaDon theo ngày,
chỉ tính hóa đơn có TrangThai = N'Đã thanh toán', phục vụ báo cáo M2.
```

```text
fix(seed): sửa lỗi hóa đơn bị trùng món

Vòng lặp sinh chi tiết chọn món ngẫu nhiên nhưng chưa loại các món
đã có trong hóa đơn, gây vi phạm khóa chính (MaHD, MaMon).
```

```text
docs(working): bổ sung quy ước đặt tên nhánh
```

```text
chore(repo): thêm .gitignore chặn file .mdf, .ldf, .bak
```

```text
data(seed): tăng số hóa đơn mẫu từ 1500 lên 2000
```

### 7.5. Quy tắc viết

- Dòng đầu **≤ 72 ký tự**, không kết thúc bằng dấu chấm.
- Dùng **thể mệnh lệnh**: "thêm view", không phải "đã thêm view" hay "thêm view rồi".
- Phần `loại(phạm-vi)` giữ **tiếng Anh không dấu** để máy đọc được; phần mô tả **viết tiếng Việt có dấu bình thường**.
- **Một commit = một thay đổi có nghĩa.** Đừng gộp "thêm view + sửa 3 bảng + xóa file" vào một commit; sau này muốn hủy đúng phần sai sẽ rất khó.

---

## 8. Pull request và review chéo

> **Đề xuất.** Repo dùng GitHub, nhưng lịch sử Git cho thấy **chưa từng có nhánh phụ hay merge commit** — cả 3 commit đều nằm thẳng trên `master`. Việc trên GitHub trước đây có Pull Request nào hay không thì **chưa kiểm chứng** (tài liệu này không truy cập được lịch sử PR). Nhóm nên chuyển sang luồng PR từ M2 để mọi thay đổi đều có người thứ hai đọc.

### 8.1. Khi nào phải tạo PR

| Trường hợp | Cần PR? |
|---|---|
| Thay đổi `sql/02_Bang.sql` (cấu trúc bảng, ràng buộc) | **Bắt buộc** — cả nhóm phụ thuộc cấu trúc này |
| Thêm view / thủ tục / hàm / trigger mới | **Bắt buộc** |
| Sửa `scripts/02_SEED.sql` (dữ liệu dùng để báo cáo) | **Bắt buộc** |
| Sửa lỗi chính tả trong file `.md` | Không cần, nhưng vẫn nên nhắn nhóm |
| Sửa comment trong SQL | Không cần |

### 8.2. Mẫu mô tả PR (dán vào ô Description)

```markdown
## Việc gì
Thêm view `vw_BanDangSuDung` liệt kê bàn đang có khách.

## Vì sao
Readme mục 3.4 yêu cầu ≥3 view, một view phải giới hạn cột/dòng để phân quyền.
View này chỉ trả về cột cần thiết cho vai trò `PhucVu`.

## Đã kiểm tra
- [ ] Chạy lại toàn bộ chuỗi 01 → 02 → SEED 01 → SEED 02, không lỗi
- [ ] `SELECT * FROM vw_BanDangSuDung` trả về đúng 5 dòng (5 bàn "Có khách")
- [ ] Không có thay đổi ngoài phạm vi (không sửa file của người khác)

## Người review cần chú ý
Điều kiện `WHERE TrangThai = N'Có khách'` phụ thuộc đúng chuỗi dấu tiếng Việt.
```

### 8.3. Checklist cho người review

Người review **không** chỉ đọc code, cần đối chiếu với Readme:

- [ ] Thay đổi có đúng phạm vi mô tả không? Có file lạ nào bị sửa lây không?
- [ ] Tên đối tượng SQL có theo quy ước chung của nhóm (`vw_`, `sp_`, `fn_`) không?
- [ ] Có viết đúng tiếng Việt có dấu trong `N'...'` không? (`N'Có khách'` ≠ `N'Co khach'`)
- [ ] Có làm hỏng thứ tự chạy script không? (xem mục 10.1)
- [ ] Nếu sửa bảng: đã cập nhật `DROP TABLE` ở đầu `02_Bang.sql` chưa?
- [ ] Có chứa đường dẫn tuyệt đối của máy cá nhân, mật khẩu, hay tên người thật không?
- [ ] Bạn tự chạy lại được script trên máy mình chưa?
- [ ] Bạn **giải thích được** đoạn code này nếu bị giảng viên hỏi không? (Readme mục 3.9)

### 8.4. Nhận và xử lý góp ý

- Không xem góp ý là chỉ trích. Câu hỏi "chỗ này để làm gì?" thường là dấu hiệu code chưa rõ, không phải người review khó tính.
- Sửa theo góp ý: **commit thêm** vào cùng nhánh, đẩy lên. PR sẽ tự cập nhật, không cần tạo PR mới.
- Không đồng ý: trả lời bằng lý do kỹ thuật ngay trong PR, đừng im lặng rồi merge.
- Tuyệt đối không tự merge PR của chính mình khi chưa có ai review, trừ trường hợp nhóm đã thống nhất.

---

## 9. Giải quyết xung đột (conflict)

### 9.1. Xung đột là gì và khi nào xảy ra

Xung đột xảy ra khi **hai người sửa cùng một dòng của cùng một file** và Git không tự quyết định được giữ bản nào. Với repo này, xung đột hay gặp ở:

- `sql/02_Bang.sql` — nhiều người cùng thêm bảng/cột.
- `scripts/01_SEED.sql` — nhiều người cùng thêm dòng dữ liệu vào cuối danh sách `INSERT`.
- Bất kỳ file `.md` nào khi cả nhóm cùng sửa tài liệu.

Xung đột **không phải lỗi**. Nó chỉ có nghĩa Git cần con người quyết định.

### 9.2. Quy trình 6 bước

```bash
# 1. Cập nhật master mới nhất
git switch master
git pull

# 2. Quay lại nhánh của bạn và hợp nhất master vào
git switch feature/view-doanh-thu
git merge master
# → Git báo: CONFLICT (content): Merge conflict in sql/02_Bang.sql
```

```bash
# 3. Xem file nào đang xung đột
git status
#    both modified:   sql/02_Bang.sql
```

4. **Mở file, tìm các dấu hiệu xung đột.** Chúng luôn có dạng:

```sql
<<<<<<< HEAD
    -- Bản của BẠN (nhánh hiện tại)
    CONSTRAINT CK_Ban_TrangThai CHECK (TrangThai IN (N'Trống', N'Có khách', N'Đã đặt'))
=======
    -- Bản của NGƯỜI KHÁC (master vừa merge vào)
    CONSTRAINT CK_Ban_TrangThai CHECK (TrangThai IN (N'Trống', N'Có khách', N'Đã đặt', N'Bảo trì'))
>>>>>>> master
```

5. **Sửa tay** để có nội dung cuối cùng đúng ý, rồi **xóa cả ba dòng đánh dấu** `<<<<<<<`, `=======`, `>>>>>>>`.
   Thường phải **kết hợp cả hai**, không phải chọn một. Ví dụ trên: nếu nhóm đồng ý thêm trạng thái `N'Bảo trì'` thì giữ bản dưới.

```bash
# 6. Đánh dấu đã giải quyết và hoàn tất merge
git add sql/02_Bang.sql
git commit                # Git tự soạn sẵn thông điệp merge
git push
```

### 9.3. Quy tắc riêng khi xung đột trong file `.sql`

Đây là phần quan trọng nhất của mục này, vì **merge thành công không có nghĩa là script còn chạy được**:

1. **Đọc cả hai phía trước khi sửa.** Đừng xóa bản của người khác chỉ vì bạn không hiểu nó.
2. **Kiểm tra tính đối xứng.** Nếu thêm bảng mới, phải thêm cả:
   - `DROP TABLE IF EXISTS` ở đầu `sql/02_Bang.sql` (đúng thứ tự con → cha),
   - `CREATE TABLE` ở phần thân.
   Thiếu một trong hai là script hỏng hoặc chạy lại bị lỗi.
3. **Quét lại toàn file tìm dấu vết xung đột còn sót:**

   ```bash
   grep -nE '^(<<<<<<<|=======|>>>>>>>)' sql/02_Bang.sql scripts/*.sql
   ```
   Kết quả rỗng = đã sạch. Nếu còn, script sẽ lỗi cú pháp.
4. **Chạy lại từ đầu trong môi trường sạch** (xem 9.4). Đây là bước bắt buộc, không phải tùy chọn.
5. **Kiểm tra thứ tự `DROP`.** Nếu người khác thêm bảng tham chiếu `HoaDon` mà đặt `DROP` của nó sau `HoaDon`, script sẽ lỗi `Could not drop object ... because it is referenced by a FOREIGN KEY constraint`.

### 9.4. Cách kiểm chứng sau khi giải quyết xung đột

Chạy lại **toàn bộ chuỗi** theo đúng thứ tự, không chạy lẻ:

```text
sql/01_CAUHINH_CSDL.sql   →   sql/02_Bang.sql   →   scripts/01_SEED.sql   →   scripts/02_SEED.sql
```

> **Cảnh báo thực tế:** `sql/01_CAUHINH_CSDL.sql` **xóa CSDL `QL_CAFE_NHAHANG`** rồi tạo lại, tên CSDL được viết cứng. Bạn không thể vừa kiểm chứng an toàn vừa giữ dữ liệu cũ. Hai cách xử lý:
> - **Cách 1 (khuyến nghị):** chấp nhận xóa, nhưng **nhắn nhóm trước** nếu có ai đang demo.
> - **Cách 2:** sao chép script ra file tạm **không commit**, đổi tên CSDL thành `QL_CAFE_NHAHANG_TEST`, chạy thử ở đó. Nhớ xóa file tạm trước khi `git status`.

### 9.5. Khi nào nên bỏ và làm lại

Nếu xung đột rối (hàng chục dòng, hai người cùng viết lại một đoạn), đừng cố sửa tay. Lùi lại rồi làm gọn hơn:

```bash
git merge --abort          # hủy merge, quay về trạng thái trước khi merge
```

Rồi chia nhỏ công việc: nhờ người kia merge trước, bạn `git pull` lại và viết phần của mình **sau** — cách này gần như luôn dễ hơn sửa xung đột.

---

## 10. Cộng tác trên các file SQL

Phần này là đặc thù của dự án CSDL: code không "build" ra sản phẩm, mà **chạy theo thứ tự** để tạo ra trạng thái CSDL. Sai thứ tự = sai kết quả, dù từng câu lệnh đều đúng.

### 10.1. Thứ tự chạy là bất biến

```text
1. sql/01_CAUHINH_CSDL.sql      Tạo CSDL rỗng QL_CAFE_NHAHANG
2. sql/02_Bang.sql              Tạo 10 bảng + ràng buộc + chỉ mục
3. scripts/01_SEED.sql          Nạp dữ liệu danh mục
4. scripts/02_SEED.sql          Sinh hóa đơn + chi tiết, tính TongTien
```

Vì sao không được đổi:

| Script | Phụ thuộc vào | Nếu chạy sai thứ tự |
|---|---|---|
| `02_Bang.sql` | `01_CAUHINH_CSDL.sql` đã tạo CSDL; `USE QL_CAFE_NHAHANG` ở dòng 1 | Lỗi `Cannot open database` |
| `01_SEED.sql` | 10 bảng đã tồn tại; IDENTITY bắt đầu từ 1 | Khóa ngoại sai, `MaMon` lệch so với `MonAn`/`ThucUong`/`DinhLuong` |
| `02_SEED.sql` | Dữ liệu danh mục đã có; ít nhất 1 nhân viên `PhucVu`, ≥1 món `DangBan = 1` | `THROW 50001/50002/50003` — script tự dừng và báo lỗi |

Điểm đáng chú ý: **`01_SEED.sql` gán `MaMon` bằng số cứng** (1..18 cho `MonAn`, 19..36 cho `ThucUong`, và `DinhLuong` tham chiếu 1..36). Nếu chạy `01_SEED.sql` khi bảng `Mon` **đã có dữ liệu**, `IDENTITY` sẽ bắt đầu từ số khác 1, toàn bộ tham chiếu cứng này trỏ sai món. Vì vậy: **luôn nạp dữ liệu trên CSDL vừa tạo lại từ đầu.**

### 10.2. Quy tắc sửa `sql/02_Bang.sql`

File này là "xương sống" — mọi người đều phụ thuộc. Khi sửa:

1. **Thêm bảng mới → phải sửa hai chỗ:** thêm `DROP TABLE IF EXISTS` vào **đầu file**, và `CREATE TABLE` vào **cuối file** (hoặc đúng nhóm chức năng).
2. **Thứ tự `DROP` là con → cha.** Hiện tại file đang đúng:
   `ChiTietHoaDon → HoaDon → DinhLuong → MonAn → ThucUong → Mon → NguyenLieu → NhanVien → Ban → LoaiMon`.
   Bảng mới tham chiếu bảng nào thì phải `DROP` **trước** bảng đó.
3. **Không đổi tên cột/bảng đã có** mà chưa báo nhóm. Sẽ làm hỏng `scripts/*.sql` và mọi truy vấn của người khác.
4. **Giữ nguyên kiểu dữ liệu đã thống nhất**, đặc biệt `DECIMAL(12,0)` cho tiền và `NVARCHAR` cho chuỗi tiếng Việt. Đổi `NVARCHAR` → `VARCHAR` sẽ làm mất dấu tiếng Việt và khiến các `CHECK` so sánh chuỗi thất bại.

### 10.3. Quy tắc sửa `scripts/*.sql`

1. **Không chạy lại trên CSDL đã có dữ liệu.** Hai script này **không tự xóa** dữ liệu cũ và **không kiểm tra trùng**. Chạy `02_SEED.sql` hai lần trên cùng CSDL sẽ tạo thêm 1.500 hóa đơn nữa, và mỗi bàn "Có khách" sẽ có **2 hóa đơn Mở** — vi phạm nghiệp vụ (hiện **chưa có** ràng buộc nào chặn điều này).
2. **Giữ đúng số dòng cam kết.** `02_SEED.sql` có các biến `@TongHD = 1500`, `@TongCT = 5000`, `@SoHDTrong = 5` và kiểm tra chéo ở cuối. Nếu sửa một biến mà không tính lại các biến liên quan, script sẽ `THROW 50007` / `THROW 50011`.
3. **Dữ liệu sinh ra là ngẫu nhiên.** Script dùng `CHECKSUM(NEWID())` nên **mỗi lần chạy cho kết quả khác nhau**. Hệ quả cho nhóm:
   - Số liệu trong báo cáo ("top 10 món bán chạy", "doanh thu tháng") **sẽ khác nhau giữa các máy**.
   - Đừng so sánh kết quả truy vấn của mình với bạn rồi kết luận "sai". Chỉ so sánh **cấu trúc** kết quả (số cột, kiểu dữ liệu, thứ tự sắp xếp).
   - Nếu báo cáo cần số liệu cố định, nhóm phải thống nhất: chạy một lần, xuất kết quả, hoặc chụp ảnh màn hình kèm ngày giờ. **Đây là điểm nhóm cần chốt** (xem mục 14).
4. **Không sửa tay dữ liệu đã nạp bằng `UPDATE`/`DELETE` lẻ** rồi commit. Người khác chạy lại từ đầu sẽ không có thay đổi đó.

### 10.4. Nhất quán dữ liệu dẫn xuất: `HoaDon.TongTien`

`HoaDon.TongTien` là **dữ liệu dẫn xuất** — nó phải luôn bằng `SUM(ChiTietHoaDon.SoLuong * DonGia)`. Giá trị này được tính bằng một câu `UPDATE` ở BƯỚC 4 của `scripts/02_SEED.sql`.

> **Quy tắc:** nếu bạn thêm/sửa/xóa dòng trong `ChiTietHoaDon`, **bắt buộc** phải tính lại `TongTien` của hóa đơn liên quan. Hiện **chưa có trigger** tự làm việc này (Readme xếp trigger vào M3).

Câu kiểm tra nhanh — kết quả phải rỗng:

```sql
SELECT h.MaHD, h.TongTien, ISNULL(SUM(ct.SoLuong * ct.DonGia), 0) AS TongChiTiet
FROM dbo.HoaDon AS h
LEFT JOIN dbo.ChiTietHoaDon AS ct ON ct.MaHD = h.MaHD
GROUP BY h.MaHD, h.TongTien
HAVING h.TongTien <> ISNULL(SUM(ct.SoLuong * ct.DonGia), 0);
```

### 10.5. Mã hóa file và xuống dòng

Đã kiểm tra: cả 4 file `.sql` là **UTF-8 không BOM**, xuống dòng **CRLF**. Điều này quan trọng vì hai lý do:

- **Tiếng Việt:** dữ liệu dùng `N'...'` với dấu đầy đủ. Nếu ai lưu file bằng **ANSI / Windows-1258**, các chuỗi như `N'Có khách'` sẽ bị hỏng và `CHECK (TrangThai IN (...))` sẽ **từ chối dữ liệu đúng**.
- **BOM:** nếu thêm BOM vào đầu file, một số công cụ dòng lệnh cũ có thể đọc sai ký tự đầu tiên.

> **Quy tắc:** luôn lưu `.sql` ở **UTF-8 (không BOM)**. Trong VS Code xem ở thanh trạng thái góc dưới phải; nếu thấy `UTF-8 with BOM` hãy đổi lại.

Về xuống dòng: vì `core.autocrlf = true`, Git tự chuyển đổi. Nếu `git diff` hiện **toàn bộ file** là thay đổi dù bạn chỉ sửa 1 dòng, gần như chắc chắn là do khác biệt CRLF/LF, **không phải** bạn làm hỏng gì. Cách kiểm tra và xử lý ở mục 12.

### 10.6. Đường dẫn tuyệt đối trong script

`sql/01_CAUHINH_CSDL.sql` chứa đường dẫn cứng:

```sql
FILENAME = N'C:\SQLData\QL_CAFE_NHAHANG.mdf'
```

Trên máy khảo sát, thư mục `C:\SQLData` **đã tồn tại**. Trên máy bạn khác, nếu chưa có, `CREATE DATABASE` sẽ lỗi:

> `Directory lookup for the file "C:\SQLData\QL_CAFE_NHAHANG.mdf" failed with the operating system error 2 (The system cannot find the file specified.)`

Cách xử lý: **tạo thư mục** `C:\SQLData` bằng quyền Administrator, **không sửa đường dẫn trong script** rồi commit — vì sẽ làm script hỏng trên máy người khác. Nếu nhóm thống nhất đổi đường dẫn chung thì đó là quyết định của cả nhóm, phải báo trước.

### 10.7. Tên đối tượng dùng chung

> **Đề xuất nhóm chốt** trước khi làm M2, để tránh mỗi người một kiểu:

| Loại đối tượng | Tiền tố | Ví dụ |
|---|---|---|
| View | `vw_` | `vw_DoanhThuTheoNgay` |
| Stored procedure | `sp_` | `sp_GoiMon` (Readme đã gợi ý tên này) |
| Function vô hướng | `fn_` | `fn_GiaVonMon` (Readme đã gợi ý) |
| Function bảng | `fn_` | `fn_NguyenLieuDuoiDinhMuc` (Readme đã gợi ý) |
| Trigger | `trg_` | `trg_ChiTietHoaDon_CapNhatTonKho` |
| Chỉ mục | `IX_` / `UX_` | `IX_HoaDon_NgayLap`, `UX_NhanVien_SDT` (đã có) |
| Ràng buộc | `PK_`, `FK_`, `CK_`, `DF_`, `UQ_` | theo mẫu đang dùng trong `02_Bang.sql` |

Việc giữ đúng tiền tố quan trọng vì `02_Bang.sql` đang dùng chính xác các mẫu này — đặt tên lệch sẽ làm khó truy vết khi có lỗi.

---

## 11. Quy định riêng của dự án

### 11.1. Môi trường

- SQL Server 2025, instance `MSSQLSERVER` (máy khảo sát: `17.0.1000.7`).
- Không có build system, không có `package.json`, không có script tự động: **mọi thứ chạy bằng tay** trong SSMS hoặc `sqlcmd`.
- Không có kiểm thử tự động. "Test" của dự án là **chạy lại toàn bộ chuỗi script và các câu kiểm tra ở cuối mỗi script seed**.

### 11.2. Trước khi bắt đầu làm việc

- [ ] `C:\SQLData` tồn tại (nếu chưa, tạo bằng quyền Administrator).
- [ ] Tài khoản đăng nhập SQL Server có quyền `CREATE DATABASE` và `DROP DATABASE`.
- [ ] Đã `git pull` bản mới nhất của `master`.
- [ ] Đã đọc phần liên quan trong [Readme.md](Readme.md) và, nếu sửa `sql/`, đọc [Explains.md](Explains.md).

### 11.3. Quy trình kiểm thử tối thiểu trước khi push

Đây là "definition of done" của nhóm — **đề xuất** áp dụng:

1. Chạy `sql/01_CAUHINH_CSDL.sql` → không lỗi.
2. Chạy `sql/02_Bang.sql` → không lỗi.
3. Chạy `scripts/01_SEED.sql` → 3 bảng kiểm tra cuối trả về đúng: `11 / 15 / 12 / 28 / 36 / 18 / 18 / 130`.
4. Chạy `scripts/02_SEED.sql` → `HoaDon = 1500`, `ChiTietHoaDon = 5000`, số hóa đơn rỗng `= 5`, mọi câu kiểm tra lỗi trả về **rỗng**.
5. Đối chiếu thay đổi của bạn: `git diff master --stat` chỉ ra đúng những file bạn định sửa.

> **Chưa kiểm chứng bởi tài liệu này:** các con số ở bước 3–4 là **giá trị mà script tự khai báo** trong comment và biến, không phải kết quả đã chạy thật trên môi trường này. Lần chạy đầu tiên của nhóm nên xác nhận lại và ghi vào nhật ký.

### 11.4. File được và không được commit

**Phải commit:**

- Toàn bộ `.sql` trong `sql/` và `scripts/`.
- Các file `.md` tài liệu.
- Sau này: `.cdm`, `.pdm` của PowerDesigner, báo cáo `.docx`/`.pdf`, nhật ký AI.

**Không được commit** (hiện **chưa có `.gitignore`** nên Git sẽ không tự chặn):

- File CSDL: `*.mdf`, `*.ldf`, `*.ndf` — dung lượng lớn, gắn với một máy cụ thể.
- Bản sao lưu: `*.bak`, `*.trn`, `*.dif`.
- Thư mục làm việc của Visual Studio / SSMS: `.vs/`, `*.sql~`, `*.tmp`.
- File cấu hình cá nhân, connection string có mật khẩu.
- Bất kỳ file chứa **thông tin người thật** (Readme mục 3.3 cấm dùng dữ liệu cá nhân thật).

> **Đề xuất:** tạo `.gitignore` ở gốc repo với nội dung tối thiểu dưới đây. Việc tạo file này **chưa được thực hiện** trong lần làm tài liệu này vì yêu cầu chỉ cho phép tạo tài liệu.
>
> ```gitignore
> # CSDL và bản sao lưu
> *.mdf
> *.ldf
> *.ndf
> *.bak
> *.trn
> *.dif
>
> # Công cụ
> .vs/
> *.sql~
> *.tmp
>
> # Hệ điều hành
> Thumbs.db
> .DS_Store
> ```

Nếu **lỡ commit** một file trong danh sách trên, xử lý ở mục 12 (mục "Đã commit nhầm file").

### 11.5. Bảo mật

Từ M3, Readme yêu cầu tạo login/user và phân quyền. Những điều **phải** tuân thủ:

- **Không commit mật khẩu thật.** Trong script phân quyền, dùng mật khẩu giả và ghi chú rõ:

  ```sql
  -- Mật khẩu mẫu dùng cho bài tập, KHÔNG dùng cho hệ thống thật
  CREATE LOGIN PhucVu01 WITH PASSWORD = N'MatKhauMau@123', CHECK_POLICY = OFF;
  ```

- Không đưa tên, số điện thoại, email thật của người khác vào dữ liệu mẫu. Dữ liệu hiện tại (`Nguyễn Văn An`, `0901234501`…) là hư cấu — hãy giữ nguyên tính chất đó.
- Không đưa connection string có mật khẩu vào bất kỳ file nào trong repo.
- Readme mục 3.9 cũng yêu cầu: **không đưa dữ liệu thật hoặc thông tin nhạy cảm vào lời nhắc AI**.

### 11.6. File tài liệu phải đồng bộ

Nếu bạn đổi cấu trúc bảng hoặc thứ tự chạy script, **phải** cập nhật:

- [Explains.md](Explains.md) — phần mô tả bảng tương ứng.
- [Explain_TLDR.md](Explain_TLDR.md) — nếu thay đổi ảnh hưởng tới phần tóm tắt.
- [Readme.md](Readme.md) — chỉ khi giảng viên yêu cầu hoặc nhóm quyết định đổi phạm vi đề tài; **không sửa Readme tùy tiện** vì đó là đề bài gốc.

Đổi quy ước làm việc (nhánh, commit) thì cập nhật cả [WORKING.md](WORKING.md) và [Working_TLDR.md](Working_TLDR.md).

---

## 12. Lỗi thường gặp và cách cứu

| Tình huống | Triệu chứng | Cách xử lý an toàn |
|---|---|---|
| **Quên `git pull` trước khi làm** | `git push` bị từ chối: `Updates were rejected because the remote contains work...` | `git pull` (merge), giải quyết xung đột theo mục 9, rồi `git push`. **Không** dùng `--force` |
| **Commit nhầm vào `master` (chưa push)** | `git log` thấy commit của mình nằm trên `master` | `git branch feature/viec-cua-toi` (giữ commit lại) → `git reset --hard origin/master` → `git switch feature/viec-cua-toi`. Commit của bạn vẫn còn nguyên trên nhánh mới |
| **Đã commit nhầm file rác (`.bak`, `.mdf`)** | `git status` hoặc `git log --stat` thấy file lạ | `git rm --cached <file>` → thêm vào `.gitignore` → commit lại. Lưu ý: file **vẫn còn trong lịch sử**; muốn xóa hẳn phải viết lại lịch sử (`git filter-repo`) — việc này **phải hỏi giảng viên**, đừng tự làm |
| **Đã `git add` nhưng chưa commit, muốn bỏ ra** | File nằm ở vùng staging | `git restore --staged <file>` — **an toàn**, nội dung sửa vẫn còn |
| **Muốn hủy sửa đổi chưa commit của một file** | — | `git restore <file>` — ⚠️ **mất phần sửa**, không lấy lại được |
| **Lỡ `git reset --hard` mất code** | Nhánh bị tụt về commit cũ | `git reflog` → tìm commit cũ → `git reset --hard <mã>` hoặc `git switch -c cuu-lai <mã>`. Reflog giữ ~30 ngày trên máy bạn |
| **Lỡ xóa nhánh chưa merge** | `git branch -D feature/x` | `git reflog` tìm commit cuối của nhánh → `git switch -c feature/x <mã>` |
| **File `.sql` bị báo lỗi ở dòng 1 sau khi clone** | Lỗi ký tự lạ, hoặc so sánh chuỗi tiếng Việt sai | Kiểm tra encoding phải là UTF-8 (không BOM). Trong VS Code: góc dưới phải → `UTF-8` |
| **`git diff` hiện cả file dù chỉ sửa 1 dòng** | Hàng nghìn dòng `+`/`-` | Do CRLF/LF. Kiểm tra `git config --get core.autocrlf` (nên là `true` trên Windows). Đừng commit kiểu này — `git restore <file>` rồi sửa lại |
| **Chạy script bị `Cannot open database "QL_CAFE_NHAHANG"`** | Thiếu CSDL | Chạy `sql/01_CAUHINH_CSDL.sql` trước |
| **`CREATE DATABASE` lỗi "Directory lookup ... error 2"** | Thiếu thư mục | Tạo `C:\SQLData` bằng quyền Administrator (mục 10.6) |
| **`DROP TABLE` lỗi "referenced by a FOREIGN KEY constraint"** | Thứ tự xóa sai | Sửa thứ tự `DROP` trong `02_Bang.sql`: con trước, cha sau (mục 10.2) |
| **`INSERT` bị từ chối bởi `CHECK` constraint** | Ví dụ `TrangThai` sai dấu | Đây là hệ thống hoạt động **đúng**. Kiểm tra chuỗi có `N'...'` và đúng dấu tiếng Việt |
| **Chạy `02_SEED.sql` lần hai, số hóa đơn thành 3000** | Không có kiểm tra trùng | Tạo lại CSDL từ đầu: chạy lại `01` → `02` → `SEED 01` → `SEED 02` |
| **Không đẩy được vì `src refspec ... does not match any`** | Tên nhánh gõ sai | `git branch` xem tên thật, rồi push lại đúng tên |

### 12.1. Ba lệnh phá hủy — đọc kỹ trước khi gõ

| Lệnh | Tác dụng | Mức nguy hiểm |
|---|---|---|
| `git reset --hard` | Xóa **mọi** thay đổi chưa commit và tua nhánh về commit chỉ định | 🔴 Cao — mất code chưa commit vĩnh viễn |
| `git clean -fd` | Xóa **mọi** file chưa được Git theo dõi (kể cả file bạn vừa tạo) | 🔴 Cao |
| `git push --force` | Ghi đè lịch sử trên GitHub, **xóa commit của người khác** | 🔴 Rất cao — cấm dùng trên `master` |

Nếu buộc phải dùng, chỉ dùng `--force-with-lease` (an toàn hơn, từ chối nếu có người vừa đẩy lên) và **chỉ trên nhánh cá nhân của bạn**, sau khi đã báo nhóm.

---

## 13. Ví dụ thực hành theo kịch bản

### 13.1. Kịch bản A — Thêm một view mới (M2)

```bash
# 1. Về master, lấy bản mới nhất
git switch master
git pull

# 2. Tạo nhánh cho việc này
git switch -c feature/view-ban-dang-su-dung

# 3. Tạo file mới theo thứ tự script mà Readme quy định
#    (hiện chưa có, đây là file sẽ tạo)
#    sql/04_TruyVan_View.sql

# 4. Xem mình đã đụng vào những gì
git status
#    new file:   sql/04_TruyVan_View.sql

# 5. Chạy thử trong SSMS: tạo view, rồi SELECT để kiểm tra

# 6. Stage và xem lại đúng nội dung sắp commit
git add sql/04_TruyVan_View.sql
git diff --staged

# 7. Commit theo quy ước
git commit -m "feat(view): thêm view vw_BanDangSuDung"

# 8. Đẩy lên
git push -u origin feature/view-ban-dang-su-dung

# 9. Lên GitHub tạo Pull Request (mục 8.2), nhờ một bạn review
```

### 13.2. Kịch bản B — Sửa dữ liệu mẫu mà không phá dữ liệu người khác

Giả sử bạn cần thêm 5 nguyên liệu mới.

```bash
git switch master
git pull
git switch -c data/them-nguyen-lieu
```

Mở `scripts/01_SEED.sql`, tìm khối `INSERT INTO NguyenLieu` và **thêm dòng vào cuối danh sách** (không chèn giữa, để giảm xung đột với người khác):

```sql
    (N'Bột ngọt',   N'kg',  5.00,  2.00,  45000.00),  -- 29
```

Kiểm tra trước khi commit — **đếm lại số dòng khai báo**:

```sql
SELECT COUNT(*) FROM dbo.NguyenLieu;   -- phải là 28 + 5 = 33
```

Sau đó:

```bash
git add scripts/01_SEED.sql
git commit -m "data(seed): thêm 5 nguyên liệu cho thực đơn mới"
git push -u origin data/them-nguyen-lieu
```

> **Lưu ý:** vì `DinhLuong` tham chiếu `MaNL` bằng số, thêm nguyên liệu vào **cuối** thì an toàn. Nếu **chèn giữa**, toàn bộ `MaNL` phía sau bị dịch số, và mọi dòng `DinhLuong` sẽ trỏ sai nguyên liệu.

### 13.3. Kịch bản C — Xem ai đã sửa dòng gây lỗi

```bash
git log --oneline -- sql/02_Bang.sql     # lịch sử các commit đụng file này
git blame sql/02_Bang.sql                 # ai sửa dòng nào, commit nào
git show ae0841e                          # xem chi tiết một commit
```

`git blame` rất hữu ích khi một ràng buộc bị đổi mà không ai nhớ lý do: nó chỉ ra commit và thời điểm. Từ đó `git show <mã>` xem nội dung thay đổi, và hỏi trực tiếp người đó thay vì đoán.

### 13.4. Kịch bản D — Hai người cùng sửa `02_Bang.sql`

Đây là tình huống thực tế sẽ xảy ra. Cách giảm đau:

1. **Nhắn trước:** "Mình đang thêm bảng `DatBan` vào `02_Bang.sql`, khoảng 30 phút nữa xong."
2. Người kia chờ, hoặc làm việc khác (view/thủ tục không đụng bảng).
3. Ai xong trước thì merge trước; người sau `git pull` rồi mới sửa tiếp.
4. Nếu buộc phải song song: **chia vùng rõ ràng** — người A sửa phần `CREATE TABLE`, người B sửa phần `ALTER TABLE` + chỉ mục. Xung đột sẽ ít và dễ sửa.
5. Sau khi merge, **bắt buộc** chạy lại toàn chuỗi (mục 9.4).

> Ghi nhớ: Git chỉ so sánh **từng dòng**. Hai người sửa hai vùng khác nhau trong cùng file thường merge tự động được. Xung đột nặng xảy ra khi cả hai cùng sửa **một khối lệnh**.

---

## 14. Những điều nhóm còn phải thống nhất

Checklist này liệt kê những chỗ **tài liệu đưa ra đề xuất nhưng repo chưa có gì ràng buộc**. Nhóm họp chốt rồi đánh dấu:

- [ ] **Đặt tên nhánh:** dùng đúng bộ `feature/ fix/ docs/ chore/` như mục 6?
- [ ] **Định dạng commit:** dùng `loại(phạm-vi): mô tả` như mục 7?
- [ ] **Có bắt buộc PR không**, hay nhóm nhỏ (3 người) cho phép push trực tiếp lên nhánh riêng rồi merge tay?
- [ ] **Ai review** khi chỉ có 3 thành viên? (gợi ý: xoay vòng, mỗi PR cần 1 người không phải tác giả)
- [ ] **Tạo `.gitignore`** như mục 11.4? Ai tạo, khi nào?
- [ ] **Có chuẩn hóa tên file** theo Readme mục 3.10 (`01_CSDL` … `08_ToiUu`) không? Hiện tại thư mục `sql/` chỉ có `01_CAUHINH_CSDL.sql`, `02_Bang.sql`; phần dữ liệu lại nằm ở `scripts/`. **Cần chốt** vì đây là yêu cầu nộp bài.
- [ ] **Số liệu trong báo cáo** lấy từ lần chạy nào, khi dữ liệu sinh ngẫu nhiên mỗi lần (mục 10.3)?
- [ ] **Đường dẫn `C:\SQLData`** giữ nguyên cho cả nhóm, hay đổi sang đường dẫn khác?
- [ ] **Phân công theo bảng 4.1** — điền tên thật vào.
- [ ] **Nhật ký AI** (Readme mục 3.9) lưu ở đâu, ai tổng hợp?

---

## 15. Phụ lục: bảng tra lệnh Git

| Lệnh | Việc gì | Khi nào dùng |
|---|---|---|
| `git clone <url>` | Tải toàn bộ repo về máy | Lần đầu |
| `git status` | Xem file nào đã đổi, đang ở nhánh nào | **Trước và sau mỗi thao tác** |
| `git switch <nhánh>` | Chuyển nhánh | Chuyển việc |
| `git switch -c <nhánh>` | Tạo nhánh mới và chuyển sang | Bắt đầu việc mới |
| `git branch` | Liệt kê nhánh local (`-a` gồm cả remote) | Kiểm tra |
| `git branch -d <nhánh>` | Xóa nhánh đã merge | Dọn dẹp |
| `git pull` | Tải + merge thay đổi mới nhất | **Đầu mỗi buổi làm việc** |
| `git fetch` | Chỉ tải về, không merge | Muốn xem trước khi merge |
| `git diff` | Xem thay đổi chưa stage | Trước khi `add` |
| `git diff --staged` | Xem thay đổi đã stage | **Trước khi `commit`** |
| `git add <file>` | Đưa file vào vùng staging | Chọn file để commit |
| `git restore --staged <file>` | Bỏ khỏi staging, giữ nội dung | Add nhầm — **an toàn** |
| `git commit -m "..."` | Ghi lại thay đổi | Theo quy ước mục 7 |
| `git push` | Đẩy commit lên GitHub | Sau khi commit |
| `git push -u origin <nhánh>` | Đẩy nhánh mới lần đầu | Lần đầu đẩy nhánh |
| `git log --oneline` | Lịch sử commit gọn | Xem tiến độ |
| `git log --oneline -- <file>` | Lịch sử của một file | Truy vết thay đổi |
| `git blame <file>` | Ai sửa dòng nào | Tìm người giải thích |
| `git show <mã>` | Xem chi tiết một commit | Hiểu thay đổi cũ |
| `git merge master` | Hợp nhất `master` vào nhánh hiện tại | Cập nhật nhánh của bạn |
| `git merge --abort` | Hủy merge đang dở | Xung đột quá rối |
| `git stash` / `git stash pop` | Cất tạm / lấy lại thay đổi chưa commit | Cần chuyển nhánh gấp |
| `git reflog` | Lịch sử mọi thao tác trên máy | **Cứu code bị mất** |
| `git reset --hard <mã>` | Tua nhánh về commit cũ, xóa sửa đổi | 🔴 Chỉ khi chắc chắn |

---

## Tóm tắt phần cần nhớ nhất

Nếu chỉ đọc được một đoạn, hãy đọc đoạn này:

1. **Luôn `git pull` trước khi làm.**
2. **Luôn làm trên nhánh riêng**, không commit thẳng `master`.
3. **`git add` từng file**, không `git add .` khi chưa xem `git status`.
4. **Chạy lại toàn chuỗi 01 → 02 → SEED 01 → SEED 02** trước khi báo xong việc.
5. **Không commit** `.mdf`, `.ldf`, `.bak`, mật khẩu, dữ liệu người thật.
6. **Không dùng `git push --force`** trên `master`.

Bản rút gọn một trang: [Working_TLDR.md](Working_TLDR.md).
