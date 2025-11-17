import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/workout_provider.dart';
import '../../../utils/logger.dart';

/// Home screen - Main dashboard of the app
/// Provides quick access to workouts, progress, SOS routines, and settings
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rebuild Mama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRouter.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            // User not logged in, should not happen but handle gracefully
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(AppRouter.login);
            });
            return const Center(child: CircularProgressIndicator());
          }

          return _HomeContent(
            userName: user.displayName ?? 'Mama',
            userEmail: user.email ?? '',
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          AppLogger.error('Error loading user', error: error, stackTrace: stack);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load user data',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go(AppRouter.login),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final String userName;
  final String userEmail;

  const _HomeContent({
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _WelcomeSection(userName: userName),
          const SizedBox(height: 24),

          // Quick Actions Grid
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const _QuickActionsGrid(),
          const SizedBox(height: 32),

          // Today's Workout Section
          Text(
            "Today's Workout",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const _TodayWorkoutCard(),
          const SizedBox(height: 32),

          // Progress Overview
          Text(
            'Progress Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const _ProgressOverviewSection(),
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final String userName;

  const _WelcomeSection({required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $userName!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ready to continue your recovery journey?',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: const [
        _QuickActionCard(
          title: 'Workouts',
          icon: Icons.fitness_center,
          route: AppRouter.workoutList,
        ),
        _QuickActionCard(
          title: 'Progress',
          icon: Icons.trending_up,
          route: AppRouter.progressDashboard,
        ),
        _QuickActionCard(
          title: 'SOS Relief',
          icon: Icons.healing,
          route: AppRouter.sosHome,
        ),
        _QuickActionCard(
          title: 'Kegel Trainer',
          icon: Icons.track_changes,
          route: AppRouter.kegelTrainer,
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => context.push(AppRouter.levelSelection),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Workout',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose your level and begin',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressOverviewSection extends StatelessWidget {
  const _ProgressOverviewSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _ProgressStatCard(
          title: 'Pelvic Floor',
          subtitle: 'Track your strength',
          icon: Icons.favorite_rounded,
          color: theme.colorScheme.primary,
          onTap: () => context.push(AppRouter.pelvicFloor),
        ),
        const SizedBox(height: 12),
        _ProgressStatCard(
          title: 'Diastasis Recti',
          subtitle: 'Monitor your healing',
          icon: Icons.straighten,
          color: theme.colorScheme.secondary,
          onTap: () => context.push(AppRouter.diastasisRecti),
        ),
        const SizedBox(height: 12),
        _ProgressStatCard(
          title: 'Photo Progress',
          subtitle: 'Visual tracking',
          icon: Icons.photo_camera_rounded,
          color: theme.colorScheme.tertiary,
          onTap: () => context.push(AppRouter.photoProgress),
        ),
      ],
    );
  }
}

class _ProgressStatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ProgressStatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
