# Quick Start Guide

## เริ่มต้นใช้งานด่วน

### 1. Build และ Start
```cmd
setup.bat build
setup.bat start
```

### 2. เข้าใช้งาน
- เปิดเบราว์เซอร์: http://localhost:7860
- Username: admin  
- Password: Admin123!

### 3. ตรวจสอบสถานะ
```cmd
setup.bat status
```

### 4. ดู Logs
```cmd
setup.bat logs
```

### 5. หยุดการทำงาน
```cmd
setup.bat stop
```

## คำสั่งที่สำคัญ

| คำสั่ง | คำอธิบาย |
|--------|----------|
| `setup.bat build` | Build Docker image |
| `setup.bat start` | เริ่ม services |
| `setup.bat stop` | หยุด services |
| `setup.bat restart` | Restart services |
| `setup.bat logs` | ดู logs |
| `setup.bat status` | ตรวจสอบสถานะ |
| `setup.bat cleanup` | ลบทุกอย่าง (ระวัง!) |

## การตั้งค่าสำคัญ

ไฟล์ `.env` - แก้ไขก่อนใช้งาน:
- `POSTGRES_PASSWORD=SecureLangflow2024!`
- `LANGFLOW_SUPERUSER_PASSWORD=Admin123!`
- `LANGFLOW_SECRET_KEY=super-secret-langflow-key...`

## ปัญหาที่พบบ่อย

1. **Docker ไม่ทำงาน**: ตรวจสอบว่า Docker Desktop เปิดอยู่
2. **Port ขัดแย้ง**: เปลี่ยน port ในไฟล์ `.env`
3. **Memory ไม่พอ**: เพิ่ม RAM ให้ Docker Desktop
4. **Build ล้มเหลว**: ลองรัน `docker system prune -f`

สำหรับข้อมูลเพิ่มเติม ดูที่ `README.md`
