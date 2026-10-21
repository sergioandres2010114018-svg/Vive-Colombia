import 'package:flutter/material.dart';

import 'data.dart';
import 'screens.dart';
import 'state.dart';
import 'ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Catalogo.cargar();
  await AppState.i.cargar();
  runApp(const ViveColombiaApp());
}

class ViveColombiaApp extends StatelessWidget {
  const ViveColombiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ViveColombia',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const Inicio(),
    );
  }
}

/// Estructura principal con las cinco pestañas.
class Inicio extends StatelessWidget {
  const Inicio({super.key});

  static const _paginas = <Widget>[
    HomeScreen(),
    ExplorarScreen(),
    MapaScreen(),
    ViajesScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppState.i.tab,
      builder: (context, i, _) => Scaffold(
        body: IndexedStack(index: i, children: _paginas),
        bottomNavigationBar: NavigationBar(
          selectedIndex: i,
          onDestinationSelected: (v) => AppState.i.tab.value = v,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
            NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explorar'),
            NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
            NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Mis viajes'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
