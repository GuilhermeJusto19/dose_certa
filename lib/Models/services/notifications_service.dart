import 'dart:convert';

import 'package:dose_certa/Views/Mobile/app.dart';
import 'package:dose_certa/Models/Models/lembrete.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  /// Plugin de notificações usado para agendar/cancelar notificações locais.
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa o plugin de notificações e configura o callback que navega
  /// para a rota presente no payload quando o usuário interage com a
  /// notificação.
  ///
  /// Observação: O método preserva o comportamento existente e chama
  /// `tzdata.initializeTimeZones()` para garantir dados de timezone.
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final payloadData = jsonDecode(details.payload!);
          final route = payloadData['route'] as String?;
          if (route != null) {
            navigatorKey.currentState?.pushNamed(route);
          }
        }
      },
    );

    tzdata.initializeTimeZones();
  }

  /// Agenda um lembrete usando [lembrete]. Mantive a lógica original; o
  /// método converte a data para o timezone local e chama o plugin para
  /// agendar a notificação.
  Future<void> scheduleLembrete(Lembrete lembrete) async {
    try {
      // Garante que os dados de timezone estão carregados.
      tzdata.initializeTimeZones();
      final scheduled = tz.TZDateTime.from(lembrete.dateTime, tz.local);

      final id = lembrete.id.hashCode & 0x7fffffff;

      final androidDetails = AndroidNotificationDetails(
        'lembretes_channel',
        'Lembretes',
        channelDescription: 'Lembretes agendados',
        importance: Importance.max,
        priority: Priority.high,
      );

      final iosDetails = DarwinNotificationDetails();

      await _plugin.zonedSchedule(
        id,
        lembrete.title,
        lembrete.description,
        scheduled,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.exact,
        payload: jsonEncode({
          'route': '/notificacoes',
          'lembreteId': lembrete.id,
        }),
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    } catch (e) {
      // Observação: o código original instancia Exception(...) sem lançá-la
      // ou logá-la. Preservei esse comportamento, mas isso significa que
      // erros são silenciosos. Recomendo revisar se deseja lançar ou
      // registrar estes erros.
      Exception('scheduleLembrete error: $e');
    }
  }

  /// Cancela uma notificação agendada pelo [lembreteId].
  Future<void> cancelLembreteById(String lembreteId) async {
    try {
      final id = lembreteId.hashCode & 0x7fffffff;
      await _plugin.cancel(id);
    } catch (e) {
      // Mantido o comportamento original (execução silenciosa em caso de
      // erro); ver observação em `scheduleLembrete`.
      Exception('cancelLembreteById error: $e');
    }
  }
}
