import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/common/logger.dart';
import 'package:flutter_mac/common/pair.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/reply_type.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/preference/app_preference.dart';
import 'package:flutter_mac/services/Image_utils.dart';
import 'package:flutter_mac/services/database.dart';
import 'package:flutter_mac/services/storage.dart';
import 'package:flutter_mac/services/utils.dart';
import 'package:giphy_get/giphy_get.dart';

class ChatViewModel {
  final _messageStreamProvidor = StreamController<List<MessageV2>>();
  final _viewStateStreamProvidor = StreamController<ViewState>();
  final _messageControllerStreamProvidor = StreamController<bool>();
  final _scrollStreamProvidor = StreamController<bool>();
  final _messageLoaderProvidor = StreamController<bool>();
  final _toastStreamController = StreamController<String>();
  final _audioPlayer = AudioPlayer();

  final _newMessageProvidor = StreamController<bool>();
  final _onlineProvidor = StreamController<bool>();
  final _replyProvidor = StreamController<ReplyType?>();
  final _messageList = <MessageV2>[];
  late DatabaseService _dbService;
  late StorageService _storageService;
  late ImageUtils _imageUtils;
  late StreamSubscription<List<MessageV2>> _messageStreamSubscription;

  UserCred userCred;
  UserProfile userProfile;
  int _count = 0;
  final _messageSet = HashSet<String>();
  var _viewState = ViewState.viewVisible;

  final String _soundPref;

  ChatViewModel(this.userCred, this.userProfile, ImagePreference imagePref,
      this._soundPref) {
    _dbService = DatabaseService(uid: userCred.uid);
    _imageUtils = ImageUtils(pref: imagePref);
    _storageService = StorageService(uid: userCred.uid);

    _messageStreamProvidor.add(_messageList);
    _viewStateStreamProvidor.add(_viewState);
    _scrollStreamProvidor.add(false);
    _messageControllerStreamProvidor.add(false);
    _messageLoaderProvidor.add(false);
    _newMessageProvidor.add(false);
    _onlineProvidor.add(false);
  }

  void init() {
    // _dbService.getOnlineStatus(userProfile.uid).listen((online) {
    //   _onlineProvidor.add(online);
    // });
  }

  Stream<List<MessageV2>> get messageStream => _messageStreamProvidor.stream;
  Stream<ViewState> get viewStateStream => _viewStateStreamProvidor.stream;
  Stream<bool> get messageControllerStream =>
      _messageControllerStreamProvidor.stream;
  Stream<bool> get scrollStream => _scrollStreamProvidor.stream;
  Stream<bool> get messageLoaderStream => _messageLoaderProvidor.stream;
  Stream<bool> get newMessageStream => _newMessageProvidor.stream;
  Stream<bool> get onlineStream => _onlineProvidor.stream;
  get replyStream => _replyProvidor.stream;

  getMessages() {
    _viewState = ViewState.loading;
    _viewStateStreamProvidor.add(_viewState);
    _messageStreamSubscription = _dbService.messages.listen((list) async {
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
        if (_viewState != ViewState.viewVisible) {
          _viewState = ViewState.viewVisible;
          _viewStateStreamProvidor.add(ViewState.viewVisible);
        }
        if (list.isNotEmpty && _count != 0 && !list.first.isMe!) {
          _newMessageProvidor.add(true);
          await _audioPlayer.stop();
          await _audioPlayer.play(AssetSource(_soundPref));
        } else {
          _newMessageProvidor.add(false);
        }
        if (list.isNotEmpty && (list.first.isMe! || _count == 0)) {
          if (_count == 0) _count++;
          _scrollStreamProvidor.add(true);
        }
      } catch (e, s) {
        log("getMessages() - $e \n $s");
      }
    });
  }

  //Method to fetch the old messages.
  //Getting the old messages from fireStore and placing the null item in the _messageList
  //Null item causes the loadingIndicator to appear in the list.
  //loading var is also added to if condition to stop the listener from calling firebase multiple times.
  getOldMessages(double pixels, double maxScrollExtent) async {
    if (pixels == maxScrollExtent && !_dbService.loading) {
      _messageLoaderProvidor.add(true);
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
      }
      _messageLoaderProvidor.add(false);
    }
  }

  void sendMessage(String text, ReplyType? reply) async {
    if (text.isNotEmpty) {
      _messageControllerStreamProvidor.add(true);
      await _dbService.sendMessage(
          msg: text.trim(),
          isLinktext: TextUtils.checkLinks(text.trim()),
          reply: reply);
      setReplyMessage(null);
    }
  }

  void popUpMenuAction(
      int? value, BuildContext context, ReplyType? reply) async {
    if (value != null) {
      if (value == 1) {
        GiphyGif? gif = await GiphyGet.getGif(
            context: context, //Required
            apiKey: KeyConstants.giphyApiKey,
            tabColor: Colors.teal,
            debounceTimeInMilliseconds: 350,
            showEmojis: false);
        if (gif != null &&
            gif.images != null &&
            gif.images!.fixedHeightDownsampled != null) {
          if (gif.type == 'gif') {
            _dbService.sendGIF(
                url: gif.images!.fixedHeightDownsampled!.url, reply: reply);
            setReplyMessage(null);
          } else if (gif.type == 'sticker') {
            _dbService.sendSticker(
                url: gif.images!.fixedHeightDownsampled!.url, reply: reply);
            setReplyMessage(null);
          }
        }
      } else {
        _messageLoaderProvidor.add(true);
        Pair<File?, ImageStatus?> imageFile = await _imageUtils.pickImage(null);
        if (imageFile.second != null) {
          switch (imageFile.second) {
            case ImageStatus.IMAGE_SIZE_OVERLOAD:
              _toastStreamController.add(StringConstants.useSmallerImage);
              break;
            case ImageStatus.IMAGE_PICKER_NULL:
              _toastStreamController
                  .add('Error picking the image, please try again');
              break;
            case ImageStatus.IMAGE_PICKER_EXCEPTION:
              _toastStreamController
                  .add('Error picking the image, please try again');
              break;
            case ImageStatus.IMAGE_COMPRESSION_NULL:
              break;
            case ImageStatus.IMAGE_COMPRESSION_EXCEPTION:
              break;
            case null:
              break;
          }
        } else {
          var downloadUrl = await _storageService
              .uploadImage(imageFile.first, null)
              .onError((e, s) {
            Logger.print("File upload error - $e\n$s");
            _messageLoaderProvidor.add(false);
            _toastStreamController
                .add('Error uploading the image, Please try after some time');
            return null;
          });
          if (downloadUrl != null) {
            _dbService.sendImage(url: downloadUrl, reply: reply);
            setReplyMessage(null);
            _messageControllerStreamProvidor.add(true);
          }
        }
        _messageLoaderProvidor.add(false);
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

  setOnlineStatus(bool online) async {
    // await _dbService.setOnlineStatus(online);
  }

  void dispose() {
    _messageStreamProvidor.close();
    _viewStateStreamProvidor.close();
    _messageControllerStreamProvidor.close();
    _scrollStreamProvidor.close();
    _messageLoaderProvidor.close();
    _newMessageProvidor.close();
    _onlineProvidor.close();
    _messageStreamSubscription.cancel();
    _replyProvidor.close();
  }

  void setReplyMessage(MessageV2? msg) {
    _replyProvidor.add(msg == null
        ? null
        : ReplyType(
            messageType: msg.messageType,
            id: msg.id.toString(),
            timestamp: msg.timestamp,
            value: (msg.messageType == MessageType.TEXT ||
                    msg.messageType == MessageType.LINK_TEXT)
                ? (msg.msg!.length > PrefenceConstants.maxCharReplyObject)
                    ? '${msg.msg!.substring(0, PrefenceConstants.maxCharReplyObject)}...'
                    : msg.msg.toString()
                : msg.url.toString(),
            uid: msg.uid.toString(),
            isMe: msg.isMe!));
  }

  onReplyClicked(MessageV2 msg) {
    final index =
        _messageList.lastIndexWhere((element) => element.id == msg.reply!.id);
    if (index == -1) {
      Logger.print('Index - Nope');
    } else {
      Logger.print('Index - $index');
    }
  }
}
