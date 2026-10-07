# 📋 คู่มือตั้งค่าแอปแบบละเอียด - ทำตามขั้นตอน

## 🎯 สิ่งที่ต้องเตรียม

คุณต้องตั้งค่า 3 บริการหลัก:
1. **Supabase** - Database และ Backend
2. **Firebase** - Authentication และ Analytics  
3. **Gemini AI** - AI Personalization

---

## 📝 STEP 1: ตั้งค่า Supabase (15 นาที)

### 1.1 สร้าง Supabase Project

1. ไปที่ https://supabase.com/
2. คลิก **"Start your project"** หรือ **"Sign In"**
3. สมัครสมาชิก (ใช้ Google/GitHub ได้)
4. คลิก **"New Project"**
5. กรอกข้อมูล:
   ```
   Name: fitness-game-app
   Database Password: [ตั้งรหัสผ่านแล้วจดไว้]
   Region: Southeast Asia (Singapore) [เลือกใกล้ที่สุด]
   Plan: Free
   ```
6. คลิก **"Create new project"**
7. รอ 2-3 นาที ให้ project เสร็จ

### 1.2 รัน Database Schema

1. ใน Supabase Dashboard ซ้ายมือ → คลิก **"SQL Editor"**
2. คลิก **"New query"**
3. เปิดไฟล์ `D:\jump up\Phase1-Setup\supabase_schema.sql`
4. **คัดลอกโค้ดทั้งหมด** จากไฟล์นั้นมาวางใน SQL Editor
5. คลิก **"Run"** (หรือกด Ctrl+Enter)
6. รอจนเห็น **"Success"**

### 1.3 ตรวจสอบ Tables

1. ซ้ายมือ → คลิก **"Table Editor"**
2. ควรเห็น tables เหล่านี้:
   - ✅ users
   - ✅ expert_programs
   - ✅ workout_sessions
   - ✅ achievements
   - ✅ user_achievements
   - ✅ shop_items
   - ✅ user_inventory
   - ✅ quests
   - ✅ user_quest_progress

### 1.4 คัดลอก API Keys

1. ซ้ายมือ → คลิก **"Project Settings"** (ไอคอนเฟือง)
2. คลิก **"API"**
3. **จด 2 ค่านี้ไว้:**

   📋 **Project URL**
   ```
   https://xxxxxxxxxxxxx.supabase.co
   ```
   
   📋 **anon public key** (คีย์ยาวๆ ที่ขึ้นต้นด้วย eyJ)
   ```
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

---

## 🔥 STEP 2: ตั้งค่า Firebase (20 นาที)

### 2.1 สร้าง Firebase Project

1. ไปที่ https://console.firebase.google.com/
2. คลิก **"Add project"** หรือ **"เพิ่มโปรเจกต์"**
3. ตั้งชื่อ: `fitness-game-app`
4. Google Analytics: **เปิดใช้งาน** (แนะนำ)
5. เลือก Analytics account (หรือสร้างใหม่)
6. คลิก **"Create project"**
7. รอจนเห็น "Your new project is ready"

### 2.2 เปิดใช้งาน Authentication

1. ซ้ายมือ → คลิก **"Authentication"**
2. คลิก **"Get started"**
3. คลิก **"Sign-in method"** (แท็บบนสุด)
4. คลิก **"Google"**
5. เปิด **Enable**
6. Project support email: เลือก email ของคุณ
7. คลิก **"Save"**

### 2.3 เพิ่ม Android App

1. บน Project Overview → คลิก ไอคอน **Android** (รูปหุ่นยนต์สีเขียว)
2. กรอกข้อมูล:
   ```
   Android package name: com.example.fitness_game_app
   App nickname: Fitness Game (Android)
   Debug signing certificate: [ปล่อยว่าง]
   ```
3. คลิก **"Register app"**
4. **ดาวน์โหลด** `google-services.json`
5. **ย้ายไฟล์** `google-services.json` ไปวางที่:
   ```
   D:\jump up\fitness_game_app\android\app\google-services.json
   ```
6. คลิก **"Next"** จนจบ

### 2.4 เพิ่ม iOS App

1. บน Project Overview → คลิก ไอคอน **iOS** (รูป Apple)
2. กรอกข้อมูล:
   ```
   iOS bundle ID: com.example.fitnessGameApp
   App nickname: Fitness Game (iOS)
   App Store ID: [ปล่อยว่าง]
   ```
3. คลิก **"Register app"**
4. **ดาวน์โหลด** `GoogleService-Info.plist`
5. **ย้ายไฟล์** `GoogleService-Info.plist` ไปวางที่:
   ```
   D:\jump up\fitness_game_app\ios\Runner\GoogleService-Info.plist
   ```
6. คลิก **"Next"** จนจบ

### 2.5 ตั้งค่า OAuth (สำคัญ!)

1. ไปที่ Google Cloud Console: https://console.cloud.google.com/
2. เลือกโปรเจกต์ `fitness-game-app`
3. ซ้ายมือ → **"APIs & Services"** → **"Credentials"**
4. จด **Web client ID** ไว้ (จะใช้ตอนทดสอบ)

---

## 🤖 STEP 3: ตั้งค่า Gemini AI (5 นาที)

### 3.1 สร้าง API Key

1. ไปที่ https://makersuite.google.com/app/apikey
   หรือ https://aistudio.google.com/app/apikey
2. คลิก **"Create API key"**
3. เลือก **"Create API key in new project"**
4. คลิก **"Create"**
5. **คัดลอก API Key** (ขึ้นต้นด้วย AIza...)
   ```
   AIzaSy...
   ```
6. เก็บไว้ในที่ปลอดภัย (แสดงครั้งเดียว!)

---

## 💻 STEP 4: ใส่ API Keys ลงในโค้ด

### 4.1 เปิดไฟล์ env.dart

เปิดไฟล์:
```
D:\jump up\fitness_game_app\lib\config\env.dart
```

### 4.2 แก้ไขไฟล์ (แทนที่ค่าทั้ง 3)

```dart
class Environment {
  // Supabase Configuration
  // จาก STEP 1.4
  static const String supabaseUrl = 'https://xxxxxxxxxxxxx.supabase.co'; // ⬅️ แทนที่ตรงนี้
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // ⬅️ แทนที่ตรงนี้

  // Gemini AI Configuration
  // จาก STEP 3.1
  static const String geminiApiKey = 'AIzaSy...'; // ⬅️ แทนที่ตรงนี้

  // App Configuration (ไม่ต้องแก้)
  static const String appName = 'Fitness Game App';
  static const String appVersion = '1.0.0';

  // Feature Flags (ไม่ต้องแก้)
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = false;

  // MediaPipe Configuration (ไม่ต้องแก้)
  static const int targetFPS = 15;
  static const int processEveryNthFrame = 3;
  static const double poseDetectionConfidenceThreshold = 0.7;

  // Gamification Settings (ไม่ต้องแก้)
  static const int baseExpPerLevel = 100;
  static const int baseCoinsPerVictory = 50;
  static const int baseExpPerVictory = 100;
}
```

### 4.3 ตัวอย่างที่ถูกต้อง

```dart
// ตัวอย่างค่าจริง (อย่าใช้ค่านี้!)
static const String supabaseUrl = 'https://abcdefgh12345678.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoMTIzNDU2NzgiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYzMjE0MDgwMCwiZXhwIjoxOTQ3NzE2ODAwfQ.XYZ123abc...';
static const String geminiApiKey = 'AIzaSyA1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q';
```

### 4.4 บันทึกไฟล์

กด **Ctrl+S** เพื่อบันทึก

---

## ✅ STEP 5: ตรวจสอบไฟล์ทั้งหมด

### 5.1 Checklist

- [ ] `lib/config/env.dart` - ใส่ API keys แล้ว
- [ ] `android/app/google-services.json` - ไฟล์มีอยู่
- [ ] `ios/Runner/GoogleService-Info.plist` - ไฟล์มีอยู่
- [ ] Supabase database tables - สร้างแล้ว 9 tables

### 5.2 ตรวจสอบโครงสร้างไฟล์

```
fitness_game_app/
├── android/
│   └── app/
│       └── google-services.json ✅ ต้องมี
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist ✅ ต้องมี
└── lib/
    └── config/
        └── env.dart ✅ แก้ไขแล้ว
```

---

## 🚀 STEP 6: ติดตั้งและรัน

### 6.1 เปิด Terminal

```bash
cd "D:\jump up\fitness_game_app"
```

### 6.2 ติดตั้ง Dependencies

```bash
flutter pub get
```

รอจนเห็น:
```
Running "flutter pub get" in fitness_game_app...
Resolving dependencies... (X.Xs)
Got dependencies!
```

### 6.3 รันแอป

**บน Android:**
```bash
flutter run
```

**บน iOS (ต้องมี Mac):**
```bash
cd ios
pod install
cd ..
flutter run
```

### 6.4 เลือกอุปกรณ์

ถ้ามีหลายอุปกรณ์:
```bash
flutter devices           # ดูรายการอุปกรณ์
flutter run -d <device>   # เลือกอุปกรณ์
```

---

## 🐛 แก้ปัญหาที่เจอบ่อย

### ปัญหา 1: "google-services.json not found"

**วิธีแก้:**
1. ตรวจสอบว่าไฟล์อยู่ที่ `android/app/google-services.json`
2. ชื่อไฟล์ต้องตรงทุกตัวอักษร (ตัวเล็ก)
3. ต้องไม่มี extension เพิ่ม (เช่น .txt)

### ปัญหา 2: "Supabase connection failed"

**วิธีแก้:**
1. ตรวจสอบ URL ใน `env.dart` ต้องมี `https://`
2. ลบช่องว่างหน้า-หลัง API key
3. ตรวจสอบว่า key ไม่ขาดหาย (คัดลอกทั้งหมด)

### ปัญหา 3: "Gemini API error"

**วิธีแก้:**
1. ตรวจสอบว่า API key ถูกต้อง
2. ไปที่ https://aistudio.google.com/app/apikey ตรวจสอบ quota
3. ลองสร้าง key ใหม่

### ปัญหา 4: "Google Sign-In failed"

**วิธีแก้:**
1. ตรวจสอบว่า package name ตรงกัน
2. ลองลบแอป และ install ใหม่
3. ตรวจสอบว่า SHA-1 certificate ตรงกัน (สำหรับ production)

### ปัญหา 5: "Camera permission denied"

**วิธีแก้:**

**Android:** เพิ่มใน `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

**iOS:** เพิ่มใน `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to track your exercise poses</string>
```

---

## 📱 STEP 7: ทดสอบแอป

### 7.1 ทดสอบ Authentication

1. เปิดแอป
2. คลิก "Sign in with Google"
3. เลือกบัญชี Google
4. ควรเข้าสู่หน้า Welcome/Onboarding

### 7.2 ทดสอบ Onboarding

1. กรอกข้อมูลทั้ง 7 ขั้นตอน
2. คลิก Complete
3. ควรเห็นหน้า Home พร้อมสถิติ

### 7.3 ทดสอบ Database

1. กลับไปที่ Supabase Dashboard
2. Table Editor → users
3. ควรเห็นข้อมูลผู้ใช้ที่สร้าง

### 7.4 ทดสอบ Boss Battle

1. หน้า Home → คลิก "Game Mode"
2. อนุญาตกล้อง
3. คลิก "Start Battle"
4. กดปุ่ม debug เพื่อทดสอบ
5. ดู HP/Mana เปลี่ยนไหม

---

## 🎯 สรุป - เช็คลิสต์ก่อนรัน

### ✅ Supabase
- [ ] สร้าง project แล้ว
- [ ] รัน SQL schema แล้ว (9 tables)
- [ ] คัดลอก URL และ anon key ใส่ `env.dart` แล้ว

### ✅ Firebase  
- [ ] สร้าง project แล้ว
- [ ] เปิด Google Sign-In แล้ว
- [ ] ดาวน์โหลด `google-services.json` วางแล้ว (Android)
- [ ] ดาวน์โหลด `GoogleService-Info.plist` วางแล้ว (iOS)

### ✅ Gemini AI
- [ ] สร้าง API key แล้ว
- [ ] คัดลอกใส่ `env.dart` แล้ว

### ✅ Code
- [ ] แก้ไข `lib/config/env.dart` แล้ว
- [ ] รัน `flutter pub get` แล้ว
- [ ] ไม่มี error

---

## 🎊 เสร็จแล้ว!

ตอนนี้แอปพร้อมใช้งานแล้ว! 🚀

**ถ้าติดปัญหา:**
- อ่าน error message ให้ดี
- ดู section แก้ปัญหาข้างบน
- ตรวจสอบว่าทำทุกขั้นตอนแล้ว

**หมายเหตุสำคัญ:**
- ⚠️ ห้ามแชร์ API keys ให้ใคร
- ⚠️ ห้าม commit `env.dart` ขึ้น git (มี .gitignore ป้องกันแล้ว)
- ⚠️ Production ต้อง setup SHA-1 certificate เพิ่ม
