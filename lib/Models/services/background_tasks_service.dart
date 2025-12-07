import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dose_certa/viewmodels/mobile/tarefa_viewmodel.dart';
import 'package:dose_certa/Models/DataSource/lembrete_box_handler.dart';
import 'package:dose_certa/Models/Models/consulta.dart';
import 'package:dose_certa/Models/Models/lembrete.dart';
import 'package:dose_certa/Models/Models/medicamento.dart';
import 'package:dose_certa/Models/Models/tarefa.dart';
import 'package:dose_certa/Models/Repositories/tarefa_repository_imp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_latest/flutter_native_timezone_latest.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

/// Serviço utilitário para tarefas executadas em background (ex.: WorkManager).
///
/// Documentação (PT-BR):
/// - Este arquivo contém a lógica usada por workers agendados para:
///   * renovar lembretes e tarefas (`dailyWorker`)
///   * re-agendar notificações locais a partir de dados remotos (`rescheduleNotifications`)
/// - A implementação preserva a lógica original do projeto. Não alterei regras
///   de negócio, apenas melhorei nomes locais e adicionei documentação.
///
/// Observação importante sobre comportamento observado:
/// - O código original cria instâncias de `Exception('...')` em vários pontos,
///   mas não lança (`throw`) nem registra essas exceções — isso é provavelmente
///   um comportamento não intencional. Para preservar o comportamento atual
///   (sem alterar fluxo), mantive as chamadas tal como estavam, mas documentei
///   a observação acima. Caso queira, posso substituir por `print`, `log` ou
///   `throw` conforme preferir.
class BackgroundTasks {
  BackgroundTasks._();

  static const String dailyWorker = 'daily_worker';
  static const String rescheduleNotifications = 'reschedule_notifications';

  /// Executa uma tarefa de background pelo [taskName]. Retorna `true` quando
  /// o trabalho foi concluído com sucesso, `false` caso contrário.
  static Future<bool> execute(String taskName) async {
    try {
      tzdata.initializeTimeZones();
      try {
        final tzName = await FlutterNativeTimezoneLatest.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(tzName));
      } catch (_) {
        // Fallback: se não for possível obter o timezone nativo, usamos
        // as configurações padrão carregadas por tzdata.
      }

      await Hive.initFlutter();
      Hive.registerAdapter(LembreteAdapter());
      await LembreteBoxHandler().init();

      if (taskName == rescheduleNotifications) {
        return await _reschduleNotifications();
      }

      if (taskName == dailyWorker) {
        return await _dailyWorker();
      }

      return true;
    } catch (e) {
      // Observação: o código original apenas instanciava Exception(...) sem
      // lançar/logar. Mantive este comportamento para não alterar o fluxo.
      Exception('BackgroundTasks.execute error: $e');
      return false;
    }
  }

  /// Re-agenda notificações locais consultando dados remotos (medicamentos
  /// e consultas) e recriando tarefas/lembretes locais.
  static Future<bool> _reschduleNotifications() async {
    try {
      // Inicializa o plugin de notificações
      final plugin = FlutterLocalNotificationsPlugin();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      final iosSettings = DarwinInitializationSettings();

      await plugin.initialize(
        InitializationSettings(android: androidSettings, iOS: iosSettings),
        onDidReceiveNotificationResponse: (details) {},
      );

      // Tenta inicializar o Firebase se necessário
      try {
        await Firebase.initializeApp();
      } catch (_) {}

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Exception('reschduleNotifications: sem usuário autenticado - falha');
        return true;
      }

      final firestore = FirebaseFirestore.instance;

      // Busca medicamentos do usuário
      final medsSnapshot = await firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('medicamentos')
          .get();
      final meds = medsSnapshot.docs
          .map((d) => Medicamento.fromMap(d.data()))
          .toList();

      final nowMillis = DateTime.now().millisecondsSinceEpoch;
      final consSnapshot = await firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('consultas')
          .where('dateTime', isGreaterThanOrEqualTo: nowMillis)
          .get();
      final consultas = consSnapshot.docs
          .map((d) => Consulta.fromMap(d.data()))
          .toList();

      final tarefaRepo = TarefaRepositoryImp();
      final tarefaController = TarefaViewModel(repository: tarefaRepo);
      final lembreteHandler = LembreteBoxHandler();

      // Helper para agendar lembretes usando o plugin local
      Future<void> scheduleWithPlugin(Lembrete lembrete) async {
        try {
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

          await plugin.zonedSchedule(
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
          Exception('Failed to schedule lembrete in background: $e');
        }
      }

      // Processa medicamentos: deleta recorrências antigas, gera novas tarefas
      for (final med in meds) {
        try {
          await tarefaRepo.deleteTarefaRecurrence(med.id);

          // Cancela notificações antigas e deleta lembretes locais
          final oldLembretes = lembreteHandler.getLembreteRecurrence(med.id);
          for (final l in oldLembretes) {
            try {
              final lid = l.id.hashCode & 0x7fffffff;
              await plugin.cancel(lid);
            } catch (_) {}
          }
          await lembreteHandler.deleteLembreteRecurrence(med.id);

          // Gera novas tarefas para a janela e persiste + agenda
          List<Tarefa> tarefas = [];
          switch (med.frequency) {
            case 'A cada X horas':
              tarefas = tarefaController.gerarTarefasACadaXHoras(med, 10);
              break;
            case 'X vezes ao dia':
              tarefas = tarefaController.gerarTarefasXVezesDia(med, 10);
              break;
            case 'Dias específicos da semana':
              tarefas = tarefaController.gerarTarefasDiasEspecificos(med, 10);
              break;
            case 'Diariamente':
              tarefas = tarefaController.gerarTarefasDiariamente(med, 10);
              break;
            default:
              tarefas = [];
          }

          for (final t in tarefas) {
            await tarefaRepo.addTarefa(t);

            final lembrete = Lembrete(
              id: Uuid().v1(),
              taskId: t.taskId,
              taskType: t.taskType,
              title: 'Hora do medicamento: ${t.taskName}',
              description:
                  '${t.qtdMedicamento ?? ''} ${t.unitMedicamento ?? ''}',
              dateTime: t.executionTime,
            );

            await lembreteHandler.addLembrete(lembrete);
            if (lembrete.dateTime.isAfter(DateTime.now())) {
              await scheduleWithPlugin(lembrete);
            }
          }
        } catch (e) {
          Exception('Failed processing medicamento ${med.id}: $e');
        }
      }

      // Processa consultas: deleta recorrências, gera tarefas e lembretes 1h antes
      for (final consulta in consultas) {
        try {
          await tarefaRepo.deleteTarefaRecurrence(consulta.id);

          final oldLembretes = lembreteHandler.getLembreteRecurrence(
            consulta.id,
          );
          for (final l in oldLembretes) {
            try {
              final lid = l.id.hashCode & 0x7fffffff;
              await plugin.cancel(lid);
            } catch (_) {}
          }
          await lembreteHandler.deleteLembreteRecurrence(consulta.id);

          final tarefas = tarefaController.gerarTarefaConsulta(consulta);
          for (final t in tarefas) {
            await tarefaRepo.addTarefa(t);

            // Lembrete 1 hora antes da consulta
            final lembreteDate = t.executionTime.subtract(
              const Duration(hours: 1),
            );
            final lembrete = Lembrete(
              id: Uuid().v1(),
              taskId: t.taskId,
              taskType: t.taskType,
              title: '${t.taskName} em 1 hora',
              description:
                  'Você tem uma consulta agendada: ${t.taskName}${t.doctorConsulta != null ? ' com o(a) ${t.doctorConsulta}' : ''}',
              dateTime: lembreteDate,
            );

            await lembreteHandler.addLembrete(lembrete);
            if (lembrete.dateTime.isAfter(DateTime.now())) {
              await scheduleWithPlugin(lembrete);
            }
          }
        } catch (e) {
          Exception('Failed processing consulta ${consulta.id}: $e');
        }
      }

      return true;
    } catch (e) {
      Exception('Error scheduling/refreshing tasks from remote: $e');
      return false;
    }
  }

  /// Worker diário que renova lembretes de medicamentos a cada 10 dias.
  static Future<bool> _dailyWorker() async {
    try {
      // Roda diariamente e renova os lembretes de medicamentos a cada 10 dias.
      final metaBox = await Hive.openBox('background_meta'); // guarda metadados
      final lastMillis = metaBox.get('last_renewal_millis') as int?;
      final now = DateTime.now().millisecondsSinceEpoch;
      final tenDaysMs = 10 * 24 * 60 * 60 * 1000;

      if (lastMillis != null && (now - lastMillis) < tenDaysMs) {
        Exception('DailyWorker: not yet time to renew (last was $lastMillis)');
        return true;
      }

      // Tenta inicializar o Firebase e pegar o usuário autenticado
      try {
        await Firebase.initializeApp();
      } catch (_) {
        // caso já esteja inicializado
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Exception('DailyWorker: sem usuário autenticado - falha');
        return true;
      }

      // Pega medicamentos diretamente e gera tarefas
      final snap = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('medicamentos')
          .get();

      final meds = snap.docs.map((d) => Medicamento.fromMap(d.data())).toList();

      final tarefaRepo = TarefaRepositoryImp();
      final tarefaController = TarefaViewModel(repository: tarefaRepo);

      // Prepara plugin de notificações e handler para agendar lembretes
      final plugin = FlutterLocalNotificationsPlugin();
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      final iosSettings = DarwinInitializationSettings();
      await plugin.initialize(
        InitializationSettings(android: androidSettings, iOS: iosSettings),
        onDidReceiveNotificationResponse: (details) {},
      );

      final lembreteHandler = LembreteBoxHandler();

      for (final med in meds) {
        List<Tarefa> tarefas = [];
        switch (med.frequency) {
          case 'A cada X horas':
            tarefas = tarefaController.gerarTarefasACadaXHoras(med, 10);
            break;
          case 'X vezes ao dia':
            tarefas = tarefaController.gerarTarefasXVezesDia(med, 10);
            break;
          case 'Dias específicos da semana':
            tarefas = tarefaController.gerarTarefasDiasEspecificos(med, 10);
            break;
          case 'Diariamente':
            tarefas = tarefaController.gerarTarefasDiariamente(med, 10);
            break;
          default:
            tarefas = [];
        }

        for (final t in tarefas) {
          await tarefaRepo.addTarefa(t);

          // cria lembrete e agenda notificação
          final lembrete = Lembrete(
            id: Uuid().v1(),
            taskId: t.taskId,
            taskType: t.taskType,
            title: 'Hora do medicamento: ${t.taskName}',
            description: '${t.qtdMedicamento ?? ''} ${t.unitMedicamento ?? ''}',
            dateTime: t.executionTime,
          );
          await lembreteHandler.addLembrete(lembrete);

          try {
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
            await plugin.zonedSchedule(
              id,
              lembrete.title,
              lembrete.description,
              scheduled,
              NotificationDetails(android: androidDetails, iOS: iosDetails),
              androidScheduleMode: AndroidScheduleMode.exact,
              payload: jsonEncode({'route': '/', 'lembreteId': lembrete.id}),
              matchDateTimeComponents: DateTimeComponents.dateAndTime,
            );
          } catch (e) {
            Exception('Failed to schedule lembrete in background: $e');
          }
        }
      }

      await metaBox.put('last_renewal_millis', now);
      await metaBox.close();

      Exception('DailyWorker: renewed medicamentos tarefas');
      return true;
    } catch (e) {
      Exception('DailyWorker error: $e');
      return false;
    }
  }
}
