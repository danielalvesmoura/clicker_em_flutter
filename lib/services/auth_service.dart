import 'package:firebase_auth/firebase_auth.dart';

class AuthServiceException implements Exception {
  final String mensagem;

  const AuthServiceException(this.mensagem);

  @override
  String toString() => mensagem;
}

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Future<void> fazerLogin({
    required String email,
    required String senha,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
    } on FirebaseAuthException catch (erro) {
      throw AuthServiceException(_mensagemDoFirebase(erro));
    }
  }

  Future<void> criarConta({
    required String email,
    required String senha,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
    } on FirebaseAuthException catch (erro) {
      throw AuthServiceException(_mensagemDoFirebase(erro));
    }
  }

  Future<void> sair() async {
    await _auth.signOut();
  }

  String _mensagemDoFirebase(FirebaseAuthException erro) {
    switch (erro.code) {
      case 'invalid-email':
        return 'O e-mail informado é inválido.';
      case 'email-already-in-use':
        return 'Já existe uma conta cadastrada com este e-mail.';
      case 'weak-password':
        return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
      case 'network-request-failed':
        return 'Não foi possível conectar ao Firebase. Verifique sua internet.';
      default:
        return erro.message ?? 'Não foi possível concluir a autenticação.';
    }
  }
}
