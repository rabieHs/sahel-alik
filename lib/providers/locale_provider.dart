import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar'); // Default to Arabic
  
  Locale get locale => _locale;
  
  // Initialize locale from shared preferences
  Future<void> initLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String languageCode = prefs.getString('languageCode') ?? 'ar';
    _locale = Locale(languageCode);
    notifyListeners();
  }
  
  // Set locale and save to shared preferences
  Future<void> setLocale(Locale locale) async {
    if (locale == _locale) return;
    
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners();
  }
  
  // Toggle between Arabic and English
  Future<void> toggleLocale() async {
    final newLocale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await setLocale(newLocale);
  }
}
