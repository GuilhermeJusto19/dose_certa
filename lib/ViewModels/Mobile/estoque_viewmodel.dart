import 'dart:async';

import 'package:dose_certa/Models/Models/estoque.dart';
import 'package:dose_certa/Models/Repositories/estoque_repository_imp.dart';
import 'package:flutter/foundation.dart';

class EstoqueViewModel extends ChangeNotifier {
  final EstoqueRepositoryImp _repository;

  EstoqueViewModel({EstoqueRepositoryImp? repository})
    : _repository = repository ?? EstoqueRepositoryImp();

  List<Estoque> _estoques = [];
  bool _isLoading = false;
  StreamSubscription<List<Estoque>>? _estoquesSubscription;

  List<Estoque> get estoques => _estoques;
  bool get isLoading => _isLoading;

  Future<void> addEstoque(Estoque estoque, {String? userId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.addEstoque(estoque, userId: userId);
      _estoques.add(estoque);

      notifyListeners();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isOfflineError =
          msg.contains('timeout') ||
          msg.contains('timed out') ||
          msg.contains('socketexception');

      if (!isOfflineError) {
        throw ('Erro ao adicionar estoque: $e');
      }
      if (kDebugMode) print('Operação offline: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editEstoque(Estoque estoque, {String? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _estoques.indexWhere((e) => e.id == estoque.id);
      if (index != -1) {
        _estoques[index] = estoque;
      }

      await _repository.editEstoque(estoque, userId: userId);

      notifyListeners();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isOfflineError =
          msg.contains('timeout') ||
          msg.contains('timed out') ||
          msg.contains('socketexception');

      if (!isOfflineError) {
        throw ('Erro ao editar estoque: $e');
      }
      if (kDebugMode) print('Operação offline: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEstoque(String id, {String? userId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteEstoque(id, userId: userId);

      _estoques.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      throw ('Erro ao deletar estoque: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadEstoques({String? userId}) {
    _estoquesSubscription?.cancel();
    _estoquesSubscription = _repository
        .getEstoque(userId: userId)
        .listen(
          (List<Estoque> newRecord) {
            _estoques = newRecord;
            notifyListeners();
          },
          onError: (error) {
            if (kDebugMode) print('Erro ao carregar estoques: $error');
          },
        );
  }

  @override
  void dispose() {
    _estoquesSubscription?.cancel();
    super.dispose();
  }
}
