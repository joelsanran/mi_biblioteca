import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';

class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final p = value.text;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _item('Mínimo 8 caracteres', Validators.hasMinLength(p)),
            _item('Una letra mayúscula', Validators.hasUppercase(p)),
            _item('Un carácter especial (ej. ! @ # %)',
                Validators.hasSpecialChar(p)),
          ],
        );
      },
    );
  }

  Widget _item(String text, bool met) {
    final color = met ? AppColors.success : AppColors.textLight;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              met ? Icons.check_circle : Icons.radio_button_unchecked,
              key: ValueKey(met),
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: met ? FontWeight.w600 : FontWeight.normal,
            ),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}