# ePortfolio — Nhật ký làm việc nhóm

**Đề tài 13 — Hệ thống quản lý nhà hàng / quán cà phê** · Học phần Hệ quản trị cơ sở dữ liệu · SQL Server 2025
**Kho mã nguồn:** https://github.com/ShindouAris/BT_CSDL

> Tài liệu này tóm tắt quá trình làm việc nhóm từ 26/10/2026 đến 13/11/2026, dựa trên trao đổi trong nhóm Zalo
> "HQTDL (CSDL)" và lịch sử commit/PR trên GitHub. Chỉ ghi các nội dung liên quan đến công việc.
> Cột "Minh chứng git" có thể đối chiếu bằng `git log`.

## 1. Thành viên và phân công

| Thành viên | MSSV | Vai trò / phần phụ trách |
|---|---|---|
| Trần Thanh Nam | 125001516 | Thiết kế CSDL (`01`, `02`, `03`), tích hợp và đồng bộ kho git, nhật ký sử dụng AI, ePortfolio |
| Mạc Minh Hải | 125001638 | Chỉnh sửa/kiểm thử `05_ThuTuc_Ham`, `07_PhanQuyen_SaoLuu`, chỉnh mô hình `.cdm`, phụ lục rubric |
| Trần Anh Thế | 125001555 | Điều phối nhóm, kiểm tra PR và cấu trúc repo, thiết kế slide, rà soát báo cáo |
| Tống Thái Sơn | 125001568 | Soạn báo cáo Word, bài thuyết trình PowerPoint |

Bảng phân công chi tiết theo từng file xem thêm trong [STATUS.md](STATUS.md) và
[BAO_CAO_TONG_KET.md](BAO_CAO_TONG_KET.md). Nhóm cũng dùng một bảng phân công online (Google Sheet) do Anh Thế chia sẻ.

## 2. Nhật ký theo tuần

### Tuần 1 (26/10 – 30/10): khởi động, mô hình dữ liệu, dữ liệu mẫu

| Ngày | Công việc | Người thực hiện | Minh chứng git |
|---|---|---|---|
| 26/10 | Lập nhóm Zalo; chia sẻ link repo GitHub; chia sẻ đề bài và rubric, giao Thái Sơn đọc đề | Anh Thế, Thanh Nam | `2354cc9` |
| 26/10 | Vẽ sơ đồ quan hệ bằng DrawSQL và gửi nhóm góp ý | Thanh Nam | `f4e3535` |
| 26/10 | Thảo luận ý nghĩa bảng `Ban` (ghi vào hóa đơn) và `LoaiMon` (phân loại, cây phân cấp qua `MaLoaiCha` tự tham chiếu); Thanh Nam giải thích cho Anh Thế | Thanh Nam, Anh Thế | `bc0fb28`, `3c2501f` |
| 26/10 | Nạp dữ liệu mẫu (1.500 hóa đơn, ~5.200 chi tiết), script kiểm tra vi phạm ràng buộc, tài liệu quy trình làm việc | Thanh Nam | `ae0841e`, `2d20b32`, `35f6ee3`, `b520547`, `5c1276b` |
| 26/10 | Chốt kế hoạch vẽ ERD bằng PowerDesigner (yêu cầu CLO1, CLO2); báo cáo tiến độ các hạng mục còn lại | Anh Thế, Minh Hải, Thanh Nam | `5c1276b` (`STATUS.md`) |
| 30/10 | Vẽ ERD trên PowerDesigner, xuất `ConceptualDataModel_1.cdm` (về sau thay bằng `MoHinh_CDM.cdm`), chỉnh lại tên và thuộc tính | Anh Thế | — |

### Tuần 2 (31/10 – 06/11): truy vấn, thủ tục, trigger, phân quyền, tối ưu

| Ngày | Công việc | Người thực hiện | Minh chứng git |
|---|---|---|---|
| 04/11 | Giao việc soạn Word và PowerPoint cho Thái Sơn | Anh Thế | — |
| 06/11 | Hoàn thành 5 file SQL `04`–`08` (20 truy vấn + 3 view; 5 thủ tục + 3 hàm; 3 trigger + 2 giao tác; 4 role + sao lưu/phục hồi + HA; tối ưu 3 truy vấn). Anh Thế đẩy lên nhánh riêng (fork) | Anh Thế | `9835b62` |

### Tuần 3 (07/11 – 12/11): tích hợp, sửa lỗi, hoàn thiện báo cáo và slide

| Ngày | Công việc | Người thực hiện | Minh chứng git |
|---|---|---|---|
| 07/11 | Anh Thế mở PR #1; Thanh Nam gộp và cập nhật `master` | Anh Thế, Thanh Nam | `e8c5262`, `5aa5f20` |
| 08/11 | Chạy thử và sửa lỗi: `07_PhanQuyen_SaoLuu` nhiều lỗi, `05_ThuTuc_Ham` đã sửa, `08_ToiUu` chưa test. Nhắc nhau quy định "tự giải thích mọi dòng mã nộp" khi vấn đáp | Minh Hải, Anh Thế | — |
| 10/11 | Thái Sơn gửi bản Word đầu tiên; Anh Thế xem và nhắc sửa trang bìa | Thái Sơn, Anh Thế | — |
| 11/11 | Anh Thế mở PR #2 "fix 8 file sql"; Thanh Nam kiểm tra, gộp và chuẩn hóa cấu trúc thư mục repo | Anh Thế, Thanh Nam | `362e124`, `a43f4f9`, `2b5ed30` |
| 12/11 | PR #6 "Fix all sql": thêm `03_DuLieu.sql` (gộp dữ liệu mẫu), viết lại `04`, sửa `05`, `07` (Anh Thế mở PR). Thanh Nam xóa thư mục thừa `phuong_an_khac` | Anh Thế, Thanh Nam | `670f6e5`, `2788756`, `5849113`, `d6f18f7` |
| 12/11 | Anh Thế mở PR #7 (báo cáo hoàn chỉnh, cẩm nang bảo vệ); Thanh Nam gộp thư mục lồng nhau, đưa `scripts/` vào `sql/` (nhóm `others_`) và cập nhật tài liệu | Anh Thế, Thanh Nam | `b8a5995`, `a6ee235`, `83f6d39`, `2d33bf5` |
| 12/11 | Hoàn thiện báo cáo Word và slide; Minh Hải gửi Phụ lục A/B (danh mục nộp, bảng tự kiểm rubric); chuẩn bị chốt | Thái Sơn, Anh Thế, Minh Hải | — |
| 13/11 | Anh Thế mở PR #8 "lan_cuoi_cung": thêm bộ 8 file SQL bản cuối ở gốc repo. Xuất lại mô hình dữ liệu còn đúng 10 bảng (`MoHinh_CDM.cdm`, `MoHinh_PDM.pdm`, `MoHinh_PDM_crebas.sql`) | Anh Thế, Minh Hải | `e3be1d6`, `ba993ca` |
| 13/11 | Gộp 8 file SQL bản cuối vào `sql/`; thay mô hình cũ trong `tai_lieu/`; cập nhật báo cáo và nhật ký AI cho khớp `08_ToiUu.sql` (2 chỉ mục); thêm ePortfolio | Thanh Nam | — |

## 3. Góp ý và cải tiến

| Vấn đề phát hiện | Cách nhóm xử lý |
|---|---|
| Sơ đồ ban đầu chưa rõ vai trò `LoaiMon` và `Ban` | Giải thích trong nhóm; bổ sung giải thích ở `Explains.md` |
| Mô hình 30/10 có thêm `ThucDon`, `PhieuNhap`, `ChiTietNhap` (chỉ có trong `.cdm` và bản `02_Bang` thay thế, không có trong CSDL thật) | Ngày 12/11 nhóm xóa bản `02_Bang` thay thế; ngày 13/11 xuất lại mô hình còn đúng 10 bảng, khớp `sql/02_Bang.sql`: `tai_lieu/MoHinh_CDM.cdm`, `MoHinh_PDM.pdm` (kèm `MoHinh_PDM_crebas.sql`) |
| `07_PhanQuyen_SaoLuu` và `05_ThuTuc_Ham` nhiều lỗi khi chạy | Sửa trong các PR #2, #6 |
| Thư mục bị upload lồng nhau (`BT_CSDL-master/...`) nhiều lần | Gộp lại vào cấu trúc gốc; thống nhất nên thao tác trực tiếp trên repo |
| Thư mục `scripts/` và `phuong_an_khac` thừa | Đưa file cần giữ vào `sql/` (tiền tố `others_`), xóa phần còn lại |
| Trùng lặp dữ liệu mẫu (`03a`, `03b` và `03_DuLieu`) | Giữ một file `03_DuLieu.sql` |
| Bản SQL cuối (PR #8) lược bớt comment và bỏ chỉ mục `IX_DinhLuong_MaNL` khỏi `08_ToiUu.sql` | Cập nhật báo cáo, báo cáo tổng kết và nhật ký AI cho khớp 2 chỉ mục; **việc còn lại:** chạy lại `08_ToiUu.sql` để đo lại số liệu TQ03 |

## 4. Sử dụng AI trong quá trình làm việc

Chi tiết xem [NhatKy_AI.md](NhatKy_AI.md). Ngoài nhật ký đó, nhóm còn dùng AI trong các việc sau (ghi bổ sung ở đây):

- Giải thích cột tự tham chiếu `MaLoaiCha` cho thành viên chưa hiểu (26/10).
- Hỗ trợ đồng bộ kho git: gộp thư mục lồng nhau, đưa `scripts/` vào `sql/`, đổi tên file, và cập nhật tài liệu tương ứng (11–12/11). Người yêu cầu và duyệt kết quả: Thanh Nam.
- Hỗ trợ so sánh hai bộ SQL (`sql/` và gốc repo), phát hiện khác biệt về comment và chỉ mục, rồi cập nhật tài liệu tương ứng (13/11). Người yêu cầu và duyệt kết quả: Thanh Nam.
- Tóm tắt trao đổi nhóm thành bản nháp ePortfolio này.

## 5. Minh chứng đóng góp

- Lịch sử commit: https://github.com/ShindouAris/BT_CSDL/commits/master
- Pull request: #1, #2, #6, #7, #8 (do Anh Thế mở, tài khoản `Toji-Fushiguro-0`) và các lần gộp.
- File và tài liệu liên quan: [STATUS.md](STATUS.md), [WORKING.md](WORKING.md), [NhatKy_AI.md](NhatKy_AI.md),
  [BAO_CAO_HOAN_CHINH_HQTCSDL_NHOM13.md](BAO_CAO_HOAN_CHINH_HQTCSDL_NHOM13.md).
- Ảnh chụp trao đổi nhóm: lưu riêng ngoài repo (có thông tin cá nhân); cung cấp khi giảng viên yêu cầu.

