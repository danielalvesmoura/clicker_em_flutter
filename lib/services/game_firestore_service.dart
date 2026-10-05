import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/game_save.dart';

class GameFirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GameFirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>>? get _documentoAtual {
    final usuario = _auth.currentUser;

    if (usuario == null) return null;

    return _firestore.collection('jogadores').doc(usuario.uid);
  }

  Future<void> garantirSave() async {
    final documento = _documentoAtual;

    if (documento == null) return;

    final snapshot = await documento.get();

    if (!snapshot.exists) {
      await documento.set({
        'moedas': 0,
        'poderClique': 1,
        'mineradores': 0,
        'fabricas': 0,
        'bancos': 0,
        'producaoMinerador': 1,
        'producaoFabrica': 5,
        'producaoBanco': 20,
        'picaretaEficiente': false,
        'franquia': false,
        'investidores': false,
      });
      return;
    }

    final dados = snapshot.data() ?? <String, dynamic>{};
    final atualizacoes = <String, dynamic>{};

    if (!dados.containsKey('mineradores')) atualizacoes['mineradores'] = 0;

    if (!dados.containsKey('fabricas')) atualizacoes['fabricas'] = 0;

    if (!dados.containsKey('bancos')) atualizacoes['bancos'] = 0;

    if (!dados.containsKey('producaoMinerador')) {
      atualizacoes['producaoMinerador'] = 1;
    }

    if (!dados.containsKey('producaoFabrica')) {
      atualizacoes['producaoFabrica'] = dados['franquia'] == true ? 10 : 5;
    }

    if (!dados.containsKey('producaoBanco')) {
      atualizacoes['producaoBanco'] = dados['investidores'] == true ? 40 : 20;
    }
    
    if (!dados.containsKey('picaretaEficiente')) {
      atualizacoes['picaretaEficiente'] = false;
      atualizacoes['poderClique'] = 1;
    }

    if (!dados.containsKey('franquia')) atualizacoes['franquia'] = false;
    
    if (!dados.containsKey('investidores')) atualizacoes['investidores'] = false;

    if (dados.containsKey('nivel')) {
      atualizacoes['nivel'] = FieldValue.delete();
    }

    if (atualizacoes.isNotEmpty) {
      await documento.update(atualizacoes);
    }
  }

  Stream<GameSave> observarSave() {
    final documento = _documentoAtual;

    if (documento == null) {
      return Stream<GameSave>.value(GameSave.inicial());
    }

    return documento.snapshots().map((snapshot) {
      final dados = snapshot.data();

      if (!snapshot.exists || dados == null) {
        return GameSave.inicial();
      }

      return GameSave.fromMap(dados);
    });
  }

  Future<void> adicionarMoedas(int quantidade) async {
    if (quantidade <= 0) return;

    final documento = _documentoAtual;
    if (documento == null) return;

    await documento.update({
      'moedas': FieldValue.increment(quantidade),
    });
  }

  Future<void> aplicarCompraAutomatica({
    required String tipo,
    required int moedas,
    required int quantidade,
  }) async {
    final documento = _documentoAtual;
    if (documento == null) return;

    final campo = switch (tipo) {
      'minerador' => 'mineradores',
      'fabrica' => 'fabricas',
      'banco' => 'bancos',
      _ => throw ArgumentError('Tipo de upgrade automático inválido: $tipo'),
    };

    await documento.update({
      'moedas': moedas,
      campo: quantidade,
    });
  }

  Future<void> aplicarCompraPermanente({
    required int moedas,
    required Map<String, dynamic> efeitos,
  }) async {
    final documento = _documentoAtual;
    if (documento == null) return;

    await documento.update({
      'moedas': moedas,
      ...efeitos,
    });
  }
}
