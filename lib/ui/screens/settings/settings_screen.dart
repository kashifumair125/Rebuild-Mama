import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/preferences_provider.dart';
import '../../../utils/logger.dart';

/// Settings screen for app preferences and account management
/// Provides access to theme, notifications, privacy, and account settings
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(isDarkModeEnabledProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // User Profile Section
          userAsync.when(
            data: (user) {
              if (user != null) {
                return _UserProfileSection(
                  userName: user.displayName ?? 'User',
                  userEmail: user.email ?? '',
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const Divider(),

          // Appearance Section
          _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark themes'),
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(isDarkModeEnabledProvider.notifier).setDarkMode(value);
            },
          ),

          const Divider(),

          // Notifications Section
          _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive workout reminders and updates'),
            secondary: Icon(
              Icons.notifications_outlined,
              color: theme.colorScheme.primary,
            ),
            value: notificationsEnabled,
            onChanged: (value) {
              ref
                  .read(notificationsEnabledProvider.notifier)
                  .setNotificationsEnabled(value);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Notifications enabled'
                        : 'Notifications disabled',
                  ),
                ),
              );
            },
          ),

          const Divider(),

          // App Information Section
          _SectionHeader(title: 'App Information'),
          ListTile(
            leading: Icon(
              Icons.language_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Language'),
            subtitle: const Text('English (US)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouter.language),
          ),
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouter.privacy),
          ),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
            ),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouter.about),
          ),

          const Divider(),

          // Account Section
          _SectionHeader(title: 'Account'),
          ListTile(
            leading: Icon(
              Icons.person_outline,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit Profile - Coming soon'),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.lock_outline,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Change Password - Coming soon'),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Log Out',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _showLogoutDialog(context, ref),
          ),

          const SizedBox(height: 24),

          // Danger Zone
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Danger Zone',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Delete Account',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Permanently delete your account and data'),
            onTap: () => _showDeleteAccountDialog(context, ref),
          ),

          const SizedBox(height: 24),

          // App Version
          Center(
            child: Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                final authHelpers = ref.read(authHelpersProvider.notifier);
                await authHelpers.logout();

                if (context.mounted) {
                  context.go(AppRouter.login);
                }
              } catch (e) {
                AppLogger.error('Logout failed', error: e);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  /// Show delete account confirmation dialog
  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                final authHelpers = ref.read(authHelpersProvider.notifier);
                await authHelpers.deleteAccount();

                if (context.mounted) {
                  context.go(AppRouter.login);
                }
              } catch (e) {
                AppLogger.error('Account deletion failed', error: e);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete account: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _UserProfileSection extends StatelessWidget {
  final String userName;
  final String userEmail;

  const _UserProfileSection({
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
