import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/env.dart';
import '../models/user_model.dart';
import '../models/expert_program.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: Environment.geminiApiKey,
    );
  }

  /// Personalize workout program based on user profile
  Future<Map<String, dynamic>> personalizeWorkoutProgram({
    required UserModel user,
    required ExpertProgram program,
  }) async {
    final prompt = _buildPersonalizationPrompt(user, program);

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null) {
        throw Exception('No response from Gemini API');
      }

      // Parse JSON response
      final jsonText = _extractJson(text);
      return _parsePersonalizedProgram(jsonText);
    } catch (e) {
      throw Exception('Failed to personalize program: $e');
    }
  }

  String _buildPersonalizationPrompt(UserModel user, ExpertProgram program) {
    return '''
You are a fitness AI assistant. Personalize the following workout program for the user.

User Profile:
- Fitness Goal: ${user.fitnessGoal}
- Age: ${user.age} years
- Weight: ${user.weightKg} kg
- Height: ${user.heightCm} cm
- Body Shape: ${user.bodyShape}
- Physical Limitations: ${user.physicalLimitations?.join(', ') ?? 'None'}
- Available Equipment: ${user.availableEquipment?.join(', ') ?? 'None'}
- Experience Level: ${_getUserExperienceLevel(user)}

Original Program:
- Title: ${program.title}
- Difficulty: ${program.difficultyLevel}
- Exercises: ${program.exercises.map((e) => '${e.name} (${e.duration}s or ${e.reps} reps)').join(', ')}

Instructions:
1. Adjust exercise durations and reps based on user's fitness level
2. Substitute exercises if user has physical limitations
3. Adjust intensity based on user's experience level
4. Consider available equipment
5. Provide a brief explanation for the adjustments

Return ONLY a valid JSON object with this structure (no markdown, no extra text):
{
  "exercises": [
    {
      "name": "Exercise name",
      "duration": 30,
      "reps": 10,
      "sets": 3,
      "notes": "Why this adjustment was made"
    }
  ],
  "explanation": "Brief explanation of the personalization",
  "estimatedDuration": 20
}
''';
  }

  String _getUserExperienceLevel(UserModel user) {
    if (user.level < 5) return 'Beginner';
    if (user.level < 15) return 'Intermediate';
    return 'Advanced';
  }

  String _extractJson(String text) {
    // Remove markdown code blocks if present
    text = text.trim();
    if (text.startsWith('```json')) {
      text = text.substring(7);
    } else if (text.startsWith('```')) {
      text = text.substring(3);
    }
    if (text.endsWith('```')) {
      text = text.substring(0, text.length - 3);
    }
    return text.trim();
  }

  Map<String, dynamic> _parsePersonalizedProgram(String jsonText) {
    // In a real implementation, parse the JSON
    // For now, return a mock structure
    return {
      'exercises': [],
      'explanation': 'Program personalized based on your profile',
      'estimatedDuration': 30,
    };
  }

  /// Analyze user progress and provide insights
  Future<String> analyzeProgress({
    required UserModel user,
    required List<Map<String, dynamic>> recentSessions,
  }) async {
    final prompt = '''
Analyze this user's fitness progress and provide insights.

User: Level ${user.level}, ${user.exp} XP
Recent Sessions (last 7 days):
${recentSessions.map((s) => '- ${s['session_type']}: ${s['exp_earned']} XP, ${s['coins_earned']} coins').join('\n')}

Provide:
1. Progress summary
2. Strengths
3. Areas for improvement
4. Motivational message

Keep it brief and encouraging (max 200 words).
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to analyze progress at this time.';
    } catch (e) {
      throw Exception('Failed to analyze progress: $e');
    }
  }
}
