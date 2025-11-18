import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// About screen with app information
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Logo/Icon
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.favorite,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App Name
          Text(
            'Rebuild Mama',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Version
          Text(
            'Version 1.0.0',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Description
          Text(
            'About Rebuild Mama',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Rebuild Mama is your comprehensive postpartum recovery companion, designed to help new mothers safely rebuild their core strength and pelvic floor health.\n\n'
            'Our app provides:\n'
            '• Personalized workout programs based on your delivery type and recovery stage\n'
            '• Pelvic floor exercises and Kegel trainer\n'
            '• Diastasis recti assessment and tracking\n'
            '• Progress monitoring with photos and measurements\n'
            '• SOS routines for immediate relief\n'
            '• Safe, evidence-based exercises designed for postpartum recovery',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Mission
          Text(
            'Our Mission',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We believe every mother deserves access to safe, effective postpartum recovery resources. '
            'Our mission is to empower mothers with the knowledge and tools they need to rebuild their strength, '
            'confidence, and health after childbirth.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Contact & Support
          Text(
            'Contact & Support',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          _buildContactTile(
            context,
            theme,
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'kashifumair1011@gmail.com',
            onTap: () => _launchEmail('kashifumair1011@gmail.com'),
          ),

          const SizedBox(height: 32),

          // Legal
          Text(
            'Legal',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/settings/privacy'),
          ),

          const SizedBox(height: 32),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Medical Disclaimer',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This app is designed to provide information and support for postpartum recovery. '
                  'It is not a substitute for professional medical advice, diagnosis, or treatment. '
                  'Always seek the advice of your physician or other qualified health provider before '
                  'starting any new exercise program.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Copyright
          Text(
            '© ${DateTime.now().year} Rebuild Mama. All rights reserved.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Rebuild Mama Support',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}
