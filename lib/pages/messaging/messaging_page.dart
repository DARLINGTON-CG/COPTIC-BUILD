import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:blur/blur.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:copticmeet/custom_icons/coptic_meet_icons_icons.dart';
import 'package:copticmeet/services/BLoCs/content_modelation/image_moderation.dart';
import 'package:copticmeet/services/BLoCs/messaging/messaging_bloc.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/services/location/location.dart';
import 'package:copticmeet/services/messaging/messaging.dart';
import 'package:copticmeet/services/storage/storage.dart';
import 'package:copticmeet/utils/color_utils.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

class MessagingPage extends StatefulWidget {
  MessagingPage(
      {Key key,
      @required this.database,
      @required this.storage,
      @required this.userID,
      @required this.bloc,
      @required this.location})
      : super(key: key);
  final Database database;
  final Storage storage;
  final Location location;
  final userID;
  final MessagingBloc bloc;

  static Widget create(BuildContext context, Database database, Storage storage,
      String userID, Messaging messaging, Location location) {
    return Provider<MessagingBloc>(
      create: (_) => MessagingBloc(
          database: database,
          storage: storage,
          messaging: messaging,
          userID: userID),
      dispose: (context, bloc) => bloc.dispose(),
      child: Consumer<MessagingBloc>(
        builder: (BuildContext context, bloc, _) => MessagingPage(
          bloc: bloc,
          database: database,
          storage: storage,
          userID: userID,
          location: location,
        ),
      ),
    );
  }

  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  @override
  Widget build(BuildContext context) {
    var messaging = Provider.of<Messaging>(context, listen: false);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            elevation: 0.0,
            title: Text('Matches',style:TextStyle(
                fontFamily: "Papyrus",
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              )),
            centerTitle:true,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ],
                  begin: const FractionalOffset(1.0, 0.0),
                  end: const FractionalOffset(0.0, 0.7),
                  stops: [0.3, 1.0],
                  tileMode: TileMode.clamp)),
          child: StreamBuilder(
              stream: widget.database.getUserData,
              builder: (context, snapshot) {
                return FutureBuilder(
                    future: widget.database.getAllUsersData(),
                    builder: (BuildContext context, allData) {
                      if (allData.hasData) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  FutureBuilder(
                                      future: widget.database
                                          .getActiveMatchesNumber(),
                                      builder:
                                          (BuildContext context, matchUserID) {
                                        if (matchUserID.hasData) {
                                          var jsonList = jsonDecode(
                                              matchUserID.data.value);
                                          if (jsonList?.length != 0) {
                                            var matches = List.generate(
                                                jsonList?.length, (index) {
                                              return FutureBuilder(
                                                  future: widget.storage
                                                      .getUserProfilePictures(
                                                          widget.database,
                                                          jsonList[index]),
                                                  builder:
                                                      (BuildContext context,
                                                          imageURL) {
                                                    if (imageURL.hasData) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          widget.database
                                                              .updateNewMatches(
                                                                  jsonList[
                                                                      index]);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => UserChatPage.create(
                                                                    context,
                                                                    jsonList[
                                                                        index],
                                                                    allData.data
                                                                            .value[jsonList[index]]
                                                                        [
                                                                        'name'],
                                                                    widget
                                                                        .userID,
                                                                    imageURL.data[
                                                                        0],
                                                                    widget
                                                                        .database,
                                                                    widget
                                                                        .storage,
                                                                    messaging,
                                                                    widget
                                                                        .location)),
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            width: 100,
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                // CircleAvatar(
                                                                //   radius: 30,
                                                                //   backgroundImage:
                                                                //       CachedNetworkImageProvider(
                                                                //     '${imageURL.data[0]}',
                                                                //   ),
                                                                // ),
                                                                Container(
                                                                  width: 65,
                                                                  height: 65,
                                                                  child: Card(
                                                                    elevation:
                                                                        2,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      side: BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            30.0),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Container(
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(30),
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          imageUrl: imageURL.data.length == 0
                                                                              ? ""
                                                                              : "${imageURL.data[0]}",
                                                                          placeholder: (context, url) =>
                                                                              Container(
                                                                            height:
                                                                                5,
                                                                            width:
                                                                                5,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              backgroundColor: Theme.of(context).primaryColor,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                          errorWidget: (context, string, dynamics) =>
                                                                              Icon(Icons.people),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    '${allData.data.value[jsonList[index]]['name']}',
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .body2,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      return GestureDetector(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            width: 100,
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                CircleAvatar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  radius: 30,
                                                                  child: Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                    backgroundColor:
                                                                        Theme.of(context)
                                                                            .primaryColor,
                                                                    color: Colors
                                                                        .white,
                                                                  )),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    '${allData.data.value[jsonList[index]]['name']}',
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .body2,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  });
                                            });
                                            return SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: matches),
                                            );
                                          } else {
                                            return Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    9,
                                                child: Center(
                                                    child: Text(
                                                  'No matches, start swiping to get matches!',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .body2,
                                                )));
                                          }
                                        } else {
                                          return Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  9,
                                              child: Center(
                                                  child: Text(
                                                'No matches, start swiping to get matches!',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body2,
                                              )));
                                        }
                                      })
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('Messages'),
                                  Container(
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    child: FutureBuilder(
                                        future: messaging.getActiveMessages(),
                                        builder: (BuildContext context,
                                            activeMessages) {
                                          if (activeMessages.hasData) {
                                            var listOfMessages = List.generate(
                                                activeMessages.data.length,
                                                (index) {
                                              return StreamBuilder(
                                                  stream: widget.bloc
                                                      .newMessagesInOrder(
                                                          activeMessages
                                                              .data[index]),
                                                  //future: messaging.getMessageKeysInOrder(activeMessages.data[index]),
                                                  builder:
                                                      (BuildContext context,
                                                          messageKeys) {
                                                    if (messageKeys.hasData) {
                                                      if (messageKeys.data !=
                                                          null) {
                                                        var latestMessage =
                                                            messageKeys.data[0];
                                                        return FutureBuilder(
                                                            future: widget.bloc
                                                                .getMessages(
                                                                    activeMessages
                                                                            .data[
                                                                        index],
                                                                    latestMessage),
                                                            builder: (BuildContext
                                                                    context,
                                                                messageData) {
                                                              if (messageData
                                                                  .hasData) {
                                                                return FutureBuilder(
                                                                    future: widget
                                                                        .storage
                                                                        .getUserProfilePictures(
                                                                            widget
                                                                                .database,
                                                                            activeMessages.data[
                                                                                index]),
                                                                    builder: (BuildContext
                                                                            context,
                                                                        imageURL) {
                                                                      if (imageURL
                                                                          .hasData) {
                                                                        var messageSent = DateTime.parse(messageData
                                                                            .data
                                                                            .value['time']);
                                                                        var formattedMessage = timeago.format(
                                                                            messageSent,
                                                                            locale:
                                                                                'en_short');
                                                                        return ListTile(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => UserChatPage.create(context, activeMessages.data[index], allData.data.value[activeMessages.data[index]]['name'], widget.userID, imageURL.data[0], widget.database, widget.storage, messaging, widget.location)),
                                                                            );
                                                                          },
                                                                          leading:
                                                                              //     CircleAvatar(
                                                                              //   radius:
                                                                              //       25,
                                                                              //   backgroundImage:
                                                                              //       CachedNetworkImageProvider(
                                                                              //     '${imageURL.data[0]}',
                                                                              //   ),
                                                                              // ),
                                                                              Container(
                                                                            width:
                                                                                60,
                                                                            height:
                                                                                60,
                                                                            child:
                                                                                Card(
                                                                              elevation: 2,
                                                                              shape: RoundedRectangleBorder(
                                                                                side: BorderSide(color: Colors.grey),
                                                                                borderRadius: const BorderRadius.all(
                                                                                  Radius.circular(140.0),
                                                                                ),
                                                                              ),
                                                                              child: Container(
                                                                                child: ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(140),
                                                                                  child: CachedNetworkImage(
                                                                                    fit: BoxFit.cover,
                                                                                    imageUrl: imageURL.data.length == 0 ? "" : "${imageURL.data[0]}",
                                                                                    placeholder: (context, url) => Container(
                                                                                      height: 5,
                                                                                      width: 5,
                                                                                      child: CircularProgressIndicator(
                                                                                        backgroundColor: Theme.of(context).primaryColor,
                                                                                        color: Colors.white,
                                                                                      ),
                                                                                    ),
                                                                                    errorWidget: (context, string, dynamics) => Icon(Icons.people),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          title: FutureBuilder<bool>(
                                                                              future: widget.bloc.checkLatestMessage(messageData.data.value, activeMessages.data[index]),
                                                                              builder: (context, unread) {
                                                                                if (unread.hasData) {
                                                                                  return Text(
                                                                                    '${allData.data.value[activeMessages.data[index]]['name']}',
                                                                                    style: TextStyle(fontFamily: "Papyrus", fontWeight: !unread.data ? FontWeight.normal : FontWeight.bold, fontSize: 20),
                                                                                  );
                                                                                } else {
                                                                                  return Text(
                                                                                    '${allData.data.value[activeMessages.data[index]]['name']}',
                                                                                    style: TextStyle(fontFamily: "Papyrus", fontWeight: FontWeight.normal, fontSize: 20),
                                                                                  );
                                                                                }
                                                                              }),
                                                                          subtitle: FutureBuilder<bool>(
                                                                              future: widget.bloc.checkLatestMessage(messageData.data.value, '${activeMessages.data[index]}'),
                                                                              builder: (context, unread) {
                                                                                return FutureBuilder<String>(
                                                                                    future: widget.bloc.messageTile(messageData.data.value, '${activeMessages.data[index]}', '${allData.data.value[activeMessages.data[index]]['name']}'),
                                                                                    builder: (context, messageTileText) {
                                                                                      if (unread.hasData) {
                                                                                        return Text(
                                                                                          '${messageTileText.data}',
                                                                                          style: TextStyle(fontFamily: "Papyrus", fontWeight: !unread.data ? FontWeight.normal : FontWeight.bold, fontSize: 12),
                                                                                        );
                                                                                      } else {
                                                                                        return Text(
                                                                                          '${messageTileText.data}',
                                                                                          style: TextStyle(fontFamily: "Papyrus", fontWeight: FontWeight.normal, fontSize: 12),
                                                                                        );
                                                                                      }
                                                                                    });
                                                                              }),
                                                                          trailing: FutureBuilder<bool>(
                                                                              future: widget.bloc.checkLatestMessage(messageData.data.value, activeMessages.data[index]),
                                                                              builder: (context, unread) {
                                                                                if (unread.hasData) {
                                                                                  return Text(
                                                                                    '$formattedMessage',
                                                                                    style: TextStyle(fontFamily: "Papyrus", fontWeight: !unread.data ? FontWeight.normal : FontWeight.bold, fontSize: 14),
                                                                                  );
                                                                                } else {
                                                                                  return Text(
                                                                                    '$formattedMessage',
                                                                                    style: TextStyle(fontFamily: "Papyrus", fontWeight: FontWeight.normal, fontSize: 14),
                                                                                  );
                                                                                }
                                                                              }),
                                                                        );
                                                                      } else {
                                                                        var messageSent = DateTime.parse(messageData
                                                                            .data
                                                                            .value['time']);
                                                                        var formattedMessage = timeago.format(
                                                                            messageSent,
                                                                            locale:
                                                                                'en_short');
                                                                        return ListTile(
                                                                          leading:
                                                                              CircularProgressIndicator(
                                                                            backgroundColor:
                                                                                Theme.of(context).primaryColor,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                          title: FutureBuilder<bool>(
                                                                              future: widget.bloc.checkLatestMessage(messageData.data.value, activeMessages.data[index]),
                                                                              builder: (context, unread) {
                                                                                if (unread.hasData) {
                                                                                  return Text(
                                                                                    '${allData.data.value[activeMessages.data[index]]['name']}',
                                                                                    style: TextStyle(fontFamily: "Papyrus", fontWeight: !unread.data ? FontWeight.normal : FontWeight.bold, fontSize: 20),
                                                                                  );
                                                                                } else {
                                                                                  return Text(
                                                                                    '${allData.data.value[activeMessages.data[index]]['name']}',
                                                                                    style: TextStyle(fontFamily: "Papyrus", fontWeight: FontWeight.normal, fontSize: 20),
                                                                                  );
                                                                                }
                                                                              }),
                                                                          subtitle: FutureBuilder<bool>(
                                                                              future: widget.bloc.checkLatestMessage(messageData.data.value, activeMessages.data[index]),
                                                                              builder: (context, unread) {
                                                                                return FutureBuilder(
                                                                                    future: widget.bloc.messageTile(messageData.data.value, '${activeMessages.data[index]}', '${allData.data.value[activeMessages.data[index]]['name']}'),
                                                                                    builder: (context, messageTileText) {
                                                                                      if (unread.hasData) {
                                                                                        return Text(
                                                                                          '${messageTileText.data}',
                                                                                          style: TextStyle(fontFamily: "Papyrus", fontWeight: !unread.data ? FontWeight.normal : FontWeight.bold, fontSize: 12),
                                                                                        );
                                                                                      } else {
                                                                                        return Text(
                                                                                          '${messageTileText.data}',
                                                                                          style: TextStyle(fontFamily: "Papyrus", fontWeight: FontWeight.normal, fontSize: 12),
                                                                                        );
                                                                                      }
                                                                                    });
                                                                              }),
                                                                          trailing: FutureBuilder<bool>(
                                                                              future: widget.bloc.checkLatestMessage(messageData.data.value, activeMessages.data[index]),
                                                                              builder: (context, unread) {
                                                                                if (unread.hasData) {
                                                                                  return Text(
                                                                                    '$formattedMessage',
                                                                                    style: TextStyle(fontFamily: "Papyrus", fontWeight: !unread.data ? FontWeight.normal : FontWeight.bold, fontSize: 14),
                                                                                  );
                                                                                } else {
                                                                                  return Text(
                                                                                    '$formattedMessage',
                                                                                    style: TextStyle(fontFamily: "Papyrus", fontWeight: FontWeight.normal, fontSize: 14),
                                                                                  );
                                                                                }
                                                                              }),
                                                                        );
                                                                      }
                                                                    });
                                                              } else {
                                                                return Center(
                                                                    child:
                                                                        Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          20.0),
                                                                  child: Text(
                                                                    'No current messages, to send your first message tap on one of your matches above.',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .body2,
                                                                  ),
                                                                ));
                                                              }
                                                            });
                                                      } else {
                                                        return Center(
                                                            child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20.0),
                                                          child: Text(
                                                            'No current messages, to send your first message tap on one of your matches above.',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .body2,
                                                          ),
                                                        ));
                                                      }
                                                    } else {
                                                      return Container();
                                                    }
                                                  });
                                            });
                                            if (activeMessages.data.length >=
                                                1) {
                                              return Column(
                                                  children: listOfMessages);
                                            } else {
                                              return Center(
                                                  child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                                child: Text(
                                                  'No current messages, to send your first message tap on one of your matches above.',
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .body2,
                                                ),
                                              ));
                                            }
                                          } else {
                                            return Center(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Text(
                                                'No current messages, to send your first message tap on one of your matches above.',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body2,
                                              ),
                                            ));
                                          }
                                        }),
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                            child: CircularProgressIndicator(
                          backgroundColor: Theme.of(context).primaryColor,
                          color: Colors.white,
                        ));
                      }
                    });
              }),
        ));
  }
}

class UserChatPageWrapper extends StatefulWidget {
  final Function onInit;
  final Function onDispose;
  final Widget child;

  const UserChatPageWrapper(
      {@required this.onInit, @required this.child, @required this.onDispose});

  @override
  _UserChatPageWrapperState createState() => _UserChatPageWrapperState();
}

class _UserChatPageWrapperState extends State<UserChatPageWrapper> {
  @override
  void initState() {
    if (widget.onInit != null) {
      widget.onInit();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.onDispose != null) {
      widget.onDispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class UserChatPage extends StatelessWidget {
  UserChatPage(
      {Key key,
      @required this.imageURL,
      @required this.receiverID,
      @required this.userID,
      @required this.name,
      @required this.bloc,
      this.database,
      @required this.storage,
      @required this.location})
      : super(key: key);
  final imageURL;
  final receiverID;
  final userID;
  final name;
  final Storage storage;
  final Location location;
  final MessagingBloc bloc;
  final Database database;

  static Widget create(
      BuildContext context,
      receiverID,
      name,
      userID,
      imageURL,
      Database database,
      Storage storage,
      Messaging messaging,
      Location location) {
    return Provider<MessagingBloc>(
      create: (_) => MessagingBloc(
          database: database,
          storage: storage,
          messaging: messaging,
          userID: userID),
      dispose: (context, bloc) => bloc.dispose(),
      child: Consumer<MessagingBloc>(
          builder: (BuildContext context, bloc, _) => UserChatPage(
                bloc: bloc,
                receiverID: receiverID,
                userID: userID,
                imageURL: imageURL,
                name: name,
                database: database,
                storage: storage,
                location: location,
              )),
    );
  }

  static final Random _random = Random.secure();

  static String createCryptoRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }

  File file;

  double _inputHeight = 50;
  final TextEditingController _textEditingController = TextEditingController();

  GlobalKey _bottomBarKey = GlobalKey();
  GlobalKey _pictureKey = GlobalKey();

  VideoPlayerController _videoPlayerController;
  Future<void> _initializeVideoPlayerFuture;

  bool isGIF = false;

  bool allowOffensiveWord = false;

  var gifURL;

  String mimeValue = '';

  Future _getUserLocations() async {
    var location = await database.getSpecificUserValues('location');
    return location;
  }

  final ValueNotifier<double> _bottomBarHeight = ValueNotifier<double>(-1);

  void _checkInputHeight() async {
    int count = _textEditingController.text.split('\n').length;

    if (count == 0 && _inputHeight == 50.0) {
      return;
    }
    if (count <= 5) {
      // use a maximum height of 6 rows
      // height values can be adapted based on the font size
      var newHeight = count == 0 ? 50.0 : 28.0 + (count * 18.0);
      _inputHeight = newHeight;
    }
  }

  Future _chooseFileType(BuildContext context) async {
    String didRequestSignOut;
    await Alert(
            context: context,
            title: "Send a photo",
            desc: "Please choose one of the options below to send a photo.",
            buttons: [
              DialogButton(
                child: Text(
                  "Photo",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                onPressed: () async {
                  didRequestSignOut = 'photo';
                  Navigator.of(context).pop();
                },
                color: Theme.of(context).primaryColor,
              ),
              DialogButton(
                child: Text(
                  "Video",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                onPressed: () async {
                  didRequestSignOut = 'video';
                  Navigator.of(context).pop();
                },
                color: Theme.of(context).primaryColor,
              ),
              DialogButton(
                child: Text(
                  "GIF",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                onPressed: () async {
                  didRequestSignOut = 'gif';
                  Navigator.of(context).pop();
                },
                color: Theme.of(context).primaryColor,
              )
            ],
            closeFunction: () {})
        .show();
    if (didRequestSignOut == 'photo') {
      try {
        file = await FilePicker.getFile(
          type: FileType.image,
        );
        var croppedFile = await ImageCropper.cropImage(
            sourcePath: file.path,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
            androidUiSettings: AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Theme.of(context).primaryColor,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 1.0,
            ));
        file = croppedFile;
        return file;
      } catch (e) {
        print(e);
      }
    } else if (didRequestSignOut == 'video') {
      try {
        file = await FilePicker.getFile(
          type: FileType.video,
        );
        return file;
      } catch (e) {
        print(e);
      }
    } else if (didRequestSignOut == 'gif') {
      mimeValue = 'gif';
      isGIF = true;
      final gif = await GiphyPicker.pickGif(
          context: context, apiKey: 'puAeeIaseO2EthMhdwfzc0yVf8EYNOjK');
      gifURL = gif.images.original.url;
      return '${gif.images.original.url}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserChatPageWrapper(
      onInit: () {
        _textEditingController.addListener(_checkInputHeight);
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            _bottomBarHeight.value = _bottomBarKey.currentContext.size.height);
      },
      onDispose: () {
        _textEditingController.dispose();
        bloc.dispose();
        _videoPlayerController.dispose();
      },
      child: Scaffold(
        backgroundColor: Colors.yellow[100],
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context)),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: <Widget>[
              PopupMenuButton(
                offset: Offset(0, 100),
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    height: 10,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                              context: context,
                              builder: (_) => new AlertDialog(
                                    contentPadding: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0))),
                                    content: Builder(
                                      builder: (context) {
                                        var height =
                                            MediaQuery.of(context).size.height;
                                        var width =
                                            MediaQuery.of(context).size.width;
                                        return SafeArea(
                                          child: Container(
                                            child: Container(
                                              height: height - 250,
                                              width: width - 40,
                                              child: FutureBuilder(
                                                  future: _getUserLocations(),
                                                  builder:
                                                      (BuildContext context,
                                                          userLocations) {
                                                    if (userLocations.hasData) {
                                                      return Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            1.1,
                                                        child: MatchCardPopup(
                                                          storage: storage,
                                                          database: database,
                                                          matchID: receiverID,
                                                          location: location,
                                                          accountLocation:
                                                              userLocations
                                                                  .data.value,
                                                          userID: userID,
                                                          onMessage: () {
                                                            Navigator.push(
                                                                context,
                                                                new MaterialPageRoute(
                                                                    builder: (BuildContext context) => new Provider<
                                                                            Messaging>(
                                                                        create: (_) => CopticMeetMessaging(
                                                                            uid: userID
                                                                                .data,
                                                                            database:
                                                                                database),
                                                                        child: Consumer<
                                                                            Messaging>(builder: (BuildContext
                                                                                context,
                                                                            messaging,
                                                                            _) {
                                                                          return MessagingPage.create(
                                                                              context,
                                                                              database,
                                                                              storage,
                                                                              userID.data,
                                                                              messaging,
                                                                              location);
                                                                        }))));
                                                          },
                                                        ),
                                                      );
                                                    } else {
                                                      return Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                      ));
                                                    }
                                                  }),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.4,
                          child: ListTile(
                            title: Text(
                              'View Profile',
                              style: TextStyle(
                                fontFamily: "Papyrus",
                              ),
                            ),
                            trailing: Icon(Icons.person, color: Colors.black),
                          ),
                        )),
                  ),
                  PopupMenuItem(
                    value: 2,
                    height: 10,
                    child: GestureDetector(
                        onTap: () {
                          database
                              .updateUserDetails({'unmatch': '$receiverID'});
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.4,
                          child: ListTile(
                            title: Text(
                              'Unmatch',
                              style: TextStyle(
                                  fontFamily: "Papyrus",
                                  color: Colors.redAccent),
                            ),
                            trailing: Icon(Icons.undo, color: Colors.redAccent),
                          ),
                        )),
                  ),
                  PopupMenuItem(
                    value: 3,
                    height: 10,
                    child: GestureDetector(
                        onTap: () async {
                          var currentblockedUsers =
                              await database.getSpecificUserValues('blocked');
                          List currentblockedUsersList =
                              await json.decode(currentblockedUsers.value);
                          currentblockedUsersList.add(receiverID);
                          database.updateUserDetails({
                            "blocked": "${json.encode(currentblockedUsersList)}"
                          });
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.4,
                          child: ListTile(
                            title: Text(
                              'Block & Report',
                              style: TextStyle(
                                  fontFamily: "Papyrus",
                                  color: Colors.redAccent),
                            ),
                            trailing:
                                Icon(Icons.block, color: Colors.redAccent),
                          ),
                        )),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: CachedNetworkImageProvider(
                      '$imageURL',
                    ),
                  ),
                ),
              ),
            ],
            title: Text(
              '$name',
              style: Theme.of(context).textTheme.body1,
            )),
        bottomNavigationBar: Transform.translate(
          offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
          child: BottomAppBar(
            key: _bottomBarKey,
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                child: SafeArea(
                    child: StreamBuilder<Object>(
                        stream: bloc.uploadingState,
                        initialData: false,
                        builder: (context, snapshot) {
                          return Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        child: StreamBuilder(
                                            stream: bloc.filePath,
                                            builder: (BuildContext context,
                                                filePath) {
                                              if (filePath.hasData) {
                                                if (mimeValue != 'gif') {
                                                  String mimeType =
                                                      lookupMimeType(
                                                          filePath.data.path);
                                                  List mimeTypeList =
                                                      mimeType.split('/');
                                                  mimeValue = mimeTypeList[0];
                                                }
                                                if (mimeValue == 'image') {
                                                  bloc.setTextFieldHint(
                                                      'Tap arrow to send');
                                                  bloc.setTextField(false);
                                                  return Column(
                                                    children: <Widget>[
                                                      ValueListenableBuilder(
                                                          valueListenable:
                                                              _bottomBarHeight,
                                                          builder: (BuildContext
                                                                  context,
                                                              double height,
                                                              Widget child) {
                                                            return AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      800),
                                                              height: _bottomBarHeight
                                                                          .value ==
                                                                      -1
                                                                  ? 100
                                                                  : _bottomBarHeight
                                                                      .value,
                                                            );
                                                          }),
                                                      Bubble(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12.0),
                                                          child: Stack(
                                                            children: <Widget>[
                                                              Container(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      2,
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  child: Center(
                                                                    child:
                                                                        Container(
                                                                      child: Image
                                                                          .file(
                                                                        filePath
                                                                            .data,
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        key:
                                                                            _pictureKey,
                                                                      ),
                                                                    ),
                                                                  )),
                                                              Container(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    2,
                                                                child: Center(
                                                                  child: FutureBuilder(
                                                                      future: bloc.getPictureSize(file),
                                                                      builder: (BuildContext context, imageData) {
                                                                        if (imageData
                                                                            .hasData) {
                                                                          return snapshot.data
                                                                              ? Opacity(
                                                                                  opacity: 0.6,
                                                                                  child: AspectRatio(
                                                                                    aspectRatio: imageData.data.width / imageData.data.height,
                                                                                    child: Container(
                                                                                      color: Colors.grey,
                                                                                      child: Center(
                                                                                          child: CircularProgressIndicator(
                                                                                        backgroundColor: Theme.of(context).primaryColor,
                                                                                        color: Colors.white,
                                                                                      )),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Container();
                                                                        } else {
                                                                          return Container();
                                                                        }
                                                                      }),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else if (mimeValue ==
                                                    'video') {
                                                  bloc.setTextFieldHint(
                                                      'Tap arrow to send');
                                                  bloc.setTextField(false);
                                                  _videoPlayerController =
                                                      VideoPlayerController
                                                          .file(filePath.data);
                                                  _initializeVideoPlayerFuture =
                                                      _videoPlayerController
                                                          .initialize();
                                                  var playing = false;
                                                  return Column(
                                                    children: <Widget>[
                                                      ValueListenableBuilder(
                                                          valueListenable:
                                                              _bottomBarHeight,
                                                          builder: (BuildContext
                                                                  context,
                                                              double height,
                                                              Widget child) {
                                                            return AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      800),
                                                              height: _bottomBarHeight
                                                                          .value ==
                                                                      -1
                                                                  ? 100
                                                                  : _bottomBarHeight
                                                                      .value,
                                                            );
                                                          }),
                                                      Bubble(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              if (playing ==
                                                                  false) {
                                                                _videoPlayerController
                                                                    .play();
                                                                playing = true;
                                                              } else {
                                                                _videoPlayerController
                                                                    .pause();
                                                                playing = false;
                                                              }
                                                            },
                                                            child: Stack(
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      2,
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  child: Center(
                                                                    child:
                                                                        FutureBuilder(
                                                                      future:
                                                                          _initializeVideoPlayerFuture,
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        if (snapshot.connectionState ==
                                                                            ConnectionState.done) {
                                                                          return AspectRatio(
                                                                            aspectRatio:
                                                                                _videoPlayerController.value.aspectRatio,
                                                                            child:
                                                                                VideoPlayer(_videoPlayerController),
                                                                          );
                                                                        } else {
                                                                          return Center(
                                                                              child: CircularProgressIndicator(
                                                                            backgroundColor:
                                                                                Theme.of(context).primaryColor,
                                                                            color:
                                                                                Colors.white,
                                                                          ));
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      2,
                                                                  child: Center(
                                                                    child: FutureBuilder(
                                                                        future: bloc.getPictureSize(file),
                                                                        builder: (BuildContext context, imageData) {
                                                                          if (imageData
                                                                              .hasData) {
                                                                            return snapshot.data
                                                                                ? Opacity(
                                                                                    opacity: 0.6,
                                                                                    child: AspectRatio(
                                                                                      aspectRatio: imageData.data.width / imageData.data.height,
                                                                                      child: Container(
                                                                                        color: Colors.grey,
                                                                                        child: Center(
                                                                                            child: CircularProgressIndicator(
                                                                                          backgroundColor: Theme.of(context).primaryColor,
                                                                                          color: Colors.white,
                                                                                        )),
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                : Container();
                                                                          } else {
                                                                            return Container();
                                                                          }
                                                                        }),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              } else {
                                                return Container();
                                              }
                                            }),
                                      ),
                                    ),
                                    Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Spacer(),
                                          IconButton(
                                              icon: Icon(Icons.photo),
                                              onPressed: () async {
                                                if (!snapshot.data) {
                                                  var _image =
                                                      await _chooseFileType(
                                                          context);

                                                  if (_image.runtimeType !=
                                                      String) {
                                                    bloc.setFilePath(_image);
                                                  } else {
                                                    await bloc.sendGIF(
                                                        DateTime.now()
                                                            .toUtc()
                                                            .toString(),
                                                        '',
                                                        receiverID,
                                                        '${createCryptoRandomString()}',
                                                        'gif',
                                                        context,
                                                        _image);
                                                    mimeValue = 'gif';
                                                    isGIF = true;
                                                    gifURL = _image;
                                                  }
                                                }
                                              }),
                                          Spacer(),
                                          StreamBuilder<Object>(
                                              stream: bloc.textFieldHint,
                                              initialData: 'Enter message',
                                              builder: (context, hintText) {
                                                return Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2,
                                                  child: StreamBuilder<Object>(
                                                      stream: bloc
                                                          .disabletextController,
                                                      initialData: true,
                                                      builder:
                                                          (context, disable) {
                                                        return TextFormField(
                                                          controller:
                                                              _textEditingController,
                                                          textCapitalization:
                                                              TextCapitalization
                                                                  .sentences,
                                                          textInputAction:
                                                              TextInputAction
                                                                  .send,
                                                          onChanged: (value) {
                                                            if (value
                                                                        .trim()
                                                                        .length >=
                                                                    1 &&
                                                                allowOffensiveWord !=
                                                                    true) {
                                                              checkOffensiveText(
                                                                      value)
                                                                  .then(
                                                                      (value) {
                                                                if (value[0] ==
                                                                    true) {
                                                                  if (Platform
                                                                      .isIOS) {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          CupertinoAlertDialog(
                                                                        // title: Text(
                                                                        //     'Are You Sure?'),
                                                                        // content:
                                                                        //     Text('You want to send ${value[2]} word? ${value[1]}'),
                                                                        content:
                                                                            Text(
                                                                          'Are You Sure? WWJD',
                                                                          style:
                                                                              TextStyle(fontFamily: 'Papyrus'),
                                                                        ),
                                                                        // actions: [
                                                                        //   CupertinoDialogAction(
                                                                        //     child:
                                                                        //         Text('No'),
                                                                        //     onPressed: () =>
                                                                        //         Navigator.pop(context, 'Cancel'),
                                                                        //   ),
                                                                        //   CupertinoDialogAction(
                                                                        //     child:
                                                                        //         Text('Yes'),
                                                                        //     onPressed:
                                                                        //         () {
                                                                        //       allowOffensiveWord = true;
                                                                        //       Navigator.pop(context, 'OK');
                                                                        //     },
                                                                        //   ),
                                                                        // ],
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          AlertDialog(
                                                                        elevation:
                                                                            10.0,
                                                                        // title: Text(
                                                                        //     'Are You Sure?'),
                                                                        content:
                                                                            Text(
                                                                          'You want to send ${value[2]} word? ${value[1]}',
                                                                          style:
                                                                              TextStyle(fontFamily: 'Papyrus'),
                                                                        ),
                                                                        // actions: <
                                                                        //     Widget>[
                                                                        //   TextButton(
                                                                        //     onPressed: () =>
                                                                        //         Navigator.pop(context, 'Cancel'),
                                                                        //     child:
                                                                        //         const Text('No'),
                                                                        //   ),
                                                                        //   TextButton(
                                                                        //     onPressed:
                                                                        //         () {
                                                                        //       allowOffensiveWord = true;
                                                                        //       Navigator.pop(context, 'OK');
                                                                        //     },
                                                                        //     child:
                                                                        //         const Text('Yes'),
                                                                        //   ),
                                                                        // ],
                                                                      ),
                                                                    );
                                                                  }
                                                                }
                                                              });
                                                            }
                                                          },
                                                          onFieldSubmitted:
                                                              (value) async {
                                                            bool showPopup =
                                                                await bloc.sendMessage(
                                                                    DateTime.now()
                                                                        .toUtc()
                                                                        .toString(),
                                                                    value,
                                                                    receiverID,
                                                                    '',
                                                                    '${createCryptoRandomString()}',
                                                                    '',
                                                                    context,
                                                                    file);

                                                            _textEditingController
                                                                .clear();
                                                            bloc.setFilePath(
                                                                null);
                                                          },
                                                          enabled:
                                                              !snapshot.data,
                                                          maxLines: null,
                                                          keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                          cursorColor:
                                                              Colors.black,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .body2,
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                "${hintText.data}",
                                                            hintStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .body2,
                                                          ),
                                                        );
                                                      }),
                                                );
                                              }),
                                          Spacer(),
                                          IconButton(
                                              icon: Icon(CopticMeetIcons
                                                  .send_coptic_meet),
                                              onPressed: () async {
                                                if (!snapshot.data) {
                                                  if (mimeValue == '') {
                                                    bool showPopup =
                                                        await bloc.sendMessage(
                                                            DateTime.now()
                                                                .toUtc()
                                                                .toString(),
                                                            _textEditingController
                                                                .text,
                                                            receiverID,
                                                            '',
                                                            '${createCryptoRandomString()}',
                                                            mimeValue,
                                                            context,
                                                            file);
                                                    mimeValue = '';

                                                    _textEditingController
                                                        .clear();
                                                    bloc.setFilePath(null);
                                                  } else {
                                                    bool showPopup =
                                                        await bloc.sendMessage(
                                                            DateTime.now()
                                                                .toUtc()
                                                                .toString(),
                                                            _textEditingController
                                                                .text,
                                                            receiverID,
                                                            path.basename(
                                                                file.path),
                                                            '${createCryptoRandomString()}',
                                                            mimeValue,
                                                            context,
                                                            file);
                                                    mimeValue = '';
                                                    _textEditingController
                                                        .clear();
                                                    bloc.setFilePath(null);
                                                  }
                                                }
                                              }),
                                          Spacer()
                                        ]),
                                  ],
                                ),
                              ],
                            ),
                          );
                        })),
              ),
            ),
          ),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Stack(children: <Widget>[
              Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: StreamBuilder(
                          stream: bloc.usersMessages(receiverID, userID),
                          builder: (BuildContext context, messageData) {
                            if (messageData.hasData) {
                              return StreamBuilder<List<dynamic>>(
                                  stream: bloc.newMessagesInOrder(receiverID),
                                  builder: (BuildContext context, messageKeys) {
                                    if (messageKeys.hasData) {
                                      if (messageKeys.data != null) {
                                        bloc.updateReadMessages(
                                            receiverID, userID);
                                        String latestUnread = '';
                                        for (var i = 0;
                                            i < messageKeys.data.length;
                                            i++) {
                                          if (messageData.data.snapshot.value[
                                                      messageKeys.data[i]]
                                                  ['receiverRead'] ==
                                              'false') {
                                            if (i !=
                                                messageKeys.data.length - 1) {
                                              if (messageData
                                                          .data.snapshot.value[
                                                      messageKeys.data[i +
                                                          1]]['receiverRead'] ==
                                                  'true') {
                                                latestUnread =
                                                    messageKeys.data[i + 1];
                                              }
                                            }
                                          }
                                        }
                                        return Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ListView.builder(
                                            padding: EdgeInsets.all(10.0),
                                            itemBuilder: (context, index) =>
                                                NewMessageCardBuilder(
                                              database,
                                              receiverID: receiverID,
                                              message: messageData
                                                      .data.snapshot.value[
                                                  messageKeys.data[index]],
                                              imageURL: imageURL,
                                              messageKey:
                                                  messageKeys.data[index],
                                              latestMessageKey:
                                                  messageKeys.data,
                                              allMessages: messageData
                                                  .data.snapshot.value,
                                              bloc: bloc,
                                              userProfilePic: imageURL,
                                              latestUnread: latestUnread,
                                            ),
                                            //buildMessageTile(receiverID, messageData.data.snapshot.value[messageKeys.data[index]], imageURL, messageKeys.data[index], context, messageKeys.data, messageData.data.snapshot.value),
                                            itemCount: messageKeys.data.length,
                                            reverse: true,
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          
                                          child: Center(
                                              child: Text(
                                            'Say hi to your new match, $name is waiting',
                                            textAlign: TextAlign.center,
                                          )),
                                        );
                                      }
                                    } else {
                                      return Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: Center(
                                            child: Text(
                                          'Say hi to your new match, $name is waiting',
                                          textAlign: TextAlign.center,
                                        )),
                                      );
                                    }
                                  });
                            } else {
                              return Container(
                                width: double.infinity,
                                height: double.infinity,
                                child: Center(
                                    child: Text(
                                  'Say hi to your new match, $name is waiting',
                                  textAlign: TextAlign.center,
                                )),
                              );
                            }
                          }),
                    ),
                  ),
                  ValueListenableBuilder(
                      valueListenable: _bottomBarHeight,
                      builder:
                          (BuildContext context, double height, Widget child) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 800),
                          height: _bottomBarHeight.value == -1
                              ? 100
                              : _bottomBarHeight.value,
                        );
                      }),
                ],
              ),
            ])),
      ),
    );
  }
}

class NewMessageCardBuilder extends StatefulWidget {
  NewMessageCardBuilder(this.db,
      {Key key,
      @required this.receiverID,
      @required this.message,
      @required this.imageURL,
      @required this.messageKey,
      @required this.latestMessageKey,
      @required this.allMessages,
      @required this.bloc,
      @required this.userProfilePic,
      @required this.latestUnread})
      : super(key: key);
  final String receiverID;
  final Map<dynamic, dynamic> message;
  final String imageURL;
  final String messageKey;
  final List latestMessageKey;
  final Map<dynamic, dynamic> allMessages;
  final MessagingBloc bloc;
  final String userProfilePic;
  final String latestUnread;
  final Database db;

  @override
  _NewMessageCardBuilderState createState() => _NewMessageCardBuilderState();
}

class _NewMessageCardBuilderState extends State<NewMessageCardBuilder> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  bool playing = false;

  @override
  void initState() {
    super.initState();
    if (widget.message['mimeType'] == 'video') {
      _controller = VideoPlayerController.network(
        widget.message['imageURL'],
      );
      _initializeVideoPlayerFuture = _controller.initialize();
    }
  }

  @override
  void dispose() {
    if (widget.message['mimeType'] == 'video') {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.receiverID == widget.message['sender']) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            child: Column(
              children: <Widget>[
                widget.message['userLiked'] == 'true'
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                CopticMeetIcons.right_coptic_meet,
                                color: Theme.of(context).primaryColor,
                                size: 12,
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: GestureDetector(
                      onDoubleTap: () {
                        if (widget.message['userLiked'] == 'true') {
                          widget.bloc.updateLikedNotification(
                              widget.receiverID,
                              widget.messageKey,
                              widget.message['sender'],
                              false);
                        } else {
                          widget.bloc.updateLikedNotification(
                              widget.receiverID,
                              widget.messageKey,
                              widget.message['sender'],
                              true);
                        }
                      },
                      child: Bubble(
                          margin: BubbleEdges.only(top: 10),
                          nip: BubbleNip.leftTop,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                widget.message['mimeType'] == 'image'
                                    ? ChatImage(
                                        img: '${widget.message['imageURL']}',
                                        imgType:
                                            '${widget.message['mimeType']}',
                                      )
                                    : Container(),
                                widget.message['mimeType'] == 'video'
                                    ? GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => PhotoViewPage(
                                                    imageURL:
                                                        '${widget.message['imageURL']}',
                                                    mimeType:
                                                        '${widget.message['mimeType']}')),
                                          );
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Center(
                                              child: FutureBuilder(
                                                future:
                                                    _initializeVideoPlayerFuture,
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.done) {
                                                    return AspectRatio(
                                                      aspectRatio: _controller
                                                          .value.aspectRatio,
                                                      child: VideoPlayer(
                                                          _controller),
                                                    );
                                                  } else {
                                                    return Container(
                                                        height: 200,
                                                        child: Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          color: Colors.white,
                                                        )));
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    widget.message['message'] != ''
                                        ? Flexible(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${widget.message['message']}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .body2,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        widget.message["time"] !=
                                                                null
                                                            ? DateFormat('hh:mm a')
                                                                    .format(DateTime.parse(
                                                                        widget.message[
                                                                            'time']))
                                                                    .toString()
                                                                    .startsWith(
                                                                        '0')
                                                                ? DateFormat(
                                                                        'hh:mm a')
                                                                    .format(DateTime.parse(
                                                                        widget.message[
                                                                            'time']))
                                                                    .toString()
                                                                    .substring(
                                                                        1)
                                                                : DateFormat(
                                                                        'hh:mm a')
                                                                    .format(DateTime.parse(
                                                                        widget.message['time']))
                                                                    .toString()
                                                            : "",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container()
                                  ]),
                            ],
                          )),
                    ),
                  ),
                ),
                widget.message['messageKey'] == widget.latestUnread ||
                        (widget.message['messageKey'] ==
                                widget.latestMessageKey[0] &&
                            widget.message['receiverRead'] == 'true')
                    ? Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundImage: CachedNetworkImageProvider(
                              '${widget.userProfilePic}',
                            ),
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
          widget.message['mimeType'] == ''
              ? Container(width: MediaQuery.of(context).size.width / 3)
              : Container(),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              widget.message['mimeType'] == ''
                  ? Container(width: MediaQuery.of(context).size.width / 3)
                  : Container(),
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  children: <Widget>[
                    widget.message['userLiked'] == 'true'
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    CopticMeetIcons.right_coptic_meet,
                                    color: Colors.redAccent,
                                    size: 12,
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        child: Bubble(
                            margin: BubbleEdges.only(top: 10),
                            nip: BubbleNip.rightTop,
                            color: ColorUtils.defaultColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(mainAxisSize: MainAxisSize.min, children: [
                                  widget.message['mimeType'] == 'image'
                                      ? ChatImage(
                                          img: '${widget.message['imageURL']}',
                                          imgType:
                                              '${widget.message['mimeType']}',
                                        )
                                      : Container(),
                                  widget.message['mimeType'] == 'video'
                                      ? GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => PhotoViewPage(
                                                      imageURL:
                                                          '${widget.message['imageURL']}',
                                                      mimeType:
                                                          '${widget.message['mimeType']}')),
                                            );
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: Center(
                                                child: FutureBuilder(
                                                  future:
                                                      _initializeVideoPlayerFuture,
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                      return AspectRatio(
                                                        aspectRatio: _controller
                                                            .value.aspectRatio,
                                                        child: VideoPlayer(
                                                            _controller),
                                                      );
                                                    } else {
                                                      return Container(
                                                          height: 200,
                                                          child: Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                            color: Colors.white,
                                                          )));
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      widget.message['message'] != ''
                                          ? Flexible(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(0.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${widget.message['message']}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .body2,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        FutureBuilder(
                                                          builder:
                                                              (_, snapshot) {
                                                            Widget w =
                                                                SizedBox();
                                                            if (snapshot
                                                                .hasData) {
                                                              DataSnapshot res =
                                                                  snapshot.data;
                                                              final data =
                                                                  res.value;
                                                              final read = data[
                                                                          "read_receipts"] !=
                                                                      null &&
                                                                  data["read_receipts"] ==
                                                                      "Yes";
                                                              w = read &&
                                                                      widget.message[
                                                                              "receiverRead"] ==
                                                                          "true"
                                                                  ? Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        "Read",
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                "Papyrus",
                                                                            fontSize:
                                                                                12),
                                                                      ))
                                                                  : SizedBox();
                                                            }
                                                            return w;
                                                          },
                                                          future: widget.db
                                                              .getOtherUserData(
                                                            widget.message[
                                                                "sender"],
                                                          ),
                                                        ),
                                                        Text(
                                                          widget.message["time"] !=
                                                                  null
                                                              ? DateFormat(
                                                                          'hh:mm a')
                                                                      .format(DateTime.parse(
                                                                          widget.message[
                                                                              'time']))
                                                                      .toString()
                                                                      .startsWith(
                                                                          '0')
                                                                  ? DateFormat(
                                                                          'hh:mm a')
                                                                      .format(DateTime.parse(
                                                                          widget.message[
                                                                              'time']))
                                                                      .toString()
                                                                      .substring(
                                                                          1)
                                                                  : DateFormat(
                                                                          'hh:mm a')
                                                                      .format(
                                                                          DateTime.parse(widget.message['time']))
                                                                      .toString()
                                                              : "",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText1,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container()
                                    ]),
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          widget.message['messageKey'] == widget.latestUnread ||
                  (widget.message['messageKey'] == widget.latestMessageKey[0] &&
                      widget.message['receiverRead'] == 'true')
              ? Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundImage: CachedNetworkImageProvider(
                        '${widget.userProfilePic}',
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      );
    }
  }
}

/// this will blur the images if it's nude content.
class ChatImage extends StatelessWidget {
  const ChatImage({Key key, @required this.img, @required this.imgType})
      : super(key: key);

  final String img;
  final String imgType;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getImageModelationType(img),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PhotoViewPage(imageURL: '$img', mimeType: '$imgType')),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Blur(
                      blur: snapshot.data ? 10.4 : 0.0,
                      blurColor: Colors.black,
                      child: CachedNetworkImage(
                        imageUrl: '$img',
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                                child: Container(
                                    height: 200,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      color: Colors.white,
                                    )))),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error_outline),
                      ),
                    ),
                    Container(
                      width: 200.0,
                      height: 130.0,
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Transform.rotate(
                            angle: pi / 5.0,
                            child: Icon(
                              CupertinoIcons.hand_point_left,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            'Tap to see',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PhotoViewPage(imageURL: '$img', mimeType: '$imgType')),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: CachedNetworkImage(
                  imageUrl: '$img',
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                          child: Container(
                              height: 200,
                              child: Center(
                                  child: CircularProgressIndicator(
                                value: downloadProgress.progress,
                                backgroundColor: Theme.of(context).primaryColor,
                                color: Colors.white,
                              )))),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error_outline),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class MessageCardBuilder extends StatefulWidget {
  MessageCardBuilder(
      {Key key,
      @required this.receiverID,
      @required this.message,
      @required this.imageURL,
      @required this.messageKey,
      @required this.latestMessageKey,
      @required this.allMessages,
      @required this.bloc})
      : super(key: key);
  final String receiverID;
  final Map<dynamic, dynamic> message;
  final String imageURL;
  final String messageKey;
  final List latestMessageKey;
  final Map<dynamic, dynamic> allMessages;
  final MessagingBloc bloc;

  @override
  _MessageCardBuilderState createState() => _MessageCardBuilderState();
}

class _MessageCardBuilderState extends State<MessageCardBuilder> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  bool playing = false;

  @override
  void initState() {
    super.initState();
    if (widget.message['mimeType'] == 'video') {
      _controller = VideoPlayerController.network(
        widget.message['imageURL'],
      );
      _initializeVideoPlayerFuture = _controller.initialize();
    }
  }

  @override
  void dispose() {
    if (widget.message['mimeType'] == 'video') {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message['message'] != '') {
      if (widget.receiverID == widget.message['sender']) {
        if (widget.message['receiverRead'] == "true") {
          return FutureBuilder(
              future: widget.bloc.getLatestSenderMessage(
                  widget.latestMessageKey,
                  widget.receiverID,
                  widget.allMessages),
              builder: (BuildContext context, latestSenderMessageKey) {
                if (widget.message['messageKey'] ==
                    latestSenderMessageKey.data) {
                  return Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          GestureDetector(
                            onDoubleTap: () {
                              if (widget.message['userLiked'] == 'true') {
                                widget.bloc.updateLikedNotification(
                                    widget.receiverID,
                                    widget.messageKey,
                                    widget.message['sender'],
                                    false);
                              } else {
                                widget.bloc.updateLikedNotification(
                                    widget.receiverID,
                                    widget.messageKey,
                                    widget.message['sender'],
                                    true);
                              }
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.5,
                                        child: Bubble(
                                          margin: BubbleEdges.only(top: 10),
                                          nip: BubbleNip.leftTop,
                                          child: Text(
                                            '${widget.message['message']}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2,
                                          ),
                                        ),
                                      ),
                                    ])),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, top: 2, bottom: 2),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundImage: CachedNetworkImageProvider(
                                    '${widget.imageURL}'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      widget.message['userLiked'] == 'true'
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Icon(
                                    CopticMeetIcons.right_coptic_meet,
                                    color: Theme.of(context).primaryColor,
                                    size: 12,
                                  )),
                            )
                          : Container(height: 12, width: 12)
                    ],
                  );
                } else {
                  return Stack(
                    children: <Widget>[
                      GestureDetector(
                        onDoubleTap: () {
                          if (widget.message['userLiked'] == 'true') {
                            widget.bloc.updateLikedNotification(
                                widget.receiverID,
                                widget.messageKey,
                                widget.message['sender'],
                                false);
                          } else {
                            widget.bloc.updateLikedNotification(
                                widget.receiverID,
                                widget.messageKey,
                                widget.message['sender'],
                                true);
                          }
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 1.5,
                                    child: Bubble(
                                      margin: BubbleEdges.only(top: 10),
                                      nip: BubbleNip.leftTop,
                                      child: Text(
                                        '${widget.message['message']}',
                                        style:
                                            Theme.of(context).textTheme.body2,
                                      ),
                                    ),
                                  ),
                                ])),
                      ),
                      widget.message['userLiked'] == 'true'
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Icon(
                                    CopticMeetIcons.right_coptic_meet,
                                    color: Theme.of(context).primaryColor,
                                    size: 12,
                                  )),
                            )
                          : Container(height: 12, width: 12)
                    ],
                  );
                }
              });
        } else {
          return Stack(
            children: <Widget>[
              GestureDetector(
                onDoubleTap: () {
                  if (widget.message['userLiked'] == 'true') {
                    widget.bloc.updateLikedNotification(widget.receiverID,
                        widget.messageKey, widget.message['sender'], false);
                  } else {
                    widget.bloc.updateLikedNotification(widget.receiverID,
                        widget.messageKey, widget.message['sender'], true);
                  }
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 1.5,
                            child: Bubble(
                              margin: BubbleEdges.only(top: 10),
                              nip: BubbleNip.leftTop,
                              child: Text(
                                '${widget.message['message']}',
                                style: Theme.of(context).textTheme.body2,
                              ),
                            ),
                          ),
                        ])),
              ),
              widget.message['userLiked'] == 'true'
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Icon(
                            CopticMeetIcons.right_coptic_meet,
                            color: Theme.of(context).primaryColor,
                            size: 12,
                          )),
                    )
                  : Container(height: 12, width: 12)
            ],
          );
        }
      } else {
        return Stack(
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Bubble(
                      margin: BubbleEdges.only(top: 10),
                      nip: BubbleNip.rightTop,
                      color: ColorUtils.defaultColor,
                      child: Text(
                        '${widget.message['message']}',
                        style: Theme.of(context).textTheme.body2,
                      ),
                    ),
                  ),
                ])),
            widget.message['userLiked'] == 'true'
                ? Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Align(
                        alignment: Alignment.topRight,
                        child: Icon(CopticMeetIcons.right_coptic_meet,
                            color: Colors.redAccent, size: 12)),
                  )
                : Container(height: 12, width: 12),
          ],
        );
      }
    } else {
      if (widget.receiverID == widget.message['sender']) {
        if (widget.message['mimeType'] == 'image') {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: GestureDetector(
                  onDoubleTap: () {
                    if (widget.message['userLiked'] == 'true') {
                      widget.bloc.updateLikedNotification(widget.receiverID,
                          widget.messageKey, widget.message['sender'], false);
                    } else {
                      widget.bloc.updateLikedNotification(widget.receiverID,
                          widget.messageKey, widget.message['sender'], true);
                    }
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PhotoViewPage(
                              imageURL: '${widget.message['imageURL']}',
                              mimeType: '${widget.message['mimeType']}')),
                    );
                  },
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: Bubble(
                          margin:
                              BubbleEdges.only(left: 0, top: 15, bottom: 20),
                          nip: BubbleNip.leftTop,
                          child: CachedNetworkImage(
                            imageUrl: '${widget.message['imageURL']}',
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Center(
                                    child: Container(
                                        height: 200,
                                        child: Center(
                                            child: CircularProgressIndicator(
                                          value: downloadProgress.progress,
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          color: Colors.white,
                                        )))),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error_outline),
                          ),
                        ),
                      ),
                      widget.message['userLiked'] == 'true'
                          ? Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Icon(
                                    CopticMeetIcons.right_coptic_meet,
                                    color: Theme.of(context).primaryColor,
                                    size: 12,
                                  )),
                            )
                          : Container(height: 12, width: 12)
                    ],
                  ),
                ),
              ),
              Spacer(),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: GestureDetector(
                    onDoubleTap: () {
                      if (widget.message['userLiked'] == 'true') {
                        widget.bloc.updateLikedNotification(widget.receiverID,
                            widget.messageKey, widget.message['sender'], false);
                      } else {
                        widget.bloc.updateLikedNotification(widget.receiverID,
                            widget.messageKey, widget.message['sender'], true);
                      }
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PhotoViewPage(
                                imageURL: '${widget.message['imageURL']}',
                                mimeType: '${widget.message['mimeType']}')),
                      );
                    },
                    child: Stack(
                      children: <Widget>[
                        Bubble(
                          margin: BubbleEdges.only(top: 10),
                          nip: BubbleNip.leftTop,
                          child: Center(
                            child: FutureBuilder(
                              future: _initializeVideoPlayerFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return AspectRatio(
                                    aspectRatio: _controller.value.aspectRatio,
                                    child: VideoPlayer(_controller),
                                  );
                                } else {
                                  return Container(
                                      height: 200,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        color: Colors.white,
                                      )));
                                }
                              },
                            ),
                          ),
                        ),
                        widget.message['userLiked'] == 'true'
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Icon(
                                      CopticMeetIcons.right_coptic_meet,
                                      color: Theme.of(context).primaryColor,
                                      size: 12,
                                    )),
                              )
                            : Container(height: 12, width: 12)
                      ],
                    ),
                  ),
                ),
              ),
              Spacer(),
            ],
          );
        }
      } else {
        if (widget.message['mimeType'] == 'image') {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  widget.message['userLiked'] == 'true'
                      ? Padding(
                          padding: const EdgeInsets.only(right: 0, top: 10),
                          child: Align(
                              alignment: Alignment.topRight,
                              child: Icon(CopticMeetIcons.right_coptic_meet,
                                  color: Colors.redAccent, size: 12)),
                        )
                      : Container(height: 12, width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PhotoViewPage(
                                imageURL: '${widget.message['imageURL']}',
                                mimeType: '${widget.message['mimeType']}')),
                      );
                    },
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Bubble(
                            margin: BubbleEdges.only(right: 0, bottom: 10),
                            nip: BubbleNip.rightTop,
                            color: ColorUtils.defaultColor,
                            child: CachedNetworkImage(
                              imageUrl: '${widget.message['imageURL']}',
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                      child: Container(
                                          height: 200,
                                          child: Center(
                                              child: CircularProgressIndicator(
                                            value: downloadProgress.progress,
                                            backgroundColor:
                                                Theme.of(context).accentColor,
                                            color: Colors.white,
                                          )))),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error_outline),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Spacer(),
              Container(
                width: MediaQuery.of(context).size.width / 1.5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PhotoViewPage(
                              imageURL: '${widget.message['imageURL']}',
                              mimeType: '${widget.message['mimeType']}')),
                    );
                  },
                  child: Stack(
                    children: <Widget>[
                      Bubble(
                        margin: BubbleEdges.only(top: 10, right: 0, bottom: 10),
                        nip: BubbleNip.rightTop,
                        color: ColorUtils.defaultColor,
                        child: Center(
                          child: FutureBuilder(
                            future: _initializeVideoPlayerFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(_controller),
                                );
                              } else {
                                return Container(
                                    height: 200,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      color: Colors.white,
                                    )));
                              }
                            },
                          ),
                        ),
                      ),
                      widget.message['userLiked'] == 'true'
                          ? Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Align(
                                  alignment: Alignment.topRight,
                                  child: Icon(
                                    CopticMeetIcons.right_coptic_meet,
                                    color: Colors.redAccent,
                                    size: 12,
                                  )),
                            )
                          : Container(height: 12, width: 12)
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      }
    }
  }
}

class PhotoViewPage extends StatefulWidget {
  PhotoViewPage({Key key, @required this.imageURL, @required this.mimeType})
      : super(key: key);

  final String imageURL;
  final String mimeType;

  @override
  _PhotoViewPageState createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  bool playing = false;

  @override
  void initState() {
    super.initState();
    if (widget.mimeType == 'video') {
      _controller = VideoPlayerController.network(
        widget.imageURL,
      );
      _initializeVideoPlayerFuture = _controller.initialize();
    }
  }

  @override
  void dispose() {
    if (widget.mimeType == 'video') {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mimeType == 'image') {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: GestureDetector(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(
                widget.imageURL,
              ),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
              enableRotation: true,
              backgroundDecoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    } else if (widget.mimeType == 'video') {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: GestureDetector(
          onTap: () {
            if (playing == false) {
              _controller.play();
              playing = true;
            } else {
              _controller.pause();
              playing = false;
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  );
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                    color: Colors.white,
                  ));
                }
              },
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
