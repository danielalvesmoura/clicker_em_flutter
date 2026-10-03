import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:async';

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
    iniciarTimer();
  }

  Timer? timer;
  int mineradoresAtuais = 0;

  void iniciarTimer() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        if (mineradoresAtuais <= 0) return;

        final usuario = FirebaseAuth.instance.currentUser;

        if (usuario == null) return;

        await FirebaseFirestore.instance
            .collection('jogadores')
            .doc(usuario.uid)
            .update({
              'moedas': FieldValue.increment(mineradoresAtuais),
            });
      },
    );
  }

  @override
    void dispose() {
      timer?.cancel();
      super.dispose();
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
      await documento.set({
        'moedas': 0, 
        'poderClique': 1, 
        'nivel': 1,
        'mineradores': 0,
      });
    } else {
      final dados = snapshot.data()!;

      if (!dados.containsKey('mineradores')) {
        await documento.update({
          'mineradores': 0,
        });
      }
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

  Future<void> comprarMinerador(
    int moedasAtuais,
    int mineradoresAtuais,
  ) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    final url = Uri.parse(
      'http://localhost:3000/minerador/comprar',
    );

    final resposta = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'moedas': moedasAtuais,
        'mineradores': mineradoresAtuais,
      }),
    );

    final dados = jsonDecode(resposta.body);

    if (resposta.statusCode == 200) {
      await FirebaseFirestore.instance
          .collection('jogadores')
          .doc(usuario.uid)
          .update({
            'moedas': dados['moedas'],
            'mineradores': dados['mineradores'],
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dados['erro']),
        ),
      );
    }
  }

  Future<int?> buscarPrecoMinerador(int quantidade) async {
    final url = Uri.parse(
      'http://localhost:3000/minerador/$quantidade',
    );

    final resposta = await http.get(url);

    if (resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);

      return dados['custoProximo'];
    }

    return null;
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
          final mineradores = dados['mineradores'] ?? 0;

          mineradoresAtuais = mineradores;

          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Moedas: $moedas',
                        style: const TextStyle(fontSize: 32),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: clicar,
                        child: const Text('CLICAR'),
                      ),

                      const SizedBox(height: 20),

                      Text('Nível: $nivel'),
                      Text('Poder por clique: $poderClique'),
                    ],
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                height: 500,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upgrades',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 15),

                    FutureBuilder<int?>(
                      future: buscarPrecoMinerador(mineradores),
                      builder: (context, snapshotPreco) {
                        if (!snapshotPreco.hasData) {
                          return const Text('Carregando preço...');
                        }

                        final preco = snapshotPreco.data!;

                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Minerador',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text('Minera ouro.'),
                                  const Text(
                                    'Cada minerador gera +1 moeda/s.',
                                  ),
                                  Text('Possui: $mineradores'),
                                ],
                              ),
                            ),


                            Column(
                              children: [
                                Text('Preço: $preco moedas'),

                                ElevatedButton(
                                  onPressed: () {
                                    comprarMinerador(
                                      moedas,
                                      mineradores,
                                    );
                                  },
                                  child: const Text('Comprar'),
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
