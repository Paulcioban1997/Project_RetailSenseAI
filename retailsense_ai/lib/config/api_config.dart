import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _localInferenceFromEnv = String.fromEnvironment(
    'USE_LOCAL_INFERENCE',
    defaultValue: 'true',
  );

  static const String _apiFromEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static bool get useLocalInference {
    if (kIsWeb) return false;
    return _localInferenceFromEnv.toLowerCase() != 'false';
  }

  static String get baseUrl {
    if (_apiFromEnv.isNotEmpty) {
      return _apiFromEnv;
    }

    if (kIsWeb) {
      return 'https://project-retailsenseai.onrender.com';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 fonctionne juste pour l'émulateur Android, mais pas pour un appareil physique. Pour un appareil physique, utilisez l'adresse IP de votre machine de développement.
      return 'http://10.0.0.131:8000';
    }

    return 'http://127.0.0.1:8000';
  }
}