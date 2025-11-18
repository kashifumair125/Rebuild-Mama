import 'package:flutter/material.dart';

/// Privacy Policy screen
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Privacy Policy',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${DateTime.now().year}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          _buildSection(
            theme,
            'Introduction',
            'Rebuild Mama ("we", "our", or "us") is committed to protecting your privacy. '
            'This Privacy Policy explains how we collect, use, disclose, and safeguard your '
            'information when you use our mobile application.',
          ),

          _buildSection(
            theme,
            'Information We Collect',
            'We collect information that you provide directly to us, including:\n\n'
            '• Account Information: Name, email address, and password\n'
            '• Health Data: Postpartum recovery information, delivery type, weeks postpartum\n'
            '• Progress Data: Workout sessions, exercise completion, and progress photos\n'
            '• Usage Data: App interactions, features used, and session duration',
          ),

          _buildSection(
            theme,
            'How We Use Your Information',
            'We use the information we collect to:\n\n'
            '• Provide, maintain, and improve our services\n'
            '• Personalize your workout experience\n'
            '• Track your progress and provide insights\n'
            '• Send you updates and notifications (with your consent)\n'
            '• Respond to your comments and questions\n'
            '• Ensure the security of our services',
          ),

          _buildSection(
            theme,
            'Data Storage and Security',
            'Your data is stored securely using industry-standard encryption. '
            'We implement appropriate technical and organizational measures to protect your '
            'personal information against unauthorized access, alteration, disclosure, or destruction.\n\n'
            'Your health and workout data is stored locally on your device and, if you choose, '
            'synced to secure cloud servers using Firebase services.',
          ),

          _buildSection(
            theme,
            'Data Sharing',
            'We do not sell, trade, or rent your personal information to third parties. '
            'We may share your information only in the following circumstances:\n\n'
            '• With your consent\n'
            '• To comply with legal obligations\n'
            '• To protect our rights and property\n'
            '• With service providers who assist in app operations (subject to confidentiality agreements)',
          ),

          _buildSection(
            theme,
            'Your Rights',
            'You have the right to:\n\n'
            '• Access your personal data\n'
            '• Correct inaccurate data\n'
            '• Request deletion of your data\n'
            '• Export your data\n'
            '• Opt-out of notifications\n'
            '• Withdraw consent at any time',
          ),

          _buildSection(
            theme,
            'Children\'s Privacy',
            'Our service is not intended for children under 18 years of age. '
            'We do not knowingly collect personal information from children under 18.',
          ),

          _buildSection(
            theme,
            'Changes to This Privacy Policy',
            'We may update our Privacy Policy from time to time. We will notify you of any '
            'changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
          ),

          _buildSection(
            theme,
            'Contact Us',
            'If you have any questions about this Privacy Policy, please contact us at:\n\n'
            'Email: kashifumair1011@gmail.com',
          ),

          const SizedBox(height: 32),

          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('I Understand'),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
