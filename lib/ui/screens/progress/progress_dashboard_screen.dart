import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/progress_provider.dart';
import '../../../database/app_database.dart';
import '../../widgets/diastasis_chart_widget.dart';
import '../../widgets/pelvic_floor_strength_indicator.dart';
import '../../widgets/workout_calendar_heatmap.dart';
import '../../widgets/photo_progress_timeline.dart';
import '../../widgets/achievement_badges.dart';
import '../../widgets/progress_summary_card.dart';
import '../../themes/colors.dart';

/// Comprehensive progress tracking dashboard with 4 main sections
class ProgressDashboardScreen extends ConsumerStatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  ConsumerState<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState
    extends ConsumerState<ProgressDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Watch all providers
    final diastasisProgressAsync = ref.watch(diastasisProgressStreamProvider);
    final pelvicFloorProgressAsync = ref.watch(pelvicFloorProgressStreamProvider);
    final workoutStreakAsync = ref.watch(workoutStreakProvider);
    final weeklyStatsAsync = ref.watch(weeklyWorkoutStatsProvider);
    final achievementsAsync = ref.watch(achievementsProvider);
    final photoProgressAsync = ref.watch(photoProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(diastasisProgressStreamProvider);
              ref.invalidate(pelvicFloorProgressStreamProvider);
              ref.invalidate(workoutStreakProvider);
              ref.invalidate(weeklyWorkoutStatsProvider);
              ref.invalidate(achievementsProvider);
              ref.invalidate(photoProgressProvider);
            },
            tooltip: 'Refresh',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Export Report'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'export') {
                _showExportDialog(context);
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Diastasis'),
            Tab(text: 'Pelvic Floor'),
            Tab(text: 'Workouts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Overview
          _buildOverviewTab(
            context,
            theme,
            diastasisProgressAsync,
            pelvicFloorProgressAsync,
            workoutStreakAsync,
            weeklyStatsAsync,
            achievementsAsync,
            photoProgressAsync,
          ),
          // Tab 2: Diastasis Recti
          _buildDiastasisTab(context, theme, diastasisProgressAsync),
          // Tab 3: Pelvic Floor
          _buildPelvicFloorTab(context, theme, pelvicFloorProgressAsync),
          // Tab 4: Workouts & Photos
          _buildWorkoutsTab(
            context,
            theme,
            workoutStreakAsync,
            weeklyStatsAsync,
            photoProgressAsync,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    ThemeData theme,
    AsyncValue<List<Progress>> diastasisProgress,
    AsyncValue<List<Progress>> pelvicFloorProgress,
    AsyncValue<WorkoutStreak> workoutStreak,
    AsyncValue<WeeklyWorkoutStats> weeklyStats,
    AsyncValue<List<Achievement>> achievements,
    AsyncValue<List<Progress>> photoProgress,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(diastasisProgressStreamProvider);
        ref.invalidate(pelvicFloorProgressStreamProvider);
        ref.invalidate(workoutStreakProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Summary Card
            workoutStreak.when(
              data: (streak) {
                final healthScore = ProgressSummaryCard.calculateHealthScore(
                  diastasisImprovement: null,
                  pelvicFloorImprovement: null,
                  workoutStreak: streak.currentStreak,
                  completedWorkouts: 0,
                );

                return ProgressSummaryCard(
                  startDate: DateTime.now().subtract(const Duration(days: 14)),
                  weekNumber: 3,
                  healthScore: healthScore,
                  motivationalMessage: ProgressSummaryCard.getMotivationalMessage(
                    healthScore,
                    3,
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Quick Stats Grid
            workoutStreak.when(
              data: (streak) => weeklyStats.when(
                data: (stats) => _buildQuickStatsGrid(theme, streak, stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Achievements
            achievements.when(
              data: (achievementList) => AchievementBadges(
                achievements: achievementList,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsGrid(
    ThemeData theme,
    WorkoutStreak streak,
    WeeklyWorkoutStats stats,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          theme,
          'Workout Streak',
          '${streak.currentStreak} days',
          Icons.local_fire_department,
          AppColors.danger,
          streak.currentStreak > 0,
        ),
        _buildStatCard(
          theme,
          'This Week',
          '${stats.workoutsThisWeek}/7',
          Icons.calendar_today,
          AppColors.primary,
          stats.workoutsThisWeek > 0,
        ),
        _buildStatCard(
          theme,
          'Total Time',
          '${stats.totalTime} min',
          Icons.timer,
          AppColors.info,
          stats.totalTime > 0,
        ),
        _buildStatCard(
          theme,
          'Calories',
          '${stats.caloriesBurned} kcal',
          Icons.local_fire_department_outlined,
          AppColors.warning,
          stats.caloriesBurned > 0,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
    bool hasData,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: hasData ? color : theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiastasisTab(
    BuildContext context,
    ThemeData theme,
    AsyncValue<List<Progress>> diastasisProgress,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(diastasisProgressStreamProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Gap',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '2.5 finger widths',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Goal',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              Text(
                                '1-2 finger widths',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Est. Time',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              Text(
                                '4-6 weeks',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chart
            diastasisProgress.when(
              data: (progress) => DiastasisChartWidget(
                progressData: progress,
                targetGap: 2.0,
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Center(
                child: Text('Error loading progress: $error'),
              ),
            ),
            const SizedBox(height: 24),

            // Log New Measurement Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  _showLogMeasurementDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Log New Measurement'),
              ),
            ),
            const SizedBox(height: 16),

            // Tips Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(
                        'Tips for Improvement',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem('Avoid straining exercises that increase abdominal pressure'),
                  _buildTipItem('Focus on core strengthening exercises'),
                  _buildTipItem('Maintain proper posture throughout the day'),
                  _buildTipItem('Be patient - healing takes time'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(tip)),
        ],
      ),
    );
  }

  Widget _buildPelvicFloorTab(
    BuildContext context,
    ThemeData theme,
    AsyncValue<List<Progress>> pelvicFloorProgress,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(pelvicFloorProgressStreamProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: pelvicFloorProgress.when(
          data: (progress) => PelvicFloorStrengthIndicator(
            progressData: progress,
            currentLevel: 7, // Mock data
            onAssessment: () {
              Navigator.of(context).pushNamed('/pelvic-floor-assessment');
            },
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Center(
            child: Text('Error loading progress: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutsTab(
    BuildContext context,
    ThemeData theme,
    AsyncValue<WorkoutStreak> workoutStreak,
    AsyncValue<WeeklyWorkoutStats> weeklyStats,
    AsyncValue<List<Progress>> photoProgress,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(workoutStreakProvider);
        ref.invalidate(weeklyWorkoutStatsProvider);
        ref.invalidate(photoProgressProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Stats Card
            workoutStreak.when(
              data: (streak) => weeklyStats.when(
                data: (stats) => Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (streak.currentStreak > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.danger,
                                  AppColors.danger.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${streak.currentStreak}-day streak!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          'This Week',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildWeekStat(theme, 'Workouts', '${stats.workoutsThisWeek}/7'),
                        const SizedBox(height: 8),
                        _buildWeekStat(theme, 'Total Time', '${stats.totalTime} minutes'),
                        const SizedBox(height: 8),
                        _buildWeekStat(theme, 'Calories', '${stats.caloriesBurned} kcal'),
                      ],
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Calendar Heatmap
            // Note: This would need actual workout session data
            const WorkoutCalendarHeatmap(
              sessions: [], // TODO: Pass actual workout sessions
              monthsToShow: 3,
            ),
            const SizedBox(height: 24),

            // Photo Progress
            photoProgress.when(
              data: (photos) => PhotoProgressTimeline(
                photoRecords: photos,
                onAddPhoto: () {
                  _showAddPhotoDialog(context);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekStat(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showLogMeasurementDialog(BuildContext context) {
    // TODO: Implement measurement logging dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log measurement dialog - TODO')),
    );
  }

  void _showAddPhotoDialog(BuildContext context) {
    // TODO: Implement photo upload dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add photo dialog - TODO')),
    );
  }

  void _showExportDialog(BuildContext context) {
    // TODO: Implement PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature - TODO')),
    );
  }
}
