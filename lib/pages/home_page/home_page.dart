import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:copticmeet/custom_icons/coptic_meet_icons_icons.dart';
import 'package:copticmeet/pages/home_page/list_of_likeed_user.dart';
import 'package:copticmeet/pages/messaging/messaging_page.dart';
import 'package:copticmeet/providers/profile_info_caches.dart';
import 'package:copticmeet/reusable_widgets/edit_profile_widget.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/services/location/location.dart';
import 'package:copticmeet/services/messaging/messaging.dart';
import 'package:copticmeet/services/sign_in/auth.dart';
import 'package:copticmeet/services/storage/storage.dart';
import 'package:copticmeet/utils/color_utils.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/platform_aler_dialog.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import 'home_page_card.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, @required this.database, @required this.storage})
      : super(key: key);
  final Database database;
  final storage;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var location;
  var likeNumbersData;
  var likeNumber = 0;
  var dislikeNumberData;
  var dislikeNumber = 0;
  var doubleLikeNumberData;
  var doubleLikeNumber = 0;
  var loc;
  var numberNewlikes;
  var userLocation;

  setLocation() async {
    Provider.of<ProfileImageCaches>(context, listen: false)
        .getUserLocation(widget.database);

    final DatabaseReference userRef = await widget.database.getUserDataOnce();
    final DataSnapshot userSnap = await userRef.once();
    final userData = userSnap.value;
    if (userData["location"] != null && userData["location"] != "null") {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      final location = '${position.latitude},${position.longitude}';
      final locationName = await getTownInfo(location) ?? "";
      widget.database.updateUserDetails(
          {"locationName": locationName, "location": location});
    }
  }

  setProfileImages() async {
    final DatabaseReference userRef = await widget.database.getUserDataOnce();
    final DataSnapshot userSnap = await userRef.once();
    final userData = userSnap.value;
    bool notSet = userData["imageUrls"] == null;
    //if (notSet) {
    final urls = await widget.storage
        .getUserProfilePictures(widget.database, widget.database.userId);
    final urlsStrings = json.encode(urls);
    widget.database.updateUserDetails({"imageUrls": urlsStrings});
    //}
  }

  getLikeNumber() async {
    var snapshot = await widget.database.getLikesNumber();
    setState(() {
      likeNumbersData = snapshot.value;
      likeNumber = likeNumbersData.length;
    });
  }

  getDoubleLike() async {
    var snapshot = await widget.database.getDislikesNumber();
    setState(() {
      dislikeNumberData = snapshot.value;
      dislikeNumber = dislikeNumberData.length;
    });
  }

  getDislikeNumber() async {
    var snapshot = await widget.database.getDoubleLikeNumber();
    setState(() {
      doubleLikeNumberData = snapshot.value;
      doubleLikeNumber = doubleLikeNumberData.length;
    });
  }

  Future<bool> getPastPurchases() async {
    DataSnapshot snapshot =
        await widget.database.getSpecificUserValues('proActive');
    if (snapshot.value == 'true') {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkPastPurchases() async {
    List<PurchaseDetails> _purchases = [];
    InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;
    FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();

    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
    }
    _purchases = response.pastPurchases;
    if (_purchases.length > 0 &&
        (_purchases[0].productID == 'copticmeet.yearly_subscription' ||
            _purchases[0].productID ==
                'copticmeet.three_monthly_subscription' ||
            _purchases[0].productID == 'copticmeet.monthly_subscription' ||
            _purchases[0].productID == 'copticmeet.weekly_subscription')) {
      widget.database.updateUserDetails({'proActive': 'true'});
      return true;
    } else {
      widget.database.updateUserDetails({'proActive': 'false'});
      firebaseMessaging.unsubscribeFromTopic('proMode');
      return false;
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
      final deleteCaches =
          Provider.of<ProfileImageCaches>(context, listen: false);
      deleteCaches.clearProfileImages();
      deleteCaches.signedOut(true);
    } catch (e) {}
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await PlatformAlertDialog(
            title: 'Logout',
            cancelActionText: 'Cancel',
            content: 'Are you sure you want to logout?',
            defaultActionText: 'Logout')
        .show(context);
    if (didRequestSignOut == true) {
      Navigator.of(context).pop();
      _signOut(context);
    } else {
      Navigator.of(context).pop();
    }
  }

  updateOnlineStatus() async {
    var database = Provider.of<Database>(context, listen: false);
    database.updateUserDetails({
      "online": "false",
    });
  }

  updateToken() async {
    var database = Provider.of<Database>(context, listen: false);
    var newToken = await _firebaseMessaging.getToken();
    database.updateUserDetails({
      "online": "false",
    });
    database.addUserNotificationToken({
      "$newToken": {
        "platform": "${Platform.operatingSystem}",
        "timeCreated": "${DateTime.now().toUtc()}",
      },
    });
  }

  androidNotificationClick(Map<dynamic, dynamic> message) {
    var database = Provider.of<Database>(context, listen: false);
    var location = Provider.of<Location>(context, listen: false);
    var storage = Provider.of<Storage>(context, listen: false);
    if (message['data']['match'] == "true") {
      showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.all(0),
            content: FutureBuilder(
              future: widget.database.checkPreferences(),
              builder:
                  (BuildContext context, AsyncSnapshot<String> preferences) {
                if (preferences.connectionState == ConnectionState.done) {
                  return FutureBuilder(
                      future: _getUserLocations(),
                      builder: (BuildContext context, userLocations) {
                        if (userLocations.hasData) {
                          return Container(
                            color: Colors.transparent,
                            width: MediaQuery.of(context).size.width / 1.1,
                            child: NewMatchPopupCard(
                              accountLocation: userLocations.data.value,
                              database: database,
                              location: location,
                              matchID: message['user'],
                              storage: storage,
                              userID: database.userId,
                              preferences: preferences.data,
                              onMessage: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            new Provider<Messaging>(
                                                create: (_) =>
                                                    CopticMeetMessaging(
                                                        uid: database.userId,
                                                        database: database),
                                                child: Consumer<Messaging>(
                                                    builder:
                                                        (BuildContext context,
                                                            messaging, _) {
                                                  return MessagingPage.create(
                                                      context,
                                                      database,
                                                      storage,
                                                      database.userId,
                                                      messaging,
                                                      location);
                                                }))));
                              },
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
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                    color: Colors.white,
                  ));
                }
              },
            ),
          );
        },
      );
    } else if (message['data']['liked'] == "true") {
      showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.all(0),
            content: FutureBuilder(
              future: widget.database.checkPreferences(),
              builder:
                  (BuildContext context, AsyncSnapshot<String> preferences) {
                if (preferences.connectionState == ConnectionState.done) {
                  return FutureBuilder(
                      future: _getUserLocations(),
                      builder: (BuildContext context, userLocations) {
                        if (userLocations.hasData) {
                          return Container(
                            color: Colors.transparent,
                            width: MediaQuery.of(context).size.width / 1.1,
                            child: PopupProfileCard(
                              location: location,
                              preferences: preferences.data,
                              database: database,
                              storage: storage,
                              userID: message['data']['user'],
                              accountLocation: userLocations.data.value,
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
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                    color: Colors.white,
                  ));
                }
              },
            ),
          );
        },
      );
    } else if (message['data']['message'] == 'true') {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => new Provider<Messaging>(
                  create: (_) => CopticMeetMessaging(
                      uid: message['data']['user'], database: database),
                  child: Consumer<Messaging>(
                      builder: (BuildContext context, messaging, _) {
                    return MessagingPage.create(context, database, storage,
                        message['data']['user'], messaging, location);
                  }))));
    }
  }

  iosClickNotification(Map<dynamic, dynamic> message) {
    var database = Provider.of<Database>(context, listen: false);
    var location = Provider.of<Location>(context, listen: false);
    var storage = Provider.of<Storage>(context, listen: false);
    if (message['match'] == "true") {
      showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.all(0),
            content: FutureBuilder(
              future: widget.database.checkPreferences(),
              builder:
                  (BuildContext context, AsyncSnapshot<String> preferences) {
                if (preferences.connectionState == ConnectionState.done) {
                  return FutureBuilder(
                      future: _getUserLocations(),
                      builder: (BuildContext context, userLocations) {
                        if (userLocations.hasData) {
                          return Container(
                            color: Colors.transparent,
                            width: MediaQuery.of(context).size.width / 1.1,
                            child: NewMatchPopupCard(
                              accountLocation: userLocations.data.value,
                              database: database,
                              location: location,
                              matchID: message['user'],
                              storage: storage,
                              userID: database.userId,
                              preferences: preferences.data,
                              onMessage: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            new Provider<Messaging>(
                                                create: (_) =>
                                                    CopticMeetMessaging(
                                                        uid: database.userId,
                                                        database: database),
                                                child: Consumer<Messaging>(
                                                    builder:
                                                        (BuildContext context,
                                                            messaging, _) {
                                                  return MessagingPage.create(
                                                      context,
                                                      database,
                                                      storage,
                                                      database.userId,
                                                      messaging,
                                                      location);
                                                }))));
                              },
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
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                    color: Colors.white,
                  ));
                }
              },
            ),
          );
        },
      );
    } else if (message['liked'] == "true") {
      showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.all(0),
            content: FutureBuilder(
              future: widget.database.checkPreferences(),
              builder:
                  (BuildContext context, AsyncSnapshot<String> preferences) {
                if (preferences.connectionState == ConnectionState.done) {
                  return FutureBuilder(
                      future: _getUserLocations(),
                      builder: (BuildContext context, userLocations) {
                        if (userLocations.hasData) {
                          userLocation = userLocations.data.value;
                          return Container(
                            color: Colors.transparent,
                            width: MediaQuery.of(context).size.width / 1.1,
                            child: PopupProfileCard(
                              preferences: preferences.data,
                              location: location,
                              database: database,
                              storage: storage,
                              userID: message['user'],
                              accountLocation: userLocations.data.value,
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
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                    color: Colors.white,
                  ));
                }
              },
            ),
          );
        },
      );
    } else if (message['message'] == 'true') {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => new Provider<Messaging>(
                  create: (_) => CopticMeetMessaging(
                      uid: message['user'], database: database),
                  child: Consumer<Messaging>(
                      builder: (BuildContext context, messaging, _) {
                    return MessagingPage.create(context, database, storage,
                        message['user'], messaging, location);
                  }))));
    }
  }

  setupFirebaseMessaging() {
    final userPreferences =
        Provider.of<ProfileImageCaches>(context, listen: false);
    bool isFriend = userPreferences.getUserInfo["preferences"] == "friend";
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        Flushbar(
          onTap: (value) {
            if (Platform.isIOS) {
              iosClickNotification(message);
            } else {
              androidNotificationClick(message);
            }
          },
          margin: EdgeInsets.all(8),
          backgroundColor:
              isFriend ? ColorUtils.friendColor : ColorUtils.defaultColor,
          borderRadius: 12,
          messageText: Text("${message['notification']['title']}"),
          flushbarStyle: FlushbarStyle.FLOATING,
          flushbarPosition: FlushbarPosition.TOP,
          icon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.message,
              size: 28.0,
              color: Colors.black,
            ),
          ),
          duration: Duration(seconds: 4),
        )..show(context);
      },
      onLaunch: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          iosClickNotification(message);
        } else {
          androidNotificationClick(message);
        }
      },
    );
  }

  Future _getUserLocations() async {
    var database = Provider.of<Database>(context, listen: false);
    var location = await database.getSpecificUserValues('location');
    setState(() {
      loc = location.value;
      userLocation = location.value;
    });
    return location;
  }

  String _getSection(String section, [bool isCompliment = false]) {
    String temp = section;
    if (temp == null || temp.isEmpty) temp = "dating";
    if (isCompliment) {
      if (temp == "friend")
        return "dating".capitalize();
      else
        return "friend".capitalize();
    } else {
      return temp.capitalize();
    }
  }

  String preferences = "";
  bool pastPurchases = null;

  @override
  void initState() {
    super.initState();
    setLocation();
    setProfileImages();
    _firebaseMessaging.requestNotificationPermissions();
    updateToken();
    setupFirebaseMessaging();
    checkPastPurchases();
    _getUserLocations();
    getLikeNumber();
    getDoubleLike();
    getDislikeNumber();

    Provider.of<ProfileImageCaches>(context, listen: false)
        .userDetails(widget.database);
    Provider.of<ProfileImageCaches>(context, listen: false)
        .userDetailsPro(widget.database);

    preferences = Provider.of<ProfileImageCaches>(context, listen: false)
        .getUserInfo["preferences"];

    fetchPastPurchases();
  }

  fetchPastPurchases() async {
    pastPurchases = await getPastPurchases();
  }

  @override
  Widget build(BuildContext context) {
    var database = Provider.of<Database>(context, listen: false);
    var location = Provider.of<Location>(context, listen: false);
    var storage = Provider.of<Storage>(context, listen: false);
    var userId = database.userId;

    return Consumer<ProfileImageCaches>(builder:
        (BuildContext context, ProfileImageCaches profileCaches, Widget child) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Container(
            width: MediaQuery.of(context).size.width,
            child: Consumer<ProfileImageCaches>(
              builder: (BuildContext context, ProfileImageCaches profileCaches,
                  Widget child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: PopupMenuButton(
                          offset: Offset(50, 0),
                          elevation: 12,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                            height: 20,
                                            child: Text(
                                              "New Matches",
                                              textAlign: TextAlign.start,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
                                            )),
                                        Divider(),
                                        FutureBuilder(
                                            future:
                                                database.getNewMatchesNumber(),
                                            builder: (BuildContext context,
                                                matchUserID) {
                                              if (matchUserID.hasData) {
                                                var jsonList = jsonDecode(
                                                    matchUserID.data.value);
                                                if (jsonList.length != 0) {
                                                  return Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: List.generate(
                                                          jsonList.length,
                                                          (index) {
                                                        return FutureBuilder(
                                                            future: widget
                                                                .storage
                                                                .getUserProfilePictures(
                                                                    widget
                                                                        .database,
                                                                    jsonList[
                                                                        index]),
                                                            builder:
                                                                (BuildContext
                                                                        context,
                                                                    imageURL) {
                                                              if (imageURL
                                                                  .hasData) {
                                                                return GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    await showDialog(
                                                                        context:
                                                                            context,
                                                                        builder: (_) =>
                                                                            new AlertDialog(
                                                                              contentPadding: EdgeInsets.all(0),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                                                                              content: Builder(
                                                                                builder: (context) {
                                                                                  var height = MediaQuery.of(context).size.height;
                                                                                  var width = MediaQuery.of(context).size.width;
                                                                                  return SafeArea(
                                                                                    child: Container(
                                                                                      child: Container(
                                                                                        height: height - 250,
                                                                                        width: width - 40,
                                                                                        child: FutureBuilder(
                                                                                            future: _getUserLocations(),
                                                                                            builder: (BuildContext context, userLocations) {
                                                                                              if (userLocations.hasData) {
                                                                                                return Container(
                                                                                                  width: MediaQuery.of(context).size.width / 1.1,
                                                                                                  child: MatchCardPopup(
                                                                                                    storage: storage,
                                                                                                    database: database,
                                                                                                    preferences: preferences,
                                                                                                    matchID: jsonList[index],
                                                                                                    location: location,
                                                                                                    accountLocation: userLocations.data.value,
                                                                                                    userID: userId,
                                                                                                    onMessage: () {
                                                                                                      Navigator.push(
                                                                                                          context,
                                                                                                          new MaterialPageRoute(
                                                                                                              builder: (BuildContext context) => new Provider<Messaging>(
                                                                                                                  create: (_) => CopticMeetMessaging(uid: userId, database: database),
                                                                                                                  child: Consumer<Messaging>(builder: (BuildContext context, messaging, _) {
                                                                                                                    return MessagingPage.create(context, database, storage, userId, messaging, location);
                                                                                                                  }))));
                                                                                                    },
                                                                                                  ),
                                                                                                );
                                                                                              } else {
                                                                                                return Center(
                                                                                                    child: CircularProgressIndicator(
                                                                                                  backgroundColor: Theme.of(context).primaryColor,
                                                                                                  color: Colors.white,
                                                                                                ));
                                                                                              }
                                                                                            }),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ));
                                                                    await widget
                                                                        .database
                                                                        .updateNewMatches(
                                                                            jsonList[index]);
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child: Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        color: Colors
                                                                            .white,
                                                                        child: FutureBuilder(
                                                                            future: database.buildingProfileSettings(jsonList[index]),
                                                                            builder: (BuildContext context, userData) {
                                                                              if (userData.hasData) {
                                                                                return Row(
                                                                                  children: <Widget>[
                                                                                    Hero(
                                                                                      tag: imageURL.data.length == 0 ? "" : '${imageURL.data[0]}',
                                                                                      child: Container(
                                                                                        width: 40,
                                                                                        height: 40,
                                                                                        child: Card(
                                                                                          elevation: 2,
                                                                                          shape: RoundedRectangleBorder(
                                                                                            side: BorderSide(color: Colors.grey),
                                                                                            borderRadius: const BorderRadius.all(
                                                                                              Radius.circular(30.0),
                                                                                            ),
                                                                                          ),
                                                                                          child: Container(
                                                                                            child: ClipRRect(
                                                                                              borderRadius: BorderRadius.circular(30),
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
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 14),
                                                                                      child: Hero(
                                                                                        tag: "${userData.data.value['name']}",
                                                                                        child: Text(
                                                                                          '${userData.data.value['name']}',
                                                                                          style: Theme.of(context).textTheme.body2,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              } else {
                                                                                return Container(
                                                                                  height: 35,
                                                                                  child: Center(
                                                                                    child: Text(
                                                                                      'No new matches',
                                                                                      style: TextStyle(color: Colors.grey, fontFamily: "Papyrus"),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }
                                                                            }),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              10)
                                                                    ],
                                                                  ),
                                                                );
                                                              } else {
                                                                return Container(
                                                                  height: 35,
                                                                  child: Center(
                                                                    child: Text(
                                                                      'No new matches',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontFamily:
                                                                              "Papyrus"),
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            });
                                                      }));
                                                } else {
                                                  return Container(
                                                    height: 35,
                                                    child: Center(
                                                      child: Text(
                                                        'No new matches',
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontFamily:
                                                                "Papyrus"),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                return Container(
                                                  height: 35,
                                                  child: Center(
                                                    child: Text(
                                                      'No new matches',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontFamily:
                                                              "Papyrus"),
                                                    ),
                                                  ),
                                                );
                                              }
                                            }),
                                        Divider(),
                                      ]),
                                ),
                                PopupMenuItem(
                                  value: 1,
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LikedUserList(
                                                        pastPurchases:
                                                            pastPurchases,
                                                        database: database,
                                                        location: location,
                                                        storage: storage,
                                                        preferences:
                                                            preferences,
                                                      ))),
                                          child: Container(
                                              height: 20,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "New Likes",
                                                    textAlign: TextAlign.start,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .body2,
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    numberNewlikes.length
                                                        .toString(),
                                                    textAlign: TextAlign.start,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .body2,
                                                  ),
                                                ],
                                              )),
                                        ),
                                        Divider(),
                                      ]),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  height: 35,
                                  child: Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditProfileHomePage(
                                                      database: database,
                                                      storage: storage,
                                                      preferences: preferences,
                                                    )),
                                          );
                                        },
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              'Edit Profile',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
                                            ),
                                            Spacer(),
                                            Icon(Icons.edit)
                                          ],
                                        ),
                                      ),
                                      Divider()
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  height: 35,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Builder(
                                        builder: (
                                          BuildContext context,
                                        ) {
                                          return GestureDetector(
                                            onTap: () {
                                              preferences = profileCaches
                                                  .getUserInfo["preferences"];

                                              profileCaches.updateUserPreferences(
                                                  _getSection(
                                                          profileCaches.getUserInfo[
                                                                      "preferences"] ==
                                                                  "friend"
                                                              ? "friend"
                                                              : "dating",
                                                          true)
                                                      .toLowerCase(),
                                                  widget.database);
                                              var flipBool =
                                                  !profileCaches.clearAllData;
                                              profileCaches.clearAllData =
                                                  flipBool;
                                              Fluttertoast.showToast(
                                                  backgroundColor: Colors.white,
                                                  textColor: Colors.black,
                                                  msg:
                                                      "Switch to ${profileCaches.getUserInfo["preferences"] == 'friend' ? 'Sahbiti Sahbi' : 'Habibti Habibi'}");

                                              Navigator.of(context).pop();
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Switch to ${profileCaches.getUserInfo["preferences"] != 'friend' ? 'Sahbiti Sahbi' : 'Habibti Habibi'}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .body2,
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      Divider(),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  height: 5,
                                  child: GestureDetector(
                                    onTap: () => _confirmSignOut(context),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'Logout',
                                          style:
                                              Theme.of(context).textTheme.body2,
                                        ),
                                        Spacer(),
                                        Icon(Icons.exit_to_app)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                          child: Stack(
                            children: <Widget>[
                              Consumer<ProfileImageCaches>(
                                builder: (BuildContext context,
                                    ProfileImageCaches profileCaches,
                                    Widget child) {
                                  if (!profileCaches.cachedState ||
                                      profileCaches.rebuildstate ||
                                      profileCaches.userProfiles.isEmpty)
                                    profileCaches.profileImages(
                                        storage, database);

                                  return Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      elevation: 8,
                                      child: ((profileCaches.cachedState !=
                                                  false) &&
                                              profileCaches
                                                  .userProfiles.isNotEmpty)
                                          ? CircleAvatar(
                                              radius: 20,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      profileCaches
                                                          .userProfiles.first),
                                            )
                                          : CircleAvatar(radius: 20));
                                },
                              ),
                              FutureBuilder(
                                  future: database?.getNewLikesNumber(),
                                  builder: (BuildContext context, newLikes) {
                                    if (newLikes.hasData) {
                                      numberNewlikes =
                                          jsonDecode(newLikes.data.value);
                                      return FutureBuilder(
                                          future:
                                              database.getNewMatchesNumber(),
                                          builder:
                                              (BuildContext context, userData) {
                                            if (userData.hasData) {
                                              var numberNewMatches = jsonDecode(
                                                  userData.data.value);
                                              var totalNotifications =
                                                  numberNewMatches.length +
                                                      numberNewlikes.length;
                                              if (totalNotifications != 0) {
                                                return Card(
                                                  color: Colors.transparent,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      color: Colors.red,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child: Text(
                                                          '$totalNotifications',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Container();
                                              }
                                            } else {
                                              return Container();
                                            }
                                          });
                                    } else {
                                      return Container();
                                    }
                                  }),
                            ],
                          )),
                    ),
                    Column(
                      children: [
                        Text(
                          'Coptic Meet',
                          style: Theme.of(context)
                              .textTheme
                              .body2
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          profileCaches.getUserInfo["preferences"] == "friend"
                              ? "Sahbiti Sahbi"
                              : "Habibti Habibi",
                          style: Theme.of(context)
                              .textTheme
                              .body2
                              .copyWith(fontSize: 14),
                        )
                      ],
                    ),
                    IconButton(
                        icon: Icon(CopticMeetIcons.send_coptic_meet),
                        onPressed: () {
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      new Provider<Messaging>(
                                          create: (_) => CopticMeetMessaging(
                                              uid: userId, database: database),
                                          child: Consumer<Messaging>(builder:
                                              (BuildContext context, messaging,
                                                  _) {
                                            return MessagingPage.create(
                                                context,
                                                database,
                                                storage,
                                                userId,
                                                messaging,
                                                location);
                                          }))));

                          //    demoToast("00xongAHoaWIrfIr3LiXxZfFliw2");
                        })
                  ],
                );
              },
            ),
          ),
          bottomOpacity: 0.0,
        ),
        backgroundColor: profileCaches.getUserInfo["preferences"] == "friend"
            ? ColorUtils.friendColor
            : ColorUtils.defaultColor,
        body: Consumer<ProfileImageCaches>(builder: (BuildContext context,
            ProfileImageCaches profileCaches, Widget child) {
          if (!profileCaches.clearAllData) {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                  colors: [
                    profileCaches.getUserInfo["preferences"] != "friend"
                        ? ColorUtils.defaultColor
                        : Colors.white,
                    profileCaches.getUserInfo["preferences"] != "friend"
                        ? Colors.white
                        : ColorUtils.defaultColor,
                  ],
                  begin: const FractionalOffset(1.0, 0.0),
                  end: const FractionalOffset(0.0, 0.8),
                  stops: [0.3, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: HomePageCard(
                preferences: profileCaches.getUserInfo["preferences"],
                loc: userLocation,
                database: database,
                userId: userId,
                location: location,
                storage: storage,
                pastPurchases: pastPurchases,
              ),
            );
          } else {
            Future.delayed(Duration(seconds: 1), () {
              profileCaches.resetClearAllData();
            });
            return Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          profileCaches.getUserInfo["preferences"] != "friend"
                              ? ColorUtils.defaultColor
                              //: ColorUtils.friendColor,
                              : Theme.of(context).accentColor,
                          profileCaches.getUserInfo["preferences"] != "friend"
                              ? Theme.of(context).accentColor
                              : ColorUtils.defaultColor,
                        ],
                        begin: const FractionalOffset(1.0, 0.0),
                        end: const FractionalOffset(0.0, 0.7),
                        stops: [0.3, 1.0],
                        tileMode: TileMode.clamp)),
                child: Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor,
                  color: Colors.white,
                )));
          }
        }),
      );
    });
  }
}

class EditProfileHomePage extends StatefulWidget {
  EditProfileHomePage(
      {Key key,
      @required this.database,
      @required this.storage,
      @required this.preferences})
      : super(key: key);
  final String preferences;
  final storage;
  final database;

  @override
  _EditProfileHomePageState createState() => _EditProfileHomePageState();
}

class _EditProfileHomePageState extends State<EditProfileHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  widget.preferences != "friend"
                      ? ColorUtils.defaultColor
                      //: ColorUtils.friendColor,
                      : Theme.of(context).accentColor,
                  widget.preferences != "friend"
                      ? Theme.of(context).accentColor
                      : ColorUtils.defaultColor,
                ],
                begin: const FractionalOffset(1.0, 0.0),
                end: const FractionalOffset(0.0, 0.7),
                stops: [0.3, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: SafeArea(
            child: Center(
              child: Card(
                color: Colors.transparent,
                elevation: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    height: MediaQuery.of(context).size.height / 1.1,
                    color: Colors.white,
                    child: EditProfileWidget(
                        database: widget.database, storage: widget.storage),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
