import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

class Pelicula {
  final String titulo;
  final String anio;
  final String poster; // URL o 'N/A'
  final String imdbId;

  const Pelicula({required this.titulo, required this.anio, required this.poster, required this.imdbId});

  factory Pelicula.desdeJson(Map<String, dynamic> j) => Pelicula(
        titulo: j['Title'] as String? ?? 'Sin título',
        anio: j['Year'] as String? ?? '',
        poster: j['Poster'] as String? ?? 'N/A',
        imdbId: j['imdbID'] as String? ?? '',
      );

  bool get tienePoster => poster.startsWith('http');
}

/// Cada estado de ánimo busca con palabras distintas en OMDb.
const busquedasPorAnimo = <String, List<String>>{
  '😄 Feliz': ['comedy', 'party', 'friends', 'summer'],
  '😢 Triste': ['love', 'heart', 'rain', 'memory'],
  '😱 Con miedo': ['horror', 'ghost', 'night', 'haunted'],
  '🤩 Aventurero': ['adventure', 'journey', 'treasure', 'island'],
  '🤖 Geek': ['robot', 'space', 'future', 'star'],
};

class OmdbServicio {
  final http.Client cliente;
  final String apiKey;
  final Random azar;
  OmdbServicio(this.cliente, this.apiKey, {Random? azar}) : azar = azar ?? Random();

  Uri urlBusqueda(String termino) => Uri.https('www.omdbapi.com', '/', {
        'apikey': apiKey,
        's': termino,
        'type': 'movie',
      });

  /// Devuelve la lista de películas para ese estado de ánimo.
  Future<List<Pelicula>> porAnimo(String animo) async {
    if (apiKey.isEmpty) {
      throw Exception('Falta la API key de OMDb. Ponla en lib/config.dart');
    }
    final palabras = busquedasPorAnimo[animo] ?? ['movie'];
    final termino = palabras[azar.nextInt(palabras.length)];
    final r = await cliente.get(urlBusqueda(termino));
    if (r.statusCode != 200) throw Exception('Error del servidor (${r.statusCode})');
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    if (j['Response'] != 'True') {
      throw Exception(j['Error'] ?? 'No se encontraron películas');
    }
    return (j['Search'] as List).map((e) => Pelicula.desdeJson(e as Map<String, dynamic>)).toList();
  }

  /// Una sola película al azar de la lista.
  Pelicula alAzar(List<Pelicula> lista) => lista[azar.nextInt(lista.length)];
}
