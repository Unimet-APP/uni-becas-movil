import 'package:flutter/material.dart';
import '../models/becario.dart';
import '../models/plaza.dart';
import '../models/reporte_semanal.dart';
import '../models/periodo_config.dart';
import '../models/reportes_global_response.dart';
import '../services/student_service.dart';

class StudentProvider with ChangeNotifier {
  final StudentService _service = StudentService();

  Becario? _becario;
  Plaza? _plaza;
  List<ReporteSemanal> _reports = [];
  PeriodoConfig? _currentPeriod;
  Map<String, dynamic> _estadisticas = {};
  ReportesGlobalResponse? _reportesGlobales;
  bool _isLoading = false;
  String? _error;

  Becario? get becario => _becario;
  Plaza? get plaza => _plaza;
  List<ReporteSemanal> get reports => _reports;
  PeriodoConfig? get currentPeriod => _currentPeriod;
  Map<String, dynamic> get estadisticas => _estadisticas;
  ReportesGlobalResponse? get reportesGlobales => _reportesGlobales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasPlaza => _becario?.hasPlaza ?? false;
  double get progressPercentage => _becario?.porcentajeCompletado ?? 0;
  int get horasCompletadas => _becario?.horasCompletadas.toInt() ?? 0;
  int get horasRequeridas => _becario?.horasRequeridas ?? 0;

  // Estadísticas de reportes globales
  int get totalReportes {
    // Primero intenta usar reportesGlobales, si no tiene datos, usa la lista de reportes
    if (_reportesGlobales?.total != null && _reportesGlobales!.total > 0) {
      return _reportesGlobales!.total;
    }
    return _reports.length;
  }
  int get reportesPendientes => _reportesGlobales?.estadisticas.pendiente ?? 0;
  int get reportesAprobados => _reportesGlobales?.estadisticas.aprobada ?? 0;
  int get reportesRechazados => _reportesGlobales?.estadisticas.rechazada ?? 0;
  int get reportesEnRevision => _reportesGlobales?.estadisticas.enRevision ?? 0;
  double get horasTotalesAprobadas => _reportesGlobales?.estadisticas.horasTotalesAprobadas ?? 0.0;

  Future<void> loadStudentData(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cargar información del becario (usa token, no necesita userId)
      _becario = await _service.getMyBecario(userId);

      // Cargar plaza asignada directamente con el endpoint de plazas por ayudante
      _plaza = await _service.getMyPlaza(userId);

      // Cargar período académico actual primero (necesario para otros datos)
      _currentPeriod = await _service.getCurrentPeriod();

      // Cargar reportes semanales y estadísticas
      if (userId.isNotEmpty) {
        // Cargar siempre la lista de reportes básicos
        _reports = await _service.getMyReports(userId);

        // Intentar cargar reportes globales (solo funciona si el usuario tiene permisos)
        try {
          _reportesGlobales = await _service.getReportesGlobales(userId);
        } catch (e) {
          print('⚠️ Could not load global reports (may be permission issue): $e');
        }

        // Cargar estadísticas
        _estadisticas = await _service.getEstadisticas(userId);

        // Obtener supervisor desde los reportes si está disponible
        _becario = await _service.enrichBecarioWithSupervisor(_becario, _reports);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading student data: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReport({
    required String userId,
    required int semana,
    required String periodoAcademico,
    required String fecha,
    required double horasTrabajadas,
    String? objetivosPeriodo,
    String? metasEspecificas,
    String? actividadesProgramadas,
    String? actividadesRealizadas,
    String? descripcionActividades,
    String? observaciones,
  }) async {
    try {
      _error = null;

      await _service.createReport(
        semana: semana,
        periodoAcademico: periodoAcademico,
        fecha: fecha,
        horasTrabajadas: horasTrabajadas,
        objetivosPeriodo: objetivosPeriodo,
        metasEspecificas: metasEspecificas,
        actividadesProgramadas: actividadesProgramadas,
        actividadesRealizadas: actividadesRealizadas,
        descripcionActividades: descripcionActividades,
        observaciones: observaciones,
      );

      // Recargar reportes y estadísticas después de enviar
      _reports = await _service.getMyReports(userId);
      if (userId.isNotEmpty) {
        // Intentar cargar estadísticas globales si está disponible
        try {
          _reportesGlobales = await _service.getReportesGlobales(userId);
        } catch (e) {
          print('⚠️ Could not load global reports: $e');
        }
        _estadisticas = await _service.getEstadisticas(userId);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh(String userId) async {
    await loadStudentData(userId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
