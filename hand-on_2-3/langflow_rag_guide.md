# คู่มือการใช้งาน RAG บน Langflow

## การตั้งค่าระบบสำหรับข้อมูลอาหารไทย

คู่มือนี้จะแนะนำวิธีการตั้งค่าระบบ Retrieval Augmented Generation (RAG) โดยใช้ Langflow และข้อมูลเกี่ยวกับอาหารไทยที่อยู่ในโฟลเดอร์ `data/`

### ขั้นตอนที่ 1: การเตรียมข้อมูล

ข้อมูลสำหรับใช้ใน RAG ประกอบด้วย 2 ไฟล์หลัก:
- `thai_food_information.txt`: ข้อมูลเกี่ยวกับอาหารไทยยอดนิยม 10 ชนิด
- `thai_ingredients.txt`: ข้อมูลเกี่ยวกับวัตถุดิบและเครื่องปรุงอาหารไทย

### ขั้นตอนที่ 2: เริ่มต้นใช้งาน Langflow

1. เปิด Langflow ในเบราว์เซอร์
2. เลือก "Create New Flow" หรือสามารถใช้ตัวอย่าง Simple Agent Template
3. จะได้ Flow ที่มีส่วนประกอบพื้นฐานของ Simple Agent

### ขั้นตอนที่ 3: การตั้งค่าส่วนประกอบ Document Loader

1. ค้นหา Component "Text Loader" และลากมาวางบน Canvas
2. กำหนดค่า:
   - `file_path`: เลือกไฟล์ `thai_food_information.txt` และ `thai_ingredients.txt`
   
3. ค้นหา Component "Text Splitter" และลากมาวางบน Canvas
4. กำหนดค่า:
   - `chunk_size`: 1000
   - `chunk_overlap`: 200
5. เชื่อมต่อ Output ของ Text Loader เข้ากับ Input ของ Text Splitter

### ขั้นตอนที่ 4: การตั้งค่า Embeddings และ Vector Store

1. ค้นหา Component "OpenAI Embeddings" หรือ "HuggingFaceEmbeddings" และลากมาวางบน Canvas
2. กำหนด API Key (ถ้าจำเป็น)
3. ค้นหา Component "FAISS" หรือ "Chroma" และลากมาวางบน Canvas
4. เชื่อมต่อ:
   - Output ของ Text Splitter เข้ากับ Input "documents" ของ Vector Store
   - Output ของ Embeddings เข้ากับ Input "embeddings" ของ Vector Store

### ขั้นตอนที่ 5: การตั้งค่า Chain และ Agent

1. ค้นหา Component "Conversational Retrieval QA Chain" และลากมาวางบน Canvas
2. ค้นหา Component "Chat OpenAI" หรือ "Chat Anthropic" และลากมาวางบน Canvas
3. เชื่อมต่อ:
   - Output ของ Vector Store เข้ากับ Input "retriever" ของ Chain
   - Output ของ Chat Model เข้ากับ Input "llm" ของ Chain

4. ค้นหา Component "Initialize Agent" และลากมาวางบน Canvas
5. กำหนดค่า:
   - `agent_type`: "chat-conversational-react-description"
   - เชื่อมต่อ Output ของ Chat Model เข้ากับ Input "llm" ของ Agent
   - เพิ่ม Chain เป็นหนึ่งใน Tools ของ Agent

6. ค้นหา Component "AgentExecutor" และลากมาวางบน Canvas
7. เชื่อมต่อ Output ของ Initialize Agent เข้ากับ Input "agent" ของ AgentExecutor

### ขั้นตอนที่ 6: การตั้งค่า Custom Prompt

1. ค้นหา Component "Prompt Template" และลากมาวางบน Canvas
2. กำหนดค่า template จากไฟล์ `prompt.txt`
3. เชื่อมต่อ Prompt Template เข้ากับ Chain ที่ใช้

### ขั้นตอนที่ 7: การทดสอบระบบ

1. คลิกปุ่ม "Build" หรือ "Deploy" เพื่อสร้าง Flow
2. เมื่อ Flow พร้อมใช้งาน ให้ไปที่แท็บ "Chat"
3. ลองป้อนคำถามจากไฟล์ `questions.txt` เพื่อทดสอบระบบ

## คำแนะนำเพิ่มเติม

### การปรับแต่ง Prompt

Prompt เป็นส่วนสำคัญในการกำหนดรูปแบบและคุณภาพของคำตอบ คุณสามารถปรับแต่ง Prompt ได้ตามต้องการโดยแก้ไขไฟล์ `prompt.txt`

ตัวอย่าง Prompt ที่ดีควรประกอบด้วย:
- การกำหนดบทบาทที่ชัดเจน (เช่น "คุณเป็นผู้เชี่ยวชาญด้านอาหารไทย")
- คำแนะนำในการใช้ข้อมูลที่ได้รับ
- รูปแบบการตอบที่ต้องการ
- การจัดการกรณีที่ไม่มีข้อมูลเพียงพอ

### การติดตั้ง Tools เพิ่มเติม

คุณสามารถเพิ่ม Tools อื่นๆ เข้าไปใน Agent เพื่อเพิ่มความสามารถได้ เช่น:
- Calculator: สำหรับคำนวณปริมาณส่วนผสม
- Weather: สำหรับแนะนำอาหารตามสภาพอากาศ
- Web Search: สำหรับค้นหาข้อมูลเพิ่มเติมจากอินเทอร์เน็ต

### การเพิ่มข้อมูล

หากต้องการเพิ่มข้อมูลเกี่ยวกับอาหารไทยเพิ่มเติม คุณสามารถ:
1. เพิ่มข้อมูลลงในไฟล์ที่มีอยู่
2. สร้างไฟล์ใหม่และเพิ่มเข้าไปใน Document Loader
3. อัพเดท Vector Store เมื่อมีการเปลี่ยนแปลงข้อมูล

## การแก้ไขปัญหาเบื้องต้น

### ปัญหา: คำตอบไม่ตรงกับข้อมูลที่มี
- ตรวจสอบค่า `chunk_size` และ `chunk_overlap` ให้เหมาะสม
- ปรับแต่ง Prompt ให้ชัดเจนว่าต้องใช้ข้อมูลที่ให้มาเท่านั้น
- เพิ่มจำนวนเอกสารที่ดึงจาก Vector Store (k parameter)

### ปัญหา: การค้นหาไม่พบข้อมูลที่เกี่ยวข้อง
- ตรวจสอบการแบ่งชั้นเอกสาร (Text Splitter)
- ลองใช้ Embeddings Model ที่มีประสิทธิภาพสูงขึ้น
- ปรับค่า similarity threshold ในการค้นหา

### ปัญหา: Agent ไม่เลือกใช้ Tool ที่ถูกต้อง
- ปรับแต่งคำอธิบาย Tool ให้ชัดเจนยิ่งขึ้น
- กำหนด System Prompt ที่แนะนำการใช้ Tool อย่างเหมาะสม