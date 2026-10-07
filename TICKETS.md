# Implementation Tickets Breakdown

**Project:** Gamified Fitness Mobile Application  
**Total Tickets:** 18 vertical slices (tracer bullets)  
**Phases:** 3 (MVP, Core Features, Polish)

---

## Ticket Breakdown

### Phase 1: MVP Foundation (Tickets 01-08)

#### 01. Project Setup & Infrastructure
**Type:** Setup  
**Blocked by:** None  
**Estimated Effort:** 1-2 days

**Description:**
Set up Flutter project with all dependencies, Firebase/Supabase configuration, and database schema.

**Tasks:**
- Create Flutter project with proper folder structure
- Add all required packages to pubspec.yaml (Riverpod, Supabase, Firebase, MediaPipe, etc.)
- Configure Firebase project (Auth, Analytics)
- Configure Supabase project
- Create database schema: users, expert_programs, workout_sessions, achievements, shop_items, quests tables
- Implement Row Level Security policies
- Set up Riverpod providers structure
- Create base navigation structure (bottom nav bar)

**Acceptance Criteria:**
- [ ] Flutter app runs on iOS & Android
- [ ] Firebase Auth configured with Google Sign-In enabled
- [ ] Supabase database created with all tables
- [ ] RLS policies applied and tested
- [ ] App compiles without errors
- [ ] Basic navigation works (can switch between tabs)

**Demo Path:** Run app → sees placeholder screens for each tab → navigation works

---

#### 02. Google Sign-In & User Record Creation
**Type:** Feature (Vertical Slice)  
**Blocked by:** 01  
**Estimated Effort:** 2-3 days

**Description:**
Complete authentication flow from Google Sign-In through user record creation in Supabase.

**Tasks:**
- Create login screen UI
- Implement Firebase Google Sign-In
- Create Supabase auth hook to exchange Firebase token for Supabase JWT
- Create user record in Supabase on first sign-in
- Implement auth state management with Riverpod
- Create welcome screen
- Handle auth errors gracefully

**Acceptance Criteria:**
- [ ] Tap "Sign in with Google" shows Google account picker
- [ ] After selection, Firebase auth session created
- [ ] Supabase user record created with firebase_uid
- [ ] User proceeds to welcome screen
- [ ] Auth state persists across app restarts
- [ ] Error handling for network failures

**Demo Path:** Launch app → tap "Sign in with Google" → select account → see welcome screen → restart app → still logged in

---

#### 03. Onboarding Flow (7-Step Profile Setup)
**Type:** Feature (Vertical Slice)  
**Blocked by:** 02  
**Estimated Effort:** 3-4 days

**Description:**
Complete onboarding journey with all 7 steps, validation, and profile storage.

**Tasks:**
- Create 7 onboarding screens:
  1. Fitness goal selection (lose weight, build muscle, stay fit, etc.)
  2. Personal info (age, weight, height)
  3. Equipment selection (dumbbells, resistance bands, none, etc.)
  4. Preferred workout time
  5. Body shape selection
  6. Physical limitations (knee issues, back pain, etc.)
  7. Confirmation & analysis
- Implement validation for each step
- Create progress indicator
- Store profile data to Supabase users table
- Implement Gemini API mock call (actual integration in later ticket)
- Navigate to home page after completion

**Acceptance Criteria:**
- [ ] All 7 steps display correctly
- [ ] Cannot proceed without completing required fields
- [ ] Progress indicator shows current step
- [ ] Profile data saves to Supabase
- [ ] After completion, navigates to home page
- [ ] Back button works between steps

**Demo Path:** Complete sign-in → go through all 7 steps → submit → profile saved → see home page

---

#### 04. Home Page with Gamification Stats
**Type:** Feature (Vertical Slice)  
**Blocked by:** 03  
**Estimated Effort:** 2-3 days

**Description:**
Build home page displaying user stats (level, exp, coins, daily streak) and action buttons.

**Tasks:**
- Create home page UI layout
- Display username from Supabase
- Show level with progress bar (exp / required_exp)
- Display coins and daily streak
- Create action cards (Game, Workout, Community - placeholders for now)
- Implement daily streak logic (check last_login_date, update on launch)
- Create Riverpod provider for user stats
- Add hamburger menu (placeholder items)
- Add notification icon (placeholder)

**Acceptance Criteria:**
- [ ] Home page displays username
- [ ] Shows level with progress bar
- [ ] Displays current exp, coins, daily streak
- [ ] Action cards render (even if non-functional)
- [ ] Daily streak increments on consecutive logins
- [ ] Streak resets if >1 day gap
- [ ] Bottom navigation works

**Demo Path:** Login → see home page with stats → logout → login next day → streak incremented → wait 2 days → login → streak reset

---

#### 05. MediaPipe Pose Detection Foundation
**Type:** Infrastructure  
**Blocked by:** 01  
**Estimated Effort:** 3-4 days

**Description:**
Implement MediaPipe integration with camera, pose landmark detection, and validation logic for all 5 poses.

**Tasks:**
- Request and handle camera permissions
- Initialize MediaPipe PoseDetector
- Create camera preview widget
- Implement pose landmark processing (process every 3rd frame)
- Create pose validation logic for:
  - Punch (arm extension, wrist forward)
  - Uppercut (arm upward motion, elbow angle)
  - Squat (knee bend angle, hip position)
  - Plank (body parallel, elbow alignment)
  - High Knee (knee height, balance)
- Create pose detection service
- Add debug overlay showing skeleton landmarks
- Handle device capability check

**Acceptance Criteria:**
- [ ] Camera permission requested and handled
- [ ] Camera preview displays correctly
- [ ] MediaPipe detects pose landmarks at 10-15 FPS
- [ ] Each of 5 poses can be validated (>90% accuracy with test videos)
- [ ] Debug skeleton overlay toggleable
- [ ] Works on minimum device specs (iPhone 7+, Android 7.0+)
- [ ] Graceful degradation on unsupported devices

**Demo Path:** Launch → grant camera → see camera feed → perform each pose → debug overlay shows correct detection

---

#### 06. Boss Battle - Core Game Loop
**Type:** Feature (Vertical Slice)  
**Blocked by:** 04, 05  
**Estimated Effort:** 4-5 days

**Description:**
Complete boss battle from start to results, including pose-based combat, HP/mana management, and victory/defeat logic.

**Tasks:**
- Create boss battle screen UI (HP bars, mana bar, boss sprite)
- Implement "Get Ready" screen
- Create boss battle state machine (ready, fighting, victory, defeat)
- Implement pose action system:
  - Punch: 10 damage, 10 mana cost
  - Uppercut: 25 damage, 25 mana cost, 2s cooldown, critical effect
  - Squat: dodge, 15 mana cost, 1s cooldown
  - Plank: shield (3s duration), 20 mana cost, 3s cooldown
  - High Knee: restore 30 mana, 1s cooldown
- Implement mana consumption/regeneration
- Create boss AI (simple counter-attack pattern)
- Handle cooldowns per pose
- Implement victory/defeat conditions
- Add battle animations

**Acceptance Criteria:**
- [ ] Tap "Game" → camera permission → "Get Ready" screen
- [ ] Battle starts with 100 HP, 100 Mana (user) and boss HP
- [ ] Each pose performs correct action when detected
- [ ] Mana decreases on use, blocks action if insufficient
- [ ] Cooldowns prevent pose spam
- [ ] Boss counter-attacks
- [ ] Victory when boss HP → 0
- [ ] Defeat when user HP → 0
- [ ] Battle state updates in real-time

**Demo Path:** Tap Game → get ready → start → perform poses → deal damage → boss counter-attacks → defeat boss → see victory

---

#### 07. Results Page & Reward System
**Type:** Feature (Vertical Slice)  
**Blocked by:** 06  
**Estimated Effort:** 2-3 days

**Description:**
Display post-battle/workout results with rewards calculation, exp/coins earned, and level progression.

**Tasks:**
- Create results page UI
- Implement reward calculation logic:
  - Base: 100 exp, 50 coins (victory) or 50 exp, 20 coins (defeat)
  - Speed bonus: +20 exp if <5 minutes
  - Variety bonus: +15 exp if 20+ poses used
- Implement level-up detection (exp ≥ 100 * level²)
- Create level-up animation
- Save workout_session to Supabase
- Update user exp, coins, level in database
- Display achievements unlocked (if any)
- "Continue" button returns to home
- Handle exp overflow to next level

**Acceptance Criteria:**
- [ ] After battle/workout, results page displays
- [ ] Shows exp earned, coins earned
- [ ] Calculates bonuses correctly
- [ ] Level-up animation triggers when threshold crossed
- [ ] Session saved to workout_sessions table
- [ ] User stats updated in Supabase
- [ ] Tap "Continue" → home page with updated stats
- [ ] Overflow exp carries to next level

**Demo Path:** Complete battle → see results → exp/coins displayed → level up animation (if applicable) → tap Continue → home shows new stats

---

#### 08. Basic Achievement System
**Type:** Feature (Vertical Slice)  
**Blocked by:** 07  
**Estimated Effort:** 2-3 days

**Description:**
Achievement checking, unlocking, and display on results page and profile.

**Tasks:**
- Seed achievements table with initial achievements:
  - "First Victory" (win first boss battle)
  - "First Workout" (complete first workout)
  - "Getting Started" (reach level 2)
  - "Dedicated" (5 day streak)
- Implement achievement checker service
- Check unlock criteria after each session
- Display newly unlocked achievements on results page
- Create achievement collection view in profile
- Add achievement badges/icons

**Acceptance Criteria:**
- [ ] Achievements table seeded with at least 4 achievements
- [ ] After each session, unlock criteria checked
- [ ] Newly unlocked achievements shown on results page
- [ ] Achievement collection viewable from profile
- [ ] Each achievement has name, description, icon
- [ ] user_achievements records created correctly

**Demo Path:** Win first battle → results show "First Victory" unlocked → view profile → see achievement in collection

---

### Phase 2: Core Features (Tickets 09-14)

#### 09. Community Feed (Read-Only)
**Type:** Feature (Vertical Slice)  
**Blocked by:** 04  
**Estimated Effort:** 3-4 days

**Description:**
Browse expert programs from community with pagination, sorting, and detail view.

**Tasks:**
- Create community feed UI (paginated, 20 per page)
- Implement expert_programs query with pagination
- Add sort options: Popular, Recent, Difficulty
- Create program card component (thumbnail, title, creator, difficulty, followers)
- Implement pull-to-refresh
- Create program detail page (creator info, description, videos/images, exercise list)
- Add back navigation
- Seed database with 3-5 sample expert programs

**Acceptance Criteria:**
- [ ] Tap "Community" → feed loads with programs
- [ ] Shows 20 programs per page
- [ ] Sort by Popular/Recent/Difficulty works
- [ ] Pull to refresh reloads feed
- [ ] Tap program card → detail page
- [ ] Detail shows all program info
- [ ] Back button returns to feed

**Demo Path:** Tap Community → see programs → sort by difficulty → tap one → see details → back → scroll → load more

---

#### 10. AI Personalization & Program Following
**Type:** Feature (Vertical Slice)  
**Blocked by:** 09  
**Estimated Effort:** 3-4 days

**Description:**
Complete flow from selecting expert program to AI personalization to following.

**Tasks:**
- Implement Gemini 1.5 Flash API integration
- Create personalization service (user profile + program → API call → parse response)
- Add "Follow Program" button on program detail
- Show loading state "Personalizing for you..."
- Store personalized_build (JSONB) in user record
- Update following_program_id
- Show confirmation dialog
- Implement API error handling & fallback (use original program)
- Add caching (don't re-personalize if already done)
- Ensure only 1 program followed at a time (replace old)

**Acceptance Criteria:**
- [ ] Tap "Follow Program" → loading state
- [ ] Gemini API called with correct prompt
- [ ] Returns personalized JSON (adjusted reps/durations/substitutions)
- [ ] personalized_build saved to user record
- [ ] following_program_id updated
- [ ] Confirmation shown: "Program personalized! Ready to start?"
- [ ] Following new program replaces old one
- [ ] Fallback works if API fails

**Demo Path:** Browse community → select program → tap "Follow Program" → see loading → personalization complete → confirmation shown

---

#### 11. Workout Mode - Guided Session
**Type:** Feature (Vertical Slice)  
**Blocked by:** 05, 10  
**Estimated Effort:** 4-5 days

**Description:**
Complete workout session flow with MediaPipe tracking, rep counting, and exercise progression.

**Tasks:**
- Check if user has following_program_id (redirect to community if null)
- Load personalized_build from user record
- Create "Ready" page (program name, duration, exercise previews)
- Create workout session screen with:
  - Exercise name display
  - Demo video/image
  - Countdown timer
  - Rep counter
  - Rest timer between exercises
  - Progress bar (exercises completed / total)
  - Pause/resume functionality
- Integrate MediaPipe for pose validation
- Count valid reps only
- Navigate through exercise sequence
- Trigger results page on completion

**Acceptance Criteria:**
- [ ] Tap "Workout" → checks following_program_id
- [ ] If null, redirects to Community
- [ ] If set, shows Ready page
- [ ] Tap "Start" → camera permission → MediaPipe init
- [ ] Each exercise displays correctly
- [ ] MediaPipe validates poses, counts reps
- [ ] Rest timer between exercises
- [ ] Progress bar updates
- [ ] Can pause/resume
- [ ] Completion triggers results page

**Demo Path:** Follow program → tap Workout → Ready page → Start → complete exercises → rest periods → finish → see results

---

#### 12. Workout Results & Session Saving
**Type:** Feature (Vertical Slice)  
**Blocked by:** 11  
**Estimated Effort:** 2 days

**Description:**
Display workout results, calculate rewards based on completion rate, and save session.

**Tasks:**
- Calculate completion rate (exercises done / total)
- Calculate rewards: (100 * completion_rate) exp, (30 * completion_rate) coins
- Display results: exercises completed, duration, exp, coins
- Save workout_session with session_type='workout'
- Update user exp/coins
- Check for level-up
- Check for achievement unlocks
- Return to home

**Acceptance Criteria:**
- [ ] After workout, results display
- [ ] Shows exercises completed, total duration
- [ ] Exp/coins calculated correctly based on completion rate
- [ ] Session saved with session_type='workout'
- [ ] User stats updated
- [ ] Level-up animation if threshold crossed
- [ ] Achievement checks run
- [ ] Tap "Continue" → home

**Demo Path:** Complete workout → see results → exp/coins match completion → level up (if applicable) → home updated

---

#### 13. Shop & Cosmetic Items
**Type:** Feature (Vertical Slice)  
**Blocked by:** 07  
**Estimated Effort:** 3-4 days

**Description:**
Shop UI, cosmetic purchasing with coins, and inventory management.

**Tasks:**
- Seed shop_items table with cosmetic items (at least 10)
- Create shop screen UI (paginated, filterable by type)
- Display items: image, name, price in coins
- Implement item detail/preview
- Create purchase flow:
  - Check coin balance
  - Deduct coins
  - Add to user_inventory
  - Show success message
- Create inventory view in profile
- Implement equip/unequip (1 item per type at a time)
- Handle insufficient coins error

**Acceptance Criteria:**
- [ ] Tap "Shop" → items display
- [ ] Filter by type works (profile_decoration, mascot_skin, mascot_accessory)
- [ ] Tap item → preview + "Purchase" button
- [ ] Purchase checks balance
- [ ] Coins deducted, item added to inventory
- [ ] Insufficient coins shows error
- [ ] Inventory viewable from profile
- [ ] Can equip/unequip items
- [ ] Only 1 item per type equipped at a time

**Demo Path:** Earn coins → tap Shop → browse → purchase item → coins deducted → view profile → see item in inventory → equip

---

#### 14. Quest System
**Type:** Feature (Vertical Slice)  
**Blocked by:** 07  
**Estimated Effort:** 3-4 days

**Description:**
Daily quest display, progress tracking, completion detection, and rewards.

**Tasks:**
- Seed quests table with daily/weekly quests
- Create quest service to fetch active quest
- Display "Today Quest" card on home page
- Show quest requirements & progress
- Implement progress tracking in user_quest_progress (JSONB)
- Check quest completion after each session
- Show quest completion notification
- Award quest rewards (exp, coins)
- Reset daily quests at midnight (user local time)
- Create quest history view

**Acceptance Criteria:**
- [ ] "Today Quest" card displays on home
- [ ] Shows quest requirements (e.g., "Complete 3 workouts")
- [ ] Progress updates after each session
- [ ] Completion detected correctly
- [ ] Rewards granted (exp, coins)
- [ ] Completion notification shown
- [ ] Daily quests reset at midnight
- [ ] Quest history viewable

**Demo Path:** See quest on home → complete workout → progress updates → complete quest → see completion notification → rewards added

---

### Phase 3: Polish & Enhancement (Tickets 15-18)

#### 15. Community Posting (User-Generated Content)
**Type:** Feature (Vertical Slice)  
**Blocked by:** 09  
**Estimated Effort:** 3-4 days

**Description:**
Allow users to create and share their own workout programs.

**Tasks:**
- Add "Share Program" button on profile
- Create program creation form:
  - Title, description, difficulty (required)
  - Exercise list builder (name, duration, reps)
  - Thumbnail, videos, images upload to Supabase Storage
- Implement image/video compression
- Save to expert_programs table with creator_id
- Add to community feed immediately (no approval)
- Implement edit/delete for own programs only (RLS policy)
- Add "My Programs" section in profile

**Acceptance Criteria:**
- [ ] Tap "Share Program" → creation form
- [ ] Can add exercises with name/duration/reps
- [ ] Can upload thumbnail, videos, images
- [ ] Required fields validated
- [ ] Posts immediately to community
- [ ] Appears in feed
- [ ] Creator can edit/delete own programs
- [ ] Cannot edit others' programs
- [ ] "My Programs" shows user's created programs

**Demo Path:** Tap Share → fill form → add exercises → upload media → submit → appears in community → edit own program → delete

---

#### 16. Progress Analytics Page
**Type:** Feature (Vertical Slice)  
**Blocked by:** 12  
**Estimated Effort:** 2-3 days

**Description:**
View workout history, statistics, and progress over time.

**Tasks:**
- Create progress page UI
- Query workout_sessions for user
- Display statistics:
  - Total sessions (game + workout)
  - Total exp earned
  - Total coins earned
  - Most used poses
  - Workout completion rate
  - Weekly activity chart
- Add date range filter
- Create session history list (tap to see details)
- Add charts (line chart for weekly activity)

**Acceptance Criteria:**
- [ ] Tap "Progress" → statistics display
- [ ] Shows total sessions, exp, coins
- [ ] Most used poses calculated correctly
- [ ] Weekly activity chart renders
- [ ] Session history list shows all past sessions
- [ ] Tap session → see details
- [ ] Date range filter works

**Demo Path:** Complete sessions → tap Progress → see stats → view charts → browse history → filter by date

---

#### 17. Multiple Bosses & Boss Selection
**Type:** Feature (Vertical Slice)  
**Blocked by:** 06  
**Estimated Effort:** 2-3 days

**Description:**
Add 2 additional bosses (total 3) with boss selection screen.

**Tasks:**
- Create 2 additional boss sprites/images
- Define boss stats (HP, attack patterns) for each
- Create boss selection screen (shows 3 bosses)
- Each boss unlocked by user level:
  - Boss 1: Level 1+
  - Boss 2: Level 5+
  - Boss 3: Level 10+
- Display locked bosses with unlock requirements
- Store selected boss in session state
- Update boss battle to use selected boss stats

**Acceptance Criteria:**
- [ ] Tap Game → boss selection screen
- [ ] Shows 3 bosses
- [ ] Boss 1 always unlocked
- [ ] Boss 2 locked until level 5
- [ ] Boss 3 locked until level 10
- [ ] Can select unlocked boss
- [ ] Battle uses selected boss stats
- [ ] Different boss sprites display correctly

**Demo Path:** Tap Game → see 3 bosses → Boss 2/3 locked → select Boss 1 → battle → reach level 5 → Boss 2 unlocks

---

#### 18. Performance Optimization & Bug Fixes
**Type:** Polish  
**Blocked by:** All previous tickets  
**Estimated Effort:** 3-5 days

**Description:**
Final polish pass, performance optimization, bug fixes, and launch preparation.

**Tasks:**
- Optimize MediaPipe frame processing (ensure 10-15 FPS)
- Optimize database queries (add indexes if needed)
- Implement image caching for community feed
- Add loading states everywhere
- Handle edge cases and errors gracefully
- Test on multiple devices (iOS & Android, old & new)
- Fix any reported bugs from testing
- Add analytics events (Firebase Analytics)
- Prepare app store assets (screenshots, description)
- Write release notes

**Acceptance Criteria:**
- [ ] MediaPipe maintains 10-15 FPS on target devices
- [ ] No memory leaks
- [ ] All loading states present
- [ ] Error handling covers edge cases
- [ ] Tested on min spec devices (iPhone 7, Android 7.0)
- [ ] Crash rate <5%
- [ ] All critical bugs fixed
- [ ] App store assets ready
- [ ] Analytics tracking implemented

**Demo Path:** Full user journey from sign-up → onboarding → battle → workout → shop → no crashes → smooth performance

---

## Dependency Visualization

```
01 (Setup)
├─ 02 (Auth)
│  └─ 03 (Onboarding)
│     └─ 04 (Home Page)
│        ├─ 06 (Boss Battle) [needs 05]
│        │  └─ 07 (Results)
│        │     ├─ 08 (Achievements)
│        │     ├─ 13 (Shop)
│        │     └─ 14 (Quests)
│        └─ 09 (Community)
│           └─ 10 (AI Personalization)
│              └─ 11 (Workout Mode) [needs 05]
│                 └─ 12 (Workout Results)
│                    └─ 16 (Progress Analytics)
├─ 05 (MediaPipe) [parallel to 02-04]
│  ├─ 06 (Boss Battle) [needs 04]
│  └─ 11 (Workout Mode) [needs 10]
└─ 15 (Community Posting) [needs 09]
   └─ 17 (Multiple Bosses) [needs 06]
      └─ 18 (Polish) [needs all]
```

---

## Frontier (Ready to Start)

**Tickets with no blockers:**
- **01**: Project Setup & Infrastructure

**After 01 completes:**
- **02**: Google Sign-In (depends on 01)
- **05**: MediaPipe Foundation (depends on 01)

These tickets can be worked in parallel after ticket 01.

---

## Summary

- **Total Tickets:** 18
- **Phase 1 (MVP):** Tickets 01-08 (Weeks 1-6)
- **Phase 2 (Core):** Tickets 09-14 (Weeks 7-12)
- **Phase 3 (Polish):** Tickets 15-18 (Weeks 13-16)
- **Parallel Work Opportunities:** Tickets 02-04 can run parallel to ticket 05
- **Critical Path:** 01 → 02 → 03 → 04 → 06 (needs 05) → 07 → ... → 18

Each ticket is a **vertical slice** that delivers demoable functionality across all layers (UI, logic, database, tests).
