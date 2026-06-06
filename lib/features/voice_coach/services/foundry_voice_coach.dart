import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;
import '../../../core/config/app_config.dart';

/// Azure AI Foundry Voice Coach Service
/// Powered by gpt-4o-mini-tts deployed in Azure AI Foundry
/// This is the Microsoft IQ — Foundry IQ intelligence layer!
class FoundryVoiceCoach {
  bool _isSpeaking = false;

  // ── Exercise coaching phrases ──────────────────────────────────────────────

  static const Map<String, List<String>> _exerciseCues = {
    'push-up': [
      'Keep your core tight and lower your chest to the floor.',
      'Great form! Breathe out on the push.',
      'Keep your back straight — no sagging hips!',
    ],
    'squat': [
      'Chest up, knees tracking over your toes.',
      'Drive through your heels on the way up.',
      'Keep your back straight — sit back into the squat.',
    ],
    'plank': [
      'Neutral spine — squeeze your glutes and core.',
      'Keep breathing. You\'ve got this!',
      'Eyes down, neck neutral.',
    ],
    'lunge': [
      'Step forward and drop your back knee gently.',
      'Keep your front knee behind your toes.',
      'Drive up through your front heel.',
    ],
    'bicep curl': [
      'Keep your elbows pinned to your sides.',
      'Control the weight on the way down.',
      'Full range of motion — all the way up!',
    ],
    'shoulder press': [
      'Drive the dumbbells straight overhead.',
      'Keep your core braced — don\'t arch your back.',
      'Lower slowly for maximum benefit.',
    ],
    'glute bridge': [
      'Drive your hips up and squeeze at the top.',
      'Keep your feet flat, push through your heels.',
      'Hold at the top for one second.',
    ],
  };

  /// Speak a coaching cue for the given exercise using Azure Foundry TTS
  Future<void> coachExercise(String exerciseName) async {
    if (_isSpeaking) return;
    final name = exerciseName.toLowerCase();
    final cues = _exerciseCues[name] ?? [
      'Keep your form tight and breathe steadily.',
      'You\'re doing great — stay focused!',
    ];
    final cue = cues[DateTime.now().millisecond % cues.length];
    await speak(cue);
  }

  /// Speak any text using Azure AI Foundry gpt-4o-mini-tts
  Future<void> speak(String text, {String voice = 'alloy'}) async {
    if (_isSpeaking) return;
    _isSpeaking = true;

    try {
      if (AppConfig.azureApiKey.isEmpty) {
        // Fallback: browser speech synthesis
        await _browserTts(text);
        return;
      }

      final response = await http.post(
        Uri.parse(AppConfig.azureTtsUrl),
        headers: {
          'Content-Type': 'application/json',
          'api-key': AppConfig.azureApiKey,
        },
        body: jsonEncode({
          'model': AppConfig.ttsDeployment,
          'input': text,
          'voice': voice,        // alloy | echo | fable | onyx | nova | shimmer
          'response_format': 'mp3',
        }),
      );

      if (response.statusCode == 200) {
        await _playAudioBytes(response.bodyBytes);
      } else {
        debugPrint('TTS error ${response.statusCode}: ${response.body}');
        // Fallback to browser TTS on error
        await _browserTts(text);
      }
    } catch (e) {
      debugPrint('TTS exception: $e');
      await _browserTts(text);
    } finally {
      _isSpeaking = false;
    }
  }

  /// Play raw MP3 bytes in the browser using Web Audio API
  Future<void> _playAudioBytes(List<int> bytes) async {
    if (!kIsWeb) return;
    try {
      // Convert bytes to base64 data URL and play via HTML Audio
      final base64 = base64Encode(bytes);
      final audio = web.HTMLAudioElement();
      audio.src = 'data:audio/mp3;base64,$base64';
      audio.play().toDart;
      // Wait ~5 seconds max for short coaching cues
      await Future.delayed(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }

  /// Browser fallback TTS using Web Speech API
  Future<void> _browserTts(String text) async {
    if (!kIsWeb) return;
    try {
      final utterance = web.SpeechSynthesisUtterance(text);
      utterance.rate = 0.9;
      utterance.pitch = 1.0;
      web.window.speechSynthesis.speak(utterance);
    } catch (e) {
      debugPrint('Browser TTS error: $e');
    }
  }

  /// Quick motivational phrases
  Future<void> sayMotivation() async {
    const phrases = [
      'Keep pushing — you\'re doing amazing!',
      'Last few reps — give it everything!',
      'Perfect form! Stay strong!',
      'Breathe and focus. You\'ve got this!',
    ];
    final phrase = phrases[DateTime.now().millisecond % phrases.length];
    await speak(phrase, voice: 'nova');
  }

  /// Announce a new exercise
  Future<void> announceExercise(String name, int sets, String reps) async {
    await speak('Next up: $name. $sets sets of $reps. Let\'s go!', voice: 'alloy');
  }

  /// Rest timer announcement
  Future<void> announceRest(int seconds) async {
    await speak('Rest for $seconds seconds. Recover and breathe.', voice: 'alloy');
  }

  bool get isSpeaking => _isSpeaking;
}
