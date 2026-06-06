/// KinetiQ — Azure OpenAI Configuration
///
/// Set your Azure OpenAI credentials via --dart-define at run time:
///   flutter run \
///     --dart-define=AZURE_OPENAI_ENDPOINT=https://YOUR_RESOURCE.openai.azure.com \
///     --dart-define=AZURE_OPENAI_KEY=YOUR_KEY_HERE \
///     --dart-define=AZURE_OPENAI_DEPLOYMENT=gpt-4o
///
/// Or create a local launch config in .vscode/launch.json / run configs.
class AppConfig {
  // ── Azure OpenAI ──────────────────────────────────────────────────────────
  static const String azureEndpoint = String.fromEnvironment(
    'AZURE_OPENAI_ENDPOINT',
    defaultValue: 'https://YOUR_RESOURCE.openai.azure.com',
  );

  static const String azureApiKey = String.fromEnvironment(
    'AZURE_OPENAI_KEY',
    defaultValue: '',
  );

  static const String azureDeployment = String.fromEnvironment(
    'AZURE_OPENAI_DEPLOYMENT',
    defaultValue: 'gpt-4o',
  );

  /// Full Azure OpenAI chat completions URL
  static String get azureChatUrl =>
      '$azureEndpoint/openai/deployments/$azureDeployment'
      '/chat/completions?api-version=2024-08-01-preview';

  // ── App metadata ──────────────────────────────────────────────────────────
  static const String appName = 'KinetiQ';
  static const String appVersion = '1.0.0';

  // ── Feature flags ─────────────────────────────────────────────────────────
  static const bool enableVoiceCoach = true;
  static const bool enableFormScoring = true;
}
