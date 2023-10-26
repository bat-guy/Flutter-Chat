import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/screens/chat/message.dart';
import 'package:flutter_mac/screens/profile/profile.dart';
import 'package:flutter_mac/services/auth_service.dart';
import 'package:flutter_mac/services/database.dart';
import 'package:flutter_mac/services/storage.dart';
import 'package:flutter_mac/services/utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giphy_get/giphy_get.dart';
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
  late ChatUtils _chatUtils;
  late DatabaseService _dbService;
  late StorageService _storageService;
  late ViewState _viewState;
  late ScrollController _scrollController;
  final _messageList = <MessageV2?>[];
  var _count = 0;
  bool _emojiShowing = false;
  final FocusNode _focus = FocusNode();
  var _keyboardVisible = false;

  @override
  initState() {
    super.initState();
    _viewState = ViewState.viewVisible;
    _scrollController = ScrollController();
    _chatUtils = ChatUtils(uid: widget.uid);
    _dbService = DatabaseService(uid: widget.uid);
    _storageService = StorageService(uid: widget.uid);
    _focus.addListener(_onFocusChange);
    try {
      _dbService.messages.listen((list) {
        if (_messageList.isEmpty) {
          _messageList.insertAll(0, list);
        } else {
          if (_messageList.contains(null)) _messageList.remove(null);
          for (int i = 0; i < list.length - 1; i++) {
            if (_messageList[i]!.id != list[i].id)
              _messageList.insert(0, list[i]);
          }
        }
        setState(() {
          if (_count == 0) _messageList.add(null);
          _viewState = ViewState.viewVisible;
          if (list.isNotEmpty && (list.first.isMe || _count == 0)) {
            if (_count == 0) _count++;
            _scrollController.animateTo(
              _scrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          }
        });
        _scrollController.addListener(_scrollListener);
      });
    } catch (e, s) {
      print(s);
    }
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
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => const ProfileScreen()));
                },
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
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black12,
                        ),
                        child: ListView.builder(
                            itemCount: _messageList.length,
                            controller: _scrollController,
                            reverse: true,
                            itemBuilder: (context, index) {
                              return MessageWidget(msg: _messageList[index]);
                            }),
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
                              onSubmitted: (value) =>
                                  _sendMessage(_scrollController),
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
                            onPressed: () => _sendMessage(_scrollController),
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
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_dbService.loading) {
      final list = await _dbService.getOldMessageListSnapshot();
      if (list != null && list.isNotEmpty) {
        if (_messageList.contains(null)) _messageList.remove(null);
        // _messageList.addAll(list);
        int j = _messageList.length - 1;
        for (int i = 0; i < list.length; i++) {
          if (_messageList[j]!.id != list[i].id) _messageList.add(list[i]);
          j--;
        }
        setState(() => _messageList.add(null));
      } else {
        setState(() {
          if (_messageList.contains(null)) _messageList.remove(null);
        });
      }
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
    });
  }

  //Method called when the back button of the device is presed.
  _onBackButtonPressed() async {
    if (_keyboardVisible) {
      _focus.unfocus();
      return false;
    } else if (_emojiShowing) {
      setState(() => _emojiShowing = false);
      return false;
    }
    return true;
  }

  void _sendMessage(ScrollController controller) async {
    if (_messageController.text.isNotEmpty) {
      await _dbService.sendMessage(msg: _messageController.text);
      _messageController.clear();
    }
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
      if (value != null) {
        if (value == 1) {
          GiphyGif? gif = await GiphyGet.getGif(
            context: context, //Required
            apiKey: KeyConstants.giphyApiKey,
            tabColor: Colors.teal,
            debounceTimeInMilliseconds: 350,
          );
          if (gif != null &&
              gif.images != null &&
              gif.images!.fixedHeightDownsampled != null) {
            if (gif.type == 'gif') {
              _dbService.sendGIF(url: gif.images!.fixedHeightDownsampled!.url);
            } else if (gif.type == 'sticker') {
              _dbService.sendSticker(
                  url: gif.images!.fixedHeightDownsampled!.url);
            }
          }
        } else {
          File? imageFile = await _chatUtils.pickImage();
          setState(() => _viewState = ViewState.loading);
          var downloadUrl = await _storageService.uploadImage(imageFile);
          setState(() => _viewState = ViewState.viewVisible);
          if (downloadUrl != null) {
            _dbService.sendImage(url: downloadUrl);
            _messageController.clear();
          }
        }
      }
    });
  }
}
