import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Avisa a las pantallas cuando cambia el catálogo (por ejemplo, al llegar datos de Firebase).
final ValueNotifier<int> cambiosCatalogo = ValueNotifier<int>(0);

double? _num(dynamic v) => v is num ? v.toDouble() : null;
String _str(dynamic v) => v is String ? v : '';

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
        intro = _str(j['intro']),
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
        intro = _str(j['intro']),
        historia = _str(j['historia']),
        llegar = _str(j['llegar']),
        lat = (j['lat'] as num).toDouble(),
        lon = (j['lon'] as num).toDouble(),
        datos = ((j['datos'] ?? <dynamic>[]) as List)
            .map((e) => (e as List).map((x) => x.toString()).toList())
            .toList(),
        foco = j['foco'] == true;
}

/// Lugar, plato, música, hotel, restaurante o evento.
class Item {
  final String id, c, n, d, tip, dep, foto, video, munNombre;
  final String? muni;
  final int? m;
  final double? lat, lon;
  final bool nuevo, editado;

  Item({
    required this.id,
    required this.c,
    required this.n,
    required this.dep,
    this.d = '',
    this.tip = '',
    this.foto = '',
    this.video = '',
    this.munNombre = '',
    this.muni,
    this.m,
    this.lat,
    this.lon,
    this.nuevo = false,
    this.editado = false,
  });

  factory Item.fromJson(Map<String, dynamic> j, {String? id, bool nuevo = false, bool editado = false}) {
    final mu = j['muni'];
    return Item(
      id: id ?? j['id'] as String,
      c: j['c'] as String,
      n: j['n'] as String,
      dep: j['dep'] as String,
      d: _str(j['d']),
      tip: _str(j['tip']),
      foto: _str(j['foto']),
      video: _str(j['video']),
      munNombre: _str(j['munNombre']),
      muni: (mu is String && mu.isNotEmpty) ? mu : null,
      m: (j['m'] as num?)?.toInt(),
      lat: _num(j['lat']),
      lon: _num(j['lon']),
      nuevo: nuevo,
      editado: editado,
    );
  }

  Map<String, dynamic> toJson() => {
        'c': c,
        'n': n,
        'dep': dep,
        'd': d,
        'tip': tip,
        'foto': foto,
        'video': video,
        'munNombre': munNombre,
        'muni': muni ?? '',
        if (m != null) 'm': m,
        if (lat != null) 'lat': lat,
        if (lon != null) 'lon': lon,
      };

  bool get tieneCoord => lat != null && lon != null;

  /// Municipio al que pertenece: uno base o uno escrito a mano en el panel.
  String? get muniId => muni ?? (munNombre.isNotEmpty ? 'x-${Catalogo.slug(munNombre)}' : null);
}

class Catalogo {
  static List<Depto> deptos = [];
  static List<Muni> munis = [];
  static List<Item> base = [];
  static List<Item> items = [];
  static Map<String, dynamic> identidad = {};
  static final Map<String, Depto> dep = {};
  static final Map<String, Item> porId = {};

  /// Documentos de la colección "lugares" en Firestore.
  static Map<String, Map<String, dynamic>> remoto = {};

  static Future<void> cargar() async {
    final raw = await rootBundle.loadString('assets/data.json');
    final j = jsonDecode(raw) as Map<String, dynamic>;
    deptos = (j['deptos'] as List).map((e) => Depto.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.n.compareTo(b.n));
    munis = (j['munis'] as List).map((e) => Muni.fromJson(e as Map<String, dynamic>)).toList();
    base = (j['items'] as List).map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
    identidad = (j['identidad'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    for (final d in deptos) {
      dep[d.k] = d;
    }
    reconstruir();
  }

  /// Une el contenido base con los cambios guardados en Firebase.
  static void reconstruir() {
    final out = <Item>[];
    final vistos = <String>{};
    for (final b in base) {
      vistos.add(b.id);
      final r = remoto[b.id];
      if (r == null) {
        out.add(b);
        continue;
      }
      if (r['oculto'] == true) continue;
      try {
        final mezcla = {...b.toJson(), ...r};
        mezcla['dep'] = b.dep;
        mezcla['muni'] = b.muni ?? '';
        out.add(Item.fromJson(mezcla, id: b.id, editado: true));
      } catch (_) {
        out.add(b);
      }
    }
    remoto.forEach((id, r) {
      if (vistos.contains(id) || r['oculto'] == true) return;
      if (r['n'] is! String || r['c'] is! String || r['dep'] is! String) return;
      if (!dep.containsKey(r['dep'])) return;
      try {
        out.add(Item.fromJson(r, id: id, nuevo: true));
      } catch (_) {}
    });
    items = out;
    porId
      ..clear()
      ..addEntries(out.map((i) => MapEntry(i.id, i)));
    cambiosCatalogo.value++;
  }

  static Muni? muni(String? id) {
    if (id == null) return null;
    for (final m in munis) {
      if (m.id == id) return m;
    }
    return null;
  }

  /// Municipios base del departamento más los agregados desde el panel.
  static List<({String id, String n, Muni? base})> munisDe(String depK) {
    final l = <({String id, String n, Muni? base})>[
      for (final m in munis.where((m) => m.dep == depK)) (id: m.id, n: m.n, base: m),
    ];
    for (final i in items) {
      if (i.dep == depK && i.muni == null && i.munNombre.isNotEmpty) {
        final id = i.muniId!;
        if (!l.any((x) => x.id == id)) l.add((id: id, n: i.munNombre, base: null));
      }
    }
    return l;
  }

  static String muniNombre(String depK, String? id) {
    if (id == null) return '';
    for (final m in munisDe(depK)) {
      if (m.id == id) return m.n;
    }
    return '';
  }

  static String lugarDe(Item i) {
    final mn = muniNombre(i.dep, i.muniId);
    final d = dep[i.dep];
    return [if (mn.isNotEmpty) mn, if (d != null) d.n].join(', ');
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

  static String slug(String s) {
    final t = norm(s).replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    return t.length > 60 ? t.substring(0, 60) : t;
  }
}
