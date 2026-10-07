# Fitness Game App

A gamified fitness mobile application that makes exercise engaging through AI personalization and game mechanics.

## Features

- 🎮 **Game Mode**: Battle virtual bosses using real exercise poses
- 💪 **Workout Mode**: Follow AI-personalized workout programs
- 👥 **Community**: Browse and share expert programs
- 🏆 **Gamification**: Levels, achievements, daily streaks, quests
- 🛍️ **Shop**: Cosmetic items and customization
- 📊 **Progress Tracking**: Detailed analytics and history

## Tech Stack

- **Framework**: Flutter 3.0+
- **State Management**: Riverpod
- **Backend**: Supabase (PostgreSQL)
- **Authentication**: Firebase Auth (Google Sign-In)
- **AI**: Gemini 1.5 Flash
- **Computer Vision**: MediaPipe (on-device pose detection)
- **3D Engine**: Unity 2022.3 LTS (Phase 2)
- **AR**: AR Foundation (ARCore/ARKit)
- **Analytics**: Firebase Analytics

## Project Structure

```
fitness_game_app/
├── lib/
│   ├── config/          # Environment configuration
│   ├── models/          # Data models
│   ├── providers/       # Riverpod providers
│   ├── screens/         # UI screens
│   │   ├── auth/
│   │   ├── onboarding/
│   │   ├── home/
│   │   ├── game/
│   │   │   ├── boss_battle_screen.dart       # Phase 1: 2D
│   │   │   └── ar_boss_battle_screen.dart    # Phase 2: 3D AR
│   │   └── workout/
│   ├── services/        # Business logic services
│   │   ├── mediapipe_service.dart
│   │   ├── database_service.dart
│   │   └── unity_service.dart                # Phase 2: Unity bridge
│   └── widgets/         # Reusable widgets
│
├── unity_project/       # Phase 2: Unity AR game
│   ├── Assets/
│   │   ├── Models/      # 3D monster model
│   │   ├── Scripts/     # C# game logic
│   │   ├── VFX/         # Particle effects
│   │   └── Scenes/      # AR game scene
│   └── Builds/          # Exported builds
│
├── docs/                # Phase 2 documentation
│   ├── BLENDER_RIGGING_GUIDE.md
│   ├── UNITY_SETUP_GUIDE.md
│   └── UNITY_EXPORT_GUIDE.md
│
└── PHASE2_README.md     # Phase 2 overview
```

## Setup

### Prerequisites

- Flutter SDK 3.0+
- Firebase account
- Supabase account
- Gemini API key

### Installation

1. Clone the repository
```bash
git clone https://github.com/tainlnwza/Jump-up.git
cd fitness_game_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure environment variables

Create `lib/config/env.dart`:
```dart
class Environment {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
}
```

4. Setup Firebase

- Create Firebase project
- Enable Google Sign-In
- Download and add config files:
  - `google-services.json` → `android/app/`
  - `GoogleService-Info.plist` → `ios/Runner/`

5. Setup Supabase

- Create Supabase project
- Run `supabase_schema.sql` in SQL Editor
- Copy Project URL and anon key

6. Run the app
```bash
flutter run
```

## Development Roadmap

### Phase 1: MVP (Weeks 1-6) ✅ 90% Complete
- [x] Project setup
- [x] Authentication (Google Sign-In)
- [x] Onboarding flow (7 steps)
- [x] Home page with gamification stats
- [x] MediaPipe pose detection
- [x] Boss battle mechanics (basic)
- [x] Results page
- [ ] Achievement system (in progress)

### Phase 2: 3D AR Game (Weeks 7-10) 📝 Documentation Complete
- [ ] **Blender**: Monster rigging + 5 animations
- [ ] **Unity**: 3D AR game implementation
  - [ ] AR Foundation setup
  - [ ] Monster controller + animations
  - [ ] 7 VFX particle systems
  - [ ] Flutter-Unity integration
- [ ] **Testing**: Device testing + optimization
- 📚 **Docs**: [PHASE2_README.md](PHASE2_README.md)

### Phase 3: Core Features (Weeks 11-14)
- [ ] Workout mode with MediaPipe
- [ ] Community feed
- [ ] AI personalization (Gemini)
- [ ] Shop & cosmetics
- [ ] Quest system

### Phase 4: Polish (Weeks 15-16)
- [ ] Community posting
- [ ] Multiple bosses
- [ ] Progress analytics
- [ ] Bug fixes & optimization
- [ ] App store submission

## Database Schema

See `Phase1-Setup/supabase_schema.sql` for complete schema including:
- users
- expert_programs
- workout_sessions
- achievements
- shop_items
- quests

## Contributing

This is a personal project. Feel free to fork and modify for your own use.

## License

MIT License - See LICENSE file for details

## Contact

GitHub: [@tainlnwza](https://github.com/tainlnwza)
