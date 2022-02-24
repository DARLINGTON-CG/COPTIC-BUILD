import 'dart:math';

import 'package:copticmeet/pages/home_page/swipe_profile_card.dart';
import 'package:copticmeet/pages/profile/camera_scan.dart';
import 'package:copticmeet/pages/profile/profile_images_loader.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/services/location/location.dart';
import 'package:copticmeet/services/storage/storage.dart';
import 'package:copticmeet/widgets/motivation_card.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/widgets.dart';
import 'package:copticmeet/widgets/pro_mode/pop_up.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:swipe_stack/swipe_stack.dart';

List userRemoved = [];
int mainQuoteIndex = 0;
int shopIndex = 0;

class HomePageCard extends StatefulWidget {
  final String preferences;
  final Database database;
  final loc;
  final userId;
  final pastPurchases;
  final Storage storage;
  final Location location;

  HomePageCard(
      {Key key,
      @required this.preferences,
      @required this.loc,
      @required this.database,
      @required this.userId,
      @required this.location,
      @required this.pastPurchases,
      @required this.storage})
      : super(key: key);

  @override
  _HomePageCardState createState() => _HomePageCardState();
}

class _HomePageCardState extends State<HomePageCard> {
  GlobalKey<SwipeStackState> swipeKey = GlobalKey<SwipeStackState>();
  final _random = new Random();
  List<String> quotesList = [
    "With all lowliness and gentleness, with longsuffering, bearing with one another in love. Ephesians 4:2",
    "And above all things have fervent love for one another, for “love will cover a multitude of sins.” 1 Peter 4:8",
    "There is no fear in love; but perfect love casts out fear, because fear involves torment. But he who fears has not been made perfect in love. 1 John 4:18 ",
    "And the Lord God said, “It is not good that man should be alone; I will make him a helper comparable to him.” Genesis 2:18",
    "He who walks with wise men will be wise, but the companion of fools will be destroyed. Proverbs 13:20",
    "Therefore comfort each other and edify one another, just as you also are doing. 1 Thessalonians 5:11",
    "Have I not commanded you? Be strong and of good courage; do not be afraid, nor be dismayed, for the Lord your God is with you wherever you go. Joshua 1:9",
    "Fear not, for I am with you, Be not dismayed, for I am your God, I will strengthen you, Yes, I will help you,I will uphold you with My righteous right hand. Isaiah 41:10",
    "Peace I leave with you, My peace I give to you; not as the world gives do I give to you. Let not your heart be troubled, neither let it be afraid. John 14:27",
    "For God has not given us a spirit of fear, but of power and of love and of a sound mind. 2 Timothy 1:7",
    "God is in the midst of her, she shall not be moved; God shall help her, just at the break of dawn. Psalms 46:5",
    "But the fruit of the Spirit is love, joy, peace, longsuffering, kindness, goodness, faithfulness, gentleness, self-control. Against such there is no law. Galatians 5:22-23",
    "I say then: Walk in the Spirit, and you shall not fulfill the lust of the flesh. Galatians 5:16",
    "If you afflict my daughters, or if you take other wives besides my daughters, although no man is with us—see, God is witness between you and me. Genesis 31:50",
    "Flee also youthful lusts; but pursue righteousness, faith, love, peace with those who call on the Lord out of a pure heart. 2 Timothy 2:22",
    "Delight yourself also in the Lord and He shall give you the desires of your heart. Psalm 37:4",
    "For all that is in the world—the lust of the flesh, the lust of the eyes, and the pride of life—is not of the Father but is of the world. 1 John 2:16",
    "Charm is deceitful and beauty is passing But a woman who fears the Lord, she shall be praised. Proverbs 31:30",
    "There are many plans in a man’s heart nevertheless the Lord’s counsel—that will stand. Proverbs 19:21",
    "I charge you, O daughters of Jerusalem By the gazelles or by the does of the field, Do not stir up nor awaken love Until it pleases. Song of Solomon 2:7",
    "A friend loves at all times and a brother is born for adversity. Proverbs 17:17",
  ];
  bool fourtyCardEnabled = false;
  bool shopIndexCardEnabled = false;
  int removeIndex;
  int rIndex;
  var cardKeysList;
  List<Map<String, dynamic>> initialCardKeysList = [];
  int globalIndex = 2;
  int rewindIndex = 0;
  int freeRewind = 5;

  int doubleHeartLimitIndex = 0;
  int freeDoubleHeartLimitIndex = 3;

  bool loading = true;
  bool doubleLike = false;
  bool rewindDislike = false;
  bool rewindLike = false;
  bool rewindDoubleLike = false;
  bool exceedSwipes = false;
  int buttonStatus = 0;
  int freeSwipe = 5;
  String quoteString;

  @override
  void initState() {
    super.initState();

    getBuildStack();
    getRewindIndex();
    getDoubleHeartLikeIndex();
    quoteString = quotesList[_random.nextInt(quotesList.length)];
  }

  getCurrentUserId() {}

  getRewindIndex() async {
    var data = await widget.database.getTotalRewindCount();
    setState(() {
      if (data != null) {
        rewindIndex = int.parse(data.toString());
      } else {
        rewindIndex = 0;
      }
    });
  }

  getDoubleHeartLikeIndex() async {
    var data = await widget.database.getTotalDoubleHeartLimitIndex();
    if (mounted)
      setState(() {
        if (data != null) {
          doubleHeartLimitIndex = int.parse(data.toString());
        } else {
          doubleHeartLimitIndex = 0;
        }
      });
  }

  getBuildStack() async {
    var snapshot = await widget.database.buildStackWithCorrectValues(
        widget.location, widget.userId == 'a7CxbdOxeVSww9LCekQfqL4K9cC2');
    if (mounted)
      setState(() {
        cardKeysList = snapshot;
        loading = false;
        createInitialCradList();
      });
  }

  createInitialCradList() {
    quoteString = quotesList[_random.nextInt(quotesList.length)];
    if (loading == false && cardKeysList.length > 3) {
      initialCardKeysList = [];
      for (int i = cardKeysList.length - 3; i < cardKeysList.length; i++) {
        initialCardKeysList.add({'index': i, 'value': cardKeysList[i]});
      }
      globalIndex = 2;
    } else if (loading == false &&
        cardKeysList.length < 3 &&
        cardKeysList.length > 0) {
      initialCardKeysList = [];
      for (int i = 0; i < cardKeysList.length; i++) {
        initialCardKeysList.add({'index': i, 'value': cardKeysList[i]});
      }
      globalIndex = cardKeysList.length - 1;
    } else {
      initialCardKeysList = [];
      cardKeysList = [];
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return StreamBuilder(
        stream: widget.database.getUserData,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData &&
              !snapshot.hasError &&
              snapshot.data.snapshot.value != null &&
              ((snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.waiting))) {
            var data = snapshot.data.snapshot.value;
            final isVerified =
                data["isVerified"] != null && data["isVerified"] == true;
            return !loading
                ? (isVerified
                    ? Stack(
                        children: [
                          Center(
                            child: cardKeysList != null
                                ? SafeArea(
                                    child: Stack(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              color: Colors.transparent,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              child: cardKeysList.length != 0
                                                  ? SwipeStack(
                                                      key: swipeKey,
                                                      children:
                                                          initialCardKeysList
                                                              .map((index) {
                                                        return SwiperItem(
                                                          builder:
                                                              (SwiperPosition
                                                                      position,
                                                                  double
                                                                      progress) {
                                                            return Stack(
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Hero(
                                                                    tag: index,
                                                                    child: shopIndexCardEnabled
                                                                        ? ShoppingCard()
                                                                        : (fourtyCardEnabled == false
                                                                            ? SwipeProfileCard(
                                                                                location: widget.location,
                                                                                preferences: widget.preferences,
                                                                                database: widget.database,
                                                                                storage: widget.storage,
                                                                                userID: index['value'],
                                                                                accountLocation: widget.loc.toString(),
                                                                              )
                                                                            : MotivationalCard(
                                                                                quoteString: quoteString,
                                                                              )),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          48.0),
                                                                  child: position
                                                                              .toString() ==
                                                                          "SwiperPosition.Left"
                                                                      ? Align(
                                                                          alignment:
                                                                              Alignment.topLeft,
                                                                          child:
                                                                              Transform.rotate(
                                                                            angle:
                                                                                -pi / 8,
                                                                            child:
                                                                                Container(
                                                                              height: 70,
                                                                              width: 100,
                                                                              child: Center(
                                                                                child: ImageIcon(
                                                                                  AssetImage('assets/images/icons/dislike.png'),
                                                                                  color: Theme.of(context).primaryColor,
                                                                                  size: 70,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : position.toString() == "SwiperPosition.Right" &&
                                                                              doubleLike == false
                                                                          ? Align(
                                                                              alignment: Alignment.topRight,
                                                                              child: Transform.rotate(
                                                                                angle: pi / 8,
                                                                                child: Container(
                                                                                  height: 70,
                                                                                  width: 100,
                                                                                  child: Center(
                                                                                    child: ImageIcon(
                                                                                      AssetImage('assets/images/icons/like.png'),
                                                                                      color: Theme.of(context).primaryColor,
                                                                                      size: 70,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : position.toString() == "SwiperPosition.Right" && doubleLike == true
                                                                              ? Align(
                                                                                  alignment: Alignment.topCenter,
                                                                                  child: Container(
                                                                                    height: 90,
                                                                                    width: 100,
                                                                                    child: Center(
                                                                                      child: ImageIcon(
                                                                                        AssetImage('assets/images/icons/doublelike.png'),
                                                                                        color: Theme.of(context).primaryColor,
                                                                                        size: 90,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Container(),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }).toList(
                                                        growable: true,
                                                      ),
                                                      threshold: 30,
                                                      maxAngle: 100,
                                                      animationDuration:
                                                          Duration(
                                                              milliseconds:
                                                                  900),
                                                      visibleCount: 5,
                                                      historyCount: 1,
                                                      stackFrom:
                                                          StackFrom.Right,
                                                      translationInterval: 5,
                                                      scaleInterval: 0.08,
                                                      onSwipe: (int index,
                                                          SwiperPosition
                                                              position) async {
                                                        if (position ==
                                                            SwiperPosition
                                                                .Left) {
                                                          mainQuoteIndex =
                                                              mainQuoteIndex +
                                                                  1;
                                                          shopIndex += 1;
                                                          setState(() {
                                                            fourtyCardEnabled =
                                                                false;
                                                            shopIndexCardEnabled =
                                                                false;
                                                          });
                                                          if (mainQuoteIndex ==
                                                              40) {
                                                            mainQuoteIndex = 0;
                                                            setState(() {
                                                              fourtyCardEnabled =
                                                                  true;
                                                            });
                                                          } else if ((shopIndex %
                                                                      30 ==
                                                                  0) &&
                                                              shopIndex != 0) {
                                                            setState(() {
                                                              shopIndexCardEnabled =
                                                                  true;
                                                            });
                                                          } else {
                                                            int removeIndex =
                                                                initialCardKeysList[
                                                                        index]
                                                                    ['index'];

                                                            await updateDislikedUsers(
                                                                    cardKeysList[
                                                                        removeIndex],
                                                                    widget
                                                                        .database)
                                                                .then((value) {
                                                              if (value ==
                                                                  true) {
                                                                Fluttertoast
                                                                    .showToast(
                                                                  gravity:
                                                                      ToastGravity
                                                                          .TOP,
                                                                  webPosition:
                                                                      "right",
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  textColor:
                                                                      Colors
                                                                          .black,
                                                                  msg:
                                                                      "Missed Connection",
                                                                );
                                                              }
                                                            });
                                                            // REMOVE SWIPE CARD FROM LIST
                                                            cardKeysList
                                                                .removeAt(
                                                                    removeIndex);

                                                            userRemoved.clear();
                                                            setState(() {
                                                              rIndex =
                                                                  removeIndex;
                                                              userRemoved.add(
                                                                  initialCardKeysList[
                                                                          index]
                                                                      [
                                                                      'value']);
                                                              initialCardKeysList
                                                                  .removeAt(
                                                                      index);

                                                              globalIndex =
                                                                  index - 1;
                                                              rewindDislike =
                                                                  true;
                                                            });

                                                            if (index == 0) {
                                                              setState(() {
                                                                createInitialCradList();
                                                              });
                                                            }
                                                          }
                                                        } else if (position ==
                                                            SwiperPosition
                                                                .Right) {
                                                          mainQuoteIndex =
                                                              mainQuoteIndex +
                                                                  1;

                                                          shopIndex += 1;

                                                          setState(() {
                                                            fourtyCardEnabled =
                                                                false;
                                                            shopIndexCardEnabled =
                                                                false;
                                                          });
                                                          if (mainQuoteIndex ==
                                                              40) {
                                                            mainQuoteIndex = 0;
                                                            setState(() {
                                                              fourtyCardEnabled =
                                                                  true;
                                                            });
                                                          } else if ((shopIndex %
                                                                      30 ==
                                                                  0) &&
                                                              shopIndex != 0) {
                                                            setState(() {
                                                              shopIndexCardEnabled =
                                                                  true;
                                                            });
                                                          } else {
                                                            int removeIndex =
                                                                initialCardKeysList[
                                                                        index]
                                                                    ['index'];

                                                            doubleLike
                                                                ? updateDoubleLikedUsers(
                                                                    cardKeysList[
                                                                        removeIndex],
                                                                    widget
                                                                        .database)
                                                                : updateLikedUser(
                                                                    cardKeysList[
                                                                        removeIndex],
                                                                    widget
                                                                        .database);

                                                            cardKeysList
                                                                .removeAt(
                                                                    removeIndex);
                                                            userRemoved.clear();
                                                            setState(() {
                                                              rIndex =
                                                                  removeIndex;
                                                              userRemoved.add(
                                                                  initialCardKeysList[
                                                                          index]
                                                                      [
                                                                      'value']);
                                                              initialCardKeysList
                                                                  .removeAt(
                                                                      index);
                                                              globalIndex =
                                                                  globalIndex -
                                                                      1;
                                                              doubleLike =
                                                                  false;
                                                              rewindLike = true;
                                                              Future.delayed(
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  () {
                                                                if (rewindDoubleLike) {
                                                                  rewindLike =
                                                                      false;
                                                                }
                                                              });
                                                            });

                                                            if (index == 0) {
                                                              setState(() {
                                                                createInitialCradList();
                                                              });
                                                            }
                                                          }
                                                        } else {
                                                          debugPrint(
                                                              "onSwipe $index $position");
                                                          setState(() {
                                                            index = index + 1;
                                                          });
                                                        }
                                                      },
                                                      onRewind: (int index,
                                                          SwiperPosition
                                                              position) {
                                                        mainQuoteIndex =
                                                            mainQuoteIndex + 1;
                                                        shopIndex += 1;
                                                        setState(() {
                                                          fourtyCardEnabled =
                                                              false;
                                                          shopIndexCardEnabled =
                                                              false;
                                                        });
                                                        if (mainQuoteIndex ==
                                                            40) {
                                                          mainQuoteIndex = 0;
                                                          setState(() {
                                                            fourtyCardEnabled =
                                                                true;
                                                          });
                                                        } else if ((shopIndex %
                                                                    30 ==
                                                                0) &&
                                                            shopIndex != 0) {
                                                          setState(() {
                                                            shopIndexCardEnabled =
                                                                true;
                                                          });
                                                        } else {
                                                          swipeKey
                                                              .currentContext
                                                              .dependOnInheritedWidgetOfExactType();

                                                          if (widget.pastPurchases ==
                                                                  false &&
                                                              widget.preferences !=
                                                                  "friend") {
                                                            if (rewindIndex <
                                                                freeRewind) {
                                                              if ((4 -
                                                                      rewindIndex) ==
                                                                  0) {
                                                                Fluttertoast.showToast(
                                                                    gravity:
                                                                        ToastGravity
                                                                            .TOP,
                                                                    webPosition:
                                                                        "right",
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    textColor:
                                                                        Colors
                                                                            .black,
                                                                    msg:
                                                                        "You have reached the maximum number of undo's available");
                                                              } else {
                                                                Fluttertoast.showToast(
                                                                    gravity:
                                                                        ToastGravity
                                                                            .TOP,
                                                                    webPosition:
                                                                        "right",
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    textColor:
                                                                        Colors
                                                                            .black,
                                                                    msg:
                                                                        "Undo: ${4 - rewindIndex} remaining");
                                                              }
                                                              initialCardKeysList
                                                                  .insert(
                                                                      initialCardKeysList
                                                                          .length,
                                                                      {
                                                                    'index':
                                                                        rIndex,
                                                                    'value':
                                                                        userRemoved[
                                                                            0]
                                                                  });
                                                              cardKeysList.insert(
                                                                  rIndex,
                                                                  userRemoved[
                                                                      0]);
                                                              if (rewindDislike) {
                                                                widget.database
                                                                    .removeDislikedUsers(
                                                                        userRemoved[
                                                                            0]);
                                                              } else if (rewindLike) {
                                                                widget.database
                                                                    .removeLikedUsers(
                                                                        userRemoved[
                                                                            0]);
                                                              } else if (rewindDoubleLike) {
                                                                widget.database
                                                                    .removeDoubleLikedUsers(
                                                                        userRemoved[
                                                                            0]);
                                                              }
                                                              widget.database
                                                                  .updateRewindCount(
                                                                      rewindIndex +
                                                                          1);

                                                              setState(() {
                                                                userRemoved
                                                                    .clear();
                                                                globalIndex =
                                                                    index + 1;
                                                                rewindLike =
                                                                    false;
                                                                rewindDislike =
                                                                    false;
                                                                rewindDoubleLike =
                                                                    false;
                                                                rewindIndex =
                                                                    rewindIndex +
                                                                        1;
                                                              });

                                                              debugPrint(
                                                                  "onRewind $index $position");
                                                            } else {
                                                              Fluttertoast.showToast(
                                                                  gravity:
                                                                      ToastGravity
                                                                          .TOP,
                                                                  webPosition:
                                                                      "right",
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  textColor:
                                                                      Colors
                                                                          .black,
                                                                  msg:
                                                                      "You have reached the maximum number of undo's available");
                                                              setState(() {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (_) => PurchaseProPopup.create(
                                                                        context,
                                                                        database:
                                                                            widget.database));
                                                              });
                                                            }
                                                          } else {
                                                            initialCardKeysList
                                                                .insert(
                                                                    initialCardKeysList
                                                                        .length,
                                                                    {
                                                                  'index':
                                                                      rIndex,
                                                                  'value':
                                                                      userRemoved[
                                                                          0]
                                                                });
                                                            cardKeysList.insert(
                                                                rIndex,
                                                                userRemoved[0]);
                                                            if (rewindDislike) {
                                                              widget.database
                                                                  .removeDislikedUsers(
                                                                      userRemoved[
                                                                          0]);
                                                            } else if (rewindLike) {
                                                              widget.database
                                                                  .removeLikedUsers(
                                                                      userRemoved[
                                                                          0]);
                                                            } else if (rewindDoubleLike) {
                                                              widget.database
                                                                  .removeDoubleLikedUsers(
                                                                      userRemoved[
                                                                          0]);
                                                            } else {}
                                                            widget.database
                                                                .updateRewindCount(
                                                                    rewindIndex +
                                                                        1);

                                                            setState(() {
                                                              userRemoved
                                                                  .clear();
                                                              globalIndex =
                                                                  index + 1;
                                                              rewindLike =
                                                                  false;
                                                              rewindDislike =
                                                                  false;
                                                              rewindDoubleLike =
                                                                  false;
                                                              rewindIndex =
                                                                  rewindIndex +
                                                                      1;
                                                            });

                                                            debugPrint(
                                                                "onRewind $index $position");
                                                          }
                                                        }
                                                      },
                                                    )
                                                  : Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(30.0),
                                                        child: Text(
                                                          'No users matching your filter, try expanding your search range',
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                            cardKeysList.length != 0
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            25),
                                                    child: Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: <Widget>[
                                                          Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.15,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.15,
                                                            child:
                                                                FloatingActionButton(
                                                                    heroTag:
                                                                        UniqueKey(),
                                                                    backgroundColor:
                                                                        Theme.of(context)
                                                                            .primaryColor,
                                                                    child:
                                                                        ImageIcon(
                                                                      AssetImage(
                                                                          'assets/images/icons/dislike.png'),
                                                                      color: Colors
                                                                          .white,
                                                                      size: 34,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      if (mainQuoteIndex ==
                                                                          40) {
                                                                        swipeKey
                                                                            .currentState
                                                                            .swipeLeft();
                                                                      } else {
                                                                        if (initialCardKeysList.length >
                                                                            0) {
                                                                          swipeKey
                                                                              .currentState
                                                                              .swipeLeft();
                                                                          setState(
                                                                              () {
                                                                            rewindDislike =
                                                                                true;
                                                                          });
                                                                        }
                                                                      }
                                                                    }),
                                                          ),
                                                          Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.15,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.15,
                                                            child:
                                                                FloatingActionButton(
                                                                    heroTag:
                                                                        UniqueKey(),
                                                                    backgroundColor:
                                                                        Theme.of(context)
                                                                            .primaryColor,
                                                                    child:
                                                                        ImageIcon(
                                                                      AssetImage(
                                                                          'assets/images/icons/doublelike.png'),
                                                                      color: Colors
                                                                          .white,
                                                                      size: 34,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      if (mainQuoteIndex ==
                                                                          40) {
                                                                        swipeKey
                                                                            .currentState
                                                                            .swipeRight();
                                                                      } else {
                                                                        if (widget.pastPurchases ==
                                                                                false &&
                                                                            widget.preferences !=
                                                                                "friend") {
                                                                          if (doubleHeartLimitIndex <
                                                                              freeDoubleHeartLimitIndex) {
                                                                            if ((2 - rewindIndex) ==
                                                                                0) {
                                                                              Fluttertoast.showToast(gravity: ToastGravity.TOP, webPosition: "right", backgroundColor: Colors.white, textColor: Colors.black, msg: "You have reached the maximum number of Double Likes");
                                                                              setState(() {
                                                                                showDialog(context: context, builder: (_) => PurchaseProPopup.create(context, database: widget.database));
                                                                              });
                                                                            } else {
                                                                              Fluttertoast.showToast(gravity: ToastGravity.TOP, webPosition: "right", backgroundColor: Colors.white, textColor: Colors.black, msg: "Double Like: ${2 - doubleHeartLimitIndex} remaining");
                                                                            }
                                                                            if (doubleHeartLimitIndex ==
                                                                                0) {
                                                                              widget.database.updateDoubleHeartLimitIndex(doubleHeartLimitIndex + 1);
                                                                            } else {
                                                                              widget.database.updateDoubleHeartLimitIndex(doubleHeartLimitIndex);
                                                                            }

                                                                            setState(() {
                                                                              doubleHeartLimitIndex = doubleHeartLimitIndex + 1;
                                                                            });

                                                                            if (initialCardKeysList.length >
                                                                                0) {
                                                                              swipeKey.currentState.swipeRight();
                                                                              setState(() {
                                                                                doubleLike = true;
                                                                                rewindDoubleLike = true;
                                                                              });
                                                                            }
                                                                          } else {
                                                                            Fluttertoast.showToast(
                                                                                gravity: ToastGravity.TOP,
                                                                                webPosition: "right",
                                                                                backgroundColor: Colors.white,
                                                                                textColor: Colors.black,
                                                                                msg: "You have reached the maximum number of Double Likes");
                                                                            setState(() {
                                                                              showDialog(context: context, builder: (_) => PurchaseProPopup.create(context, database: widget.database));
                                                                            });
                                                                            widget.database.updateDoubleHeartLimitIndex(doubleHeartLimitIndex +
                                                                                1);
                                                                          }
                                                                        } else {
                                                                          if (initialCardKeysList.length >
                                                                              0) {
                                                                            swipeKey.currentState.swipeRight();
                                                                            setState(() {
                                                                              doubleLike = true;
                                                                              rewindDoubleLike = true;
                                                                            });
                                                                          }
                                                                        }
                                                                      }
                                                                    }),
                                                          ),
                                                          Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.15,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.15,
                                                            child:
                                                                FloatingActionButton(
                                                                    heroTag:
                                                                        UniqueKey(),
                                                                    backgroundColor:
                                                                        Theme.of(context)
                                                                            .primaryColor,
                                                                    child:
                                                                        ImageIcon(
                                                                      AssetImage(
                                                                          'assets/images/icons/like.png'),
                                                                      color: Colors
                                                                          .white,
                                                                      size: 34,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      if (mainQuoteIndex ==
                                                                          40) {
                                                                        swipeKey
                                                                            .currentState
                                                                            .swipeRight();
                                                                      } else {
                                                                        if (initialCardKeysList.length >
                                                                            0) {
                                                                          swipeKey
                                                                              .currentState
                                                                              .swipeRight();
                                                                          setState(
                                                                              () {
                                                                            rewindLike =
                                                                                true;
                                                                          });
                                                                        }
                                                                      }
                                                                    }),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            cardKeysList.length != 0 &&
                                                    mainQuoteIndex != 0
                                                ? Align(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child:
                                                        initialCardKeysList
                                                                    .length !=
                                                                0
                                                            ? Container(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.15,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.15,
                                                                child:
                                                                    FloatingActionButton(
                                                                        heroTag:
                                                                            UniqueKey(),
                                                                        backgroundColor: userRemoved.length >
                                                                                0
                                                                            ? Colors
                                                                                .white
                                                                            : Theme.of(context)
                                                                                .primaryColor,
                                                                        child: userRemoved.length >
                                                                                0
                                                                            ? ImageIcon(
                                                                                AssetImage('assets/images/icons/reply.png'),
                                                                                color: Color(0xFFD7AF4F),
                                                                                size: 34,
                                                                              )
                                                                            : Icon(
                                                                                Icons.not_interested,
                                                                                color: Colors.white,
                                                                                size: 34,
                                                                              ),
                                                                        onPressed:
                                                                            () {
                                                                          //         if (((freeRewind -
                                                                          //                     rewindIndex) ==
                                                                          //                 2) &&
                                                                          //             widget.pastPurchases ==
                                                                          //                 false) {
                                                                          //           // setState(() {
                                                                          //           //   exceedSwipes = true;
                                                                          //           // });
                                                                          //           setState(() {
                                                                          //               showDialog(
                                                                          // context: context,
                                                                          // builder: (_) =>
                                                                          //     PurchaseProPopup.create(
                                                                          //         context,
                                                                          //         database:
                                                                          //             widget.database));
                                                                          //           });

                                                                          //         }
                                                                          if (((freeRewind - rewindIndex) == 1) &&
                                                                              widget.pastPurchases == false) {
                                                                            // setState(() {
                                                                            //   exceedSwipes = true;
                                                                            // });
                                                                            Fluttertoast.showToast(
                                                                                gravity: ToastGravity.TOP,
                                                                                webPosition: "right",
                                                                                backgroundColor: Colors.white,
                                                                                textColor: Colors.black,
                                                                                msg: "You have reached the maximum number of undo's available");
                                                                            setState(() {
                                                                              showDialog(context: context, builder: (_) => PurchaseProPopup.create(context, database: widget.database));
                                                                            });
                                                                          }

                                                                          if (!(rewindIndex < freeRewind) &&
                                                                              widget.pastPurchases == false) {
                                                                            Fluttertoast.showToast(
                                                                                gravity: ToastGravity.TOP,
                                                                                webPosition: "right",
                                                                                backgroundColor: Colors.white,
                                                                                textColor: Colors.black,
                                                                                msg: "You have reached the maximum number of undo's available");
                                                                            setState(() {
                                                                              showDialog(context: context, builder: (_) => PurchaseProPopup.create(context, database: widget.database));
                                                                            });
                                                                          }

                                                                          if (userRemoved.length >
                                                                              0) {
                                                                            swipeKey.currentState.rewind();
                                                                          }

                                                                          //  if(exceedSwipes && widget.pastPurchases == false){

                                                                          //  }
                                                                        }),
                                                              )
                                                            : Container(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.15,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.15,
                                                                child:
                                                                    FloatingActionButton(
                                                                  heroTag:
                                                                      UniqueKey(),
                                                                  backgroundColor:
                                                                      Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                  child: Icon(
                                                                    Icons
                                                                        .refresh,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 34,
                                                                  ),
                                                                  onPressed:
                                                                      () {},
                                                                ),
                                                              ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : Scaffold(
                                    backgroundColor: Colors.white,
                                    body: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                Theme.of(context).primaryColor,
                                                Theme.of(context).accentColor
                                              ],
                                              begin: const FractionalOffset(
                                                  1.0, 0.0),
                                              end: const FractionalOffset(
                                                  0.0, 0.7),
                                              stops: [0.3, 1.0],
                                              tileMode: TileMode.clamp)),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      )
                    : Center(
                        child: ListTile(
                          title: RaisedButton(
                            elevation: 16.0,
                            onPressed: () async {
                              Navigator.push(
                                buildContext,
                                MaterialPageRoute(
                                  builder: (_) => ProfileImagesLoader(
                                    data: data,
                                    database: widget.database,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Verify your profile',
                                style: Theme.of(context).textTheme.body2,
                              ),
                            ),
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ))
                : Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Theme.of(context).primaryColor,
                      color: Colors.white,
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
  }
}


//below code is for  undo pop up

//  exceedSwipes && widget.pastPurchases == false
//                                   ? Align(
//                                       alignment: Alignment.center,
//                                       child: InkWell(
//                                         child: Container(
//                                           color: Colors.white.withOpacity(.3),
//                                           child: Dialog(
//                                             insetAnimationCurve:
//                                                 Curves.bounceInOut,
//                                             insetAnimationDuration:
//                                                 Duration(seconds: 2),
//                                             shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(20)),
//                                             backgroundColor: Colors.white,
//                                             child: Container(
//                                               height: MediaQuery.of(context)
//                                                       .size
//                                                       .height *
//                                                   .55,
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceEvenly,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.center,
//                                                 children: [
//                                                   Icon(
//                                                     Icons.error_outline,
//                                                     size: 50,
//                                                     color: Theme.of(context)
//                                                         .primaryColor,
//                                                   ),
//                                                   Text(
//                                                     "you have already used the maximum number of free available swipes.",
//                                                     textAlign: TextAlign.center,
//                                                     style: TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey,
//                                                         fontSize: 20),
//                                                   ),
//                                                   Padding(
//                                                     padding:
//                                                         const EdgeInsets.all(
//                                                             8.0),
//                                                     child: Icon(
//                                                       Icons.lock_outline,
//                                                       size: 120,
//                                                       color: Theme.of(context)
//                                                           .primaryColor,
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     "For rewind more users just subscribe our premium plans.",
//                                                     textAlign: TextAlign.center,
//                                                     style: TextStyle(
//                                                         color: Theme.of(context)
//                                                             .primaryColor,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontSize: 20),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         onTap: () async {
//                                           if (widget.pastPurchases == false) {
//                                             final didRequestPassportMode =
//                                                 await PlatformAlertDialog(
//                                               title: 'More Rewind',
//                                               content:
//                                                   'For rewind more users just subscribe our premium plans. Would you like to get access?',
//                                               defaultActionText: 'Yes',
//                                               cancelActionText: 'Cancel',
//                                             ).show(context);
//                                             if (didRequestPassportMode ==
//                                                 true) {
//                                               //await PlatformAlertDialog(title: 'Pro Mode', content: 'These features are coming soon', defaultActionText: 'Ok').show(context);
//                                               //   Navigator.pop(context);
//                                               showDialog(
//                                                 context: context,
//                                                 builder: (_) =>
//                                                     PurchaseProPopup.create(
//                                                         context,
//                                                         database:
//                                                             widget.database),
//                                               );
//                                             } else {
//                                               setState(() {
//                                                 exceedSwipes = false;
//                                               });
//                                             }
//                                           }
//                                         },
//                                       ),
//                                     )
//                                   : Container()
