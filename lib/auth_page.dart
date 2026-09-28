import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> criarConta() async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text, 
      password: senhaController.text
    );
  }

  Future<void> fazerLogin() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: senhaController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clicker Game')),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'E-mail'),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Senha'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: fazerLogin,
              child: const Text('Fazer login'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: criarConta,
              child: const Text('Criar conta'),
            ),
            
          ],
        ),
      ),
      
    );
  }
}
