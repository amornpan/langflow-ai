# 🚀 Langflow - Super Easy Setup

## เริ่มใช้งานแค่ 1 คลิก!

### 📁 ไฟล์ที่สำคัญ:
- **`start.bat`** - เริ่ม Langflow ✅
- **`stop.bat`** - หยุด Langflow ⏹️  
- **`status.bat`** - ดูสถานะ 📊
- **`cleanup.bat`** - ลบทุกอย่าง 🗑️

## 🎯 วิธีใช้งาน

### 1. เริ่มต้น
```cmd
start.bat
```
- รัน Langflow แบบ SQLite (ไม่ต้องตั้งค่า database)
- Auto-login เปิดใช้งาน (ไม่ต้องพิมพ์รหัสผ่าน)
- เปิดเบราว์เซอร์อัตโนมัติ

### 2. ตรวจสอบสถานะ
```cmd
status.bat
```

### 3. หยุดการทำงาน
```cmd
stop.bat
```

### 4. ลบทุกอย่าง (ถ้าต้องการ)
```cmd
cleanup.bat
```

## 🌐 การเข้าถึง

- **URL**: http://localhost:7860
- **Login**: Auto-login (ไม่ต้องใส่รหัส)
- **Data**: บันทึกใน Docker volume (ไม่หายหลัง restart)

## 🔧 ข้อดี

✅ **ง่ายมาก** - แค่ดับเบิลคลิก `start.bat`  
✅ **ไม่ต้องตั้งค่า** - ใช้ SQLite database  
✅ **Auto-login** - ไม่ต้องจำรหัสผ่าน  
✅ **Persistent data** - ข้อมูลไม่หาย  
✅ **เปิดเบราว์เซอร์อัตโนมัติ** - พร้อมใช้งานทันที  

## 🆘 แก้ปัญหา

### Langflow ไม่เริ่ม?
```cmd
# ดู error
docker logs langflow_easy

# ลองใหม่
cleanup.bat
start.bat
```

### Port ขัดแย้ง?
```cmd
# หยุดโปรแกรมที่ใช้ port 7860
netstat -ano | findstr :7860
```

## 💡 Tips

- **ไฟล์ flows** จะบันทึกอัตโนมัติ
- **รีสตาร์ท** ด้วย `stop.bat` แล้ว `start.bat`
- **อัพเดท** ด้วย `cleanup.bat` แล้ว `start.bat`
