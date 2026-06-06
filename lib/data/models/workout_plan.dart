import 'user_profile.dart';

// ─── Top-level plan ──────────────────────────────────────────────────────────

class WorkoutPlan {
  final String id;
  final String userId;
  final String title;
  final String summary;
  final List<WorkoutWeek> weeks;
  final DateTime createdAt;
  final FitnessGoal goal;
  final FitnessLevel level;

  const WorkoutPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.summary,
    required this.weeks,
    required this.createdAt,
    required this.goal,
    required this.level,
  });

  WorkoutWeek get currentWeek => weeks.isNotEmpty ? weeks[0] : weeks.first;

  factory WorkoutPlan.fromJson(Map<String, dynamic> json, {
    required String userId,
    required FitnessGoal goal,
    required FitnessLevel level,
  }) {
    return WorkoutPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: json['title'] as String? ?? 'Your Personalized Plan',
      summary: json['summary'] as String? ?? '',
      createdAt: DateTime.now(),
      goal: goal,
      level: level,
      weeks: (json['weeks'] as List<dynamic>)
          .map((w) => WorkoutWeek.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'summary': summary,
    'createdAt': createdAt.toIso8601String(),
    'goal': goal.name,
    'level': level.name,
    'weeks': weeks.map((w) => w.toJson()).toList(),
  };
}

// ─── Week ─────────────────────────────────────────────────────────────────────

class WorkoutWeek {
  final int weekNumber;
  final String focus;
  final List<WorkoutDay> days;

  const WorkoutWeek({
    required this.weekNumber,
    required this.focus,
    required this.days,
  });

  List<WorkoutDay> get activeDays => days.where((d) => !d.isRest).toList();
  int get totalExercises =>
      activeDays.fold(0, (sum, d) => sum + d.exercises.length);

  factory WorkoutWeek.fromJson(Map<String, dynamic> json) {
    return WorkoutWeek(
      weekNumber: json['weekNumber'] as int? ?? 1,
      focus: json['focus'] as String? ?? '',
      days: (json['days'] as List<dynamic>)
          .map((d) => WorkoutDay.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'weekNumber': weekNumber,
    'focus': focus,
    'days': days.map((d) => d.toJson()).toList(),
  };
}

// ─── Day ──────────────────────────────────────────────────────────────────────

class WorkoutDay {
  final String dayName;       // "Monday", "Tuesday" etc.
  final String sessionName;   // "Upper Body Strength", "Rest & Recovery" etc.
  final bool isRest;
  final int estimatedMinutes;
  final List<WorkoutExercise> exercises;
  final List<String> muscleGroups;

  const WorkoutDay({
    required this.dayName,
    required this.sessionName,
    required this.isRest,
    required this.estimatedMinutes,
    required this.exercises,
    required this.muscleGroups,
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    final isRest = json['isRest'] as bool? ?? false;
    return WorkoutDay(
      dayName: json['dayName'] as String? ?? '',
      sessionName: json['sessionName'] as String? ?? (isRest ? 'Rest & Recovery' : 'Workout'),
      isRest: isRest,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 30,
      muscleGroups: (json['muscleGroups'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      exercises: isRest
          ? []
          : (json['exercises'] as List<dynamic>? ?? [])
              .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'dayName': dayName,
    'sessionName': sessionName,
    'isRest': isRest,
    'estimatedMinutes': estimatedMinutes,
    'muscleGroups': muscleGroups,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}

// ─── Exercise ─────────────────────────────────────────────────────────────────

class WorkoutExercise {
  final String name;
  final int sets;
  final String reps;         // "12", "10-12", "30 sec" etc.
  final int restSeconds;
  final String instructions; // One-line form tip
  final List<String> muscleGroups;
  final ExerciseType type;

  const WorkoutExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.instructions,
    required this.muscleGroups,
    required this.type,
  });

  bool get isTimeBased => reps.contains('sec') || reps.contains('min');

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      name: json['name'] as String? ?? '',
      sets: json['sets'] as int? ?? 3,
      reps: json['reps']?.toString() ?? '10',
      restSeconds: json['restSeconds'] as int? ?? 60,
      instructions: json['instructions'] as String? ?? '',
      muscleGroups: (json['muscleGroups'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      type: ExerciseType.values.firstWhere(
        (t) => t.name == (json['type'] as String? ?? ''),
        orElse: () => ExerciseType.bodyweight,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets,
    'reps': reps,
    'restSeconds': restSeconds,
    'instructions': instructions,
    'muscleGroups': muscleGroups,
    'type': type.name,
  };
}

enum ExerciseType {
  bodyweight('Bodyweight', '🏃'),
  dumbbell('Dumbbell', '🏋️'),
  cardio('Cardio', '❤️'),
  stretch('Stretch', '🧘');

  final String label;
  final String emoji;
  const ExerciseType(this.label, this.emoji);
}
