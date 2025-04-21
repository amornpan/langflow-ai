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

## การทำงานของ Agent แบบละเอียด

```mermaid
sequenceDiagram
    participant User as ผู้ใช้
    participant Agent as Tool Calling Agent
    participant Search as Search Tool
    participant Vector as Vector Store
    participant Calc as Calculator Tool
    
    User->>Agent: ถามคำถามเกี่ยวกับอาหารไทย
    Agent->>Agent: วิเคราะห์คำถามและเขียน Thought
    
    alt ต้องการข้อมูลเฉพาะ
        Agent->>Search: เลือกใช้ Search Tool
        Search->>Vector: ค้นหาข้อมูลอาหารไทยที่เกี่ยวข้อง
        Vector-->>Search: ส่งข้อมูลที่เกี่ยวข้อง
        Search-->>Agent: ส่งผลการค้นหา (Observation)
        Agent->>Agent: วิเคราะห์ข้อมูลที่ได้รับและเขียน Thought ใหม่
    else ต้องการคำนวณ
        Agent->>Calc: เลือกใช้ Calculator Tool
        Calc-->>Agent: ส่งผลการคำนวณ (Observation)
        Agent->>Agent: วิเคราะห์ผลการคำนวณและเขียน Thought ใหม่
    end
    
    Agent->>Agent: ตัดสินใจว่ามีข้อมูลเพียงพอหรือต้องใช้ Tool เพิ่มเติม
    
    opt ต้องการข้อมูลเพิ่มเติม
        Agent->>Search: ใช้ Search Tool อีกครั้ง
        Search->>Vector: ค้นหาข้อมูลเพิ่มเติม
        Vector-->>Search: ส่งข้อมูลเพิ่มเติม
        Search-->>Agent: ส่งผลการค้นหา (Observation)
        Agent->>Agent: วิเคราะห์ข้อมูลเพิ่มเติมและเขียน Thought ใหม่
    end
    
    Agent->>User: สร้างคำตอบสุดท้ายจากข้อมูลที่รวบรวมได้
```

## โครงสร้างของ Simple Agent Flow ใน Langflow

```mermaid
graph TD
    A[Chat Input Component] --> B[Tool Calling Agent]
    B --> C[Chat Output Component]
    D[OpenAI] --> B
    E[Search Tool] --> B
    F[Calculator Tool] --> B
    G[URL Tool] -.ไม่ใช้ในโปรเจกต์นี้.-> B
    H[Vector Store] --> E
    I[Text Splitter] --> H
    J[Embeddings] --> H
    K[Document Loader] --> I
```

## องค์ประกอบหลักของ Simple Agent Flow

```mermaid
mindmap
  root((Simple Agent Flow))
    Tool Calling Agent
      ใช้ LLM วิเคราะห์คำถาม
      เลือก Tool ที่เหมาะสม
      แสดงกระบวนการคิด (Thoughts)
      กำหนดจำนวนรอบสูงสุดในการคิด (max_iterations)
    Search Tool
      เชื่อมต่อกับ Vector Store
      ค้นหาข้อมูลอาหารไทย
      รองรับการค้นหาด้วยภาษาธรรมชาติ
      กำหนดจำนวนผลลัพธ์ที่ต้องการ
    Calculator Tool
      คำนวณส่วนผสมอาหาร
      แปลงหน่วยการวัด
      คำนวณแคลอรี่และคุณค่าทางโภชนาการ
      รองรับสูตรคณิตศาสตร์ทั่วไป
    Vector Store
      เก็บข้อมูลอาหารไทย
      สร้าง Embeddings จากข้อมูล
      ใช้ Similarity Search ค้นหาข้อมูล
      รองรับการอัปเดตข้อมูลใหม่
    System Prompt
      กำหนดบทบาทของ Agent
      อธิบายการใช้งาน Tools
      กำหนดโครงสร้างคำตอบ
      กำหนดบุคลิกภาพของ Agent
```

## กระบวนการคิดของ Simple Agent

การทำงานของ Simple Agent สามารถแสดงเป็นกระบวนการคิดได้ดังนี้:

```mermaid
graph LR
    A[รับคำถาม] --> B[วิเคราะห์คำถาม]
    B --> C{ต้องใช้ Tool หรือไม่?}
    C -->|ไม่ต้องใช้| D[ตอบจากความรู้พื้นฐาน]
    C -->|ต้องใช้| E{เลือก Tool}
    E -->|Search Tool| F[ค้นหาข้อมูล]
    E -->|Calculator Tool| G[คำนวณ]
    F --> H[รวบรวมข้อมูลจาก Observation]
    G --> H
    H --> I{มีข้อมูลเพียงพอหรือไม่?}
    I -->|ไม่เพียงพอ| E
    I -->|เพียงพอ| J[สร้างคำตอบสุดท้าย]
    D --> K[ส่งคำตอบให้ผู้ใช้]
    J --> K
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
    B --> C[เลือก Simple Agent]
    C --> D[Flow พื้นฐานถูกสร้างขึ้น]
```

1. เปิด Langflow ในเบราว์เซอร์
2. คลิกปุ่ม **New Flow**
3. เลือก **Simple Agent** จากรายการ Template

### ขั้นตอนที่ 3: ปรับแต่งองค์ประกอบหลัก

```mermaid
flowchart TD
    A[คลิกที่ OpenAI Component] --> B[ใส่ API Key]
    B --> C[เลือก Model เช่น gpt-4-turbo]
    
    D[คลิกที่ Document Loader] --> E[เลือก Text Loader]
    E --> F[ระบุเส้นทางไปยังไฟล์ข้อมูลอาหารไทย]
    
    G[คลิกที่ Text Splitter] --> H[ตั้งค่า Chunk Size = 1000]
    H --> I[ตั้งค่า Chunk Overlap = 200]
    
    J[คลิกที่ Vector Store] --> K[เลือกประเภท FAISS]
    K --> L[ตั้งค่า Index Name = thai_food_store]
    
    M[คลิกที่ Tool Calling Agent] --> N[แก้ไข System Prompt]
    N --> O[เพิ่มคำอธิบายเกี่ยวกับอาหารไทย]
```

### ขั้นตอนที่ 4: เชื่อมต่อองค์ประกอบ

```mermaid
flowchart LR
    A[Document Loader] --> B[Text Splitter]
    B --> C[Vector Store]
    D[Embeddings] --> C
    C --> E[Search Tool]
    E --> F[Tool Calling Agent]
    G[Calculator Tool] --> F
    H[OpenAI] --> F
    I[Chat Input] --> F
    F --> J[Chat Output]
```

### ขั้นตอนที่ 5: ปรับแต่ง System Prompt

```mermaid
graph TD
    A[คลิกที่ Tool Calling Agent] --> B[แก้ไข System Prompt]
    B --> C[ระบุบทบาทเป็นผู้เชี่ยวชาญด้านอาหารไทย]
    C --> D[อธิบายวิธีการใช้ Tools]
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

## การทำงานของ Simple Agent ในแต่ละขั้นตอน

```mermaid
sequenceDiagram
    participant User as ผู้ใช้
    participant Input as Chat Input
    participant Agent as Tool Calling Agent
    participant Search as Search Tool
    participant Vector as Vector Store
    participant Calc as Calculator Tool
    participant Output as Chat Output
    
    User->>Input: พิมพ์คำถาม
    Input->>Agent: ส่งคำถาม
    
    Agent->>Agent: วิเคราะห์คำถามและเขียน Thought
    Agent->>Agent: ตัดสินใจเลือก Tool
    
    alt เลือกใช้ Search Tool
        Agent->>Search: ส่งคำถามไปค้นหา
        Search->>Vector: ค้นหาในฐานข้อมูล
        Vector-->>Search: คืนข้อมูลที่เกี่ยวข้อง
        Search-->>Agent: ส่ง Observation กลับ
    else เลือกใช้ Calculator Tool
        Agent->>Calc: ส่งนิพจน์ที่ต้องการคำนวณ
        Calc->>Calc: ประมวลผลการคำนวณ
        Calc-->>Agent: ส่งผลลัพธ์การคำนวณกลับ
    end
    
    Agent->>Agent: ประมวลผลข้อมูลที่ได้รับ
    
    opt ถ้าข้อมูลไม่เพียงพอ
        Agent->>Agent: เขียน Thought ใหม่
        Agent->>Agent: เลือก Tool เพิ่มเติม
        
        alt เลือกใช้ Search Tool อีกครั้ง
            Agent->>Search: ส่งคำถามใหม่ไปค้นหา
            Search->>Vector: ค้นหาในฐานข้อมูล
            Vector-->>Search: คืนข้อมูลที่เกี่ยวข้อง
            Search-->>Agent: ส่ง Observation กลับ
        else เลือกใช้ Calculator Tool
            Agent->>Calc: ส่งนิพจน์ที่ต้องการคำนวณ
            Calc->>Calc: ประมวลผลการคำนวณ
            Calc-->>Agent: ส่งผลลัพธ์การคำนวณกลับ
        end
    end
    
    Agent->>Agent: สร้างคำตอบสุดท้าย
    Agent->>Output: ส่งคำตอบไปแสดงผล
    Output->>User: แสดงคำตอบให้ผู้ใช้
```

## ตัวอย่างคำถามและวิธีการคิดของ Agent

### ตัวอย่างที่ 1: "วัตถุดิบหลักในการทำต้มยำกุ้งมีอะไรบ้าง?"

```mermaid
graph TD
    A[คำถาม: วัตถุดิบหลักในการทำต้มยำกุ้งมีอะไรบ้าง?] --> B[Agent คิด]
    B --> C[เลือก Search Tool]
    C --> D[ค้นหา: วัตถุดิบ ต้มยำกุ้ง]
    D --> E[พบข้อมูลเกี่ยวกับวัตถุดิบต้มยำกุ้ง]
    E --> F[สร้างคำตอบจากข้อมูลที่พบ]
```

### ตัวอย่างที่ 2: "ถ้าต้องทำต้มยำกุ้งสำหรับ 5 คน ต้องใช้กุ้งกี่ตัว?"

```mermaid
graph TD
    A[คำถาม: ถ้าต้องทำต้มยำกุ้งสำหรับ 5 คน ต้องใช้กุ้งกี่ตัว?] --> B[Agent คิด]
    B --> C[เลือก Search Tool]
    C --> D[ค้นหา: สูตรต้มยำกุ้ง จำนวนกุ้ง]
    D --> E[พบว่าสูตรมาตรฐานใช้ 3-4 ตัวต่อคน]
    E --> F[เลือก Calculator Tool]
    F --> G[คำนวณ: 4 * 5]
    G --> H[ได้ผลลัพธ์ = 20]
    H --> I[สร้างคำตอบ: ควรใช้กุ้ง 15-20 ตัว]
```

## เทคนิคการปรับแต่ง Prompt เพื่อประสิทธิภาพที่ดีขึ้น

```mermaid
graph TD
    A[การปรับแต่ง Prompt] --> B[ความเฉพาะเจาะจง]
    A --> C[กระบวนการคิด]
    A --> D[การใช้ Tools]
    A --> E[รูปแบบการตอบ]
    
    B --> B1[ระบุชนิดอาหารที่เชี่ยวชาญ]
    B --> B2[ระบุภูมิภาคอาหารไทย]
    
    C --> C1[แนะนำให้คิดเป็นขั้นตอน]
    C --> C2[ให้วิเคราะห์คำถามก่อนตอบ]
    
    D --> D1[อธิบายเงื่อนไขการใช้ Tools]
    D --> D2[กำหนดลำดับความสำคัญของ Tools]
    
    E --> E1[โครงสร้างคำตอบมาตรฐาน]
    E --> E2[รูปแบบการนำเสนอสูตรอาหาร]
```

## ข้อแนะนำในการพัฒนา Simple Agent ให้ดียิ่งขึ้น

```mermaid
mindmap
  root((การพัฒนา Agent))
    เพิ่ม Tools เฉพาะทาง
      Recipe Tool
      Nutrition Calculator
      Ingredient Substitute Tool
    ปรับปรุงข้อมูล
      เพิ่มข้อมูลอาหารไทยหลากหลายภูมิภาค
      เพิ่มข้อมูลอาหารไทยสมัยใหม่
      เพิ่มข้อมูลประวัติความเป็นมา
    ปรับปรุง Prompt
      ระบุบุคลิกภาพเฉพาะ
      กำหนดโครงสร้างคำตอบ
      เพิ่มตัวอย่างการตอบ
    เพิ่มความสามารถ
      สร้างเมนูตามข้อจำกัด
      คำนวณคุณค่าทางโภชนาการ
      แนะนำการดัดแปลงสูตร
```

## แหล่งข้อมูลเพิ่มเติม

```mermaid
graph LR
    A[แหล่งข้อมูลเพิ่มเติม] --> B[เอกสาร Langflow]
    A --> C[คู่มือการสร้าง Agents]
    A --> D[เอกสารเกี่ยวกับอาหารไทย]
    
    B --> B1[Langflow Documentation]
    B --> B2[Starter Projects: Simple Agent]
    
    C --> C1[คู่มือการใช้งาน RAG]
    C --> C2[การสร้าง Agent ขั้นสูง]
    
    D --> D1[ตำราอาหารไทย]
    D --> D2[Thai Food Heritage Archive]
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

```mermaid
graph TD
    A[Simple Agent สำหรับข้อมูลอาหารไทย] --> B[ความสามารถหลัก]
    B --> C[ตอบคำถามเกี่ยวกับอาหารไทย]
    B --> D[คำนวณปริมาณส่วนผสม]
    B --> E[อธิบายวิธีการทำและประวัติ]
    
    A --> F[ประโยชน์]
    F --> G[เข้าถึงข้อมูลอาหารไทยได้อย่างสะดวก]
    F --> H[ปรับแต่งสูตรตามความต้องการ]
    F --> I[สืบทอดวัฒนธรรมอาหารไทย]
    
    A --> J[การนำไปต่อยอด]
    J --> K[แอปพลิเคชัน Cookbook]
    J --> L[ระบบแนะนำวัตถุดิบทดแทน]
    J --> M[ระบบออกแบบเมนูเพื่อสุขภาพ]
```

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