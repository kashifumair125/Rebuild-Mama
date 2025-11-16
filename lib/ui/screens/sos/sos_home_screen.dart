import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../database/app_database.dart';
import '../../../providers/sos_provider.dart';
import '../../../providers/auth_provider.dart';

/// SOS Home Screen - Quick access to emergency relief routines
class SosHomeScreen extends ConsumerWidget {
  const SosHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final routinesAsync = ref.watch(watchAllSosRoutinesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, theme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 8),
                  _buildDisclaimer(theme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          routinesAsync.when(
            data: (routines) => _buildRoutinesList(context, ref, routines),
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: _buildErrorView(context, error.toString()),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: const Color(0xFFFF6B6B), // Emergency red/pink
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'SOS Relief',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF6B6B),
                const Color(0xFFFF8E8E),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.healing,
              size: 80,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Relief Routines',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Quick relief exercises for common postpartum discomforts',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0), // Warm warning color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB74D),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFFE65100),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'These exercises provide temporary relief. If symptoms persist or worsen, please consult your healthcare provider.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFFE65100),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinesList(
    BuildContext context,
    WidgetRef ref,
    List<SosRoutine> routines,
  ) {
    if (routines.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Text(
              'No SOS routines available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final routine = routines[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildRoutineCard(context, ref, routine),
            );
          },
          childCount: routines.length,
        ),
      ),
    );
  }

  Widget _buildRoutineCard(
    BuildContext context,
    WidgetRef ref,
    SosRoutine routine,
  ) {
    final theme = Theme.of(context);
    final userId = ref.watch(currentUserIdProvider);

    // Get usage count for this routine
    final usageCountAsync = userId != null
        ? ref.watch(routineUsageCountProvider(int.parse(userId), routine.sosRoutineId))
        : null;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _startSosRoutine(context, ref, routine),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getRoutineColor(routine.orderIndex).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        routine.iconEmoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          routine.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Metadata row
              Row(
                children: [
                  _buildMetadataChip(
                    theme,
                    Icons.timer_outlined,
                    '${routine.durationMinutes} min',
                  ),
                  const SizedBox(width: 8),
                  _buildMetadataChip(
                    theme,
                    Icons.fitness_center,
                    '${routine.exerciseCount} exercises',
                  ),
                  const SizedBox(width: 8),
                  _buildDifficultyChip(theme, routine.difficulty),
                ],
              ),
              // Usage count
              if (usageCountAsync != null)
                usageCountAsync.when(
                  data: (count) {
                    if (count > 0) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Used $count ${count == 1 ? 'time' : 'times'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              // Tips
              if (routine.tips != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          routine.tips!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Safety warning
              if (routine.safetyWarning != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_outlined,
                        size: 16,
                        color: Color(0xFFC62828),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          routine.safetyWarning!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFC62828),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startSosRoutine(context, ref, routine),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getRoutineColor(routine.orderIndex),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Start Now',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(ThemeData theme, String difficulty) {
    final color = _getDifficultyColor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'moderate':
        return const Color(0xFFFF9800);
      case 'advanced':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }

  Color _getRoutineColor(int orderIndex) {
    switch (orderIndex) {
      case 1:
        return const Color(0xFF6366F1); // Indigo - Back Pain
      case 2:
        return const Color(0xFFEC4899); // Pink - Pelvic Heaviness
      case 3:
        return const Color(0xFFF59E0B); // Amber - C-Section
      case 4:
        return const Color(0xFF8B5CF6); // Purple - Diastasis
      case 5:
        return const Color(0xFF10B981); // Green - Pelvic Floor
      default:
        return const Color(0xFF6366F1);
    }
  }

  void _startSosRoutine(
    BuildContext context,
    WidgetRef ref,
    SosRoutine routine,
  ) {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to start a routine'),
        ),
      );
      return;
    }

    // Navigate to the SOS routine screen
    context.push('/sos/routine/${routine.sosRoutineId}');
  }

  Widget _buildErrorView(BuildContext context, String message) {
    final theme = Theme.of(context);
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
              'Error Loading Routines',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
