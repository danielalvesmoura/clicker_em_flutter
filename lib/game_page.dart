import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<Map<String, dynamic>?> buscarUpgrade(int nivel) async {
    final url = Uri.parse('http://localhost:3000/upgrade/$nivel');

    final resposta = await http.get(url);

    if (resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);

      return dados;
    }

    return null;
  }

  Future<void> comprarUpgrade(
    int moedasAtuais,
    int nivelAtual,
  ) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    final url = Uri.parse(
      'http://localhost:3000/upgrade/comprar',
    );

    final resposta = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nivelAtual': nivelAtual,
        'moedas': moedasAtuais,
      }),
    );

    final dados = jsonDecode(resposta.body);

    if (resposta.statusCode == 200) {
      await FirebaseFirestore.instance
          .collection('jogadores')
          .doc(usuario.uid)
          .update({
            'moedas': dados['moedas'],
            'nivel': dados['nivel'],
            'poderClique': dados['poderClique'],
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dados['erro']),
        ),
      );
    }
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
          final nivel = dados['nivel'] ?? 1;
          final poderClique = dados['poderClique'] ?? 1;

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

                const SizedBox(height: 30),

                Text(
                  'Nível: $nivel',
                  style: const TextStyle(fontSize: 20),
                ),

                Text(
                  'Poder por clique: $poderClique',
                  style: const TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 20),

                FutureBuilder<Map<String, dynamic>?>(
                  future: buscarUpgrade(nivel + 1),
                  builder: (context, snapshotUpgrade) {
                    if (!snapshotUpgrade.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final upgrade = snapshotUpgrade.data!;

                    return Column(
                      children: [
                        Text(
                          'Próximo nível: ${upgrade['nivel']}',
                        ),
                        Text(
                          'Custo: ${upgrade['custo']} moedas',
                        ),
                        Text(
                          'Novo poder: ${upgrade['poderClique']}',
                        ),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: () {
                            comprarUpgrade(moedas, nivel);
                          },
                          child: const Text('Comprar upgrade'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
