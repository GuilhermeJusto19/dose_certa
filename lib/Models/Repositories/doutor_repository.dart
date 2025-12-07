import 'package:dose_certa/Models/Models/doutor.dart';

abstract class DoutorRepository {
  Future<void> addDoutor(Doutor doutor);

  Future<void> editDoutor(Doutor doutor);

  Future<void> deleteDoutor(String id);

  Stream<List<Doutor>> getDoutors({String? userId});
}
