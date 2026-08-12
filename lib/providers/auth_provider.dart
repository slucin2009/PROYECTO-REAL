import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_fix/services/auth_service.dart';
import 'package:campus_fix/models/app_user.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.instance.authStateChanges();
});

final authUserProvider = Provider<User?>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.maybeWhen(data: (user) => user, orElse: () => null);
});

final isAnonymousProvider = Provider<bool>((ref) {
  final user = ref.watch(authUserProvider);
  return user?.isAnonymous == true;
});

final studentModeProvider = StateProvider<bool>((ref) => false);

final studentSessionIdProvider = StateProvider<String?>((ref) => null);

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final auth = ref.watch(authStateProvider);
  return auth.when(
    data: (user) {
      if (user == null || user.isAnonymous) return null;
      return AuthService.instance.loadProfile(user);
    },
    loading: () => null,
    error: (error, stackTrace) => null,
  );
});

final signInProvider = Provider((ref) => AuthService.instance);
