import 'package:flutter/material.dart';
import 'package:nyore/core/navigation/routes.dart';
import 'package:nyore/features/ask_gemini/presentation/page/ask_gemini_page.dart';
import 'package:nyore/features/main/presentation/page/main_page.dart';

Map<String, Widget Function(BuildContext)> appRoutes = {
  Routes.root: (context) => const MainPage(),
  Routes.askGemini: (context) => const AskGeminiPage(),
};
