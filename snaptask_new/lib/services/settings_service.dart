import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static SettingsService? _instance;
  static SettingsService get instance {
    _instance ??= SettingsService._();
    return _instance!;
  }

  SettingsService._();

  String _language = 'English';
  double _textSize = 1.0;
  double _iconSize = 1.0;

  String get language => _language;
  double get textSize => _textSize;
  double get iconSize => _iconSize;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('language') ?? 'English';
    _textSize = prefs.getDouble('textSize') ?? 1.0;
    _iconSize = prefs.getDouble('iconSize') ?? 1.0;
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    notifyListeners();
  }

  Future<void> updateTextSize(double size) async {
    _textSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textSize', size);
    notifyListeners();
  }

  Future<void> updateIconSize(double size) async {
    _iconSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('iconSize', size);
    notifyListeners();
  }

  // Helper methods for dynamic sizing
  double getScaledTextSize(double baseSize) => baseSize * _textSize;
  double getScaledIconSize(double baseSize) => baseSize * _iconSize;

  TextStyle getTextStyle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize != null ? getScaledTextSize(fontSize) : null,
      color: color,
      fontWeight: fontWeight,
      decoration: decoration,
    );
  }

  IconThemeData getIconTheme({
    Color? color,
    double? size,
  }) {
    return IconThemeData(
      color: color,
      size: size != null ? getScaledIconSize(size) : null,
    );
  }
} 