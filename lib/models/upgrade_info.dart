class AutomaticUpgradeInfo {
  final String tipo;
  final String nome;
  final String descricao;
  final int custo;
  final int producaoBase;

  const AutomaticUpgradeInfo({
    required this.tipo,
    required this.nome,
    required this.descricao,
    required this.custo,
    required this.producaoBase,
  });

  factory AutomaticUpgradeInfo.fromMap(Map<String, dynamic> dados) {
    return AutomaticUpgradeInfo(
      tipo: dados['tipo'] as String,
      nome: dados['nome'] as String,
      descricao: dados['descricao'] as String,
      custo: (dados['custo'] as num).toInt(),
      producaoBase: (dados['producaoBase'] as num).toInt(),
    );
  }
}

class PermanentUpgradeInfo {
  final String tipo;
  final String nome;
  final String descricao;
  final int custo;

  const PermanentUpgradeInfo({
    required this.tipo,
    required this.nome,
    required this.descricao,
    required this.custo,
  });

  factory PermanentUpgradeInfo.fromMap(Map<String, dynamic> dados) {
    return PermanentUpgradeInfo(
      tipo: dados['tipo'] as String,
      nome: dados['nome'] as String,
      descricao: dados['descricao'] as String,
      custo: (dados['custo'] as num).toInt(),
    );
  }
}
