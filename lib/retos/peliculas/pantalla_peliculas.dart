import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import 'omdb_servicio.dart';

class PantallaPeliculas extends StatefulWidget {
  const PantallaPeliculas({super.key});
  @override
  State<PantallaPeliculas> createState() => _PantallaPeliculasState();
}

class _PantallaPeliculasState extends State<PantallaPeliculas> {
  final servicio = OmdbServicio(http.Client(), omdbKey);
  String? animo;
  Future<List<Pelicula>>? futuro;
  Pelicula? elegida;

  void _elegirAnimo(String a) {
    setState(() {
      animo = a;
      elegida = null;
      futuro = servicio.porAnimo(a);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reto 1 · Películas')),
      body: Column(children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text('¿Cómo te sientes este fin de semana?', style: TextStyle(fontSize: 18)),
        ),
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
          for (final a in busquedasPorAnimo.keys)
            ChoiceChip(label: Text(a), selected: animo == a, onSelected: (_) => _elegirAnimo(a)),
        ]),
        const SizedBox(height: 8),
        Expanded(
          child: futuro == null
              ? const Center(child: Text('Elige un estado de ánimo 👆'))
              : FutureBuilder<List<Pelicula>>(
                  future: futuro,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('${snap.error}'.replaceFirst('Exception: ', ''), textAlign: TextAlign.center),
                        ),
                      );
                    }
                    final lista = snap.data!;
                    return Column(children: [
                      FilledButton.icon(
                        onPressed: () => setState(() => elegida = servicio.alAzar(lista)),
                        icon: const Icon(Icons.casino),
                        label: const Text('Recomiéndame una al azar'),
                      ),
                      if (elegida != null) TarjetaPelicula(pelicula: elegida!, destacada: true),
                      Expanded(
                        child: ListView(children: [for (final p in lista) TarjetaPelicula(pelicula: p)]),
                      ),
                    ]);
                  },
                ),
        ),
      ]),
    );
  }
}

class TarjetaPelicula extends StatelessWidget {
  final Pelicula pelicula;
  final bool destacada;
  const TarjetaPelicula({super.key, required this.pelicula, this.destacada = false});

  @override
  Widget build(BuildContext context) {
    final alto = destacada ? 180.0 : 110.0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: destacada ? Theme.of(context).colorScheme.primaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: Row(children: [
        SizedBox(
          width: alto * 0.68,
          height: alto,
          child: pelicula.tienePoster
              ? Image.network(pelicula.poster, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.movie, size: 40))
              : const Icon(Icons.movie, size: 40),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (destacada) const Text('⭐ Tu película del fin de semana'),
            Text(pelicula.titulo,
                style: TextStyle(fontSize: destacada ? 20 : 16, fontWeight: FontWeight.bold)),
            Text(pelicula.anio),
          ]),
        ),
      ]),
    );
  }
}
