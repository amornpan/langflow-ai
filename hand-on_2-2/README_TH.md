# คู่มือการใช้งาน Langflow Vector Store RAG

## บทนำ

คู่มือนี้อธิบายการใช้งาน Vector Store RAG (Retrieval Augmented Generation) ใน Langflow ซึ่งเป็นเทคนิคที่ช่วยปรับปรุงความสามารถของโมเดลภาษาขนาดใหญ่ (LLM) โดยการค้นคืนข้อมูลที่เกี่ยวข้องจากฐานข้อมูลเวกเตอร์มาใช้เป็นบริบทเพิ่มเติม ทำให้ LLM สามารถตอบคำถามโดยอ้างอิงข้อมูลเฉพาะได้แม่นยำยิ่งขึ้น

## แผนภาพภาพรวมของ Vector Store RAG

```mermaid
flowchart TD
    A[เอกสารหรือข้อมูล] --> B[Document Loader]
    B --> C[Text Splitter]
    C --> D[Embeddings]
    D --> E[Vector Store]
    
    F[คำถามของผู้ใช้] --> G[Embeddings]
    G --> H[Vector Store Retrieval]
    
    E -.-> H
    
    H --> I[เอกสารที่เกี่ยวข้อง]
    I --> J[PromptTemplate]
    F --> J
    J --> K[LLM]
    K --> L[คำตอบที่ถูกเพิ่มเติมด้วยข้อมูล]
    
    subgraph "การสร้างฐานข้อมูลเวกเตอร์"
    A
    B
    C
    D
    E
    end
    
    subgraph "การค้นคืนข้อมูล"
    F
    G
    H
    I
    end
    
    subgraph "การสร้างคำตอบ"
    J
    K
    L
    end
```

แผนภาพข้างต้นแสดงการทำงานของระบบ Vector Store RAG ซึ่งประกอบด้วย 3 ส่วนหลัก:
1. **การสร้างฐานข้อมูลเวกเตอร์**: เอกสารถูกโหลด แบ่งเป็นชิ้นส่วน และแปลงเป็นเวกเตอร์เพื่อจัดเก็บในฐานข้อมูลเวกเตอร์
2. **การค้นคืนข้อมูล**: คำถามของผู้ใช้ถูกแปลงเป็นเวกเตอร์เพื่อค้นหาเอกสารที่เกี่ยวข้อง
3. **การสร้างคำตอบ**: เอกสารที่ค้นคืนมาและคำถามถูกนำไปสร้างคำตอบโดย LLM

## RAG คืออะไร?

```mermaid
sequenceDiagram
    participant User as ผู้ใช้
    participant Retriever as ระบบค้นคืน
    participant VectorDB as ฐานข้อมูลเวกเตอร์
    participant LLM as โมเดลภาษา
    
    User->>Retriever: ส่งคำถาม
    Retriever->>VectorDB: ค้นหาข้อมูลที่เกี่ยวข้อง
    VectorDB-->>Retriever: ส่งข้อมูลที่ค้นพบ
    Retriever->>LLM: ส่งคำถาม + ข้อมูลที่ค้นพบ
    LLM->>User: สร้างคำตอบโดยใช้ทั้งความรู้ของโมเดล<br/>และข้อมูลที่ค้นพบ
```

Retrieval Augmented Generation (RAG) เป็นเทคนิคที่รวมกระบวนการค้นคืนข้อมูล (Retrieval) เข้ากับการสร้างเนื้อหา (Generation) โดย:

1. **ค้นคืนข้อมูลที่เกี่ยวข้อง**: เมื่อผู้ใช้ตั้งคำถาม ระบบจะค้นหาข้อมูลที่เกี่ยวข้องจากฐานข้อมูลเวกเตอร์
2. **เพิ่มบริบท**: ข้อมูลที่ค้นคืนมาจะถูกใช้เป็นบริบทเพิ่มเติมสำหรับ LLM
3. **สร้างคำตอบ**: LLM จะสร้างคำตอบโดยใช้ทั้งความรู้ที่มีอยู่และข้อมูลที่ค้นคืนมา

ข้อดีของ RAG:
- ช่วยให้ LLM ตอบคำถามโดยอ้างอิงข้อมูลที่ทันสมัยและเฉพาะเจาะจง
- ลดปัญหา "hallucination" หรือการสร้างข้อมูลที่ไม่ถูกต้อง
- อนุญาตให้ LLM เข้าถึงข้อมูลนอกเหนือจากชุดข้อมูลฝึกอบรมเดิม

## การเปรียบเทียบ LLM ทั่วไปกับ RAG

```mermaid
graph TD
    subgraph "LLM ทั่วไป"
        A1[คำถาม] --> B1[LLM]
        B1 --> C1[คำตอบจากความรู้ที่มีอยู่<br/>อาจมีข้อมูลไม่ทันสมัย<br/>หรือไม่ถูกต้อง]
    end
    
    subgraph "RAG-Enhanced LLM"
        A2[คำถาม] --> B2[RAG Pipeline]
        B2 --> C2[Vector Store]
        C2 --> D2[ค้นคืนข้อมูลที่เกี่ยวข้อง]
        D2 --> E2[LLM + ข้อมูลที่ค้นคืน]
        E2 --> F2[คำตอบอ้างอิงข้อมูลที่ทันสมัย<br/>และเฉพาะเจาะจง]
    end
    
    style C1 fill:#ffcccc
    style F2 fill:#ccffcc
```

## สิ่งที่ต้องมีก่อนเริ่มต้น

ก่อนเริ่มต้นใช้งาน Vector Store RAG ใน Langflow ตรวจสอบให้แน่ใจว่าคุณมี:

1. อินสแตนซ์ของ Langflow ที่รันอยู่
2. OpenAI API key (เริ่มต้นด้วย `sk-...`)
3. บัญชี DataStax Astra DB (สำหรับใช้เป็นฐานข้อมูลเวกเตอร์) หรือใช้ฐานข้อมูลเวกเตอร์อื่น เช่น FAISS (ไม่ต้องการการเชื่อมต่อกับบริการภายนอก)

## การสร้าง Vector Store RAG Flow

### ขั้นตอนที่ 1: เปิด Langflow และเริ่มโปรเจกต์ใหม่

```mermaid
flowchart LR
    A[เปิด Langflow] --> B[คลิก 'New Flow']
    B --> C[เลือก 'Vector Store RAG']
    C --> D[Flow เริ่มต้นถูกสร้างขึ้น]
```

1. เข้าสู่ระบบที่แดชบอร์ด Langflow
2. คลิกปุ่ม **New Flow**
3. เลือก **Vector Store RAG** จากเทมเพลต

### ขั้นตอนที่ 2: ทำความเข้าใจองค์ประกอบหลัก

```mermaid
classDiagram
    class DocumentLoader {
        +source: str
        +load_documents()
    }
    
    class TextSplitter {
        +chunk_size: int
        +chunk_overlap: int
        +split_documents()
    }
    
    class Embeddings {
        +model_name: str
        +embed_documents()
        +embed_query()
    }
    
    class VectorStore {
        +collection_name: str
        +embedding_dimension: int
        +add_documents()
        +similarity_search()
    }
    
    class ConversationalRetrievalChain {
        +llm: BaseLLM
        +retriever: BaseRetriever
        +combine_docs_chain: BaseCombineDocumentsChain
        +_call()
    }
    
    class Prompt {
        +template: str
        +input_variables: List[str]
        +format()
    }
    
    class ChatOpenAI {
        +model_name: str
        +temperature: float
        +api_key: str
        +_generate()
    }
    
    DocumentLoader --> TextSplitter
    TextSplitter --> VectorStore
    Embeddings --> VectorStore
    VectorStore --> ConversationalRetrievalChain
    Prompt --> ConversationalRetrievalChain
    ChatOpenAI --> ConversationalRetrievalChain
```

Vector Store RAG flow ประกอบด้วยองค์ประกอบหลักต่อไปนี้:

1. **OpenAI** - เชื่อมต่อกับ API ของ OpenAI เพื่อใช้โมเดลภาษา
2. **Embeddings** - สร้างเวกเตอร์ (vector embeddings) จากข้อความ
3. **AstraDB/FAISS/อื่นๆ** - ฐานข้อมูลเวกเตอร์สำหรับเก็บและค้นคืนข้อมูล
4. **Document Loader** - โหลดเอกสารเพื่อนำเข้าฐานข้อมูล
5. **Text Splitter** - แบ่งเอกสารเป็นชิ้นส่วนที่เหมาะสมสำหรับการวิเคราะห์
6. **Prompt** - กำหนดโครงสร้างของคำถามและคำตอบ
7. **ConversationalRetrievalChain** - เชื่อมโยงการค้นคืนและการสนทนาเข้าด้วยกัน

### ขั้นตอนที่ 3: การกำหนดค่าองค์ประกอบ

```mermaid
flowchart TB
    A[เริ่มการกำหนดค่า] --> B[กำหนดค่า OpenAI API Key]
    B --> C{เลือกฐานข้อมูลเวกเตอร์}
    C --> |AstraDB| D[กำหนดค่า AstraDB]
    C --> |FAISS| E[กำหนดค่า FAISS]
    C --> |อื่นๆ| F[กำหนดค่าตามประเภท Vector Store]
    
    D --> G[เตรียมเอกสาร]
    E --> G
    F --> G
    
    G --> H[กำหนดค่า Text Splitter]
    H --> I[กำหนดค่า Prompt]
    I --> J[เชื่อมต่อองค์ประกอบ]
    J --> K[ทดสอบ Flow]
```

#### กำหนดค่า OpenAI
1. คลิกที่องค์ประกอบ **OpenAI**
2. ในฟิลด์ **OpenAI API Key** คลิกปุ่ม **Globe**
3. คลิก **Add New Variable**
4. ป้อน `openai_api_key` ในฟิลด์ Variable Name
5. วาง OpenAI API Key ของคุณในฟิลด์ Value
6. คลิก **Save Variable**

#### กำหนดค่า Vector Store (ตัวอย่างใช้ FAISS)
1. คลิกที่องค์ประกอบ **FAISS**
2. กำหนดค่าพารามิเตอร์ที่จำเป็น:
   - **Index Name** - ชื่อของดัชนี FAISS (เช่น "langflow_index")
   - **Persist Directory** - ไดเรกทอรีสำหรับบันทึกดัชนี FAISS (เช่น "./faiss_index")

#### กำหนดค่า Document Loader
1. คลิกที่องค์ประกอบ **Document Loader**
2. เลือกประเภทของเอกสารที่ต้องการโหลด (เช่น Webpage, PDF, CSV)
3. ป้อน URL หรืออัปโหลดไฟล์ตามที่ต้องการ

#### กำหนดค่า Text Splitter
1. คลิกที่องค์ประกอบ **Text Splitter**
2. กำหนดค่า **Chunk Size** (ขนาดของชิ้นส่วนข้อความที่แบ่ง เช่น 500)
3. กำหนดค่า **Chunk Overlap** (จำนวนตัวอักษรที่ซ้อนกันระหว่างชิ้นส่วน เช่น 50)

#### กำหนดค่า Prompt
1. คลิกที่องค์ประกอบ **Prompt**
2. แก้ไขเทมเพลตตามที่ต้องการ เช่น:
```
Given the context:
{context}

Answer the question: {question}

Use only the context provided. If you don't know the answer based on the context, say "I don't know".
```

### ขั้นตอนที่ 4: เชื่อมต่อองค์ประกอบ

```mermaid
graph TD
    A[Document Loader] -->|documents| B[Text Splitter]
    B -->|documents| C[Vector Store]
    D[Embeddings] -->|embedding| C
    C -->|retriever| E[ConversationalRetrievalChain]
    F[OpenAI] -->|llm| E
    G[Prompt] -->|combine_docs_chain| E
    H[Chat Message] -->|inputs| E
    E -->|outputs| H
    
    style A fill:#f9d5e5
    style B fill:#d5e5f9
    style C fill:#d5f9e5
    style D fill:#f9e5d5
    style E fill:#e5d5f9
    style F fill:#e5f9d5
    style G fill:#f9d5e5
    style H fill:#d5e5f9
```

เชื่อมต่อองค์ประกอบต่างๆ เข้าด้วยกัน:

1. เชื่อมต่อ **Document Loader** ไปยัง **Text Splitter**
2. เชื่อมต่อ **Text Splitter** ไปยัง **Vector Store** (ที่พอร์ต `documents`)
3. เชื่อมต่อ **Embeddings** ไปยัง **Vector Store** (ที่พอร์ต `embedding`)
4. เชื่อมต่อ **Vector Store** ไปยัง **ConversationalRetrievalChain** (ที่พอร์ต `retriever`)
5. เชื่อมต่อ **OpenAI** ไปยัง **ConversationalRetrievalChain** (ที่พอร์ต `llm`)
6. เชื่อมต่อ **Prompt** ไปยัง **ConversationalRetrievalChain** (ที่พอร์ต `combine_docs_chain`)

## ตัวอย่างโครงสร้าง Vector Store RAG Flow ใน Langflow

```mermaid
flowchart TD
    subgraph "Data Sources"
        DS1[Web Pages]
        DS2[PDF Files]
        DS3[CSV Files]
        DS4[Text Files]
    end
    
    subgraph "Document Loading"
        DL1[Web Loader]
        DL2[PDF Loader]
        DL3[CSV Loader]
        DL4[Text Loader]
    end
    
    subgraph "Processing"
        P1[Text Splitter]
        P2[Embeddings]
    end
    
    subgraph "Storage"
        S1[Vector Store]
    end
    
    subgraph "Retrieval & Generation"
        RG1[Conversational Retrieval Chain]
        RG2[OpenAI LLM]
        RG3[Prompt Template]
    end
    
    subgraph "User Interface"
        UI1[Chat Interface]
    end
    
    DS1 --> DL1
    DS2 --> DL2
    DS3 --> DL3
    DS4 --> DL4
    
    DL1 --> P1
    DL2 --> P1
    DL3 --> P1
    DL4 --> P1
    
    P1 --> S1
    P2 --> S1
    
    S1 --> RG1
    RG2 --> RG1
    RG3 --> RG1
    
    RG1 --> UI1
    UI1 --> RG1
```

## กระบวนการทำงานของ Vector Store RAG ในรายละเอียด

```mermaid
sequenceDiagram
    participant DL as Document Loader
    participant TS as Text Splitter
    participant EM as Embeddings Model
    participant VS as Vector Store
    participant User as ผู้ใช้
    participant P as Prompt Template
    participant LLM as Language Model
    
    DL->>TS: ส่งเอกสารเพื่อแบ่งเป็นชิ้นส่วน
    TS->>EM: ส่งชิ้นส่วนเพื่อสร้าง embeddings
    EM->>VS: เก็บชิ้นส่วนและ embeddings
    
    User->>EM: ส่งคำถาม
    EM->>VS: แปลงคำถามเป็น embedding
    VS->>P: ค้นคืนชิ้นส่วนที่เกี่ยวข้อง
    P->>LLM: สร้าง prompt จากคำถามและชิ้นส่วน
    LLM->>User: สร้างคำตอบที่มีบริบทจากชิ้นส่วน
```

## การใช้ Vector Store อื่นๆ

นอกจาก FAISS แล้ว Langflow ยังรองรับ Vector Store อื่นๆ ดังนี้:

```mermaid
mindmap
    root((Vector Stores))
        FAISS
            ::icon(fa fa-database)
            ใช้งานในเครื่อง
            ไม่ต้องการบริการภายนอก
            เหมาะกับการทดลอง
        Astra DB
            ::icon(fa fa-cloud)
            บริการฐานข้อมูลบนคลาวด์
            จัดการโดย DataStax
            มีแพลนฟรี
        Pinecone
            ::icon(fa fa-cloud)
            จัดการเต็มรูปแบบ
            ปรับขนาดได้
            เสียค่าใช้จ่าย
        Milvus
            ::icon(fa fa-cogs)
            โอเพนซอร์ส
            ขยายขนาดได้
            มีความยืดหยุ่นสูง
        อื่นๆ
            ::icon(fa fa-ellipsis-h)
            Chroma
            Qdrant
            Weaviate
            ElasticSearch
            MongoDB Atlas
            Opensearch
            PGVector
            Supabase
            Redis
            Couchbase
            Clickhouse
```

### การเลือก Vector Store ที่เหมาะสม

```mermaid
graph TD
    A[เริ่มการเลือก Vector Store] --> B{มีงบประมาณหรือไม่?}
    B -->|ไม่มี| C{ต้องการใช้ในเครื่องหรือไม่?}
    B -->|มี| D{ต้องการการจัดการเองหรือไม่?}
    
    C -->|ใช่| E[FAISS: ใช้งานในเครื่อง<br/>ไม่ต้องการอินเทอร์เน็ต]
    C -->|ไม่| F[Astra DB: มีแพลนฟรี<br/>ต้องการอินเทอร์เน็ต]
    
    D -->|ไม่| G[Pinecone: จัดการเต็มรูปแบบ<br/>ง่ายต่อการใช้งาน]
    D -->|ใช่| H[Milvus: มีความยืดหยุ่นสูง<br/>ต้องการการจัดการเอง]
    
    E --> I[เหมาะสำหรับ: การทดลอง<br/>โปรเจกต์ส่วนตัว]
    F --> J[เหมาะสำหรับ: โปรเจกต์เริ่มต้น<br/>ข้อมูลขนาดเล็กถึงกลาง]
    G --> K[เหมาะสำหรับ: โปรเจกต์ธุรกิจ<br/>ต้องการความเสถียรสูง]
    H --> L[เหมาะสำหรับ: องค์กรขนาดใหญ่<br/>ต้องการปรับแต่งสูง]
```

## เคล็ดลับและเทคนิคเพิ่มเติม

### การปรับปรุงคุณภาพของผลลัพธ์

```mermaid
graph LR
    A[ประสิทธิภาพการค้นคืน] --> B[ขนาด Chunk]
    A --> C[Embedding Model]
    A --> D[จำนวนผลลัพธ์]
    
    E[คุณภาพคำตอบ] --> F[Prompt Template]
    E --> G[LLM Model]
    E --> H[Temperature]
    
    B --> B1[ปรับ Chunk Size: 200-1000]
    B --> B2[ปรับ Chunk Overlap: 10-20%]
    
    C --> C1[เลือกโมเดลคุณภาพสูง]
    C --> C2[ใช้โมเดลที่เหมาะกับภาษา]
    
    D --> D1[เพิ่มจำนวนสำหรับคำถามซับซ้อน]
    D --> D2[ลดจำนวนเพื่อความเร็ว]
    
    F --> F1[ระบุวิธีใช้บริบทให้ชัดเจน]
    F --> F2[แนะนำรูปแบบการตอบที่ต้องการ]
    
    G --> G1[เลือกโมเดลที่เหมาะกับงาน]
    
    H --> H1[ค่าต่ำสำหรับคำตอบที่แม่นยำ]
    H --> H2[ค่าสูงสำหรับความสร้างสรรค์]
```

1. **การปรับแต่ง Text Splitter**:
   - ปรับ Chunk Size ให้เหมาะกับข้อมูลของคุณ
   - เพิ่ม Chunk Overlap เพื่อรักษาบริบทระหว่างชิ้นส่วน

2. **การใช้ Embeddings ที่เหมาะสม**:
   - โมเดล Embeddings ที่ดีกว่าจะให้ผลการค้นคืนที่แม่นยำกว่า
   - ทดลองใช้โมเดลต่างๆ เช่น OpenAI's text-embedding-ada-002 หรือ BERT

3. **การปรับแต่ง Prompt**:
   - ให้คำแนะนำที่ชัดเจนว่า AI ควรตอบอย่างไร
   - ระบุว่า AI ควรใช้เฉพาะข้อมูลที่ให้มาและหลีกเลี่ยงการสร้างข้อมูลที่ไม่มีในบริบท

4. **การปรับแต่งพารามิเตอร์การค้นคืน**:
   - เพิ่มจำนวนผลลัพธ์ที่ค้นคืน (Number of Results) สำหรับคำถามที่ซับซ้อน
   - ปรับ Score Threshold เพื่อควบคุมความเกี่ยวข้องของผลลัพธ์

### การแก้ไขปัญหาทั่วไป

```mermaid
flowchart TD
    A[ปัญหาที่พบบ่อย] --> B{ไม่พบผลลัพธ์ที่เกี่ยวข้อง}
    A --> C{คำตอบไม่ถูกต้อง}
    A --> D{ประสิทธิภาพต่ำ}
    A --> E{ไม่สามารถเชื่อมต่อ API}
    
    B --> B1[ตรวจสอบข้อมูลในฐานข้อมูล]
    B --> B2[ปรับ Chunk Size และ Overlap]
    B --> B3[เพิ่มจำนวนผลลัพธ์ที่ค้นคืน]
    
    C --> C1[ปรับปรุง Prompt]
    C --> C2[ตรวจสอบคุณภาพข้อมูล]
    C --> C3[ลด Temperature ของ LLM]
    
    D --> D1[ใช้ Vector Store ที่เหมาะสม]
    D --> D2[ลดขนาดของ Embeddings]
    D --> D3[ใช้การแคชข้อมูล]
    
    E --> E1[ตรวจสอบ API Key]
    E --> E2[ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต]
    E --> E3[ตรวจสอบข้อจำกัดการใช้งาน API]
```

1. **ข้อมูลขนาดใหญ่**:
   - แบ่งเอกสารขนาดใหญ่เป็นส่วนย่อยๆ ก่อนนำเข้า
   - พิจารณาใช้ฐานข้อมูลเวกเตอร์ที่ขยายขนาดได้สำหรับข้อมูลขนาดใหญ่

2. **ความถูกต้องของคำตอบ**:
   - ตรวจสอบว่า Prompt รวมคำแนะนำให้ AI อ้างอิงเฉพาะข้อมูลที่มีอยู่
   - เพิ่มคำแนะนำให้ AI ระบุเมื่อไม่มีข้อมูลเพียงพอในบริบท

3. **ประสิทธิภาพ**:
   - ใช้ฐานข้อมูลเวกเตอร์ที่เหมาะสมกับขนาดข้อมูลของคุณ
   - พิจารณาลดมิติของ embeddings สำหรับชุดข้อมูลขนาดใหญ่มาก

## สรุป

Vector Store RAG ใน Langflow เป็นเครื่องมือที่ทรงพลังในการสร้าง AI แชทบอทที่อ้างอิงข้อมูลเฉพาะได้อย่างแม่นยำ โดยการรวม LLM เข้ากับฐานข้อมูลเวกเตอร์ คุณสามารถสร้างแอปพลิเคชันที่:

- ตอบคำถามโดยอ้างอิงข้อมูลที่คุณกำหนด
- ลดการสร้างข้อมูลที่ไม่ถูกต้อง (hallucination)
- อัปเดตความรู้ได้โดยไม่ต้องฝึกอบรมโมเดลใหม่
- ให้คำตอบที่มีความเฉพาะเจาะจงสูงและเชื่อถือได้

```mermaid
graph TB
    A[Langflow Vector Store RAG] --> B[ข้อดี]
    A --> C[การใช้งาน]
    A --> D[ความสามารถ]
    
    B --> B1[ตอบคำถามแม่นยำตามข้อมูล]
    B --> B2[ลดปัญหา hallucination]
    B --> B3[ปรับปรุงข้อมูลได้ง่าย]
    B --> B4[ใช้ได้กับข้อมูลเฉพาะทาง]
    
    C --> C1[แชทบอทความรู้องค์กร]
    C --> C2[ผู้ช่วยส่วนตัว]
    C --> C3[ระบบสนับสนุนลูกค้า]
    C --> C4[ระบบค้นคืนเอกสาร]
    
    D --> D1[ค้นหาข้อมูลที่เกี่ยวข้อง]
    D --> D2[เข้าใจบริบทเฉพาะ]
    D --> D3[ผสานความรู้กับข้อมูลใหม่]
    D --> D4[สร้างคำตอบที่สอดคล้อง]
    
    style A fill:#f9d5e5,stroke:#333,stroke-width:2px
    style B fill:#d5e5f9,stroke:#333,stroke-width:1px
    style C fill:#d5f9e5,stroke:#333,stroke-width:1px
    style D fill:#f9e5d5,stroke:#333,stroke-width:1px
```

ด้วยการปรับแต่งองค์ประกอบที่เหมาะสม คุณสามารถปรับแต่ง RAG system ให้ตอบสนองความต้องการเฉพาะของคุณได้ ไม่ว่าจะเป็นการสร้างผู้ช่วยส่วนตัว, ระบบ knowledge base, หรือแชทบอทสำหรับเอกสารเฉพาะทาง

## แหล่งข้อมูลเพิ่มเติม

- [Langflow Documentation](https://docs.langflow.org)
- [Vector Store Components](https://docs.langflow.org/components-vector-stores)
- [Starter Projects: Vector Store RAG](https://docs.langflow.org/starter-projects-vector-store-rag)
- [DataStax Astra DB Documentation](https://docs.datastax.com/en/astra-db/docs/)