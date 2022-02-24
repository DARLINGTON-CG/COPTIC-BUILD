import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:copticmeet/custom_icons/coptic_meet_icons_icons.dart';
import 'package:copticmeet/providers/profile_info_caches.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/utils/color_utils.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ViewProfilePage extends StatefulWidget {
  @override
  _ViewProfilePageState createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  Future<int> calculateAge(Database database) async {
    var reference = await database.getUserDataOnce();
    var values = await reference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      return values;
    });
    var birthDate = DateTime.parse(values['dateOfBirth']);
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  String heightData;
  List<String> heightDefaultList = [
    "45",
    "46",
    "47",
    "48",
    "49",
    "410",
    "411",
    "50",
    "51",
    "52",
    "53",
    "54",
    "55",
    "56",
    "57",
    "58",
    "59",
    "510",
    "511",
    "60",
    "61",
    "62",
    "63",
    "64",
    "65",
    "66",
    "67",
    "68",
    "69",
    "610",
    "611",
    "71"
  ];

  List<String> heightFeetList = ["4", "5", "6", "7"];

  _checkHeightIsInRange({feet, inch}) {
    if (heightDefaultList.contains(feet.toString() + inch.toString())) {
    } else {
      if (heightFeetList.contains(feet)) {
      } else {}
    }
  }

  userHightHelper({userHeight}) {
    List height = [0, 0];

    height[0] =
        (userHeight[0] == null || userHeight[0] == "null") ? 0 : userHeight[0];
    if (height[0].toString().length > 1) {
      height[0] = height[0].toString().substring(0, 1);
    }
    height[1] =
        (userHeight[1] == null || userHeight[1] == "null") ? 0 : userHeight[1];
    if (height[1].toString().length > 2) {
      height[1] = height[1].toString().substring(0, 2);
    }
    heightData = height.join("'") + '"';
  }

  String _favouriteSpellErrorOrNot(String value) {
    if (value == "My favorite bible passage is..." ||
        value == "My fravorite bible passage is..." ||
        value == "My favorite bible passage is…") {
      return "My favorite bible passage is...";
    } else {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.defaultColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context)
              .textTheme
              .body2
              .copyWith(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  // Color(#D7AF4F),
                  Theme.of(context).accentColor,
                ],
                begin: const FractionalOffset(1.0, 0.0),
                end: const FractionalOffset(0.0, 0.7),
                stops: [0.3, 1.0],
                tileMode: TileMode.clamp)),
        child: Consumer<ProfileImageCaches>(builder: (BuildContext context,
            ProfileImageCaches profileCaches, Widget child) {
          var height =
              profileCaches.getUserInfo["height"].toString().split(",");
          _checkHeightIsInRange(
            inch: height != null ? height[1] : 0,
            feet: height != null ? height[0] : 0,
          );
          userHightHelper(userHeight: height != null ? height : [0, 0]);
          return Card(
              elevation: 10,
              margin: EdgeInsets.only(top: 10, bottom: 15, left: 20, right: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              color: Colors.transparent,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Stack(children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(40)),
                                  image: ((profileCaches.cachedState !=
                                              false) &&
                                          profileCaches.userProfiles.isNotEmpty)
                                      ? DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                              profileCaches.userProfiles.first))
                                      : null,

                                  // boxShadow:
                                ),
                                child: ((profileCaches.cachedState != false) &&
                                        profileCaches.userProfiles.isNotEmpty)
                                    ? Container()
                                    : Container(
                                        child: Center(
                                        child: Text(
                                          "No Profile Image",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                              ),
                              Wrap(alignment: WrapAlignment.center, children: [
                                Text(
                                  "${profileCaches.getUserInfo['name']},",
                                  style: TextStyle(
                                      fontFamily: "Papyrus",
                                      fontWeight: FontWeight.normal,
                                      fontSize: 24,
                                      color: Colors.black),
                                ),
                                Text(
                                  profileCaches.getUserInfo.isEmpty
                                      ? "N/A"
                                      : calculateAgeFromCache(profileCaches
                                              .getUserInfo['dateOfBirth'])
                                          .toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: "Papyrus",
                                      fontWeight: FontWeight.normal,
                                      fontSize: 24,
                                      color: Colors.black),
                                ),
                              ]),
                              Text(
                                  profileCaches.getUserInfo["occupation"] ==
                                              "" ||
                                          profileCaches
                                                  .getUserInfo["occupation"] ==
                                              null
                                      ? "-"
                                      : profileCaches.getUserInfo["occupation"]
                                          .toString()
                                          .toLowerCase()
                                          .capitalize(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 17)),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Card(
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              CopticMeetIcons
                                                  .height_coptic_meet,
                                              color: Colors.black,
                                              size: 18,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: profileCaches.getUserInfo[
                                                          'height'] ==
                                                      null || profileCaches.getUserInfo[
                                                          'height'] == "None"
                                                  ? Container()
                                                  : Text(
                                                      heightData,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black,
                                                          fontFamily: "Papyrus",
                                                          fontSize: 18),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: profileCaches.getUserInfo[
                                                        'gender'] ==
                                                    'Male'
                                                ? Icon(
                                                    MdiIcons.genderMale,
                                                    color: Colors.black,
                                                    size: 18,
                                                  )
                                                : Icon(
                                                    MdiIcons.genderFemale,
                                                    color: Colors.black,
                                                    size: 18,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  profileCaches.getUserInfo['educationLevel'] !=
                                              null &&
                                          profileCaches.getUserInfo[
                                                  'educationLevel'] !=
                                              "null" && profileCaches.getUserInfo[
                                                  'educationLevel'] != "None"
                                      ? Card(
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          child: Container(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    CopticMeetIcons
                                                        .education_level_coptic_meet,
                                                    color: Colors.black,
                                                    size: 18,
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      profileCaches.getUserInfo[
                                                              'educationLevel'] ??
                                                          'NA',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black,
                                                          fontFamily: "Papyrus",
                                                          fontSize: 18),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  profileCaches.getUserInfo['starSign'] !=
                                              null &&
                                          profileCaches
                                                  .getUserInfo['starSign'] !=
                                              "null" && profileCaches.getUserInfo['starSign'] != "None"
                                      ? Card(
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          child: Container(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Stack(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Icon(
                                                        CopticMeetIcons
                                                            .star_sign,
                                                        color: Colors.black,
                                                        size: 40,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 35,
                                                                right: 8,
                                                                top: 8,
                                                                bottom: 8),
                                                        child: Text(
                                                          profileCaches
                                                                      .getUserInfo[
                                                                  'starSign'] ??
                                                              'NA',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  "Papyrus",
                                                              fontSize: 18),
                                                          textAlign:
                                                              TextAlign.start,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  profileCaches.getUserInfo['loveLanguage'] !=
                                              null &&
                                          profileCaches.getUserInfo[
                                                  'loveLanguage'] !=
                                              "null" && 
                                              profileCaches.getUserInfo['loveLanguage'] != "None"
                                      ? Visibility(
                                          visible: profileCaches
                                                  .getUserInfo["preferences"] ==
                                              "dating",
                                          child: Card(
                                            elevation: 8,
                                            child: Container(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Stack(
                                                    children: <Widget>[
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        height: 40,
                                                        width: 40,
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.favorite,
                                                            color: Colors.black,
                                                            size: 24,
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 35,
                                                                  right: 8,
                                                                  top: 8,
                                                                  bottom: 8),
                                                          child: Text(
                                                            profileCaches
                                                                        .getUserInfo[
                                                                    'loveLanguage'] ??
                                                                'NA',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    "Papyrus",
                                                                fontSize: 18),
                                                            textAlign:
                                                                TextAlign.start,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  profileCaches.getUserInfo['pets'] != null &&
                                          profileCaches.getUserInfo['pets'] !=
                                              "null" && profileCaches.getUserInfo['pets'] != "None"
                                      ? Card(
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          child: Container(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    CopticMeetIcons.pets_filter,
                                                    color: Colors.black,
                                                    size: 22,
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      profileCaches.getUserInfo[
                                                              'pets'] ??
                                                          'NA',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black,
                                                          fontFamily: "Papyrus",
                                                          fontSize: 18),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  profileCaches.getUserInfo['kids'] != null &&
                                          profileCaches.getUserInfo['kids'] !=
                                              "null" && profileCaches.getUserInfo['kids'] != "None"
                                      ? Visibility(
                                          visible: profileCaches
                                                  .getUserInfo["preferences"] ==
                                              "dating",
                                          child: Card(
                                            elevation: 8,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                            child: Container(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Icon(
                                                      CopticMeetIcons
                                                          .kids_filter,
                                                      color: Colors.black,
                                                      size: 22,
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        profileCaches
                                                                    .getUserInfo[
                                                                'kids'] ??
                                                            'NA',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                "Papyrus",
                                                            fontSize: 18),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  profileCaches.getUserInfo['drink'] != null &&
                                          profileCaches.getUserInfo['drink'] !=
                                              "null" &&  profileCaches.getUserInfo['drink'] != "None"
                                      ? Card(
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          child: Container(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ImageIcon(
                                                    AssetImage(
                                                        'assets/images/icons/drink.png'),
                                                    // color: Color(0xFFD7AF4F),
                                                    size: 28,
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      profileCaches.getUserInfo[
                                                              'drink'] ??
                                                          'NA',
                                                      //  "Never",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black,
                                                          fontFamily: "Papyrus",
                                                          fontSize: 18),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  profileCaches.getUserInfo['smoke'] != null &&
                                          profileCaches.getUserInfo['smoke'] !=
                                              "null" && profileCaches.getUserInfo['smoke'] != "None"
                                      ? Card(
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          child: Container(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: ImageIcon(
                                                      AssetImage(
                                                          'assets/images/icons/smoke.png'),
                                                      // color: Color(0xFFD7AF4F),
                                                      size: 28,
                                                    )),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      profileCaches.getUserInfo[
                                                              'smoke'] ??
                                                          'NA',
                                                      //  "Never",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black,
                                                          fontFamily: "Papyrus",
                                                          fontSize: 18),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  profileCaches.getUserInfo['feminist'] !=
                                              null &&
                                          profileCaches
                                                  .getUserInfo['feminist'] !=
                                              "null" && profileCaches.getUserInfo['feminist'] != "None"
                                      ? Card(
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          child: Container(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: ImageIcon(
                                                      AssetImage(
                                                          'assets/images/icons/feminist.png'),
                                                      // color: Color(0xFFD7AF4F),
                                                      size: 32,
                                                    )),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      profileCaches.getUserInfo[
                                                              'feminist'] ??
                                                          'NA',
                                                      // "No way",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 18,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                              profileCaches.getUserInfo['aboutUser'] != null &&
                                      profileCaches.getUserInfo['aboutUser'] !=
                                          "null" &&
                                      profileCaches.getUserInfo['aboutUser'] !=
                                          ""
                                  ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Text(
                                            profileCaches
                                                    .getUserInfo['aboutUser'] ??
                                                'NA',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              profileCaches.getUserInfo['promptInput'] !=
                                          null &&
                                      profileCaches
                                              .getUserInfo["promptInput"] !=
                                          "null" &&
                                      profileCaches
                                              .getUserInfo["promptInput"] !=
                                          "Null" &&
                                      profileCaches.getUserInfo["promptInput"]
                                              .toString()
                                              .trim() !=
                                          ""
                                  ? Card(
                                      elevation: 8,
                                      margin: EdgeInsets.all(5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, right: 8.0),
                                                child: ImageIcon(
                                                  AssetImage(
                                                      'assets/images/icons/cross.png'),
                                                  // color: Color(0xFFD7AF4F),
                                                  size: 15,
                                                )),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      // profileCaches.getUserInfo[
                                                      //         'chosenPrompt'] ??
                                                      //     'NA',
                                                      _favouriteSpellErrorOrNot(
                                                          profileCaches
                                                                  .getUserInfo[
                                                              'chosenPrompt']),

                                                      softWrap: true,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      // textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  // Spacer(),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            right: 8.0),
                                                    child: Text(
                                                      profileCaches.getUserInfo[
                                                              'promptInput'] ??
                                                          'NA',
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              profileCaches.getUserInfo['anotherPromptInput'] !=
                                          null &&
                                      profileCaches.getUserInfo[
                                              "anotherPromptInput"] !=
                                          "null" &&
                                      profileCaches.getUserInfo[
                                              "anotherPromptInput"] !=
                                          "Null" &&
                                      profileCaches
                                              .getUserInfo["anotherPromptInput"]
                                              .toString()
                                              .trim() !=
                                          ""
                                  ? Card(
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ImageIcon(
                                                  AssetImage(
                                                      'assets/images/icons/cross.png'),
                                                  // color: Color(0xFFD7AF4F),
                                                  size: 15,
                                                )),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            right: 8.0),
                                                    child: Text(
                                                      profileCaches.getUserInfo[
                                                              'anotherPrompt'] ??
                                                          'NA',
                                                      softWrap: true,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      // textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  // Spacer(),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      profileCaches.getUserInfo[
                                                              'anotherPromptInput'] ??
                                                          'NA',
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              profileCaches.getUserInfo[
                                              'secondAnotherPromptInput'] !=
                                          null &&
                                      profileCaches.getUserInfo[
                                              "secondAnotherPromptInput"] !=
                                          "null" &&
                                      profileCaches.getUserInfo[
                                              "secondAnotherPromptInput"] !=
                                          "Null" &&
                                      profileCaches.getUserInfo[
                                                  "secondAnotherPromptInput"]
                                              .toString()
                                              .trim() !=
                                          ""
                                  ? Card(
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ImageIcon(
                                                  AssetImage(
                                                      'assets/images/icons/cross.png'),
                                                  // color: Color(0xFFD7AF4F),
                                                  size: 15,
                                                )),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            right: 8.0),
                                                    child: Text(
                                                      profileCaches.getUserInfo[
                                                              'secondAnotherPrompt'] ??
                                                          'NA',
                                                      softWrap: true,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      // textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  // Spacer(),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      profileCaches.getUserInfo[
                                                              'secondAnotherPromptInput'] ??
                                                          'NA',
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Icon(
                                                CopticMeetIcons.location_2,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Text(
                                              "Your Location",
                                              style: TextStyle(
                                                  fontFamily: "Papyrus",
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          )
                                        ]),
                                  ),
                                  (profileCaches.getUserInfo['locationName'] !=
                                              null &&
                                          profileCaches.getUserInfo[
                                                  'locationName'] !=
                                              "null")
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            left: 12.0,
                                          ),
                                          child: Text(
                                            "${profileCaches.getUserInfo['locationName']}",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontFamily: "Papyrus",
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(left: 12.0),
                                          child: Text(
                                            'N/A',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontFamily: "Papyrus",
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                  SizedBox(
                                    height: 20,
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ]))));
        }),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
