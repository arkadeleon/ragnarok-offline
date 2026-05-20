# คัดลอกไฟล์ไคลเอนต์ Ragnarok Online ไปยังอุปกรณ์ของคุณ

## วิธีที่ 1: Wi-Fi (จาก Windows ไปยัง iPhone/iPad)

**ขั้นตอนที่ 1 — แชร์โฟลเดอร์บน Windows**

1. คลิกขวาที่โฟลเดอร์ไคลเอนต์ kRO แล้วเลือก **Properties**
2. เปิดแท็บ **Sharing** แล้วคลิก **Advanced Sharing**
3. ติ๊กถูกที่ **Share this folder** แล้วคลิก **OK**
4. เปิด **Settings** → **Network & Internet** และตรวจสอบว่าโปรไฟล์เครือข่ายตั้งไว้เป็น **Private**
5. ใน **Control Panel** → **Network and Sharing Center** → **Change advanced sharing settings** เปิดใช้งาน **Network discovery** และ **File and printer sharing**

**ขั้นตอนที่ 2 — ค้นหาที่อยู่ IP ของ PC**

กด **Win + R** พิมพ์ `cmd` กด Enter แล้วพิมพ์ `ipconfig` จดบันทึก **IPv4 Address** (เช่น `192.168.1.10`)

**ขั้นตอนที่ 3 — เชื่อมต่อจาก iOS**

1. เปิดแอป **Files**
2. แตะ **···** ที่มุมขวาบน แล้วเลือก **Connect to Server**
3. ป้อน `smb://192.168.1.10` (ใช้ IP ของ PC ของคุณ)
4. ป้อนชื่อผู้ใช้และรหัสผ่าน Windows แล้วแตะ **Connect**

**ขั้นตอนที่ 4 — คัดลอกไฟล์**

คัดลอกรายการต่อไปนี้ไปยัง **On My iPhone/iPad → Ragnarok Offline** (กดค้างแต่ละรายการ → **Copy** ไปที่ปลายทาง → **Paste**):

- **data.grf**
- โฟลเดอร์ **BGM**

---

## วิธีที่ 2: สาย USB

**Mac:** เชื่อมต่ออุปกรณ์ → เปิด **Finder** → เลือก iPhone/iPad → แท็บ **Files** → ขยาย **Ragnarok Offline** → ลากไฟล์เข้าไป

**Windows:** เชื่อมต่ออุปกรณ์ → เปิด **iTunes** → เลือกอุปกรณ์ → **File Sharing** → เลือก **Ragnarok Offline** → ลากไฟล์เข้าไป
