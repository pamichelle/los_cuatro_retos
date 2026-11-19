import 'package:flutter/material.dart';

import 'retos/clima/pantalla_clima.dart';
import 'retos/cripto/pantalla_cripto.dart';
import 'retos/gatos/pantalla_gatos.dart';
import 'retos/peliculas/pantalla_peliculas.dart';

void main() {
  runApp(MaterialApp(
    title: 'Los 4 Retos',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
    home: const PantallaMenu(),
  ));
}

class PantallaMenu extends StatelessWidget {
  const PantallaMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final retos = <(String, String, IconData, Widget)>[
      ('Reto 1 · Películas', 'Recomendación según tu estado de ánimo', Icons.movie, const PantallaPeliculas()),
      ('Reto 2 · Memes de gatos', 'Tu frase encima de un gato, con filtros', Icons.pets, const PantallaGatos()),
      ('Reto 3 · Clima', 'Clima actual de tu ciudad', Icons.wb_sunny, const PantallaClima()),
      ('Reto 4 · Cripto', 'Cuánta crypto compras con tus dólares', Icons.currency_bitcoin, const PantallaCripto()),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Los 4 Retos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (titulo, sub, icono, pantalla) in retos)
            Card(
              child: ListTile(
                leading: Icon(icono, size: 36),
                title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(sub),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => pantalla)),
              ),
            ),
        ],
      ),
    );
  }
}
