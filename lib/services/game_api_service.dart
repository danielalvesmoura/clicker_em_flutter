import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/game_save.dart';
import '../models/upgrade_info.dart';

class ApiException implements Exception {
  final String mensagem;

  const ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

class GameApiService {
  static const String baseUrl = 'http://localhost:3000';

  Future<List<AutomaticUpgradeInfo>> buscarAutomaticos(GameSave save) async {
    final uri = Uri.parse('$baseUrl/automaticos/precos').replace(
      queryParameters: {
        'mineradores': save.mineradores.toString(),
        'fabricas': save.fabricas.toString(),
        'bancos': save.bancos.toString(),
      },
    );

    final resposta = await http.get(uri);
    final dados = _decodificarResposta(resposta);

    final lista = dados['automaticos'] as List<dynamic>? ?? [];

    return lista
        .map(
          (item) => AutomaticUpgradeInfo.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> comprarAutomatico({
    required String tipo,
    required int moedas,
    required int quantidadeAtual,
  }) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl/automaticos/comprar'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tipo': tipo,
        'moedas': moedas,
        'quantidadeAtual': quantidadeAtual,
      }),
    );

    return _decodificarResposta(resposta);
  }

  Future<List<PermanentUpgradeInfo>> buscarPermanentes() async {
    final resposta = await http.get(
      Uri.parse('$baseUrl/permanentes'),
    );

    final dados = _decodificarResposta(resposta);
    final lista = dados['permanentes'] as List<dynamic>? ?? [];

    return lista
        .map(
          (item) => PermanentUpgradeInfo.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> comprarPermanente({
    required String tipo,
    required int moedas,
    required bool jaComprado,
  }) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl/permanentes/comprar'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tipo': tipo,
        'moedas': moedas,
        'jaComprado': jaComprado,
      }),
    );

    return _decodificarResposta(resposta);
  }

  Map<String, dynamic> _decodificarResposta(http.Response resposta) {
    Map<String, dynamic> dados;

    try {
      dados = Map<String, dynamic>.from(jsonDecode(resposta.body) as Map);
    } catch (_) {
      throw const ApiException('A API retornou uma resposta inválida.');
    }

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw ApiException(
        dados['erro']?.toString() ?? 'Erro ao acessar a API.',
      );
    }

    return dados;
  }
}
