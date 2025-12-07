import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';
import 'package:dose_certa/Models/Models/consulta.dart';
import 'package:dose_certa/Models/Models/medicamento.dart';
import 'package:dose_certa/Models/Models/tarefa.dart';
import 'package:dose_certa/Models/services/graficos_service.dart';
import 'package:dose_certa/_Core/utils/utils.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
// Observação: gráficos são gerados na UI e capturados como PNG para embutir no PDF.
// Aqui fazemos consultas diretas ao Firestore para construir o relatório.

/// Serviço responsável por gerar relatórios em PDF com dados do usuário.
///
/// Documentação (PT-BR):
/// - Usa consultas diretas ao Firestore para coletar medicamentos,
///   consultas e tarefas no período informado. Em seguida gera um PDF
///   contendo dados, tabelas e gráficos (quando disponíveis).
/// - Não altera o comportamento do projeto; apenas organiza e documenta o
///   fluxo existente.
class RelatorioService {
  RelatorioService();

  final UserViewModel _userController = UserViewModel();

  // Dados do relatório (preenchidos por `getDataFromPeriod`).
  List<Medicamento> medicamentosPeriod = [];
  List<Consulta> consultasPeriod = [];
  List<Tarefa> tarefasConcluidas = [];
  List<Tarefa> tarefasPendentes = [];
  // tarefas que possuem comentário (aparecem em lista extra independente do estado)
  List<Tarefa> tarefasComentadas = [];

  Future<File> generateRelatorioPdf({
    required String fileName,
    required DateTime initialDate,
    required DateTime finalDate,
  }) async {
    await getDataFromPeriod(initialDate: initialDate, finalDate: finalDate);

    final pdf = Document();

    Uint8List? logoBytes;
    try {
      const assetPath = 'assets/images/logo_variation.png';
      final data = await rootBundle.load(assetPath);
      logoBytes = data.buffer.asUint8List();
    } catch (_) {
      logoBytes = null;
    }

    Uint8List? graficoPie;

    try {
      graficoPie = await GraficosService().gerarGraficoAdesao(
        tarefasConcluidas.length.toDouble(),
        tarefasPendentes.length.toDouble(),
      );
    } catch (_) {
      graficoPie = null;
    }

    // Placeholder para gráfico de barras. Atualmente não há geração local
    // programática aqui; mantive a variável para preservar compatibilidade.
    Uint8List? graficoBar;

    pdf.addPage(
      generateMultiPageDocument(
        logoBytes: logoBytes,
        graficoPie: graficoPie,
        graficoBar: graficoBar,
        initialDate: initialDate,
        finalDate: finalDate,
      ),
    );

    return saveRelatorioPdf(fileName: fileName, pdf: pdf);
  }

  Future<File> saveRelatorioPdf({
    required String fileName,
    required Document pdf,
  }) async {
    final root = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final file = File('${root!.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> openPdf(File file) async {
    final path = file.path;
    await OpenFile.open(path);
  }

  MultiPage generateMultiPageDocument({
    Uint8List? logoBytes,
    Uint8List? graficoPie,
    Uint8List? graficoBar,
    required DateTime initialDate,
    required DateTime finalDate,
  }) {
    return MultiPage(
      header: (context) => customHeader(logoBytes: logoBytes),
      footer: (context) => customFooter(),
      pageFormat: PdfPageFormat.a4,
      build: (Context context) {
        final children = <Widget>[];
        if (logoBytes != null) {
          final image = MemoryImage(logoBytes);
          children.add(
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Image(image, width: 100, height: 100),
            ),
          );
        }

        children.addAll([
          customTitle('Relatório de Adesão'),
          SizedBox(height: 20),
          customUserInfo(
            Utils.capitalizeTitle(_userController.currentUser!.fullname),
            _userController.currentUser!.email,
            '${DateFormat("dd/MM/yyyy").format(initialDate)} - ${DateFormat("dd/MM/yyyy").format(finalDate)}',
          ),
          SizedBox(height: 20),
          customSubTitle('Adesão ao Tratamento'),
          SizedBox(height: 10),
          if (graficoPie != null)
            customGraficoFromBytes(graficoPie)
          else
            Container(
              child: Text(
                'Gráfico indisponível',
                style: TextStyle(fontSize: 14),
              ),
            ),
          SizedBox(height: 10),
          adesaoSection(),
          SizedBox(height: 20),
          customSubTitle('Medicamentos do Paciente'),
          SizedBox(height: 10),
          medicamentosSection(),
          SizedBox(height: 20),
          customSubTitle('Consultas do Paciente'),
          SizedBox(height: 10),
          consultasSection(),
          SizedBox(height: 20),
          customSubTitle('Tarefas do Paciente'),
          SizedBox(height: 10),
          tarefasSection(),
          SizedBox(height: 20),
          customSubTitle('Tarefas com Comentários'),
          SizedBox(height: 10),
          comentariosSection(),
          SizedBox(height: 20),
        ]);

        return children;
      },
    );
  }

  Future<void> getDataFromPeriod({
    required DateTime initialDate,
    required DateTime finalDate,
    String? userId,
  }) async {
    final uid = userId ?? _userController.currentUser!.id;
    final startMillis = DateTime(
      initialDate.year,
      initialDate.month,
      initialDate.day,
    ).millisecondsSinceEpoch;
    final endExclusiveMillis = DateTime(
      finalDate.year,
      finalDate.month,
      finalDate.day,
    ).add(const Duration(days: 1)).millisecondsSinceEpoch;

    final firestore = FirebaseFirestore.instance;

    try {
      final medsSnapshot = await firestore
          .collection('usuarios')
          .doc(uid)
          .collection('medicamentos')
          .where('startDate', isGreaterThanOrEqualTo: startMillis)
          .where('startDate', isLessThan: endExclusiveMillis)
          .get();

      medicamentosPeriod = medsSnapshot.docs
          .map((d) => Medicamento.fromMap(d.data()))
          .toList();

      // Ordena medicamentos por data de início
      medicamentosPeriod.sort((a, b) => a.startDate.compareTo(b.startDate));
    } catch (e) {
      medicamentosPeriod = [];
      rethrow;
    }

    try {
      final consultasSnapshot = await firestore
          .collection('usuarios')
          .doc(uid)
          .collection('consultas')
          .where('dateTime', isGreaterThanOrEqualTo: startMillis)
          .where('dateTime', isLessThan: endExclusiveMillis)
          .get();

      consultasPeriod = consultasSnapshot.docs
          .map((d) => Consulta.fromMap(d.data()))
          .toList();

      // Ordena consultas por data
      consultasPeriod.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } catch (e) {
      consultasPeriod = [];
      rethrow;
    }

    try {
      final tarefasSnapshot = await firestore
          .collection('usuarios')
          .doc(uid)
          .collection('tarefas')
          .where('executionTime', isGreaterThanOrEqualTo: startMillis)
          .where('executionTime', isLessThan: endExclusiveMillis)
          .orderBy('executionTime', descending: false)
          .get();

      final tarefas = tarefasSnapshot.docs
          .map((d) => Tarefa.fromMap(d.data()))
          .toList();

      tarefas.sort((a, b) => a.executionTime.compareTo(b.executionTime));

      tarefasConcluidas = tarefas.where((t) => t.state == 'Executada').toList();
      tarefasPendentes = tarefas.where((t) => t.state != 'Executada').toList();

      tarefasComentadas = tarefas
          .where((t) => t.comment != null && t.comment!.trim().isNotEmpty)
          .toList();
    } catch (e) {
      tarefasConcluidas = [];
      tarefasPendentes = [];
      rethrow;
    }
  }

  Widget customHeader({Uint8List? logoBytes}) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 20),
      child: (logoBytes != null)
          ? Opacity(
              opacity: .5,
              child: Image(MemoryImage(logoBytes), width: 50, height: 50),
            )
          : Text(
              'Relatório de Adesão',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget customFooter() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10),
      child: Text(
        'Relatorio gerado automaticamente. Obrigado por usar o Dose Certa!',
        style: TextStyle(fontSize: 10, color: PdfColors.grey),
      ),
    );
  }

  Widget customTitle(String text) {
    return Container(
      padding: const EdgeInsets.only(bottom: 3 * PdfPageFormat.mm),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 2, color: PdfColors.grey)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 25,
          color: PdfColors.blue900,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget customSubTitle(String text) {
    return Container(
      padding: const EdgeInsets.only(bottom: 2 * PdfPageFormat.mm),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: PdfColors.grey)),
      ),
      child: Text(text, style: TextStyle(fontSize: 18)),
    );
  }

  Widget customGraficoFromBytes(
    Uint8List bytes, {
    double width = 180,
    double height = 180,
  }) {
    final image = MemoryImage(bytes);
    return Container(
      alignment: Alignment.center,
      child: Image(image, width: width, height: height),
    );
  }

  String _normalizeTaskState(String state) {
    if (state == 'Novo' || state == 'Pendente') {
      return 'Não Executada';
    }
    return state;
  }

  Widget customUserInfo(String name, String email, String periodo) {
    final now = DateFormat("dd/MM/yyyy").format(DateTime.now());
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Paciente: $name', style: TextStyle(fontSize: 18)),
          Text('Email: $email', style: TextStyle(fontSize: 18)),
          Text('Período: $periodo', style: TextStyle(fontSize: 18)),
          Text('Data de Geração: $now', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget adesaoSection() {
    final realizadas = tarefasConcluidas.length;
    final pendentes = tarefasPendentes.length;
    final total = realizadas + pendentes;
    if (total <= 0) {
      return Container(
        child: Text(
          'Nenhuma tarefa encontrada no período selecionado.',
          style: TextStyle(fontSize: 14),
        ),
      );
    }
    final fraction = realizadas / total;
    final percent = (fraction * 100).floor();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adesão ao Tratamento: $percent%',
            style: TextStyle(fontSize: 14),
          ),
          Text('Total de Tarefas: $total', style: TextStyle(fontSize: 14)),
          Text(
            'Tarefas Concluídas: ${tarefasConcluidas.length}',
            style: TextStyle(fontSize: 14),
          ),
          Text(
            'Tarefas Pendentes: ${tarefasPendentes.length}',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget medicamentosSection() {
    if (medicamentosPeriod.isEmpty) {
      return Container(
        child: Text(
          'Nenhum medicamento encontrado no período selecionado.',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return Table(
      border: TableBorder.all(color: PdfColors.grey),
      children: [
        TableRow(
          decoration: BoxDecoration(color: PdfColors.blue100),
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Nome',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Dosagem',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Início',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Frequência',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        ...medicamentosPeriod.map(
          (med) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(med.name, style: TextStyle(fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(med.unit, style: TextStyle(fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  DateFormat("dd/MM/yyyy").format(med.startDate),
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(med.frequency, style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget consultasSection() {
    if (consultasPeriod.isEmpty) {
      return Container(
        child: Text(
          'Nenhuma consulta encontrada no período selecionado.',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return Table(
      border: TableBorder.all(color: PdfColors.grey),
      children: [
        TableRow(
          decoration: BoxDecoration(color: PdfColors.blue100),
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Consulta',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Data',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Médico',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Observações',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        ...consultasPeriod.map(
          (cons) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(cons.name, style: TextStyle(fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  DateFormat("dd/MM/yyyy HH:mm").format(cons.dateTime),
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  (cons.doctor != null) ? cons.doctor! : "Não Informado",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  (cons.description != null)
                      ? cons.description!
                      : "Sem Observações",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget tarefasSection() {
    if (tarefasConcluidas.isEmpty && tarefasPendentes.isEmpty) {
      return Container(
        child: Text(
          'Nenhuma tarefa encontrada no período selecionado.',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return Table(
      border: TableBorder.all(color: PdfColors.grey),
      children: [
        TableRow(
          decoration: BoxDecoration(color: PdfColors.blue100),
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Tarefa',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Data de Execução',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Estado',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        ...tarefasConcluidas.map(
          (tarefa) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(tarefa.taskName, style: TextStyle(fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  DateFormat("dd/MM/yyyy HH:mm").format(tarefa.executionTime),
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  _normalizeTaskState(tarefa.state),
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        ...tarefasPendentes.map(
          (tarefa) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(tarefa.taskName, style: TextStyle(fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  DateFormat("dd/MM/yyyy HH:mm").format(tarefa.executionTime),
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  _normalizeTaskState(tarefa.state),
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget comentariosSection() {
    if (tarefasComentadas.isEmpty) {
      return Container(
        child: Text(
          'Nenhuma tarefa com comentário encontrada no período selecionado.',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return Table(
      border: TableBorder.all(color: PdfColors.grey),
      children: [
        TableRow(
          decoration: BoxDecoration(color: PdfColors.blue100),
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Tarefa',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Data',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Comentário',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        ...tarefasComentadas.map(
          (tarefa) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(tarefa.taskName, style: TextStyle(fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  DateFormat("dd/MM/yyyy HH:mm").format(tarefa.executionTime),
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  tarefa.comment ?? '',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
