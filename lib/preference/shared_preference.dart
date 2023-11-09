import 'package:flutter/material.dart';
import 'package:flutter_mac/preference/app_color_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreference {
  final _appBarColor = 'appBarColor';
  final _primaryBackgroundColor = 'primaryBackgroundColor';
  final _secondaryBackgroundColor = 'secondaryBackgroundColor';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  getAppColorPref() async {
    final SharedPreferences prefs = await _prefs;
    return AppColorPref(Color(prefs.getInt(_appBarColor) ?? Colors.red.value), [
      Color(prefs.getInt(_primaryBackgroundColor) ?? Colors.red.value),
      Color(prefs.getInt(_secondaryBackgroundColor) ?? Colors.blue.value)
    ]);
  }

  setAppBarColor(Color color) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt(_appBarColor, color.value);
  }

  setBackgroundColor(List<Color> color) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt(_primaryBackgroundColor, color[0].value);
    await prefs.setInt(_secondaryBackgroundColor, color[1].value);
  }
}
