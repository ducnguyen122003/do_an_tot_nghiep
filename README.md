# Đồ án tốt nghiệp

Repository chung cho backend Spring Boot và frontend React. FE và BE cùng làm việc trên một hệ thống nhánh, mỗi công việc có nhánh riêng.

| Thư mục | Công nghệ hiện tại |
| --- | --- |
| `backend/` | Java 17, Spring Boot 3.5.5, Maven Wrapper, MySQL, MinIO |
| `frontend/` | React 19, Vite 7, npm; CI dùng Node.js 24 |
| `.github/` | CI, mẫu pull request/issue, cấu hình bảo vệ nhánh để import |

## Quy trình làm việc

`feature/*`, `fix/*`, `chore/*` → pull request vào `develop` → kiểm tra → pull request vào `main`.

- `main`: phiên bản ổn định, chuẩn bị demo hoặc bàn giao.
- `develop`: nơi tích hợp công việc của cả nhóm.
- Mỗi nhánh công việc tồn tại đến khi pull request được merge.

Đọc [hướng dẫn Git và lệnh thực hành](CONTRIBUTING.md) trước khi bắt đầu. Chủ repository thực hiện [cấu hình bảo vệ nhánh](docs/GITHUB_SETUP.md) để GitHub bắt buộc quy trình này.

## Chạy cục bộ

Frontend, từ thư mục gốc:

```powershell
cd frontend
npm ci
npm run dev
```

Backend, trong một cửa sổ PowerShell khác, từ thư mục gốc:

```powershell
cd backend
.\mvnw.cmd spring-boot:run
```

Trên Linux/macOS dùng `sh mvnw spring-boot:run`. Cần Java 17 và cấu hình MySQL/MinIO phù hợp trước khi khởi động backend. Maven Wrapper tải Maven khi chạy lần đầu.

CI kiểm tra quy tắc nhánh, đóng gói backend và build frontend. Backend hiện chạy `package -DskipTests`; đây chưa phải kiểm thử nghiệp vụ hoặc kiểm thử tích hợp. Chi tiết trong [CONTRIBUTING.md](CONTRIBUTING.md#kiểm-tra-trước-khi-mở-pull-request).
