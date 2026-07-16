import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

class AuthController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // État initial inactif (AsyncData(null))
  }

  Future<bool> signIn(String email, String password) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() => authRepository.signIn(email, password));
    return !state.hasError;
  }

  Future<bool> signUp(String email, String password) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() => authRepository.signUp(email, password));
    return !state.hasError;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() => authRepository.signOut());
  }
}

final authControllerProvider = AsyncNotifierProvider.autoDispose<AuthController, void>(() {
  return AuthController();
});
