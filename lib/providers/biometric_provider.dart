import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/biometric_service.dart';

part 'biometric_provider.g.dart';

@riverpod
BiometricService biometricService(BiometricServiceRef ref) {
  return BiometricService();
}

@riverpod
Future<bool> isBiometricAvailable(IsBiometricAvailableRef ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.isBiometricAvailable();
}

@riverpod
Future<bool> isBiometricEnabled(IsBiometricEnabledRef ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.isBiometricEnabled();
}
