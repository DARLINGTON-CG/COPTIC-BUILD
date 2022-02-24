import 'dart:collection';

import 'package:copticmeet/services/database/database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

abstract class Messaging {
  Future sendMessage(String timeStamp, String message, String receiverID,
      String imageURL, String key, String mimeType);
  Future getMessageKeysInOrder(String receiverID);
  Future getUsers();
  Future getActiveMessages();
  Future getMessages(String receiverID, String messageKey);
  Stream<Event> usersMessages(String receiverID);
  Future updateLikedNotification(
      String receiverID, String messageKey, String senderID, bool likedMessage);
  Future isMessageLiked(String senderID, String receiverID, String messageKey);
  Future updateReadMessages(
      String receiverID, String messageKey, String senderID, bool likedMessage);
  Future checkIfUnread(String receiverID, String messageKey);
}

class CopticMeetMessaging implements Messaging {
  final String uid;
  final Database database;
  CopticMeetMessaging({@required this.uid, @required this.database})
      : assert(uid != null);

  Stream<Event> usersMessages(String receiverID) {
    final senderID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    final userReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child('users/$senderID/messages/$receiverID/messages/');
    return userReference.onValue;
  }

  Future sendMessage(String timeStamp, String message, String receiverID,
      String imageURL, String key, String mimeType) async {
    final senderID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    final userReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child('users/$senderID/messages/$receiverID/messages/');
    await userReference.update({
      '$key': {
        "message": '$message',
        "imageURL": "$imageURL",
        "time": "$timeStamp",
        "sender": "$senderID",
        "receiverRead": "false",
        "userLiked": "false",
        "messageKey": "$key",
        "mimeType": '$mimeType'
      }
    });
    final receiverReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child('users/$receiverID/messages/$senderID/messages/');
    await receiverReference.update({
      '$key': {
        "message": '$message',
        "imageURL": "$imageURL",
        "time": "$timeStamp",
        "sender": "$senderID",
        "receiverRead": "false",
        "userLiked": "false",
        "messageKey": "$key",
        "mimeType": '$mimeType'
      }
    });
  }

  Future updateLikedNotification(String receiverID, String messageKey,
      String senderID, bool likedMessage) async {
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    if (senderID != uid) {
      receiverID = uid;
    }
    final userReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child('users/$senderID/messages/$receiverID/messages/$messageKey/');
    await userReference.update({"userLiked": "$likedMessage"});
    final receiverReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child('users/$receiverID/messages/$senderID/messages/$messageKey/');
    await receiverReference.update({"userLiked": "$likedMessage"});
  }

  Future isMessageLiked(
      String senderID, String receiverID, String messageKey) async {
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    final userReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child(
            'users/$receiverID/messages/$senderID/messages/$messageKey/userLiked');
    final isMessageLiked = await userReference.once();
    if (isMessageLiked.value == 'true') {
      return true;
    } else {
      return false;
    }
  }

  Future getMessageKeysInOrder(String receiverID) async {
    final senderID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    final userReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child('users')
        .child(senderID)
        .child('messages')
        .child(receiverID)
        .child('messages');
    final receivedMessages = await userReference.once();
    if (receivedMessages.value != 'null') {
      final sorted = new SplayTreeMap<String, dynamic>.from(
          receivedMessages.value,
          (a, b) => receivedMessages.value[a]['time']
              .compareTo(receivedMessages.value[b]['time']));
      return sorted.keys.toList();
    } else {
      return null;
    }
  }

  Future getMessages(String receiverID, String messageKey) async {
    final senderID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    final userReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child('users')
        .child(senderID)
        .child('messages')
        .child(receiverID)
        .child('messages')
        .child(messageKey);
    final receivedMessage = await userReference.once();
    return receivedMessage;
  }

  Future getActiveMessages() async {
    final senderID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    final userReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child('users')
        .child(senderID)
        .child('messages');
    final activeUsers = await userReference.once();

    if (activeUsers.value != 'null') {
      List listOfMatches = activeUsers.value.keys.toList();
      List listActiveMessages = [];
      for (var i = 0; i < listOfMatches.length; i++) {
        if (activeUsers.value[listOfMatches[i]]['messages'] != "null") {
          listActiveMessages.add(listOfMatches[i]);
        }
      }
      return listActiveMessages;
    } else {
      return null;
    }
  }

  Future getUsers() {
    final senderID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    final userReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child('users')
        .child(senderID)
        .child('messages');
    final message = userReference.once();
    return message;
  }

  Future updateReadMessages(String receiverID, String messageKey,
      String senderID, bool likedMessage) async {
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    if (senderID != uid) {
      receiverID = uid;
    }
    final receiverReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child('users/$receiverID/messages/$senderID/messages/$messageKey/');
    await receiverReference.update({"receiverRead": "$likedMessage"});
  }

  Future checkIfUnread(String receiverID, String messageKey) async {
    final senderID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    final receiverReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child(
            'users/$receiverID/messages/$senderID/messages/$messageKey/receiverRead');
    final data = await receiverReference.once();
    return data;
  }
}
