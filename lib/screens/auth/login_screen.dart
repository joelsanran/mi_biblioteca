import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/app_user.dart';
import '../../theme/app_theme.dart';
import '../user/user_main_screen.dart';
import '../admin/admin_main_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _goToHomeByRole(AppUser user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user.role == 'admin'
            ? const AdminMainScreen()
            : UserMainScreen(
                userId: user.uid,
                userName: user.name,
                userEmail: user.email,
              ),
      ),
    );
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = await _authService.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      if (user != null && mounted) {
        _goToHomeByRole(user);
      }
    } on FirebaseAuthException catch (e) {
      _showError(_authService.getAuthErrorMessage(e));
    } catch (e) {
      _showError('Ocurrió un error inesperado');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _loading = true);

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        _goToHomeByRole(user);
      }
    } catch (e) {
      _showError('Error al iniciar sesión con Google: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        height: 140,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inicia sesión para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textLight, fontSize: 15),
                  ),

                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ingresa tu correo';
                      }

                      if (!v.contains('@')) {
                        return 'Correo inválido';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }

                      if (v.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _handleEmailLogin,
                          child: const Text('Iniciar sesión'),
                        ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                    child: const Text('¿No tienes cuenta? Regístrate'),
                  ),

                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          ),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),

                  const SizedBox(height: 12),

                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'o',
                          style: TextStyle(color: AppColors.textLight),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _loading ? null : _handleGoogleLogin,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Continuar con Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
