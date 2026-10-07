# 🎯 Quick Reference - API Keys & Config

## ทุกอย่างที่ต้องใส่ (สรุปแบบเร็ว)

### 1️⃣ Supabase (2 ค่า)

**ที่หา:** https://supabase.com → Project → Settings → API

```
✅ Project URL:    https://xxxxx.supabase.co
✅ anon public:    eyJhbGciOi... (คีย์ยาว)
```

**ใส่ที่:**
```
lib/config/env.dart
  → supabaseUrl
  → supabaseAnonKey
```

---

### 2️⃣ Firebase (2 ไฟล์)

**ที่หา:** https://console.firebase.google.com → Project → Settings

```
✅ google-services.json (Android)
✅ GoogleService-Info.plist (iOS)
```

**วางที่:**
```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

---

### 3️⃣ Gemini AI (1 ค่า)

**ที่หา:** https://aistudio.google.com/app/apikey

```
✅ API Key:    AIzaSy... (ขึ้นต้นด้วย AIza)
```

**ใส่ที่:**
```
lib/config/env.dart
  → geminiApiKey
```

---

## 📂 ไฟล์ที่ต้องแก้/เพิ่ม

```
fitness_game_app/
├── lib/config/env.dart                          ✏️ EDIT (3 ค่า)
├── android/app/google-services.json             ➕ ADD FILE
└── ios/Runner/GoogleService-Info.plist          ➕ ADD FILE
```

---

## ⚡ คำสั่งรัน

```bash
cd "D:\jump up\fitness_game_app"
flutter pub get
flutter run
```

---

## ✅ เช็คก่อนรัน

- [ ] env.dart มี 3 API keys แล้ว
- [ ] google-services.json วางแล้ว
- [ ] GoogleService-Info.plist วางแล้ว  
- [ ] Supabase มี 9 tables แล้ว
- [ ] flutter pub get แล้ว

**เสร็จ! รันได้เลย** 🚀
