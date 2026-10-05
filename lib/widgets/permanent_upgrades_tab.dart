import 'package:flutter/material.dart';

import '../models/game_save.dart';
import '../models/upgrade_info.dart';
import '../services/game_api_service.dart';
import '../services/game_firestore_service.dart';
import 'upgrade_card.dart';

class PermanentUpgradesTab extends StatefulWidget {
  final GameSave save;
  final GameApiService apiService;
  final GameFirestoreService firestoreService;

  const PermanentUpgradesTab({
    super.key,
    required this.save,
    required this.apiService,
    required this.firestoreService,
  });

  @override
  State<PermanentUpgradesTab> createState() => _PermanentUpgradesTabState();
}

class _PermanentUpgradesTabState extends State<PermanentUpgradesTab> {
  late final Future<List<PermanentUpgradeInfo>> _upgradesFuture;
  String? _comprando;

  @override
  void initState() {
    super.initState();
    _upgradesFuture = widget.apiService.buscarPermanentes();
  }

  Future<void> _comprar(PermanentUpgradeInfo upgrade) async {
    final jaComprado = widget.save.permanenteComprado(upgrade.tipo);

    if (jaComprado) return;

    setState(() {
      _comprando = upgrade.tipo;
    });

    try {
      final resultado = await widget.apiService.comprarPermanente(
        tipo: upgrade.tipo,
        moedas: widget.save.moedas,
        jaComprado: jaComprado,
      );

      final efeitos = Map<String, dynamic>.from(
        resultado['efeitos'] as Map,
      );

      await widget.firestoreService.aplicarCompraPermanente(
        moedas: (resultado['moedas'] as num).toInt(),
        efeitos: efeitos,
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

  List<String> _detalhes(PermanentUpgradeInfo upgrade) {
    switch (upgrade.tipo) {
      case 'picaretaEficiente':
        return [
          'Força atual do clique: ${widget.save.poderClique}',
          'Após a compra: 2 moedas por clique.',
        ];
      case 'franquia':
        return [
          'Fábricas passam de +5 para +10 moedas/s cada.',
        ];
      case 'investidores':
        return [
          'Bancos passam de +20 para +40 moedas/s cada.',
        ];
      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PermanentUpgradeInfo>>(
      future: _upgradesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text('Não foi possível carregar os upgrades permanentes.'),
          );
        }

        final upgrades = snapshot.data!;

        return ListView.separated(
          itemCount: upgrades.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final upgrade = upgrades[index];
            final comprado = widget.save.permanenteComprado(upgrade.tipo);

            return UpgradeCard(
              titulo: upgrade.nome,
              descricao: upgrade.descricao,
              detalhes: _detalhes(upgrade),
              custo: upgrade.custo,
              comprado: comprado,
              carregando: _comprando == upgrade.tipo,
              onComprar: () => _comprar(upgrade),
            );
          },
        );
      },
    );
  }
}
