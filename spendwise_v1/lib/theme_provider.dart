import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'hive_constants.dart';

class ThemeProvider extends ChangeNotifier {
  Box get _box => Hive.box(HiveConstants.settingsBox);

  ThemeMode get themeMode {
    final isDark = _box.get('isDark', defaultValue: false) as bool;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark => themeMode == ThemeMode.dark;

  void toggleTheme() {
    _box.put('isDark', !isDark);
    notifyListeners();
  }
}
