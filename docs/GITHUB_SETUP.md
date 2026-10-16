# Bật bảo vệ nhánh trên GitHub

## Phần trong mã nguồn và phần trong Settings

Workflow CI, mẫu PR/issue và tài liệu nằm trong Git. File JSON trong `.github/rulesets/` là cấu hình chuẩn bị sẵn; việc commit file này **không tự bật** bảo vệ nhánh. Chủ repository cần import nó trong Settings hoặc dùng GitHub CLI có quyền quản trị repository.

Plugin GitHub được dùng để tạo nhánh/commit/PR trong lần thiết lập này không có công cụ ghi Branch Protection/Rulesets. Vì vậy không coi hai nhánh là đã được bảo vệ cho đến khi hoàn tất bước dưới đây và kiểm tra trên GitHub.

## Import bằng giao diện

1. Mở [Settings → Rules → Rulesets](https://github.com/ducnguyen122003/do_an_tot_nghiep/settings/rules).
2. Chọn **New ruleset → Import a ruleset**.
3. Tải file [main-develop.json](../.github/rulesets/main-develop.json) về máy và chọn file JSON đó. Nếu PR thiết lập chưa merge, tải file từ nhánh `develop`.
4. Kiểm tra target là `main` và `develop`, Enforcement là **Active** rồi lưu.
5. Xem một pull request có CI đã chạy để xác nhận tên ba required checks khớp: `Branch policy`, `Backend build`, `Frontend build`.

Ruleset này bắt buộc đi qua PR, yêu cầu CI thành công và nhánh được cập nhật với base, yêu cầu giải quyết các review thread, đồng thời chặn force push và xóa `main`/`develop`. Không có bypass actor, nên quản trị viên cũng tuân theo rule.

Mặc định có **0 approval bắt buộc** để không khóa người đang làm một mình; vẫn phải mở PR và qua CI. Khi có ít nhất hai người có quyền review, đổi **Required approvals** thành **1**. GitHub không tính việc tác giả tự duyệt PR của mình.

## Cách khác: GitHub CLI trong PowerShell

Chỉ cần làm một trong hai cách. Nếu đã import qua giao diện, không chạy lệnh POST dưới đây vì sẽ tạo thêm ruleset trùng.

Sau khi cài GitHub CLI và đăng nhập bằng tài khoản có quyền quản trị repo, đứng tại thư mục gốc của bản checkout chứa file JSON:

```powershell
gh auth login
Get-Content .github/rulesets/main-develop.json -Raw | gh api --method POST repos/ducnguyen122003/do_an_tot_nghiep/rulesets --input -
gh api repos/ducnguyen122003/do_an_tot_nghiep/rulesets
```

Lệnh không nhận hay ghi token vào repository. Nếu tổ chức áp thêm quyền hạn hoặc GitHub trả lỗi quyền truy cập, kiểm tra quyền của tài khoản/app trước khi thử lại.

## Cấu hình merge và lần phát hành đầu

Trong [Settings → General](https://github.com/ducnguyen122003/do_an_tot_nghiep/settings):

- Giữ **Allow squash merging** cho PR công việc vào `develop`.
- Giữ **Allow merge commits** cho `develop`/`release/*`/`hotfix/*` vào `main`, và `main` về `develop`.
- Không bật xóa nhánh tự động nếu chưa có cơ chế giữ `develop`: GitHub có thể xóa nhánh nguồn sau PR `develop` → `main`. Chỉ xóa thủ công nhánh công việc đã hoàn tất.
- Giữ default branch là `main`; thành viên chọn base `develop` khi mở PR công việc. CI sẽ báo lỗi nếu chọn nhầm hướng.

Lần thiết lập đầu tạo `develop` từ commit hiện tại của `main` và thêm cấu hình vào `develop`. Pull request `develop` → `main` đưa bộ cấu hình này vào nhánh mặc định. Kiểm tra CI rồi dùng **Create a merge commit**; mẫu issue/PR trên nhánh mặc định sẽ có hiệu lực sau khi merge. Tiếp đó có thể mở PR `main` → `develop` để đồng bộ lịch sử.

Tài liệu chính thức: [Rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets), [quản lý ruleset](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets-for-a-repository), [REST API tạo ruleset](https://docs.github.com/en/rest/repos/rules#create-a-repository-ruleset).
