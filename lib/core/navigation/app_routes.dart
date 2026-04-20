import 'package:flutter/material.dart';
import 'package:nyore/core/navigation/routes.dart';
import 'package:nyore/features/agent/presentation/page/chef_agent_page.dart';
import 'package:nyore/features/ask_gemini/presentation/page/ask_gemini_page.dart';
import 'package:nyore/features/chatbot/presentation/page/chatbot_page.dart';
import 'package:nyore/features/chatbot/presentation/page/chatbot_v2_page.dart';
import 'package:nyore/features/main/presentation/page/main_page.dart';
import 'package:nyore/features/mlkit/presentation/page/text_recognition_page.dart';
import 'package:nyore/features/stt_openai/presentation/page/stt_openai_page.dart';

Map<String, Widget Function(BuildContext)> appRoutes = {
  Routes.root: (context) => const MainPage(),
  Routes.askGemini: (context) => const AskGeminiPage(),
  Routes.sttOpenAI: (context) => const SttOpenAiPage(),
  Routes.chatbot: (context) => const ChatbotPage(),
  Routes.chatbotV2: (context) => const ChatbotV2Page(),
  Routes.chefAgent: (context) => const ChefAgentPage(),
  Routes.textRecognition: (context) => const TextRecognitionPage(),
};
