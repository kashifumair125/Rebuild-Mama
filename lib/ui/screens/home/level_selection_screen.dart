import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../config/routes.dart';
import '../../../providers/auth_provider.dart';

class LevelSelectionScreen extends ConsumerWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Choose Your Level'),
        centerTitle: true,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(AppRouter.login);
            });
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Your Workout Level',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a level based on your postpartum recovery stage',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Level 1: Repair (0-6 weeks postpartum)
                _LevelCard(
                  level: 1,
                  title: 'Level 1: Repair',
                  subtitle: '0-6 weeks postpartum',
                  description: 'Gentle exercises to reconnect with your core and pelvic floor',
                  color: const Color(0xFFFFB6C1), // Light pink
                  icon: Icons.healing_rounded,
                  benefits: [
                    'Gentle pelvic floor activation',
                    'Basic breathing exercises',
                    'Postural awareness',
                  ],
                  onTap: () => context.push('${AppRouter.workoutList}?level=1'),
                ),

                const SizedBox(height: 16),

                // Level 2: Rebuild (6-12 weeks postpartum)
                _LevelCard(
                  level: 2,
                  title: 'Level 2: Rebuild',
                  subtitle: '6-12 weeks postpartum',
                  description: 'Progressive strengthening of core and pelvic floor',
                  color: const Color(0xFFFFDAB9), // Peach
                  icon: Icons.trending_up_rounded,
                  benefits: [
                    'Core strengthening',
                    'Functional movements',
                    'Improved coordination',
                  ],
                  onTap: () => context.push('${AppRouter.workoutList}?level=2'),
                ),

                const SizedBox(height: 16),

                // Level 3: Strengthen (12+ weeks postpartum)
                _LevelCard(
                  level: 3,
                  title: 'Level 3: Strengthen',
                  subtitle: '12+ weeks postpartum',
                  description: 'Advanced exercises for full-body strength and endurance',
                  color: const Color(0xFFE0FFF0), // Mint
                  icon: Icons.fitness_center_rounded,
                  benefits: [
                    'Full-body strength training',
                    'High-intensity exercises',
                    'Athletic performance',
                  ],
                  onTap: () => context.push('${AppRouter.workoutList}?level=3'),
                ),

                const SizedBox(height: 24),

                // Safety Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.error.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.error,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Always consult with your healthcare provider before starting any exercise program postpartum.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading user: $error'),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final IconData icon;
  final List<String> benefits;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.icon,
    required this.benefits,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
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

                const SizedBox(height: 16),

                // Description
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 16),

                // Benefits list
                ...benefits.map((benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              benefit,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
