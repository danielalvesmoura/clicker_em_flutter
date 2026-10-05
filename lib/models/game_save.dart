class GameSave {
  final int moedas;
  final int poderClique;
  final int mineradores;
  final int fabricas;
  final int bancos;
  final int producaoMinerador;
  final int producaoFabrica;
  final int producaoBanco;
  final bool picaretaEficiente;
  final bool franquia;
  final bool investidores;

  const GameSave({
    required this.moedas,
    required this.poderClique,
    required this.mineradores,
    required this.fabricas,
    required this.bancos,
    required this.producaoMinerador,
    required this.producaoFabrica,
    required this.producaoBanco,
    required this.picaretaEficiente,
    required this.franquia,
    required this.investidores,
  });

  factory GameSave.inicial() {
    return const GameSave(
      moedas: 0,
      poderClique: 1,
      mineradores: 0,
      fabricas: 0,
      bancos: 0,
      producaoMinerador: 1,
      producaoFabrica: 5,
      producaoBanco: 20,
      picaretaEficiente: false,
      franquia: false,
      investidores: false,
    );
  }

  factory GameSave.fromMap(Map<String, dynamic> dados) {
    return GameSave(
      moedas: (dados['moedas'] as num?)?.toInt() ?? 0,
      poderClique: (dados['poderClique'] as num?)?.toInt() ?? 1,
      mineradores: (dados['mineradores'] as num?)?.toInt() ?? 0,
      fabricas: (dados['fabricas'] as num?)?.toInt() ?? 0,
      bancos: (dados['bancos'] as num?)?.toInt() ?? 0,
      producaoMinerador: (dados['producaoMinerador'] as num?)?.toInt() ?? 1,
      producaoFabrica: (dados['producaoFabrica'] as num?)?.toInt() ?? 5,
      producaoBanco: (dados['producaoBanco'] as num?)?.toInt() ?? 20,
      picaretaEficiente: dados['picaretaEficiente'] == true,
      franquia: dados['franquia'] == true,
      investidores: dados['investidores'] == true,
    );
  }

  int get moedasPorSegundo {
    return (mineradores * producaoMinerador) +
        (fabricas * producaoFabrica) +
        (bancos * producaoBanco);
  }

  int producaoDoAutomatico(String tipo) {
    switch (tipo) {
      case 'minerador':
        return producaoMinerador;
      case 'fabrica':
        return producaoFabrica;
      case 'banco':
        return producaoBanco;
      default:
        return 0;
    }
  }

  int quantidadeDoAutomatico(String tipo) {
    switch (tipo) {
      case 'minerador':
        return mineradores;
      case 'fabrica':
        return fabricas;
      case 'banco':
        return bancos;
      default:
        return 0;
    }
  }

  bool permanenteComprado(String tipo) {
    switch (tipo) {
      case 'picaretaEficiente':
        return picaretaEficiente;
      case 'franquia':
        return franquia;
      case 'investidores':
        return investidores;
      default:
        return false;
    }
  }
}
