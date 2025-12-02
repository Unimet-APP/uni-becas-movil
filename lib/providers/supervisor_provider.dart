import 'package:flutter/material.dart';
import '../models/becario.dart';
import '../models/reporte_semanal.dart';
import '../models/reportes_global_response.dart';
import '../models/plaza.dart';
import '../services/supervisor_service.dart';

class SupervisorProvider with ChangeNotifier {
  final SupervisorService _service = SupervisorService();

  List<Becario> _assistants = [];
  List<ReporteSemanal> _pendingReports = [];
  ReportesGlobalResponse? _reportesGlobales;
  Map<String, dynamic>? _supervisorInfo;
  Plaza? _plazaAsignada;
  int _totalAyudantes = 0;
  bool _isLoading = false;
  String? _error;

  List<Becario> get assistants => _assistants;
  List<ReporteSemanal> get pendingReports => _pendingReports;
  ReportesGlobalResponse? get reportesGlobales => _reportesGlobales;
  Map<String, dynamic>? get supervisorInfo => _supervisorInfo;
  Plaza? get plazaAsignada => _plazaAsignada;
  int get totalAyudantes => _totalAyudantes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Estadísticas de reportes
  int get totalReportes => _reportesGlobales?.total ?? 0;
  int get pendingReportsCount => _reportesGlobales?.estadisticas.pendiente ?? 0;
  int get reportesAprobados => _reportesGlobales?.estadisticas.aprobada ?? 0;
  int get reportesRechazados => _reportesGlobales?.estadisticas.rechazada ?? 0;
  double get horasTotalesAprobadas => _reportesGlobales?.estadisticas.horasTotalesAprobadas ?? 0.0;

  int get assistantsWithoutPlaza =>
      _assistants.where((a) => !a.hasPlaza).length;

  Future<void> loadAssistants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _assistants = await _service.getMyAssistants();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingReports = await _service.getPendingReports();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ReporteSemanal>> getReportsForAssistant(
      String becarioId) async {
    try {
      return await _service.getReportsForAssistant(becarioId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<bool> approveReport(
    String becarioId,
    String reporteId, {
    String? observaciones,
  }) async {
    try {
      await _service.approveReport(becarioId, reporteId,
          observaciones: observaciones);
      await loadPendingReports();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectReport(
    String becarioId,
    String reporteId,
    String motivo,
  ) async {
    try {
      await _service.rejectReport(becarioId, reporteId, motivo);
      await loadPendingReports();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cargar datos usando el nuevo endpoint /v1/supervisores/{id}/ayudantes
  Future<void> loadSupervisorData(String supervisorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cargar ayudantes
      final ayudantesData = await _service.getAyudantesBySupervisorId(supervisorId);
      _supervisorInfo = ayudantesData['supervisor'];
      _assistants = ayudantesData['ayudantes'];
      _totalAyudantes = ayudantesData['total'];

      // Cargar plaza asignada al supervisor (si existe)
      // Buscar en los ayudantes la primera plaza asignada
      String? plazaId;
      for (var assistant in _assistants) {
        if (assistant.plazaAsignada != null && assistant.plazaAsignada!.isNotEmpty) {
          plazaId = assistant.plazaAsignada;
          break;
        }
      }

      if (plazaId != null && plazaId.isNotEmpty) {
        _plazaAsignada = await _service.getPlazaById(plazaId);
      }

      // Cargar reportes globales filtrados por supervisor
      _reportesGlobales = await _service.getReportesBySupervisorId(
        supervisorId,
        limit: 100,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading supervisor data: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await Future.wait([
      loadAssistants(),
      loadPendingReports(),
    ]);
  }

  Future<void> refreshWithId(String supervisorId) async {
    await loadSupervisorData(supervisorId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
