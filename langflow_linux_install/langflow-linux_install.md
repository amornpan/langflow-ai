# วิธีการติดตั้ง Langflow บน Linux

Langflow เป็นเครื่องมือสร้าง UI แบบลากและวาง (drag-and-drop) สำหรับ LangChain ช่วยให้คุณสร้างและทดสอบโปรเจคที่ใช้ LLM ได้อย่างรวดเร็ว

## ความต้องการเบื้องต้น

- Python เวอร์ชัน 3.9 หรือสูงกว่า
- pip หรือ uv (แนะนำให้ใช้ uv เพราะเร็วกว่า)
- Virtual environment manager (เช่น venv)

## วิธีการติดตั้งโดยใช้ pip

### 1. สร้าง Virtual Environment

```bash
python -m venv langflow-env
source langflow-env/bin/activate
```

### 2. ติดตั้ง Langflow

```bash
pip install langflow
```

### 3. เริ่มต้นใช้งาน Langflow

```bash
langflow run
```

Server จะทำงานที่ http://localhost:7860

## วิธีการติดตั้งโดยใช้ uv (เร็วกว่า)

### 1. ติดตั้ง uv (ถ้ายังไม่ได้ติดตั้ง)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
```

### 2. สร้าง Virtual Environment และติดตั้ง Langflow

```bash
mkdir langflow-project
cd langflow-project
uv venv
source .venv/bin/activate
uv pip install langflow
```

### 3. เริ่มต้นใช้งาน Langflow

```bash
langflow run
```

Server จะทำงานที่ http://localhost:7860

## การติดตั้งด้วย Docker (ทางเลือก)

ถ้าคุณต้องการใช้ Docker แทน:

```bash
docker pull langflow/langflow
docker run -p 7860:7860 langflow/langflow
```

## การเข้าถึง UI

หลังจากเริ่มการทำงานแล้ว คุณสามารถเข้าถึง Langflow UI ได้ที่:
- http://localhost:7860

## คำสั่งเพิ่มเติมที่มีประโยชน์

- กำหนดพอร์ตที่ต้องการ:
  ```bash
  langflow run --port 8000
  ```

- กำหนดโฮสต์:
  ```bash
  langflow run --host 0.0.0.0
  ```

- ตั้งค่าโทเค็น API (ถ้าต้องการใช้ OpenAI API):
  ```bash
  export OPENAI_API_KEY=your-api-key
  langflow run
  ```

## การแก้ไขปัญหาเบื้องต้น

1. หากพบปัญหาขณะติดตั้ง ลองอัปเดต pip ก่อน:
   ```bash
   pip install --upgrade pip
   ```

2. ถ้ามีปัญหาเกี่ยวกับการติดตั้งไลบรารี:
   ```bash
   pip install --upgrade setuptools wheel
   ```

3. ถ้าเกิดข้อผิดพลาดเกี่ยวกับการเข้าถึงพอร์ต:
   - ลองเปลี่ยนพอร์ต: `langflow run --port 8000`
   - ตรวจสอบว่าไม่มีโปรแกรมอื่นใช้พอร์ตอยู่

4. ถ้า uv ทำงานไม่ถูกต้อง ให้ตรวจสอบว่าได้เพิ่มเข้าใน PATH แล้ว:
   ```bash
   source $HOME/.local/bin/env
   ```

## ลิงก์ที่เป็นประโยชน์

- [เอกสารอย่างเป็นทางการของ Langflow](https://docs.langflow.org)
- [GitHub Repository](https://github.com/langflow-ai/langflow)
- [LangChain Documentation](https://python.langchain.com/docs/get_started/introduction.html)
