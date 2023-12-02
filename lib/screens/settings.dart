import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/common/pair.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/preference/app_preference.dart';
import 'package:flutter_mac/screens/chat/message.dart';
import 'package:flutter_mac/viewmodel/settings_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  final String uid;

  const SettingsScreen({super.key, required this.uid});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  var _valueChanged = false;
  final _fontSizeList = <Pair<String, int>>[];
  final _audioPlayer = AudioPlayer();

  AppColorPref _colorsPref = AppColorPref();
  MessagePref _messagePref = MessagePref();
  late SettingsViewModel _viewModel;

  var _messageSound;
  var _loading = false;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel(widget.uid);
    _viewModel.loading.listen((e) => setState(() => _loading = e));
    _viewModel.appColorPref.listen((e) => setState(() => _colorsPref = e));
    _viewModel.messagePref.listen((e) => setState(() => _messagePref = e));
    _viewModel.messageSound.listen((e) => setState(() => _messageSound = e));

    for (var i = 10; i <= 30; i++) {
      _fontSizeList.add(Pair(i.toString(), i));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.dispose();
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
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _getRowContainer(
                        _getDropDownView('Message Sound: ', _messageSound,
                            AssetsConstants.soundArray, (e) async {
                          await _audioPlayer.stop();
                          await _audioPlayer.play(AssetSource(e));
                          setState(() => _messageSound = e);
                          _valueChanged = true;
                        }),
                        Colors.teal),
                    _getRowContainer(
                        Column(children: [
                          _getColorRow(
                              type: 'AppBar Color :',
                              color: _colorsPref.appBarColor,
                              singleColorCallback: (c) {
                                setState(() => _colorsPref.appBarColor = c);
                                _valueChanged = true;
                              }),
                          const SizedBox(height: 10),
                          _getColorRow(
                              type: 'Background Color :',
                              colorPair: _colorsPref.appBackgroundColor,
                              colorPairCallback: (c) async {
                                setState(
                                    () => _colorsPref.appBackgroundColor = c);
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
                                setState(
                                    () => _messagePref.senderTextColor = c);
                                _valueChanged = true;
                              },
                            ),
                            const SizedBox(height: 5),
                            _getColorRow(
                              type: 'Sender Background Color:',
                              color: _messagePref.senderBackgroundColor,
                              singleColorCallback: (c) {
                                setState(() =>
                                    _messagePref.senderBackgroundColor = c);
                                _valueChanged = true;
                              },
                            ),
                            const SizedBox(height: 5),
                            _getColorRow(
                              type: 'Reciever Text Color:',
                              color: _messagePref.receiverTextColor,
                              singleColorCallback: (c) {
                                setState(
                                    () => _messagePref.receiverTextColor = c);
                                _valueChanged = true;
                              },
                            ),
                            const SizedBox(height: 5),
                            _getColorRow(
                              type: 'Reciever Background Color:',
                              color: _messagePref.receiverBackgroundColor,
                              singleColorCallback: (c) {
                                setState(() =>
                                    _messagePref.receiverBackgroundColor = c);
                                _valueChanged = true;
                              },
                            ),
                            const SizedBox(height: 5),
                            _getColorRow(
                              type: 'Sender Time Color:',
                              color: _messagePref.senderTimeColor,
                              singleColorCallback: (c) {
                                setState(
                                    () => _messagePref.senderTimeColor = c);
                                _valueChanged = true;
                              },
                            ),
                            const SizedBox(height: 5),
                            _getColorRow(
                              type: 'Receiver Time Color:',
                              color: _messagePref.receiverTimeColor,
                              singleColorCallback: (c) {
                                setState(
                                    () => _messagePref.receiverTimeColor = c);
                                _valueChanged = true;
                              },
                            ),
                            const SizedBox(height: 5),
                            _getColorRow(
                              type: 'Date Background Color:',
                              color: _messagePref.dateBackgroundColor,
                              singleColorCallback: (c) {
                                setState(
                                    () => _messagePref.dateBackgroundColor = c);
                                _valueChanged = true;
                              },
                            ),
                            const SizedBox(height: 5),
                            _getColorRow(
                              type: 'Date Text Color:',
                              color: _messagePref.dateTextColor,
                              singleColorCallback: (c) {
                                setState(() => _messagePref.dateTextColor = c);
                                _valueChanged = true;
                              },
                            ),
                            const SizedBox(height: 5),
                            _getDropDownView(
                                'Date Text Size:',
                                _messagePref.dateTextSize,
                                _fontSizeList, (value) {
                              setState(() => _messagePref.dateTextSize = value);
                              _valueChanged = true;
                            }),
                            const SizedBox(height: 5),
                            _getDropDownView(
                                'Message Text Size:',
                                _messagePref.messageTextSize,
                                _fontSizeList, (value) {
                              setState(
                                  () => _messagePref.messageTextSize = value);
                              _valueChanged = true;
                            }),
                            const SizedBox(height: 5),
                            _getDropDownView(
                                'Message Time Text Size:',
                                _messagePref.messageTimeSize,
                                _fontSizeList, (value) {
                              setState(
                                  () => _messagePref.messageTimeSize = value);
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
                        Colors.transparent),
                    const SizedBox(height: 80)
                  ],
                ),
              ),
              TextButton(
                onPressed: () => savePref(context),
                child: Container(
                  height: 50,
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.cyan,
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: Text(
                    'Save',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Visibility(
                  visible: _loading,
                  child: const SpinKitDualRing(
                    color: Colors.red,
                    size: 100,
                  ))
            ],
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

  savePref(BuildContext context) async {
    if (_valueChanged) {
      await _viewModel.savePreference(_messagePref, _colorsPref, _messageSound);
      if (mounted) Navigator.pop(context, _valueChanged);
    }
  }
}
