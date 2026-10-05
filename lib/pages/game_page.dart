import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game_save.dart';
import '../services/auth_service.dart';
import '../services/game_api_service.dart';
import '../services/game_firestore_service.dart';
import '../widgets/automatic_upgrades_tab.dart';
import '../widgets/permanent_upgrades_tab.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final _authService = AuthService();
  final _firestoreService = GameFirestoreService();
  final _apiService = GameApiService();

  Timer? _timer;
  int _moedasPorSegundoAtuais = 0;

  @override
  void initState() {
    super.initState();
    _inicializarJogo();
  }

  Future<void> _inicializarJogo() async {
    await _firestoreService.garantirSave();

    if (!mounted) return;

    _iniciarTimer();
  }

  void _iniciarTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        if (_moedasPorSegundoAtuais <= 0) return;

        await _firestoreService.adicionarMoedas(
          _moedasPorSegundoAtuais,
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clicker Game'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: _authService.sair,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<GameSave>(
        stream: _firestoreService.observarSave(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final save = snapshot.data!;
          _moedasPorSegundoAtuais = save.moedasPorSegundo;

          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Moedas: ${save.moedas}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+${save.moedasPorSegundo} moedas/s',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _firestoreService.adicionarMoedas(
                          save.poderClique,
                        ),
                        child: Text('CLICAR (+${save.poderClique})'),
                      ),
                    ],
                  ),
                ),
              ),
              DefaultTabController(
                length: 2,
                child: Container(
                  width: double.infinity,
                  height: 500,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upgrades',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const TabBar(
                        tabs: [
                          Tab(text: 'Automáticos'),
                          Tab(text: 'Permanentes'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TabBarView(
                          children: [
                            AutomaticUpgradesTab(
                              save: save,
                              apiService: _apiService,
                              firestoreService: _firestoreService,
                            ),
                            PermanentUpgradesTab(
                              save: save,
                              apiService: _apiService,
                              firestoreService: _firestoreService,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
