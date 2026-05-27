# 🕷️ VietnamWorks Job Crawler

> Intern Assignment for Zigexn Ventura (2026) — developed by **Bui Huynh Long**

A Ruby on Rails application that automatically crawls job postings from the VietnamWorks API, saves them to a MySQL database, and displays them on a clean, responsive web interface. The system includes an automated background job scheduled to fetch new data daily.

---

## 🚀 Features

- **API Crawler** — Extracts data directly from the VietnamWorks internal API (faster and more reliable than HTML scraping)
- **Smart Data Handling** — Cleans and formats salary data (VNĐ/USD). Automatically detects and skips duplicate jobs using `job_url` as a unique index
- **Web Interface** — Clean UI with search by title, filter by location, and pagination
- **Automation** — Sidekiq + Redis background cron job runs daily at 00:00 to fetch the latest jobs without blocking the main web server

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Language | Ruby 3.3.1 |
| Framework | Ruby on Rails 8.1 |
| Database | MySQL 8.0 |
| Background Jobs | Sidekiq + Redis |
| Scheduling | Sidekiq-cron |
| Key Gems | HTTParty, Nokogiri, Kaminari, slim-rails |

---

## ⚙️ Prerequisites

Ensure the following are installed and running before setup:

- Ruby `3.3.1` (via `rbenv` or `rvm`)
- MySQL server
- Redis server (required for Sidekiq)

---

## 💻 Installation & Setup

### 1. Clone the repository

```bash
git clone https://github.com/huynhlong2706/Jobs-Crawler.git
cd Jobs-Crawler
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Configure the database

Edit `config/database.yml` with your local MySQL credentials:

```yaml
default: &default
  adapter: mysql2
  encoding: utf8mb4
  username: root
  password: your_mysql_password
  host: localhost
```

### 4. Create database and run migrations

```bash
rails db:create
rails db:migrate
```

### 5. Seed initial data (optional)

To populate the database immediately without waiting for the scheduled job:

```bash
rails c
> CrawlJobsJob.perform_now(2)  # Crawls the first 2 pages (~100 jobs)
```

---

## 🏃 Running the Application

You need **two terminal windows** to run the full application.

**Terminal 1 — Web server:**

```bash
rails s
```

Visit `http://localhost:3000` to view the job listings.

**Terminal 2 — Background worker:**

```bash
bundle exec sidekiq
```

> Make sure Redis is running before starting Sidekiq (`redis-server`).
> The crawler is scheduled to run automatically every day at **00:00**.

---

## 🗂️ Project Structure
app/
├── services/
│   └── vietnamworks_crawler.rb   # Crawl API data & Save to DB
├── jobs/
│   └── crawl_jobs_job.rb         # Sidekiq background job
├── controllers/
│   └── jobs_controller.rb
└── views/
└── jobs/
└── index.html.slim       # Main UI

---

## 🗄️ ERD
┌─────────────────────────────────────┐
│              jobs                   │
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

---

## 👤 Author

**Bui Huynh Long**
Computer Science Student — HCMUT (Bach Khoa University)
