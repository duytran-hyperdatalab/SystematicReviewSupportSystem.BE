# Hướng dẫn Deploy SRSS Backend

## Yêu cầu
- Server Ubuntu 22.04 với Docker + Docker Compose v2
- Hoặc DigitalOcean Droplet (Basic / 2 vCPU / 4 GB RAM)

---

## Bước 1 — Clone repo

```bash
git clone https://github.com/duytran-hyperdatalab/SystematicReviewSupportSystem.BE.git
cd SystematicReviewSupportSystem.BE
mkdir -p /opt/srss
cp docker-compose.prod.yml /opt/srss/
cd /opt/srss
```

---

## Bước 2 — Tạo file `.env`

```bash
nano /opt/srss/.env
```

Paste nội dung sau và điền giá trị thực:

```dotenv
# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=YOUR_STRONG_PASSWORD
POSTGRES_DB=SRSS.IAM

# Redis
REDIS_PASSWORD=

# JWT
JWT_ISSUER=http://YOUR_SERVER_IP:5000
JWT_AUDIENCE=http://YOUR_SERVER_IP:5000
JWT_SECRET_KEY=YOUR_SECRET_KEY_MIN_32_CHARS
JWT_ACCESS_EXPIRY=15
JWT_REFRESH_EXPIRY=30

# Supabase
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...   ← service_role JWT

# AI
GEMINI_API_KEY=AIza...
GEMINI_MODEL_ID=gemini-2.5-flash
OPENAI_API_KEY=sk-...
OPENALEX_API_KEY=your@email.com
OPENROUTER_API_KEY=sk-or-v1-...

# Google OAuth (tùy chọn)
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...

# Frontend URL (cho CORS)
VITE_API_URL=http://YOUR_SERVER_IP:5000/api
```

---

## Bước 3 — Cập nhật CORS trong docker-compose.prod.yml

Mở file và sửa 2 dòng CORS:

```bash
nano /opt/srss/docker-compose.prod.yml
```

Tìm và sửa:
```yaml
CorsSettings__AllowedOrigins__0: "https://YOUR_FRONTEND_URL.vercel.app"
CorsSettings__AllowedOrigins__1: "http://YOUR_SERVER_IP:5000"
```

---

## Bước 4 — Chạy

```bash
cd /opt/srss

# Lần đầu - pull images và start
docker compose -f docker-compose.prod.yml up -d

# Kiểm tra
docker compose -f docker-compose.prod.yml ps
```

---

## Bước 5 — Kiểm tra hoạt động

```bash
# Xem logs
docker compose -f docker-compose.prod.yml logs -f backend

# Test API
curl http://localhost:5000/swagger/v1/swagger.json | python3 -m json.tool | head -5
```

Swagger UI: `http://YOUR_SERVER_IP:5000/swagger`

---

## Lệnh thường dùng

```bash
# Restart backend
docker compose -f docker-compose.prod.yml restart backend

# Xem logs
docker compose -f docker-compose.prod.yml logs -f backend

# Dừng tất cả
docker compose -f docker-compose.prod.yml down

# Update image mới nhất
docker compose -f docker-compose.prod.yml pull backend
docker compose -f docker-compose.prod.yml up -d --no-deps --force-recreate backend
```

---

## Lưu ý

- File `.env` **KHÔNG commit** lên git
- Backend tự động chạy migration khi khởi động
- Grobid dùng Hugging Face Cloud (miễn phí) — không cần cài thêm
- Image BE được build tự động qua GitHub Actions khi push lên `main`
