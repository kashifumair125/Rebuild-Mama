import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../providers/workout_provider.dart';
import '../../../providers/auth_provider.dart';

/// Screen that celebrates workout completion and shows stats
class WorkoutCompleteScreen extends ConsumerStatefulWidget {
  const WorkoutCompleteScreen({super.key});

  @override
  ConsumerState<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends ConsumerState<WorkoutCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = ref.watch(currentUserIdProvider);

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please log in to see your stats'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final statsAsync = ref.watch(workoutSessionStatsProvider(int.parse(userId)));
    final streakAsync = ref.watch(workoutStreakProvider(int.parse(userId)));

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: statsAsync.when(
          data: (stats) => streakAsync.when(
            data: (streak) => _buildContent(context, theme, stats, streak),
            loading: () => _buildLoadingView(),
            error: (error, stack) => _buildContent(context, theme, stats, 0),
          ),
          loading: () => _buildLoadingView(),
          error: (error, stack) => _buildErrorView(context, theme, error.toString()),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> stats,
    int streak,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Celebration animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        // Success icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Congratulations text
                        Text(
                          'Workout Complete!',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Motivational message
                        Text(
                          _getMotivationalMessage(stats),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Stats cards
                _buildStatsCard(theme, stats, streak),

                const SizedBox(height: 24),

                // Progress indicator
                if (streak > 0) _buildStreakCard(theme, streak),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // Action buttons
        _buildActionButtons(context, theme),
      ],
    );
  }

  Widget _buildStatsCard(ThemeData theme, Map<String, dynamic> stats, int streak) {
    final totalSessions = stats['totalSessions'] ?? 0;
    final totalTime = stats['totalWorkoutTime'] ?? 0;
    final totalCalories = stats['totalCaloriesBurned'] ?? 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Stats',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    Icons.fitness_center,
                    '$totalSessions',
                    'Workouts',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    Icons.timer,
                    '$totalTime min',
                    'Total Time',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    Icons.local_fire_department,
                    '$totalCalories',
                    'Calories',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    Icons.calendar_today,
                    '$streak days',
                    'Streak',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(ThemeData theme, int streak) {
    return Card(
      elevation: 2,
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You\'re on a $streak-day streak!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keep it up! Come back tomorrow to continue your streak.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Home button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Back to Home',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // View progress button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () => context.push('/progress'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'View Progress',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorView(BuildContext context, ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading stats',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }

  String _getMotivationalMessage(Map<String, dynamic> stats) {
    final totalSessions = stats['completedSessions'] ?? 0;

    if (totalSessions == 1) {
      return 'Great start! You\'ve completed your first workout!';
    } else if (totalSessions < 5) {
      return 'You\'re building a great habit! Keep going!';
    } else if (totalSessions < 10) {
      return 'Amazing progress! You\'re getting stronger every day!';
    } else if (totalSessions < 20) {
      return 'Incredible dedication! You\'re a fitness champion!';
    } else {
      return 'You\'re unstoppable! Your commitment is inspiring!';
    }
  }
}
