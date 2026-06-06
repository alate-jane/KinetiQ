/// KinetiQ — GitHub Models Configuration
///
/// Uses GitHub Models (free tier) backed by Azure AI infrastructure.
/// Pass credentials via --dart-define:
///   flutter run \
///     --dart-define=GITHUB_TOKEN=ghp_xxxx \
///     --dart-define=AZURE_OPENAI_DEPLOYMENT=gpt-4o
class AppConfig {
  // ── GitHub Models (Workout Planner) ──────────────────────────────────────
  static const String githubToken = String.fromEnvironment(
    'GITHUB_TOKEN',
    defaultValue: '',
  );

  static const String azureDeployment = String.fromEnvironment(
    'AZURE_OPENAI_DEPLOYMENT',
    defaultValue: 'gpt-4o',
  );

  /// GitHub Models chat completions endpoint (Azure-backed, OpenAI-compatible)
  static const String chatUrl =
      'https://models.inference.ai.azure.com/chat/completions';

  // ── Azure AI Foundry TTS (Voice Coach — Foundry IQ) ──────────────────────
  static const String azureEndpoint = String.fromEnvironment(
    'AZURE_OPENAI_ENDPOINT',
    defaultValue: 'https://kinetiq-openai.openai.azure.com',
  );

  static const String azureApiKey = String.fromEnvironment(
    'AZURE_OPENAI_KEY',
    defaultValue: '',
  );

  static const String ttsDeployment = String.fromEnvironment(
    'AZURE_TTS_DEPLOYMENT',
    defaultValue: 'tts',
  );

  /// Azure Foundry TTS endpoint — this IS Foundry IQ!
  static String get azureTtsUrl =>
      '$azureEndpoint/openai/deployments/$ttsDeployment'
      '/audio/speech?api-version=2025-01-01-preview';

  // ── App metadata ──────────────────────────────────────────────────────────
  static const String appName = 'KinetiQ';
  static const String appVersion = '1.0.0';

  // ── Feature flags ─────────────────────────────────────────────────────────
  static const bool enableVoiceCoach = true;
  static const bool enableFormScoring = true;
}
