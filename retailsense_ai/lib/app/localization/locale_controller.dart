import 'package:flutter/material.dart';

class LocaleController extends ChangeNotifier {
  LocaleController._();

  static final LocaleController instance = LocaleController._();

  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode.toUpperCase();

  void setLanguageCode(String code) {
    final next = Locale(code.toLowerCase());
    if (_locale == next) {
      return;
    }
    _locale = next;
    notifyListeners();
  }
}