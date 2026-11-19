import 'package:cuatro_retos/retos/gatos/cataas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sin texto pide un gato normal', () {
    final u = urlGato(semilla: 1);
    expect(u.host, 'cataas.com');
    expect(u.pathSegments, ['cat']);
    expect(u.queryParameters.containsKey('fontSize'), false);
  });

  test('con texto usa /cat/says/<texto>', () {
    final u = urlGato(texto: 'Hola', semilla: 1);
    expect(u.pathSegments, ['cat', 'says', 'Hola']);
    expect(u.queryParameters['fontColor'], 'white');
    expect(u.queryParameters['fontSize'], '40');
  });

  test('los espacios y acentos se codifican en la URL', () {
    final u = urlGato(texto: 'Ya es viernes, ¿o qué?');
    expect(u.pathSegments.last, 'Ya es viernes, ¿o qué?'); // el texto original se conserva
    expect(u.toString(), isNot(contains(' '))); // pero la URL no lleva espacios
  });

  test('un "/" en la frase no rompe la ruta', () {
    final u = urlGato(texto: 'sí/no');
    expect(u.pathSegments, ['cat', 'says', 'sí/no']);
  });

  test('el texto solo con espacios cuenta como vacío', () {
    expect(urlGato(texto: '   ').pathSegments, ['cat']);
  });

  test('filtros: mono, negate y blur', () {
    expect(urlGato(filtro: FiltroGato.mono).queryParameters['filter'], 'mono');
    expect(urlGato(filtro: FiltroGato.negate).queryParameters['filter'], 'negate');
    expect(urlGato(filtro: FiltroGato.blur).queryParameters['blur'], '5');
    expect(urlGato().queryParameters.containsKey('filter'), false);
  });

  test('la semilla cambia la URL para evitar la caché', () {
    expect(urlGato(semilla: 1), isNot(urlGato(semilla: 2)));
  });
}
