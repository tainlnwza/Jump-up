class Environment {
  // Supabase Configuration
  // Get these from: https://supabase.com/dashboard/project/_/settings/api
  static const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Gemini AI Configuration
  // Get from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';

  // App Configuration
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
  static const int baseExpPerLevel = 100; // exp = 100 * level^2
  static const int baseCoinsPerVictory = 50;
  static const int baseExpPerVictory = 100;
}
