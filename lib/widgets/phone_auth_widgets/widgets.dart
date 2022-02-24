import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:copticmeet/custom_icons/coptic_meet_icons_icons.dart';
import 'package:copticmeet/data_models/country_model.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/services/location/location.dart';
import 'package:copticmeet/services/storage/storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhoneAuthWidgets {
  static Widget getLogo({String logoPath, double height}) => Material(
        type: MaterialType.transparency,
        elevation: 10.0,
        child: Image.asset(logoPath, height: height),
      );

  static Widget searchCountry(TextEditingController controller) => Padding(
        padding:
            const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 2.0, right: 8.0),
        child: Card(
          child: TextFormField(
            autofocus: true,
            controller: controller,
            decoration: InputDecoration(
                hintText: 'Search your country',
                contentPadding: const EdgeInsets.only(
                    left: 5.0, right: 5.0, top: 10.0, bottom: 10.0),
                border: InputBorder.none),
          ),
        ),
      );

  static Widget phoneNumberField(TextEditingController controller,
          String prefix, FocusNode focusNode) =>
      Card(
        child: TextFormField(
          controller: controller,
          autofocus: true,
          focusNode: focusNode,
          keyboardType: TextInputType.phone,
          key: Key('EnterPhone-TextFormField'),
          decoration: InputDecoration(
            border: InputBorder.none,
            errorMaxLines: 1,
            prefix: Text("  " + prefix + "  "),
          ),
        ),
      );

  static Widget selectableWidget(
          Country country, Function(Country) selectThisCountry) =>
      Material(
        color: Colors.white,
        type: MaterialType.canvas,
        child: InkWell(
          onTap: () => selectThisCountry(country), //selectThisCountry(country),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
            child: Text(
              "  " +
                  country.flag +
                  "  " +
                  country.name +
                  " (" +
                  country.dialCode +
                  ")",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );

  static Widget selectCountryDropDown(Country country, Function onPressed) =>
      Card(
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.only(
                left: 4.0, right: 4.0, top: 8.0, bottom: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  ' ${country.flag}  ${country.name} ',
                  style: TextStyle(
                      fontFamily: "Papyrus", fontSize: 15, color: Colors.black),
                )),
                Icon(Icons.arrow_drop_down, size: 24.0)
              ],
            ),
          ),
        ),
      );

  static Widget subTitle(String text) => Align(
      alignment: Alignment.centerLeft,
      child: Text(' $text',
          style: TextStyle(
              fontFamily: "Papyrus", fontSize: 15, color: Colors.black)));
}

int calculateAgeFromCache(var birthDay)
{
  var birthDate = DateTime.parse(birthDay);
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

Future<int> calculateAgeOfOtherUser(user) async {
  try {
    var birthDayString = user['dateOfBirth'];
    if (birthDayString == null || birthDayString == "null") {
      return 0;
    }
    var birthDate = DateTime.parse(birthDayString);

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
  } catch (err) {

    return 0;
  }
}

Future getTownInfo(String position) async {
  var _coordinateList = position.split(',');
  List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(
      double.parse(_coordinateList[0]), double.parse(_coordinateList[1]));

  return "${placemark[0].locality}, ${placemark[0].administrativeArea}";
}

Future checkValidEntries(List valuesToCheck, Database database) async {
  List _completedList = [];
  var reference = await database.getUserDataOnce();
  var values = await reference.once().then((DataSnapshot snapshot) {
    Map<dynamic, dynamic> values = snapshot.value;
    return values;
  });
  for (var i = 0; i < valuesToCheck.length; i++) {
    if (values[valuesToCheck[i]] == "null" ||
        values[valuesToCheck[i]] == "null,null") {
      _completedList.add(true);
    } else {
      _completedList.add(false);
    }
  }
  if (_completedList.contains(true)) {
    return true;
  } else {
    return false;
  }
}

class MatchCardPopup extends StatefulWidget {
  MatchCardPopup(
      {Key key,
      @required this.location,
      @required this.database,
      @required this.storage,
      @required this.matchID,
      @required this.accountLocation,
      @required this.userID,
      this.preferences,
      @required this.onMessage})
      : super(key: key);
  final Location location;
  final Database database;
  final Storage storage;
  final matchID;
  final String preferences;
  final accountLocation;
  final userID;
  final VoidCallback onMessage;

  @override
  _MatchCardPopupState createState() => _MatchCardPopupState();
}

class _MatchCardPopupState extends State<MatchCardPopup> {
  int buttonStatus = 0;
  var userData;
  bool loading = true;
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

  _checkHeightIsInRange({feet, inch}) {
    if (heightDefaultList.contains(feet.toString() + inch.toString())) {
       } else {
           if (heightFeetList.contains(feet)) {
           } else {
           }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.database.buildingUserCardProfile(widget.matchID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var userData = snapshot.data;

            _checkHeightIsInRange(
                inch: userData.value["height"].toString().split(",")[1],
                feet: userData.value["height"].toString().split(",")[0]);
            userHightHelper(
                userHeight: userData.value["height"].toString().split(","));
                    return Card(
              elevation: 0.2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: MediaQuery.of(context).size.height / 1.3,
                  child: Stack(children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          FutureBuilder(
                              future: widget.storage.getUserProfilePictures(
                                  widget.database, widget.matchID),
                              builder: (BuildContext context, listURLs) {
                                if (listURLs.hasData) {
                                  List images = List.generate(
                                      listURLs.data.length, (index) {
                                    return CachedNetworkImageProvider(
                                      listURLs.data[index],
                                    );
                                  });
                                  //DEVMARK
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Stack(children: [
                                      Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              3,
                                          child: images.length == 0
                                              ? Container()
                                              : Carousel(
                                                  images: images,
                                                  boxFit: BoxFit.cover,
                                                  autoplay: true,
                                                  autoplayDuration:
                                                      Duration(seconds: 5),
                                                  dotSize: 4.0,
                                                  onImageTap: (i) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Scaffold(
                                                          appBar: AppBar(),
                                                          body: PhotoViewGallery
                                                              .builder(
                                                                  scrollPhysics:
                                                                      const BouncingScrollPhysics(),
                                                                  builder: (context,
                                                                          idx) =>
                                                                      PhotoViewGalleryPageOptions(
                                                                        imageProvider:
                                                                            images[idx],
                                                                        initialScale:
                                                                            PhotoViewComputedScale.contained,
                                                                        minScale:
                                                                            PhotoViewComputedScale.contained *
                                                                                (0.5 + idx / 10),
                                                                        maxScale:
                                                                            PhotoViewComputedScale.covered *
                                                                                1.1,
                                                                      ),
                                                                  itemCount: images
                                                                      .length),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  dotSpacing: 15.0,
                                                  dotColor: Theme.of(context)
                                                      .accentColor,
                                                  indicatorBgPadding: 5.0,
                                                  dotBgColor: Colors.white
                                                      .withOpacity(0.2),
                                                )),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: FutureBuilder(
                                              future: calculateAgeOfOtherUser(
                                                  userData.value),
                                              builder:
                                                  (BuildContext context, age) {
                                                return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    userData.value['name'] !=
                                                                null &&
                                                            userData.value[
                                                                    'name'] !=
                                                                "null"
                                                        ? Text(
                                                            '${toBeginningOfSentenceCase(userData.value['name'].toString().split(" ")[0].toString())}, ${age.data}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 24),
                                                          )
                                                        : Text(
                                                            'Zoichi, ${age.data}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 24),
                                                          ),
                                                    Text(
                                                      '${userData.value['occupation']}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ),
                                      ),
                                    ]),
                                  );
                                } else {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 4,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.black,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                              }),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: <Widget>[
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
                                            CopticMeetIcons.height_coptic_meet,
                                            color: Colors.black,
                                            size: 18,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: userData.value['height'] ==
                                                    null
                                                ? Container()
                                                : Text(
                                                    heightData,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 18),
                                                    textAlign: TextAlign.start,
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
                                          child:
                                              userData.value['gender'] == 'Male'
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
                                userData.value['educationLevel'] != null &&
                                        userData.value['educationLevel'] !=
                                            "null" && userData.value['educationLevel'] != "None"
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
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    userData?.value[
                                                            'educationLevel'] ??
                                                        'NA',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 18),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                userData.value['starSign'] != null &&
                                        userData.value['starSign'] != "null"
                                        &&  userData.value['starSign'] != "None"
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
                                                      CopticMeetIcons.star_sign,
                                                      color: Colors.black,
                                                      size: 40,
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 35,
                                                              right: 8,
                                                              top: 8,
                                                              bottom: 8),
                                                      child: Text(
                                                        userData?.value[
                                                                'starSign'] ??
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
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                userData.value['loveLanguage'] != null &&
                                        userData.value['loveLanguage'] !=
                                            "null" && userData.value['loveLanguage'] != "None" &&
                                        widget.preferences != null
                                    ? Visibility(
                                        visible: widget.preferences == "dating",
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
                                                          const EdgeInsets.all(
                                                              2.0),
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
                                                          userData?.value[
                                                                  'loveLanguage'] ??
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
                                        ),
                                      )
                                    : Container(),
                                userData.value['pets'] != null &&
                                        userData.value['pets'] != "null" &&
                                        userData.value['pets'] != "None"

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
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    userData?.value['pets'] ??
                                                        'NA',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 18),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                userData.value['kids'] != null &&
                                        userData.value['kids'] != "null"
                                        &&
                                        userData.value['kids'] != "None"
                                    ? Visibility(
                                        visible: widget.preferences == "dating",
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
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    CopticMeetIcons.kids_filter,
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
                                                      userData?.value['kids'] ??
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
                                        ),
                                      )
                                    : Container(),
                                userData?.value['drink'] != null &&
                                        userData?.value['drink'] != "null" &&
                                        userData?.value['drink'] != "None"
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
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    userData?.value['drink'] ??
                                                        'NA',
                                                    //  "Never",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 18),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                userData.value['smoke'] != null &&
                                        userData.value['smoke'] != "null"
                                        && userData.value['smoke'] != "None"
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
                                                        'assets/images/icons/smoke.png'),
                                                    // color: Color(0xFFD7AF4F),
                                                    size: 28,
                                                  )),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    userData?.value['smoke'] ??
                                                        'NA',
                                                    //  "Never",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 18),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                userData.value['feminist'] != null &&
                                        userData.value['feminist'] != "null" 
                                        &&  userData.value['feminist'] != "None"
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
                                                        'assets/images/icons/feminist.png'),
                                                    // color: Color(0xFFD7AF4F),
                                                    size: 32,
                                                  )),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    userData?.value[
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
                                                    textAlign: TextAlign.start,
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
                          ),
                          userData.value['aboutUser'] != null &&
                                  userData.value['aboutUser'] != "null" &&
                                  userData.value['aboutUser'] != ""
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Text(
                                        userData?.value['aboutUser'] ?? 'NA',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          userData.value['promptInput'] != null &&
                                  userData.value["promptInput"] != "null" &&
                                  userData.value["promptInput"] != "Null" && userData.value["promptInput"] != ""
                              ? Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
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
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  userData?.value[
                                                          'chosenPrompt'] ??
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
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, right: 8.0),
                                                child: Text(
                                                  userData?.value[
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
                          userData.value['anotherPromptInput'] != null &&
                                  userData.value["anotherPromptInput"] !=
                                      "null" &&
                                  userData.value["anotherPromptInput"] != "Null"
                                  && userData.value["anotherPromptInput"] != ""
                              ? Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Padding(
                                            padding: const EdgeInsets.all(8.0),
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
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, right: 8.0),
                                                child: Text(
                                                  userData?.value[
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
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  userData?.value[
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Icon(
                                            CopticMeetIcons.location_2,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          (userData.value['name'] != null &&
                                                      userData.value['name'] !=
                                                          "null"
                                                  ? toBeginningOfSentenceCase(
                                                      userData.value['name']
                                                          .toString()
                                                          .split(" ")[0]
                                                          .toString())
                                                  : "Zoichi") +
                                              "'s Location",
                                          style: TextStyle(
                                              fontFamily: "Papyrus",
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      )
                                    ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: FutureBuilder(
                                    future:
                                        getTownInfo(userData.value['location']),
                                    builder: (BuildContext context, townData) {
                                      if (townData.hasData) {
                                            return Text(
                                          '${townData.data}',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontFamily: "Papyrus",
                                              fontSize: 16),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, bottom: 17),
                                child: FutureBuilder(
                                    future: widget.location.calculateDistance(
                                        userData.value['location'],
                                        widget.accountLocation),
                                    builder:
                                        (BuildContext context, distanceAway) {
                                      if (distanceAway.hasData) {
                                        var distance = distanceAway.data / 1609;
                                        return Text(
                                          '~ ${distance.round()} miles away',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontFamily: "Papyrus",
                                              fontSize: 16),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(50.0),
                                child: RaisedButton(
                                  elevation: 16.0,
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    widget.onMessage();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Text(
                                          'Message',
                                          style:
                                              Theme.of(context).textTheme.body2,
                                        ),
                                        SizedBox(width: 20),
                                        Icon(CopticMeetIcons.send_coptic_meet)
                                      ],
                                    ),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            );
          } else {
            return Card(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: MediaQuery.of(context).size.height / 1.3,
                ),
              ),
            );
          }
        });
  }
}

void updateLikedUser(userID, Database database) async {
  var currentLikedUsers = await database.getSpecificUserValues('usersLiked');
  List currentLikedUsersList = json.decode(currentLikedUsers.value);
  currentLikedUsersList.add(userID);
  database.updateUserDetails(
      {"usersLiked": "${json.encode(currentLikedUsersList)}"});
}

Future<bool> updateDislikedUsers(userID, Database database) async {
  var currentDislikedUsers =
      await database.getSpecificUserValues('usersDisliked');
  List currentDislikedUsersList = await json.decode(currentDislikedUsers.value);
  currentDislikedUsersList.add(userID);
  database.updateUserDetails(
      {"usersDisliked": "${json.encode(currentDislikedUsersList)}"});

  return await missedConnection(userID, database);
}

Future<bool> missedConnection(userID, Database database) async {
  var currentDislikedUsers = await database.getSpecificUserValues('newLikes');
  List currentDislikedUsersList = await json.decode(currentDislikedUsers.value);

  var isMissed = currentDislikedUsersList.contains(userID);

  if (isMissed) {
    return true;
  } else {
    return false;
  }
}

void updateDoubleLikedUsers(userID, Database database) async {
  var currentDoubleLikedUsers =
      await database.getSpecificUserValues('usersDoubleLiked');
  List currentDoubleLikedUsersList =
      await json.decode(currentDoubleLikedUsers.value);

  currentDoubleLikedUsersList.add(userID);
  database.updateUserDetails(
      {"usersDoubleLiked": "${json.encode(currentDoubleLikedUsersList)}"});
}

void _updatePopupLikedUser(userID, Database database) async {
  var currentLikedUsers = await database.getSpecificUserValues('usersLiked');
  List currentLikedUsersList = json.decode(currentLikedUsers.value);
  currentLikedUsersList.add(userID);
  database.updateUserDetails(
      {"usersLiked": "${json.encode(currentLikedUsersList)}"});
}

void _updatePopupDislikedUsers(userID, Database database) async {
  var currentDislikedUsers =
      await database.getSpecificUserValues('usersDisliked');
  List currentDislikedUsersList = await json.decode(currentDislikedUsers.value);
  currentDislikedUsersList.add(userID);
  database.updateUserDetails(
      {"usersDisliked": "${json.encode(currentDislikedUsersList)}"});
}

void _updatePopupDoubleLikedUsers(userID, Database database) async {
  var currentDoubleLikedUsers =
      await database.getSpecificUserValues('usersDoubleLiked');
  List currentDoubleLikedUsersList =
      await json.decode(currentDoubleLikedUsers.value);
  currentDoubleLikedUsersList.add(userID);
  database.updateUserDetails(
      {"usersDoubleLiked": "${json.encode(currentDoubleLikedUsersList)}"});
}

class PopupProfileCard extends StatefulWidget {
  PopupProfileCard(
      {Key key,
      @required this.location,
      @required this.database,
      @required this.storage,
      @required this.userID,
      @required this.preferences,
      @required this.accountLocation})
      : super(key: key);
  final Location location;
  final Database database;
  final Storage storage;
  final String preferences;
  final userID;
  final accountLocation;

  @override
  _PopupProfileCardState createState() => _PopupProfileCardState();
}

class _PopupProfileCardState extends State<PopupProfileCard> {
  int buttonStatus = 0;
  var userData;
  bool loading = true;
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

  _checkHeightIsInRange({feet, inch}) {
    if (heightDefaultList.contains(feet.toString() + inch.toString())) {
        } else {
         if (heightFeetList.contains(feet)) {
        } else {
            }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.database.buildingUserCardProfile(widget.userID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var userData = snapshot.data;

            _checkHeightIsInRange(
                inch: userData.value["height"].toString().split(",")[1],
                feet: userData.value["height"].toString().split(",")[0]);
            userHightHelper(
                userHeight: userData.value["height"].toString().split(","));
             return Card(
              elevation: 0.2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: MediaQuery.of(context).size.height / 1.3,
                  child: Stack(children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          FutureBuilder(
                              future: widget.storage.getUserProfilePictures(
                                  widget.database, widget.userID),
                              builder: (BuildContext context, listURLs) {
                                if (listURLs.hasData) {
                                  List images = List.generate(
                                      listURLs.data.length, (index) {
                                    return CachedNetworkImageProvider(
                                      listURLs.data[index],
                                    );
                                  });
                                  //DEVMARK
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Stack(children: [
                                      Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              3,
                                          child: images.length == 0
                                              ? Container()
                                              : Carousel(
                                                  images: images,
                                                  boxFit: BoxFit.cover,
                                                  autoplay: true,
                                                  autoplayDuration:
                                                      Duration(seconds: 5),
                                                  dotSize: 4.0,
                                                  onImageTap: (i) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Scaffold(
                                                          appBar: AppBar(),
                                                          body: PhotoViewGallery
                                                              .builder(
                                                                  scrollPhysics:
                                                                      const BouncingScrollPhysics(),
                                                                  builder: (context,
                                                                          idx) =>
                                                                      PhotoViewGalleryPageOptions(
                                                                        imageProvider:
                                                                            images[idx],
                                                                        initialScale:
                                                                            PhotoViewComputedScale.contained,
                                                                        minScale:
                                                                            PhotoViewComputedScale.contained *
                                                                                (0.5 + idx / 10),
                                                                        maxScale:
                                                                            PhotoViewComputedScale.covered *
                                                                                1.1,
                                                                      ),
                                                                  itemCount: images
                                                                      .length),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  dotSpacing: 15.0,
                                                  dotColor: Theme.of(context)
                                                      .accentColor,
                                                  indicatorBgPadding: 5.0,
                                                  dotBgColor: Colors.white
                                                      .withOpacity(0.2),
                                                )),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: FutureBuilder(
                                              future: calculateAgeOfOtherUser(
                                                  userData.value),
                                              builder:
                                                  (BuildContext context, age) {
                                                return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    userData.value['name'] !=
                                                                null &&
                                                            userData.value[
                                                                    'name'] !=
                                                                "null"
                                                        ? Text(
                                                            '${toBeginningOfSentenceCase(userData.value['name'].toString().split(" ")[0].toString())}, ${age.data}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 24),
                                                          )
                                                        : Text(
                                                            'Zoichi, ${age.data}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 24),
                                                          ),
                                                    Text(
                                                      '${userData.value['occupation']}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ),
                                      ),
                                    ]),
                                  );
                                } else {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 4,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.black,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                              }),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: <Widget>[
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
                                            CopticMeetIcons.height_coptic_meet,
                                            color: Colors.black,
                                            size: 18,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: userData.value['height'] ==
                                                    null
                                                ? Container()
                                                : Text(
                                                    heightData,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 18),
                                                    textAlign: TextAlign.start,
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
                                          child:
                                              userData.value['gender'] == 'Male'
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
                                userData.value['educationLevel'] != null &&
                                        userData.value['educationLevel'] !=
                                            "null"
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
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    userData?.value[
                                                            'educationLevel'] ??
                                                        'NA',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 18),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                userData.value['starSign'] != null &&
                                        userData.value['starSign'] != "null"
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
                                                      CopticMeetIcons.star_sign,
                                                      color: Colors.black,
                                                      size: 40,
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 35,
                                                              right: 8,
                                                              top: 8,
                                                              bottom: 8),
                                                      child: Text(
                                                        userData?.value[
                                                                'starSign'] ??
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
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                userData.value['loveLanguage'] != null &&
                                        userData.value['loveLanguage'] != "null"
                                    ? Visibility(
                                        visible: widget.preferences == "dating",
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
                                                          const EdgeInsets.all(
                                                              2.0),
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
                                                          userData?.value[
                                                                  'loveLanguage'] ??
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
                                        ),
                                      )
                                    : Container(),
                                userData.value['pets'] != null &&
                                        userData.value['pets'] != "null"
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
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    userData?.value['pets'] ??
                                                        'NA',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 18),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                userData.value['kids'] != null &&
                                        userData.value['kids'] != "null"
                                    ? Visibility(
                                        visible: widget.preferences == "dating",
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
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    CopticMeetIcons.kids_filter,
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
                                                      userData?.value['kids'] ??
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
                                        ),
                                      )
                                    : Container(),
                                userData?.value['drink'] != null &&
                                        userData?.value['drink'] != "null"
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
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    userData?.value['drink'] ??
                                                        'NA',
                                                    //  "Never",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 18),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                userData.value['smoke'] != null &&
                                        userData.value['smoke'] != "null"
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
                                                        'assets/images/icons/smoke.png'),
                                                    // color: Color(0xFFD7AF4F),
                                                    size: 28,
                                                  )),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    userData?.value['smoke'] ??
                                                        'NA',
                                                    //  "Never",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontFamily: "Papyrus",
                                                        fontSize: 18),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                userData.value['feminist'] != null &&
                                        userData.value['feminist'] != "null"
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
                                                        'assets/images/icons/feminist.png'),
                                                    // color: Color(0xFFD7AF4F),
                                                    size: 32,
                                                  )),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    userData?.value[
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
                                                    textAlign: TextAlign.start,
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
                          ),
                          userData.value['aboutUser'] != null &&
                                  userData.value['aboutUser'] != "null" &&
                                  userData.value['aboutUser'] != ""
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Text(
                                        userData?.value['aboutUser'] ?? 'NA',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          userData.value['promptInput'] != null &&
                                  userData.value["promptInput"] != "null" &&
                                  userData.value["promptInput"] != "Null"
                              ? Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
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
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  userData?.value[
                                                          'chosenPrompt'] ??
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
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, right: 8.0),
                                                child: Text(
                                                  userData?.value[
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
                          userData.value['anotherPromptInput'] != null &&
                                  userData.value["anotherPromptInput"] !=
                                      "null" &&
                                  userData.value["anotherPromptInput"] != "Null"
                              ? Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Padding(
                                            padding: const EdgeInsets.all(8.0),
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
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, right: 8.0),
                                                child: Text(
                                                  userData?.value[
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
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  userData?.value[
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Icon(
                                            CopticMeetIcons.location_2,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          (userData.value['name'] != null &&
                                                      userData.value['name'] !=
                                                          "null"
                                                  ? toBeginningOfSentenceCase(
                                                      userData.value['name']
                                                          .toString()
                                                          .split(" ")[0]
                                                          .toString())
                                                  : "Zoichi") +
                                              "'s Location",
                                          style: TextStyle(
                                              fontFamily: "Papyrus",
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      )
                                    ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: FutureBuilder(
                                    future:
                                        getTownInfo(userData.value['location']),
                                    builder: (BuildContext context, townData) {
                                      if (townData.hasData) {
                                        return Text(
                                          '${townData.data}',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontFamily: "Papyrus",
                                              fontSize: 16),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, bottom: 17),
                                child: FutureBuilder(
                                    future: widget.location.calculateDistance(
                                        userData.value['location'],
                                        widget.accountLocation),
                                    builder:
                                        (BuildContext context, distanceAway) {
                                      if (distanceAway.hasData) {
                                        var distance = distanceAway.data / 1609;
                                        return Text(
                                          '~ ${distance.round()} miles away',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontFamily: "Papyrus",
                                              fontSize: 16),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          child: FloatingActionButton(
                                              heroTag: UniqueKey(),
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              child: ImageIcon(
                                                AssetImage(
                                                    'assets/images/icons/dislike.png'),
                                                color: Colors.white,
                                                size: 34,
                                              ),
                                              onPressed: () {
                                                _updatePopupDislikedUsers(
                                                    widget.userID,
                                                    widget.database);
                                                Navigator.pop(context);
                                              }),
                                        ),
                                        // GestureDetector(
                                        //   onTap: () {
                                        //     _updatePopupDislikedUsers(
                                        //         widget.userID, widget.database);
                                        //     Navigator.pop(context);
                                        //   },
                                        //   child: Padding(
                                        //     padding: const EdgeInsets.only(top: 50),
                                        //     child: Container(
                                        //       decoration: BoxDecoration(
                                        //         shape: BoxShape.circle,
                                        //         color:
                                        //             Theme.of(context).primaryColor,
                                        //       ),
                                        //       width: 70,
                                        //       height: 70,
                                        //       child: Icon(
                                        //         CopticMeetIcons.left_coptic_meet,
                                        //         color: Colors.white,
                                        //         size: 40,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),

                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          child: FloatingActionButton(
                                              heroTag: UniqueKey(),
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              child: ImageIcon(
                                                AssetImage(
                                                    'assets/images/icons/doublelike.png'),
                                                color: Colors.white,
                                                size: 34,
                                              ),
                                              onPressed: () {
                                                _updatePopupDoubleLikedUsers(
                                                    widget.userID,
                                                    widget.database);
                                                Navigator.pop(context);
                                              }),
                                        ),
                                        // GestureDetector(
                                        //   onTap: () {
                                        //     _updatePopupDoubleLikedUsers(
                                        //         widget.userID, widget.database);
                                        //     Navigator.pop(context);
                                        //   },
                                        //   child: Padding(
                                        //     padding:
                                        //         const EdgeInsets.only(bottom: 50),
                                        //     child: ClipRRect(
                                        //       borderRadius:
                                        //           BorderRadius.circular(10),
                                        //       child: Container(
                                        //         color:
                                        //             Theme.of(context).primaryColor,
                                        //         width: 50,
                                        //         height: 50,
                                        //         child: Icon(
                                        //           CopticMeetIcons.right_coptic_meet,
                                        //           color:
                                        //               Theme.of(context).accentColor,
                                        //           size: 28,
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          child: FloatingActionButton(
                                              heroTag: UniqueKey(),
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              child: ImageIcon(
                                                AssetImage(
                                                    'assets/images/icons/like.png'),
                                                color: Colors.white,
                                                size: 34,
                                              ),
                                              onPressed: () {
                                                _updatePopupLikedUser(
                                                    widget.userID,
                                                    widget.database);
                                                Navigator.pop(context);
                                              }),
                                        ),
                                        // GestureDetector(
                                        //   onTap: () {
                                        //     _updatePopupLikedUser(
                                        //         widget.userID, widget.database);
                                        //     Navigator.pop(context);
                                        //   },
                                        //   child: Padding(
                                        //     padding: const EdgeInsets.only(top: 50),
                                        //     child: Container(
                                        //       decoration: BoxDecoration(
                                        //         shape: BoxShape.circle,
                                        //         color:
                                        //             Theme.of(context).primaryColor,
                                        //       ),
                                        //       width: 70,
                                        //       height: 70,
                                        //       child: Icon(
                                        //         CopticMeetIcons.right_coptic_meet,
                                        //         color: Colors.white,
                                        //         size: 40,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ]),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            );
          } else {
            return Card(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: MediaQuery.of(context).size.height / 1.3,
                ),
              ),
            );
          }
        });
  }
}

class NewMatchPopupCard extends StatefulWidget {
  NewMatchPopupCard(
      {Key key,
      @required this.location,
      @required this.database,
      @required this.storage,
      @required this.matchID,
      @required this.accountLocation,
      @required this.userID,
      this.preferences,
      @required this.onMessage})
      : super(key: key);
  final Location location;
  final Database database;
  final Storage storage;
  final matchID;
  final String preferences;
  final accountLocation;
  final userID;
  final VoidCallback onMessage;
  @override
  _NewMatchPopupCardState createState() => _NewMatchPopupCardState();
}

class _NewMatchPopupCardState extends State<NewMatchPopupCard> {
  int buttonStatus = 0;
  var userData;
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.database.buildingUserCardProfile(widget.userID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var userData = snapshot.data;

            return Card(
              elevation: 0.2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: MediaQuery.of(context).size.height / 1.3,
                  child: Stack(children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ImageIcon(
                            AssetImage('assets/images/icons/match.png'),
                            color: Theme.of(context).primaryColor,
                            size: 170,
                          ),
                          //  Center(
                          //    child: Padding(
                          //                   padding:
                          //                       const EdgeInsets.only(left: 10.0,right: 10),
                          //                   child: Text(
                          //                     ("You and "+ ( userData.value['name'] != null &&
                          //                                 userData.value['name'] !=
                          //                                     "null"
                          //                             ? toBeginningOfSentenceCase(
                          //                                 userData.value['name']
                          //                                     .toString()
                          //                                     .split(" ")[0]
                          //                                     .toString())
                          //                             : "Zoichi") ) +
                          //                         " have liked each other.",
                          //                     style: TextStyle(
                          //                         fontFamily: "Papyrus",
                          //                         fontSize: 18,
                          //                         fontWeight: FontWeight.normal),
                          //                   ),
                          //                 ),
                          //  ),
                          FutureBuilder<List>(
                            future: widget.database
                                .getMatchedUserLikedImages(widget.matchID),
                            builder: (context, likedImg) {
                              if (likedImg.data == null) {
                                return Container();
                              } else {
                                return Container(
                                  width: double.infinity,
                                  child: ListView.builder(
                                      itemCount: likedImg.data.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          height: 80.0,
                                          width: 80.0,
                                          padding: EdgeInsets.all(4.0),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              likedImg.data[index],
                                              width: 80.0,
                                              height: 80.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      }),
                                );
                              }
                            },
                          ),
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: FutureBuilder(
                                      future: widget.storage
                                          .getUserProfilePictures(
                                              widget.database, widget.userID),
                                      builder:
                                          (BuildContext context, listURLs) {
                                        if (listURLs.hasData) {
                                          //DEVMARK
                                          return Center(
                                            child: Container(
                                              width: 70,
                                              height: 70,
                                              child: Card(
                                                elevation: 2,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(30.0),
                                                  ),
                                                ),
                                                child: Container(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    child: CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      imageUrl: listURLs.data
                                                                  .length ==
                                                              0
                                                          ? ""
                                                          : "${listURLs.data[0]}",
                                                      placeholder:
                                                          (context, url) =>
                                                              Container(
                                                        height: 5,
                                                        width: 5,
                                                        child:
                                                            CircularProgressIndicator(
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              string,
                                                              dynamics) =>
                                                          Icon(Icons.people),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                backgroundColor: Colors.black,
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: FutureBuilder(
                                      future: widget.storage
                                          .getUserProfilePictures(
                                              widget.database, widget.matchID),
                                      builder:
                                          (BuildContext context, listURLs) {
                                        if (listURLs.hasData) {
                                          //DEVMARK
                                          return Center(
                                            child: Container(
                                              width: 70,
                                              height: 70,
                                              child: Card(
                                                elevation: 2,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(30.0),
                                                  ),
                                                ),
                                                child: Container(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    child: CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      imageUrl: listURLs.data
                                                                  .length ==
                                                              0
                                                          ? ""
                                                          : "${listURLs.data[0]}",
                                                      placeholder:
                                                          (context, url) =>
                                                              Container(
                                                        height: 5,
                                                        width: 5,
                                                        child:
                                                            CircularProgressIndicator(
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              string,
                                                              dynamics) =>
                                                          Icon(Icons.people),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                            

                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 50.0, left: 50, right: 50, bottom: 10),
                                child: RaisedButton(
                                  elevation: 16.0,
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    widget.onMessage();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Text(
                                          'Message',
                                          style:
                                              Theme.of(context).textTheme.body2,
                                        ),
                                        SizedBox(width: 20),
                                        Icon(CopticMeetIcons.send_coptic_meet)
                                      ],
                                    ),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0)),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                child: RaisedButton(
                                  elevation: 16.0,
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    //    widget.onMessage();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Text(
                                          'Keep Swiping',
                                          style:
                                              Theme.of(context).textTheme.body2,
                                        ),
                                        //SizedBox(width: 20),
                                        //  Icon(CopticMeetIcons.send_coptic_meet)
                                      ],
                                    ),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
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
//================Previous like dislike and double like buttons========

//  Align(
//                             alignment: Alignment.bottomCenter,
//                             child: Padding(
//                               padding: const EdgeInsets.only(bottom: 30),
//                               child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     GestureDetector(
//                                       onTap: () {
//                                         _updatePopupDislikedUsers(
//                                             widget.userID, widget.database);
//                                         Navigator.pop(context);
//                                       },
//                                       child: Padding(
//                                         padding: const EdgeInsets.only(top: 50),
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color:
//                                                 Theme.of(context).primaryColor,
//                                           ),
//                                           width: 70,
//                                           height: 70,
//                                           child: Icon(
//                                             CopticMeetIcons.left_coptic_meet,
//                                             color: Colors.white,
//                                             size: 40,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     GestureDetector(
//                                       onTap: () {
//                                         _updatePopupDoubleLikedUsers(
//                                             widget.userID, widget.database);
//                                         Navigator.pop(context);
//                                       },
//                                       child: Padding(
//                                         padding:
//                                             const EdgeInsets.only(bottom: 50),
//                                         child: ClipRRect(
//                                           borderRadius:
//                                               BorderRadius.circular(10),
//                                           child: Container(
//                                             color:
//                                                 Theme.of(context).primaryColor,
//                                             width: 50,
//                                             height: 50,
//                                             child: Icon(
//                                               CopticMeetIcons.right_coptic_meet,
//                                               color:
//                                                   Theme.of(context).accentColor,
//                                               size: 28,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     GestureDetector(
//                                       onTap: () {
//                                         _updatePopupLikedUser(
//                                             widget.userID, widget.database);
//                                         Navigator.pop(context);
//                                       },
//                                       child: Padding(
//                                         padding: const EdgeInsets.only(top: 50),
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color:
//                                                 Theme.of(context).primaryColor,
//                                           ),
//                                           width: 70,
//                                           height: 70,
//                                           child: Icon(
//                                             CopticMeetIcons.right_coptic_meet,
//                                             color: Colors.white,
//                                             size: 40,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ]),
//                             ),
//                           )
