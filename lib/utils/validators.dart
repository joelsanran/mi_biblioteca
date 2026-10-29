class Validators {
  // ---------- Contraseña ----------
  static const int passwordMinLength = 8;

  static bool hasMinLength(String p) => p.length >= passwordMinLength;

  static bool hasUppercase(String p) =>
      RegExp(r'\p{Lu}', unicode: true).hasMatch(p);

  static bool hasSpecialChar(String p) =>
      RegExp(r'[^\p{L}\p{N}\s]', unicode: true).hasMatch(p);

  static String? password(String? value) {
    final p = value ?? '';
    if (p.isEmpty) return 'Ingresa una contraseña';
    if (!hasMinLength(p)) return 'Mínimo 8 caracteres';
    if (!hasUppercase(p)) return 'Debe incluir una mayúscula';
    if (!hasSpecialChar(p)) return 'Debe incluir un carácter especial';
    return null;
  }

  // ---------- Correo ----------
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu correo';
    final text = value.trim();
    const invalid = 'Ingresa un correo válido (ej. nombre@correo.com)';

    final format =
        RegExp(r'^[A-Za-z0-9._%+\-]+@([A-Za-z0-9\-]+\.)+[A-Za-z]{2,}$');
    if (!format.hasMatch(text)) return invalid;

    final local = text.split('@').first;
    if (local.startsWith('.') || local.endsWith('.') || text.contains('..')) {
      return invalid;
    }

    // El nombre del dominio debe tener al menos una letra (rechaza x@198382.com)
    final domain = text.split('@').last;
    final domainName = domain.substring(0, domain.lastIndexOf('.'));
    if (!RegExp(r'[A-Za-z]').hasMatch(domainName)) {
      return 'El dominio del correo no es válido';
    }
    return null;
  }

  // ---------- Nombre de persona ----------
  static String? personName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu nombre';
    final text = value.trim();
    if (text.length < 2) return 'El nombre es demasiado corto';
    if (text.length > 50) return 'El nombre es demasiado largo';
    final allowed = RegExp(r"^[\p{L}][\p{L}\s.\-']*$", unicode: true);
    if (!allowed.hasMatch(text)) return 'El nombre solo puede contener letras';
    return null;
  }

  // ---------- Autor ----------
  static String? author(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El autor es obligatorio';
    }
    final text = value.trim();
    final onlyAllowed = RegExp(r"^[\p{L}\s.\-']+$", unicode: true);
    final hasLetter = RegExp(r'\p{L}', unicode: true);
    if (!onlyAllowed.hasMatch(text) || !hasLetter.hasMatch(text)) {
      return 'El autor solo puede contener letras';
    }
    return null;
  }

  // ---------- Año de publicación (opcional) ----------
  static String? year(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d{4}$').hasMatch(text)) {
      return 'Ingresa un año de 4 dígitos (ej. 1999)';
    }
    final y = int.parse(text);
    final current = DateTime.now().year;
    if (y < 1000 || y > current) {
      return 'El año debe estar entre 1000 y $current';
    }
    return null;
  }

  // ---------- Página de lectura (opcional) ----------
  static String? page(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d{1,4}$').hasMatch(text)) {
      return 'Ingresa un número de hasta 4 dígitos';
    }
    if (int.parse(text) < 1) return 'La página debe ser mayor que 0';
    return null;
  }
}