import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../../providers/progress_provider.dart';
import '../../../providers/assessment_provider.dart';
import '../../../database/app_database.dart';
import '../../../providers/database_provider.dart';
import '../../widgets/diastasis_chart_widget.dart';
import '../../widgets/pelvic_floor_strength_indicator.dart';
import '../../widgets/workout_calendar_heatmap.dart';
import '../../widgets/photo_progress_timeline.dart';
import '../../widgets/achievement_badges.dart';
import '../../widgets/progress_summary_card.dart';
import '../../widgets/gap_width_selector.dart';
import '../../widgets/custom_segmented_button.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate aspect ratio based on screen width
        final screenWidth = constraints.maxWidth;
        final cardWidth = (screenWidth - 12) / 2;
        // Ensure minimum height for content
        final cardHeight = cardWidth / 1.3;
        final aspectRatio = cardWidth / cardHeight;

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: aspectRatio.clamp(1.0, 1.4),
          children: [
            _buildStatCard(
              theme,
              'Streak',
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
      },
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasData ? color : theme.colorScheme.onSurface.withOpacity(0.3),
                ),
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
    double? gapWidth;
    bool? hasDome;
    String? separation;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);

          return AlertDialog(
            title: const Text('Log Diastasis Measurement'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GapWidthSelector(
                    selectedGap: gapWidth,
                    onGapSelected: (gap) {
                      setState(() {
                        gapWidth = gap;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomSegmentedButton(
                    label: 'Is there a visible dome when standing?',
                    value: hasDome,
                    onChanged: (value) {
                      setState(() {
                        hasDome = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Visual Separation Assessment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...[
                    {'value': 'slight', 'label': 'Slight'},
                    {'value': 'moderate', 'label': 'Moderate'},
                    {'value': 'severe', 'label': 'Severe'},
                  ].map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setState(() => separation = option['value']),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: separation == option['value']
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: separation == option['value']
                                ? theme.colorScheme.primary
                                : Colors.grey.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              separation == option['value']
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: separation == option['value']
                                  ? theme.colorScheme.primary
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              option['label']!,
                              style: TextStyle(
                                fontWeight: separation == option['value']
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: separation == option['value']
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: gapWidth != null && hasDome != null && separation != null
                    ? () {
                        ref.read(diastasisMeasurementSubmitterProvider.notifier).submitMeasurement(
                          gapWidth: gapWidth!,
                          hasDome: hasDome!,
                          separationVisual: separation!,
                        );
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Measurement saved successfully!')),
                        );
                        // Refresh data
                        ref.invalidate(diastasisProgressStreamProvider);
                      }
                    : null,
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddPhotoDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Progress Photo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Photos are stored only on your device',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    try {
      // Save to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final photoDir = Directory('${appDir.path}/progress_photos');
      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }

      final fileName = 'progress_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${photoDir.path}/$fileName';

      // Copy file to app directory
      final file = File(pickedFile.path);
      await file.copy(savedPath);

      // Get user ID and calculate week number
      final userId = ref.read(userIdProvider);
      if (userId == null) return;

      final db = ref.read(appDatabaseProvider);

      // Calculate week number (simplified - from first photo or week 1)
      final existingPhotos = await db.progressDao.getPhotoProgress(userId);
      int weekNumber = 1;
      if (existingPhotos.isNotEmpty) {
        final firstPhoto = existingPhotos.last;
        final daysDiff = DateTime.now().difference(firstPhoto.recordedAt).inDays;
        weekNumber = (daysDiff / 7).floor() + 1;
      }

      // Save to database
      final progress = ProgressRecordsCompanion(
        userId: drift.Value(userId),
        type: const drift.Value('photo'),
        value: drift.Value({'photoPath': savedPath}),
        weekNumber: drift.Value(weekNumber),
        recordedAt: drift.Value(DateTime.now()),
      );

      await db.progressDao.insertProgress(progress);

      // Refresh photo progress
      ref.invalidate(photoProgressProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving photo: $e')),
        );
      }
    }
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Progress Report'),
        content: const Text(
          'Export your progress data as a PDF report that you can share with your healthcare provider.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
            },
            child: const Text('Export PDF'),
          ),
        ],
      ),
    );
  }
}
