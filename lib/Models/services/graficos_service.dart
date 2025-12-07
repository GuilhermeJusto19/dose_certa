import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:dose_certa/Models/Models/tarefa.dart';

class GraficosService {
  /// Gera um gráfico de pizza (PNG) mostrando a porcentagem de adesão.
  ///
  /// [realizadas] e [pendentes] são valores numéricos representando as
  /// quantidades realizadas e pendentes. Retorna `Uint8List` com os bytes PNG
  /// ou `null` em caso de erro ou quando não houver dados.
  ///
  /// Observação: Há uma possível inconsistência de dimensão na implementação
  /// original — o `Rect` usado para desenhar e as dimensões passadas para
  /// `toImage` são diferentes (troquei apenas a documentação para não alterar
  /// comportamento). Se quiser, posso alinhar as dimensões num passo seguinte.
  Future<Uint8List?> gerarGraficoAdesao(
    double realizadas,
    double pendentes, {
    int sizeX = 400,
    int sizeY = 500,
  }) async {
    try {
      final total = realizadas + pendentes;
      if (total <= 0) return null;

      // porcentagem e fração
      final fraction = realizadas / total;
      final percent = (fraction * 100).floor();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, sizeX.toDouble(), sizeX.toDouble()),
      );

      final center = Offset(sizeX / 2, sizeX / 2);
      final radius = sizeX * 0.4;
      final rect = Rect.fromCircle(center: center, radius: radius);

      final startAngle = -math.pi / 2; // inicia pelo topo
      final sweep1 = 2 * math.pi * fraction;
      final sweep2 = 2 * math.pi * (1 - fraction);

      final paintRealizadas = Paint()..color = Colors.green;
      final paintPendentes = Paint()..color = Colors.red;

      // fatia realizadas
      canvas.drawArc(rect, startAngle, sweep1, true, paintRealizadas);

      // fatia pendentes
      canvas.drawArc(rect, startAngle + sweep1, sweep2, true, paintPendentes);

      // efeito donut
      final holePaint = Paint()..color = Colors.white;
      canvas.drawCircle(center, radius * 0.55, holePaint);

      // texto central com porcentagem
      final paragraphStyle = ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 36,
        maxLines: 1,
      );
      final textStyle = ui.TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      );

      final builder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(textStyle)
        ..addText('$percent%');

      final paragraph = builder.build();
      paragraph.layout(ui.ParagraphConstraints(width: sizeX.toDouble()));

      final px = (sizeX - paragraph.maxIntrinsicWidth) / 2;
      final py = center.dy - (paragraph.height / 2);
      // nota: o deslocamento +50 foi mantido da versão original
      canvas.drawParagraph(paragraph, Offset((px + 50), py));

      // finaliza imagem
      final picture = recorder.endRecording();
      final img = await picture.toImage(sizeY, sizeX);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e, st) {
      // captura erros e retorna null para o chamador poder usar fallback
      debugPrint('Erro ao gerar gráfico programático: $e\n$st');
      return null;
    }
  }

  /// Gera um gráfico de barras agrupadas por semana (PNG) mostrando adesão.
  ///
  /// [realizadas] e [pendentes] são listas de `Tarefa` que serão agrupadas
  /// por semana (semana começando na segunda-feira). Cada semana desenha duas
  /// barras agrupadas: realizadas (verde) e pendentes (vermelho). O gráfico
  /// mostrará no máximo [maxWeeks] semanas mais recentes.
  Future<Uint8List?> gerarGraficoAdesaoPorSemana({
    required List<Tarefa> realizadas,
    required List<Tarefa> pendentes,
    int maxWeeks = 8,
    int width = 1000,
    int height = 500,
  }) async {
    try {
      final all = <DateTime>[];
      all.addAll(realizadas.map((t) => t.executionTime));
      all.addAll(pendentes.map((t) => t.executionTime));

      if (all.isEmpty) return null;

      DateTime weekStart(DateTime d) {
        // Normalize to Monday
        final monday = d.subtract(Duration(days: d.weekday - 1));
        return DateTime(monday.year, monday.month, monday.day);
      }

      final minDate = all.reduce((a, b) => a.isBefore(b) ? a : b);
      final maxDate = all.reduce((a, b) => a.isAfter(b) ? a : b);

      DateTime startWeek = weekStart(minDate);
      DateTime endWeek = weekStart(maxDate);

      // build weeks list from startWeek to endWeek
      final weeks = <DateTime>[];
      for (
        var w = startWeek;
        w.isBefore(endWeek.add(const Duration(days: 1)));
        w = w.add(const Duration(days: 7))
      ) {
        weeks.add(w);
      }

      // limit to most recent maxWeeks
      final displayWeeks = weeks.length > maxWeeks
          ? weeks.sublist(weeks.length - maxWeeks)
          : weeks;

      // counts per week
      final concluidasCounts = <int>[];
      final pendentesCounts = <int>[];

      for (final w in displayWeeks) {
        final wEnd = w.add(const Duration(days: 7));
        final c = realizadas
            .where(
              (t) =>
                  !t.executionTime.isBefore(w) &&
                  t.executionTime.isBefore(wEnd),
            )
            .length;
        final p = pendentes
            .where(
              (t) =>
                  !t.executionTime.isBefore(w) &&
                  t.executionTime.isBefore(wEnd),
            )
            .length;
        concluidasCounts.add(c);
        pendentesCounts.add(p);
      }

      // prepare drawing
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      );
      final paintConcl = Paint()..color = Colors.green;
      final paintPend = Paint()..color = Colors.red;
      final axisPaint = Paint()..color = Colors.black;

      final marginLeft = 60.0;
      final marginBottom = 80.0;
      final marginTop = 20.0;
      final plotWidth = width - marginLeft - 20.0;
      final plotHeight = height - marginTop - marginBottom;

      final weeksCount = displayWeeks.length;
      final groupWidth = plotWidth / (weeksCount == 0 ? 1 : weeksCount);
      final barWidth = groupWidth * 0.35;

      final maxValue = <int>[
        ...concluidasCounts,
        ...pendentesCounts,
      ].fold<int>(0, (prev, e) => e > prev ? e : prev);
      final yMax = (maxValue <= 0) ? 1 : maxValue;

      // draw y axis and ticks
      final tickCount = 4;
      final textStyle = ui.TextStyle(color: Colors.black, fontSize: 12);
      for (int i = 0; i <= tickCount; i++) {
        final y = marginTop + plotHeight - (plotHeight * (i / tickCount));
        canvas.drawLine(
          Offset(marginLeft - 5, y),
          Offset(marginLeft, y),
          axisPaint,
        );
        final val = (yMax * (i / tickCount)).round();
        final paraStyle = ui.ParagraphStyle(
          textAlign: TextAlign.right,
          fontSize: 12,
        );
        final pb = ui.ParagraphBuilder(paraStyle)
          ..pushStyle(textStyle)
          ..addText('$val');
        final p = pb.build();
        p.layout(ui.ParagraphConstraints(width: marginLeft - 10));
        canvas.drawParagraph(p, Offset(0, y - p.height / 2));
      }

      // draw bars
      for (int idx = 0; idx < weeksCount; idx++) {
        final groupX = marginLeft + idx * groupWidth;
        // two bars: concluidas (left), pendentes (right)
        final cVal = concluidasCounts[idx];
        final pVal = pendentesCounts[idx];
        final cH = (cVal / yMax) * plotHeight;
        final pH = (pVal / yMax) * plotHeight;

        final cLeft = groupX + (groupWidth * 0.15);
        final pLeft =
            groupX + (groupWidth * 0.15) + barWidth + (groupWidth * 0.05);

        // draw concluidas
        canvas.drawRect(
          Rect.fromLTWH(cLeft, marginTop + plotHeight - cH, barWidth, cH),
          paintConcl,
        );
        // draw pendentes
        canvas.drawRect(
          Rect.fromLTWH(pLeft, marginTop + plotHeight - pH, barWidth, pH),
          paintPend,
        );

        // week label
        final wLabel = '${displayWeeks[idx].day}/${displayWeeks[idx].month}';
        final paraStyle = ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: 12,
        );
        final pb = ui.ParagraphBuilder(paraStyle)
          ..pushStyle(textStyle)
          ..addText(wLabel);
        final p = pb.build();
        p.layout(ui.ParagraphConstraints(width: groupWidth));
        canvas.drawParagraph(p, Offset(groupX, marginTop + plotHeight + 6));
      }

      // legend
      final legendY = marginTop + 6;
      canvas.drawRect(Rect.fromLTWH(width - 150, legendY, 12, 12), paintConcl);
      final pb1 =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(textAlign: TextAlign.left, fontSize: 12),
            )
            ..pushStyle(textStyle)
            ..addText(' Concluídas');
      final p1 = pb1.build();
      p1.layout(ui.ParagraphConstraints(width: 120));
      canvas.drawParagraph(p1, Offset(width - 135, legendY - 2));

      canvas.drawRect(
        Rect.fromLTWH(width - 150, legendY + 18, 12, 12),
        paintPend,
      );
      final pb2 =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(textAlign: TextAlign.left, fontSize: 12),
            )
            ..pushStyle(textStyle)
            ..addText(' Pendentes');
      final p2 = pb2.build();
      p2.layout(ui.ParagraphConstraints(width: 120));
      canvas.drawParagraph(p2, Offset(width - 135, legendY + 16));

      // finalize
      final picture = recorder.endRecording();
      final img = await picture.toImage(width, height);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      return bd?.buffer.asUint8List();
    } catch (e, st) {
      debugPrint('Erro ao gerar gráfico de barras: $e\n$st');
      return null;
    }
  }
}
