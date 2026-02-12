import 'package:flutter/foundation.dart';
import '../models/orientacion_vocacional.dart';
import '../services/orientacion_vocacional_service.dart';

class AspiranteProvider extends ChangeNotifier {
  final OrientacionVocacionalService _service = OrientacionVocacionalService();

  // Estado general
  final bool _isLoading = false;
  String? _error;

  // Historial y perfil
  List<HistorialItem> _historial = [];
  List<HistorialItem> _sesionesEnProgreso = [];
  Map<String, dynamic>? _perfilVocacionalData;
  bool _cargandoPerfil = false;

  // Trayectoria académica
  TrayectoriaBody _trayectoria = TrayectoriaBody();
  bool _cargandoTrayectoria = false;
  bool _guardandoTrayectoria = false;

  // Notificaciones
  List<Notificacion> _notificaciones = [];
  List<Cita> _citasProximas = [];
  bool _cargandoNotificaciones = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<HistorialItem> get historial => _historial;
  List<HistorialItem> get sesionesEnProgreso => _sesionesEnProgreso;
  Map<String, dynamic>? get perfilVocacionalData => _perfilVocacionalData;
  bool get cargandoPerfil => _cargandoPerfil;

  TrayectoriaBody get trayectoria => _trayectoria;
  bool get cargandoTrayectoria => _cargandoTrayectoria;
  bool get guardandoTrayectoria => _guardandoTrayectoria;

  List<Notificacion> get notificaciones => _notificaciones;
  List<Cita> get citasProximas => _citasProximas;
  bool get cargandoNotificaciones => _cargandoNotificaciones;

  int get testsCompletados =>
      _historial.where((s) => s.isCompleted).length;

  int get notificacionesNoLeidas =>
      _notificaciones.where((n) => !n.leida).length;

  int get totalRecomendaciones {
    final resultado = _perfilVocacionalData?['resultadoActual']?['resultado'];
    if (resultado == null) return 0;
    final recs = resultado['recomendacionesCarreras'] ??
        resultado['recomendaciones_carreras'];
    return recs is List ? recs.length : 0;
  }

  String? get perfilDominante {
    final ra = _perfilVocacionalData?['resultadoActual'];
    if (ra == null) return null;
    final resultado = ra['resultado'];
    if (resultado is Map) {
      return resultado['perfilDominante']?.toString() ??
          resultado['perfil_dominante']?.toString();
    }
    return ra['perfilDominante']?.toString() ??
        ra['perfil_dominante']?.toString();
  }

  String? get codigoHolland {
    final ra = _perfilVocacionalData?['resultadoActual'];
    if (ra == null) return null;
    final resultado = ra['resultado'];
    if (resultado is Map) {
      return resultado['codigoHolland']?.toString() ??
          resultado['codigo_holland']?.toString();
    }
    return ra['codigoHolland']?.toString() ??
        ra['codigo_holland']?.toString();
  }

  // ==================== CARGAR DATOS ====================

  /// Cargar historial y perfil vocacional
  Future<void> cargarPerfilYHistorial() async {
    _cargandoPerfil = true;
    _error = null;
    notifyListeners();

    try {
      final historialFuture = _service.obtenerHistorial();
      final perfilFuture = _service.obtenerPerfilVocacional();

      final historialData = await historialFuture;
      _historial = historialData['historial'] ?? [];
      _sesionesEnProgreso = historialData['sesionesEnProgreso'] ?? [];

      _perfilVocacionalData = await perfilFuture;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error cargando perfil/historial: $e');
    } finally {
      _cargandoPerfil = false;
      notifyListeners();
    }
  }

  /// Cargar trayectoria académica
  Future<void> cargarTrayectoria() async {
    _cargandoTrayectoria = true;
    notifyListeners();

    try {
      _trayectoria = await _service.obtenerTrayectoria();
    } catch (e) {
      debugPrint('Error cargando trayectoria: $e');
    } finally {
      _cargandoTrayectoria = false;
      notifyListeners();
    }
  }

  /// Guardar trayectoria académica
  Future<bool> guardarTrayectoria() async {
    _guardandoTrayectoria = true;
    notifyListeners();

    try {
      await _service.actualizarTrayectoria(_trayectoria);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _guardandoTrayectoria = false;
      notifyListeners();
    }
  }

  /// Cargar notificaciones y citas
  Future<void> cargarNotificaciones(String userId) async {
    _cargandoNotificaciones = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.obtenerNotificaciones(),
        _service.obtenerCitas(userId),
      ]);

      _notificaciones = results[0] as List<Notificacion>;

      final todasCitas = results[1] as List<Cita>;
      final hoy = DateTime.now();
      final hoyStr =
          '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
      _citasProximas = todasCitas
          .where((c) =>
              (c.estado == 'pendiente' || c.estado == 'confirmada') &&
              c.fecha.compareTo(hoyStr) >= 0)
          .toList()
        ..sort((a, b) {
          final cmp = a.fecha.compareTo(b.fecha);
          return cmp != 0 ? cmp : a.hora.compareTo(b.hora);
        });
    } catch (e) {
      debugPrint('Error cargando notificaciones: $e');
    } finally {
      _cargandoNotificaciones = false;
      notifyListeners();
    }
  }

  // ==================== ACCIONES ====================

  /// Marcar notificación como leída
  Future<void> marcarNotificacionLeida(String notificacionId) async {
    try {
      await _service.marcarNotificacionLeida(notificacionId);
      _notificaciones = _notificaciones
          .map((n) => n.id == notificacionId ? n.copyWith(leida: true) : n)
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marcando notificacion: $e');
    }
  }

  /// Marcar todas como leídas
  Future<void> marcarTodasLeidas() async {
    try {
      await _service.marcarTodasLeidas();
      _notificaciones =
          _notificaciones.map((n) => n.copyWith(leida: true)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marcando todas leidas: $e');
    }
  }

  /// Confirmar cita
  Future<bool> confirmarCita(String citaId) async {
    try {
      await _service.confirmarCita(citaId);
      _citasProximas = _citasProximas.map((c) {
        if (c.id == citaId) {
          return Cita.fromJson({
            ...{
              'id': c.id,
              'fecha': c.fecha,
              'hora': c.hora,
              'motivo': c.motivo,
              'modalidad': c.modalidad,
              'especialista': c.especialista,
            },
            'estado': 'confirmada',
          });
        }
        return c;
      }).toList();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error confirmando cita: $e');
      return false;
    }
  }

  /// Cancelar cita
  Future<bool> cancelarCita(String citaId) async {
    try {
      await _service.cancelarCita(citaId);
      _citasProximas = _citasProximas.where((c) => c.id != citaId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error cancelando cita: $e');
      return false;
    }
  }

  // ==================== MUTADORES TRAYECTORIA ====================

  void updateTrayectoria(TrayectoriaBody newTrayectoria) {
    _trayectoria = newTrayectoria;
    notifyListeners();
  }

  void setGradoActual(String? grado) {
    _trayectoria.gradoActual = grado;
    notifyListeners();
  }

  void addMateriaDestacada(String materia, String nota) {
    _trayectoria.materiasDestacadas ??= [];
    _trayectoria.materiasDestacadas!.add('$materia: $nota');
    notifyListeners();
  }

  void removeMateriaDestacada(int index) {
    _trayectoria.materiasDestacadas?.removeAt(index);
    notifyListeners();
  }

  void addActividad(String actividad) {
    _trayectoria.actividadesExtracurriculares ??= [];
    _trayectoria.actividadesExtracurriculares!.add(actividad);
    notifyListeners();
  }

  void removeActividad(int index) {
    _trayectoria.actividadesExtracurriculares?.removeAt(index);
    notifyListeners();
  }

  void addProyecto(String proyecto) {
    _trayectoria.proyectosRealizados ??= [];
    _trayectoria.proyectosRealizados!.add(proyecto);
    notifyListeners();
  }

  void removeProyecto(int index) {
    _trayectoria.proyectosRealizados?.removeAt(index);
    notifyListeners();
  }

  void addMateriaLapso(String ano, String lapso, String materia, double nota) {
    _trayectoria.materiasPorAnoLapso ??= {};
    _trayectoria.materiasPorAnoLapso![ano] ??= {};
    _trayectoria.materiasPorAnoLapso![ano]![lapso] ??= [];
    _trayectoria.materiasPorAnoLapso![ano]![lapso]!
        .add(MateriaNota(materia: materia, nota: nota));
    notifyListeners();
  }

  void removeMateriaLapso(String ano, String lapso, int index) {
    _trayectoria.materiasPorAnoLapso?[ano]?[lapso]?.removeAt(index);
    notifyListeners();
  }
}
