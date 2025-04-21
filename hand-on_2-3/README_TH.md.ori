# คู่มือการใช้งาน Langflow Simple Agent สำหรับข้อมูลอาหารไทย

## บทนำ

คู่มือนี้อธิบายการสร้างและใช้งาน Simple Agent ใน Langflow โดยประยุกต์ใช้กับข้อมูลอาหารไทย Simple Agent เป็นแอปพลิเคชัน AI ที่สามารถเลือกใช้เครื่องมือต่างๆ เพื่อตอบคำถามและแก้ปัญหาได้อย่างอัตโนมัติ โดยใช้โมเดลภาษาขนาดใหญ่ (LLM) เป็น "สมอง" ในการวิเคราะห์และตัดสินใจ โปรเจกต์นี้จะแสดงวิธีการสร้าง Simple Agent ที่สามารถตอบคำถามเกี่ยวกับอาหารไทย วัตถุดิบ วิธีทำ และประวัติความเป็นมาได้

## การทำงานของ Simple Agent

```mermaid
flowchart TD
    A[ผู้ใช้] -->|คำถาม| B[Tool Calling Agent]
    
    B -->|วิเคราะห์คำถาม| C{เลือก Tool}
    
    C -->|ค้นหาข้อมูล| D[Search Tool]
    C -->|คำนวณ| E[Calculator Tool]
    C -->|ตอบโดยตรง| F[Final Answer]
    
    D -->|ผลการค้นหา| G[Observation]
    E -->|ผลการคำนวณ| G
    
    G --> B
    B -->|สร้างคำตอบสุดท้าย| H[คำตอบ]
    H --> A
    
    D -->|Vector Search| I[Vector Store]
    I -->|ข้อมูลที่เกี่ยวข้อง| D
    
    subgraph กระบวนการคิดของ Agent
    B
    C
    G
    end
    
    subgraph Tools
    D
    E
    I
    end
```

แผนภาพข้างต้นแสดงการทำงานของ Simple Agent โดย:
1. ผู้ใช้ส่งคำถามเข้ามา
2. Agent วิเคราะห์คำถามและตัดสินใจเลือกใช้ Tool ที่เหมาะสม
3. Tool ทำงานและส่งผลลัพธ์กลับไปให้ Agent
4. Agent ประมวลผลข้อมูลและสร้างคำตอบสุดท้ายส่งกลับไปให้ผู้ใช้

## องค์ประกอบของ Simple Agent

```mermaid
classDiagram
    class ToolCallingAgent {
        +agent_llm: OpenAI
        +system_prompt: String
        +tools: List[Tool]
        +input_value: String
        +memory: Optional[Memory]
        +max_iterations: Integer
        +process_input()
        +select_tool()
        +generate_response()
    }
    
    class SearchTool {
        +vectorstore: VectorStore
        +search_query: String
        +number_of_results: Integer
        +search()
    }
    
    class CalculatorTool {
        +expression: String
        +evaluate_expression()
    }
    
    class VectorStore {
        +documents: List
        +embeddings: Embeddings
        +similarity_search()
    }
    
    class ChatMessage {
        +input: String
        +output: String
        +display()
    }
    
    ToolCallingAgent --> SearchTool : uses
    ToolCallingAgent --> CalculatorTool : uses
    SearchTool --> VectorStore : searches
    ToolCallingAgent --> ChatMessage : sends response to
```

## การทำงานของ RAG ร่วมกับ Simple Agent

```mermaid
sequenceDiagram
    participant User as ผู้ใช้
    participant Agent as Tool Calling Agent
    participant Search as Search Tool
    participant Vector as Vector Store
    participant Calc as Calculator Tool
    
    User->>Agent: ถามคำถามเกี่ยวกับอาหารไทย
    
    Agent->>Agent: วิเคราะห์คำถามและตัดสินใจเลือก Tool
    
    alt ต้องการข้อมูลเฉพาะ
        Agent->>Search: ใช้ Search Tool
        Search->>Vector: ค้นหาข้อมูลอาหารไทยที่เกี่ยวข้อง
        Vector-->>Search: ส่งข้อมูลที่เกี่ยวข้อง
        Search-->>Agent: ส่งผลการค้นหา
    else ต้องการคำนวณ
        Agent->>Calc: ใช้ Calculator Tool
        Calc-->>Agent: ส่งผลการคำนวณ
    end
    
    Agent->>User: สร้างคำตอบโดยใช้ข้อมูลที่ได้จาก Tool
```

## โครงสร้างของ Flow ใน Langflow

```mermaid
graph TD
    A[Chat Input Component] --> B[Tool Calling Agent]
    B --> C[Chat Output Component]
    
    D[OpenAI] --> B
    
    E[Search Tool] --> B
    F[Calculator Tool] --> B
    
    G[Vector Store] --> E
    
    H[Text Splitter] --> G
    I[Embeddings] --> G
    
    J[Document Loader] --> H
    
    style A fill:#f9d5e5,stroke:#333,stroke-width:2px
    style B fill:#d5e5f9,stroke:#333,stroke-width:2px
    style C fill:#f9d5e5,stroke:#333,stroke-width:2px
    style D fill:#ffefc1,stroke:#333,stroke-width:2px
    style E fill:#c1ffe4,stroke:#333,stroke-width:2px
    style F fill:#c1ffe4,stroke:#333,stroke-width:2px
    style G fill:#e4c1ff,stroke:#333,stroke-width:2px
    style H fill:#c1e0ff,stroke:#333,stroke-width:2px
    style I fill:#c1e0ff,stroke:#333,stroke-width:2px
    style J fill:#ffc1c1,stroke:#333,stroke-width:2px
```

## องค์ประกอบหลักของ Simple Agent Flow

```mermaid
mindmap
    root(Simple Agent Flow)
        Tool Calling Agent
            ::icon(fa fa-brain)
            ใช้ LLM วิเคราะห์คำถาม
            เลือก Tool ที่เหมาะสม
            System Prompt กำหนดพฤติกรรม
        Search Tool
            ::icon(fa fa-search)
            เชื่อมต่อกับ Vector Store
            ค้นหาข้อมูลอาหารไทย
            รองรับการค้นหาด้วยภาษาธรรมชาติ
        Calculator Tool
            ::icon(fa fa-calculator)
            คำนวณส่วนผสมอาหาร
            แปลงหน่วยการวัด
            คำนวณแคลอรี่และคุณค่าทางโภชนาการ
        Vector Store
            ::icon(fa fa-database)
            เก็บข้อมูลอาหารไทย
            สร้าง Embeddings จากข้อมูล
            ใช้ Similarity Search ค้นหาข้อมูล
        Prompt Template
            ::icon(fa fa-file-text)
            กำหนดบทบาทของ Agent
            แนะนำวิธีใช้เครื่องมือ
            ระบุรูปแบบการตอบกลับ
```

## ขั้นตอนการสร้าง Simple Agent สำหรับข้อมูลอาหารไทย

### ขั้นตอนที่ 1: เตรียมข้อมูลอาหารไทย

```mermaid
flowchart LR
    A[รวบรวมข้อมูลอาหารไทย] --> B[เตรียมไฟล์ข้อความ]
    B --> C[แบ่งข้อมูลเป็นหมวดหมู่]
    C -->|อาหารแต่ละชนิด| D[thai_food_information.txt]
    C -->|วัตถุดิบและเครื่องปรุง| E[thai_ingredients.txt]
```

โปรเจคนี้มีข้อมูลพร้อมใช้งานในโฟลเดอร์ `data/` ซึ่งประกอบด้วย:
- `thai_food_information.txt`: ข้อมูลเกี่ยวกับอาหารไทย 10 ชนิด
- `thai_ingredients.txt`: ข้อมูลเกี่ยวกับวัตถุดิบและเครื่องปรุงอาหารไทย

### ขั้นตอนที่ 2: เปิด Langflow และเริ่มต้นโปรเจกต์

```mermaid
flowchart TD
    A[เปิด Langflow] --> B[สร้าง Flow ใหม่]
    B --> C{เลือก Template}
    C --> D[Simple Agent]
    D --> E[Flow พื้นฐานถูกสร้างขึ้น]
```

1. เปิด Langflow ในเบราว์เซอร์
2. คลิกปุ่ม **New Flow**
3. เลือก **Simple Agent** จากรายการ Template

### ขั้นตอนที่ 3: ตั้งค่าองค์ประกอบหลัก

```mermaid
flowchart TD
    subgraph "1. ตั้งค่า OpenAI API"
        A[คลิกที่ OpenAI Component] --> B[ใส่ API Key]
    end
    
    subgraph "2. ตั้งค่า Document Loader"
        C[คลิกที่ Document Loader] --> D[ระบุเส้นทางไปยัง thai_food_information.txt]
        C --> E[ระบุเส้นทางไปยัง thai_ingredients.txt]
    end
    
    subgraph "3. ตั้งค่า Text Splitter"
        F[คลิกที่ Text Splitter] --> G[ตั้งค่า Chunk Size = 1000]
        G --> H[ตั้งค่า Chunk Overlap = 200]
    end
    
    subgraph "4. ตั้งค่า Vector Store"
        I[คลิกที่ Vector Store] --> J[เลือกประเภท (FAISS)]
        J --> K[ตั้งค่า Index Name]
    end
    
    subgraph "5. ตั้งค่า Tool Calling Agent"
        L[คลิกที่ Tool Calling Agent] --> M[แก้ไข System Prompt]
        M --> N[เพิ่มรายละเอียดเกี่ยวกับอาหารไทย]
    end
```

### ขั้นตอนที่ 4: เชื่อมต่อองค์ประกอบ

```mermaid
flowchart LR
    A[Document Loader] --> B[Text Splitter]
    B --> C[Vector Store]
    D[Embeddings] --> C
    
    C --> E[Search Tool]
    F[Calculator Tool] --> G[Tool Calling Agent]
    E --> G
    
    H[OpenAI] --> G
    I[Prompt Template] --> G
    
    J[Chat Input] --> G
    G --> K[Chat Output]
```

### ขั้นตอนที่ 5: ปรับแต่ง System Prompt

```mermaid
graph TD
    A[เปิด Tool Calling Agent] --> B[แก้ไข System Prompt]
    B --> C[ระบุบทบาทเป็นผู้เชี่ยวชาญด้านอาหารไทย]
    C --> D[อธิบายวิธีการใช้ Tool]
    D --> E[กำหนดรูปแบบการตอบคำถาม]
```

ตัวอย่าง System Prompt:

```
คุณเป็นผู้เชี่ยวชาญด้านอาหารไทย ที่มีความรู้เกี่ยวกับอาหารไทยแท้ดั้งเดิม วัตถุดิบ วิธีการทำ และประวัติความเป็นมา

คุณมีเครื่องมือต่างๆ ที่สามารถใช้ช่วยในการตอบคำถามได้:
1. Search Tool - ใช้ค้นหาข้อมูลเกี่ยวกับอาหารไทย วัตถุดิบ และวิธีการทำ 
2. Calculator - ใช้คำนวณปริมาณส่วนผสม การแปลงหน่วย หรือคุณค่าทางโภชนาการ

ในการตอบคำถาม:
- ใช้ข้อมูลที่ถูกต้องและอ้างอิงจากแหล่งข้อมูลที่มี
- อธิบายอย่างละเอียดและเป็นขั้นตอน
- หากมีหลายวิธี ให้ระบุทางเลือกต่างๆ
- หากไม่มีข้อมูลเพียงพอ ให้แจ้งว่าไม่มีข้อมูล

เมื่อตอบคำถามเกี่ยวกับวิธีทำอาหาร ให้แสดงส่วนผสมและขั้นตอนอย่างชัดเจน
```

## การทดสอบ Simple Agent

```mermaid
sequenceDiagram
    participant User as ผู้ใช้
    participant Agent as Simple Agent
    
    User->>Agent: คุณมีเครื่องมืออะไรบ้าง?
    Agent->>User: ฉันมีเครื่องมือดังนี้:<br/>1. Search Tool<br/>2. Calculator
    
    User->>Agent: วัตถุดิบในการทำต้มยำกุ้งมีอะไรบ้าง?
    Agent->>Agent: คิด: ฉันต้องใช้ Search Tool เพื่อค้นหาวัตถุดิบต้มยำกุ้ง
    Agent->>User: [แสดงวัตถุดิบต้มยำกุ้งที่ค้นพบ]
    
    User->>Agent: ถ้าฉันต้องทำต้มยำกุ้งสำหรับ 5 คน ต้องใช้วัตถุดิบเท่าไร?
    Agent->>Agent: คิด: ฉันต้องใช้ Search Tool ค้นหาวัตถุดิบมาตรฐาน<br/>และใช้ Calculator คำนวณปริมาณสำหรับ 5 คน
    Agent->>User: [แสดงคำตอบพร้อมการคำนวณ]
```

## คำถามทดสอบและตัวอย่างผลลัพธ์

โปรเจคนี้มีคำถามทดสอบใน `questions.txt` จำนวน 10 คำถาม ตัวอย่างเช่น:

### คำถาม 1: วัตถุดิบหลักในการทำต้มยำกุ้งมีอะไรบ้าง?

```mermaid
graph TD
    A[คำถาม: วัตถุดิบหลักในการทำต้มยำกุ้งมีอะไรบ้าง?] --> B[Agent คิด]
    B --> C{เลือก Tool}
    C -->|Search Tool| D[ค้นหา: วัตถุดิบ ต้มยำกุ้ง]
    D --> E[พบข้อมูลเกี่ยวกับวัตถุดิบต้มยำกุ้ง]
    E --> F[สร้างคำตอบจากข้อมูลที่พบ]
    F --> G[คำตอบละเอียดเกี่ยวกับวัตถุดิบต้มยำกุ้ง]
```

**ตัวอย่างคำตอบ:**
```
วัตถุดิบหลักในการทำต้มยำกุ้งประกอบด้วย:

1. กุ้งสด (กุ้งแม่น้ำหรือกุ้งทะเล)
2. น้ำซุปหรือน้ำเปล่า
3. สมุนไพรหลัก:
   - ข่า (หั่นเป็นแว่นบางๆ)
   - ตะไคร้ (ทุบและหั่นท่อน)
   - ใบมะกรูด (ฉีก)
4. พริกขี้หนูสด
5. น้ำปลา
6. น้ำมะนาว
7. เห็ดฟาง หรือเห็ดนางฟ้า
8. หอมแดง
9. ผักชี

สำหรับต้มยำน้ำข้น จะมีวัตถุดิบเพิ่มเติม:
- น้ำพริกเผา
- นมข้น หรือกะทิ

วัตถุดิบเหล่านี้รวมกันสร้างรสชาติเปรี้ยว เผ็ด และหอมกลิ่นสมุนไพรที่เป็นเอกลักษณ์ของต้มยำกุ้ง
```

### คำถาม 2: ทำไมส้มตำไทยถึงมีรสชาติต่างจากส้มตำลาว?

```mermaid
graph TD
    A[คำถาม: ทำไมส้มตำไทยถึงมีรสชาติต่างจากส้มตำลาว?] --> B[Agent คิด]
    B --> C{เลือก Tool}
    C -->|Search Tool| D[ค้นหา: ความแตกต่าง ส้มตำไทย ส้มตำลาว]
    D --> E[พบข้อมูลเกี่ยวกับประวัติและความแตกต่าง]
    E --> F[สร้างคำตอบเปรียบเทียบความแตกต่าง]
    F --> G[คำตอบละเอียดพร้อมประวัติความเป็นมา]
```

**ตัวอย่างคำตอบ:**
```
ส้มตำไทยและส้มตำลาวมีรสชาติที่แตกต่างกันเนื่องจากหลายปัจจัย:

1. รสชาติหลัก:
   - ส้มตำไทย: มีความหวานมากกว่า ความเผ็ดน้อยกว่า และมีความกลมกล่อมจากการผสมผสานรสชาติหวาน เปรี้ยว เค็ม เผ็ด
   - ส้มตำลาว (ตำบักหุ่ง): มีความเผ็ดจัดกว่า เน้นรสเค็มจากน้ำปลาร้า และรสเปรี้ยวจากมะนาว มีรสหวานน้อยกว่า

2. ส่วนประกอบที่แตกต่าง:
   - ส้มตำไทย: ใส่น้ำตาลปี๊บ กุ้งแห้ง และถั่วลิสง
   - ส้มตำลาว: ใส่น้ำปลาร้า มักไม่ใส่กุ้งแห้งและน้ำตาลปี๊บ หรือใส่ในปริมาณน้อย

3. ประวัติความเป็นมา:
   ตามที่ระบุในข้อมูลที่มี ส้มตำมีต้นกำเนิดจากอาหารของชาวลาวในภาคตะวันออกเฉียงเหนือของไทย (อีสาน) แต่เมื่อแพร่หลายไปทั่วประเทศไทย ได้มีการปรับเปลี่ยนรสชาติให้เข้ากับความชอบของคนไทยทั่วไป โดยเพิ่มความหวานและลดความเผ็ดลง

4. วิธีการปรุง:
   - การโขลกส่วนผสมของส้มตำไทยจะนุ่มนวลกว่า เพื่อให้รสชาติกลมกล่อม
   - การโขลกส้มตำลาวมักจะแรงกว่าเพื่อให้รสชาติเข้มข้น

การปรับรสชาตินี้สะท้อนให้เห็นถึงวัฒนธรรมการรับประทานอาหารที่แตกต่างกัน และการพัฒนาของอาหารเมื่อแพร่กระจายจากต้นกำเนิดไปยังพื้นที่ใหม่
```

## ข้อแนะนำสำหรับการปรับแต่ง Prompt

```mermaid
graph TD
    A[การปรับแต่ง Prompt] --> B{จุดประสงค์}
    
    B --> C[ความเฉพาะเจาะจง]
    B --> D[รูปแบบคำตอบ]
    B --> E[พฤติกรรมของ Agent]
    
    C --> C1[ระบุประเภทอาหารที่ต้องการ]
    C --> C2[ระบุภูมิภาคของอาหารไทย]
    
    D --> D1[ขั้นตอนการทำอาหารแบบละเอียด]
    D --> D2[ข้อมูลวัตถุดิบและทางเลือก]
    
    E --> E1[ให้คำแนะนำเพิ่มเติม]
    E --> E2[เปรียบเทียบอาหารคล้ายกัน]
```

ตัวอย่างการปรับแต่งที่ดี:

```
คุณเป็นเชฟอาหารไทยที่มีประสบการณ์มากกว่า 30 ปี ตอบคำถามโดยใช้ความรู้จากข้อมูลที่มีอยู่ ให้คำแนะนำเกี่ยวกับอาหารไทยแท้ๆ

เมื่อถูกถามเกี่ยวกับวิธีทำอาหาร ให้อธิบายเป็นขั้นตอนชัดเจน เรียงตามลำดับ พร้อมระบุ:
1. วัตถุดิบที่จำเป็น พร้อมปริมาณโดยประมาณ
2. วัตถุดิบทดแทนที่อาจหาได้ง่ายกว่า
3. เทคนิคพิเศษที่จะช่วยให้อาหารมีรสชาติดีขึ้น
4. ข้อควรระวังในขั้นตอนสำคัญ

ใช้ภาษาเป็นกันเอง แต่ให้รายละเอียดครบถ้วนและถูกต้องตามตำรับดั้งเดิม
```

## โครงสร้างไฟล์ของโปรเจกต์

```
hand-on_2-3/
├── data/
│   ├── thai_food_information.txt  # ข้อมูลเกี่ยวกับอาหารไทย 10 ชนิด
│   └── thai_ingredients.txt       # ข้อมูลเกี่ยวกับวัตถุดิบและเครื่องปรุงอาหารไทย
├── questions.txt                  # ชุดคำถาม 10 ข้อสำหรับทดสอบระบบ 
├── prompt.txt                     # Prompt แบบ Dynamic สำหรับใช้กับระบบ
├── langflow_rag_guide.md          # คู่มือการใช้งาน RAG บน Langflow
├── simple_agent_explanation.md    # เอกสารอธิบายการทำงานของ Simple Agent
└── README_TH.md                   # ไฟล์นี้
```

## สรุป

Simple Agent ใน Langflow เป็นเครื่องมือที่ทรงพลังสำหรับการสร้างแอปพลิเคชัน AI ที่สามารถแก้ปัญหาและตอบคำถามได้โดยอัตโนมัติ ด้วยการรวม Simple Agent เข้ากับเทคโนโลยี RAG และข้อมูลอาหารไทย ทำให้เราสามารถสร้างแชทบอทที่:

- ตอบคำถามเกี่ยวกับอาหารไทยได้อย่างแม่นยำ
- เลือกใช้เครื่องมือที่เหมาะสมกับคำถามแต่ละประเภท
- ให้ข้อมูลเชิงลึกเกี่ยวกับวัตถุดิบ วิธีการทำ และประวัติความเป็นมา
- สามารถคำนวณปริมาณส่วนผสมและปรับสูตรอาหารได้

คู่มือนี้ได้อธิบายการสร้าง Simple Agent สำหรับข้อมูลอาหารไทย ซึ่งสามารถนำไปประยุกต์ใช้กับข้อมูลประเภทอื่นๆ ได้เช่นกัน

## แหล่งข้อมูลเพิ่มเติม

- [Langflow Documentation](https://docs.langflow.org)
- [Starter Projects: Simple Agent](https://docs.langflow.org/starter-projects-simple-agent)
- [คู่มือการใช้งาน RAG](langflow_rag_guide.md)
- [คำอธิบายการทำงานของ Simple Agent](simple_agent_explanation.md)

## หมายเหตุ

แผนภาพในเอกสารนี้สร้างด้วย Mermaid ซึ่งเป็น JavaScript library สำหรับสร้างแผนภาพจากข้อความ คุณสามารถดูแผนภาพเหล่านี้ได้ใน GitHub หรือเว็บไซต์ที่สนับสนุนการแสดงผล Mermaid เช่น GitHub, GitLab หรือเว็บไซต์ที่มีปลั๊กอิน Mermaid