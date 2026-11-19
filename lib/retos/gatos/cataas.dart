/// Filtros que acepta la API de Cataas.
enum FiltroGato {
  ninguno('Normal'),
  mono('Blanco y negro'),
  negate('Negativo'),
  blur('Borroso');

  final String etiqueta;
  const FiltroGato(this.etiqueta);
}

/// Construye la URL dinámica de Cataas.
/// - Sin texto:  https://cataas.com/cat
/// - Con texto:  https://cataas.com/cat/says/<texto>
/// [semilla] cambia en cada clic para que Flutter no muestre la imagen guardada en caché.
Uri urlGato({
  String texto = '',
  FiltroGato filtro = FiltroGato.ninguno,
  String colorTexto = 'white',
  int tamano = 40,
  int semilla = 0,
}) {
  final limpio = texto.trim();
  final segmentos = ['cat', if (limpio.isNotEmpty) ...['says', limpio]];
  final params = <String, String>{
    if (limpio.isNotEmpty) 'fontColor': colorTexto,
    if (limpio.isNotEmpty) 'fontSize': '$tamano',
    if (filtro == FiltroGato.blur) 'blur': '5',
    if (filtro == FiltroGato.mono || filtro == FiltroGato.negate) 'filter': filtro.name,
    't': '$semilla',
  };
  // pathSegments codifica solo los espacios, acentos y "/" del texto.
  return Uri(scheme: 'https', host: 'cataas.com', pathSegments: segmentos, queryParameters: params);
}
