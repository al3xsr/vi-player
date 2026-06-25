import 'dart:ui';
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData.light();
ThemeData darkTheme = ThemeData.dark();

class ThemeProvider extends ChangeNotifier {
  bool isPlatformDark =
      PlatformDispatcher.instance.platformBrightness == Brightness.dark;

  ThemeData get initTheme => isPlatformDark ? darkTheme : lightTheme;

  void toggleTheme() {
    isPlatformDark = !isPlatformDark;
    notifyListeners();
  }

  // force a specific value
  void setTheme({required bool isDark}) {
    isPlatformDark = isDark;
    notifyListeners();
  }
}
