# ✅ SQL Schema แก้ไขแล้ว - พร้อมรัน!

## 🔧 ปัญหาที่แก้ไขแล้ว

**Error เดิม:**
```
operator does not exist: text = uuid
```

**สาเหตร:** Type mismatch ระหว่าง `auth.uid()` (TEXT) และ `id` (UUID)

**การแก้ไข:**
- เพิ่ม `::text` cast ทุกที่ที่เปรียบเทียบ `auth.uid()`
- เพิ่ม `IF NOT EXISTS` เพื่อป้องกัน error ถ้ารันซ้ำ
- เพิ่ม `DROP POLICY IF EXISTS` ก่อนสร้าง policy ใหม่
- เพิ่ม `ON CONFLICT DO NOTHING` ใน seed data
- เพิ่ม function `add_exp_and_coins` สำหรับอัพเดท exp/coins

---

## 🚀 วิธีรัน (ใหม่)

### ขั้นตอนที่ 1: เปิด Supabase SQL Editor
1. ไปที่ https://supabase.com/dashboard
2. เลือกโปรเจกต์ `wecccgdzekkgdajrodna`
3. ซ้ายมือ → คลิก **SQL Editor**
4. คลิก **"New query"**

### ขั้นตอนที่ 2: รัน SQL
1. เปิดไฟล์ใหม่: `D:\jump up\fitness_game_app\supabase_schema_fixed.sql`
2. **คัดลอกโค้ดทั้งหมด** (Ctrl+A, Ctrl+C)
3. **วางใน SQL Editor** (Ctrl+V)
4. คลิก **"Run"** หรือกด **Ctrl+Enter**
5. รอจนเห็น **"Success"**

### ขั้นตอนที่ 3: ตรวจสอบ
1. ซ้ายมือ → **Table Editor**
2. ควรเห็น **9 tables:**
   - ✅ users
   - ✅ expert_programs
   - ✅ workout_sessions
   - ✅ achievements
   - ✅ user_achievements
   - ✅ shop_items
   - ✅ user_inventory
   - ✅ quests
   - ✅ user_quest_progress

3. คลิก **achievements** → ควรเห็น **6 rows** (achievements)
4. คลิก **shop_items** → ควรเห็น **6 rows** (items)
5. คลิก **quests** → ควรเห็น **2 rows** (quests)

---

## 📋 สิ่งที่แก้ไขไปแล้ว

### 1. Type Casting
```sql
-- เดิม (ผิด)
USING (firebase_uid = auth.uid())

-- ใหม่ (ถูก)
USING (firebase_uid = auth.uid()::text)
```

### 2. IF NOT EXISTS
```sql
-- เพิ่มให้ทุก CREATE TABLE
CREATE TABLE IF NOT EXISTS users (...)
```

### 3. DROP POLICY
```sql
-- เพิ่มก่อนสร้าง policy ใหม่
DROP POLICY IF EXISTS "Users can view own data" ON users;
CREATE POLICY "Users can view own data" ...
```

### 4. ON CONFLICT
```sql
-- เพิ่มใน INSERT statements
INSERT INTO achievements (...) VALUES (...)
ON CONFLICT DO NOTHING;
```

### 5. Helper Function
```sql
-- สำหรับอัพเดท exp และ coins
CREATE OR REPLACE FUNCTION add_exp_and_coins(...)
```

---

## ✅ ผลลัพธ์ที่คาดหวัง

เมื่อรันเสร็จ ควรเห็น:
```
Success. 9 statements executed.
```

และใน Table Editor:
- **9 tables** สร้างสำเร็จ
- **6 achievements** ถูกเพิ่ม
- **6 shop items** ถูกเพิ่ม
- **2 quests** ถูกเพิ่ม
- **RLS policies** ทำงานถูกต้อง

---

## 🎯 ขั้นตอนถัดไป

หลังรัน SQL สำเร็จ:

1. ✅ Supabase Database - **เสร็จ**
2. ⚠️ Firebase Config Files - **ยังไม่ได้ทำ**
3. ⚠️ รันแอป

---

## 💡 หมายเหตุ

- ไฟล์ใหม่: `supabase_schema_fixed.sql` (แก้ไข error แล้ว)
- ไฟล์เดิม: `Phase1-Setup/supabase_schema.sql` (มี error)
- สามารถรันซ้ำได้ (มี IF NOT EXISTS)
- ปลอดภัย (มี ON CONFLICT DO NOTHING)

---

**พร้อมรันแล้ว! ลองรันดูครับ แล้วบอกผลว่าสำเร็จหรือไม่** 🚀
