import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../planner/screens/planner_screen.dart';
import '../planner/providers/planner_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;

  final _tabs = [
    const _DashboardTab(),
    const PlannerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _tabs[_selectedTab],
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.home_rounded, label: 'Home'),
      (icon: Icons.calendar_today_rounded, label: 'My Plan'),
      (icon: Icons.videocam_rounded, label: 'Train'),
      (icon: Icons.bar_chart_rounded, label: 'Progress'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Color(0xFF1E2D48), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isSelected = i == selectedIndex;
              final isComingSoon = i >= 2;

              return GestureDetector(
                onTap: isComingSoon ? null : () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected
                            ? AppColors.primary
                            : isComingSoon
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : isComingSoon
                                  ? AppColors.textMuted
                                  : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Tab (Home)
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planState = ref.watch(plannerProvider);
    final hasPlan = planState.status == PlanStatus.loaded;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          expandedHeight: 120,
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good morning 👋',
                        style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        )),
                    Text('KinetiQ',
                        style: GoogleFonts.inter(
                          fontSize: 22, fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary, letterSpacing: -0.5,
                          height: 1.1,
                        )),
                  ],
                ),
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.background, size: 22),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _StreakRow(),
              const SizedBox(height: 28),
              hasPlan ? _TodayWorkoutCard(plan: planState) : _GeneratePlanCard(),
              const SizedBox(height: 28),
              Text('Quick Start',
                  style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 16),
              _QuickActions(),
              const SizedBox(height: 28),
              _CameraTeaser(),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _StreakRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(label: '🔥 Streak', value: '0 days'),
        const SizedBox(width: 12),
        _StatChip(label: '💪 Sessions', value: '0 total'),
        const SizedBox(width: 12),
        _StatChip(label: '⭐ Form Avg', value: '—'),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E2D48)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Today's Workout Card (when plan exists)
// ─────────────────────────────────────────────────────────────────────────────
class _TodayWorkoutCard extends StatelessWidget {
  final PlannerState plan;
  const _TodayWorkoutCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final today = plan.currentWeek?.days.firstWhere(
      (d) => !d.isRest,
      orElse: () => plan.currentWeek!.days.first,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2E1F), Color(0xFF0A1A3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: Text("TODAY'S WORKOUT",
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppColors.primary, letterSpacing: 1,
                )),
          ),
          const SizedBox(height: 14),
          Text(today?.sessionName ?? 'Workout',
              style: GoogleFonts.inter(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, height: 1.2,
              )),
          const SizedBox(height: 6),
          Text(
            '${today?.exercises.length ?? 0} exercises · ${today?.estimatedMinutes ?? 30} min',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('▶  Start Workout',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generate Plan Card (when no plan yet)
// ─────────────────────────────────────────────────────────────────────────────
class _GeneratePlanCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2E1F), Color(0xFF0A1A3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set up your plan\nto get started! 🎯',
              style: GoogleFonts.inter(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, height: 1.2,
              )),
          const SizedBox(height: 8),
          Text('KinetiQ AI will build a personalised 4-week plan using Azure OpenAI.',
              style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary, height: 1.5,
              )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final profile = ref.read(userProfileProvider).valueOrNull;
              if (profile != null) {
                await ref.read(plannerProvider.notifier).generatePlan(profile);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('✨  Generate My Plan',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.videocam_rounded, 'label': 'Start\nWorkout', 'color': AppColors.primary},
      {'icon': Icons.auto_graph_rounded, 'label': 'My\nProgress', 'color': AppColors.accent},
      {'icon': Icons.library_books_rounded, 'label': 'Exercise\nLibrary', 'color': const Color(0xFFFFD60A)},
      {'icon': Icons.settings_rounded, 'label': 'Settings', 'color': AppColors.textSecondary},
    ];
    return Row(
      children: actions.asMap().entries.map((entry) {
        final i = entry.key;
        final a = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < actions.length - 1 ? 12.0 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E2D48)),
              ),
              child: Column(
                children: [
                  Icon(a['icon'] as IconData, color: a['color'] as Color, size: 26),
                  const SizedBox(height: 8),
                  Text(a['label'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary, height: 1.3,
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CameraTeaser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E2D48)),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0D3A5C), Color(0xFF0A2240)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.remove_red_eye_rounded, color: AppColors.accent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Form Detection',
                    style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 4),
                Text('Real-time pose tracking & rep counting — Day 4!',
                    style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary, height: 1.4,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Soon',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
