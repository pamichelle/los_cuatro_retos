/// API keys de los retos que las necesitan.
///
/// Opción A (rápida): pega tu key entre las comillas de `defaultValue`.
/// Opción B (más segura, no se sube a GitHub):
///   flutter run --dart-define=OMDB_KEY=tu_key --dart-define=OWM_KEY=tu_key
///
/// - OMDb (películas):          https://www.omdbapi.com/apikey.aspx  (opción FREE)
/// - OpenWeatherMap (clima):    https://home.openweathermap.org/api_keys
///   (una key nueva tarda de 10 min a 2 h en activarse)
const omdbKey = String.fromEnvironment('OMDB_KEY', defaultValue: '');
const owmKey = String.fromEnvironment('OWM_KEY', defaultValue: '1ae665e0828523d30cbed945b7abe4e0');
