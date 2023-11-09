import 'package:flutter/material.dart';
import 'package:flutter_mac/common/constants.dart';

class AppColorPref {
  Color appBarColor = AppColors.appRed;
  List<Color> backgroundColor = [Colors.red, Colors.blue];

  AppColorPref(Color? appBarColor, List<Color>? backgroundColor) {
    this.appBarColor = appBarColor ?? AppColors.appRed;
    this.backgroundColor = backgroundColor ?? [Colors.red, Colors.blue];
  }
}
