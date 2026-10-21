import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Departamento de Colombia.
class Depto {
  final String k, n, cap, r, intro;
  final double lat, lon;
  final bool foco;

  Depto.fromJson(Map<String, dynamic> j)
      : k = j['k'] as String,
        n = j['n'] as String,
        cap = j['cap'] as String,
        r = j['r'] as String,
        intro = (j['intro'] ?? '') as String,
        lat = (j['lat'] as num).toDouble(),
        lon = (j['lon'] as num).toDouble(),
        foco = j['foco'] == true;
}

/// Municipio con información detallada.
class Muni {
  final String id, n, dep, intro, historia, llegar;
  final double lat, lon;
  final List<List<String>> datos;
  final bool foco;

  Muni.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        n = j['n'] as String,
        dep = (j['dep'] ?? 'co-ma') as String,
        intro = (j['intro'] ?? '') as String,
        historia = (j['historia'] ?? '') as String,
        llegar = (j['llegar'] ?? '') as String,
        lat = (j['lat'] as num).toDouble(),
        lon = (j['lon'] as num).toDouble(),
        datos = ((j['datos'] ?? <dynamic>[]) as List)
            .map((e) => (e as List).map((x) => x.toString()).toList())
            .toList(),
        foco = j['foco'] == true;
}

/// Lugar, plato, música, hotel, restaurante o evento.
class Item {
  final String id, c, n, d, tip, dep;
  final String? muni;
  final int? m;
  final double? lat, lon;

  Item.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        c = j['c'] as String,
        n = j['n'] as String,
        d = (j['d'] ?? '') as String,
        tip = (j['tip'] ?? '') as String,
        dep = j['dep'] as String,
        muni = j['muni'] as String?,
        m = (j['m'] as num?)?.toInt(),
        lat = (j['lat'] as num?)?.toDouble(),
        lon = (j['lon'] as num?)?.toDouble();

  bool get tieneCoord => lat != null && lon != null;
}

class Catalogo {
  static List<Depto> deptos = [];
  static List<Muni> munis = [];
  static List<Item> items = [];
  static Map<String, dynamic> identidad = {};
  static final Map<String, Depto> dep = {};
  static final Map<String, Item> porId = {};

  static Future<void> cargar() async {
    final raw = await rootBundle.loadString('assets/data.json');
    final j = jsonDecode(raw) as Map<String, dynamic>;
    deptos = (j['deptos'] as List)
        .map((e) => Depto.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.n.compareTo(b.n));
    munis = (j['munis'] as List)
        .map((e) => Muni.fromJson(e as Map<String, dynamic>))
        .toList();
    items = (j['items'] as List)
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();
    identidad = (j['identidad'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    for (final d in deptos) {
      dep[d.k] = d;
    }
    for (final i in items) {
      porId[i.id] = i;
    }
  }

  static Muni? muni(String? id) {
    if (id == null) return null;
    for (final m in munis) {
      if (m.id == id) return m;
    }
    return null;
  }

  static List<Muni> munisDe(String depK) =>
      munis.where((m) => m.dep == depK).toList();

  static String lugarDe(Item i) {
    final mu = muni(i.muni);
    final d = dep[i.dep];
    return [if (mu != null) mu.n, if (d != null) d.n].join(', ');
  }

  /// Eventos ordenados a partir del mes actual.
  static List<Item> proximos(int n) {
    final ahora = DateTime.now().month;
    final ev = items.where((i) => i.m != null).toList();
    int dist(Item i) => (i.m! - ahora + 12) % 12;
    ev.sort((a, b) {
      final c = dist(a).compareTo(dist(b));
      return c != 0 ? c : a.n.compareTo(b.n);
    });
    return ev.take(n).toList();
  }

  static String norm(String s) {
    const de = 'áéíóúüñÁÉÍÓÚÜÑ';
    const a = 'aeiouunAEIOUUN';
    final b = StringBuffer();
    for (final ch in s.split('')) {
      final k = de.indexOf(ch);
      b.write(k >= 0 ? a[k] : ch);
    }
    return b.toString().toLowerCase();
  }
}
