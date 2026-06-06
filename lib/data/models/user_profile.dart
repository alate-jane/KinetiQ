class UserProfile {
  final String id;
  final FitnessGoal goal;
  final FitnessLevel level;
  final List<Equipment> equipment;
  final int daysPerWeek;
  final List<String> injuries;
  final WorkoutStyle style;
  final String preferredLanguage;

  const UserProfile({
    required this.id,
    required this.goal,
    required this.level,
    required this.equipment,
    required this.daysPerWeek,
    required this.injuries,
    required this.style,
    this.preferredLanguage = 'en',
  });

  UserProfile copyWith({
    FitnessGoal? goal,
    FitnessLevel? level,
    List<Equipment>? equipment,
    int? daysPerWeek,
    List<String>? injuries,
    WorkoutStyle? style,
    String? preferredLanguage,
  }) {
    return UserProfile(
      id: id,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      equipment: equipment ?? this.equipment,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      injuries: injuries ?? this.injuries,
      style: style ?? this.style,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'goal': goal.name,
    'level': level.name,
    'equipment': equipment.map((e) => e.name).toList(),
    'daysPerWeek': daysPerWeek,
    'injuries': injuries,
    'style': style.name,
    'preferredLanguage': preferredLanguage,
  };
}

enum FitnessGoal {
  weightLoss('Lose Weight', '🔥'),
  muscleGain('Build Muscle', '💪'),
  endurance('Build Endurance', '🏃'),
  flexibility('Improve Flexibility', '🧘'),
  generalFitness('Stay Healthy', '❤️');

  final String label;
  final String emoji;
  const FitnessGoal(this.label, this.emoji);
}

enum FitnessLevel {
  beginner('Beginner', 'New to exercise or returning after a long break'),
  intermediate('Intermediate', 'Exercise 1–3 times/week regularly'),
  advanced('Advanced', 'Train 4+ times/week with intensity');

  final String label;
  final String description;
  const FitnessLevel(this.label, this.description);
}

enum Equipment {
  none('No Equipment', '🏠'),
  dumbbells('Dumbbells', '🏋️'),
  resistanceBands('Resistance Bands', '📿'),
  pullUpBar('Pull-up Bar', '🔩'),
  fullGym('Full Gym', '🏟️');

  final String label;
  final String emoji;
  const Equipment(this.label, this.emoji);
}

enum WorkoutStyle {
  hiit('HIIT', '⚡'),
  strength('Strength Training', '🏋️'),
  yoga('Yoga & Flexibility', '🧘'),
  cardio('Cardio', '🏃'),
  mixed('Mixed / Variety', '🎯');

  final String label;
  final String emoji;
  const WorkoutStyle(this.label, this.emoji);
}
