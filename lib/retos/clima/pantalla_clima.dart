import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import 'clima_servicio.dart';

class PantallaClima extends StatefulWidget {
  const PantallaClima({super.key});
  @override
  State<PantallaClima> createState() => _PantallaClimaState();
}

class _PantallaClimaState extends State<PantallaClima> {
  final servicio = ClimaServicio(http.Client(), owmKey);
  final _ciudad = TextEditingController(text: 'Dolores Hidalgo,MX');
  bool cargando = false;
  Clima? clima;
  String? error;

  @override
  void initState() {
    super.initState();
    _buscar(() => servicio.porCiudad(_ciudad.text));
  }

  Future<void> _buscar(Future<Clima> Function() peticion) async {
    setState(() {
      cargando = true;
      error = null;
    });
    Clima? c;
    String? e;
    try {
      c = await peticion();
    } catch (ex) {
      e = '$ex'.replaceFirst('Exception: ', '');
    }
    if (!mounted) return; // el usuario ya salió de la pantalla
    setState(() {
      cargando = false;
      error = e;
      if (c != null) clima = c;
    });
  }

  /// "Plus" del reto: detectar la ubicación con geolocator.
  Future<Clima> _miUbicacion() async {
    if (!await Geolocator.isLocationServiceEnabled()) throw Exception('Activa el GPS del teléfono.');
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) permiso = await Geolocator.requestPermission();
    if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) {
      throw Exception('Necesito permiso de ubicación.');
    }
    final p = await Geolocator.getCurrentPosition();
    return servicio.porCoordenadas(p.latitude, p.longitude);
  }

  @override
  void dispose() {
    _ciudad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reto 3 · Clima')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _ciudad,
              decoration: const InputDecoration(labelText: 'Ciudad', border: OutlineInputBorder()),
              onSubmitted: (_) => _buscar(() => servicio.porCiudad(_ciudad.text)),
            ),
          ),
          IconButton.filled(
            onPressed: () => _buscar(() => servicio.porCiudad(_ciudad.text)),
            icon: const Icon(Icons.search),
          ),
          IconButton.filledTonal(
            tooltip: 'Usar mi ubicación',
            onPressed: () => _buscar(_miUbicacion),
            icon: const Icon(Icons.my_location),
          ),
        ]),
        const SizedBox(height: 40),
        if (cargando)
          const Center(child: CircularProgressIndicator())
        else if (error != null)
          Center(child: Text(error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)))
        else if (clima != null)
          Column(children: [
            Text(clima!.ciudad, style: Theme.of(context).textTheme.headlineMedium),
            Image.network(clima!.urlIcono, height: 140,
                errorBuilder: (_, __, ___) => const Icon(Icons.cloud, size: 100)),
            Text(clima!.temperaturaTexto,
                style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w200)),
            Text(clima!.descripcionBonita, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Text('Sensación ${clima!.sensacion.round()}°C  ·  Humedad ${clima!.humedad}%'),
          ]),
      ]),
    );
  }
}
