import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

/// Estado de la app: sesión, favoritos, ruta, perfil y permisos de administrador.
/// Sin sesión, todo se guarda en el teléfono. Con sesión, se sincroniza con Firebase.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState i = AppState._();

  SharedPreferences? _p;
  List<String> favs = [];
  List<String> ruta = [];
  Map<String, dynamic> perfil = {};

  bool firebaseListo = false;
  User? usuario;
  bool esAdmin = false;

  /// Pestaña activa de la barra inferior.
  final ValueNotifier<int> tab = ValueNotifier<int>(0);

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _lugaresSub;
  Timer? _guardarTimer;

  FirebaseFirestore get db => FirebaseFirestore.instance;

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

  /// Se llama cuando Firebase quedó inicializado.
  void conectarFirebase() {
    firebaseListo = true;
    _lugaresSub = db.collection('lugares').snapshots().listen((snap) {
      Catalogo.remoto = {for (final d in snap.docs) d.id: d.data()};
      Catalogo.reconstruir();
    }, onError: (_) {});
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_alCambiarSesion);
    notifyListeners();
  }

  Future<void> _alCambiarSesion(User? u) async {
    usuario = u;
    esAdmin = false;
    notifyListeners();
    if (u == null) return;
    try {
      final a = await db.collection('admins').doc(u.uid).get();
      esAdmin = a.exists;
    } catch (_) {
      esAdmin = false;
    }
    try {
      final doc = await db.collection('usuarios').doc(u.uid).get();
      final d = doc.data() ?? {};
      List<String> lista(dynamic v) => v is List ? v.map((e) => e.toString()).toList() : <String>[];
      // Une lo guardado en el teléfono con lo guardado en la cuenta.
      final f = lista(d['favs']);
      final r = lista(d['ruta']);
      favs = [...f, ...favs.where((x) => !f.contains(x))];
      ruta = [...r, ...ruta.where((x) => !r.contains(x))];
      if (d['perfil'] is Map) {
        perfil = {...perfil, ...Map<String, dynamic>.from(d['perfil'] as Map)};
      }
      _guardarLocal();
      _guardarNube();
    } catch (_) {}
    notifyListeners();
  }

  void _guardarLocal() {
    _p?.setStringList('favs', favs);
    _p?.setStringList('ruta', ruta);
    _p?.setString('perfil', jsonEncode(perfil));
  }

  void _guardarNube() {
    final u = usuario;
    if (u == null) return;
    _guardarTimer?.cancel();
    _guardarTimer = Timer(const Duration(milliseconds: 600), () {
      db.collection('usuarios').doc(u.uid).set({
        'favs': favs,
        'ruta': ruta,
        'perfil': perfil,
        'actualizado': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).catchError((_) {});
    });
  }

  void _cambio() {
    _guardarLocal();
    _guardarNube();
    notifyListeners();
  }

  bool esFav(String id) => favs.contains(id);
  bool enRuta(String id) => ruta.contains(id);

  void toggleFav(String id) {
    esFav(id) ? favs.remove(id) : favs.add(id);
    _cambio();
  }

  void toggleRuta(String id) {
    enRuta(id) ? ruta.remove(id) : ruta.add(id);
    _cambio();
  }

  void mover(int desde, int delta) {
    final hasta = desde + delta;
    if (hasta < 0 || hasta >= ruta.length) return;
    final x = ruta.removeAt(desde);
    ruta.insert(hasta, x);
    _cambio();
  }

  void guardarPerfil(Map<String, dynamic> p) {
    perfil = p;
    _cambio();
  }

  String get nombre => (perfil['nombre'] ?? '').toString();

  // ---------------- cuenta
  Future<String?> entrar(String correo, String clave) async {
    if (!firebaseListo) return 'No hay conexión con el servidor. Revisa tu internet.';
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: correo, password: clave);
      return null;
    } on FirebaseAuthException catch (e) {
      return _msg(e.code);
    } catch (_) {
      return 'No se pudo iniciar sesión. Inténtalo de nuevo.';
    }
  }

  Future<String?> registrar(String correo, String clave, String nombre) async {
    if (!firebaseListo) return 'No hay conexión con el servidor. Revisa tu internet.';
    try {
      final c = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: correo, password: clave);
      await c.user?.updateDisplayName(nombre);
      perfil = {...perfil, 'nombre': nombre, 'correo': correo};
      _cambio();
      return null;
    } on FirebaseAuthException catch (e) {
      return _msg(e.code);
    } catch (_) {
      return 'No se pudo crear la cuenta. Inténtalo de nuevo.';
    }
  }

  Future<String?> recuperar(String correo) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);
      return null;
    } on FirebaseAuthException catch (e) {
      return _msg(e.code);
    }
  }

  Future<void> salir() async {
    await FirebaseAuth.instance.signOut();
  }

  String _msg(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo. Inicia sesión.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos.';
      case 'operation-not-allowed':
        return 'El inicio con correo no está activado en Firebase (Authentication → Método de acceso).';
      default:
        return 'Ocurrió un error ($code).';
    }
  }

  // ---------------- panel de administración
  Future<String?> guardarLugar(String? id, Map<String, dynamic> datos) async {
    if (!esAdmin) return 'Tu cuenta no tiene permiso de administrador.';
    final ref = id == null
        ? db.collection('lugares').doc()
        : db.collection('lugares').doc(id);
    try {
      await ref.set({
        ...datos,
        'autor': usuario?.uid,
        'actualizado': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseException catch (e) {
      return e.code == 'permission-denied'
          ? 'Firebase rechazó el cambio: tu cuenta no está en la lista de administradores.'
          : 'No se pudo guardar (${e.code}).';
    }
  }

  Future<String?> ocultarLugar(Item i) async {
    if (!esAdmin) return 'Tu cuenta no tiene permiso de administrador.';
    try {
      final ref = db.collection('lugares').doc(i.id);
      if (i.nuevo) {
        await ref.delete();
      } else {
        await ref.set({'oculto': true, 'autor': usuario?.uid, 'actualizado': FieldValue.serverTimestamp()});
      }
      favs.remove(i.id);
      ruta.remove(i.id);
      _cambio();
      return null;
    } on FirebaseException catch (e) {
      return 'No se pudo completar (${e.code}).';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _lugaresSub?.cancel();
    _guardarTimer?.cancel();
    super.dispose();
  }
}
