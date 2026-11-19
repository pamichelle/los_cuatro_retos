import 'dart:convert';

import 'package:http/http.dart' as http;

class Clima {
  final String ciudad;
  final double temperatura;
  final double sensacion;
  final int humedad;
  final String descripcion;
  final String icono; // código de OpenWeatherMap, ej. "01d"

  const Clima({
    required this.ciudad,
    required this.temperatura,
    required this.sensacion,
    required this.humedad,
    required this.descripcion,
    required this.icono,
  });

  factory Clima.desdeJson(Map<String, dynamic> j) {
    final main = j['main'] as Map<String, dynamic>;
    final w = (j['weather'] as List).first as Map<String, dynamic>;
    return Clima(
      ciudad: j['name'] as String? ?? '',
      temperatura: (main['temp'] as num).toDouble(),
      sensacion: (main['feels_like'] as num).toDouble(),
      humedad: (main['humidity'] as num).toInt(),
      descripcion: w['description'] as String? ?? '',
      icono: w['icon'] as String? ?? '01d',
    );
  }

  String get temperaturaTexto => '${temperatura.round()}°C';
  String get urlIcono => 'https://openweathermap.org/img/wn/$icono@4x.png';
  String get descripcionBonita =>
      descripcion.isEmpty ? '' : descripcion[0].toUpperCase() + descripcion.substring(1);
}

class ClimaServicio {
  final http.Client cliente;
  final String apiKey;
  ClimaServicio(this.cliente, this.apiKey);

  Map<String, String> get _base => {'appid': apiKey, 'units': 'metric', 'lang': 'es'};

  Uri urlPorCiudad(String ciudad) =>
      Uri.https('api.openweathermap.org', '/data/2.5/weather', {..._base, 'q': ciudad});

  Uri urlPorCoordenadas(double lat, double lon) =>
      Uri.https('api.openweathermap.org', '/data/2.5/weather', {..._base, 'lat': '$lat', 'lon': '$lon'});

  Future<Clima> porCiudad(String ciudad) => _pedir(urlPorCiudad(ciudad));
  Future<Clima> porCoordenadas(double lat, double lon) => _pedir(urlPorCoordenadas(lat, lon));

  Future<Clima> _pedir(Uri url) async {
    if (apiKey.isEmpty) throw Exception('Falta la API key de OpenWeatherMap. Ponla en lib/config.dart');
    final r = await cliente.get(url);
    if (r.statusCode == 401) throw Exception('API key inválida o todavía no se activa (espera unos minutos).');
    if (r.statusCode == 404) throw Exception('No encontré esa ciudad.');
    if (r.statusCode != 200) throw Exception('Error del servidor (${r.statusCode})');
    return Clima.desdeJson(jsonDecode(r.body) as Map<String, dynamic>);
  }
}
