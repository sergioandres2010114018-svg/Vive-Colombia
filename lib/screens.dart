import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'data.dart';
import 'servicios.dart';
import 'state.dart';
import 'ui.dart';

const _pad = EdgeInsets.fromLTRB(16, 8, 16, 32);

// ---------------------------------------------------------------- Inicio
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pij = Catalogo.muni('pijino');
    return Scaffold(
      appBar: AppBar(
        title: const Wordmark(),
        bottom: const Bandera(),
        actions: [
          IconButton(
            tooltip: 'Buscar',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const BuscarScreen())),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([AppState.i, cambiosCatalogo]),
        builder: (context, _) => ListView(padding: _pad, children: [
          const SizedBox(height: 8),
          Text(
            AppState.i.nombre.isEmpty
                ? 'BIENVENIDO'
                : 'HOLA, ${AppState.i.nombre.split(' ').first.toUpperCase()}',
            style: TextStyle(
                fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(children: [
              const TextSpan(text: 'Descubre la esencia de '),
              TextSpan(text: 'Colombia', style: TextStyle(color: cs.error)),
              const TextSpan(text: ' en un solo lugar'),
            ]),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.15),
          ),
          const SizedBox(height: 14),
          TextField(
            readOnly: true,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const BuscarScreen())),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Busca un destino, plato o fiesta',
              filled: true,
              fillColor: cs.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.95,
            children: [
              for (final e in cats.entries)
                _BotonCat(
                  icono: IconoCat(e.key),
                  texto: e.value.corto,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => CategoriaScreen(c: e.key))),
                ),
              _BotonCat(
                icono: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.map_outlined, size: 22),
                ),
                texto: 'Mapa',
                onTap: () => AppState.i.tab.value = 2,
              ),
            ],
          ),
          if (pij != null) ...[
            const Titulo('Destino destacado'),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => MuniScreen(depK: pij.dep, muniId: pij.id))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const BandaRegion(region: 'caribe', height: 140, semilla: 'pijino'),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('MAGDALENA · REGIÓN CARIBE',
                          style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(pij.n, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      const Text('Ciénaga, chandé, Festival del Bocachico y la Virgen del Carmen.'),
                    ]),
                  ),
                ]),
              ),
            ),
          ],
          Titulo('Próximas fiestas',
              accion: TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CategoriaScreen(c: 'evento'))),
                child: const Text('Ver todas'),
              )),
          Lista([for (final i in Catalogo.proximos(4)) ItemTile(i, mostrarLugar: true)]),
          const Titulo('Regiones'),
          SizedBox(
            height: 160,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final r in regiones.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: 150,
                    child: Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ExplorarScreen(region: r.key))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          BandaRegion(region: r.key, height: 95, semilla: r.key),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                            child: Text(r.value.nombre,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                                '${Catalogo.deptos.where((d) => d.r == r.key).length} departamentos',
                                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _BotonCat extends StatelessWidget {
  const _BotonCat({required this.icono, required this.texto, required this.onTap});
  final Widget icono;
  final String texto;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            icono,
            const SizedBox(height: 4),
            Text(texto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

// ---------------------------------------------------------------- Explorar
class ExplorarScreen extends StatefulWidget {
  const ExplorarScreen({super.key, this.region = 'todas'});
  final String region;
  @override
  State<ExplorarScreen> createState() => _ExplorarState();
}

class _ExplorarState extends State<ExplorarScreen> {
  late String r = widget.region;
  @override
  Widget build(BuildContext context) {
    final deps = Catalogo.deptos.where((d) => r == 'todas' || d.r == r).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar'), bottom: const Bandera()),
      body: ListView(padding: _pad, children: [
        const SizedBox(height: 8),
        Filtros(
          opciones: {'todas': 'Todas', for (final e in regiones.entries) e.key: e.value.nombre},
          valor: r,
          onCambio: (v) => setState(() => r = v),
        ),
        Titulo(r == 'todas' ? '32 departamentos' : 'Región ${regiones[r]!.nombre}'),
        Lista([
          for (final d in deps)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: regiones[d.r]!.a.withOpacity(0.15),
                child: Icon(d.foco ? Icons.place : Icons.landscape_outlined, color: regiones[d.r]!.a),
              ),
              title: Text(d.n, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Capital: ${d.cap} · ${regiones[d.r]!.nombre}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => DeptoScreen(depK: d.k))),
            ),
        ]),
      ]),
    );
  }
}

/// Fila horizontal de chips para filtrar.
class Filtros extends StatelessWidget {
  const Filtros({super.key, required this.opciones, required this.valor, required this.onCambio});
  final Map<String, String> opciones;
  final String valor;
  final ValueChanged<String> onCambio;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 44,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (final e in opciones.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(e.value),
                selected: valor == e.key,
                onSelected: (_) => onCambio(e.key),
              ),
            ),
        ]),
      );
}

// ---------------------------------------------------------------- Departamento
class DeptoScreen extends StatefulWidget {
  const DeptoScreen({super.key, required this.depK});
  final String depK;
  @override
  State<DeptoScreen> createState() => _DeptoState();
}

class _DeptoState extends State<DeptoScreen> {
  String f = 'todas';
  @override
  Widget build(BuildContext context) {
    final d = Catalogo.dep[widget.depK]!;
    final items = Catalogo.items.where((i) => i.dep == d.k && i.muniId == null).toList();
    final presentes = cats.keys.where((c) => items.any((i) => i.c == c)).toList();
    final munis = Catalogo.munisDe(d.k);
    final total = Catalogo.items.where((i) => i.dep == d.k).length;
    return Scaffold(
      appBar: AppBar(title: Text(d.n), bottom: const Bandera()),
      body: ValueListenableBuilder<int>(valueListenable: cambiosCatalogo, builder: (context, _, __) => ListView(padding: EdgeInsets.zero, children: [
        Foto(url: '', wiki: Wikipedia.depto(d), height: 200, respaldo: BandaRegion(region: d.r, height: 170, semilla: d.k)),
        Padding(
          padding: _pad,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('REGIÓN ${regiones[d.r]!.nombre.toUpperCase()}',
                style: const TextStyle(fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.w700)),
            Text(d.n, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _Dato('Capital', d.cap)),
              const SizedBox(width: 8),
              Expanded(child: _Dato('Lugares en la app', '$total')),
            ]),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: ChipClima(d.lat, d.lon)),
            const SizedBox(height: 4),
            Text(d.intro, style: const TextStyle(fontSize: 16, height: 1.45)),
            ResumenWiki(Wikipedia.depto(d)),
            if (munis.isNotEmpty) ...[
              const Titulo('Municipios'),
              Lista([
                for (final m in munis)
                  ListTile(
                    leading: const IconoCat('sitio'),
                    title: Text(m.n, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(m.base?.intro ?? 'Agregado desde el panel', maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => MuniScreen(depK: d.k, muniId: m.id))),
                  ),
              ]),
            ],
            const Titulo('Qué ver y vivir'),
            Filtros(
              opciones: {'todas': 'Todo', for (final c in presentes) c: cats[c]!.corto},
              valor: f,
              onCambio: (v) => setState(() => f = v),
            ),
            const SizedBox(height: 8),
            Lista([for (final i in items.where((i) => f == 'todas' || i.c == f)) ItemTile(i)]),
          ]),
        ),
      ])),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.k, this.v);
  final String k, v;
  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(k.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

// ---------------------------------------------------------------- Municipio
class MuniScreen extends StatefulWidget {
  const MuniScreen({super.key, required this.depK, required this.muniId});
  final String depK, muniId;
  @override
  State<MuniScreen> createState() => _MuniState();
}

class _MuniState extends State<MuniScreen> {
  String f = 'todas';
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: cambiosCatalogo,
      builder: (context, _, __) {
        final d = Catalogo.dep[widget.depK]!;
        final m = Catalogo.muni(widget.muniId);
        final nombre = m?.n ?? Catalogo.muniNombre(widget.depK, widget.muniId);
        final items = Catalogo.items.where((i) => i.dep == d.k && i.muniId == widget.muniId).toList()
          ..sort((a, b) => (a.m ?? 0).compareTo(b.m ?? 0));
        final presentes = cats.keys.where((c) => items.any((i) => i.c == c)).toList();
        final faltan = ['hotel', 'restaurante'].where((c) => !presentes.contains(c)).toList();
        final cs = Theme.of(context).colorScheme;
        final wiki = Wikipedia.muni(nombre, d.n);
        return Scaffold(
          appBar: AppBar(title: Text(nombre), bottom: const Bandera()),
          body: ListView(padding: EdgeInsets.zero, children: [
            Foto(url: '', wiki: wiki, height: 210, respaldo: BandaRegion(region: d.r, height: 170, semilla: widget.muniId)),
            Padding(
              padding: _pad,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('${d.n.toUpperCase()} · REGIÓN ${regiones[d.r]!.nombre.toUpperCase()}',
                    style: const TextStyle(fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.w700)),
                Text(nombre, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                if (m != null) Align(alignment: Alignment.centerLeft, child: ChipClima(m.lat, m.lon)),
                if (m != null && m.datos.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final x in m.datos)
                      SizedBox(
                        width: (MediaQuery.sizeOf(context).width - 40) / 2,
                        child: _Dato(x[0], x[1]),
                      ),
                  ]),
                ],
                const SizedBox(height: 12),
                if (m != null && m.intro.isNotEmpty) Text(m.intro, style: const TextStyle(fontSize: 16, height: 1.45)),
                if (m != null && m.historia.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(m.historia, style: TextStyle(height: 1.45, color: cs.onSurfaceVariant)),
                ],
                if (m != null && m.llegar.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                    child: Text('Cómo llegar. ${m.llegar}'),
                  ),
                ResumenWiki(wiki),
                Titulo('Qué ver y vivir',
                    accion: Text('${items.length} lugares', style: TextStyle(color: cs.onSurfaceVariant))),
                Filtros(
                  opciones: {'todas': 'Todo', for (final c in presentes) c: cats[c]!.corto},
                  valor: f,
                  onCambio: (v) => setState(() => f = v),
                ),
                const SizedBox(height: 8),
                Lista([for (final i in items.where((i) => f == 'todas' || i.c == f)) ItemTile(i)]),
                if (faltan.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Aún no hay ${faltan.map((c) => cats[c]!.nombre.toLowerCase()).join(' ni ')} registrados aquí. '
                      'Los administradores pueden agregarlos desde Perfil → Panel de contenido.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Categoría
class CategoriaScreen extends StatefulWidget {
  const CategoriaScreen({super.key, required this.c});
  final String c;
  @override
  State<CategoriaScreen> createState() => _CategoriaState();
}

class _CategoriaState extends State<CategoriaScreen> {
  @override
  void initState() {
    super.initState();
    cambiosCatalogo.addListener(_refrescar);
  }

  void _refrescar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    cambiosCatalogo.removeListener(_refrescar);
    super.dispose();
  }

  String r = 'todas';
  @override
  Widget build(BuildContext context) {
    final all = Catalogo.items.where((i) => i.c == widget.c).toList();
    final regs = regiones.keys.where((k) => all.any((i) => Catalogo.dep[i.dep]?.r == k)).toList();
    final items = all.where((i) => r == 'todas' || Catalogo.dep[i.dep]?.r == r).toList();
    if (widget.c == 'evento') {
      items.sort((a, b) => (a.m ?? 13).compareTo(b.m ?? 13));
    } else {
      items.sort((a, b) => Catalogo.lugarDe(a).compareTo(Catalogo.lugarDe(b)));
    }
    return Scaffold(
      appBar: AppBar(title: Text(cats[widget.c]!.nombre), bottom: const Bandera()),
      body: ListView(padding: _pad, children: [
        const SizedBox(height: 8),
        Filtros(
          opciones: {'todas': 'Todo el país', for (final k in regs) k: regiones[k]!.nombre},
          valor: r,
          onCambio: (v) => setState(() => r = v),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Todavía no hay registros en esta categoría.', textAlign: TextAlign.center),
          )
        else
          Lista([for (final i in items) ItemTile(i, mostrarLugar: true)]),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Buscar
class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});
  @override
  State<BuscarScreen> createState() => _BuscarState();
}

class _BuscarState extends State<BuscarScreen> {
  @override
  void initState() {
    super.initState();
    cambiosCatalogo.addListener(_refrescar);
  }

  void _refrescar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    cambiosCatalogo.removeListener(_refrescar);
    super.dispose();
  }

  String q = '';
  @override
  Widget build(BuildContext context) {
    final n = Catalogo.norm(q.trim());
    final deps = n.length < 2
        ? <Depto>[]
        : Catalogo.deptos.where((d) => Catalogo.norm('${d.n} ${d.cap}').contains(n)).toList();
    final munis = n.length < 2
        ? <Muni>[]
        : Catalogo.munis.where((m) => Catalogo.norm(m.n).contains(n)).toList();
    final items = n.length < 2
        ? <Item>[]
        : Catalogo.items
            .where((i) => Catalogo.norm('${i.n} ${i.d} ${Catalogo.lugarDe(i)} ${cats[i.c]!.nombre}')
                .contains(n))
            .take(60)
            .toList();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
              hintText: 'Destino, plato, fiesta, música…', border: InputBorder.none),
          onChanged: (v) => setState(() => q = v),
        ),
        bottom: const Bandera(),
      ),
      body: ListView(padding: _pad, children: [
        if (n.length < 2)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Prueba con “bocachico”, “cumbia” o “playa”.'),
          )
        else if (deps.isEmpty && munis.isEmpty && items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Sin resultados para “$q”. Revisa la ortografía.'),
          )
        else ...[
          if (deps.isNotEmpty) ...[
            const Titulo('Departamentos'),
            Lista([
              for (final d in deps)
                ListTile(
                  title: Text(d.n),
                  subtitle: Text('Capital: ${d.cap}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => DeptoScreen(depK: d.k))),
                ),
            ]),
          ],
          if (munis.isNotEmpty) ...[
            const Titulo('Municipios'),
            Lista([
              for (final m in munis)
                ListTile(
                  title: Text(m.n),
                  subtitle: Text(Catalogo.dep[m.dep]?.n ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => MuniScreen(depK: m.dep, muniId: m.id))),
                ),
            ]),
          ],
          if (items.isNotEmpty) ...[
            const Titulo('Lugares, comida, música y fiestas'),
            Lista([for (final i in items) ItemTile(i, mostrarLugar: true)]),
          ],
        ],
      ]),
    );
  }
}

// ---------------------------------------------------------------- Mapa
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});
  @override
  State<MapaScreen> createState() => _MapaState();
}

class _MapaState extends State<MapaScreen> {
  @override
  void initState() {
    super.initState();
    cambiosCatalogo.addListener(_refrescar);
  }

  void _refrescar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    cambiosCatalogo.removeListener(_refrescar);
    super.dispose();
  }

  final ctrl = MapController();
  String modo = 'pais';

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      for (final d in Catalogo.deptos)
        Marker(
          point: LatLng(d.lat, d.lon),
          width: 36,
          height: 36,
          child: GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => DeptoScreen(depK: d.k))),
            child: Tooltip(
              message: d.n,
              child: Icon(Icons.location_on, size: 34, color: d.foco ? kSol : kMar),
            ),
          ),
        ),
      if (modo == 'magdalena')
        for (final i in Catalogo.items.where((i) => i.tieneCoord))
          Marker(
            point: LatLng(i.lat!, i.lon!),
            width: 30,
            height: 30,
            child: GestureDetector(
              onTap: () => mostrarItem(context, i),
              child: Container(
                decoration: BoxDecoration(
                  color: cats[i.c]!.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(cats[i.c]!.icono, size: 16, color: Colors.white),
              ),
            ),
          ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa'), bottom: const Bandera()),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Filtros(
            opciones: const {'pais': 'Colombia', 'magdalena': 'Magdalena en detalle'},
            valor: modo,
            onCambio: (v) {
              setState(() => modo = v);
              if (v == 'magdalena') {
                ctrl.move(const LatLng(10.1, -74.2), 7.6);
              } else {
                ctrl.move(const LatLng(4.6, -74.0), 5);
              }
            },
          ),
        ),
        Expanded(
          child: FlutterMap(
            mapController: ctrl,
            options: MapOptions(
              initialCenter: LatLng(4.6, -74.0),
              initialZoom: 5,
              minZoom: 4,
              maxZoom: 17,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'co.vivecolombia.vive_colombia',
              ),
              MarkerLayer(markers: markers),
              RichAttributionWidget(attributions: [
                TextSourceAttribution('OpenStreetMap contributors',
                    onTap: () => abrirUrl(context, 'https://openstreetmap.org/copyright')),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Mis viajes
class ViajesScreen extends StatelessWidget {
  const ViajesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis viajes'), bottom: const Bandera()),
      body: ListenableBuilder(
        listenable: Listenable.merge([AppState.i, cambiosCatalogo]),
        builder: (context, _) {
          final st = AppState.i;
          final ruta = st.ruta.map((id) => Catalogo.porId[id]).whereType<Item>().toList();
          final favs = st.favs.map((id) => Catalogo.porId[id]).whereType<Item>().toList();
          return ListView(padding: _pad, children: [
            Titulo('Mi ruta', accion: Text('${ruta.length} paradas')),
            if (ruta.isEmpty)
              const _Vacio(Icons.alt_route, 'Tu ruta está vacía',
                  'Abre cualquier lugar y toca “A mi ruta”.')
            else ...[
              Lista([
                for (var k = 0; k < ruta.length; k++)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: kSol,
                      foregroundColor: const Color(0xFF3B2D00),
                      child: Text('${k + 1}'),
                    ),
                    title: Text(ruta[k].n, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(Catalogo.lugarDe(ruta[k])),
                    onTap: () => mostrarItem(context, ruta[k]),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                          tooltip: 'Subir',
                          onPressed: k == 0 ? null : () => st.mover(k, -1),
                          icon: const Icon(Icons.keyboard_arrow_up)),
                      IconButton(
                          tooltip: 'Bajar',
                          onPressed: k == ruta.length - 1 ? null : () => st.mover(k, 1),
                          icon: const Icon(Icons.keyboard_arrow_down)),
                      IconButton(
                          tooltip: 'Quitar',
                          onPressed: () => st.toggleRuta(ruta[k].id),
                          icon: const Icon(Icons.close)),
                    ]),
                  ),
              ]),
              const SizedBox(height: 10),
              if (ruta.length >= 2)
                FilledButton.icon(
                  onPressed: () => abrirUrl(context, urlRuta(ruta)),
                  icon: const Icon(Icons.directions),
                  label: const Text('Abrir ruta en Google Maps'),
                )
              else
                const Text('Agrega al menos dos paradas para abrir la ruta en Google Maps.'),
            ],
            Titulo('Favoritos', accion: Text('${favs.length}')),
            if (favs.isEmpty)
              const _Vacio(Icons.favorite_border, 'Aún no tienes favoritos',
                  'Toca “Guardar” en un lugar para verlo aquí.')
            else
              Lista([for (final i in favs) ItemTile(i, mostrarLugar: true)]),
          ]);
        },
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio(this.icono, this.titulo, this.texto);
  final IconData icono;
  final String titulo, texto;
  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Icon(icono, size: 36),
            const SizedBox(height: 8),
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(texto, textAlign: TextAlign.center),
          ]),
        ),
      );
}

class AcercaScreen extends StatelessWidget {
  const AcercaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final id = Catalogo.identidad;
    String t(String k) => (id[k] ?? '').toString();
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de'), bottom: const Bandera()),
      body: ListView(padding: _pad, children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Image.asset('assets/logo.png', width: 280),
          ),
        ),
        const SizedBox(height: 12),
        Text('“${t('slogan')}”', textAlign: TextAlign.center, style: const TextStyle(fontStyle: FontStyle.italic)),
        const Titulo('Misión'),
        Text(t('mision'), style: const TextStyle(height: 1.45)),
        const Titulo('Visión'),
        Text(t('vision'), style: const TextStyle(height: 1.45)),
        const Titulo('Equipo'),
        Text(t('equipo'), style: const TextStyle(height: 1.45)),
        const SizedBox(height: 16),
        const Text(
            'Confirma la información de hoteles, restaurantes y fechas con cada establecimiento u oficina de turismo antes de viajar.',
            style: TextStyle(fontSize: 13)),
      ]),
    );
  }
}
