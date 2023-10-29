import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/screens/chat/message.dart';
import 'package:flutter_mac/services/auth_service.dart';

import 'package:flutter_mac/viewmodel/chat_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatScreen extends StatefulWidget {
  final String uid;

  ChatScreen({super.key, required this.uid});

  final AuthService _auth = AuthService();

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late ViewState _viewState;
  late ScrollController _scrollController;
  late ChatViewModel _chatViewModel;
  bool _emojiShowing = false;
  final FocusNode _focus = FocusNode();
  var _keyboardVisible = false;
  var _messageLoaderVisible = false;

  @override
  initState() {
    super.initState();
    _viewState = ViewState.viewVisible;
    _scrollController = ScrollController();
    _chatViewModel = ChatViewModel(uid: widget.uid);
    _focus.addListener(_onFocusChange);

    _chatViewModel.scrollStream.listen((event) {
      if (event) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
    _chatViewModel.viewStateStream.listen((state) {
      _viewState = state;
    });
    _chatViewModel.messageControllerStream.listen((state) {
      if (state) _messageController.clear();
    });
    _chatViewModel.messageLoaderStream.listen((isVisible) {
      setState(() => _messageLoaderVisible = isVisible);
    });

    _chatViewModel.getMessages();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return WillPopScope(
        onWillPop: () async {
          return _onBackButtonPressed();
        },
        child: Scaffold(
            appBar: AppBar(
              leading: GestureDetector(
                child: const Icon(Icons.account_circle_rounded),
                onTap: () {},
              ),
              leadingWidth: 100, // default is 56
              title: const Text('Chat Room'),
              actions: [
                IconButton.filled(
                    onPressed: () {
                      widget._auth.signOut();
                    },
                    icon: const Icon(Icons.logout)),
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
                          'Uploading Photo. Please wait...',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        )
                      ]),
                ),
              ViewState.viewVisible => Column(
                  children: <Widget>[
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.black12,
                            ),
                            child: StreamBuilder(
                                stream: _chatViewModel.messageStream,
                                builder: (context, snapshot) =>
                                    _setListWidget(snapshot)),
                          ),
                          Visibility(
                              visible: false,
                              child: SpinKitCircle(
                                color: Colors.red,
                              ))
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8.0),
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
                              textInputAction: TextInputAction.done,
                              onSubmitted: (value) => _chatViewModel
                                  .sendMessage(_messageController.text.trim()),
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
                                          TargetPlatform.iOS
                                      ? 1.30
                                      : 1.0),
                              verticalSpacing: 0,
                              horizontalSpacing: 0,
                              gridPadding: EdgeInsets.zero,
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
            }));
  }

  //Getting the old messages from fireStore and placing the null item in the _messageList
  //Null item causes the loadingIndicator to appear in the list.
  //loading var is also added to if condition to stop the listener from calling firebase multiple times.
  void _scrollListener() async {
    _chatViewModel.getOldMessages(_scrollController.position.pixels,
        _scrollController.position.maxScrollExtent);
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

  Widget _setListWidget(AsyncSnapshot<List<MessageV2>> snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      return ListView.builder(
          itemCount: snapshot.data!.length,
          controller: _scrollController,
          reverse: true,
          itemBuilder: (context, index) {
            return MessageWidget(msg: snapshot.data![index]);
          });
    } else {
      return Center(child: Text('No data...'));
    }
  }

  //Method called when the back button of the device is presed.
  _onBackButtonPressed() async {
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
}
