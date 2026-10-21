import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Favoritos, ruta y perfil del usuario, guardados en el teléfono.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState i = AppState._();

  SharedPreferences? _p;
  List<String> favs = [];
  List<String> ruta = [];
  Map<String, dynamic> perfil = {};

  /// Pestaña activa de la barra inferior.
  final ValueNotifier<int> tab = ValueNotifier<int>(0);

  Future<void> cargar() async {
    _p = await SharedPreferences.getInstance();
    favs = _p!.getStringList('favs') ?? [];
    ruta = _p!.getStringList('ruta') ?? [];
    final s = _p!.getString('perfil');
    if (s != null) {
      try {
        perfil = jsonDecode(s) as Map<String, dynamic>;
      } catch (_) {
        perfil = {};
      }
    }
  }

  bool esFav(String id) => favs.contains(id);
  bool enRuta(String id) => ruta.contains(id);

  void toggleFav(String id) {
    esFav(id) ? favs.remove(id) : favs.add(id);
    _p?.setStringList('favs', favs);
    notifyListeners();
  }

  void toggleRuta(String id) {
    enRuta(id) ? ruta.remove(id) : ruta.add(id);
    _p?.setStringList('ruta', ruta);
    notifyListeners();
  }

  void mover(int desde, int delta) {
    final hasta = desde + delta;
    if (hasta < 0 || hasta >= ruta.length) return;
    final x = ruta.removeAt(desde);
    ruta.insert(hasta, x);
    _p?.setStringList('ruta', ruta);
    notifyListeners();
  }

  void guardarPerfil(Map<String, dynamic> p) {
    perfil = p;
    _p?.setString('perfil', jsonEncode(p));
    notifyListeners();
  }

  String get nombre => (perfil['nombre'] ?? '') as String;
}
