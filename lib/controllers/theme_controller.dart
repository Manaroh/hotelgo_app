import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contrôleur responsable du thème clair/sombre.
///
/// Il utilise ChangeNotifier pour informer toute l'application
/// quand l'utilisateur active ou désactive le mode sombre.
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._internal();

  ThemeController._internal();

  static const String _keyThemeMode = 'themeMode';

  ThemeMode _themeMode = ThemeMode.light;

  /// Thème actuellement utilisé par l'application.
  ThemeMode get themeMode => _themeMode;

  /// Indique si le mode sombre est actif.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Charge le thème sauvegardé localement.
  ///
  /// Cette méthode est appelée au démarrage de l'application pour conserver
  /// le choix de l'utilisateur.
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_keyThemeMode);

    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    notifyListeners();
  }

  /// Change le thème de l'application et sauvegarde le choix localement.
  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    await prefs.setString(
      _keyThemeMode,
      isDark ? 'dark' : 'light',
    );

    notifyListeners();
  }
}