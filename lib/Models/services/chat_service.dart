import 'package:dose_certa/_Core/constants/constants.dart';
import 'package:openai_dart/openai_dart.dart';

/// Serviço responsável por interagir com a API de chat (OpenAI).
///
/// Documentação (PT-BR):
/// - O método `messageChat` recebe uma lista de mensagens (strings do usuário),
///   prepara o payload com instruções do sistema/desenvolvedor e retorna a
///   resposta do modelo como `String`.
/// - Não alterei a lógica original de formação das mensagens; apenas
///   melhorei nomes locais, validações e documentação.
class ChatService {
  ChatService();

  // A chave de API pode vir de constantes de configuração; mantemos como
  // nullable porque a configuração pode não existir em builds locais.
  final String? _openaiApiKey = Constants.openaiApiKey;

  // Cliente instanciado sob demanda para evitar criar o cliente quando a
  // chave não está configurada (preserva comportamento anterior, mas evita
  // exceções inesperadas durante a construção da classe).
  OpenAIClient? _client;

  OpenAIClient get _clientInstance =>
      _client ??= OpenAIClient(apiKey: _openaiApiKey, retries: 1);

  /// Envia [messages] ao modelo de chat e retorna a resposta do assistente.
  ///
  /// Lança uma [Exception] quando a chave de API não está disponível ou quando
  /// não é possível obter uma resposta válida do modelo.
  Future<String> messageChat(List<String> messages) async {
    if (_openaiApiKey == null || _openaiApiKey.isEmpty) {
      throw Exception('A chave de API não foi encontrada.');
    }

    final List<ChatCompletionMessage> payload = [];

    // Instrução que define o comportamento do assistente (mensagem do "desenvolvedor").
    final developerInstruction = ChatCompletionMessage.developer(
      content: ChatCompletionDeveloperMessageContent.text(
        'Você é um assistente que responde dúvidas simples sobre medicamentos, sem diagnósticos e com respostas curtas. Em caso de pedir diagnósticos responda "Para saber o melhor tratamento, recomendo entrar em contato com um médico para lhe orientar.". Caso algo fuja disso, diga apenas "Não entendi a sua dúvida."',
      ),
    );

    payload.add(developerInstruction);

    for (final m in messages) {
      payload.add(
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(m),
        ),
      );
    }

    final client = _clientInstance;

    final CreateChatCompletionResponse response = await client
        .createChatCompletion(
          request: CreateChatCompletionRequest(
            model: ChatCompletionModel.modelId('gpt-3.5-turbo'),
            messages: payload,
          ),
        );

    if (response.choices.isEmpty) {
      throw Exception('Nenhuma resposta recebida do modelo de linguagem.');
    }

    final content = response.choices.first.message.content;
    if (content == null || content.isEmpty) {
      throw Exception('Resposta vazia recebida do modelo.');
    }

    return content;
  }
}
