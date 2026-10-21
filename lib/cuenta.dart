import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'data.dart';
import 'screens.dart';
import 'state.dart';
import 'ui.dart';

const _pad = EdgeInsets.fromLTRB(16, 8, 16, 32);

// ---------------------------------------------------------------- Login
const _creditos = 'Creado por Estudiantes IE Pijiño';

class _Pie extends StatelessWidget {
  const _Pie();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(children: [
      const SizedBox(width: 120, child: Bandera()),
      const SizedBox(height: 10),
      Text(_creditos,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
      const SizedBox(height: 2),
      Text('Institución Educativa Técnica Departamental Pijiño del Carmen · SENA',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
    ]);
  }
}

class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Image.asset('assets/logo.png', width: 250),
      );
}

/// Pantalla mientras se confirma si hay sesión iniciada.
class CargaScreen extends StatelessWidget {
  const CargaScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: SafeArea(
          child: Column(children: [
            Spacer(),
            _Logo(),
            SizedBox(height: 24),
            SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
            Spacer(),
            Padding(padding: EdgeInsets.only(bottom: 20), child: _Pie()),
          ]),
        ),
      );
}

/// Primera pantalla de la app: iniciar sesión, crear cuenta o explorar sin cuenta.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 44),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Center(child: _Logo()),
                const SizedBox(height: 12),
                Text('Descubre la esencia de Colombia en un solo lugar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic, color: cs.onSurfaceVariant)),
                const SizedBox(height: 8),
                const FormularioAcceso(),
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  onPressed: AppState.i.entrarComoInvitado,
                  icon: const Icon(Icons.explore_outlined),
                  label: const Text('Explorar sin cuenta'),
                ),
                const SizedBox(height: 28),
                const _Pie(),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Perfil
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil'), bottom: const Bandera()),
      body: ListenableBuilder(
        listenable: AppState.i,
        builder: (context, _) {
          final st = AppState.i;
          final u = st.usuario;
          return ListView(padding: _pad, children: [
            if (u == null) const FormularioAcceso() else _Cuenta(key: ValueKey(u.uid)),
            const Titulo('Más'),
            Lista([
              if (u != null)
                ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: const Text('Panel de contenido'),
                  subtitle: Text(st.esAdmin
                      ? 'Agregar y corregir lugares, fotos y videos'
                      : 'Solo para administradores'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const PanelScreen())),
                ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Acerca de ViveColombia'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const AcercaScreen())),
              ),
            ]),
            const SizedBox(height: 28),
            const _Pie(),
          ]);
        },
      ),
    );
  }
}

/// Inicio de sesión y registro con correo.
class FormularioAcceso extends StatefulWidget {
  const FormularioAcceso({super.key});
  @override
  State<FormularioAcceso> createState() => FormularioAccesoState();
}

class FormularioAccesoState extends State<FormularioAcceso> {
  final _form = GlobalKey<FormState>();
  final nombre = TextEditingController();
  final correo = TextEditingController();
  final clave = TextEditingController();
  bool registro = false, cargando = false, verClave = false;
  String? error;

  @override
  void dispose() {
    nombre.dispose();
    correo.dispose();
    clave.dispose();
    super.dispose();
  }

  Future<void> enviar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      cargando = true;
      error = null;
    });
    final st = AppState.i;
    final e = registro
        ? await st.registrar(correo.text.trim(), clave.text, nombre.text.trim())
        : await st.entrar(correo.text.trim(), clave.text);
    if (!mounted) return;
    setState(() {
      cargando = false;
      error = e;
    });
  }

  Future<void> olvido() async {
    final c = correo.text.trim();
    if (c.isEmpty) {
      setState(() => error = 'Escribe tu correo y vuelve a tocar “Olvidé mi contraseña”.');
      return;
    }
    final e = await AppState.i.recuperar(c);
    if (!mounted) return;
    setState(() => error = e);
    if (e == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Te enviamos un correo a $c para cambiar la contraseña.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Iniciar sesión')),
            ButtonSegment(value: true, label: Text('Crear cuenta')),
          ],
          selected: {registro},
          onSelectionChanged: (v) => setState(() {
            registro = v.first;
            error = null;
          }),
        ),
        const SizedBox(height: 16),
        Text(
          registro
              ? 'Crea tu cuenta para guardar tus favoritos y tu ruta en la nube.'
              : 'Entra para ver tus favoritos y tu ruta en cualquier celular.',
        ),
        const SizedBox(height: 12),
        if (registro) ...[
          TextFormField(
            controller: nombre,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
            validator: (v) => (v ?? '').trim().isEmpty ? 'Escribe tu nombre' : null,
          ),
          const SizedBox(height: 12),
        ],
        TextFormField(
          controller: correo,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(labelText: 'Correo', border: OutlineInputBorder()),
          validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim())
              ? null
              : 'Escribe un correo válido, por ejemplo nombre@gmail.com',
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: clave,
          obscureText: !verClave,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: verClave ? 'Ocultar' : 'Mostrar',
              icon: Icon(verClave ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => verClave = !verClave),
            ),
          ),
          validator: (v) => (v ?? '').length < 6 ? 'Mínimo 6 caracteres' : null,
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: cargando ? null : enviar,
          child: Text(cargando ? 'Un momento…' : (registro ? 'Crear cuenta' : 'Entrar')),
        ),
        if (!registro)
          TextButton(onPressed: olvido, child: const Text('Olvidé mi contraseña')),
      ]),
    );
  }
}

/// Datos del usuario con sesión iniciada.
class _Cuenta extends StatefulWidget {
  const _Cuenta({super.key});
  @override
  State<_Cuenta> createState() => _CuentaState();
}

class _CuentaState extends State<_Cuenta> {
  final _form = GlobalKey<FormState>();
  late final nombre = TextEditingController(text: _p('nombre'));
  late final origen = TextEditingController(text: _p('origen'));
  late String tipo = _p('tipo');
  late final Set<String> intereses =
      ((AppState.i.perfil['intereses'] ?? <dynamic>[]) as List).map((e) => e.toString()).toSet();

  static String _p(String k) => (AppState.i.perfil[k] ?? '').toString();
  static const tipos = ['', 'Turista nacional', 'Turista extranjero', 'Estudiante', 'Familia', 'Viajero independiente'];

  @override
  void dispose() {
    nombre.dispose();
    origen.dispose();
    super.dispose();
  }

  void guardar() {
    if (!_form.currentState!.validate()) return;
    AppState.i.guardarPerfil({
      ...AppState.i.perfil,
      'nombre': nombre.text.trim(),
      'origen': origen.text.trim(),
      'tipo': tipo,
      'intereses': intereses.toList(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil guardado')));
  }

  @override
  Widget build(BuildContext context) {
    final st = AppState.i;
    final u = st.usuario!;
    final cs = Theme.of(context).colorScheme;
    final n = st.nombre.isNotEmpty ? st.nombre : (u.displayName ?? '');
    return Form(
      key: _form,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: kSol,
              foregroundColor: const Color(0xFF3B2D00),
              child: Text(n.isEmpty ? '?' : n[0].toUpperCase()),
            ),
            title: Text(n.isEmpty ? 'Viajero' : n, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(u.email ?? ''),
            trailing: st.esAdmin ? const Chip(label: Text('Admin')) : null,
          ),
        ),
        const Titulo('Mis datos'),
        TextFormField(
          controller: nombre,
          decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
          validator: (v) => (v ?? '').trim().isEmpty ? 'Escribe tu nombre' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: origen,
          decoration: const InputDecoration(labelText: 'Ciudad o país de origen', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: tipos.contains(tipo) ? tipo : '',
          decoration: const InputDecoration(labelText: 'Viajo como', border: OutlineInputBorder()),
          items: [
            for (final t in tipos)
              DropdownMenuItem(value: t, child: Text(t.isEmpty ? 'Sin especificar' : t)),
          ],
          onChanged: (v) => setState(() => tipo = v ?? ''),
        ),
        const SizedBox(height: 12),
        const Text('Me interesa', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 4, children: [
          for (final e in cats.entries)
            FilterChip(
              label: Text(e.value.corto),
              selected: intereses.contains(e.key),
              onSelected: (s) => setState(() => s ? intereses.add(e.key) : intereses.remove(e.key)),
            ),
        ]),
        const SizedBox(height: 16),
        FilledButton(onPressed: guardar, child: const Text('Guardar cambios')),
        const SizedBox(height: 4),
        OutlinedButton(onPressed: () => st.salir(), child: const Text('Cerrar sesión')),
        const SizedBox(height: 12),
        Text('Tu código de usuario (para que te den permiso de administrador):',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        Row(children: [
          Expanded(child: SelectableText(u.uid, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
          IconButton(
            tooltip: 'Copiar',
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: u.uid));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Código copiado')));
            },
          ),
        ]),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Panel de contenido
class PanelScreen extends StatefulWidget {
  const PanelScreen({super.key});
  @override
  State<PanelScreen> createState() => _PanelState();
}

class _PanelState extends State<PanelScreen> {
  String dep = 'co-ma';
  String mu = 'todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de contenido'), bottom: const Bandera()),
      floatingActionButton: AppState.i.esAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditorScreen(dep: dep, mu: (mu == 'todos' || mu == 'depto') ? null : mu))),
              icon: const Icon(Icons.add),
              label: const Text('Agregar lugar'),
            )
          : null,
      body: ListenableBuilder(
        listenable: Listenable.merge([AppState.i, cambiosCatalogo]),
        builder: (context, _) {
          final st = AppState.i;
          if (!st.esAdmin) {
            return ListView(padding: _pad, children: const [
              SizedBox(height: 16),
              Text('Tu cuenta todavía no es administradora.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text('Para obtener permiso, envía tu código de usuario (está en Perfil) al administrador. '
                  'Él lo agrega en Firebase, en Firestore, dentro de la colección “admins”. '
                  'Luego cierra sesión y vuelve a entrar.'),
            ]);
          }
          final munis = Catalogo.munisDe(dep);
          if (mu != 'todos' && mu != 'depto' && !munis.any((m) => m.id == mu)) mu = 'todos';
          final items = Catalogo.items
              .where((i) => i.dep == dep && (mu == 'todos' || (mu == 'depto' ? i.muniId == null : i.muniId == mu)))
              .toList();
          return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), children: [
            Text('Los cambios se publican al instante en todos los celulares.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: dep,
              decoration: const InputDecoration(labelText: 'Departamento', border: OutlineInputBorder()),
              items: [for (final d in Catalogo.deptos) DropdownMenuItem(value: d.k, child: Text(d.n))],
              onChanged: (v) => setState(() {
                dep = v ?? dep;
                mu = 'todos';
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: mu,
              decoration: const InputDecoration(labelText: 'Municipio', border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem(value: 'todos', child: Text('Todos')),
                const DropdownMenuItem(value: 'depto', child: Text('Nivel departamento')),
                for (final m in munis) DropdownMenuItem(value: m.id, child: Text(m.n)),
              ],
              onChanged: (v) => setState(() => mu = v ?? 'todos'),
            ),
            const SizedBox(height: 12),
            Lista([
              for (final i in items)
                ListTile(
                  leading: IconoCat(i.c),
                  title: Text(i.n, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text([
                    cats[i.c]!.corto,
                    if (i.muniId != null) Catalogo.muniNombre(i.dep, i.muniId),
                    if (i.nuevo) 'nuevo' else if (i.editado) 'editado',
                    if (i.foto.isNotEmpty) 'con foto',
                    if (i.video.isNotEmpty) 'con video',
                  ].join(' · ')),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => EditorScreen(item: i, dep: i.dep))),
                ),
            ]),
          ]);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------- Editor
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, this.item, required this.dep, this.mu});
  final Item? item;
  final String dep;
  final String? mu;
  @override
  State<EditorScreen> createState() => _EditorState();
}

class _EditorState extends State<EditorScreen> {
  final _form = GlobalKey<FormState>();
  late final Item? i = widget.item;
  late final n = TextEditingController(text: i?.n ?? '');
  late final d = TextEditingController(text: i?.d ?? '');
  late final tip = TextEditingController(text: i?.tip ?? '');
  late final lat = TextEditingController(text: i?.lat?.toString() ?? '');
  late final lon = TextEditingController(text: i?.lon?.toString() ?? '');
  late final foto = TextEditingController(text: i?.foto ?? '');
  late final video = TextEditingController(text: i?.video ?? '');
  late final otroMuni = TextEditingController(text: i?.munNombre ?? '');
  late String c = i?.c ?? 'sitio';
  late String dep = i?.dep ?? widget.dep;
  late String muni = i?.muni ?? (i != null && i!.munNombre.isNotEmpty ? '__otro' : (widget.mu ?? ''));
  late int? mes = i?.m;
  bool guardando = false, confirmar = false, subiendo = false;
  String? error;
  late final String docId = i?.id ?? AppState.i.nuevoId();
  late final List<String> fotos = [...?i?.fotos];
  final List<String> porBorrar = [];

  Future<void> agregarFoto(ImageSource origen) async {
    try {
      final x = await ImagePicker().pickImage(source: origen, maxWidth: 1600, maxHeight: 1600, imageQuality: 80);
      if (x == null) return;
      setState(() {
        subiendo = true;
        error = null;
      });
      final bytes = await x.readAsBytes();
      final url = await AppState.i.subirFoto(docId, bytes);
      if (!mounted) return;
      setState(() {
        fotos.add(url);
        subiendo = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        subiendo = false;
        error = 'No se pudo subir la foto. Revisa tu conexión y que Storage esté activado en Firebase.';
      });
    }
  }

  void quitarFoto(String url) => setState(() {
        fotos.remove(url);
        porBorrar.add(url);
      });

  bool get esBase => i != null && !i!.nuevo;

  @override
  void dispose() {
    for (final t in [n, d, tip, lat, lon, foto, video, otroMuni]) {
      t.dispose();
    }
    super.dispose();
  }

  String? _coord(String? v, double min, double max) {
    final t = (v ?? '').trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    final x = double.tryParse(t);
    if (x == null || x < min || x > max) return 'Fuera de Colombia';
    return null;
  }

  String? _url(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    return t.startsWith('https://') ? null : 'Debe empezar por https://';
  }

  Future<void> guardar() async {
    if (!_form.currentState!.validate()) return;
    final la = double.tryParse(lat.text.trim().replaceAll(',', '.'));
    final lo = double.tryParse(lon.text.trim().replaceAll(',', '.'));
    if ((la == null) != (lo == null)) {
      setState(() => error = 'Escribe la latitud y la longitud, o deja ambas vacías.');
      return;
    }
    final datos = <String, dynamic>{
      'n': n.text.trim(),
      'c': c,
      'd': d.text.trim(),
      'tip': tip.text.trim(),
      'foto': foto.text.trim(),
      'fotos': fotos,
      'video': video.text.trim(),
      'dep': esBase ? i!.dep : dep,
      'muni': esBase ? (i!.muni ?? '') : (muni == '__otro' ? '' : muni),
      'munNombre': esBase ? i!.munNombre : (muni == '__otro' ? otroMuni.text.trim() : ''),
      if (la != null) 'lat': la,
      if (lo != null) 'lon': lo,
      if (mes != null) 'm': mes,
    };
    setState(() {
      guardando = true;
      error = null;
    });
    final e = await AppState.i.guardarLugar(docId, datos);
    if (!mounted) return;
    if (e == null) {
      for (final u in porBorrar) {
        AppState.i.borrarFoto(u);
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(i == null ? 'Lugar publicado' : 'Cambios guardados')));
    } else {
      setState(() {
        guardando = false;
        error = e;
      });
    }
  }

  Future<void> ocultar() async {
    if (!confirmar) {
      setState(() => confirmar = true);
      return;
    }
    final e = await AppState.i.ocultarLugar(i!);
    if (!mounted) return;
    if (e == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(i!.nuevo ? 'Lugar eliminado' : 'Lugar oculto de la app')));
    } else {
      setState(() => error = e);
    }
  }

  InputDecoration _dec(String l, {String? hint}) =>
      InputDecoration(labelText: l, hintText: hint, border: const OutlineInputBorder());

  @override
  Widget build(BuildContext context) {
    final munis = Catalogo.munisDe(dep).where((m) => m.base != null).toList();
    if (muni.isNotEmpty && muni != '__otro' && !munis.any((m) => m.id == muni)) muni = '';
    const gap = SizedBox(height: 12);
    return Scaffold(
      appBar: AppBar(title: Text(i == null ? 'Nuevo lugar' : 'Editar lugar'), bottom: const Bandera()),
      body: Form(
        key: _form,
        child: ListView(padding: _pad, children: [
          gap,
          TextFormField(
            controller: n,
            decoration: _dec('Nombre', hint: 'Ej. Hotel La Ciénaga'),
            validator: (v) => (v ?? '').trim().isEmpty ? 'Escribe el nombre' : null,
          ),
          gap,
          DropdownButtonFormField<String>(
            value: c,
            decoration: _dec('Categoría'),
            items: [for (final e in cats.entries) DropdownMenuItem(value: e.key, child: Text(e.value.nombre))],
            onChanged: (v) => setState(() => c = v ?? c),
          ),
          gap,
          DropdownButtonFormField<String>(
            value: dep,
            decoration: _dec('Departamento'),
            items: [for (final x in Catalogo.deptos) DropdownMenuItem(value: x.k, child: Text(x.n))],
            onChanged: esBase ? null : (v) => setState(() {
                  dep = v ?? dep;
                  muni = '';
                }),
          ),
          gap,
          DropdownButtonFormField<String>(
            value: muni,
            decoration: _dec('Municipio'),
            items: [
              const DropdownMenuItem(value: '', child: Text('Nivel departamento')),
              for (final m in munis) DropdownMenuItem(value: m.id, child: Text(m.n)),
              const DropdownMenuItem(value: '__otro', child: Text('Otro municipio…')),
            ],
            onChanged: esBase ? null : (v) => setState(() => muni = v ?? ''),
          ),
          if (muni == '__otro') ...[
            gap,
            TextFormField(
              controller: otroMuni,
              enabled: !esBase,
              decoration: _dec('Nombre del municipio'),
              validator: (v) => (muni == '__otro' && (v ?? '').trim().isEmpty) ? 'Escribe el municipio' : null,
            ),
          ],
          gap,
          TextFormField(controller: d, maxLines: 4, decoration: _dec('Descripción')),
          gap,
          TextFormField(controller: tip, decoration: _dec('Consejo para el viajero (opcional)')),
          gap,
          const Text('Fotos del lugar', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          SizedBox(
            height: 104,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final u in fotos)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(u, width: 104, height: 104, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(width: 104, height: 104, child: Icon(Icons.broken_image))),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => quitarFoto(u),
                        child: const CircleAvatar(
                            radius: 13, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 16, color: Colors.white)),
                      ),
                    ),
                  ]),
                ),
              if (subiendo)
                const SizedBox(width: 104, child: Center(child: CircularProgressIndicator())),
              if (fotos.isEmpty && !subiendo)
                const Center(child: Text('Todavía no hay fotos propias de este lugar.')),
            ]),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: subiendo ? null : () => agregarFoto(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Tomar foto'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: subiendo ? null : () => agregarFoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galería'),
              ),
            ),
          ]),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Las fotos se guardan en Firebase Storage. Recuerda tocar “Guardar cambios” al final.',
                style: TextStyle(fontSize: 12)),
          ),
          gap,
          TextFormField(
            controller: foto,
            keyboardType: TextInputType.url,
            decoration: _dec('O enlace de una foto en internet (opcional)', hint: 'https://…'),
            validator: _url,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
                'Si el lugar no tiene fotos propias ni enlace, la app busca una foto en Wikipedia.',
                style: TextStyle(fontSize: 12)),
          ),
          if (foto.text.trim().startsWith('https://')) ...[
            gap,
            ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Foto(url: foto.text.trim(), height: 160)),
          ],
          gap,
          TextFormField(
            controller: video,
            keyboardType: TextInputType.url,
            decoration: _dec('Enlace de video de YouTube (opcional)', hint: 'https://youtu.be/…'),
            validator: _url,
          ),
          gap,
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: lat,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: _dec('Latitud', hint: '9.333'),
                validator: (v) => _coord(v, -5, 14),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: lon,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: _dec('Longitud', hint: '-74.450'),
                validator: (v) => _coord(v, -82, -66),
              ),
            ),
          ]),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('En Google Maps, mantén presionado el punto y copia los dos números.',
                style: TextStyle(fontSize: 12)),
          ),
          gap,
          DropdownButtonFormField<int?>(
            value: mes,
            decoration: _dec('Mes (para eventos)'),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Sin mes')),
              for (var k = 1; k <= 12; k++) DropdownMenuItem<int?>(value: k, child: Text(mesesLargo[k - 1])),
            ],
            onChanged: (v) => setState(() => mes = v),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: (guardando || subiendo) ? null : guardar,
            child: Text(guardando ? 'Guardando…' : (i == null ? 'Publicar lugar' : 'Guardar cambios')),
          ),
          if (i != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: ocultar,
              icon: const Icon(Icons.delete_outline),
              label: Text(confirmar
                  ? 'Toca otra vez para confirmar'
                  : (i!.nuevo ? 'Eliminar lugar' : 'Ocultar de la app')),
            ),
          ],
        ]),
      ),
    );
  }
}
