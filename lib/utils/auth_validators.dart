class AuthValidators {
  static String? email(String? valor) {
    final email = valor?.trim() ?? '';

    if (email.isEmpty) {
      return 'Informe seu e-mail.';
    }

    final formatoEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!formatoEmail.hasMatch(email)) {
      return 'Digite um e-mail válido.';
    }

    return null;
  }

  static String? senha(String? valor) {
    final senha = valor ?? '';

    if (senha.isEmpty) {
      return 'Informe sua senha.';
    }

    if (senha.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }

    return null;
  }
}
