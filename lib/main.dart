import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'widgets/update_check_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: CampusFixApp()));
}

class CampusFixApp extends ConsumerWidget {
  const CampusFixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final studentMode = ref.watch(studentModeProvider);

    final homeWidget = authState.when(
      data: (user) {
        if (user != null && !user.isAnonymous) {
          return const HomeScreen(studentMode: false);
        }
        if (studentMode) {
          return const HomeScreen(studentMode: true);
        }
        return const LoginScreen();
      },
      loading: () {
        if (studentMode) {
          return const HomeScreen(studentMode: true);
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, stackTrace) => const Scaffold(
        body: Center(child: Text(AppStrings.errorGeneral)),
      ),
    );

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: UpdateCheckWrapper(child: homeWidget),
    );
  }
}
