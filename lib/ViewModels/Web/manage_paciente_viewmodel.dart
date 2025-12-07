import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:dose_certa/Models/Models/consulta.dart';
import 'package:dose_certa/Models/Models/medicamento.dart';
import 'package:dose_certa/Models/Repositories/consulta_repository_imp.dart';
import 'package:dose_certa/Models/Repositories/medicamento_repository_imp.dart';

class ManagePacienteViewmodel extends ChangeNotifier {
  final MedicamentoRepositoryImp _medicamentoRepository;
  final ConsultaRepositoryImp _consultaRepository;

  ManagePacienteViewmodel({
    MedicamentoRepositoryImp? medicamentoRepository,
    ConsultaRepositoryImp? consultaRepository,
  }) : _medicamentoRepository =
           medicamentoRepository ?? MedicamentoRepositoryImp(),
       _consultaRepository = consultaRepository ?? ConsultaRepositoryImp();

  List<Medicamento> _medicamentos = [];
  List<Consulta> _consultas = [];
  bool _isLoading = false;
  StreamSubscription<List<Medicamento>>? _medicamentoSubscription;
  StreamSubscription<List<Consulta>>? _consultaSubscription;

  List<Medicamento> get medicamentos => _medicamentos;
  List<Consulta> get consultas => _consultas;
  bool get isLoading => _isLoading;

  // ========== MEDICAMENTOS ==========

  Future<void> addMedicamento(
    Medicamento medicamento,
    String pacienteId,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _medicamentoRepository.addMedicamento(
        medicamento,
        userId: pacienteId,
      );
      notifyListeners();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isOfflineError =
          msg.contains('timeout') ||
          msg.contains('timed out') ||
          msg.contains('socketexception');

      if (!isOfflineError) {
        throw Exception('Erro ao adicionar medicamento: $e');
      }
      if (kDebugMode) print('Operação offline: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editMedicamento(
    Medicamento medicamento,
    String pacienteId,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _medicamentoRepository.editMedicamento(
        medicamento,
        userId: pacienteId,
      );
      notifyListeners();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isOfflineError =
          msg.contains('timeout') ||
          msg.contains('timed out') ||
          msg.contains('socketexception');

      if (!isOfflineError) {
        throw Exception('Erro ao editar medicamento: $e');
      }
      if (kDebugMode) print('Operação offline: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMedicamento(String id, String pacienteId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _medicamentoRepository.deleteMedicamento(id, userId: pacienteId);
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao deletar medicamento: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadMedicamentos(String pacienteId) {
    _medicamentoSubscription?.cancel();
    _medicamentoSubscription = _medicamentoRepository
        .getMedicamentos(userId: pacienteId)
        .listen(
          (List<Medicamento> newRecords) {
            _medicamentos = newRecords;
            notifyListeners();
          },
          onError: (error) {
            if (kDebugMode) print('Erro ao carregar medicamentos: $error');
          },
        );
  }

  // ========== CONSULTAS ==========

  Future<void> addConsulta(Consulta consulta, String pacienteId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _consultaRepository.addConsulta(consulta, userId: pacienteId);
      notifyListeners();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isOfflineError =
          msg.contains('timeout') ||
          msg.contains('timed out') ||
          msg.contains('socketexception');

      if (!isOfflineError) {
        throw Exception('Erro ao adicionar consulta: $e');
      }
      if (kDebugMode) print('Operação offline: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editConsulta(Consulta consulta, String pacienteId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _consultaRepository.editConsulta(consulta, userId: pacienteId);
      notifyListeners();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isOfflineError =
          msg.contains('timeout') ||
          msg.contains('timed out') ||
          msg.contains('socketexception');

      if (!isOfflineError) {
        throw Exception('Erro ao editar consulta: $e');
      }
      if (kDebugMode) print('Operação offline: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteConsulta(String id, String pacienteId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _consultaRepository.deleteConsulta(id, userId: pacienteId);
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao deletar consulta: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadConsultas(String pacienteId) {
    _consultaSubscription?.cancel();
    _consultaSubscription = _consultaRepository
        .getConsultas(userId: pacienteId)
        .listen(
          (List<Consulta> newRecords) {
            _consultas = newRecords;
            notifyListeners();
          },
          onError: (error) {
            if (kDebugMode) print('Erro ao carregar consultas: $error');
          },
        );
  }

  @override
  void dispose() {
    _medicamentoSubscription?.cancel();
    _consultaSubscription?.cancel();
    super.dispose();
  }
}
