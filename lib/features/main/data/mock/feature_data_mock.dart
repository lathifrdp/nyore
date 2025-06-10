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
    "name": "Speech to Text X OpenAI",
    "description": "Fitur ini adalah semacam Speech to Text yang ter-integrasi dengan OpenAI",
    "isActive": true,
    "pathRoute": "/stt-openai"
  }
]
''';

// Parse the JSON and return a list of FeatureModel
List<FeatureModel> getMockFeatures() {
  final List data = json.decode(featureDataJson);
  return data.map((json) => FeatureModel.fromJson(json)).toList();
}
