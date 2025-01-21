import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token.dart';

// print current working directory

class GptApi {
  final String apiKey;
  http.Client client;
  final modelMap = {
      'GPT-3.5-turbo': 'gpt-3.5-turbo-0125',
      'GPT-4o-mini': 'gpt-4o-mini',
      'GPT-4o': 'gpt-4o',
    };


  GptApi({http.Client? client})
      : apiKey = OpenAIToken,
        client = client ?? http.Client();

  Future<String> queryGpt(String input, String prompt, List<Map<String, String>> messages, String model) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    String message = '$prompt\n\nUser: $input\n';

    final limitedMessages = [
      {'role': 'system', 'content': prompt},
      ...messages.take(5).map((msg) {
        return {'role': msg['type'] == 'sent' ? 'user' : 'assistant', 'content': msg['text']};
      })
    ];
    print("model: $model");

    model = modelMap[model] ?? 'gpt-4o-mini';
    print('Querying GPT with message: $message');
    print('Model: $model');
    print("personality: $prompt");

    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': limitedMessages,
        'max_tokens': 500,
      }),
      encoding: Encoding.getByName('utf-8'), // Ensure UTF-8 encoding
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String gptResponse = data['choices'][0]['message']['content'].trim();
      // Remove special characters except ! and ?
      gptResponse = gptResponse.replaceAll(RegExp(r'[^\w\s!?]+'), '');
      return gptResponse;
    } else {
      print('Response body: ${response.body}');
      throw Exception('Failed to query: ${response.statusCode}');
    }
  }
}



