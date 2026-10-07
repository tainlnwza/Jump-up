# 🔍 ตัวอย่างค่าจริง (Demo - อย่าใช้!)

## ⚠️ คำเตือน
ค่าเหล่านี้เป็นตัวอย่างเท่านั้น! ใช้ไม่ได้จริง
คุณต้องสร้างของตัวเองตาม COMPLETE_SETUP_GUIDE.md

---

## 1. Supabase URL

**รูปแบบ:**
```
https://[project-id].supabase.co
```

**ตัวอย่าง:**
```dart
static const String supabaseUrl = 'https://abcdefgh12345678.supabase.co';
```

**จริงของคุณจะเป็น:**
- ขึ้นต้นด้วย `https://`
- ตามด้วยตัวอักษรและตัวเลขสุ่ม
- จบด้วย `.supabase.co`
- ไม่มี `/` ท้าย

---

## 2. Supabase Anon Key

**รูปแบบ:**
```
eyJ[ตัวอักษรยาวมาก].eyJ[ตัวอักษรยาวมาก].[ตัวอักษร]
```

**ตัวอย่าง:**
```dart
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoMTIzNDU2NzgiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYzMjE0MDgwMCwiZXhwIjoxOTQ3NzE2ODAwfQ.XYZ123abcDEF456ghiJKL789mnoPQR012stuVWX345yza';
```

**จริงของคุณจะเป็น:**
- ขึ้นต้นด้วย `eyJ`
- มีจุด `.` 2 จุด แบ่งเป็น 3 ส่วน
- ยาวมาก (200+ ตัวอักษร)
- คัดลอกทั้งหมด ห้ามขาด

---

## 3. Gemini API Key

**รูปแบบ:**
```
AIza[ตัวอักษรและตัวเลข 35 ตัว]
```

**ตัวอย่าง:**
```dart
static const String geminiApiKey = 'AIzaSyA1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q';
```

**จริงของคุณจะเป็น:**
- ขึ้นต้นด้วย `AIza`
- ตามด้วยตัวอักษรและตัวเลขผสมกัน
- ยาวประมาณ 39 ตัวอักษร
- ไม่มีช่องว่าง

---

## 4. ตัวอย่าง env.dart ที่สมบูรณ์

```dart
class Environment {
  // Supabase Configuration
  // ⬇️ แทนที่ด้วยของคุณ
  static const String supabaseUrl = 'https://abcdefgh12345678.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoMTIzNDU2NzgiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYzMjE0MDgwMCwiZXhwIjoxOTQ3NzE2ODAwfQ.XYZ123abcDEF456ghiJKL789mnoPQR012stuVWX345yza';

  // Gemini AI Configuration
  // ⬇️ แทนที่ด้วยของคุณ
  static const String geminiApiKey = 'AIzaSyA1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q';

  // App Configuration (ไม่ต้องแก้)
  static const String appName = 'Fitness Game App';
  static const String appVersion = '1.0.0';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = false;

  // MediaPipe Configuration
  static const int targetFPS = 15;
  static const int processEveryNthFrame = 3;
  static const double poseDetectionConfidenceThreshold = 0.7;

  // Gamification Settings
  static const int baseExpPerLevel = 100;
  static const int baseCoinsPerVictory = 50;
  static const int baseExpPerVictory = 100;
}
```

---

## 5. วิธีเช็คว่าใส่ถูกไหม

### ✅ ถูกต้อง:
```dart
static const String supabaseUrl = 'https://abcdefgh12345678.supabase.co';
```

### ❌ ผิด - มี / ท้าย:
```dart
static const String supabaseUrl = 'https://abcdefgh12345678.supabase.co/';
```

### ❌ ผิด - ไม่มี https://
```dart
static const String supabaseUrl = 'abcdefgh12345678.supabase.co';
```

### ❌ ผิด - ยังไม่ได้แทนที่:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
```

---

## 6. Common Mistakes (ข้อผิดพลาดบ่อย)

### ผิด: คัดลอก key ไม่ครบ
```dart
// ❌ ขาดท้าย
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZ';
```

### ผิด: มีช่องว่าง
```dart
// ❌ มีช่องว่างหน้า
static const String geminiApiKey = ' AIzaSyA1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q';
```

### ผิด: ใช้ quote ผิด
```dart
// ❌ ใช้ " ปนกับ '
static const String supabaseUrl = "https://abc.supabase.co';
```

### ถูก: สมบูรณ์
```dart
// ✅ ไม่มีช่องว่าง, quote ถูกต้อง, ครบทั้งหมด
static const String geminiApiKey = 'AIzaSyA1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q';
```

---

## 7. ตรวจสอบด้วยตัวเอง

คัดลอกโค้ดนี้แทนที่ใน env.dart แล้วแก้ไข:

```dart
class Environment {
  // ✏️ ลบ YOUR_ ออก แล้วใส่ของจริง
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  
  // ส่วนนี้ไม่ต้องแก้
  static const String appName = 'Fitness Game App';
  static const String appVersion = '1.0.0';
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = false;
  static const int targetFPS = 15;
  static const int processEveryNthFrame = 3;
  static const double poseDetectionConfidenceThreshold = 0.7;
  static const int baseExpPerLevel = 100;
  static const int baseCoinsPerVictory = 50;
  static const int baseExpPerVictory = 100;
}
```

**เช็ค:**
- [ ] ไม่มีคำว่า `YOUR_` เหลืออยู่
- [ ] URL ขึ้นต้นด้วย `https://`
- [ ] Anon key ขึ้นต้นด้วย `eyJ`
- [ ] Gemini key ขึ้นต้นด้วย `AIza`
- [ ] ไม่มีช่องว่างหน้าหลัง
- [ ] ใช้ single quote `'` ทั้งหมด

---

## 🎯 สรุป

**3 ค่าที่ต้องใส่:**
1. Supabase URL (ลงท้าย .supabase.co)
2. Supabase Anon Key (ขึ้นต้น eyJ, ยาวมาก)
3. Gemini API Key (ขึ้นต้น AIza, ยาวปานกลาง)

**อย่าลืม:**
- คัดลอกให้ครบ
- ไม่มีช่องว่าง
- ตรวจสอบ 2-3 รอบ

พร้อมแล้ว! 🚀
