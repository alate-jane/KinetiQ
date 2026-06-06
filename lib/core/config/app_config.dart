/// KinetiQ — GitHub Models Configuration
///
/// Uses GitHub Models (free tier) backed by Azure AI infrastructure.
/// Pass credentials via --dart-define:
///   flutter run \
///     --dart-define=GITHUB_TOKEN=ghp_xxxx \
///     --dart-define=AZURE_OPENAI_DEPLOYMENT=gpt-4o
class AppConfig {
  // ── GitHub Models ────────────────────────────────────────────────────────
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

  // ── App metadata ──────────────────────────────────────────────────────────
  static const String appName = 'KinetiQ';
  static const String appVersion = '1.0.0';

  // ── Feature flags ─────────────────────────────────────────────────────────
  static const bool enableVoiceCoach = true;
  static const bool enableFormScoring = true;
}
