import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data.dart';
import 'screens.dart';
import 'servicios.dart';
import 'state.dart';

// Colores del logo
const kSol = Color(0xFFF2C014);
const kMar = Color(0xFF1857B8);
const kRojo = Color(0xFFD3242E);
const kNavy = Color(0xFF12245C);
const kSelva = Color(0xFF1D7444);

ThemeData buildTheme(Brightness b) {
  final scheme = ColorScheme.fromSeed(
    seedColor: kMar,
    brightness: b,
    primary: b == Brightness.light ? kMar : const Color(0xFF8AB8FF),
    secondary: kSol,
    error: kRojo,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        b == Brightness.light ? const Color(0xFFF3F5FA) : const Color(0xFF0B1129),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: scheme.onSurface),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
  );
}

class Cat {
  final String nombre, corto;
  final IconData icono;
  final Color color;
  const Cat(this.nombre, this.corto, this.icono, this.color);
}

const cats = <String, Cat>{
  'sitio': Cat('Sitios turísticos', 'Sitios', Icons.landscape_outlined, Color(0xFF1D7444)),
  'comida': Cat('Gastronomía', 'Comida', Icons.ramen_dining_outlined, Color(0xFFC0602A)),
  'cultura': Cat('Cultura e historia', 'Cultura', Icons.museum_outlined, Color(0xFF8B3FB3)),
  'musica': Cat('Música', 'Música', Icons.music_note_outlined, Color(0xFFD3242E)),
  'hotel': Cat('Hoteles y hospedaje', 'Hoteles', Icons.hotel_outlined, Color(0xFF1857B8)),
  'restaurante': Cat('Restaurantes', 'Restaurantes', Icons.restaurant_outlined, Color(0xFFB07A00)),
  'evento': Cat('Eventos y fiestas', 'Eventos', Icons.event_outlined, Color(0xFF0F6F73)),
};

class Region {
  final String nombre;
  final Color a, b;
  const Region(this.nombre, this.a, this.b);
}

const regiones = <String, Region>{
  'caribe': Region('Caribe', Color(0xFF1B78C9), Color(0xFFF2C014)),
  'andina': Region('Andina', Color(0xFF1D7444), Color(0xFF8FBF5A)),
  'pacifica': Region('Pacífica', Color(0xFF0F6F73), Color(0xFF47B39D)),
  'orinoquia': Region('Orinoquía', Color(0xFFC0602A), Color(0xFFF0B23C)),
  'amazonia': Region('Amazonía', Color(0xFF135A35), Color(0xFF5FA04E)),
  'insular': Region('Insular', Color(0xFF0AA3B5), Color(0xFF7FDCD0)),
};

const meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
const mesesLargo = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
];

Future<void> abrirUrl(BuildContext context, String url) async {
  final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')));
  }
}

String consultaLugar(Item i) => i.tieneCoord
    ? '${i.lat},${i.lon}'
    : '${i.n}, ${Catalogo.lugarDe(i)}, Colombia';

String urlMapa(Item i) =>
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(consultaLugar(i))}';

String urlRuta(List<Item> r) {
  var u = 'https://www.google.com/maps/dir/?api=1&travelmode=driving'
      '&origin=${Uri.encodeComponent(consultaLugar(r.first))}'
      '&destination=${Uri.encodeComponent(consultaLugar(r.last))}';
  if (r.length > 2) {
    u += '&waypoints=${Uri.encodeComponent(r.sublist(1, r.length - 1).map(consultaLugar).join('|'))}';
  }
  return u;
}

/// Nombre de la app con los colores del logo.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 22});
  final double size;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final st = TextStyle(fontSize: size, fontWeight: FontWeight.w800, letterSpacing: -0.3);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Image.asset('assets/pin.png', height: size * 1.5),
      const SizedBox(width: 6),
      Text.rich(TextSpan(style: st, children: [
        TextSpan(text: 'Vive', style: TextStyle(color: dark ? const Color(0xFFC9D6FF) : kNavy)),
        const TextSpan(text: 'Col', style: TextStyle(color: Color(0xFFE0AD00))),
        TextSpan(text: 'om', style: TextStyle(color: dark ? const Color(0xFF8AB8FF) : kMar)),
        TextSpan(text: 'bia', style: TextStyle(color: dark ? const Color(0xFFFF7A7F) : kRojo)),
      ])),
    ]);
  }
}

/// Franja con los colores de la bandera.
class Bandera extends StatelessWidget implements PreferredSizeWidget {
  const Bandera({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(5);
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 5,
        child: Row(children: [
          Expanded(flex: 2, child: ColoredBox(color: kSol)),
          Expanded(child: ColoredBox(color: kMar)),
          Expanded(child: ColoredBox(color: kRojo)),
        ]),
      );
}

/// Ilustración de paisaje según la región.
class BandaRegion extends StatelessWidget {
  const BandaRegion({super.key, required this.region, this.height = 150, this.semilla = ''});
  final String region;
  final double height;
  final String semilla;
  @override
  Widget build(BuildContext context) {
    final r = regiones[region] ?? regiones['caribe']!;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _Paisaje(r, region, semilla.hashCode)),
    );
  }
}

class _Paisaje extends CustomPainter {
  _Paisaje(this.r, this.tipo, this.seed);
  final Region r;
  final String tipo;
  final int seed;
  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    c.drawRect(Offset.zero & s, Paint()..color = r.b.withOpacity(0.25));
    final sx = w * (0.55 + (seed.abs() % 30) / 100);
    c.drawCircle(Offset(sx, h * 0.32), h * 0.17, Paint()..color = kSol);
    final p1 = Path();
    if (tipo == 'andina') {
      p1.moveTo(0, h);
      p1.lineTo(w * 0.22, h * 0.35);
      p1.lineTo(w * 0.38, h * 0.6);
      p1.lineTo(w * 0.6, h * 0.22);
      p1.lineTo(w * 0.82, h * 0.55);
      p1.lineTo(w, h * 0.4);
      p1.lineTo(w, h);
      p1.close();
    } else {
      p1.moveTo(0, h * 0.62);
      p1.quadraticBezierTo(w * 0.25, h * 0.45, w * 0.5, h * 0.62);
      p1.quadraticBezierTo(w * 0.75, h * 0.78, w, h * 0.6);
      p1.lineTo(w, h);
      p1.lineTo(0, h);
      p1.close();
    }
    c.drawPath(p1, Paint()..color = r.b);
    final p2 = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.3, h * 0.66, w * 0.6, h * 0.78)
      ..quadraticBezierTo(w * 0.8, h * 0.86, w, h * 0.74)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    c.drawPath(p2, Paint()..color = r.a);
  }

  @override
  bool shouldRepaint(covariant _Paisaje old) => old.tipo != tipo || old.seed != seed;
}

class IconoCat extends StatelessWidget {
  const IconoCat(this.c, {super.key, this.size = 40});
  final String c;
  final double size;
  @override
  Widget build(BuildContext context) {
    final k = cats[c]!;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: k.color.withOpacity(dark ? 0.3 : 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(k.icono, size: size * 0.55, color: dark ? Color.lerp(k.color, Colors.white, 0.45) : k.color),
    );
  }
}

class ItemTile extends StatelessWidget {
  const ItemTile(this.i, {super.key, this.mostrarLugar = false});
  final Item i;
  final bool mostrarLugar;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: AppState.i,
      builder: (context, _) => ListTile(
        leading: i.m != null
            ? Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                child: Text(meses[i.m! - 1], style: const TextStyle(fontWeight: FontWeight.w800)),
              )
            : IconoCat(i.c),
        title: Text(i.n, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(mostrarLugar ? Catalogo.lugarDe(i) : i.d,
            maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: AppState.i.esFav(i.id)
            ? const Icon(Icons.favorite, color: kRojo, size: 20)
            : const Icon(Icons.chevron_right),
        onTap: () => mostrarItem(context, i),
      ),
    );
  }
}

/// Lista agrupada en una tarjeta.
class Lista extends StatelessWidget {
  const Lista(this.hijos, {super.key});
  final List<Widget> hijos;
  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          for (var k = 0; k < hijos.length; k++) ...[
            if (k > 0) const Divider(height: 1),
            hijos[k],
          ]
        ]),
      );
}

class Titulo extends StatelessWidget {
  const Titulo(this.texto, {super.key, this.accion});
  final String texto;
  final Widget? accion;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Row(children: [
          Expanded(
              child: Text(texto,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700))),
          if (accion != null) accion!,
        ]),
      );
}

/// Foto: la del administrador si existe; si no, la de Wikipedia.
class Foto extends StatelessWidget {
  const Foto({super.key, required this.url, this.wiki, this.height = 200, this.respaldo});
  final String url;
  final Future<InfoWiki?>? wiki;
  final double height;
  final Widget? respaldo;

  @override
  Widget build(BuildContext context) {
    final vacio = respaldo ?? SizedBox(height: 0, width: double.infinity);
    if (url.isNotEmpty) return _img(url, null, vacio);
    if (wiki == null) return vacio;
    return FutureBuilder<InfoWiki?>(
      future: wiki,
      builder: (context, s) {
        final w = s.data;
        if (w == null || w.foto.isEmpty) return vacio;
        return _img(w.foto, 'Foto: Wikipedia', vacio);
      },
    );
  }

  Widget _img(String src, String? credito, Widget vacio) => SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(fit: StackFit.expand, children: [
          Image.network(
            src,
            fit: BoxFit.cover,
            headers: encabezadosImagen,
            errorBuilder: (_, __, ___) => vacio,
            loadingBuilder: (c, child, p) => p == null
                ? child
                : ColoredBox(color: Theme.of(c).colorScheme.surfaceContainerHighest),
          ),
          if (credito != null)
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                child: Text(credito, style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ),
        ]),
      );
}

/// Resumen de Wikipedia con enlace al artículo.
class ResumenWiki extends StatelessWidget {
  const ResumenWiki(this.wiki, {super.key});
  final Future<InfoWiki?> wiki;
  @override
  Widget build(BuildContext context) => FutureBuilder<InfoWiki?>(
        future: wiki,
        builder: (context, s) {
          final w = s.data;
          if (w == null || w.resumen.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('SEGÚN WIKIPEDIA',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(w.resumen, style: const TextStyle(height: 1.4)),
              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () => abrirUrl(context, w.url),
                child: const Text('Leer más en Wikipedia'),
              ),
            ]),
          );
        },
      );
}

/// Clima actual del lugar.
class ChipClima extends StatelessWidget {
  const ChipClima(this.lat, this.lon, {super.key});
  final double lat, lon;
  @override
  Widget build(BuildContext context) => FutureBuilder<Clima?>(
        future: ServicioClima.actual(lat, lon),
        builder: (context, s) {
          final c = s.data;
          if (c == null) return const SizedBox.shrink();
          return Chip(
            avatar: const Icon(Icons.wb_sunny_outlined, size: 18),
            label: Text('Ahora: ${c.temp.round()} °C · ${c.descripcion}'),
            visualDensity: VisualDensity.compact,
          );
        },
      );
}

String urlVideos(Item i) => i.video.isNotEmpty
    ? i.video
    : 'https://www.youtube.com/results?search_query=${Uri.encodeComponent('${i.n} ${Catalogo.lugarDe(i)}')}';

void mostrarItem(BuildContext context, Item i) {
  final conFoto = i.foto.isNotEmpty || i.c == 'sitio' || i.c == 'cultura';
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (ctx) => ListenableBuilder(
      listenable: AppState.i,
      builder: (ctx, _) {
        final st = AppState.i;
        final fav = st.esFav(i.id), ruta = st.enRuta(i.id);
        final k = cats[i.c]!;
        final wiki = (i.c == 'sitio' || i.c == 'cultura' || i.c == 'comida') ? Wikipedia.item(i) : null;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (conFoto)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Foto(url: i.foto, wiki: wiki, height: 190),
              ),
            const SizedBox(height: 10),
            Wrap(spacing: 6, children: [
              Chip(
                  avatar: Icon(k.icono, size: 18, color: k.color),
                  label: Text(k.corto),
                  visualDensity: VisualDensity.compact),
              if (i.m != null)
                Chip(label: Text(mesesLargo[i.m! - 1]), visualDensity: VisualDensity.compact),
            ]),
            const SizedBox(height: 8),
            Text(i.n, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              icon: const Icon(Icons.place_outlined, size: 18),
              label: Text(Catalogo.lugarDe(i)),
              onPressed: () {
                Navigator.pop(ctx);
                final mu = i.muniId;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => mu != null ? MuniScreen(depK: i.dep, muniId: mu) : DeptoScreen(depK: i.dep)));
              },
            ),
            if (i.d.isNotEmpty) Text(i.d, style: const TextStyle(fontSize: 16, height: 1.45)),
            if (i.tip.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12)),
                child: Text('Consejo: ${i.tip}'),
              ),
            if (wiki != null && i.c != 'comida') ResumenWiki(wiki),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => st.toggleFav(i.id),
                  icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
                  label: Text(fav ? 'Guardado' : 'Guardar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => st.toggleRuta(i.id),
                  icon: Icon(ruta ? Icons.check : Icons.alt_route),
                  label: Text(ruta ? 'En mi ruta' : 'A mi ruta'),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => abrirUrl(ctx, urlMapa(i)),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Cómo llegar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => abrirUrl(ctx, urlVideos(i)),
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(i.video.isNotEmpty ? 'Ver video' : 'Videos'),
                ),
              ),
            ]),
            if (i.c == 'hotel' || i.c == 'restaurante')
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('Confirma precios, horarios y reservas con el establecimiento.',
                    style: TextStyle(fontSize: 13)),
              ),
          ]),
        );
      },
    ),
  );
}
