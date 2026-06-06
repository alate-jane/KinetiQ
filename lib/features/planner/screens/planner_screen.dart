import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/workout_plan.dart';
import '../providers/planner_provider.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plannerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: switch (state.status) {
        PlanStatus.idle   => _EmptyState(onGenerate: () => _generate(ref, context)),
        PlanStatus.loading => const _LoadingState(),
        PlanStatus.loaded  => _PlanView(plan: state.plan!),
        PlanStatus.error   => _ErrorState(
            message: state.errorMessage ?? 'Unknown error',
            onRetry: () => _generate(ref, context),
          ),
      },
    );
  }

  Future<void> _generate(WidgetRef ref, BuildContext context) async {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.valueOrNull;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete onboarding first!')),
      );
      return;
    }
    await ref.read(plannerProvider.notifier).generatePlan(profile);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onGenerate;
  const _EmptyState({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  Colors.transparent,
                ]),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 28),
            Text('Generate Your Plan',
                style: GoogleFonts.inter(
                  fontSize: 28, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, letterSpacing: -0.5,
                )),
            const SizedBox(height: 12),
            Text(
              'KinetiQ\'s AI will build a personalised 4-week workout plan based on your goals, fitness level, and available equipment.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15, color: AppColors.textSecondary, height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            _FeatureRow(icon: '🎯', text: 'Tailored to your fitness goal'),
            const SizedBox(height: 12),
            _FeatureRow(icon: '📈', text: 'Progressive overload built in'),
            const SizedBox(height: 12),
            _FeatureRow(icon: '🏋️', text: 'Works with your equipment'),
            const SizedBox(height: 12),
            _FeatureRow(icon: '⚡', text: 'Powered by Azure OpenAI GPT-4o'),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: onGenerate,
              child: const Text('✨  Generate My 4-Week Plan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 14),
        Text(text, style: GoogleFonts.inter(
          fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500,
        )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading State
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingState extends StatefulWidget {
  const _LoadingState();

  @override
  State<_LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<_LoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  int _dotCount = 1;

  static const _messages = [
    'Analysing your fitness profile...',
    'Designing your workout structure...',
    'Calculating progressive overload...',
    'Adding exercise variations...',
    'Almost ready...',
  ];
  int _msgIndex = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    // Cycle messages
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      setState(() {
        _msgIndex = (_msgIndex + 1) % _messages.length;
        _dotCount = (_dotCount % 3) + 1;
      });
      return true;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulse,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.primary.withValues(alpha: 0.05),
                    ]),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text('🤖', style: TextStyle(fontSize: 52)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Azure OpenAI is working${'.' * _dotCount}',
                style: GoogleFonts.inter(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _messages[_msgIndex],
                  key: ValueKey(_msgIndex),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15, color: AppColors.textSecondary, height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              LinearProgressIndicator(
                backgroundColor: AppColors.surfaceCard,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                borderRadius: BorderRadius.circular(4),
                minHeight: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan View — the main UI
// ─────────────────────────────────────────────────────────────────────────────
class _PlanView extends ConsumerWidget {
  final WorkoutPlan plan;
  const _PlanView({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plannerProvider);
    final week = state.currentWeek!;
    final day = state.currentDay;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(plan.title,
                          style: GoogleFonts.inter(
                            fontSize: 22, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary, letterSpacing: -0.5,
                          )),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(plannerProvider.notifier).generatePlan(
                          ref.read(userProfileProvider).valueOrNull!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1E2D48)),
                        ),
                        child: Text('Regenerate',
                            style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(plan.summary,
                    style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary, height: 1.5,
                    )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Week Selector ──────────────────────────────────────
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: plan.weeks.length,
              itemBuilder: (ctx, i) {
                final selected = i == state.selectedWeek;
                return GestureDetector(
                  onTap: () => ref.read(plannerProvider.notifier).selectWeek(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.primary : const Color(0xFF1E2D48),
                      ),
                    ),
                    child: Text('Week ${i + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: selected ? AppColors.background : AppColors.textSecondary,
                        )),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Week Focus label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(week.focus,
                style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600,
                )),
          ),

          const SizedBox(height: 16),

          // ── Day Selector ───────────────────────────────────────
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: week.days.length,
              itemBuilder: (ctx, i) {
                final d = week.days[i];
                final selected = i == state.selectedDay;
                return GestureDetector(
                  onTap: () => ref.read(plannerProvider.notifier).selectDay(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    width: 56,
                    decoration: BoxDecoration(
                      color: selected
                          ? (d.isRest ? AppColors.surfaceCard : AppColors.primary.withValues(alpha: 0.15))
                          : AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? (d.isRest ? AppColors.textMuted : AppColors.primary)
                            : const Color(0xFF1E2D48),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(d.dayName.substring(0, 3),
                            style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: selected ? AppColors.primary : AppColors.textSecondary,
                            )),
                        const SizedBox(height: 4),
                        Text(
                          d.isRest ? '😴' : '🔥',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ── Day Detail ─────────────────────────────────────────
          Expanded(
            child: day == null
                ? const SizedBox()
                : day.isRest
                    ? _RestDayCard(day: day)
                    : _WorkoutDayDetail(day: day),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rest Day
// ─────────────────────────────────────────────────────────────────────────────
class _RestDayCard extends StatelessWidget {
  final WorkoutDay day;
  const _RestDayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E2D48)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😴', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(day.sessionName,
                style: GoogleFonts.inter(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 8),
            Text(
              'Take it easy today. Rest is when your muscles grow stronger.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary, height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Workout Day Detail
// ─────────────────────────────────────────────────────────────────────────────
class _WorkoutDayDetail extends StatelessWidget {
  final WorkoutDay day;
  const _WorkoutDayDetail({required this.day});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // Session header
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D2E1F), Color(0xFF0A1A3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day.sessionName,
                        style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        )),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: day.muscleGroups.map((mg) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(mg,
                            style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            )),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text('⏱️', style: const TextStyle(fontSize: 24)),
                  Text('${day.estimatedMinutes}m',
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text('${day.exercises.length} Exercises',
            style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            )),
        const SizedBox(height: 12),

        // Exercise list
        ...day.exercises.asMap().entries.map((entry) {
          final i = entry.key;
          final ex = entry.value;
          return _ExerciseCard(exercise: ex, index: i + 1);
        }),

        const SizedBox(height: 80),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exercise Card
// ─────────────────────────────────────────────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final int index;
  const _ExerciseCard({required this.exercise, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2D48)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index + type badge
          Column(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('$index',
                      style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      )),
                ),
              ),
              const SizedBox(height: 6),
              Text(exercise.type.emoji, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(width: 14),

          // Exercise details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name,
                    style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 8),

                // Sets / Reps / Rest chips
                Row(
                  children: [
                    _Chip('${exercise.sets} sets', AppColors.accent),
                    const SizedBox(width: 6),
                    _Chip(exercise.reps, AppColors.primary),
                    const SizedBox(width: 6),
                    _Chip('${exercise.restSeconds}s rest', AppColors.textMuted),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.tips_and_updates_rounded,
                        size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(exercise.instructions,
                          style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textSecondary,
                            height: 1.4,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
            fontSize: 11, color: color, fontWeight: FontWeight.w600,
          )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error State
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            Text('Something went wrong',
                style: GoogleFonts.inter(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary, height: 1.5,
                )),
            const SizedBox(height: 8),
            Text(
              'Make sure your Azure OpenAI key is set via --dart-define.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.textMuted, height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
