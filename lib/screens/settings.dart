import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/preference/app_color_preference.dart';
import 'package:flutter_mac/preference/shared_preference.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  final _pref = AppPreference();
  var _valueChanged = false;

  AppColorPref _colorsPref = AppColorPref(null, null);

  @override
  void initState() {
    super.initState();
    _getColorsPref();
  }

  _getColorsPref() async {
    var a = await _pref.getAppColorPref();
    setState(() => _colorsPref = a);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, _valueChanged);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: _colorsPref.appBarColor,
          ),
          body: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                tileMode: TileMode.mirror,
                colors: _colorsPref.backgroundColor,
              ),
            ),
            child: Column(
              children: [
                _getColorRow('AppBar Color :', [_colorsPref.appBarColor], (c) {
                  setState(() => _colorsPref.appBarColor = c[0]);
                  _pref.setAppBarColor(c[0]);
                  _valueChanged = true;
                }, false),
                _getColorRow(
                  'Background Color :',
                  _colorsPref.backgroundColor,
                  (List<Color> c) => setState(() {
                    _colorsPref.backgroundColor = c;
                    _pref.setBackgroundColor(c);
                    _valueChanged = true;
                  }),
                  true,
                )
              ],
            ),
          ),
        ));
  }

  Container _getColorRow(String type, List<Color> color,
      Function(List<Color>) callback, bool twoColors) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.white),
          color: Colors.amber),
      child: Row(
        children: [
          Text(
            type,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 20),
          twoColors
              ? _getGradientView(color, callback)
              : GestureDetector(
                  onTap: () => _showPicker(color[0], callback),
                  child: Container(
                    height: 20,
                    width: 50,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(5),
                        ),
                        border: Border.all(color: Colors.white),
                        color: color[0]),
                  ),
                )
        ],
      ),
    );
  }

  _getGradientView(List<Color> list, Function(List<Color>) callback) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        border: Border.all(color: Colors.white),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(
          onTap: () =>
              _showPicker(list[0], (c) => callback.call([c[0], list[1]])),
          child: Container(
            color: list[0],
            height: 20,
            width: 50,
          ),
        ),
        GestureDetector(
          onTap: () =>
              _showPicker(list[1], (c) => callback.call([list[0], c[0]])),
          child: Container(
            color: list[1],
            height: 20,
            width: 50,
          ),
        ),
      ]),
    );
  }

  _showPicker(Color color, Function(List<Color>) callback) {
    showDialog(
        context: context,
        builder: (ctx) {
          Color pickerColor = color;
          return AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.hardEdge,
              child: ColorPicker(
                pickerColor: color,
                onColorChanged: (c) => pickerColor = c,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Got it'),
                onPressed: () {
                  callback.call([pickerColor]);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
