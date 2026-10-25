class Validators {
  /// Contraseña: mínimo 8 caracteres, al menos una letra y un número.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa una contraseña';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Debe incluir al menos una letra';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Debe incluir al menos un número';
    }
    return null;
  }

  /// Autor: solo letras (con acentos), espacios, puntos, guiones y apóstrofes.
  /// Permite nombres como "J. K. Rowling", "Jean-Paul Sartre" u "O'Brien".
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
}
