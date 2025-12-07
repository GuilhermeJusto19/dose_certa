import 'package:dose_certa/Models/services/chat_service.dart';

class ChatbotViewmodel {
  final messages = <String>[];

  final chatService = ChatService();

  Future<String> sendMessage(String message) async {
    messages.add(message);
    return await chatService.messageChat(messages);
  }
}
