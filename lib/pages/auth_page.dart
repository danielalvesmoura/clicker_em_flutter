import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/auth_validators.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();

  String? _mensagemErro;
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _autenticar({required bool criarConta}) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _mensagemErro = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      if (criarConta) {
        await _authService.criarConta(
          email: _emailController.text,
          senha: _senhaController.text,
        );
      } else {
        await _authService.fazerLogin(
          email: _emailController.text,
          senha: _senhaController.text,
        );
      }
    } on AuthServiceException catch (erro) {
      if (!mounted) return;

      setState(() {
        _mensagemErro = erro.mensagem;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _mensagemErro = 'Ocorreu um erro inesperado. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clicker Game'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Entre para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: AuthValidators.email,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (_) {
                      if (_mensagemErro != null) {
                        setState(() => _mensagemErro = null);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    validator: AuthValidators.senha,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (_) {
                      if (_mensagemErro != null) {
                        setState(() => _mensagemErro = null);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_mensagemErro != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _mensagemErro!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _carregando
                        ? null
                        : () => _autenticar(criarConta: false),
                    child: _carregando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Fazer login'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _carregando
                        ? null
                        : () => _autenticar(criarConta: true),
                    child: const Text('Criar conta'),
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
