# Setup Instructions

This file contains placeholders for sensitive configuration. Follow these steps to complete the setup:

## 1. Supabase Configuration

1. Go to https://supabase.com/dashboard
2. Create a new project or select existing one
3. Navigate to Project Settings → API
4. Copy the following values to `lib/config/env.dart`:
   - **Project URL**: Replace `YOUR_SUPABASE_PROJECT_URL`
   - **anon/public key**: Replace `YOUR_SUPABASE_ANON_KEY`

## 2. Gemini AI Configuration

1. Go to https://makersuite.google.com/app/apikey
2. Create a new API key
3. Copy the key to `lib/config/env.dart`:
   - Replace `YOUR_GEMINI_API_KEY`

## 3. Firebase Configuration

### Android
1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project
3. Add Android app
4. Download `google-services.json`
5. Place it in `android/app/` directory

### iOS
1. In Firebase Console, add iOS app
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/` directory

## 4. Database Setup

1. Go to Supabase SQL Editor
2. Copy and run the SQL from `Phase1-Setup/supabase_schema.sql`
3. Verify all tables are created in Table Editor

## 5. Install Dependencies

```bash
flutter pub get
```

## 6. Run the App

```bash
flutter run
```

## Important Notes

- ⚠️ Never commit `lib/config/env.dart` with real API keys
- ⚠️ Add `lib/config/env.dart` to `.gitignore` (already done)
- ⚠️ Keep Firebase config files private

## Troubleshooting

If you encounter issues:
1. Check `flutter doctor`
2. Verify all API keys are correctly placed
3. Ensure Firebase is properly configured
4. Check Supabase database is accessible
