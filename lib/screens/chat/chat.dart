import 'package:flutter/material.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/state.dart';
import 'package:flutter_mac/screens/chat/message.dart';
import 'package:flutter_mac/screens/profile/profile.dart';
import 'package:flutter_mac/services/auth_service.dart';
import 'package:flutter_mac/services/database.dart';
import 'package:flutter_mac/services/storage.dart';
import 'package:flutter_mac/services/utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giphy_get/giphy_get.dart';

class ChatScreen extends StatefulWidget {
  final String uid;

  ChatScreen({super.key, required this.uid});

  final AuthService _auth = AuthService();

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  late ChatUtils _chatUtils;
  late DatabaseService _dbService;
  late StorageService _storageService;
  late ViewState _viewState;
  late ScrollController _scrollController;
  var messageList = <Message?>[];
  var count = 0;

  @override
  initState() {
    super.initState();
    _viewState = ViewState.viewVisible;
    _scrollController = ScrollController();
    _chatUtils = ChatUtils(uid: widget.uid);
    _dbService = DatabaseService(uid: widget.uid);
    _storageService = StorageService(uid: widget.uid);
    _dbService.messages.listen((list) {
      if (messageList.isEmpty) {
        messageList.insertAll(0, list);
      } else {
        if (messageList.contains(null)) messageList.remove(null);
        for (int i = 0; i < list.length - 1; i++) {
          if (messageList[i]!.id != list[i].id) messageList.insert(0, list[i]);
        }
      }
      setState(() {
        if (count == 0) messageList.add(null);
        _viewState = ViewState.viewVisible;
        if (list.isNotEmpty && (list.first.isMe || count == 0)) {
          if (count == 0) count++;
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      });
      _scrollController.addListener(_scrollListener);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //Getting the old messages from fireStore and placing the null item in the messageList
  //Null item causes the loadingIndicator to appear in the list.
  //loading var is also added to if condition to stop the listener from calling firebase multiple times.
  void _scrollListener() async {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_dbService.loading) {
      final list = await _dbService.getOldMessageListSnapshot();
      if (list != null && list.isNotEmpty) {
        if (messageList.contains(null)) messageList.remove(null);
        // messageList.addAll(list);
        int j = messageList.length - 1;
        for (int i = 0; i < list.length; i++) {
          if (messageList[j]!.id != list[i].id) messageList.add(list[i]);
          j--;
        }
        setState(() => messageList.add(null));
      } else {
        setState(() {
          if (messageList.contains(null)) messageList.remove(null);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            child: Icon(Icons.account_circle_rounded),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfileScreen())),
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
                      'Upload Photo. Please wait...',
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
                        itemCount: messageList.length,
                        controller: _scrollController,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return MessageWidget(msg: messageList[index]);
                        }),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                              labelText: StringConstants.typeMessage),
                          textInputAction: TextInputAction.search,
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
                      )
                    ],
                  ),
                ),
              ],
            ),
        });
  }

  void _sendMessage(ScrollController controller) {
    if (messageController.text.isNotEmpty) {
      _dbService.sendMessage(
        msg: messageController.text,
        name: 'name',
        uid: widget.uid,
      );
      messageController.clear();
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
        } else {
          var imageFile = await _chatUtils.pickImage();
          setState(() => _viewState = ViewState.loading);
          var downloadUrl = await _storageService.uploadImage(imageFile);
          setState(() => _viewState = ViewState.viewVisible);
          if (downloadUrl != null) {
            _dbService.sendMessage(imageUrl: downloadUrl, uid: widget.uid);
            messageController.clear();
          }
        }
      }
    });
  }
}
