import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/biometric_service.dart';

/// Provider for the BiometricService
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// Provider to check if biometric authentication is available on device
final isBiometricAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.isBiometricAvailable();
});

/// Provider to check if biometric lock is enabled in app settings
final isBiometricEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.isBiometricEnabled();
});

/// StateNotifier to manage biometric enabled state
class BiometricEnabledNotifier extends StateNotifier<AsyncValue<bool>> {
  final BiometricService _service;

  BiometricEnabledNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadState();
  }

  Future<void> _loadState() async {
    state = const AsyncValue.loading();
    try {
      final enabled = await _service.isBiometricEnabled();
      state = AsyncValue.data(enabled);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> toggle() async {
    final currentValue = state.valueOrNull ?? false;

    if (!currentValue) {
      // Trying to enable - authenticate first
      final authenticated = await _service.authenticate();
      if (authenticated) {
        await _service.enableBiometric();
        state = const AsyncValue.data(true);
        return true;
      }
      return false;
    } else {
      // Disabling
      await _service.disableBiometric();
      state = const AsyncValue.data(false);
      return true;
    }
  }

  void refresh() {
    _loadState();
  }
}

/// Provider for managing biometric enabled state
final biometricEnabledNotifierProvider =
    StateNotifierProvider<BiometricEnabledNotifier, AsyncValue<bool>>((ref) {
  final service = ref.watch(biometricServiceProvider);
  return BiometricEnabledNotifier(service);
});