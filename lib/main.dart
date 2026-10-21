import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'cuenta.dart';
import 'data.dart';
import 'firebase_options.dart';
import 'screens.dart';
import 'state.dart';
import 'ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Catalogo.cargar();
  await AppState.i.cargar();
  runApp(const ViveColombiaApp());
  // Firebase se conecta después de mostrar la app; si falla, la app sigue funcionando sin nube.
  try {
    await Firebase.initializeApp(options: firebaseOptions);
    AppState.i.conectarFirebase();
  } catch (_) {}
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
      home: ListenableBuilder(
        listenable: AppState.i,
        builder: (context, _) {
          final st = AppState.i;
          if (!st.sesionLista) return const CargaScreen();
          if (st.usuario == null && !st.invitado) return const LoginScreen();
          return const Inicio();
        },
      ),
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
