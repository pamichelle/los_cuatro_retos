import 'dart:convert';

import 'package:cuatro_retos/retos/peliculas/omdb_servicio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('Pelicula.desdeJson lee título, año y póster', () {
    final p = Pelicula.desdeJson({'Title': 'Coco', 'Year': '2017', 'Poster': 'https://x/coco.jpg', 'imdbID': 'tt1'});
    expect(p.titulo, 'Coco');
    expect(p.anio, '2017');
    expect(p.tienePoster, true);
  });

  test('un póster "N/A" no se considera imagen', () {
    final p = Pelicula.desdeJson({'Title': 'X', 'Poster': 'N/A'});
    expect(p.tienePoster, false);
  });

  test('porAnimo busca con una palabra de ese estado de ánimo', () async {
    final servicio = OmdbServicio(MockClient((req) async {
      expect(req.url.host, 'www.omdbapi.com');
      expect(req.url.queryParameters['apikey'], 'KEY');
      expect(busquedasPorAnimo['😱 Con miedo'], contains(req.url.queryParameters['s']));
      return http.Response(
          jsonEncode({
            'Response': 'True',
            'Search': [
              {'Title': 'It', 'Year': '2017', 'Poster': 'N/A', 'imdbID': 'tt2'}
            ]
          }),
          200);
    }), 'KEY');
    final lista = await servicio.porAnimo('😱 Con miedo');
    expect(lista.single.titulo, 'It');
  });

  test('si OMDb responde Response=False lanza su mensaje de error', () {
    final servicio = OmdbServicio(
        MockClient((_) async => http.Response(jsonEncode({'Response': 'False', 'Error': 'Invalid API key!'}), 200)),
        'KEY');
    expect(servicio.porAnimo('😄 Feliz'), throwsA(predicate((e) => '$e'.contains('Invalid API key'))));
  });

  test('sin API key avisa antes de hacer la petición', () {
    final servicio = OmdbServicio(MockClient((_) async => fail('no debió llamar a la red')), '');
    expect(servicio.porAnimo('😄 Feliz'), throwsA(predicate((e) => '$e'.contains('API key'))));
  });
}
