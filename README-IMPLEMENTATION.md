# Gamified Fitness Application - Implementation Guide

## Quick Start Summary

คุณได้ออกแบบแอปพลิเคชันออกกำลังกายแบบเกมที่ใช้ AI และ MediaPipe สำหรับการติดตามท่าทาง นี่คือข้อมูลสำคัญทั้งหมดที่คุณต้องรู้

## 🎯 สิ่งที่คุณจะได้รับ

1. **CONTEXT.md** - คำศัพท์และความหมายที่ใช้ในโปรเจกต์
2. **ARCHITECTURE.md** - สถาปัตยกรรมระบบแบบเต็ม รวม data model และ flow diagrams
3. **ADR documents** - บันทึกการตัดสินใจสถาปัตยกรรมที่สำคัญ
4. **Implementation Roadmap** - ขั้นตอนการพัฒนา

## 📋 Tech Stack Recommendations (สิ่งที่แนะนำ)

### ✅ ใช้สิ่งนี้แทนแผนเดิม:

| Component | แผนเดิม | แนะนำให้ใช้ | เหตุผล |
|-----------|---------|-------------|---------|
| **Backend** | Firebase + Supabase | **Supabase เป็นหลัก** | ง่ายกว่า ไม่ต้องจัดการ 2 ระบบ |
| **Database** | Supabase | **Supabase PostgreSQL** | เหมาะกับข้อมูลที่มีความสัมพันธ์ซับซ้อน |
| **Storage** | ไม่ระบุ | **Supabase Storage** | 1GB ฟรี พอสำหรับ video/images |
| **Auth** | Google Login | **Firebase Auth → Supabase** | ใช้ Firebase Auth แล้วซิงค์ไป Supabase |
| **AI Service** | ไม่ระบุ | **Gemini 1.5 Flash** | ฟรี 15 req/min, เร็ว, ดีสำหรับ JSON |
| **MediaPipe** | Client-side | **Client-side (ตามที่คิด)** | ✅ ถูกต้องแล้ว - ไม่มีค่าใช้จ่าย, เร็ว |
| **Analytics** | ไม่ระบุ | **Firebase Analytics** | ฟรี, ดีที่สุดสำหรับ mobile |

### 🎨 Flutter Packages ที่แนะนำ

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  
  # Backend
  supabase_flutter: ^2.0.0
  
  # Auth
  firebase_auth: ^4.15.0
  firebase_core: ^2.24.0
  google_sign_in: ^6.1.6
  
  # AI
  google_generative_ai: ^0.2.0
  
  # MediaPipe / ML
  google_mlkit_pose_detection: ^0.11.0
  camera: ^0.10.5
  
  # UI/UX
  cached_network_image: ^3.3.0
  flutter_animate: ^4.3.0
  video_player: ^2.8.0
  
  # Analytics
  firebase_analytics: ^10.8.0
```

## 🏗️ Architecture Overview

```
Flutter App (Client)
├─ MediaPipe (On-Device Pose Detection)
├─ Gemini AI (Workout Personalization)
└─ Backend Services
   ├─ Supabase (Main Backend)
   │  ├─ PostgreSQL Database
   │  ├─ Storage (Videos/Images)
   │  └─ Row Level Security
   └─ Firebase
      ├─ Authentication (Google Sign-In)
      └─ Analytics
```

## 📊 Database Schema

ดู ARCHITECTURE.md สำหรับ SQL schema ทั้งหมด - มีตาราง users, expert_programs, workout_sessions, achievements, shop_items, quests พร้อม Row Level Security

## 🎮 Game Mode - Boss Battle Mechanics

| Pose | Function | Damage | Mana Cost | Cooldown |
|------|----------|--------|-----------|----------|
| **Punch** | โจมตีธรรมดา | 10 | 10 | 0s |
| **Uppercut** | โจมตีคริติคอล | 25 | 25 | 2s |
| **Squat** | หลบ (Dodge) | 0 | 15 | 1s |
| **Plank** | ป้องกัน (Shield) | 0 | 20 | 3s |
| **High Knee** | ฟื้นฟู Mana | 0 | 0 | 1s |

## 🚀 Development Roadmap

### Phase 1: MVP (4-6 สัปดาห์)
**Week 1-2:** Flutter setup, Firebase Auth + Supabase, Basic UI, Database schema
**Week 3-4:** MediaPipe pose detection, Boss battle mechanics, QTE system, Results page
**Week 5-6:** Onboarding flow, Level/exp system, Daily streak, Basic achievements

### Phase 2: Core Features (4-6 สัปดาห์)
**Week 7-8:** Workout Mode with MediaPipe, Exercise library, Timer, Progress tracking
**Week 9-10:** Community (view only), Program detail page, Video player, Follow system
**Week 11-12:** Gemini API integration, Personalization logic, Cache system, Fallback handling

### Phase 3: Polish (2-4 สัปดาห์)
**Week 13-14:** Shop UI, Cosmetic items, Inventory system, Quest system
**Week 15-16:** Bug fixes, Performance optimization, User testing, App store submission

## 💰 Cost Estimation

**Free Tier Limits:**
- Supabase: 500MB DB, 1GB storage → ~500 users
- Gemini AI: 15 req/min → ~1,500 users
- Firebase Auth & Analytics: Unlimited

**Expected Monthly Cost:**
- 0-500 users: **$0**
- 500-2,000 users: **$10-25** (Supabase Pro)
- 2,000+ users: **$50-100**

## 📚 Next Steps

1. **อ่านเอกสารทั้งหมด** - CONTEXT.md, ARCHITECTURE.md, ADRs
2. **Setup Project** - สร้าง Flutter project, เพิ่ม dependencies
3. **Setup Backend** - สร้าง Supabase project, import schema
4. **Implement Auth** - Firebase Auth + Google Sign-In
5. **Build MVP** - เริ่มจาก onboarding และ game mode
6. **Test on Real Devices** - ทดสอบ MediaPipe performance
7. **Deploy Beta** - TestFlight / Internal Testing

## 🆘 Common Issues & Solutions

| Problem | Solution |
|---------|----------|
| MediaPipe ช้า | ลดความละเอียดกล้อง, process fewer frames |
| Gemini API quota เกิน | Implement caching, rate limiting |
| Battery drain สูง | Optimize pose detection frequency |
| Supabase storage เต็ม | Compress images/videos before upload |

---

**เอกสารนี้ครอบคลุมทุกอย่างที่คุณต้องรู้เพื่อเริ่มสร้างแอปนี้ อ่านไฟล์แต่ละไฟล์เพื่อรายละเอียดเพิ่มเติม รวมถึง code examples ใน Dart/Flutter!** 🚀
