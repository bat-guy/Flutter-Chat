import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/common/logger.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/navigator.dart';
import 'package:flutter_mac/preference/app_preference.dart';
import 'package:flutter_mac/preference/shared_preference.dart';
import 'package:flutter_mac/screens/chat/message.dart';

import 'package:flutter_mac/viewmodel/chat_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatScreen extends StatefulWidget {
  final UserCred userCred;
  final UserProfile userProfile;

  const ChatScreen(
      {super.key, required this.userCred, required this.userProfile});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  late ViewState _viewState;
  late ScrollController _scrollController;
  late ChatViewModel _chatViewModel;
  bool _emojiShowing = false;
  final FocusNode _focus = FocusNode();
  var _keyboardVisible = false;
  var _messageLoaderVisible = false;
  var _newMessage = false;
  var _online = true;
  final _pref = AppPreference();
  AppColorPref _colorsPref = AppColorPref();
  MessagePref _messagePref = MessagePref();

  @override
  initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _getColorsPref();
    _viewState = ViewState.loading;
    _scrollController = ScrollController();
    setViewModel();
    _focus.addListener(_onFocusChange);
  }

  void setViewModel() async {
    final imagePref = await _pref.getImagePref();
    final soundPref = await _pref.getMessageSound();
    _chatViewModel = ChatViewModel(
        widget.userCred, widget.userProfile, imagePref, soundPref);
    _chatViewModel.init();
    _chatViewModel.scrollStream.listen((event) {
      if (event) {
        _scrollToBottom();
      }
    });
    _chatViewModel.viewStateStream.listen((state) {
      Logger.print("View State - $state");
      _viewState = state;
    });
    _chatViewModel.messageControllerStream.listen((state) {
      if (state) _messageController.clear();
    });
    _chatViewModel.messageLoaderStream.listen((isVisible) {
      Logger.print("isVisible - $isVisible");
      if (mounted) setState(() => _messageLoaderVisible = isVisible);
    });
    _chatViewModel.newMessageStream.listen((isVisible) {
      if (mounted) setState(() => _newMessage = isVisible);
    });
    // _chatViewModel.onlineStream.listen((online) {
    //   if (mounted) setState(() => _online = online);
    // });

    _chatViewModel.getMessages();
    _scrollController.addListener(_scrollListener);
    _chatViewModel.setOnlineStatus(true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        _chatViewModel.setOnlineStatus(true);
        break;
      case AppLifecycleState.paused:
        _chatViewModel.setOnlineStatus(false);
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
    _chatViewModel.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return WillPopScope(
        onWillPop: () => _onBackButtonPressed(),
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: _colorsPref.appBarColor,
              title: Text(widget.userProfile.name),
              actions: [
                Image(
                  image: AssetImage(AssetsConstants.dot),
                  color: _online
                      ? Colors.green
                      : const Color.fromARGB(255, 232, 98, 88),
                  width: 25,
                  height: 25,
                ),
                IconButton(
                    onPressed: () => ScreenNavigator.openProfileScreen(
                        widget.userProfile.uid, false, context),
                    icon: const Icon(Icons.account_circle_rounded)),
              ],
            ),
            body: switch (_viewState) {
              ViewState.loading => const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SpinKitCubeGrid(
                          color: Colors.red,
                        ),
                        Text(
                          'Please wait...',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        )
                      ]),
                ),
              ViewState.viewVisible => Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    tileMode: TileMode.decal,
                    colors: [
                      _colorsPref.appBackgroundColor.first,
                      _colorsPref.appBackgroundColor.second
                    ],
                  )),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black12,
                                  ),
                                  child: StreamBuilder(
                                      stream: _chatViewModel.messageStream,
                                      builder: (context, snapshot) =>
                                          _setListWidget(
                                              snapshot, _messagePref)),
                                ),
                                Visibility(
                                  visible: _messageLoaderVisible,
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    height: 50,
                                    width: 50,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                    ),
                                    child: const SpinKitRing(
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Visibility(
                              visible: _newMessage,
                              child: Container(
                                  margin: const EdgeInsets.all(5),
                                  child: FloatingActionButton(
                                    backgroundColor: Colors.amber,
                                    onPressed: () {
                                      _scrollToBottom();
                                      setState(() => _newMessage = false);
                                    },
                                    child:
                                        const Icon(Icons.arrow_downward_sharp),
                                  )),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.white70,
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.emoji_emotions_outlined),
                              onPressed: () => setState(() {
                                if (!_emojiShowing) _focus.unfocus();
                                _emojiShowing = !_emojiShowing;
                              }),
                            ),
                            Expanded(
                              child: TextField(
                                minLines: 1,
                                maxLines: 5,
                                focusNode: _focus,
                                controller: _messageController,
                                decoration: InputDecoration(
                                    labelText: StringConstants.typeMessage,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never),
                                textInputAction: TextInputAction.go,
                                onSubmitted: (value) =>
                                    _chatViewModel.sendMessage(
                                        _messageController.text.trim()),
                              ),
                            ),
                            GestureDetector(
                              child: const Icon(Icons.attach_file),
                              onTapDown: (TapDownDetails details) async {
                                _showPopupMenu(details.globalPosition);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () => _chatViewModel
                                  .sendMessage(_messageController.text.trim()),
                            ),
                          ],
                        ),
                      ),
                      Offstage(
                        offstage: !_emojiShowing,
                        child: SizedBox(
                            height: 250,
                            child: EmojiPicker(
                              textEditingController: _messageController,
                              onBackspacePressed: _onBackspacePressed,
                              config: Config(
                                columns: 7,
                                // Issue: https://github.com/flutter/flutter/issues/28894
                                emojiSizeMax: 32 *
                                    (foundation.defaultTargetPlatform ==
                                            TargetPlatform.macOS
                                        ? 1.30
                                        : 1.0),

                                initCategory: Category.RECENT,
                                bgColor: const Color(0xFFF2F2F2),
                                indicatorColor: Colors.blue,
                                iconColor: Colors.grey,
                                iconColorSelected: Colors.blue,
                                backspaceColor: Colors.blue,
                                skinToneDialogBgColor: Colors.white,
                                skinToneIndicatorColor: Colors.grey,
                                enableSkinTones: true,
                                recentTabBehavior: RecentTabBehavior.RECENT,
                                recentsLimit: 28,
                                replaceEmojiOnLimitExceed: false,
                                noRecents: const Text(
                                  'No Recents',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black26),
                                  textAlign: TextAlign.center,
                                ),
                                loadingIndicator: const SizedBox.shrink(),
                                tabIndicatorAnimDuration: kTabScrollDuration,
                                categoryIcons: const CategoryIcons(),
                                buttonMode: ButtonMode.CUPERTINO,
                                checkPlatformCompatibility: true,
                              ),
                            )),
                      ),
                    ],
                  ),
                )
            }));
  }

  _getColorsPref() async {
    var a = await _pref.getAppColorPref();
    var b = await _pref.getMessagePref();
    setState(() {
      _colorsPref = a;
      _messagePref = b;
    });
  }

  void _scrollListener() async {
    _chatViewModel.getOldMessages(_scrollController.position.pixels,
        _scrollController.position.maxScrollExtent);
    if (_newMessage &&
        _scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
      setState(() {
        _newMessage = false;
      });
    }
  }

  _onBackspacePressed() {
    _messageController
      ..text = _messageController.text.characters.toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length));
  }

  void _onFocusChange() {
    setState(() {
      if (_focus.hasFocus) _emojiShowing = false;
      _keyboardVisible = _focus.hasFocus;
    });
  }

  Widget _setListWidget(
      AsyncSnapshot<List<MessageV2>> snapshot, MessagePref pref) {
    return (snapshot.hasData && snapshot.data != null)
        ? ListView.builder(
            itemCount: snapshot.data!.length,
            controller: _scrollController,
            reverse: true,
            itemBuilder: (context, index) {
              return MessageWidget(
                  msg: snapshot.data![index], messagePref: pref);
            })
        : const Center(child: Text('No data...'));
  }

  //Method called when the back button of the device is presed.
  Future<bool> _onBackButtonPressed() async {
    if (_keyboardVisible) {
      _focus.unfocus();
      _keyboardVisible = false;
      return false;
    } else if (_emojiShowing) {
      setState(() => _emojiShowing = false);
      return false;
    }
    return true;
  }

  void _showPopupMenu(Offset offset) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx + 30, offset.dy + 30, 0, 0),
      items: [
        const PopupMenuItem(value: 1, child: Text("Gif")),
        const PopupMenuItem(value: 2, child: Text("Image")),
      ],
      elevation: 8.0,
    ).then((value) async {
      _chatViewModel.popUpMenuAction(value, context);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeIn,
      );
    }
  }
}
