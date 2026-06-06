/// KinetiQ App Configuration
/// 
/// Copy this file to secrets.dart and fill in your API keys.
/// NEVER commit secrets.dart to version control.
class AppConfig {
  // Replace with your real Gemini API key from https://aistudio.google.com/
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY_HERE',
  );

  // App metadata
  static const String appName = 'KinetiQ';
  static const String appVersion = '1.0.0';

  // Feature flags
  static const bool enableVoiceCoach = true;
  static const bool enableFormScoring = true;
}
