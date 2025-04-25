# คู่มือการติดตั้ง MCP Filesystem

คู่มือนี้ให้คำแนะนำในการติดตั้ง Model Context Protocol (MCP) Filesystem ทั้งในระบบปฏิบัติการ Windows และ macOS

## ทางเลือกในการติดตั้ง

คุณสามารถใช้ MCP Filesystem ได้ด้วย 2 วิธี:
1. ใช้ `npx` (ไม่ต้องติดตั้ง)
2. ติดตั้งแบบ global ด้วย `npm`

## วิธีที่ 1: ใช้ NPX (ไม่ต้องติดตั้ง)

### การตั้งค่าบน Windows
```json
"filesystem": {
  "command": "npx",
  "args": [
    "-y",
    "@modelcontextprotocol/server-filesystem",
    "C:/path/to/your/files"
  ]
}
```

### การตั้งค่าบน macOS
```json
"filesystem": {
  "command": "npx",
  "args": [
    "-y",
    "@modelcontextprotocol/server-filesystem",
    "/path/to/your/files"
  ]
}
```

## วิธีที่ 2: ติดตั้งแบบ Global ด้วย NPM

### ขั้นตอนที่ 1: ติดตั้งแพ็คเกจแบบ Global

รันคำสั่งต่อไปนี้ในเทอร์มินัล:

```bash
npm install -g @modelcontextprotocol/server-filesystem
```

### ขั้นตอนที่ 2: การตั้งค่าบน Windows

หลังจากติดตั้งแบบ global แล้ว ให้แก้ไขการตั้งค่าของคุณ:

```json
"filesystem": {
  "command": "C:/Users/[YourUsername]/AppData/Roaming/npm/mcp-server-filesystem.cmd",
  "args": [
    "C:/path/to/your/files"
  ]
}
```

หรือคุณสามารถใช้แบบสั้นได้ถ้าคำสั่งอยู่ใน PATH:

```json
"filesystem": {
  "command": "mcp-server-filesystem",
  "args": [
    "C:/path/to/your/files"
  ]
}
```

### ขั้นตอนที่ 3: การตั้งค่าบน macOS

หลังจากติดตั้งแบบ global แล้ว ให้แก้ไขการตั้งค่าของคุณ:

```json
"filesystem": {
  "command": "mcp-server-filesystem",
  "args": [
    "/path/to/your/files"
  ]
}
```

ถ้าแบบข้างบนไม่ทำงาน คุณอาจต้องใช้เส้นทางเต็ม:

```json
"filesystem": {
  "command": "/usr/local/bin/mcp-server-filesystem",
  "args": [
    "/path/to/your/files"
  ]
}
```

สำหรับ Mac ที่ใช้ชิพ Apple Silicon และใช้ Homebrew เส้นทางอาจเป็น:
```json
"filesystem": {
  "command": "/opt/homebrew/bin/mcp-server-filesystem",
  "args": [
    "/path/to/your/files"
  ]
}
```

## การแก้ไขปัญหา

### การค้นหาเส้นทางที่ถูกต้องของไฟล์ Binary

#### Windows
การค้นหาเส้นทางของ binary ที่ติดตั้ง:
```cmd
dir "%APPDATA%\npm\mcp*"
```

หรือตรวจสอบข้อมูล binary ในไฟล์ package.json:
```cmd
type "%APPDATA%\npm\node_modules\@modelcontextprotocol\server-filesystem\package.json" | findstr "bin"
```

#### macOS
การค้นหาเส้นทางของ binary ที่ติดตั้ง:
```bash
which mcp-server-filesystem
```

หรือตรวจสอบในไดเรกทอรี npm bin:
```bash
ls $(npm bin -g) | grep mcp
```

### ปัญหาที่พบบ่อย

1. **ไม่พบคำสั่ง**: ตรวจสอบว่าแพ็คเกจติดตั้งถูกต้องและเส้นทางถูกต้อง
2. **ปัญหาเรื่องสิทธิ์**: บน macOS คุณอาจต้องใช้ `sudo` ในการติดตั้ง
3. **ปัญหาเรื่องเส้นทาง**: ตรวจสอบให้แน่ใจว่าใช้เครื่องหมาย forward slash (`/`) แม้แต่บน Windows

## ตัวอย่างการตั้งค่าแบบสมบูรณ์

การตั้งค่าที่สมบูรณ์อาจมีลักษณะดังนี้:

```json
{
  "services": {
    "filesystem": {
      "command": "mcp-server-filesystem",
      "args": [
        "C:/Users/YourUsername/Documents/project_files"
      ]
    }
  }
}
```

เปลี่ยน `"C:/Users/YourUsername/Documents/project_files"` เป็นเส้นทางไปยังไดเรกทอรีที่คุณต้องการเปิดให้เข้าถึงผ่านบริการ filesystem
