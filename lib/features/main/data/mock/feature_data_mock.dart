import 'dart:convert';

import 'package:nyore/features/main/data/model/feature_model.dart';

// Example JSON data mock
const String featureDataJson = '''
[
  {
    "id": 1,
    "name": "Ask Gemini",
    "description": "Fitur ini adalah semacam prompting yang ter-integrasi dengan Gemini AI",
    "isActive": true,
    "pathRoute": "/ask-gemini"
  },
  {
    "id": 2,
    "name": "Speech AI",
    "description": "Fitur ini adalah semacam Speech to Text dan Text to Speech yang ter-integrasi dengan Gemini AI",
    "isActive": true,
    "pathRoute": "/stt-openai"
  },
  {
    "id": 3,
    "name": "Chatbot",
    "description": "Fitur chatbot yang ter-integrasi dengan Gemini AI",
    "isActive": true,
    "pathRoute": "/chatbot-v2"
  },
  {
    "id": 4,
    "name": "Juru Masak Agent",
    "description": "Chatbot khusus untuk membantu dalam memasak",
    "isActive": true,
    "pathRoute": "/chef-agent"
  }
]
''';

// Parse the JSON and return a list of FeatureModel
List<FeatureModel> getMockFeatures() {
  final List data = json.decode(featureDataJson);
  return data.map((json) => FeatureModel.fromJson(json)).toList();
}
