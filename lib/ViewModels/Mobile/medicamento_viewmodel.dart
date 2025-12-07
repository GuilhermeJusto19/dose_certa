import 'dart:async';

import 'package:dose_certa/viewmodels/mobile/tarefa_viewmodel.dart';
import 'package:dose_certa/Models/Models/medicamento.dart';
import 'package:dose_certa/Models/Repositories/medicamento_repository_imp.dart';
import 'package:flutter/foundation.dart';

class MedicamentoViewModel extends ChangeNotifier {
  final MedicamentoRepositoryImp _repository;

  final TarefaViewModel _tarefaController = TarefaViewModel();

  MedicamentoViewModel({MedicamentoRepositoryImp? repository})
    : _repository = repository ?? MedicamentoRepositoryImp();

  List<Medicamento> _medicamentos = [];
  bool _isLoading = false;
  StreamSubscription<List<Medicamento>>? _medicamentosSubscription;

  List<Medicamento> get medicamentos => _medicamentos;
  bool get isLoading => _isLoading;

  Future<void> addMedicamento(Medicamento medicamento, {String? userId}) async {
    try {
      //* Salvar o medicamento no Firestore
      await _repository.addMedicamento(medicamento, userId: userId);
      _medicamentos.add(medicamento);

      //* Criar e salvar a tarefa e lembrete associada
      await _tarefaController.addTarefa(
        medicamento: medicamento,
        userId: userId,
      );

      _isLoading = true;
      notifyListeners();
    } catch (e) {
      throw ('Erro ao adicionar medicamento: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editMedicamento(
    Medicamento medicamento, {
    String? userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _medicamentos.indexWhere((c) => c.id == medicamento.id);
      if (index != -1) {
        _medicamentos[index] = medicamento;
      }

      await _repository.editMedicamento(medicamento, userId: userId);

      //* Atualizar a tarefa e lembretes associados
      await _tarefaController.deleteTarefa(medicamento.id, userId: userId);
      await _tarefaController.addTarefa(
        medicamento: medicamento,
        userId: userId,
      );

      notifyListeners();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isOfflineError =
          msg.contains('timeout') ||
          msg.contains('timed out') ||
          msg.contains('socketexception');

      if (!isOfflineError) {
        throw ('Erro ao editar medicamento: $e');
      }
      if (kDebugMode) print('Operação offline: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMedicamento(String id, {String? userId}) async {
    try {
      _isLoading = true;

      await _repository.deleteMedicamento(id, userId: userId);

      //* Deletar tarefa associada
      await _tarefaController.deleteTarefa(id, userId: userId);

      _medicamentos.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      throw ('Erro ao deletar medicamento: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadMedicamentos({String? userId}) {
    _medicamentosSubscription?.cancel();
    _medicamentosSubscription = _repository
        .getMedicamentos(userId: userId)
        .listen(
          (List<Medicamento> newRecord) {
            _medicamentos = newRecord;
            notifyListeners();
          },
          onError: (error) {
            if (kDebugMode) print('Erro ao carregar medicamentos: $error');
          },
        );
  }
}
