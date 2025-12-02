import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/plaza.dart';
import '../models/becario.dart';
import '../models/becario_compatible.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _service = AdminService();

  List<User> _users = [];
  List<User> _pendingUsers = [];
  List<Plaza> _plazas = [];
  List<Becario> _becarios = [];
  BecariosCompatiblesResponse? _becariosCompatibles;
  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  List<User> get pendingUsers => _pendingUsers;
  List<Plaza> get plazas => _plazas;
  List<Becario> get becarios => _becarios;
  BecariosCompatiblesResponse? get becariosCompatibles => _becariosCompatibles;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get pendingUsersCount => _pendingUsers.length;

  Future<void> loadUsers({String? role, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _service.getUsers(role: role, search: search);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingUsers = await _service.getPendingUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveUser(String userId) async {
    try {
      await _service.approveUser(userId);
      await loadPendingUsers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadPlazas({String? departamento, String? estado}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _plazas = await _service.getPlazas(
        departamento: departamento,
        estado: estado,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBecarios({String? estado, String? programaBeca}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _becarios = await _service.getBecarios(
        estado: estado,
        programaBeca: programaBeca,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _statistics = await _service.getStatistics();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> assignBecarioToPlaza(String becarioId, String plazaId) async {
    try {
      await _service.assignBecarioToPlaza(becarioId, plazaId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadBecariosCompatibles(String plazaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _becariosCompatibles = await _service.getBecariosCompatibles(plazaId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
