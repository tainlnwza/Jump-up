# Phase 1 Setup Guide - Gamified Fitness App

## Prerequisites
- Flutter SDK 3.0 or higher
- Firebase account
- Supabase account
- Git installed

## Step-by-Step Setup

### 1. Create Flutter Project
```bash
cd "D:\jump up"
flutter create fitness_game_app
cd fitness_game_app
```

### 2. Replace pubspec.yaml
Copy the `pubspec.yaml` from this folder to your project root.

```bash
cp ../Phase1-Setup/pubspec.yaml .
flutter pub get
```

### 3. Setup Firebase

#### 3.1 Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Create new project: "fitness-game-app"
3. Enable Google Analytics (optional)

#### 3.2 Add Android App
1. Click "Add app" → Android
2. Package name: `com.example.fitness_game_app`
3. Download `google-services.json`
4. Place in `android/app/`

#### 3.3 Add iOS App
1. Click "Add app" → iOS
2. Bundle ID: `com.example.fitnessGameApp`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/`

#### 3.4 Enable Authentication
1. Go to Authentication → Sign-in method
2. Enable "Google" provider
3. Add your email as test user

#### 3.5 FlutterFire CLI (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your app
flutterfire configure
```

### 4. Setup Supabase

#### 4.1 Create Supabase Project
1. Go to https://supabase.com/
2. Create new project: "fitness-game-app"
3. Choose region (closest to users)
4. Save database password

#### 4.2 Run Database Schema
1. Go to SQL Editor in Supabase dashboard
2. Copy content from `supabase_schema.sql`
3. Run the SQL script
4. Verify tables created in Table Editor

#### 4.3 Get Supabase Credentials
1. Go to Project Settings → API
2. Copy:
   - Project URL: `https://xxxxx.supabase.co`
   - `anon` public key

### 5. Configure Environment Variables

Create `lib/config/env.dart`:

```dart
class Environment {
  // Supabase
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Gemini AI
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
}
```

**Important:** Add `lib/config/env.dart` to `.gitignore`

### 6. Project Structure

Create this folder structure:
```
lib/
├── config/
│   └── env.dart
├── models/
│   ├── user_model.dart
│   ├── workout_session.dart
│   └── expert_program.dart
├── providers/
│   ├── auth_provider.dart
│   └── user_provider.dart
├── screens/
│   ├── auth/
│   ├── onboarding/
│   ├── home/
│   ├── game/
│   └── workout/
├── services/
│   ├── auth_service.dart
│   ├── database_service.dart
│   └── mediapipe_service.dart
├── widgets/
│   └── common/
└── main.dart
```

### 7. Android Configuration

#### 7.1 Update `android/app/build.gradle`
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.example.fitness_game_app"
        minSdkVersion 24  // Required for MediaPipe
        targetSdkVersion 34
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

#### 7.2 Update `android/app/src/main/AndroidManifest.xml`
Add permissions:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
```

### 8. iOS Configuration

#### 8.1 Update `ios/Runner/Info.plist`
Add camera permission:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to track your exercise poses</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to save your achievements</string>
```

#### 8.2 Set minimum iOS version
In `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

### 9. Get Gemini API Key

1. Go to https://makersuite.google.com/app/apikey
2. Create API key
3. Add to `lib/config/env.dart`

### 10. Initialize Git Repository

```bash
git init
git remote add origin https://github.com/tainlnwza/Jump-up.git
git add .
git commit -m "Initial setup: Flutter project with Firebase and Supabase"
```

### 11. Test Setup

Run the app to verify setup:
```bash
flutter run
```

Expected: App launches without errors (even with empty screens)

### 12. Verify Checklist

- [ ] Flutter project created
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Firebase project configured
- [ ] Supabase database schema created
- [ ] Environment variables configured
- [ ] Android minSdkVersion set to 24
- [ ] iOS minimum version set to 12.0
- [ ] Camera permissions added
- [ ] Gemini API key obtained
- [ ] Git repository initialized
- [ ] App runs without errors

## Troubleshooting

### Common Issues

**1. "google-services.json not found"**
- Download from Firebase Console
- Place in `android/app/` directory

**2. "Supabase connection failed"**
- Check URL and anon key in env.dart
- Verify RLS policies in Supabase dashboard

**3. "Camera permission denied"**
- Check AndroidManifest.xml permissions
- Check Info.plist camera usage description

**4. "MediaPipe not working"**
- Verify minSdkVersion 24 (Android)
- Test on physical device (emulator may not support)

## Next Steps

After setup is complete:
1. Implement Ticket 02: Google Sign-In
2. Implement Ticket 03: Onboarding Flow
3. Continue with remaining Phase 1 tickets

## Support

If you encounter issues:
- Check Flutter doctor: `flutter doctor`
- Check Firebase connection
- Verify Supabase database is accessible
- Review error logs: `flutter logs`
