import 'dart:async';

import 'package:dose_certa/viewmodels/mobile/tarefa_viewmodel.dart';
import 'package:dose_certa/Models/Models/consulta.dart';
import 'package:dose_certa/Models/Repositories/consulta_repository_imp.dart';
import 'package:flutter/foundation.dart';

class ConsultaViewModel extends ChangeNotifier {
  final ConsultaRepositoryImp _repository;

  final TarefaViewModel _tarefaController = TarefaViewModel();

  ConsultaViewModel({ConsultaRepositoryImp? repository})
    : _repository = repository ?? ConsultaRepositoryImp();

  List<Consulta> _consultas = [];
  bool _isLoading = false;
  StreamSubscription<List<Consulta>>? _consultasSubscription;

  List<Consulta> get consultas => _consultas;
  bool get isLoading => _isLoading;

  Future<void> addConsulta(Consulta consulta, {String? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      //* Salvar a consulta no Firestore
      await _repository.addConsulta(consulta, userId: userId);
      _consultas.add(consulta);

      //* Criar e salvar a tarefa e lembrete associada (passando userId quando aplicável)
      await _tarefaController.addTarefa(consulta: consulta, userId: userId);

      notifyListeners();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isOfflineError =
          msg.contains('timeout') ||
          msg.contains('timed out') ||
          msg.contains('socketexception');

      // Não lançar erro em casos de timeout/sem internet (vai para o cache como esperado)
      if (!isOfflineError) {
        throw ('Erro ao adicionar consulta: $e');
      }
      // opcional: apenas log em debug
      if (kDebugMode) print('Operação offline: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editConsulta(Consulta consulta, {String? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _consultas.indexWhere((c) => c.id == consulta.id);
      if (index != -1) {
        _consultas[index] = consulta;
      }

      await _repository.editConsulta(consulta, userId: userId);

      //* Atualizar a tarefa e lembretes associados (passando userId para atuar no paciente quando aplicável)
      await _tarefaController.deleteTarefa(consulta.id, userId: userId);
      await _tarefaController.addTarefa(consulta: consulta, userId: userId);

      notifyListeners();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isOfflineError =
          msg.contains('timeout') ||
          msg.contains('timed out') ||
          msg.contains('socketexception');

      if (!isOfflineError) {
        throw ('Erro ao editar consulta: $e');
      }
      if (kDebugMode) print('Operação offline: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteConsulta(String id, {String? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteConsulta(id, userId: userId);

      //* Deletar tarefa associada (passando userId quando aplicável)
      await _tarefaController.deleteTarefa(id, userId: userId);

      _consultas.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      throw ('Erro ao deletar consulta: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadConsultas({String? userId}) {
    _consultasSubscription?.cancel();
    _consultasSubscription = _repository
        .getConsultas(userId: userId)
        .listen(
          (List<Consulta> newRecord) {
            _consultas = newRecord;
            notifyListeners();
          },
          onError: (error) {
            if (kDebugMode) print('Erro ao carregar consultas: $error');
          },
        );
  }
}
