# การติดตั้ง Langflow ด้วย Docker

## เตรียมความพร้อม

### 1. ติดตั้ง Docker Desktop
- ดาวน์โหลด Docker Desktop จาก [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
- ติดตั้งและรีสตาร์ทคอมพิวเตอร์หากจำเป็น
- เปิด Docker Desktop และรอให้เริ่มทำงาน

### 2. ตรวจสอบการติดตั้ง Docker
```bash
docker --version
docker info
```

## ขั้นตอนการติดตั้ง Langflow

### 1. รัน Langflow Container
```bash
docker run -p 7860:7860 --name langflow-docker langflowai/langflow:1.4.3
```

### 2. รอให้ Download และ Start
- Docker จะดาวน์โหลด image ครั้งแรก (ใช้เวลาสักครู่)
- รอจนเห็นข้อความว่า Langflow เริ่มทำงานแล้ว

### 3. เข้าใช้งาน Langflow
เปิดเว็บเบราว์เซอร์แล้วไปที่:
```
http://localhost:7860
```

## คำสั่งที่มีประโยชน์

### ดู Container ที่กำลังทำงาน
```bash
docker ps
```

### หยุด Container
```bash
docker stop langflow-docker
```

### เริ่ม Container อีกครั้ง
```bash
docker start langflow-docker
```

### ลบ Container
```bash
docker rm langflow-docker
```

### ดู Logs
```bash
docker logs langflow-docker
```

## การรันแบบ Interactive (ตัวเลือก)
หากต้องการรันแบบ interactive และลบ container เมื่อหยุด:
```bash
docker run -it --rm -p 7860:7860 --name langflow-docker langflowai/langflow:1.4.3
```

## การ Mount Volume สำหรับข้อมูล
หากต้องการเก็บข้อมูลไว้นอก container:
```bash
docker run -p 7860:7860 --name langflow-docker -v ./langflow_data:/app/data langflowai/langflow:1.4.3
```

## การแก้ไขปัญหา

### Docker Desktop ไม่ทำงาน
1. เปิด Docker Desktop จาก Start Menu
2. รอให้แสดง "Docker Desktop is running"
3. ตรวจสอบ icon ใน system tray (มุมขวาล่าง)

### Port 7860 ถูกใช้งานแล้ว
เปลี่ยนเป็น port อื่น:
```bash
docker run -p 8080:7860 --name langflow-docker langflowai/langflow:1.4.3
```
จากนั้นเข้าใช้งานที่ `http://localhost:8080`

### Container name ซ้ำ
ลบ container เก่าก่อน:
```bash
docker rm langflow-docker
```

## หมายเหตุ
- Container จะทำงานในพื้นหลังจนกว่าจะหยุดด้วยตนเอง
- ข้อมูลใน container จะหายไปเมื่อลบ container (หากไม่ใช้ volume)
- สามารถเข้าใช้งานได้จากเครื่องอื่นในเครือข่ายเดียวกันที่ `http://[IP-Address]:7860`