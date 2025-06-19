import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'speech_to_text_event.dart';
part 'speech_to_text_state.dart';

class SpeechToTextBloc extends Bloc<SpeechToTextEvent, SpeechToTextState> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  String _recognizedText = '';
  Timer? _debounce;

  SpeechToTextBloc() : super(SpeechToTextInitial()) {
    on<StartListening>((event, emit) async {
      bool available = await _speech.initialize();
      if (available) {
        emit(ChatListening());
        _speech.listen(onResult: (result) {
          _recognizedText = result.recognizedWords;
          print(_recognizedText);

          // Debounce: tunggu 1 detik sejak terakhir bicara
          _debounce?.cancel();
          _debounce = Timer(const Duration(seconds: 1), () {
            add(StopListening());
          });
        });
      } else {
        emit(ChatError("Speech recognition unavailable"));
      }
    });

    on<StopListening>((event, emit) async {
      await _speech.stop();
      _debounce?.cancel();
      add(SendMessage(_recognizedText));
    });

    on<StopSpeaking>((event, emit) async {
      await _tts.stop();
    });

    on<SendMessage>((event, emit) async {
      emit(ChatLoading());
      try {
        final response = await _sendToGemini(event.message);
        print(response);
        await _tts.speak(response);
        emit(ChatSuccess(event.message, response));
      } catch (e) {
        emit(ChatError("Failed to get response: $e"));
      }
    });
  }

  Future<String> sendToOpenAI(String prompt) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key is missing');
    }

    final dio = Dio();
    try {
      final response = await dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        }),
        data: {
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": prompt},
          ],
        },
      );
      return response.data['choices'][0]['message']['content']
          .toString()
          .trim();
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception(
            'Rate limit exceeded. Please wait and try again later.');
      } else {
        throw Exception('OpenAI request failed: ${e.message}');
      }
    }
  }

  Future<String> _sendToGemini(String prompt) async {
    print("prompt: $prompt");
    // int totalTokens = 0;
    String answer = '';

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key is missing');
    }

    //komen

    GenerativeModel model =
        GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);

    // model.countTokens([
    //   Content.text(prompt),
    //   Content.multi([
    //     TextPart(prompt),
    //   ])
    // ]).then((value) {
    //   totalTokens = value.totalTokens;
    // });

    final value = await model.generateContent([
      Content.multi([
        TextPart(prompt),
      ])
    ]);
    answer = value.text.toString();
    print("answer: $answer");

    return answer;
  }
}
