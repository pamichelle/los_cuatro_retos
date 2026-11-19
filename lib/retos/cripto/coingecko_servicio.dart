import 'dart:convert';

import 'package:http/http.dart' as http;

class Cripto {
  final String id;
  final String nombre;
  final String simbolo;
  final double precioUsd;
  const Cripto(this.id, this.nombre, this.simbolo, this.precioUsd);

  /// Cuánta crypto compras con [usd] dólares.
  double cuantoCompras(double usd) => precioUsd <= 0 ? 0 : usd / precioUsd;
}

const monedas = {
  'bitcoin': ('Bitcoin', 'BTC'),
  'ethereum': ('Ethereum', 'ETH'),
  'solana': ('Solana', 'SOL'),
};

/// Convierte lo que escribe el usuario ("1,500.50", " 20 ") a número. Devuelve 0 si no es válido.
double leerMonto(String texto) => double.tryParse(texto.replaceAll(',', '').trim()) ?? 0;

class CoinGeckoServicio {
  final http.Client cliente;
  CoinGeckoServicio(this.cliente);

  Uri get url => Uri.https('api.coingecko.com', '/api/v3/simple/price', {
        'ids': monedas.keys.join(','),
        'vs_currencies': 'usd',
      });

  Future<List<Cripto>> precios() async {
    final r = await cliente.get(url);
    if (r.statusCode == 429) throw Exception('Demasiadas consultas. Espera un minuto y recarga.');
    if (r.statusCode != 200) throw Exception('Error del servidor (${r.statusCode})');
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    return [
      for (final e in monedas.entries)
        if (j[e.key] != null)
          Cripto(e.key, e.value.$1, e.value.$2, ((j[e.key] as Map)['usd'] as num).toDouble()),
    ];
  }
}
