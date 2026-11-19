import 'package:flutter/material.dart';

import 'cataas.dart';

class PantallaGatos extends StatefulWidget {
  const PantallaGatos({super.key});
  @override
  State<PantallaGatos> createState() => _PantallaGatosState();
}

class _PantallaGatosState extends State<PantallaGatos> {
  final _texto = TextEditingController();
  FiltroGato filtro = FiltroGato.ninguno;
  String color = 'white';
  int semilla = DateTime.now().millisecondsSinceEpoch;

  void _nuevoGato() => setState(() => semilla = DateTime.now().millisecondsSinceEpoch);

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = urlGato(texto: _texto.text, filtro: filtro, colorTexto: color, semilla: semilla);
    return Scaffold(
      appBar: AppBar(title: const Text('Reto 2 · Memes de gatos')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(
          controller: _texto,
          decoration: const InputDecoration(
            labelText: 'Escribe tu frase',
            hintText: 'Cuando es lunes y no hice la tarea',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _nuevoGato(),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          for (final f in FiltroGato.values)
            ChoiceChip(
              label: Text(f.etiqueta),
              selected: filtro == f,
              onSelected: (_) => setState(() => filtro = f),
            ),
        ]),
        Wrap(spacing: 8, children: [
          for (final c in ['white', 'yellow', 'pink', 'black'])
            ChoiceChip(label: Text('Texto $c'), selected: color == c, onSelected: (_) => setState(() => color = c)),
        ]),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _nuevoGato, icon: const Icon(Icons.refresh), label: const Text('Generar meme')),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url.toString(),
            key: ValueKey(url.toString()),
            fit: BoxFit.contain,
            loadingBuilder: (_, hijo, progreso) => progreso == null
                ? hijo
                : const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
            errorBuilder: (_, __, ___) => const SizedBox(
              height: 200,
              child: Center(child: Text('😿 No se pudo cargar el gato. Revisa tu internet.')),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SelectableText(url.toString(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    );
  }
}
