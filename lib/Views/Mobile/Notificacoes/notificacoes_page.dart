import 'package:dose_certa/Models/DataSource/lembrete_box_handler.dart';
import 'package:dose_certa/Models/Models/lembrete.dart';
import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  final LembreteBoxHandler _lembreteHandler = LembreteBoxHandler();
  late List _lembretes;

  @override
  void initState() {
    _lembretes = _lembreteHandler.getTodayTriggeredLembretes(DateTime.now());
    //_lembretes = _lembreteHandler.getAllLembretes(); // Para teste
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackground,
        title: Text(
          'Notificações',
          style: AppTextStyles.semibold24.copyWith(
            color: AppColors.mainTextColor,
          ),
        ),
        leading: CustomBackButton(),
      ),
      body: ListView.builder(
        itemCount: _lembretes.length,
        itemBuilder: (context, index) {
          final lembrete = _lembretes[index] as Lembrete;
          return Dismissible(
            key: Key(lembrete.id),
            direction: DismissDirection.endToStart,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gray400,
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(lembrete.title),
                  subtitle: Text(
                    'Data e hora: ${DateFormat('dd/MM/yyyy HH:mm').format(lembrete.dateTime)}',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
