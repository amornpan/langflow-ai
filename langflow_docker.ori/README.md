# Langflow Docker Project with uv

โปรเจค Langflow ที่ใช้ uv สำหรับการติดตั้งและจัดการ dependencies อย่างเร็วและมีประสิทธิภาพ

## 🚀 คุณสมบัติ

- **uv Package Manager**: ใช้ uv แทน pip เพื่อการติดตั้งที่เร็วกว่า
- **Multi-stage Docker Build**: ลดขนาด image และเพิ่มความปลอดภัย  
- **PostgreSQL Database**: ฐานข้อมูลที่เสถียรสำหรับ production
- **Redis Cache**: เพิ่มประสิทธิภาพการทำงาน
- **Nginx Reverse Proxy**: Load balancing และ SSL termination
- **Health Checks**: ตรวจสอบสถานะ services อัตโนมัติ
- **Volume Persistence**: เก็บข้อมูลอย่างถาวร
- **Security Hardening**: การตั้งค่าความปลอดภัยที่ดี

## 📁 โครงสร้างโปรเจค

```
langflow_docker/
├── Dockerfile                 # Multi-stage build with uv
├── docker-compose.yml         # Services orchestration
├── pyproject.toml             # Python dependencies
├── .env                       # Environment variables
├── .dockerignore             # Docker ignore file
├── setup.sh                  # Linux/Mac setup script
├── setup.bat                 # Windows setup script
├── init-scripts/             # Database initialization
│   └── 01-init-langflow.sh
├── flows/                    # Langflow flows storage
│   └── README.json
├── nginx/                    # Nginx configuration
│   ├── nginx.conf
│   └── ssl/
│       └── README.md
└── README.md                 # This file
```

## 🛠️ การติดตั้งและใช้งาน

### ความต้องการ

- Docker Desktop หรือ Docker Engine
- Docker Compose
- Git (สำหรับ clone repository)

### วิธีการใช้งาน

#### สำหรับ Windows:
```cmd
# Build และ start services
setup.bat build
setup.bat start

# ดู logs
setup.bat logs

# ตรวจสอบสถานะ
setup.bat status

# หยุดการทำงาน
setup.bat stop
```

#### สำหรับ Linux/Mac:
```bash
# ให้สิทธิ์ execute
chmod +x setup.sh

# Build และ start services  
./setup.sh build
./setup.sh start

# ดู logs
./setup.sh logs

# ตรวจสอบสถานะ
./setup.sh status

# หยุดการทำงาน
./setup.sh stop
```

#### Manual Docker Compose:
```bash
# Build images
docker compose build

# Start services
docker compose up -d

# View logs
docker compose logs -f langflow

# Stop services
docker compose down
```

## 🔧 การกำหนดค่า

### การตั้งค่าหลัก (ในไฟล์ .env)

#### 🗄️ **Database Configuration**
- `POSTGRES_USER=langflow` - ชื่อผู้ใช้ database
- `POSTGRES_PASSWORD=SecureLangflow2024!` - รหัสผ่าน database  
- `POSTGRES_DB=langflow` - ชื่อ database
- `POSTGRES_PORT=5432` - พอร์ต database

#### 🔐 **Authentication & Security** 
- `LANGFLOW_SUPERUSER=admin` - ชื่อผู้ดูแล
- `LANGFLOW_SUPERUSER_PASSWORD=Admin123!` - รหัสผ่านผู้ดูแล
- `LANGFLOW_SECRET_KEY=...` - กุญแจลับสำหรับเข้ารหัส
- `LANGFLOW_ACCESS_TOKEN_EXPIRE_MINUTES=60` - อายุ token

#### 🌐 **Network Configuration**
- `LANGFLOW_PORT=7860` - พอร์ต Langflow
- `LANGFLOW_HOST=0.0.0.0` - Host binding
- `NGINX_PORT=80` - พอร์ต Nginx
- `NGINX_SSL_PORT=443` - พอร์ต SSL

#### 📝 **Logging Configuration**
- `LANGFLOW_LOG_LEVEL=INFO` - ระดับ log
- `LANGFLOW_LOG_FILE=/home/langflow/.langflow/logs/langflow.log` - ที่เก็บ log

#### ⚡ **Performance Configuration**
- `LANGFLOW_CACHE_TYPE=redis` - ประเภท cache
- `LANGFLOW_WORKERS=1` - จำนวน worker processes
- `REDIS_PORT=6379` - พอร์ต Redis

#### 🔑 **API Keys** (เติมเมื่อใช้งานจริง)
- `OPENAI_API_KEY=` - OpenAI API key
- `ANTHROPIC_API_KEY=` - Anthropic API key  
- `GOOGLE_API_KEY=` - Google API key
- `HUGGINGFACE_API_TOKEN=` - Hugging Face token

## 🌐 การเข้าถึง

หลังจาก start services แล้ว:

- **Langflow UI**: http://localhost:7860
- **Nginx Proxy**: http://localhost:80 (ถ้าเปิดใช้)
- **Database**: localhost:5432
- **Redis**: localhost:6379

### การล็อกอิน
- **Username**: admin (หรือตามที่กำหนดใน `LANGFLOW_SUPERUSER`)
- **Password**: Admin123! (หรือตามที่กำหนดใน `LANGFLOW_SUPERUSER_PASSWORD`)

## 📦 Dependencies ที่ติดตั้ง

### Core Dependencies
- `langflow>=1.1.0` - แอพพลิเคชันหลัก
- `uvicorn[standard]>=0.23.0` - ASGI server
- `fastapi>=0.104.0` - Web framework
- `sqlalchemy>=2.0.0` - ORM
- `psycopg2-binary>=2.9.7` - PostgreSQL adapter

### Optional Dependencies
- `pandas>=2.1.0` - Data manipulation
- `matplotlib>=3.7.0` - Plotting
- `openai>=1.0.0` - OpenAI integration
- `anthropic>=0.7.0` - Anthropic integration
- `transformers>=4.35.0` - Hugging Face models

## 🔄 การจัดการ Services

### Docker Compose Commands
```bash
# ดู service status
docker compose ps

# ดู logs ของ service เฉพาะ
docker compose logs postgres
docker compose logs redis  
docker compose logs langflow

# Restart service เฉพาะ
docker compose restart langflow

# Scale services
docker compose up -d --scale langflow=2

# Execute command ใน container
docker compose exec langflow bash
docker compose exec postgres psql -U langflow
```

### Health Checks
- **PostgreSQL**: `pg_isready -U langflow`
- **Redis**: `redis-cli ping`  
- **Langflow**: `curl -f http://localhost:7860/health`

## 🗂️ การจัดการข้อมูล

### Volumes
- `postgres_data` - ข้อมูล PostgreSQL
- `redis_data` - ข้อมูล Redis
- `langflow_data` - ข้อมูล Langflow
- `langflow_logs` - Log files
- `langflow_storage` - File storage

### Backup Database
```bash
# Backup
docker compose exec postgres pg_dump -U langflow langflow > backup.sql

# Restore  
docker compose exec -T postgres psql -U langflow langflow < backup.sql
```

## 🛠️ การปรับแต่ง

### เพิ่ม Python Dependencies
แก้ไขไฟล์ `pyproject.toml`:
```toml
dependencies = [
    "langflow>=1.1.0",
    "your-package-here>=1.0.0",
]
```

### เพิ่ม Environment Variables
แก้ไขไฟล์ `.env`:
```bash
CUSTOM_VAR=your_value
ANOTHER_VAR=another_value
```

### การตั้งค่า SSL (HTTPS)
1. วาง certificate files ใน `nginx/ssl/`
2. Uncomment SSL configuration ใน `nginx/nginx.conf`
3. เปิดใช้ nginx profile:
```bash
docker compose --profile nginx up -d
```

## 🚀 Production Deployment

### การตั้งค่า Production
1. **เปลี่ยน passwords และ secret keys** ทั้งหมดใน `.env`
2. **ใช้ external database** แทน container database
3. **ตั้งค่า SSL certificates**
4. **เปิดใช้ nginx reverse proxy**
5. **ตั้งค่า monitoring และ logging**

### Environment Variables สำหรับ Production
```bash
LANGFLOW_DEV=false
LANGFLOW_DEBUG=false
LANGFLOW_AUTO_LOGIN=false
LANGFLOW_LOG_LEVEL=WARNING
```

### Resource Limits
```yaml
deploy:
  resources:
    limits:
      memory: 2G
      cpus: '1.0'
    reservations:
      memory: 1G  
      cpus: '0.5'
```

## 🐛 การแก้ปัญหา

### ปัญหาที่พบบ่อย

#### 1. Services ไม่สามารถเชื่อมต่อกันได้
```bash
# ตรวจสอบ network
docker compose ps
docker network ls

# ตรวจสอบ logs  
docker compose logs postgres
docker compose logs redis
```

#### 2. Database connection error
```bash
# ตรวจสอบ PostgreSQL
docker compose exec postgres pg_isready -U langflow

# ตรวจสอบ credentials ใน .env
```

#### 3. Memory issues
```bash
# ตรวจสอบ resource usage
docker stats

# เพิ่ม memory limits ใน docker-compose.yml
```

#### 4. Permission errors
```bash
# ตรวจสอบ file permissions
ls -la

# Fix permissions
chmod +x setup.sh
```

### Debug Commands
```bash
# เข้า container
docker compose exec langflow bash

# ตรวจสอบ environment
docker compose exec langflow env

# ตรวจสอบ processes
docker compose exec langflow ps aux

# ตรวจสอบ disk space
docker system df
```

## 📚 Resources

- [Langflow Documentation](https://docs.langflow.org/)
- [uv Documentation](https://docs.astral.sh/uv/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes  
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License.
