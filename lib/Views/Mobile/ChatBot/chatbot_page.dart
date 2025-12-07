import 'package:dose_certa/viewmodels/mobile/chatbot_viewmodel.dart';
import 'package:dose_certa/Models/services/app_connectivity_service.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _viewmodel = ChatbotViewmodel();
  late TextEditingController _messageController;

  final List<Widget> _messagesList = [];

  @override
  void initState() {
    _messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messagesList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SingleChildScrollView(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (!AppConnectivity().isConnected!) {
      return Center(
        child: Text(
          "Sem conexão com a internet. Por favor, verifique sua conexão e tente novamente.",
          style: AppTextStyles.medium14.copyWith(
            color: AppColors.mainTextColor,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [_buildHeader(), _buildChat(), _buildTextSection()],
    );
  }

  Widget _buildChat() {
    return SizedBox(
      height: 680, //580
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: _messagesList.isNotEmpty ? _messagesList : [],
          ),
        ),
      ),
    );
  }

  Widget _buildTextSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: "Digite sua mensagem...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              inputFormatters: [LengthLimitingTextInputFormatter(600)],
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bluePrimary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  onPressed() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      final response = await _viewmodel.sendMessage(message);
      setState(() {
        _messagesList.add(_messageBubble(message, true));
        _messagesList.add(_messageBubble(response, false));
        _messageController.clear();
      });
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 80, 0, 10),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.bluePrimary,
              borderRadius: BorderRadius.circular(30),
            ),
            clipBehavior: Clip.hardEdge,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                "assets/icons/chatbot.png",
                width: 20,
                height: 20,
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "Chatbot DoseCerta",
            style: AppTextStyles.semibold20.copyWith(
              color: AppColors.mainTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12.0, 10, 12.0, 10),
        margin: isUser
            ? const EdgeInsets.fromLTRB(50.0, 5.0, 0.0, 5.0)
            : const EdgeInsets.fromLTRB(0.0, 5.0, 50.0, 5.0),
        decoration: BoxDecoration(
          color: isUser ? AppColors.bluePrimary : AppColors.blueWhite,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          message,
          style: AppTextStyles.medium14.copyWith(
            color: isUser ? Colors.white : AppColors.mainTextColor,
          ),
        ),
      ),
    );
  }
}
