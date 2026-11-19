import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'coingecko_servicio.dart';

class PantallaCripto extends StatefulWidget {
  const PantallaCripto({super.key});
  @override
  State<PantallaCripto> createState() => _PantallaCriptoState();
}

class _PantallaCriptoState extends State<PantallaCripto> {
  final servicio = CoinGeckoServicio(http.Client());
  final _monto = TextEditingController(text: '100');
  late Future<List<Cripto>> futuro = servicio.precios();

  void _recargar() => setState(() => futuro = servicio.precios());

  @override
  void dispose() {
    _monto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usd = leerMonto(_monto.text);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reto 4 · Cripto'),
        actions: [IconButton(onPressed: _recargar, icon: const Icon(Icons.refresh))],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _monto,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: '¿Cuántos dólares tienes?',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}), // recalcula al escribir
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Cripto>>(
            future: futuro,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('${snap.error}'.replaceFirst('Exception: ', '')),
                    const SizedBox(height: 8),
                    FilledButton(onPressed: _recargar, child: const Text('Reintentar')),
                  ]),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => _recargar(),
                child: ListView(children: [
                  for (final c in snap.data!)
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(c.simbolo[0])),
                        title: Text('${c.nombre} (${c.simbolo})'),
                        subtitle: Text('1 ${c.simbolo} = \$${c.precioUsd.toStringAsFixed(2)} USD'),
                        trailing: Text(
                          '${c.cuantoCompras(usd).toStringAsFixed(6)}\n${c.simbolo}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}
