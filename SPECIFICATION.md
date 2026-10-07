# Product Specification: Gamified Fitness Mobile Application

**Version:** 1.0  
**Date:** 2026-09-13  
**Status:** Ready for Implementation  
**Estimated Effort:** 14-16 weeks (3 phases)

---

## Executive Summary

Build a cross-platform mobile fitness application that makes exercise engaging through gamification and AI personalization. Users battle virtual bosses using real exercise poses detected by on-device computer vision, follow AI-personalized workout programs from community experts, and progress through an RPG-style advancement system with levels, achievements, and cosmetic rewards.

**Core Value Proposition:** Transform boring exercise into fun gameplay while providing legitimate fitness guidance through AI-personalized expert programs.

---

## Project Vocabulary

All terms defined in `CONTEXT.md`. Key concepts:

- **Boss Battle**: QTE combat using exercise poses as attacks/abilities
- **Exercise Pose**: 5 tracked movements (Punch, Uppercut, Squat, Plank, High Knee)
- **Expert Program**: Community-shared workout routine with video/images/text
- **Personalized Build**: AI-customized workout based on user profile
- **Mana**: Resource system limiting pose spam during battles
- **Daily Streak**: Login counter for engagement
- **Quest**: Completable challenges rewarding exp/coins
- **Cosmetic Item**: Shop purchases (profile decorations, mascots) using earned coins

---

## User Stories

### Epic 1: Onboarding & Profile

**US-001: Google Sign-In**  
As a new user, I want to sign in with my Google account so I can start quickly without creating another password.

**Acceptance Criteria:**
- Tap "Sign in with Google" shows Google account picker
- After selection, user proceeds to welcome screen
- Firebase Auth creates auth session
- Supabase user record created with firebase_uid

**US-002: Fitness Profile Setup**  
As a new user, I want to provide my fitness information so the app can personalize workouts for me.

**Acceptance Criteria:**
- 7-step flow: Goal → Personal Info → Equipment → Time → Body Shape → Limitations → Confirmation
- Each step validates input before proceeding
- AI analyzes profile on final step (Gemini 1.5 Flash)
- Profile stored in Supabase users table
- Cannot skip required fields

### Epic 2: Game Mode (Boss Battle)

**US-003: Start Boss Battle**  
As a user, I want to fight a boss using exercise poses so working out feels like playing a game.

**Acceptance Criteria:**
- Tap Game icon → camera permission check → MediaPipe initialization
- "Get Ready" screen shows boss preview and pose controls
- Battle starts with full HP (100) and Mana (100)
- Boss HP bar and user HP/Mana bars visible
- Frame rate: 10-15 FPS pose detection

**US-004: Perform Exercise Poses**  
As a user, I want each exercise pose to have a unique combat function so I'm motivated to use all movements.

**Acceptance Criteria:**
- **Punch**: 10 damage, 10 mana, 0s cooldown
- **Uppercut**: 25 damage, 25 mana, 2s cooldown, shows critical effect
- **Squat**: dodges next attack, 15 mana, 1s cooldown
- **Plank**: shield for 3 seconds, 20 mana, 3s cooldown
- **High Knee**: restores 30 mana, free, 1s cooldown
- MediaPipe validates pose correctness before action executes
- Insufficient mana shows warning, blocks action

**US-005: Battle Victory & Results**  
As a user, I want to see my rewards after defeating a boss so I feel accomplished and track progress.

**Acceptance Criteria:**
- Boss HP reaches 0 → Victory animation
- Results page shows: exp earned, coins earned, achievements unlocked, level progress bar
- Base rewards: 100 exp, 50 coins (victory) or 50 exp, 20 coins (defeat)
- Speed bonus: +20 exp if under 5 minutes
- Variety bonus: +15 exp if 20+ poses used
- Session saved to workout_sessions table
- Tap "Continue" returns to home

### Epic 3: Workout Mode

**US-006: Follow Expert Program**  
As a user, I want to follow workout programs created by experts so I have structured guidance.

**Acceptance Criteria:**
- Tap Workout icon → check if following_program_id exists
- If null, redirect to Community to select program
- If set, load personalized_build from user record
- Show Ready page: program name, estimated duration, exercise previews
- Tap "Start" → camera permission → MediaPipe init

**US-007: Guided Workout Session**  
As a user, I want the app to track my form and count reps so I know I'm exercising correctly.

**Acceptance Criteria:**
- For each exercise: name displayed, demo video/image shown, countdown timer
- MediaPipe validates pose landmarks in real-time
- Valid rep increments counter (displayed on screen)
- Rest timer between exercises
- Progress bar shows exercises completed / total
- Can pause/resume session

**US-008: Workout Completion**  
As a user, I want to see my workout results so I know what I accomplished.

**Acceptance Criteria:**
- All exercises completed → workout summary
- Results: exercises completed, duration, exp earned, coins earned
- Exp/coins calculated: (100 * completion_rate) exp, (30 * completion_rate) coins
- Session saved with session_type='workout'
- Level up animation if exp threshold crossed

### Epic 4: Community & AI Personalization

**US-009: Browse Expert Programs**  
As a user, I want to browse workout programs from the community so I can find one that interests me.

**Acceptance Criteria:**
- Tap Community icon → paginated feed (20 programs per page)
- Sort options: Popular, Recent, Difficulty
- Each card shows: thumbnail, title, creator, difficulty, follower count
- Pull to refresh
- Tap card → program detail page

**US-010: Select & Personalize Program**  
As a user, I want the app to customize expert programs for my fitness level so workouts are appropriate for me.

**Acceptance Criteria:**
- Program detail shows: creator info, description, videos/images, exercise list
- Tap "Follow Program" → loading state "Personalizing for you..."
- Gemini API called with user profile + program exercises
- Returns adjusted durations, reps, substitutions, explanation
- Personalized build stored in user.personalized_build (JSONB)
- User.following_program_id updated
- Confirmation: "Program personalized! Ready to start?"
- Can only follow 1 program at a time (following new one replaces old)

**US-011: Post Workout Program (Expert/User)**  
As an experienced user, I want to share my workout program so others can benefit from it.

**Acceptance Criteria:**
- Tap "Share Program" from Profile → creation form
- Required: title, description, difficulty, exercises (JSONB with name/duration/reps)
- Optional: thumbnail, videos, images (uploaded to Supabase Storage)
- No approval required (posts immediately)
- Program appears in Community feed
- Creator can edit/delete own programs only

### Epic 5: Gamification & Progression

**US-012: Level Up System**  
As a user, I want to level up by earning exp so I feel a sense of progression.

**Acceptance Criteria:**
- Exp required per level: 100 * level²  (exponential)
- Level display on home page with progress bar
- Level up animation when threshold crossed
- Overflow exp carries to next level
- Level stored in users.level, updated after each session

**US-013: Daily Streak Tracking**  
As a user, I want my consecutive login days tracked so I'm motivated to return daily.

**Acceptance Criteria:**
- On app launch, check last_login_date
- If today > last_login_date + 1 day: reset streak to 1
- If today = last_login_date + 1 day: increment streak
- If today = last_login_date: no change
- Display streak prominently on home ("🔥 5 Day Streak")

**US-014: Achievements**  
As a user, I want to unlock achievements for milestones so I have long-term goals.

**Acceptance Criteria:**
- Achievements defined in achievements table (name, description, icon, unlock_criteria JSONB)
- Examples: "First Victory", "10 Day Streak", "Level 10", "100 Workouts"
- After each session, check unlock_criteria against user stats
- Newly unlocked achievements shown on Results page
- Achievement collection viewable from profile

**US-015: Shop & Cosmetics**  
As a user, I want to buy cosmetic items with earned coins so I can customize my profile.

**Acceptance Criteria:**
- Shop accessible from bottom nav
- Items paginated, filterable by type (profile_decoration, mascot_skin, mascot_accessory)
- Each item shows: image, name, price in coins
- Tap item → preview + "Purchase" button
- Purchase checks coin balance, deducts coins, adds to user_inventory
- Inventory accessible from profile
- Can equip 1 item per type at a time

### Epic 6: Quests

**US-016: Daily Quest System**  
As a user, I want daily quests so I have short-term goals beyond just leveling.

**Acceptance Criteria:**
- "Today Quest" card on home page
- Quest types: daily, weekly, special (stored in quests.quest_type)
- Requirements in JSONB (e.g., {type: 'complete_workouts', count: 3})
- Progress tracked in user_quest_progress (JSONB)
- Completion shows rewards (exp, coins from quests.rewards)
- Daily quests reset at midnight user local time
- Quest completion notification

---

## Technical Decisions

### Architecture (ADR-001)

**Decision:** Use Supabase as primary backend; Firebase only for Auth & Analytics

**Rationale:**
- PostgreSQL better for relational data (users → programs → sessions)
- Simpler than dual-backend architecture
- Row Level Security for fine-grained access control
- Free tier sufficient for MVP (500MB DB, 1GB storage)

**Auth Flow:**
1. Firebase Auth handles Google Sign-In
2. Get Firebase ID token
3. Exchange for Supabase JWT via custom auth hook
4. All data operations through Supabase client

### Pose Detection (ADR-002)

**Decision:** MediaPipe on-device processing (client-side)

**Rationale:**
- Game mode needs <100ms latency (QTE requirement)
- Network round-trip adds 200-500ms
- Privacy: no video upload
- Cost: zero server processing costs
- Works offline

**Implementation:**
- `google_mlkit_pose_detection` Flutter package
- PoseDetectionMode.stream for real-time
- Process every 3rd frame (10 FPS sufficient)
- 720p camera resolution
- Pose validation logic: check landmark angles/positions

**Minimum Device:**
- iOS 12+ (iPhone 7+)
- Android 7.0+ with ARCore
- 2GB+ RAM

### AI Personalization (ADR-003)

**Decision:** Gemini 1.5 Flash API, called from client

**Rationale:**
- Free tier: 15 req/min, 1M tokens/min
- Fast responses (1-2 seconds)
- Good JSON output for structured workout data
- Supports ~1,500 active users on free tier

**Prompt Structure:**
```
Personalize this workout program.

User Profile:
- Goal: {fitness_goal}
- Age: {age}
- Limitations: {physical_limitations}
- Equipment: {available_equipment}
- Body Shape: {body_shape}

Original Program: {exercises_json}

Return: {"exercises": [...], "explanation": "..."}
```

**Fallback:** If API unavailable, use original program with disclaimer

### State Management

**Decision:** Riverpod

**Rationale:**
- Better than Provider for complex state
- Good Flutter ecosystem support
- Suitable for: user state, workout session, camera/MediaPipe state

---

## Data Model

### Core Tables

**users**
```sql
- id (UUID, PK)
- firebase_uid (TEXT, unique)
- username (TEXT, unique)
- email (TEXT)
- level (INT, default 1)
- exp (INT, default 0)
- coins (INT, default 0)
- daily_streak (INT, default 0)
- last_login_date (DATE)
- fitness_goal, age, weight_kg, height_cm, body_shape
- physical_limitations (TEXT[])
- available_equipment (TEXT[])
- preferred_workout_time (TIME)
- following_program_id (UUID FK → expert_programs)
- personalized_build (JSONB)
```

**expert_programs**
```sql
- id (UUID, PK)
- creator_id (UUID FK → users)
- title (TEXT, required)
- description (TEXT)
- difficulty_level (TEXT: beginner|intermediate|advanced)
- duration_weeks (INT)
- exercises (JSONB)
- thumbnail_url, video_urls (TEXT[]), image_urls (TEXT[])
- followers_count (INT, default 0)
- created_at (TIMESTAMP)
```

**workout_sessions**
```sql
- id (UUID, PK)
- user_id (UUID FK → users)
- session_type (TEXT: 'game' | 'workout')
- started_at, completed_at (TIMESTAMP)
- exp_earned, coins_earned (INT)
- poses_completed (JSONB: {pose_name: count})
- boss_defeated (BOOLEAN, for game sessions)
- program_id (UUID FK → expert_programs, for workout sessions)
```

**achievements, user_achievements, shop_items, user_inventory, quests, user_quest_progress**

Full schemas in `ARCHITECTURE.md`.

### Row Level Security

```sql
-- Users see only own data
CREATE POLICY "Users view own" ON users FOR SELECT
  USING (firebase_uid = auth.uid());

-- Public read for programs
CREATE POLICY "Public programs" ON expert_programs FOR SELECT
  USING (true);

-- Creators edit own
CREATE POLICY "Creators edit own" ON expert_programs FOR UPDATE
  USING (creator_id = auth.uid());
```

---

## Testing Strategy

### Test Seams

**Seam 1: API Integration (E2E)**
- Auth: Google Sign-In → Firebase token → Supabase JWT → user record created
- Workout Session: start workout → complete → rewards calculated → database updated → UI reflects new level/coins

**Seam 2: MediaPipe Pose Detection (Integration)**
- Camera image → MediaPipe landmarks → pose validation → action triggered
- Test with recorded video files of each pose
- Validate: correct pose detected >90% accuracy, incorrect pose rejected

**Seam 3: AI Personalization (Integration)**
- User profile + Expert Program → Gemini API → JSON response → parsed → stored as personalized_build
- Test: beginner profile gets reduced reps, advanced gets increased, limitations trigger substitutions

**Seam 4: Gamification Logic (Unit)**
- Exp calculation: victory/defeat/bonuses
- Level up detection: exp threshold crossed → level increments → overflow carries
- Streak logic: date comparisons → increment/reset

**Seam 5: UI State Management (Widget)**
- Riverpod providers: user state updates → UI rebuilds
- Navigation flows: onboarding → home, game → results → home

### Test Coverage Targets

- Unit tests: gamification logic, reward calculations, level progression
- Integration tests: MediaPipe pose validation, AI API calls, database operations
- Widget tests: navigation flows, state updates
- E2E tests: complete user journeys (onboarding, first workout, boss battle)

**Minimum 70% code coverage before Phase 1 completion.**

---

## UI/UX Design Principles

### Home Page Layout
- Top: Username, daily streak badge, level progress bar
- Center: Quick action grid (Game, Workout, Community cards)
- Bottom: "Today Quest" card
- Navigation: Bottom bar (Home, Plan, Shop, Progress, Profile)
- Hamburger menu (top-left): Settings, About, Terms, Contact

### Visual Style
- Use `flutter_animate` for level-ups, achievements
- `cached_network_image` for all remote images
- Material Design 3 components
- Light mode primary (can add dark mode in Phase 3)

### Camera/Pose View
- Full-screen camera feed
- Overlay: HP/Mana bars (game), Rep counter (workout)
- Pose prompt at top
- MediaPipe skeleton overlay (optional debug mode)

---

## Performance Requirements

| Metric | Target | Measurement |
|--------|--------|-------------|
| Pose detection latency | <50ms | 95th percentile |
| Frame processing rate | 10-15 FPS | Average during session |
| Battery drain | <15% per 30min | Measured on reference devices |
| App launch time | <3 seconds | Cold start |
| AI personalization | <5 seconds | API call + parse |
| Community feed load | <2 seconds | Initial 20 items |

### Optimizations
- Process every 3rd camera frame
- 720p camera resolution
- Image compression: 5MB video max, 1MB image max
- Database pagination: 20 items per page
- Implement frame skipping if processing backlog builds

---

## Security & Privacy

### Data Protection
- No video data leaves device (MediaPipe on-device only)
- User exercise videos never stored on server
- Supabase RLS enforces access control
- Gemini API key in Firebase Remote Config (not in app bundle)

### API Security
- Firebase App Check prevents API abuse
- Rate limiting: 1 AI personalization per 5 seconds per user
- Supabase RLS policies prevent unauthorized data access

### Content Moderation
- Report button on all community posts
- Profanity filter for usernames/descriptions
- Manual review queue for flagged content (Phase 3)

---

## Deployment Plan

### Phase 1: MVP (Weeks 1-6)
**Deliverables:**
- ✅ Firebase Auth + Supabase integration
- ✅ Onboarding flow (7 steps)
- ✅ Game mode: 1 boss, 5 poses, MediaPipe, QTE mechanics
- ✅ Results page with rewards
- ✅ Basic home page
- ✅ Level/exp system
- ✅ Daily streak tracking

**Success Criteria:**
- User can sign in, complete onboarding, fight boss, earn exp/coins, level up
- MediaPipe pose detection works on target devices
- No crashes during core flows

### Phase 2: Core Features (Weeks 7-12)
**Deliverables:**
- ✅ Workout mode with MediaPipe tracking
- ✅ Community feed (view only)
- ✅ AI personalization (Gemini integration)
- ✅ Program follow system
- ✅ Shop with cosmetic items
- ✅ Achievement system
- ✅ Quest system

**Success Criteria:**
- User can browse programs, personalize, complete workout
- AI personalization success rate >95%
- Shop purchases work correctly
- Achievements unlock appropriately

### Phase 3: Polish & Launch (Weeks 13-16)
**Deliverables:**
- ✅ Community posting (users can share programs)
- ✅ Multiple bosses (at least 3)
- ✅ Advanced quests
- ✅ Progress analytics page
- ✅ Bug fixes from user testing
- ✅ Performance optimization
- ✅ App store assets & submission

**Success Criteria:**
- Beta testing with 50+ users
- Performance targets met
- No critical bugs
- App store approval

---

## Cost Estimation & Scaling

### Free Tier Capacity
- **Supabase:** 500MB DB, 1GB storage, 2GB bandwidth → ~100-500 users
- **Gemini AI:** 15 req/min → ~1,500 users (assuming 1-2 personalizations per week)
- **Firebase Auth:** Unlimited
- **Firebase Analytics:** Unlimited

### Scaling Costs
| User Count | Monthly Cost | Upgrades Needed |
|------------|--------------|-----------------|
| 0-500 | $0 | None (free tier) |
| 500-2,000 | $10-25 | Supabase Pro |
| 2,000-5,000 | $50-100 | + caching, optimize queries |
| 5,000+ | $150-300 | Consider server-side AI proxy, CDN |

### Cost Control Measures
- Cache AI personalizations (don't regenerate on every view)
- Compress media uploads
- Implement pagination everywhere
- Monitor Gemini quota, add circuit breaker

---

## Out of Scope (Explicitly Excluded)

The following are **NOT** included in this specification:

❌ **Real-time multiplayer boss battles** - Increases complexity significantly; consider for v2.0

❌ **Video recording of workouts** - Privacy concerns, storage costs; stick to pose tracking only

❌ **Integration with wearable devices** (Apple Watch, Fitbit) - Future enhancement

❌ **Social features beyond community** - No friends list, no direct messaging, no social feed

❌ **Custom workout program builder** - Users can only follow existing programs or share their own in freeform

❌ **Nutrition tracking** - Focus purely on exercise

❌ **Payment/subscription system** - All monetization is in-app coins only (no real money)

❌ **Multiple languages** - Launch in English/Thai only

❌ **Offline mode for AI personalization** - Requires network for Gemini API

❌ **Advanced pose corrections/coaching** - Only validates if pose is correct, doesn't provide form feedback

❌ **Progress comparison with friends** - No social comparison features

❌ **Push notifications** - In-app notifications only for MVP

❌ **Dark mode** - Light mode only for MVP

---

## Dependencies & Prerequisites

### External Services
- Firebase project created with Auth & Analytics enabled
- Supabase project created, database schema imported
- Gemini API key obtained (Google AI Studio)
- Google Sign-In configured for iOS & Android

### Development Environment
- Flutter SDK 3.x
- Xcode (iOS development)
- Android Studio (Android development)
- Supabase CLI (database migrations)

### Third-Party Packages
See `pubspec.yaml` in implementation docs:
- `flutter_riverpod` (state management)
- `supabase_flutter` (database)
- `firebase_auth`, `google_sign_in` (auth)
- `google_generative_ai` (AI)
- `google_mlkit_pose_detection` (MediaPipe)
- `camera`, `video_player`, `cached_network_image`

---

## Success Metrics

### Phase 1 (MVP) Metrics
- **User Activation:** 70% complete onboarding flow
- **Retention D1:** 50% return next day
- **Boss Battle Completion:** 60% defeat first boss
- **Technical:** <5% crash rate, <50ms pose detection latency

### Phase 2 Metrics
- **Program Adoption:** 50% follow at least 1 Expert Program
- **AI Success:** 95% personalizations complete without error
- **Workout Completion:** 40% complete first personalized workout
- **Retention D7:** 30% active after 1 week

### Phase 3 (Launch) Metrics
- **DAU/MAU:** 20% (daily actives / monthly actives)
- **Session Length:** Avg 15+ minutes per session
- **Monetization:** 10% purchase at least 1 cosmetic item
- **Retention D30:** 15% active after 1 month

---

## Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| MediaPipe accuracy <90% | High | Medium | Test on diverse body types, adjust thresholds, provide manual override |
| Gemini API quota exceeded | Medium | Low | Implement caching, rate limiting, fallback to non-personalized |
| Battery drain too high | Medium | Medium | Optimize frame processing, lower resolution, add battery warning |
| Supabase free tier exceeded early | Low | Low | Monitor usage, optimize queries, upgrade if needed |
| Device compatibility issues | High | Medium | Define minimum specs clearly, test on range of devices |
| Content moderation challenges | Medium | Medium | Implement report mechanism, plan manual review process |

---

## Appendices

### A. Related Documents
- `CONTEXT.md` - Domain vocabulary reference
- `ARCHITECTURE.md` - Full technical architecture, data schemas, code examples
- `docs/adr/` - Architectural Decision Records (001: Supabase, 002: MediaPipe, 003: Gemini)
- `README-IMPLEMENTATION.md` - Development roadmap, package list, troubleshooting

### B. Open Questions
None. All major decisions resolved during design phase.

### C. Change Log
- 2026-09-13 v1.0: Initial specification created from design documents

---

**This specification represents all decisions made during the design phase. Ready for breakdown into implementation tickets.**
