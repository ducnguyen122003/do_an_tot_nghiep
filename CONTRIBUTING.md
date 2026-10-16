# Quy trình Git của nhóm

## Các nhánh

| Nhánh | Tạo từ | Pull request đến | Mục đích |
| --- | --- | --- | --- |
| `main` | Có sẵn | — | Bản ổn định để demo/bàn giao |
| `develop` | `main` khi khởi tạo | `main` | Tích hợp toàn bộ FE/BE |
| `feature/<issue>-<ten>` | `develop` | `develop` | Tính năng mới |
| `fix/<issue>-<ten>` | `develop` | `develop` | Sửa lỗi trong quá trình phát triển |
| `chore/<ten>`, `ci/<ten>` | `develop` | `develop` | Cấu hình, công cụ, CI |
| `docs/<ten>`, `test/<ten>`, `refactor/<ten>` | `develop` | `develop` | Tài liệu, kiểm thử, cải tổ mã nguồn |
| `release/<phien-ban>` | `develop` | `main` | Tùy chọn: ổn định bản phát hành khi nhóm cần |
| `hotfix/<ten>` | `main` | `main` | Sửa lỗi khẩn cấp của bản ổn định |

Tên nhánh viết thường, không dấu, dùng chữ/số và dấu `-` trong phần tên; ví dụ `feature/12-login-ui`, `feature/13-login-api`, `fix/18-stock-validation`.

FE và BE chia nhánh theo công việc. Một thay đổi gồm cả giao diện và API có thể ở chung một nhánh; các việc độc lập dùng nhánh riêng.

## Bắt đầu một công việc

Các lệnh dưới đây chạy được trong PowerShell và Git Bash. Ví dụ cho công việc số 12:

```powershell
git clone https://github.com/ducnguyen122003/do_an_tot_nghiep.git
cd do_an_tot_nghiep
git fetch origin
git switch develop
git pull --ff-only origin develop
git switch -c feature/12-login-ui
```

Nếu đã có project trên máy, bắt đầu từ `git fetch origin`. Chỉ chuyển nhánh sau khi đã commit hoặc cất các thay đổi đang làm dở.

Sau khi sửa code, thêm đúng những file thuộc công việc rồi commit:

```powershell
git status
git add frontend/src/pages/login
git commit -m "feat(frontend): add login page"
git push -u origin feature/12-login-ui
```

Đường dẫn trong `git add` là ví dụ; thay bằng file/thư mục bạn đã sửa. Trên GitHub, mở pull request với **base: `develop`**, **compare: `feature/12-login-ui`** và điền mẫu có sẵn.

## Đồng bộ khi người khác đã merge code

Khi đang ở nhánh công việc và working tree sạch:

```powershell
git fetch origin
git merge origin/develop
git push
```

Nếu có conflict, sửa các đoạn Git đánh dấu, kiểm tra lại, `git add` từng file đã giải quyết rồi `git commit` và `git push`. Dùng `git merge --abort` nếu cần hủy lần merge đang xử lý. Nhánh cá nhân được đẩy bình thường, không cần force push.

## Kiểm tra trước khi mở pull request

Frontend:

```powershell
cd frontend
npm ci
npm run build
npm run lint
```

Backend, trong terminal khác ở thư mục gốc:

```powershell
cd backend
.\mvnw.cmd --batch-mode --no-transfer-progress -DskipTests package
```

Trên Linux/macOS thay `.\mvnw.cmd` bằng `sh mvnw`.

CI có ba check ổn định: **Branch policy**, **Backend build**, **Frontend build**. CI chạy trên mọi pull request vào `main`/`develop` và mỗi push lên hai nhánh này, kể cả thay đổi tài liệu, để required checks không bị treo vì bộ lọc đường dẫn.

- `Backend build`: biên dịch, biên dịch mã kiểm thử và đóng gói JAR với `-DskipTests`. Bài `BackendApplicationTests.contextLoads` hiện khởi tạo ứng dụng cùng MySQL/MinIO, nên chưa chạy trong CI này. Chỉ gọi đây là kiểm tra build; cần môi trường kiểm thử độc lập trước khi bật `verify` đầy đủ.
- `Frontend build`: `npm ci` và `npm run build`. Chưa có script `test` trong package hiện tại. Lint chạy cục bộ và chưa được đặt thành required check.
- `Branch policy`: kiểm tra hướng pull request và tên nhánh. Push trực tiếp chỉ được ngăn sau khi chủ repo bật Ruleset trong [hướng dẫn thiết lập](docs/GITHUB_SETUP.md).

Người review kiểm tra chức năng, API và phạm vi dữ liệu liên quan; bổ sung ảnh giao diện và cách thử khi thay đổi FE. Build thành công chưa chứng minh chức năng hoạt động đúng.

## Merge và phát hành

1. Công việc → `develop`: sau khi kiểm tra và review, dùng **Squash and merge**. Tiêu đề PR trở thành commit tổng hợp.
2. `develop` → `main`: mở PR khi nhóm đã thử bản tích hợp; dùng **Create a merge commit** để giữ lịch sử giữa hai nhánh dài hạn. Không squash/rebase PR này.
3. Nếu cần nhánh `release/1-0-0`, tạo từ `develop`, đưa các sửa lỗi ổn định vào đó rồi merge commit vào `main`.
4. Sau một lần phát hành hoặc hotfix, mở PR **`main` → `develop`**, dùng **Create a merge commit** để đồng bộ các sửa lỗi và lịch sử. CI cho phép hướng này.
5. Giữ `main` và `develop`. Chỉ xóa nhánh công việc/release/hotfix đã merge khi không còn dùng.

GitHub không tự triển khai ứng dụng khi merge trong cấu hình này. Muốn đánh dấu phiên bản, sau khi PR phát hành đã merge, tạo tag trên `main`:

```powershell
git fetch origin
git switch main
git pull --ff-only origin main
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

Sau khi một nhánh tính năng được squash merge, chuyển về `develop` và tạo nhánh mới cho công việc tiếp theo; không tiếp tục dùng nhánh đã squash.

## Sửa lỗi khẩn cấp

```powershell
git fetch origin
git switch main
git pull --ff-only origin main
git switch -c hotfix/fix-login-error
```

Commit/push thay đổi, mở PR vào `main`, kiểm tra và merge commit. Sau đó mở PR `main` → `develop` như phần phát hành. Nhờ đó lần phát hành sau không làm mất bản sửa lỗi.

## Quy ước commit

`<type>(<scope>): <mô tả ngắn>`; scope có thể bỏ qua.

| Type | Dùng cho |
| --- | --- |
| `feat` | Tính năng |
| `fix` | Sửa lỗi |
| `refactor` | Cải tổ code |
| `test` | Kiểm thử |
| `docs` | Tài liệu |
| `chore`, `ci` | Cấu hình và công cụ |

Ví dụ: `feat(backend): add stock validation`, `fix(frontend): show login error`, `docs: update setup guide`.

## Cấu hình riêng trên từng máy

Giữ mật khẩu, token và khóa ký trong biến môi trường hoặc cấu hình local; chỉ commit file ví dụ với giá trị giả. `.gitignore` không tự gỡ những file đã được theo dõi trước đó. Với thông tin nhạy cảm đã xuất hiện trong lịch sử Git, xóa ở commit mới chưa đủ: phải thu hồi/thay khóa trước, rồi mới cân nhắc làm sạch lịch sử theo kế hoạch của nhóm.
