import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../providers/biometric_provider.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  @override
  void initState() {
    super.initState();
    _authenticateWithBiometric();
  }

  Future<void> _authenticateWithBiometric() async {
    final service = ref.read(biometricServiceProvider);
    
    final authenticated = await service.authenticate();
    
    if (authenticated && mounted) {
      context.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fingerprint,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Unlock with Biometrics',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: _authenticateWithBiometric,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Authenticate'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go(AppRouter.login),
              child: const Text('Use Password Instead'),
            ),
          ],
        ),
      ),
    );
  }
}
