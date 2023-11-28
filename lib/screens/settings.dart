import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/common/logger.dart';
import 'package:flutter_mac/common/pair.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/message_preference.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/preference/app_preference.dart';
import 'package:flutter_mac/preference/shared_preference.dart';
import 'package:flutter_mac/screens/chat/message.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  final _pref = AppPreference();
  var _valueChanged = false;
  final _fontSizeList = <Pair<String, int>>[];
  final _audioPlayer = AudioPlayer();

  AppColorPref _colorsPref = AppColorPref();
  MessagePref _messagePref = MessagePref();
  var _messageSound;

  @override
  void initState() {
    super.initState();
    _getPref();

    for (var i = 10; i <= 30; i++) {
      _fontSizeList.add(Pair(i.toString(), i));
    }
  }

  _getPref() async {
    var a = await _pref.getAppColorPref();
    var b = await _pref.getMessagePref();
    var c = await _pref.getMessageSound();
    setState(() {
      _colorsPref = a;
      _messagePref = b;
      _messageSound = c;
      Logger.print('Message Sound - $c');
    });
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
          title: const Text('Settings'),
          backgroundColor: _colorsPref.appBarColor,
        ),
        body: Container(
          height: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.mirror,
              colors: [
                _colorsPref.appBackgroundColor.first,
                _colorsPref.appBackgroundColor.second
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _getRowContainer(
                    _getDropDownView('Message Sound: ', _messageSound,
                        AssetsConstants.soundArray, (e) async {
                      await _audioPlayer.stop();
                      await _audioPlayer.play(AssetSource(e));
                      await _pref.setMessageSound(e);
                      _getPref();
                      _valueChanged = true;
                    }),
                    Colors.teal),
                _getRowContainer(
                    Column(children: [
                      _getColorRow(
                          type: 'AppBar Color :',
                          color: _colorsPref.appBarColor,
                          singleColorCallback: (c) {
                            _pref.setAppBarColor(c);
                            _getPref();
                            _valueChanged = true;
                          }),
                      const SizedBox(height: 10),
                      _getColorRow(
                          type: 'Background Color :',
                          colorPair: _colorsPref.appBackgroundColor,
                          colorPairCallback: (c) async {
                            await _pref.setAppBackgroundColor(c);
                            _getPref();
                            _valueChanged = true;
                          }),
                    ]),
                    Colors.blue),
                _getRowContainer(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _getColorRow(
                          type: 'Sender Text Color:',
                          color: _messagePref.senderTextColor,
                          singleColorCallback: (c) {
                            _pref.setMessageColorPreference(
                                MessageColorPreference.senderTextColor, c);
                            _getPref();
                            _valueChanged = true;
                          },
                        ),
                        const SizedBox(height: 5),
                        _getColorRow(
                          type: 'Sender Background Color:',
                          color: _messagePref.senderBackgroundColor,
                          singleColorCallback: (c) {
                            _pref.setMessageColorPreference(
                                MessageColorPreference.senderBackgroundColor,
                                c);
                            _getPref();
                            _valueChanged = true;
                          },
                        ),
                        const SizedBox(height: 5),
                        _getColorRow(
                          type: 'Reciever Text Color:',
                          color: _messagePref.receiverTextColor,
                          singleColorCallback: (c) {
                            _pref.setMessageColorPreference(
                                MessageColorPreference.receiverTextColor, c);
                            _getPref();
                            _valueChanged = true;
                          },
                        ),
                        const SizedBox(height: 5),
                        _getColorRow(
                          type: 'Reciever Background Color:',
                          color: _messagePref.receiverBackgroundColor,
                          singleColorCallback: (c) {
                            _pref.setMessageColorPreference(
                                MessageColorPreference.receiverBackgroundColor,
                                c);
                            _getPref();
                            _valueChanged = true;
                          },
                        ),
                        const SizedBox(height: 5),
                        _getColorRow(
                          type: 'Sender Time Color:',
                          color: _messagePref.senderTimeColor,
                          singleColorCallback: (c) {
                            _pref.setMessageColorPreference(
                                MessageColorPreference.senderTimeColor, c);
                            _getPref();
                            _valueChanged = true;
                          },
                        ),
                        const SizedBox(height: 5),
                        _getColorRow(
                          type: 'Receiver Time Color:',
                          color: _messagePref.receiverTimeColor,
                          singleColorCallback: (c) {
                            _pref.setMessageColorPreference(
                                MessageColorPreference.receiverTimeColor, c);
                            _getPref();
                            _valueChanged = true;
                          },
                        ),
                        const SizedBox(height: 5),
                        _getColorRow(
                          type: 'Date Background Color:',
                          color: _messagePref.dateBackgroundColor,
                          singleColorCallback: (c) {
                            _pref.setMessageColorPreference(
                                MessageColorPreference.dateBackgroundColor, c);
                            _getPref();
                            _valueChanged = true;
                          },
                        ),
                        const SizedBox(height: 5),
                        _getColorRow(
                          type: 'Date Text Color:',
                          color: _messagePref.dateTextColor,
                          singleColorCallback: (c) {
                            _pref.setMessageColorPreference(
                                MessageColorPreference.dateTextColor, c);
                            _getPref();
                            _valueChanged = true;
                          },
                        ),
                        const SizedBox(height: 5),
                        _getDropDownView('Date Text Size:',
                            _messagePref.dateTextSize, _fontSizeList, (value) {
                          _pref.setMessageTimePreference(
                              MessageSizePreference.dateTextSize,
                              (value as Pair<String, int>).second.toInt());
                          _getPref();
                          _valueChanged = true;
                        }),
                        const SizedBox(height: 5),
                        _getDropDownView(
                            'Message Text Size:',
                            _messagePref.messageTextSize,
                            _fontSizeList, (value) {
                          _pref.setMessageTimePreference(
                              MessageSizePreference.messageTextSize,
                              (value as Pair<String, int>).second.toInt());
                          _getPref();
                          _valueChanged = true;
                        }),
                        const SizedBox(height: 5),
                        _getDropDownView(
                            'Message Time Text Size:',
                            _messagePref.messageTimeSize,
                            _fontSizeList, (value) {
                          _pref.setMessageTimePreference(
                              MessageSizePreference.messageTimeSize,
                              (value as Pair<String, int>).second.toInt());
                          _getPref();
                          _valueChanged = true;
                        }),
                        MessageWidget(
                          msg: MessageV2(
                            timestamp: 1699591493533,
                            messageType: MessageType.DATE,
                          ),
                          messagePref: _messagePref,
                        ),
                        MessageWidget(
                          msg: MessageV2(
                            timestamp: 1699591493533,
                            messageType: MessageType.TEXT,
                            msg: 'Hello',
                            isMe: true,
                          ),
                          messagePref: _messagePref,
                        ),
                        MessageWidget(
                          msg: MessageV2(
                            timestamp: 1699591493533,
                            messageType: MessageType.TEXT,
                            msg: 'Hello',
                            isMe: false,
                          ),
                          messagePref: _messagePref,
                        )
                      ],
                    ),
                    Colors.transparent)
              ],
            ),
          ),
        ),
      ),
    );
  }

  _getColorRow(
      {required String type,
      Color? color,
      Pair<Color, Color>? colorPair,
      Function(Color)? singleColorCallback,
      Function(Pair<Color, Color>)? colorPairCallback}) {
    return Row(
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
        colorPair != null
            ? _getGradientView(colorPair, colorPairCallback!)
            : GestureDetector(
                onTap: () => _showPicker(color!, singleColorCallback!),
                child: Container(
                  height: 20,
                  width: 50,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      border: Border.all(color: Colors.white),
                      color: color),
                ),
              )
      ],
    );
  }

  _getRowContainer(Widget child, Color backgroundColor) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: Colors.white),
            color: backgroundColor),
        child: child);
  }

  _getGradientView(
      Pair<Color, Color> pair, Function(Pair<Color, Color>) callback) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        border: Border.all(color: Colors.white),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(
          onTap: () => _showPicker(
              pair.first, (c) => callback.call(Pair(c, pair.second))),
          child: Container(
            decoration: BoxDecoration(
                color: pair.first,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                )),
            height: 20,
            width: 50,
          ),
        ),
        Container(
          color: Colors.white,
          height: 20,
          width: 1,
        ),
        GestureDetector(
          onTap: () => _showPicker(
              pair.second, (c) => callback.call(Pair(pair.first, c))),
          child: Container(
            decoration: BoxDecoration(
                color: pair.second,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                )),
            height: 20,
            width: 50,
          ),
        ),
      ]),
    );
  }

  _getDropDownView<T>(String label, T value, List<Pair<String, T>> itemList,
      Function(T) callback) {
    return Row(children: [
      Text(
        label,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(width: 20),
      Container(
          padding: const EdgeInsets.only(left: 5),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white),
          child: DropdownButton<T>(
              value: value,
              underline: const SizedBox(),
              items: itemList
                  .map((e) => DropdownMenuItem(
                        value: e.second,
                        child: Text(e.first.toString()),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) callback.call(value);
              }))
    ]);
  }

  _showPicker(Color color, Function(Color) callback) {
    showDialog(
        context: context,
        builder: (ctx) {
          Color pickerColor = color;
          return AlertDialog(
            title: const Text('Pick a color!'),
            backgroundColor: const Color.fromARGB(255, 238, 236, 236),
            content: ColorPicker(
              pickerColor: color,
              onColorChanged: (c) => pickerColor = c,
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Got it'),
                onPressed: () {
                  callback.call(pickerColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
