# ✅ API Keys Configuration - ใส่เรียบร้อยแล้ว!

## สถานะ: พร้อมใช้งาน

ไฟล์ `lib/config/env.dart` ได้รับการตั้งค่าเรียบร้อยแล้ว

---

## 🔑 API Keys ที่ใส่แล้ว

### 1. Supabase
- ✅ **URL:** `https://wecccgdzekkgdajrodna.supabase.co`
- ✅ **Anon Key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (ใส่แล้ว)

### 2. Gemini AI
- ✅ **API Key:** `AIzaSyBb3pPfPRCy7MhdYcUoTP4y1hqacD47rMQ`

---

## ⚠️ ขั้นตอนถัดไป (ต้องทำ)

### 1️⃣ รัน Supabase Database Schema (สำคัญมาก!)

**ทำตามนี้:**
1. เปิด https://supabase.com/dashboard
2. เข้าโปรเจกต์ `wecccgdzekkgdajrodna`
3. คลิกซ้ายมือ → **SQL Editor**
4. คลิก **"New query"**
5. เปิดไฟล์: `D:\jump up\Phase1-Setup\supabase_schema.sql`
6. **คัดลอกโค้ดทั้งหมด** (Ctrl+A, Ctrl+C)
7. **วางใน SQL Editor** (Ctrl+V)
8. คลิก **"Run"** (หรือกด Ctrl+Enter)
9. รอจนเห็น **"Success. No rows returned"**

**ตรวจสอบ:** ไป Table Editor ควรเห็น 9 tables:
- users
- expert_programs
- workout_sessions
- achievements
- user_achievements
- shop_items
- user_inventory
- quests
- user_quest_progress

---

### 2️⃣ ตั้งค่า Firebase (ต้องมี 2 ไฟล์)

#### สำหรับ Android:
1. ไปที่ https://console.firebase.google.com/
2. เลือกโปรเจกต์ (หรือสร้างใหม่)
3. Project Overview → เพิ่ม **Android app**
4. Package name: `com.example.fitness_game_app`
5. ดาวน์โหลด **`google-services.json`**
6. วางไฟล์ที่: `D:\jump up\fitness_game_app\android\app\google-services.json`

#### สำหรับ iOS:
1. Project Overview → เพิ่ม **iOS app**
2. Bundle ID: `com.example.fitnessGameApp`
3. ดาวน์โหลด **`GoogleService-Info.plist`**
4. วางไฟล์ที่: `D:\jump up\fitness_game_app\ios\Runner\GoogleService-Info.plist`

#### เปิดใช้งาน Authentication:
1. ซ้ายมือ → **Authentication**
2. คลิก **Get started**
3. เลือก **Google** → **Enable** → Save

---

### 3️⃣ รันแอป

```bash
cd "D:\jump up\fitness_game_app"
flutter pub get
flutter run
```

---

## 📋 Checklist

- [x] ใส่ Supabase URL
- [x] ใส่ Supabase Anon Key
- [x] ใส่ Gemini API Key
- [ ] รัน SQL Schema (9 tables)
- [ ] วาง google-services.json
- [ ] วาง GoogleService-Info.plist
- [ ] เปิด Google Sign-In ใน Firebase
- [ ] รัน flutter pub get
- [ ] รัน flutter run

---

## 🎯 ลำดับความสำคัญ

**ต้องทำก่อน:**
1. ✅ API Keys (เสร็จแล้ว)
2. ⚠️ รัน SQL Schema (สำคัญที่สุด!)
3. ⚠️ Firebase config files

**ทำได้ทีหลัง:**
- ทดสอบบนเครื่องจริง
- ปรับแต่ง UI
- เพิ่ม features

---

## 💡 หมายเหตุ

- ✅ API Keys พร้อมใช้งานแล้ว
- ⚠️ **ห้ามแชร์** API keys ให้ใคร
- ⚠️ **ห้าม commit** ขึ้น GitHub (มี .gitignore ป้องกันแล้ว)
- 📝 เก็บ keys ไว้ที่ปลอดภัย

---

**พร้อมแล้ว! ทำตาม checklist ข้างบนเพื่อเริ่มใช้งาน** 🚀
