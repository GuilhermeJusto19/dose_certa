import 'package:dose_certa/Models/Models/estoque.dart';

abstract class EstoqueRepository {
  Future<void> addEstoque(Estoque estoque, {String? userId});

  Future<void> editEstoque(Estoque estoque, {String? userId});

  Future<void> deleteEstoque(String id, {String? userId});

  Stream<List<Estoque>> getEstoque({String? userId});
}
