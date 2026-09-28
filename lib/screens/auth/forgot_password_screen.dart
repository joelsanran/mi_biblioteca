import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _authService.sendPasswordReset(_emailCtrl.text.trim());
      if (mounted) setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.code == 'user-not-found'
              ? 'No existe una cuenta con ese correo'
              : 'Error: ${e.message}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _buildSentMessage() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset, size: 56, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
              if (!v.contains('@')) return 'Correo inválido';
              return null;
            },
          ),
          const SizedBox(height: 24),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _handleReset,
                  child: const Text('Enviar enlace'),
                ),
        ],
      ),
    );
  }

  Widget _buildSentMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_read, size: 64, color: AppColors.success),
        const SizedBox(height: 16),
        const Text(
          '¡Listo! Revisa tu correo',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Enviamos un enlace a ${_emailCtrl.text.trim()} para restablecer tu contraseña.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textLight),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Volver al inicio de sesión'),
        ),
      ],
    );
  }
}