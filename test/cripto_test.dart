import 'dart:convert';

import 'package:cuatro_retos/retos/cripto/coingecko_servicio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('cuantoCompras', () {
    test('100 USD con BTC a 50,000 son 0.002 BTC', () {
      expect(const Cripto('bitcoin', 'Bitcoin', 'BTC', 50000).cuantoCompras(100), closeTo(0.002, 1e-12));
    });

    test('0 dólares compran 0', () {
      expect(const Cripto('solana', 'Solana', 'SOL', 150).cuantoCompras(0), 0);
    });

    test('precio 0 no divide entre cero', () {
      expect(const Cripto('x', 'X', 'X', 0).cuantoCompras(100), 0);
    });
  });

  group('leerMonto', () {
    test('números normales y con decimales', () {
      expect(leerMonto('100'), 100);
      expect(leerMonto('20.5'), 20.5);
    });
    test('quita comas y espacios', () => expect(leerMonto(' 1,500.75 '), 1500.75));
    test('texto inválido da 0', () {
      expect(leerMonto('abc'), 0);
      expect(leerMonto(''), 0);
    });
  });

  test('precios pide BTC, ETH y SOL en USD y los convierte', () async {
    final s = CoinGeckoServicio(MockClient((req) async {
      expect(req.url.host, 'api.coingecko.com');
      expect(req.url.queryParameters['ids'], 'bitcoin,ethereum,solana');
      expect(req.url.queryParameters['vs_currencies'], 'usd');
      return http.Response(
          jsonEncode({
            'bitcoin': {'usd': 90000},
            'ethereum': {'usd': 3000.5},
            'solana': {'usd': 150},
          }),
          200);
    }));
    final lista = await s.precios();
    expect(lista.map((c) => c.simbolo), ['BTC', 'ETH', 'SOL']);
    expect(lista[1].precioUsd, 3000.5);
  });

  test('429 avisa que hay demasiadas consultas', () {
    final s = CoinGeckoServicio(MockClient((_) async => http.Response('', 429)));
    expect(s.precios(), throwsA(predicate((e) => '$e'.contains('Demasiadas'))));
  });
}
