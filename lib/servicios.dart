import 'dart:convert';

import 'package:http/http.dart' as http;

import 'data.dart';

const _agente = {'User-Agent': 'ViveColombia/1.0 (app educativa SENA; Pijino del Carmen, Colombia)'};

/// Encabezados para cargar imágenes de Wikimedia.
const encabezadosImagen = _agente;

class InfoWiki {
  final String titulo, resumen, foto, url;
  const InfoWiki(this.titulo, this.resumen, this.foto, this.url);
}

/// Fotos y resúmenes de Wikipedia en español (gratis, sin clave).
class Wikipedia {
  static final Map<String, Future<InfoWiki?>> _cache = {};

  static Future<InfoWiki?> buscar(String consulta, {String? debeContener}) {
    final clave = '$consulta|${debeContener ?? ''}';
    return _cache.putIfAbsent(clave, () => _buscar(consulta, debeContener));
  }

  static Future<InfoWiki?> _buscar(String consulta, String? debeContener) async {
    try {
      final uri = Uri.https('es.wikipedia.org', '/w/api.php', {
        'action': 'query',
        'format': 'json',
        'generator': 'search',
        'gsrsearch': consulta,
        'gsrlimit': '3',
        'prop': 'pageimages|extracts|info',
        'inprop': 'url',
        'piprop': 'thumbnail',
        'pithumbsize': '900',
        'exintro': '1',
        'explaintext': '1',
        'exsentences': '3',
      });
      final r = await http.get(uri, headers: _agente).timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) return null;
      final j = jsonDecode(r.body) as Map<String, dynamic>;
      final pages = ((j['query'] as Map<String, dynamic>?)?['pages'] as Map<String, dynamic>?)?.values.toList() ?? [];
      pages.sort((a, b) => ((a as Map)['index'] as num? ?? 99).compareTo((b as Map)['index'] as num? ?? 99));
      for (final p in pages) {
        final m = p as Map<String, dynamic>;
        final titulo = (m['title'] ?? '').toString();
        if (debeContener != null && !_coincide(titulo, debeContener)) continue;
        final foto = ((m['thumbnail'] as Map<String, dynamic>?)?['source'] ?? '').toString();
        final resumen = (m['extract'] ?? '').toString();
        final url = (m['fullurl'] ?? 'https://es.wikipedia.org/wiki/${Uri.encodeComponent(titulo)}').toString();
        return InfoWiki(titulo, resumen, foto, url);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// El título debe compartir al menos una palabra importante con el nombre buscado,
  /// para no mostrar la foto de otro lugar.
  static bool _coincide(String titulo, String nombre) {
    const vacias = {'de', 'del', 'la', 'las', 'los', 'el', 'y', 'en', 'san', 'santa'};
    final t = Catalogo.norm(titulo);
    final palabras = Catalogo.norm(nombre)
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.length > 3 && !vacias.contains(w));
    return palabras.any(t.contains);
  }

  static Future<InfoWiki?> depto(Depto d) {
    if (d.k == 'co-sa') {
      return buscar('Archipiélago de San Andrés, Providencia y Santa Catalina', debeContener: 'San Andrés');
    }
    return buscar('departamento de ${d.n} Colombia', debeContener: d.n);
  }

  static Future<InfoWiki?> muni(String nombre, String depto) =>
      buscar('$nombre $depto Colombia municipio', debeContener: nombre);

  static Future<InfoWiki?> item(Item i) {
    final d = Catalogo.dep[i.dep]?.n ?? '';
    return buscar('${i.n} $d Colombia', debeContener: i.n);
  }
}

class Clima {
  final double temp;
  final int codigo;
  const Clima(this.temp, this.codigo);

  String get descripcion {
    if (codigo == 0) return 'Despejado';
    if (codigo <= 3) return 'Parcialmente nublado';
    if (codigo <= 48) return 'Neblina';
    if (codigo <= 67) return 'Lluvia';
    if (codigo <= 77) return 'Nieve';
    if (codigo <= 82) return 'Aguaceros';
    return 'Tormenta';
  }
}

/// Clima actual con Open-Meteo (gratis, sin clave).
class ServicioClima {
  static final Map<String, Future<Clima?>> _cache = {};

  static Future<Clima?> actual(double lat, double lon) =>
      _cache.putIfAbsent('${lat.toStringAsFixed(2)},${lon.toStringAsFixed(2)}', () => _pedir(lat, lon));

  static Future<Clima?> _pedir(double lat, double lon) async {
    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '$lat',
        'longitude': '$lon',
        'current': 'temperature_2m,weather_code',
        'timezone': 'America/Bogota',
      });
      final r = await http.get(uri).timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) return null;
      final c = (jsonDecode(r.body) as Map<String, dynamic>)['current'] as Map<String, dynamic>;
      return Clima((c['temperature_2m'] as num).toDouble(), (c['weather_code'] as num).toInt());
    } catch (_) {
      return null;
    }
  }
}
