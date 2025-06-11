part of 'speech_to_text_bloc.dart';

sealed class SpeechToTextState {}

final class SpeechToTextInitial extends SpeechToTextState {}

class ChatListening extends SpeechToTextState {}

class ChatLoading extends SpeechToTextState {}

class ChatSuccess extends SpeechToTextState {
  final String userMessage;
  final String aiResponse;
  ChatSuccess(this.userMessage, this.aiResponse);
}

class ChatError extends SpeechToTextState {
  final String message;
  ChatError(this.message);
}
