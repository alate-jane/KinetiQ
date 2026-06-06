import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/workout_plan.dart';

class AzureOpenAIService {
  // ── Prompt Builder ──────────────────────────────────────────────────────────

  String _buildSystemPrompt() => '''
You are KinetiQ, an expert certified personal trainer and sports scientist.
Your job is to create safe, effective, progressive workout plans in valid JSON.
Always respond with ONLY valid JSON — no markdown, no explanation.
''';

  String _buildUserPrompt(UserProfile profile) {
    final equipment = profile.equipment.map((e) => e.label).join(', ');
    final goal = profile.goal.label;
    final level = profile.level.label;
    final style = profile.style.label;
    final days = profile.daysPerWeek;

    return '''
Create a 4-week progressive workout plan for this user:
- Goal: $goal
- Fitness level: $level
- Workout style: $style
- Equipment available: $equipment
- Available days per week: $days

Return ONLY this exact JSON structure (no markdown, no extra text):
{
  "title": "Plan name (e.g. '4-Week Strength Builder')",
  "summary": "2-sentence overview of the plan and its progression",
  "weeks": [
    {
      "weekNumber": 1,
      "focus": "Week theme (e.g. 'Foundation & Form')",
      "days": [
        {
          "dayName": "Monday",
          "sessionName": "Upper Body Strength",
          "isRest": false,
          "estimatedMinutes": 35,
          "muscleGroups": ["Chest", "Triceps", "Shoulders"],
          "exercises": [
            {
              "name": "Push-up",
              "type": "bodyweight",
              "sets": 3,
              "reps": "10-12",
              "restSeconds": 60,
              "muscleGroups": ["Chest", "Triceps"],
              "instructions": "Keep core tight, lower chest to floor"
            }
          ]
        },
        {
          "dayName": "Tuesday",
          "sessionName": "Rest & Recovery",
          "isRest": true,
          "estimatedMinutes": 0,
          "muscleGroups": [],
          "exercises": []
        }
      ]
    }
  ]
}

Rules:
- Include exactly 7 days per week (fill non-workout days with isRest: true)
- Progressive overload: increase reps or sets each week
- Mix bodyweight and dumbbell exercises if equipment allows
- type must be one of: bodyweight, dumbbell, cardio, stretch
- Keep instructions to one clear, actionable sentence
- Distribute workout days based on the user's $days days/week preference
''';
  }

  // ── API Call ────────────────────────────────────────────────────────────────

  Future<WorkoutPlan> generatePlan(UserProfile profile) async {
    if (AppConfig.azureApiKey.isEmpty) {
      // Return a demo plan if no key is configured yet
      return _demoPlan(profile);
    }

    final response = await http.post(
      Uri.parse(AppConfig.azureChatUrl),
      headers: {
        'Content-Type': 'application/json',
        'api-key': AppConfig.azureApiKey,
      },
      body: jsonEncode({
        'messages': [
          {'role': 'system', 'content': _buildSystemPrompt()},
          {'role': 'user', 'content': _buildUserPrompt(profile)},
        ],
        'temperature': 0.7,
        'max_tokens': 4000,
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode != 200) {
      throw AzureOpenAIException(
        'Azure OpenAI error ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content = decoded['choices'][0]['message']['content'] as String;
    final planJson = jsonDecode(content) as Map<String, dynamic>;

    return WorkoutPlan.fromJson(
      planJson,
      userId: profile.id,
      goal: profile.goal,
      level: profile.level,
    );
  }

  // ── Demo Plan (no API key needed) ───────────────────────────────────────────

  WorkoutPlan _demoPlan(UserProfile profile) {
    return WorkoutPlan(
      id: 'demo-plan',
      userId: profile.id,
      title: '4-Week ${profile.goal.label} Starter',
      summary:
          'A progressive plan tailored to your ${profile.level.label.toLowerCase()} level. '
          'Each week builds on the last with increased volume and intensity.',
      goal: profile.goal,
      level: profile.level,
      createdAt: DateTime.now(),
      weeks: List.generate(4, (wi) {
        final weekNum = wi + 1;
        return WorkoutWeek(
          weekNumber: weekNum,
          focus: ['Foundation & Form', 'Building Volume', 'Power & Endurance', 'Peak Week'][wi],
          days: [
            WorkoutDay(
              dayName: 'Monday',
              sessionName: 'Full Body Strength',
              isRest: false,
              estimatedMinutes: 35 + (wi * 5),
              muscleGroups: const ['Chest', 'Back', 'Legs'],
              exercises: [
                WorkoutExercise(
                  name: 'Push-up',
                  type: ExerciseType.bodyweight,
                  sets: 3 + wi,
                  reps: '${10 + wi * 2}',
                  restSeconds: 60,
                  muscleGroups: const ['Chest', 'Triceps'],
                  instructions: 'Keep core tight, lower chest to floor',
                ),
                WorkoutExercise(
                  name: 'Squat',
                  type: ExerciseType.bodyweight,
                  sets: 3 + wi,
                  reps: '${12 + wi * 2}',
                  restSeconds: 60,
                  muscleGroups: const ['Quads', 'Glutes'],
                  instructions: 'Chest up, knees track over toes',
                ),
                WorkoutExercise(
                  name: 'Plank',
                  type: ExerciseType.bodyweight,
                  sets: 3,
                  reps: '${30 + wi * 10} sec',
                  restSeconds: 45,
                  muscleGroups: const ['Core', 'Shoulders'],
                  instructions: 'Neutral spine, squeeze glutes',
                ),
              ],
            ),
            WorkoutDay(
              dayName: 'Tuesday',
              sessionName: 'Rest & Recovery',
              isRest: true,
              estimatedMinutes: 0,
              muscleGroups: const [],
              exercises: const [],
            ),
            WorkoutDay(
              dayName: 'Wednesday',
              sessionName: 'Upper Body Focus',
              isRest: false,
              estimatedMinutes: 30 + (wi * 5),
              muscleGroups: const ['Shoulders', 'Back', 'Arms'],
              exercises: [
                WorkoutExercise(
                  name: 'Bicep Curl',
                  type: ExerciseType.dumbbell,
                  sets: 3,
                  reps: '${10 + wi}',
                  restSeconds: 60,
                  muscleGroups: const ['Biceps'],
                  instructions: 'Keep elbows pinned to sides',
                ),
                WorkoutExercise(
                  name: 'Shoulder Press',
                  type: ExerciseType.dumbbell,
                  sets: 3,
                  reps: '${10 + wi}',
                  restSeconds: 60,
                  muscleGroups: const ['Shoulders', 'Triceps'],
                  instructions: 'Drive dumbbells straight overhead',
                ),
              ],
            ),
            WorkoutDay(
              dayName: 'Thursday',
              sessionName: 'Rest & Recovery',
              isRest: true,
              estimatedMinutes: 0,
              muscleGroups: const [],
              exercises: const [],
            ),
            WorkoutDay(
              dayName: 'Friday',
              sessionName: 'Lower Body & Core',
              isRest: false,
              estimatedMinutes: 35 + (wi * 5),
              muscleGroups: const ['Glutes', 'Quads', 'Core'],
              exercises: [
                WorkoutExercise(
                  name: 'Lunge',
                  type: ExerciseType.bodyweight,
                  sets: 3,
                  reps: '${10 + wi} each leg',
                  restSeconds: 60,
                  muscleGroups: const ['Quads', 'Glutes'],
                  instructions: 'Step forward, drop back knee gently',
                ),
                WorkoutExercise(
                  name: 'Glute Bridge',
                  type: ExerciseType.bodyweight,
                  sets: 3,
                  reps: '${15 + wi * 3}',
                  restSeconds: 45,
                  muscleGroups: const ['Glutes', 'Hamstrings'],
                  instructions: 'Drive hips up, squeeze at the top',
                ),
              ],
            ),
            WorkoutDay(
              dayName: 'Saturday',
              sessionName: 'Active Recovery',
              isRest: true,
              estimatedMinutes: 0,
              muscleGroups: const [],
              exercises: const [],
            ),
            WorkoutDay(
              dayName: 'Sunday',
              sessionName: 'Rest',
              isRest: true,
              estimatedMinutes: 0,
              muscleGroups: const [],
              exercises: const [],
            ),
          ],
        );
      }),
    );
  }
}

class AzureOpenAIException implements Exception {
  final String message;
  const AzureOpenAIException(this.message);
  @override
  String toString() => 'AzureOpenAIException: $message';
}
