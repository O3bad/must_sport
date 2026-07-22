import 'package:flutter/material.dart';
import '../services/cache_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _isArabic = false;

  bool get isDarkMode => _isDarkMode;
  bool get isArabic => _isArabic;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  Locale get locale => _isArabic ? const Locale('ar') : const Locale('en');

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _isDarkMode = CacheService.instance.savedTheme == 'dark';
    _isArabic = CacheService.instance.savedLocale == 'ar';
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await CacheService.instance.saveTheme(_isDarkMode ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _isArabic = !_isArabic;
    await CacheService.instance.saveLocale(_isArabic ? 'ar' : 'en');
    notifyListeners();
  }
}
