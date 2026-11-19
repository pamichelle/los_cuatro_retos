import 'dart:convert';

import 'package:cuatro_retos/retos/clima/clima_servicio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final respuestaEjemplo = {
  'name': 'Dolores Hidalgo',
  'main': {'temp': 22.6, 'feels_like': 21.9, 'humidity': 40},
  'weather': [
    {'description': 'cielo claro', 'icon': '01d'}
  ],
};

void main() {
  test('Clima.desdeJson lee los datos y los formatea', () {
    final c = Clima.desdeJson(respuestaEjemplo);
    expect(c.ciudad, 'Dolores Hidalgo');
    expect(c.temperaturaTexto, '23°C');
    expect(c.humedad, 40);
    expect(c.descripcionBonita, 'Cielo claro');
    expect(c.urlIcono, 'https://openweathermap.org/img/wn/01d@4x.png');
  });

  test('temperatura entera en el JSON también funciona', () {
    final j = {
      ...respuestaEjemplo,
      'main': {'temp': 20, 'feels_like': 19, 'humidity': 50}
    };
    expect(Clima.desdeJson(j).temperaturaTexto, '20°C');
  });

  test('porCiudad pide grados Celsius y en español', () async {
    final s = ClimaServicio(MockClient((req) async {
      expect(req.url.path, '/data/2.5/weather');
      expect(req.url.queryParameters['q'], 'Dolores Hidalgo,MX');
      expect(req.url.queryParameters['units'], 'metric');
      expect(req.url.queryParameters['lang'], 'es');
      return http.Response(jsonEncode(respuestaEjemplo), 200);
    }), 'KEY');
    final c = await s.porCiudad('Dolores Hidalgo,MX');
    expect(c.ciudad, 'Dolores Hidalgo');
  });

  test('porCoordenadas manda lat y lon', () async {
    final s = ClimaServicio(MockClient((req) async {
      expect(req.url.queryParameters['lat'], '21.15');
      expect(req.url.queryParameters['lon'], '-100.93');
      return http.Response(jsonEncode(respuestaEjemplo), 200);
    }), 'KEY');
    await s.porCoordenadas(21.15, -100.93);
  });

  test('401 avisa que la key es inválida', () {
    final s = ClimaServicio(MockClient((_) async => http.Response('{}', 401)), 'KEY');
    expect(s.porCiudad('X'), throwsA(predicate((e) => '$e'.contains('API key'))));
  });

  test('404 avisa que no existe la ciudad', () {
    final s = ClimaServicio(MockClient((_) async => http.Response('{}', 404)), 'KEY');
    expect(s.porCiudad('Narnia'), throwsA(predicate((e) => '$e'.contains('ciudad'))));
  });
}
