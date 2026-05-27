# 🕷️ VietnamWorks Job Crawler

> Intern Assignment for Zigexn Ventura (2026) — Developed by **Bui Huynh Long**

Một ứng dụng hoàn chỉnh đạt chuẩn Production được xây dựng trên nền tảng **Ruby on Rails 8**, tự động cào dữ liệu tuyển dụng từ API nội bộ của VietnamWorks, lưu trữ vào cơ sở dữ liệu MySQL và cung cấp tính năng tìm kiếm toàn văn bản (Full-text search) tốc độ cao, thông minh qua Elasticsearch. Toàn bộ hệ thống được đóng gói đồng bộ bằng Docker Compose và tự động hóa tác vụ ngầm với Sidekiq Workers.

---

## 🚀 Tính Năng Cốt Lõi

- **Automated API Crawler** — Khai thác dữ liệu thô trực tiếp từ các endpoint API nội bộ của VietnamWorks (tốc độ vượt trội, độ ổn định cao và không bị ảnh hưởng bởi thay đổi giao diện HTML).
- **Smart Data Deduplication** — Tự động làm sạch, chuẩn hóa các định dạng lương đa tiền tệ (VNĐ/USD). Sử dụng thuộc tính `job_url` làm chỉ mục duy nhất (Unique Index) để loại bỏ tuyệt đối việc lưu trùng lặp dữ liệu.
- **Elasticsearch Full-Text Search** — Tích hợp sâu thông qua Gem `Searchkick`, cung cấp trải nghiệm tìm kiếm thông minh vượt xa câu lệnh `LIKE` của SQL thông thường:
  - **Fuzzy Search (Tìm kiếm gần đúng):** Tự động nhận diện và sửa lỗi chính tả từ người dùng (ví dụ: gõ thiếu từ `Develper` vẫn tìm ra chính xác các job `Developer`).
  - **Synonyms Handling (Từ đồng nghĩa):** Cấu hình ánh xạ thông minh, người dùng chỉ cần gõ từ viết tắt như `ror` hệ thống sẽ lập tức trả về các công việc `Ruby on Rails`.
- **Admin Dashboard** — Trang quản trị phân quyền bảo mật, cho phép Xem danh sách, Tìm kiếm chuyên sâu, Sửa đổi thông tin chi tiết và Xóa các tin tuyển dụng.
- **Full Dockerization** — Đóng gói đồng bộ toàn bộ hệ sinh thái (Rails Web, MySQL Database, Redis Broker, Sidekiq Worker, Elasticsearch Engine) chỉ bằng một câu lệnh điều phối duy nhất.
- **Automated Cron Jobs** — Thư viện Sidekiq-cron tự động kích hoạt tiến trình cào dữ liệu mới vào đúng **00:00 hàng ngày** ngầm dưới hệ thống mà không làm giảm hiệu năng của Web Server.

---

## 🛠️ Tech Stack & Công Nghệ

| Tầng Hệ Thống | Công Nghệ Sử Dụng |
|---|---|
| **Ngôn ngữ** | Ruby 3.3.1 |
| **Framework** | Ruby on Rails 8.1 (Cấu hình No-Node, tối ưu hóa biên dịch tài nguyên siêu nhẹ) |
| **Cơ sở dữ liệu** | MySQL 8.0 |
| **Bộ máy tìm kiếm** | Elasticsearch 7.17.10 (Cấu hình giới hạn tài nguyên tối ưu cho môi trường Dev) |
| **Bộ nhớ đệm & Broker** | Redis Alpine |
| **Xử lý tác vụ ngầm** | Sidekiq + Sidekiq-cron |
| **Đóng gói môi trường** | Docker + Docker Compose V2 |
| **Gems lõi quan trọng** | `searchkick`, `elasticsearch`, `httparty`, `kaminari`, `slim-rails` |

---

## ⚙️ Điều Kiện Tiên Quyết (Prerequisites)

Trước khi tiến hành cài đặt, hãy đảm bảo máy tính của bạn đã cài đặt sẵn các công cụ sau:
- **Docker Engine** (Phiên bản mới nhất)
- **Docker Compose V2** (Sử dụng cú pháp lệnh có dấu cách `docker compose`)

---

## 💻 Hướng Dẫn Cài Đặt & Khởi Chạy (Docker Setup)

### 1. Tải mã nguồn dự án về máy

```bash
git clone https://github.com/huynhlong2706/Jobs-Crawler.git
cd Jobs-Crawler
```

### 2. Cập nhật file khóa tài nguyên (Tùy chọn)

Đảm bảo môi trường máy chủ đồng bộ chính xác các dependencies:

```bash
bundle install
```

### 3. Kích hoạt toàn bộ hệ thống bằng Docker Compose

Chạy lệnh sau để Docker tự động tải, xây dựng và chạy ngầm tất cả các dịch vụ (Web, DB, Redis, Worker, Elasticsearch):

```bash
sudo docker compose up -d --build
```

(Lưu ý: Ở lần chạy đầu tiên, hãy đợi khoảng 1-2 phút để cụm Elasticsearch có đủ thời gian khởi tạo hoàn chỉnh).

### 4. Khởi tạo Cơ sở dữ liệu và Migrations trong Container

Ra lệnh trực tiếp vào trong Web Container đang chạy biệt lập để tạo cấu trúc bảng:

```bash
sudo docker compose exec web bin/rails db:create db:migrate
```

### 5. Kích hoạt cào dữ liệu ngay lập tức & Đồng bộ hóa Elasticsearch

Để có dữ liệu kiểm thử (Seeding) ngay lập tức mà không cần đợi đến 00:00:

```bash
# Lệnh 1: Ép Sidekiq Worker chạy hàm cào dữ liệu VietnamWorks ngay lập tức
sudo docker compose exec web bin/rails runner "CrawlJobsJob.perform_now"

# Lệnh 2: Đồng bộ và đánh chỉ mục toàn bộ dữ liệu vừa cào sang bộ máy Elasticsearch
sudo docker compose exec web bin/rails runner "Job.reindex"
```

---

## 🏃 Vận Hành & Giám Sát Hệ Thống

Toàn bộ hệ thống hiện đã chạy ngầm ổn định. Bạn có thể truy cập các phân vùng thông qua trình duyệt tại địa chỉ:

- **Giao diện người dùng (Trang chủ):** http://localhost:3000
- **Trang quản trị (Admin Panel):** http://localhost:3000/admin

Các câu lệnh giám sát hữu ích trong Terminal:

Theo dõi log lưu lượng Web theo thời gian thực (Puma Web Server):

```bash
sudo docker compose logs -f web
```

Theo dõi log tác vụ ngầm của Worker (Tiến trình cào dữ liệu Sidekiq):

```bash
sudo docker compose logs -f sidekiq
```

Kiểm tra trạng thái sống/chết của các Container trong hệ thống:

```bash
sudo docker compose ps
```

---

## 🔍 Kịch Bản Kiểm Thử Hệ Thống (Demo Scenarios)

Để chấm điểm tiêu chí Excellent, bạn hãy thực hiện 3 kịch bản tìm kiếm sau trên giao diện Web:

1. **Kiểm thử Fuzzy Search (Tìm gần đúng):** Gõ một từ khóa bị cố tình sai chính tả như `Logistcs` hoặc `Managr` vào ô tìm kiếm. Elasticsearch sẽ tự động sửa lỗi và trả về đúng các công việc Logistics hoặc Manager.

2. **Kiểm thử Từ đồng nghĩa (Synonyms):** Gõ chính xác cụm từ viết tắt `ror`. Nhờ cấu hình thông minh trong Model, hệ thống sẽ tự hiểu và lọc ra toàn bộ các công việc có tiêu đề chứa chữ Ruby on Rails.

3. **Kiểm thử Kết hợp (Multi-Filter):** Chọn một địa điểm cụ thể (ví dụ: `Ha Noi`) kết hợp nhập từ khóa để thấy bộ lọc đa tầng truy vấn dữ liệu tức thời.

---

## 🗂️ Cấu Trúc Dự Án (Architecture Tree)

```
app/
├── controllers/
│   ├── admin/
│   │   └── jobs_controller.rb   # Điều hướng CRUD và quản lý an toàn trang Admin
│   └── jobs_controller.rb       # Đón nhận và xử lý truy vấn tìm kiếm bằng Elasticsearch
├── jobs/
│   └── crawl_jobs_job.rb        # Định thời tác vụ ngầm Sidekiq-cron hàng ngày
├── models/
│   └── job.rb                   # Định nghĩa schema Searchkick & kiểm soát validations DB
├── services/
│   └── vietnamworks_crawler.rb  # Trái tim logic kết nối API, bóc tách cấu trúc dữ liệu
└── views/
    └── jobs/
        └── index.html.slim      # Giao diện hiển thị trang chủ tối ưu bằng Slim template
```

---

## 🗄️ Thiết Kế Cơ Sở Dữ Liệu (ERD)

```
┌─────────────────────────────────────┐
│                jobs                 │
├─────────────────────────────────────┤
│ id            INT (PK, AI)          │
│ title         VARCHAR(255) NOT NULL │
│ company_name  VARCHAR(255) NOT NULL │
│ salary        VARCHAR(255)          │
│ location      VARCHAR(255)          │
│ job_url       VARCHAR(255) UNIQUE   │
│ posted_at     DATETIME              │
│ description   TEXT                  │
│ source        VARCHAR(255)          │
│ created_at    DATETIME              │
│ updated_at    DATETIME              │
└─────────────────────────────────────┘
```

---

## 👤 Thông Tin Tác Giả

**Bùi Huỳnh Long**
Sinh viên chuyên ngành Khoa học Máy tính — Khoa Khoa học và Kỹ thuật Máy tính

Trường Đại học Bách Khoa - ĐHQG TPHCM (HCMUT)
