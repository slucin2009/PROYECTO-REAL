import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_fix/core/constants/app_strings.dart';
import 'package:campus_fix/providers/auth_provider.dart';
import 'package:campus_fix/widgets/app_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(signInProvider).signIn(_emailController.text.trim(), _passwordController.text.trim());
    } on FirebaseAuthException catch (error) {
      setState(() {
        _errorMessage = error.message ?? 'Credenciales incorrectas.';
      });
    } catch (_) {
      setState(() {
        _errorMessage = AppStrings.errorGeneral;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _enterStudentMode() {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    ref.read(studentSessionIdProvider.notifier).state = const Uuid().v4();
    ref.read(studentModeProvider.notifier).state = true;
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(AppStrings.appName, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(AppStrings.appSubtitle, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: AppStrings.emailHint),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Ingresa tu correo institucional.';
                                if (!value.contains('@')) return 'Ingresa un correo válido.';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(labelText: AppStrings.passwordHint),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Ingresa tu contraseña.';
                                if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres.';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ),
                      AppButton(label: AppStrings.signInButton, onPressed: _signIn, isLoading: _loading),
                      const SizedBox(height: 20),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('O'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: _enterStudentMode,
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                        child: const Text(AppStrings.studentModeButton),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 