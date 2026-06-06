import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final PageController _pageController;

  static const int _totalSteps = 4;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    final state = ref.read(onboardingProvider);
    if (state.currentStep < _totalSteps - 1) {
      ref.read(onboardingProvider.notifier).nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _goBack() {
    final state = ref.read(onboardingProvider);
    if (state.currentStep > 0) {
      ref.read(onboardingProvider.notifier).prevStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) context.go('/');
  }

  bool _canProceed(OnboardingState s) {
    switch (s.currentStep) {
      case 0: return s.goal != null;
      case 1: return s.level != null;
      case 2: return s.equipment.isNotEmpty;
      case 3: return s.style != null;
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final progress = (state.currentStep + 1) / _totalSteps;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // ── Top Bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  children: [
                    // Back button
                    AnimatedOpacity(
                      opacity: state.currentStep > 0 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: _goBack,
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1E2D48)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textSecondary, size: 16,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Step indicator
                    Text(
                      '${state.currentStep + 1} of $_totalSteps',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13, fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Skip
                    GestureDetector(
                      onTap: () async {
                        // Allow skipping with defaults
                        final notifier = ref.read(onboardingProvider.notifier);
                        if (ref.read(onboardingProvider).goal == null) {
                          notifier.setGoal(FitnessGoal.generalFitness);
                        }
                        if (ref.read(onboardingProvider).level == null) {
                          notifier.setLevel(FitnessLevel.beginner);
                        }
                        if (ref.read(onboardingProvider).equipment.isEmpty) {
                          notifier.toggleEquipment(Equipment.none);
                        }
                        if (ref.read(onboardingProvider).style == null) {
                          notifier.setStyle(WorkoutStyle.mixed);
                        }
                        await _finish();
                      },
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 13, fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Progress Bar ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surfaceCard,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 4,
                  ),
                ),
              ),

              // ── Pages ────────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _GoalStep(),
                    _LevelStep(),
                    _EquipmentStep(),
                    _StyleStep(),
                  ],
                ),
              ),

              // ── CTA Button ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: AnimatedOpacity(
                  opacity: _canProceed(state) ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: _canProceed(state) ? _goNext : null,
                    child: Text(
                      state.currentStep == _totalSteps - 1
                          ? '🚀  Start Training'
                          : 'Continue',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Goal
// ─────────────────────────────────────────────────────────────────────────────
class _GoalStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).goal;
    return _StepWrapper(
      title: "What's your\nfitness goal?",
      subtitle: 'We\'ll tailor your plan around what matters most to you.',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: FitnessGoal.values.map((goal) {
          final isSelected = selected == goal;
          return _SelectCard(
            emoji: goal.emoji,
            label: goal.label,
            isSelected: isSelected,
            onTap: () => ref.read(onboardingProvider.notifier).setGoal(goal),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Fitness Level
// ─────────────────────────────────────────────────────────────────────────────
class _LevelStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).level;
    return _StepWrapper(
      title: 'How experienced\nare you?',
      subtitle: 'Be honest — we\'ll make sure the plan fits your level.',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: FitnessLevel.values.map((level) {
          final isSelected = selected == level;
          return _SelectCard(
            emoji: isSelected ? '✅' : ['🌱', '🔥', '⚡'][FitnessLevel.values.indexOf(level)],
            label: level.label,
            subtitle: level.description,
            isSelected: isSelected,
            onTap: () => ref.read(onboardingProvider.notifier).setLevel(level),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Equipment (multi-select)
// ─────────────────────────────────────────────────────────────────────────────
class _EquipmentStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).equipment;
    return _StepWrapper(
      title: 'What equipment\ndo you have?',
      subtitle: 'Select all that apply — we\'ll include the right exercises.',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: Equipment.values.map((e) {
          final isSelected = selected.contains(e);
          return _SelectCard(
            emoji: e.emoji,
            label: e.label,
            isSelected: isSelected,
            isMulti: true,
            onTap: () => ref.read(onboardingProvider.notifier).toggleEquipment(e),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 4 — Workout Style
// ─────────────────────────────────────────────────────────────────────────────
class _StyleStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).style;
    return _StepWrapper(
      title: 'How do you like\nto train?',
      subtitle: 'Your preference shapes the feel of every session.',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: WorkoutStyle.values.map((style) {
          final isSelected = selected == style;
          return _SelectCard(
            emoji: style.emoji,
            label: style.label,
            isSelected: isSelected,
            onTap: () => ref.read(onboardingProvider.notifier).setStyle(style),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StepWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepWrapper({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 32, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, height: 1.2,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 15, color: AppColors.textSecondary, height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: child),
      ],
    );
  }
}

class _SelectCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String? subtitle;
  final bool isSelected;
  final bool isMulti;
  final VoidCallback onTap;

  const _SelectCard({
    required this.emoji,
    required this.label,
    this.subtitle,
    required this.isSelected,
    this.isMulti = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFF1E2D48),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: isMulti
                    ? BorderRadius.circular(6)
                    : BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: AppColors.background)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
