import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    super.initState();
    criarSave();
  }

  Future<void> sair() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> criarSave() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    final documento = FirebaseFirestore.instance
        .collection('jogadores')
        .doc(usuario.uid);

    final snapshot = await documento.get();

    if (!snapshot.exists) {
      await documento.set({'moedas': 0, 'poderClique': 1, 'nivel': 1});
    }
  }

  Future<void> clicar() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    final documento = FirebaseFirestore.instance
        .collection('jogadores')
        .doc(usuario.uid);

    final snapshot = await documento.get();

    if (!snapshot.exists) return;

    final dados = snapshot.data() as Map<String, dynamic>;
    final moedasAtuais = dados['moedas'] ?? 0;
    final poderClique = dados['poderClique'] ?? 1;

    await documento.update({'moedas': moedasAtuais + poderClique});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Clicker Game'),
        actions: [
          IconButton(
            onPressed: sair,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      
      body: StreamBuilder<DocumentSnapshot>(

        stream: FirebaseFirestore.instance
            .collection('jogadores')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final dados = snapshot.data!.data() as Map<String, dynamic>;
          final moedas = dados['moedas'];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Moedas: $moedas', style: const TextStyle(fontSize: 24)),
            
                const SizedBox(height: 20),
            
                ElevatedButton(
                  onPressed: clicar,
                  child: const Text('Clique!'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
