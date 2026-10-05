import 'package:flutter/material.dart';

import '../models/game_save.dart';
import '../models/upgrade_info.dart';
import '../services/game_api_service.dart';
import '../services/game_firestore_service.dart';
import 'upgrade_card.dart';

class AutomaticUpgradesTab extends StatefulWidget {
  final GameSave save;
  final GameApiService apiService;
  final GameFirestoreService firestoreService;

  const AutomaticUpgradesTab({
    super.key,
    required this.save,
    required this.apiService,
    required this.firestoreService,
  });

  @override
  State<AutomaticUpgradesTab> createState() => _AutomaticUpgradesTabState();
}

class _AutomaticUpgradesTabState extends State<AutomaticUpgradesTab> {
  late Future<List<AutomaticUpgradeInfo>> _precosFuture;
  String? _comprando;

  @override
  void initState() {
    super.initState();
    _precosFuture = widget.apiService.buscarAutomaticos(widget.save);
  }

  @override
  void didUpdateWidget(covariant AutomaticUpgradesTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    final quantidadesMudaram =
        oldWidget.save.mineradores != widget.save.mineradores ||
        oldWidget.save.fabricas != widget.save.fabricas ||
        oldWidget.save.bancos != widget.save.bancos;

    if (quantidadesMudaram) {
      _precosFuture = widget.apiService.buscarAutomaticos(widget.save);
    }
  }

  Future<void> _comprar(AutomaticUpgradeInfo upgrade) async {
    setState(() {
      _comprando = upgrade.tipo;
    });

    try {
      final resultado = await widget.apiService.comprarAutomatico(
        tipo: upgrade.tipo,
        moedas: widget.save.moedas,
        quantidadeAtual: widget.save.quantidadeDoAutomatico(upgrade.tipo),
      );

      await widget.firestoreService.aplicarCompraAutomatica(
        tipo: upgrade.tipo,
        moedas: (resultado['moedas'] as num).toInt(),
        quantidade: (resultado['quantidade'] as num).toInt(),
      );
    } on ApiException catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro.mensagem)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível comprar o upgrade.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _comprando = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AutomaticUpgradeInfo>>(
      future: _precosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text('Não foi possível carregar os upgrades automáticos.'),
          );
        }

        final upgrades = snapshot.data!;

        return ListView.separated(
          itemCount: upgrades.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final upgrade = upgrades[index];
            final quantidade = widget.save.quantidadeDoAutomatico(upgrade.tipo);

            final producaoAtual = widget.save.producaoDoAutomatico(
              upgrade.tipo,
            );

            return UpgradeCard(
              titulo: upgrade.nome,
              descricao: upgrade.descricao,
              detalhes: [
                'Possui: $quantidade',
                'Cada unidade gera +$producaoAtual moeda(s)/s.',
              ],
              custo: upgrade.custo,
              carregando: _comprando == upgrade.tipo,
              onComprar: () => _comprar(upgrade),
            );
          },
        );
      },
    );
  }
}
