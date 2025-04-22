ขอโทษสำหรับความเข้าใจที่คลาดเคลื่อนครับ ผมจะปรับให้ถูกต้อง ให้เห็นชัดเจนว่าต้องรัน 2 Flow แยกกัน:

# คู่มือการสร้าง Vector Store RAG ด้วย Langflow

## บทนำ
คู่มือนี้จะอธิบายวิธีการสร้าง Retrieval-Augmented Generation (RAG) โดยใช้ Vector Store ใน Langflow ซึ่งเป็นเครื่องมือสำหรับสร้าง LLM application แบบ visual และ low-code

## วัตถุประสงค์
- แนะนำวิธีการสร้าง AI Agent ที่สามารถอ้างอิงข้อมูลจากฐานข้อมูล Vector
- แสดงวิธีออกแบบระบบที่สามารถตอบข้อซักถามโดยอิงจากข้อมูลเฉพาะที่จัดเก็บไว้

## ส่วนประกอบหลัก
1. **Vector Database** - ฐานข้อมูลสำหรับเก็บ embedding ของเอกสาร (ใช้ AstraDB)
2. **LLM Component** - ใช้โมเดลภาษาขนาดใหญ่ในการสร้างคำตอบ
3. **Embedding Component** - แปลงข้อความเป็น vector embedding
4. **Retriever Component** - ดึงข้อมูลที่เกี่ยวข้องจากฐานข้อมูล vector

## การเตรียมการ
### 1. ตั้งค่าฐานข้อมูล Vector (AstraDB)
1. สมัครใช้งานที่ https://astra.datastax.com/
2. เลือก cloud-native storage
3. เลือก serverless(vector)
4. ตั้งค่า:
   - Database name: index_testdb
   - Provider: Amazon Web Service
   - Region: us-east-2
5. คลิก Create Database
6. รอจนกว่าสถานะจะเปลี่ยนเป็น active
7. ไปที่ Data Explorer:
   - คลิก create collection
   - Collection name: documents
   - Embedding generation method: Bring my own
   - Dimensions: 1536
   - Model: text-embedding-ada-002
   - Similarity: cosine
   - คลิก Create Collection
8. ไปที่เมนู Overview:
   - Application Tokens
   - Generate Token
   - Copy token ที่ได้เพื่อใช้ในภายหลัง

### 2. ตั้งค่า Langflow สำหรับไฟล์ขนาดใหญ่
เปิด PowerShell และรัน:
```powershell
$env:LANGFLOW_FILE_SIZE_LIMIT = "100"
uv run langflow run
```

## การสร้าง Vector Store RAG - ประกอบด้วย 2 Flow แยกกัน

### Flow ที่ 1: Load Data Flow (สำหรับอัปโหลดและเก็บข้อมูลในฐานข้อมูล)

#### ขั้นตอนที่ 1: สร้าง Flow แรกสำหรับโหลดข้อมูล
1. จากหน้า Dashboard ของ Langflow คลิกที่ปุ่ม **New Flow**
2. เลือก **Vector Store RAG**
3. คุณจะเห็นว่ามี 2 ส่วนหลักใน Template: Load Data Flow และ Retriever Flow

#### ขั้นตอนที่ 2: ตั้งค่า Load Data Flow
1. **เลือกไฟล์** ที่ต้องการอัปโหลด (เอกสารที่มีข้อมูลที่ต้องการให้ระบบค้นหา)
2. **ตั้งค่า Split Text**:
   - Chunk Overlap: 20
   - Chunk Size: 100
3. **ตั้งค่า OpenAI Embeddings**:
   - Model: text-embedding-ada-002
   - ใส่ OpenAI API Key
4. **ตั้งค่า AstraDB**:
   - เพิ่ม AstraDB Application Token:
     - คลิกที่ปุ่ม **Globe** ในฟิลด์ **astradb application token**
     - คลิก **Add New Variable**
     - ในฟิลด์ **Variable Name** ให้ป้อน `astra_app_api`
     - ในฟิลด์ **Value** ให้วาง AstraDB Application Token ที่คัดลอกไว้
     - คลิก **Save Variable**
   - เลือก Database และ Collection ที่สร้างไว้

#### ขั้นตอนที่ 3: รัน Flow ที่ 1 - Load Data
1. ตรวจสอบว่าทุกคอมโพเนนต์เชื่อมต่อถูกต้อง
2. คลิกที่ **Build** หรือ **Save** เพื่อบันทึก Flow
3. คลิก **Run** เพื่อโหลดข้อมูลเข้าสู่ Vector Database
4. รอจนกระบวนการเสร็จสิ้น (อาจใช้เวลาสักครู่ขึ้นอยู่กับขนาดของเอกสาร)

> **สำคัญ**: คุณต้องรัน Load Data Flow ให้เสร็จสมบูรณ์ก่อนที่จะดำเนินการในขั้นตอนถัดไป

### Flow ที่ 2: Retriever Flow (สำหรับค้นหาและตอบคำถามจากข้อมูลที่โหลดไว้แล้ว)

#### ขั้นตอนที่ 1: สร้าง Flow ใหม่สำหรับการค้นหาและตอบคำถาม
1. กลับไปที่หน้า Dashboard ของ Langflow
2. คลิกที่ปุ่ม **New Flow** อีกครั้ง
3. เลือก **Vector Store RAG** เช่นเดิม
4. คราวนี้เราจะโฟกัสที่ส่วน Retriever Flow

#### ขั้นตอนที่ 2: ตั้งค่า Retriever Flow
1. **ตั้งค่า OpenAI Embeddings**:
   - Model: text-embedding-ada-002
   - ใส่ OpenAI API Key
2. **ตั้งค่า AstraDB**:
   - คลิกที่ปุ่ม **Globe** ในฟิลด์ **astradb application token**
   - เลือก **astra_app_api** ที่เพิ่มไว้แล้ว
   - เลือก Database และ Collection เดียวกับที่ใช้ใน Flow ที่ 1
3. **ตั้งค่า Prompt Template**:
   - ใส่ template ในรูปแบบต่อไปนี้:
   ```
   {context}
   ---
   คำถาม: {question}
   ฉันจะตอบคำถามข้างต้นเกี่ยวกับแนวทางการให้บริการลูกค้าและระเบียบบริษัทโดยทำตามขั้นตอนนี้:
   ขั้นที่ 1: เข้าใจประเด็นหลักของคำถาม - คำถามนี้เกี่ยวกับอะไร
   ขั้นที่ 2: ค้นหาคำตอบที่ตรงประเด็น
   - ค้นหาในหัวข้อหลักที่เกี่ยวข้องก่อน:
     • หากเป็นเรื่องลูกค้าไม่พอใจ ให้ดูที่หัวข้อ "การจัดการกับสถานการณ์ยุ่งยาก"
     • หากเป็นเรื่องวิธีการคืนสินค้า ให้ดูที่หัวข้อ "การคืนสินค้าและเปลี่ยนสินค้า"
     • หากเป็นเรื่องเวลาทำการ ให้ดูที่หัวข้อ "เวลาทำการและการให้บริการ"
   - ระบุเลขหัวข้อและข้อย่อยที่พบข้อมูล (เช่น ข้อ 1.3.4)
   ขั้นที่ 3: ตอบให้ตรงและกระชับ
   - ตอบเฉพาะสิ่งที่ถูกถาม ไม่เพิ่มข้อมูลเกินจำเป็น
   - คัดลอกประโยคที่ตอบคำถามโดยตรงจากเอกสาร
   คำตอบ:
   ```
4. **ตั้งค่า OpenAI**:
   - ใส่ OpenAI API Key
   - เลือกโมเดลที่ต้องการใช้ (เช่น gpt-3.5-turbo)

#### ขั้นตอนที่ 3: ตรวจสอบการเชื่อมต่อคอมโพเนนต์
1. ตรวจสอบการเชื่อมต่อ:
   - ลากเส้น Parser Text ไปที่ Context ของ Prompt Component
   - ลากเส้น Prompt Message ไปที่ OpenAI Input

#### ขั้นตอนที่ 4: ทดสอบ Retriever Flow
1. คลิกที่ **Build** หรือ **Save** เพื่อบันทึก Flow
2. คลิกที่ **Playground** เพื่อเข้าสู่โหมดทดสอบ
3. ป้อนคำถามในช่องข้อความ
4. คลิก **Run** เพื่อดูผลลัพธ์

## ภาพรวมของการทำงานทั้งระบบ

1. **Flow ที่ 1 (Load Data Flow)**:
   - อัปโหลดเอกสาร
   - แบ่งเอกสารเป็นส่วนย่อย
   - สร้าง embeddings
   - จัดเก็บใน Vector Database
   
2. **Flow ที่ 2 (Retriever Flow)**:
   - รับคำถามจากผู้ใช้
   - แปลงคำถามเป็น embedding
   - ค้นหาข้อมูลที่เกี่ยวข้องจาก Vector Database
   - สร้าง prompt โดยรวมข้อมูลที่ค้นพบ
   - ส่งไปยัง LLM เพื่อสร้างคำตอบ
   - แสดงคำตอบแก่ผู้ใช้

## การแก้ไขปัญหา
- หากไม่เห็นการเชื่อมต่อสายบางส่วน ให้ตรวจสอบและลากสายเชื่อมต่อใหม่
- หากระบบไม่สามารถอัปโหลดไฟล์ขนาดใหญ่ได้ ตรวจสอบว่าได้ตั้งค่า LANGFLOW_FILE_SIZE_LIMIT แล้ว
- ตรวจสอบการเชื่อมต่อว่าคอมโพเนนต์เชื่อมถูกต้องทั้งหมด โดยเฉพาะส่วน Parser Text ไปที่ Context และ Prompt Message ไปที่ OpenAI Input
- หากค้นหาไม่พบข้อมูล ให้ตรวจสอบว่า Run Flow ที่ 1 เสร็จสมบูรณ์แล้ว และใช้ Database/Collection เดียวกันในทั้งสอง Flow

คู่มือนี้จะช่วยให้คุณสร้างระบบ Vector Store RAG ใน Langflow ได้อย่างมีประสิทธิภาพ โดยแบ่งเป็น 2 Flow แยกกัน เพื่อให้ AI Agent สามารถตอบคำถามโดยใช้ข้อมูลจากเอกสารที่คุณเตรียมไว้