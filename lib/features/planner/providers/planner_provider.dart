import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/workout_plan.dart';
import '../services/azure_openai_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum PlanStatus { idle, loading, loaded, error }

class PlannerState {
  final PlanStatus status;
  final WorkoutPlan? plan;
  final String? errorMessage;
  final int selectedWeek;
  final int selectedDay;

  const PlannerState({
    this.status = PlanStatus.idle,
    this.plan,
    this.errorMessage,
    this.selectedWeek = 0,
    this.selectedDay = 0,
  });

  PlannerState copyWith({
    PlanStatus? status,
    WorkoutPlan? plan,
    String? errorMessage,
    int? selectedWeek,
    int? selectedDay,
  }) => PlannerState(
        status: status ?? this.status,
        plan: plan ?? this.plan,
        errorMessage: errorMessage ?? this.errorMessage,
        selectedWeek: selectedWeek ?? this.selectedWeek,
        selectedDay: selectedDay ?? this.selectedDay,
      );

  WorkoutWeek? get currentWeek =>
      plan != null && selectedWeek < plan!.weeks.length
          ? plan!.weeks[selectedWeek]
          : null;

  WorkoutDay? get currentDay =>
      currentWeek != null && selectedDay < currentWeek!.days.length
          ? currentWeek!.days[selectedDay]
          : null;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class PlannerNotifier extends StateNotifier<PlannerState> {
  PlannerNotifier() : super(const PlannerState()) {
    _loadSavedPlan();
  }

  final _service = AzureOpenAIService();

  // Load any previously saved plan from SharedPreferences
  Future<void> _loadSavedPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('workout_plan');
    if (raw != null) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final goal = FitnessGoal.values.firstWhere(
          (g) => g.name == json['goal'],
          orElse: () => FitnessGoal.generalFitness,
        );
        final level = FitnessLevel.values.firstWhere(
          (l) => l.name == json['level'],
          orElse: () => FitnessLevel.beginner,
        );
        final plan = WorkoutPlan.fromJson(json, userId: json['userId'] ?? '', goal: goal, level: level);
        state = state.copyWith(status: PlanStatus.loaded, plan: plan);
      } catch (_) {
        // Ignore corrupt saved data
      }
    }
  }

  Future<void> generatePlan(UserProfile profile) async {
    state = state.copyWith(status: PlanStatus.loading);
    try {
      final plan = await _service.generatePlan(profile);
      // Persist to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('workout_plan', jsonEncode(plan.toJson()));
      state = state.copyWith(status: PlanStatus.loaded, plan: plan, selectedWeek: 0, selectedDay: 0);
    } on AzureOpenAIException catch (e) {
      state = state.copyWith(status: PlanStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: PlanStatus.error, errorMessage: e.toString());
    }
  }

  void selectWeek(int index) => state = state.copyWith(selectedWeek: index, selectedDay: 0);
  void selectDay(int index) => state = state.copyWith(selectedDay: index);
}

// ── Providers ─────────────────────────────────────────────────────────────────

final plannerProvider =
    StateNotifierProvider<PlannerNotifier, PlannerState>(
  (ref) => PlannerNotifier(),
);

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('user_profile');
  if (raw == null) return null;
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return UserProfile(
    id: json['id'] as String,
    goal: FitnessGoal.values.firstWhere((g) => g.name == json['goal']),
    level: FitnessLevel.values.firstWhere((l) => l.name == json['level']),
    equipment: (json['equipment'] as List)
        .map((e) => Equipment.values.firstWhere((eq) => eq.name == e))
        .toList(),
    daysPerWeek: json['daysPerWeek'] as int,
    injuries: (json['injuries'] as List).cast<String>(),
    style: WorkoutStyle.values.firstWhere((s) => s.name == json['style']),
    preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
  );
});
