part of 'speech_to_text_bloc.dart';

sealed class SpeechToTextEvent {}

class StartListening extends SpeechToTextEvent {}

class StopListening extends SpeechToTextEvent {}

class StopSpeaking extends SpeechToTextEvent {}

class SendMessage extends SpeechToTextEvent {
  final String message;
  SendMessage(this.message);
}
