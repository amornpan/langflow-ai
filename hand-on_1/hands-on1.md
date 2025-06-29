# คู่มือการติดตั้ง Langflow

## บทนำ
Langflow เป็นเครื่องมืออันทรงพลังที่สามารถติดตั้งได้ 2 วิธี:
- เป็นแพ็คเกจ Python (สำหรับทั้ง Windows และ macOS)
- เป็นแอปพลิเคชันเดสก์ท็อปแบบสแตนด์อโลน (มีให้เฉพาะสำหรับ macOS เท่านั้น)

คู่มือนี้จะแนะนำวิธีการติดตั้ง Langflow ทั้งบน Windows และ macOS โดยเน้นที่การติดตั้งแพ็คเกจ Python

## ข้อกำหนดเบื้องต้น
- มี Python เวอร์ชัน 3.10 ถึง 3.13 ติดตั้งอยู่ในระบบ
- ตัวจัดการแพ็คเกจ: uv (แนะนำ), pip, หรือ pipx
- แนะนำให้ใช้สภาพแวดล้อมเสมือน (virtual environment) เพื่อแยกการพึ่งพา Python ของคุณ

## ขั้นตอนการติดตั้ง

### 1. ติดตั้ง Python
ตรวจสอบว่าคุณมี Python เวอร์ชัน 3.10 ถึง 3.13 ติดตั้งอยู่ในระบบของคุณ
- ดาวน์โหลดได้จาก: https://www.python.org/downloads/

### 2. ติดตั้งตัวจัดการแพ็คเกจ uv

#### สำหรับ Windows:
1. ติดตั้ง Microsoft C++ Build Tools:
   - ไปที่: https://visualstudio.microsoft.com/visual-cpp-build-tools
   - ดาวน์โหลดและรันตัวติดตั้ง
   - เมื่อได้รับการแจ้งเตือน ให้เลือก "Desktop development with C++"

2. ติดตั้ง uv โดยใช้ PowerShell:
   ```powershell
   powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
   ```

#### สำหรับ macOS:
ใช้ curl เพื่อดาวน์โหลดและติดตั้ง:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

หรือถ้าคุณไม่มี curl ให้ใช้ wget:
```bash
wget -qO- https://astral.sh/uv/install.sh | sh
```

### 3. ตรวจสอบการติดตั้ง uv

#### Windows:
```powershell
uv --version
```
จากนั้นคุณจะเห็นเวอร์ชัน uv แสดงขึ้นมา เช่น `uv 0.1.8`

#### macOS:
```bash
uv --version
```
จากนั้นคุณจะเห็นเวอร์ชัน uv แสดงขึ้นมา เช่น `uv 0.1.8`

### 4. สร้างสภาพแวดล้อมเสมือน (Virtual Environment)

#### Windows:
ตรวจสอบตำแหน่งที่ตั้งของ Python:
```bash
where python
```

สร้างสภาพแวดล้อมเสมือน:
```bash
uv venv langflow_env --python 3.12
```

เปิดใช้งานสภาพแวดล้อม:
```bash
langflow_env\Scripts\activate
```

#### macOS:
ตรวจสอบตำแหน่งที่ตั้งของ Python:
```bash
which python
```

สร้างสภาพแวดล้อมเสมือน:
```bash
uv venv langflow_env --python 3.12
```

เปิดใช้งานสภาพแวดล้อม:
```bash
source langflow_env/bin/activate
```

เมื่อต้องการปิดการใช้งาน (ทั้ง Windows และ macOS):
```bash
deactivate
```

### 5. ติดตั้ง Langflow

#### Windows:
เมื่อเปิดใช้งานสภาพแวดล้อมเสมือนแล้ว (สังเกตจาก `(langflow_env)` ที่ขึ้นนำหน้า command prompt) ติดตั้ง Langflow:
```bash
uv pip install langflow
```

#### macOS:
เมื่อเปิดใช้งานสภาพแวดล้อมเสมือนแล้ว (สังเกตจาก `(langflow_env)` ที่ขึ้นนำหน้า terminal) ติดตั้ง Langflow:
```bash
uv pip install langflow
```

### 6. รัน Langflow

#### Windows:
```bash
uv run langflow run
```

#### macOS:
```bash
uv run langflow run
```

เมื่อ Langflow เริ่มต้นทำงาน เว็บเบราว์เซอร์จะเปิดขึ้นโดยอัตโนมัติที่:
```
http://127.0.0.1:7860
```

หากเว็บเบราว์เซอร์ไม่เปิดขึ้นโดยอัตโนมัติ คุณสามารถเปิดเว็บเบราว์เซอร์ด้วยตัวเองและไปที่ URL ข้างต้น

## ข้อมูลเพิ่มเติม

- Langflow Desktop มีให้เฉพาะสำหรับผู้ใช้ macOS เท่านั้น 
- เพื่อประสิทธิภาพที่ดีที่สุด ใช้เวอร์ชัน Python ที่แนะนำ (3.10 ถึง 3.13)
- หากคุณพบปัญหาใดๆ ตรวจสอบให้แน่ใจว่าสภาพแวดล้อมเสมือนของคุณเปิดใช้งานอยู่และมีการติดตั้งข้อกำหนดเบื้องต้นทั้งหมดอย่างถูกต้อง
