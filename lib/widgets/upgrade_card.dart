import 'package:flutter/material.dart';

class UpgradeCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final List<String> detalhes;
  final int custo;
  final bool comprado;
  final bool carregando;
  final VoidCallback? onComprar;

  const UpgradeCard({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.detalhes,
    required this.custo,
    required this.onComprar,
    this.comprado = false,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(descricao),
                const SizedBox(height: 4),
                for (final detalhe in detalhes) Text(detalhe),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text(comprado ? 'Permanente' : 'Preço: $custo moedas'),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: comprado || carregando ? null : onComprar,
                child: carregando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(comprado ? 'Comprado' : 'Comprar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
