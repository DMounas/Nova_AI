import 'dart:convert';
import 'package:nova_ai/secrets.dart'; 
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;


enum ResponseType { text, image }


class AIResponse {
  final ResponseType type;
  final String content;

  AIResponse({required this.type, required this.content});
}

class OpenAIService {

  static const String _projectId = 'gen-lang-client-0218370088';
  static const String _location = 'us-central1';

  GenerativeModel _initModel() {
    return GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: geminiApiKey,
    );
  }

  Future<AIResponse> isArtPromptAPI(String prompt) async {
    try {
      final model = _initModel();
      final generationConfig = GenerationConfig(maxOutputTokens: 10);
      final content = [
        Content.text(
          'Does this message want to generate an AI picture, image, art or anything similar? \'$prompt\'. Simply answer with a yes or no.',
        ),
      ];
      final response = await model.generateContent(
        content,
        generationConfig: generationConfig,
      );
      final text = response.text?.toLowerCase().trim() ?? 'no';

      if (text.contains('yes')) {
        final imageData = await dallEAPI(prompt);
        if (imageData.contains('Sorry')) {
          return AIResponse(type: ResponseType.text, content: imageData);
        }
        return AIResponse(type: ResponseType.image, content: imageData);
      } else {
        final chatData = await chatGeminiAPI(prompt);
        return AIResponse(type: ResponseType.text, content: chatData);
      }
    } catch (e) {
      print('Error in isArtPromptAPI: $e');
      return AIResponse(
        type: ResponseType.text,
        content: 'Sorry, an error occurred on my end.',
      );
    }
  }


  Future<String> chatGeminiAPI(String prompt) async {
    final model = _initModel();
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text?.trim() ?? 'I could not process that.';
  }


  Future<String> dallEAPI(String prompt) async {
    final url = Uri.parse(
      'https://$_location-aiplatform.googleapis.com/v1/projects/$_projectId/locations/$_location/publishers/google/models/imagegeneration@006:predict',
    );

    // Remember to get a fresh access token for testing
    final String tempAccessToken =
        'ya29.a0AW4Xtxgd10C0cD8oUijnjMUf4TqB-L99m4pXyVOS0cDWS7gTRqEJ_KOUY1jvJREShdsER6arKkWXYLgMDe5i3WNYCl5mexjFGe9nX7Im5Pvw1TUlu0UHSerXJEmPPW67BUUGw3DqkB4ISEqDtL3GwVonnkBgrCNAez65m_tIaCgYKAZ8SARESFQHGX2MiMXOZx2kI6h8BwaHHwmYsDg0175';

    final headers = {
      'Authorization': 'Bearer $tempAccessToken',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'instances': [
        {'prompt': prompt},
      ],
      'parameters': {'sampleCount': 1},
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['predictions'][0]['bytesBase64Encoded'];
      } else {
        print('Image generation failed: ${response.body}');
        return 'Sorry, I was unable to create the image.';
      }
    } catch (e) {
      print('Error in dallEAPI: $e');
      return 'An error occurred while generating the image.';
    }
  }
}
