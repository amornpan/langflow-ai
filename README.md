# คู่มือการใช้งาน Langflow

## สารบัญ
1. [การติดตั้ง Langflow](#การติดตั้ง-langflow)
2. [การเริ่มต้นใช้งาน Langflow](#การเริ่มต้นใช้งาน-langflow)
3. [การตั้งค่าสำหรับการอัพโหลดไฟล์ขนาดใหญ่](#การตั้งค่าสำหรับการอัพโหลดไฟล์ขนาดใหญ่)
4. [การใช้งาน Astra DB กับ Langflow](#การใช้งาน-astra-db-กับ-langflow)
5. [การแก้ไขปัญหาเบื้องต้น](#การแก้ไขปัญหาเบื้องต้น)
6. [การใช้งาน API](#การใช้งาน-api)

## การติดตั้ง Langflow

### สิ่งที่ต้องใช้
- Windows 11
- Python 3.9+ ขึ้นไป
- pip (ตัวจัดการแพ็คเกจของ Python)

### ขั้นตอนการติดตั้ง

1. เปิด Command Prompt หรือ PowerShell

2. ติดตั้ง Langflow ด้วยคำสั่ง pip:
   ```
   pip install langflow
   ```

3. หรือหากใช้ conda/Anaconda:
   ```
   conda create -n langflow python=3.10
   conda activate langflow
   pip install langflow
   ```

## การเริ่มต้นใช้งาน Langflow

1. เปิด Command Prompt หรือ PowerShell

2. รัน Langflow ด้วยคำสั่ง:
   ```
   langflow run --host 0.0.0.0 --port 7860
   ```

3. เปิดเว็บเบราว์เซอร์และไปที่ URL:
   ```
   http://localhost:7860
   ```

4. คุณจะเห็นหน้าเว็บไซต์ของ Langflow ซึ่งคุณสามารถสร้าง flow ใหม่ได้

## การตั้งค่าสำหรับการอัพโหลดไฟล์ขนาดใหญ่

### วิธีที่ 1: ใช้ไฟล์ .env

1. สร้างไฟล์ `.env` ในโฟลเดอร์ C:/Users/Asus/langflow:
   - เปิด Notepad หรือโปรแกรมแก้ไขข้อความอื่นๆ
   - เพิ่มการตั้งค่าต่อไปนี้:
     ```
     LANGFLOW_FILE_SIZE_LIMIT=100
     LANGFLOW_ALLOWED_FILE_TYPES=".txt,.pdf,.csv,.xlsx,.json,.md,.docx"
     ```
   - บันทึกไฟล์เป็น `.env` (หากใช้ Notepad ให้ใส่ชื่อไฟล์ในเครื่องหมายคำพูด: `".env"`)

2. เริ่มต้น Langflow:
   ```
   langflow run --host 0.0.0.0 --port 7860
   ```

### วิธีที่ 2: ตั้งค่า Environment Variables ชั่วคราว

1. ใน Command Prompt:
   ```
   set LANGFLOW_FILE_SIZE_LIMIT=100
   set LANGFLOW_ALLOWED_FILE_TYPES=".txt,.pdf,.csv,.xlsx,.json,.md,.docx"
   langflow run --host 0.0.0.0 --port 7860
   ```

2. ใน PowerShell:
   ```powershell
   $env:LANGFLOW_FILE_SIZE_LIMIT=100
   $env:LANGFLOW_ALLOWED_FILE_TYPES=".txt,.pdf,.csv,.xlsx,.json,.md,.docx"
   langflow run --host 0.0.0.0 --port 7860
   ```

### วิธีที่ 3: สร้างไฟล์ .bat สำหรับรัน Langflow

1. สร้างไฟล์ `run_langflow.bat` ใน C:/Users/Asus/langflow:
   ```bat
   @echo off
   set LANGFLOW_FILE_SIZE_LIMIT=100
   set LANGFLOW_ALLOWED_FILE_TYPES=".txt,.pdf,.csv,.xlsx,.json,.md,.docx"
   langflow run --host 0.0.0.0 --port 7860
   ```

2. รันไฟล์ `run_langflow.bat` ด้วยการดับเบิลคลิก

## การใช้งาน Astra DB กับ Langflow

### การตั้งค่า Astra DB

1. สร้างบัญชีและฐานข้อมูลใน [Astra DB](https://astra.datastax.com/)

2. สร้าง Vector Database ใหม่ใน Astra DB

3. สร้าง API Token และบันทึกไว้

### การเชื่อมต่อ Astra DB กับ Langflow

1. ใน Langflow UI ให้ค้นหาและเพิ่มโหนด "Astra DB" หรือ "AstraDB Vector Store"

2. กรอกข้อมูลการเชื่อมต่อ:
   - API Token
   - Database ID
   - Collection Name
   - Keyspace (ค่าเริ่มต้นคือ "default_keyspace")

3. การตั้งค่าสำคัญเพื่อหลีกเลี่ยงปัญหา Document Size Limitation:
   - ตั้งค่า Chunk Size ให้ต่ำกว่า 700 ตัวอักษร (แนะนำให้ใช้ 500)
   - ตั้งค่า Chunk Overlap ให้ต่ำกว่า 100 (แนะนำให้ใช้ 50)

## การแก้ไขปัญหาเบื้องต้น

### ปัญหา: Document size limitation violated

**ปัญหา**: เกิด error "Document size limitation violated: indexed String value (field 'page_content') length (9062 bytes) exceeds maximum allowed (8000 bytes)"

**วิธีแก้ไข**:
1. ลดขนาด Chunk Size ในการแบ่งเอกสาร เป็น 500 หรือน้อยกว่า
2. ลด Chunk Overlap เป็น 50 หรือน้อยกว่า
3. ใช้ separator ที่เหมาะสม เช่น "\n\n" หรือ "."

### ปัญหา: File type not allowed

**ปัญหา**: ไม่สามารถอัพโหลดไฟล์บางประเภทได้

**วิธีแก้ไข**:
1. ตรวจสอบว่าตั้งค่า `LANGFLOW_ALLOWED_FILE_TYPES` ให้รวมนามสกุลไฟล์ที่ต้องการ
2. แปลงไฟล์เป็นรูปแบบที่ได้รับการสนับสนุน
3. หากใช้ JavaScript ในเบราว์เซอร์เพื่ออัพโหลดไฟล์ ให้ตรวจสอบว่ากำหนด Content-Type อย่างถูกต้อง

## การใช้งาน API

Langflow มี REST API ที่ช่วยให้คุณสามารถทำงานกับ flow ได้โดยไม่ต้องใช้ UI

### การรัน Flow ผ่าน API

1. การเรียกใช้ flow ด้วย PowerShell:
   ```powershell
   Invoke-WebRequest -Method POST -Uri "http://localhost:7860/api/v1/run/{flow_id}?stream=false" -ContentType "application/json" -Body '{
     "input_value": "คำถามของคุณที่นี่",
     "output_type": "chat",
     "input_type": "chat"
   }'
   ```

2. การเรียกใช้ flow ด้วย curl (ใน PowerShell):
   ```powershell
   curl.exe -X POST "http://localhost:7860/api/v1/run/{flow_id}?stream=false" -H "Content-Type: application/json" -d "{\"input_value\":\"คำถามของคุณที่นี่\",\"output_type\":\"chat\",\"input_type\":\"chat\"}"
   ```

### การดู Flow ทั้งหมด

```powershell
Invoke-WebRequest -Method GET -Uri "http://localhost:7860/api/v1/flows"
```

---

## หมายเหตุ

- Flow ID คือ ID ที่ระบบสร้างขึ้นให้กับแต่ละ flow ใน Langflow (เช่น a1707e71-7ad9-400c-981c-c08d81d1df15)
- คุณสามารถดู Flow ID ได้จาก URL ของ flow หรือจากคำสั่ง API เพื่อดู flow ทั้งหมด
- สำหรับเอกสารเพิ่มเติม โปรดดูที่ [Langflow GitHub](https://github.com/langflow-ai/langflow)
