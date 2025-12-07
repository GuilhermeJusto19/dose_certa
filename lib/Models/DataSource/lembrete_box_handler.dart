// ignore: dangling_library_doc_comments
/// Handler singleton
///
/// - Esta classe encapsula as operações de leitura/escrita no box `lembretesBox`.
/// - Mantive a lógica original intacta; apenas melhorei organização, nomes
///   internos e adicionei documentação.
///
/// Observação importante sobre um possível comportamento ambiguo (não alterado):
/// - O método `getTodayTriggeredLembretes` compara hora e minuto separadamente
///   usando `<=` em ambos; isso pode levar a resultados inesperados quando a
///   comparação de tempos atravessa horas (por exemplo, 10:59 vs 11:00).
///   Não corrigi esse comportamento para preservar a lógica existente, apenas
///   documentei a possível fonte de confusão.
import 'package:dose_certa/Models/Models/lembrete.dart';
import 'package:hive_ce/hive.dart';

/// Singleton responsável por abrir/fechar o box e fornecer utilitários de acesso
/// aos lembretes armazenados localmente.
class LembreteBoxHandler {
  LembreteBoxHandler._internal();

  static final LembreteBoxHandler _instance = LembreteBoxHandler._internal();
  factory LembreteBoxHandler() => _instance;

  late final Box<Lembrete> _box;

  /// Inicializa o handler abrindo o box `lembretesBox`.
  /// Deve ser chamado antes de qualquer operação que acesse `_box`.
  Future<void> init() async {
    _box = await Hive.openBox<Lembrete>('lembretesBox');
  }

  /// Insere ou atualiza um lembrete usando `lembrete.id` como chave.
  Future<void> addLembrete(Lembrete lembrete) async {
    await _box.put(lembrete.id, lembrete);
  }

  /// Remove todas as entradas que pertençam à mesma recorrência (mesmo `taskId`).
  Future<void> deleteLembreteRecurrence(String taskId) async {
    final List<Lembrete> recorrencias = getLembreteRecurrence(taskId);
    for (final lembrete in recorrencias) {
      await _box.delete(lembrete.id);
    }
  }

  /// Retorna a lista de lembretes que têm `taskId` igual ao informado.
  List<Lembrete> getLembreteRecurrence(String taskId) {
    return _box.values.where((lembrete) => lembrete.taskId == taskId).toList();
  }

  /// Ordena os itens por `dateTime` de criação em ordem decrescente (mais
  /// recentes primeiro). Método privado auxiliar.
  List<Lembrete> _sortByCreationDesc(Iterable<Lembrete> items) {
    final List<Lembrete> list = items.toList();
    try {
      list.sort((a, b) {
        final DateTime? aDate = a.dateTime as DateTime?;
        final DateTime? bDate = b.dateTime as DateTime?;
        if (aDate == null || bDate == null) throw Exception();
        // b.compareTo(a) para ordem decrescente (mais recentes primeiro)
        return bDate.compareTo(aDate);
      });
      return list;
    } catch (_) {
      // Se ocorrer erro na ordenação, retorna a lista invertida como fallback.
      return list.reversed.toList();
    }
  }

  /// Retorna os lembretes do dia atual, ordenados por criação (descendente).
  List<Lembrete> getTodayLembretes() {
    final DateTime now = DateTime.now();
    final Iterable<Lembrete> results = _box.values.where(
      (lembrete) =>
          lembrete.dateTime.year == now.year &&
          lembrete.dateTime.month == now.month &&
          lembrete.dateTime.day == now.day,
    );
    return _sortByCreationDesc(results);
  }

  /// Retorna lembretes do dia informado que já devem ter sido acionados até
  /// a hora/minuto informados. (Lógica preservada da versão anterior.)
  List<Lembrete> getTodayTriggeredLembretes(DateTime dateTime) {
    final Iterable<Lembrete> results = _box.values.where(
      (lembrete) =>
          lembrete.dateTime.year == dateTime.year &&
          lembrete.dateTime.month == dateTime.month &&
          lembrete.dateTime.day == dateTime.day &&
          lembrete.dateTime.hour <= dateTime.hour &&
          lembrete.dateTime.minute <= dateTime.minute,
    );
    return _sortByCreationDesc(results);
  }

  /// Retorna todos os lembretes ordenados por criação (descendente).
  List<Lembrete> getAllLembretes() => _sortByCreationDesc(_box.values);

  /// Fecha o box e libera recursos.
  Future<void> closeBox() async {
    await _box.close();
  }
}
