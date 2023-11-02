import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/services/database.dart';
import 'package:flutter_mac/services/storage.dart';
import 'package:flutter_mac/services/utils.dart';
import 'package:giphy_get/giphy_get.dart';

class ChatViewModel {
  late Stream<List<MessageV2>> messageStream;
  final StreamController<List<MessageV2>> _messageStreamProvidor =
      StreamController();
  late Stream<ViewState> viewStateStream;
  final StreamController<ViewState> _viewStateStreamProvidor =
      StreamController();
  late Stream<bool> messageControllerStream;
  final StreamController<bool> _messageControllerStreamProvidor =
      StreamController();
  late Stream<bool> scrollStream;
  final StreamController<bool> _scrollStreamProvidor = StreamController();
  late Stream<bool> messageLoaderStream;
  final StreamController<bool> _messageLoaderProvidor = StreamController();
  final _messageList = <MessageV2>[];
  late DatabaseService _dbService;
  late StorageService _storageService;
  late ChatUtils _chatUtils;

  String uid;
  int _count = 0;
  final _messageSet = HashSet<String>();

  ChatViewModel({required this.uid}) {
    _dbService = DatabaseService(uid: uid);
    _chatUtils = ChatUtils(uid: uid);
    _storageService = StorageService(uid: uid);

    messageStream = _messageStreamProvidor.stream;
    _messageStreamProvidor.add(_messageList);
    viewStateStream = _viewStateStreamProvidor.stream;
    _viewStateStreamProvidor.add(ViewState.viewVisible);
    scrollStream = _scrollStreamProvidor.stream;
    _scrollStreamProvidor.add(false);
    messageControllerStream = _messageControllerStreamProvidor.stream;
    _messageControllerStreamProvidor.add(false);
    messageLoaderStream = _messageLoaderProvidor.stream;
    _messageLoaderProvidor.add(_dbService.loading);
  }

  getMessages() {
    _dbService.messages.listen((list) {
      try {
        var tempList = <MessageV2>[];
        for (var e in list) {
          if (!_messageSet.contains(e.id)) {
            tempList.add(e);
            if (e.id != null) {
              _messageSet.add(e.id!);
            }
          }
        }

        tempList.addAll(_messageList);
        _messageList.clear();
        _messageList.addAll(_parseMessageListForDate(tempList));

        _messageStreamProvidor.add(_messageList);
        _viewStateStreamProvidor.add(ViewState.viewVisible);
        if (list.isNotEmpty && (list.first.isMe! || _count == 0)) {
          if (_count == 0) _count++;
          _scrollStreamProvidor.add(true);
        }
      } catch (e) {
        print(e);
      }
    });
  }

  //Method to fetch the old messages.
  getOldMessages(double pixels, double maxScrollExtent) async {
    if (pixels == maxScrollExtent && !_dbService.loading) {
      _messageLoaderProvidor.add(_dbService.loading);
      final list = await _dbService.getOldMessageListSnapshot();
      var tempList = <MessageV2>[];
      if (list != null && list.isNotEmpty) {
        for (var i = 0; i <= list.length - 1; i++) {
          final e = list[i];
          if (!_messageSet.contains(e.id)) {
            tempList.add(e);
            if (e.id != null) {
              _messageSet.add(e.id!);
            }
          }
        }

        tempList.insertAll(0, _messageList);
        _messageList.clear();
        _messageList.addAll(_parseMessageListForDate(tempList));

        _messageStreamProvidor.add(_messageList);
        _messageLoaderProvidor.add(_dbService.loading);
      }
    }
  }

  void sendMessage(String text) async {
    if (text.isNotEmpty) {
      _messageControllerStreamProvidor.add(true);
      await _dbService.sendMessage(msg: text.trim());
    }
  }

  void popUpMenuAction(int? value, BuildContext context) async {
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
        _viewStateStreamProvidor.add(ViewState.loading);
        var downloadUrl = await _storageService.uploadImage(imageFile);
        _viewStateStreamProvidor.add(ViewState.viewVisible);
        if (downloadUrl != null) {
          _dbService.sendImage(url: downloadUrl);
          _messageControllerStreamProvidor.add(true);
        }
      }
    }
  }

  _parseMessageListForDate(List<MessageV2> list) {
    var tempList = <MessageV2>[];
    MessageV2? prevItem;
    for (var e in list.reversed) {
      if (e.messageType != MessageType.DATE) {
        if (prevItem == null ||
            DateTimeUtils.isDifferentDay(prevItem.timestamp, e.timestamp)) {
          final item =
              MessageV2(timestamp: e.timestamp, messageType: MessageType.DATE);
          tempList.add(item);
        }
        tempList.add(e);
        prevItem = e;
      }
    }
    return tempList.reversed;
  }
}
