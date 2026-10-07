# Architecture Design - Gamified Fitness Application

## Executive Summary

This document outlines the technical architecture for a Flutter-based gamified fitness application that uses MediaPipe for pose detection, AI for workout personalization, and a community-driven content model.

## Tech Stack Recommendations

### ✅ Recommended Stack

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| **Frontend** | Flutter | Cross-platform, good camera/ML integration |
| **Authentication** | Firebase Auth | Easy Google Sign-In, free tier generous |
| **Primary Database** | Supabase (PostgreSQL) | Better for structured user data, real-time subscriptions, free tier sufficient |
| **File Storage** | Supabase Storage | Integrated with database, 1GB free |
| **Hosting (if needed)** | Firebase Hosting | Free for static assets, global CDN |
| **Pose Detection** | MediaPipe (on-device) | Privacy-friendly, no server costs, low latency |
| **AI Service** | Gemini 1.5 Flash | Free tier: 15 req/min, good for personalization tasks |
| **Analytics** | Firebase Analytics | Free, good mobile integration |

### 🔄 Alternative to Current Plan

**Your original plan:**
- Firebase for server/hosting
- Supabase for user data

**Recommended change:**
- **Use Supabase as primary backend** (database + storage + auth)
- **Use Firebase only for** analytics and optional push notifications
- **Why?** Simpler architecture, one main backend, Supabase has better relational data handling for complex user profiles and community content

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                       │
│  ┌────────────┐  ┌─────────────┐  ┌──────────────────────┐ │
│  │ Game Mode  │  │Workout Mode │  │   Community Feed     │ │
│  │ (Boss      │  │ (Expert     │  │   (Browse/Post       │ │
│  │  Battle)   │  │  Programs)  │  │    Programs)         │ │
│  └────────────┘  └─────────────┘  └──────────────────────┘ │
│         │               │                     │              │
│         └───────────────┴─────────────────────┘              │
│                         │                                    │
│              ┌──────────▼──────────┐                        │
│              │   MediaPipe Layer   │                        │
│              │  (Pose Detection)   │                        │
│              │   • On-Device       │                        │
│              │   • Real-time       │                        │
│              └─────────────────────┘                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
┌──────────────────┐ ┌────────────┐ ┌─────────────────┐
│ Supabase Backend │ │  Gemini AI │ │Firebase Services│
│ ┌──────────────┐ │ │  (Flash)   │ │  ┌────────────┐ │
│ │ PostgreSQL   │ │ │            │ │  │ Analytics  │ │
│ │   Database   │ │ │ Workout    │ │  │            │ │
│ │              │ │ │Personaliza-│ │  │ Auth       │ │
│ │ • Users      │ │ │   tion     │ │  │ (Google    │ │
│ │ • Programs   │ │ │            │ │  │  Sign-In)  │ │
│ │ • Progress   │ │ │ Community  │ │  └────────────┘ │
│ │ • Community  │ │ │ Content    │ │                 │
│ └──────────────┘ │ │ Analysis   │ │                 │
│                  │ │            │ │                 │
│ ┌──────────────┐ │ └────────────┘ │                 │
│ │   Storage    │ │                │                 │
│ │              │ │                │                 │
│ │ • Videos     │ │                │                 │
│ │ • Images     │ │                │                 │
│ │ • Avatars    │ │                │                 │
│ └──────────────┘ │                │                 │
└──────────────────┘                └─────────────────┘
```

## Data Model

[ดูไฟล์ฉบับเต็มใน ARCHITECTURE.md สำหรับ Database Schema ทั้งหมด]

### Core Tables:
- users (profiles, gamification, onboarding data)
- expert_programs (community workout programs)
- workout_sessions (game & workout history)
- achievements & user_achievements
- shop_items & user_inventory
- quests & user_quest_progress

## Application Flow Architecture

### 1. Onboarding Flow
App Launch → Auth Check → Google Sign-In → Welcome → Fitness Goals → Personal Info → Equipment → Time → Body Shape → Limitations → AI Analysis → Home

### 2. Game Mode Flow
Game Icon → Camera Permission → MediaPipe Init → Boss Battle (QTE) → Results → Home

### 3. Workout Mode Flow
Workout Icon → Check Program → Load Personalized Build → Ready → MediaPipe Tracking → Results → Home

### 4. Community Flow
Community Icon → Browse Programs → Select → AI Personalization → Follow → Home

## AI Integration Architecture

**Client-Side AI Flow:**
- User selects Expert Program
- App calls Gemini 1.5 Flash API
- AI personalizes based on user profile
- Store in personalized_build field
- Display to user

**Free AI Service: Gemini 1.5 Flash**
- 15 requests/min (free tier)
- Fast responses (<2 seconds)
- Good for JSON output
- Supports ~1,500 users on free tier

## MediaPipe Implementation

**On-Device Processing:**
- Privacy-friendly (no video upload)
- Low latency (30-50ms per frame)
- Zero server costs
- Works offline

**Optimizations:**
- Process every 3rd frame
- 720p camera resolution
- Frame skipping during backlog

## Performance Considerations

- Index frequently queried database fields
- Implement pagination (20 items/page)
- Cache images with cached_network_image
- Compress uploads (5MB video, 1MB images)

## Security

**Row Level Security (Supabase):**
- Users see only their own data
- Anyone can view programs
- Only creators can edit their programs

**API Key Security:**
- Store Gemini key in Firebase Remote Config
- Enable Firebase App Check
- Implement rate limiting

## Deployment Strategy

**Phase 1 (MVP):** Auth, Onboarding, Game Mode, MediaPipe, Results
**Phase 2 (Core):** Workout Mode, Community (view), Shop, Achievements
**Phase 3 (Enhancement):** AI Personalization, Community Posting, Quests

## Cost Estimation

| Service | Free Tier | Expected Usage |
|---------|-----------|----------------|
| Supabase | 500MB DB, 1GB storage | ~100-500 users |
| Firebase Auth | Unlimited | All users |
| Gemini Flash | 15 req/min | ~1-2 per personalization |
| Firebase Analytics | Unlimited | All tracking |

**Estimated Monthly Cost:**
- 0-500 users: **$0**
- 500-2,000 users: **$10-25**
- 2,000+ users: **$50-100**

---

**อ่านไฟล์ README-IMPLEMENTATION.md สำหรับรายละเอียดเพิ่มเติม รวมถึง code examples และ development roadmap**
