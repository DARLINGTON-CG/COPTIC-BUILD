import 'dart:async';
import 'dart:io';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/services/messaging/messaging.dart';
import 'package:copticmeet/services/storage/storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessagingBloc {
  MessagingBloc(
      {@required this.userID,
      @required this.database,
      @required this.storage,
      @required this.messaging});
  final String userID;
  final Database database;
  final Storage storage;
  final Messaging messaging;

  final StreamController<List> _messagesInOrder =
      StreamController<List>.broadcast();
  Stream<List> get messagesInOrder => _messagesInOrder.stream;

  final StreamController<File> _fileImagePathController =
      StreamController<File>.broadcast();
  Stream<File> get filePath => _fileImagePathController.stream;

  final StreamController<bool> _disableTextController =
      StreamController<bool>.broadcast();
  Stream<bool> get disabletextController => _disableTextController.stream;

  final StreamController<bool> _uploadingState =
      StreamController<bool>.broadcast();
  Stream<bool> get uploadingState => _uploadingState.stream;

  final StreamController<String> _textField =
      StreamController<String>.broadcast();
  Stream<String> get textFieldHint => _textField.stream;

  final StreamController<bool> _messageTilesIsLoading =
      StreamController<bool>.broadcast();
  Stream<bool> get messageTileIsLoading => _messageTilesIsLoading.stream;

  Stream<List> newMessagesInOrder(String receiverID) async* {
    List _messagesInOrderList =
        await messaging.getMessageKeysInOrder(receiverID);
    List<dynamic> _messageKeysReverse = _messagesInOrderList;
    _messageKeysReverse = _messageKeysReverse.reversed.toList();
    yield _messageKeysReverse;
  }

  void setFilePath(File filePath) => _fileImagePathController.add(filePath);
  void setTextField(bool textFieldStatus) =>
      _disableTextController.add(textFieldStatus);
  void _setUploadingState(bool uploadingState) =>
      _uploadingState.add(uploadingState);
  void setTextFieldHint(String hintText) => _textField.add(hintText);
  void setMessageTileIsLoading(bool isLoading) =>
      _messageTilesIsLoading.add(isLoading);

  Stream<Event> usersMessages(String receiverID, uid) {
    final senderID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    final userReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child('users/$senderID/messages/$receiverID/messages/');
    return userReference.onValue;
  }

  void dispose() {
    _messagesInOrder.close();
    _fileImagePathController.close();
    _uploadingState.close();
    _textField.close();
  }

  Future sendMessage(
      String timeStamp,
      String message,
      String receiverID,
      String imageName,
      String key,
      String mimeType,
      BuildContext context,
      File file) async {
    if (mimeType == '') {
      if (message != '') {
        messaging.sendMessage(timeStamp, message, receiverID, '', key, '');
      } else {
        return true;
      }
    } else {
      var imageURL = await uploadImageReturnUrl(context, file, imageName);
      messaging.sendMessage(
          timeStamp, message, receiverID, imageURL, key, mimeType);
    }
    return false;
  }

  Future sendGIF(
      String timeStamp,
      String message,
      String receiverID,
      String key,
      String mimeType,
      BuildContext context,
      String imageURL) async {
    messaging.sendMessage(
        timeStamp, message, receiverID, imageURL, key, 'image');
  }

  Future getPictureSize(file) async {
    var decodedImage = await decodeImageFromList(file.readAsBytesSync());
    return decodedImage;
  }

  Future getMessageKeysInOrder(String receiverID) async {
    List _messagesInOrderList =
        await messaging.getMessageKeysInOrder(receiverID);
    _messagesInOrder.add(_messagesInOrderList);
  }

  Future updateLikedNotification(String receiverID, String messageKey,
      String senderID, bool likedMessage) async {
    messaging.updateLikedNotification(
        receiverID, messageKey, senderID, likedMessage);
  }

  Future getMessages(String receiverID, String messageKey) async {
    var messages = await messaging.getMessages(receiverID, messageKey);
    return messages;
  }

  Future updateReadMessages(receiverID, senderID) async {
    List messageKeysList = await messaging.getMessageKeysInOrder(receiverID);
    for (var i = 0; i < messageKeysList.length; i++) {
      messaging.updateReadMessages(
          receiverID, messageKeysList[i], senderID, true);
    }
  }

  Future getLatestSenderMessage(List latestMessageKey, String receiverID,
      Map<dynamic, dynamic> allMessages) async {
    var latestSenderMessageKey;
    for (var i = 0; i < latestMessageKey.length; i++) {
      if (allMessages[latestMessageKey[i]]['sender'] == receiverID) {
        latestSenderMessageKey = latestMessageKey[i];
        break;
      }
    }
    return latestSenderMessageKey;
  }

  Future getImage(ImageSource source) {
    var _image = ImagePicker.pickImage(source: source);
    return _image;
  }

  Future uploadImageReturnUrl(
      BuildContext context, File file, String fileName) async {
    var storageBucket = await database.getSpecificUserValues('imageBucket');
    Reference storageReference =
        FirebaseStorage(storageBucket: storageBucket.value)
            .ref()
            .child('chatImages/$fileName');
    UploadTask uploadTask = storageReference.putFile(file);
    _setUploadingState(true);
    await uploadTask;
    Reference downloadReference =
        FirebaseStorage(storageBucket: storageBucket.value)
            .ref()
            .child('chatImages/$fileName');
    String downloadURL = await downloadReference.getDownloadURL();

    setTextFieldHint('Enter message');
    setTextField(true);
    _setUploadingState(false);
    return downloadURL;
  }

  Future<String> messageTile(
      Map<dynamic, dynamic> message, receiverID, String name) async {
    if (message['sender'] != receiverID) {
      if (message['imageURL'] != '') {
        if (message['mimeType'] == 'image') {
          return 'You: sent an image';
        } else if (message['mimeType'] == 'video') {
          return 'You: sent a video';
        }
      } else {
        return 'You: ${message['message']}';
      }
    } else {
      if (message['imageURL'] != '') {
        if (message['mimeType'] == 'image') {
          return '$name sent an image';
        } else if (message['mimeType'] == 'video') {
          return '$name sent a video';
        }
      } else {
        return '${message['message']}';
      }
    }
  }

  Future<bool> checkLatestMessage(
      Map<dynamic, dynamic> message, String receiverID) async {
    if (message['sender'] == receiverID) {
      var check =
          await messaging.checkIfUnread(receiverID, message['messageKey']);
      if (check.value != 'false') {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }
}
