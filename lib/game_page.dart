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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Text(
              'Moedas: $moedas',
              style: const TextStyle(fontSize: 32),
            ),
          );
        },
      ),
    );
  }
}
