# Los 4 Retos · Consumo de APIs en Flutter

Una sola app con un menú y una pantalla por reto.

| Reto | API | ¿Key? | Archivos |
|---|---|---|---|
| 1 · Películas por estado de ánimo | OMDb | Sí (gratis) | `lib/retos/peliculas/` |
| 2 · Memes de gatos con filtros | Cataas | No | `lib/retos/gatos/` |
| 3 · Clima minimalista (+ geolocalización) | OpenWeatherMap | Sí (gratis) | `lib/retos/clima/` |
| 4 · Convertidor de cripto | CoinGecko | No | `lib/retos/cripto/` |

## 1. Preparar el proyecto (primera vez)

Abre en VS Code la carpeta `cuatro_retos` (la que tiene `pubspec.yaml`) y en la terminal:

```bash
flutter create . --project-name cuatro_retos
del test\widget_test.dart
flutter pub get
```

## 2. Permisos Android

En `android/app/src/main/AndroidManifest.xml`, antes de `<application`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

## 3. API keys (retos 1 y 3)

- OMDb: https://www.omdbapi.com/apikey.aspx → opción **FREE** → te llega la key por correo (hay que activarla con el link).
- OpenWeatherMap: crea cuenta en https://openweathermap.org → **API keys**. Una key nueva tarda de 10 min a 2 h en activarse.

Pégalas en `lib/config.dart`, dentro de `defaultValue: ''`. O sin tocar el código:

```bash
flutter run --dart-define=OMDB_KEY=tu_key --dart-define=OWM_KEY=tu_key
```

> ⚠️ Si pegas tus keys en `config.dart`, no las subas a GitHub públicas.

Los retos 2 y 4 funcionan sin key.

## 4. Pruebas

```bash
flutter test
```

| Archivo | Qué prueba |
|---|---|
| `test/peliculas_test.dart` | JSON de OMDb, búsqueda por ánimo, errores y key faltante |
| `test/gatos_test.dart` | URL dinámica de Cataas: texto, acentos, filtros, caché |
| `test/clima_test.dart` | JSON del clima, °C y español, ciudad/coordenadas, 401 y 404 |
| `test/cripto_test.dart` | Conversión USD → crypto, lectura del monto, precios y 429 |

## 5. Ejecutar

```bash
flutter run
```
