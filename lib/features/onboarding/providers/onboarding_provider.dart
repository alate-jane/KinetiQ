import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../data/models/user_profile.dart';

/// Holds the in-progress onboarding answers before saving
class OnboardingState {
  final int currentStep;
  final FitnessGoal? goal;
  final FitnessLevel? level;
  final List<Equipment> equipment;
  final int daysPerWeek;
  final WorkoutStyle? style;

  const OnboardingState({
    this.currentStep = 0,
    this.goal,
    this.level,
    this.equipment = const [],
    this.daysPerWeek = 3,
    this.style,
  });

  OnboardingState copyWith({
    int? currentStep,
    FitnessGoal? goal,
    FitnessLevel? level,
    List<Equipment>? equipment,
    int? daysPerWeek,
    WorkoutStyle? style,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      equipment: equipment ?? this.equipment,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      style: style ?? this.style,
    );
  }

  bool get isComplete =>
      goal != null && level != null && equipment.isNotEmpty && style != null;
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void prevStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setGoal(FitnessGoal goal) {
    state = state.copyWith(goal: goal);
  }

  void setLevel(FitnessLevel level) {
    state = state.copyWith(level: level);
  }

  void toggleEquipment(Equipment e) {
    final current = List<Equipment>.from(state.equipment);
    if (current.contains(e)) {
      current.remove(e);
    } else {
      current.add(e);
    }
    state = state.copyWith(equipment: current);
  }

  void setDaysPerWeek(int days) {
    state = state.copyWith(daysPerWeek: days);
  }

  void setStyle(WorkoutStyle style) {
    state = state.copyWith(style: style);
  }

  Future<void> completeOnboarding() async {
    final profile = UserProfile(
      id: const Uuid().v4(),
      goal: state.goal!,
      level: state.level!,
      equipment: state.equipment,
      daysPerWeek: state.daysPerWeek,
      injuries: [],
      style: state.style!,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setString('user_profile', jsonEncode(profile.toJson()));
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
