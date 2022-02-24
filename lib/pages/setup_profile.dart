import 'dart:io';

import 'package:copticmeet/providers/profile_info_caches.dart';
import 'package:copticmeet/reusable_widgets/edit_profile_widget.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/services/sign_in/auth.dart';
import 'package:copticmeet/services/storage/storage.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/platform_aler_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class SetupProfilePage extends StatefulWidget {
  SetupProfilePage({Key key}) : super(key: key);

  @override
  _SetupProfilePageState createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
      final deleteCaches =
          Provider.of<ProfileImageCaches>(context, listen: false);
      deleteCaches.clearProfileImages();
      deleteCaches.signedOut(true);
    } catch (e) {
      //Show a snackbar here
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await PlatformAlertDialog(
            title: 'Logout',
            cancelActionText: 'Cancel',
            content: 'Are you sure you want to logout?',
            defaultActionText: 'Logout')
        .show(context);
    if (didRequestSignOut == true) {
      _signOut(context);
    }
  }

  bool accepted = false;

  @override
  void initState() {
    super.initState();
    //checkLocation();
  }

  void checkLocation() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final status = await Geolocator().checkGeolocationPermissionStatus();
      if (status.value == 0) {
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text('Location Permission'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    const Text(
                      'You have denied the application access to your location.',
                      style: TextStyle(
                        fontFamily: 'Papyrus',
                      ),
                    ),
                    const Text(
                      'Please access the settings and allow the application to access your location, for a better experience.',
                      style: TextStyle(
                        fontFamily: 'Papyrus',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Ok',
                    style: TextStyle(
                      fontFamily: 'Papyrus',
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ],
                begin: const FractionalOffset(1.0, 0.0),
                end: const FractionalOffset(0.0, 0.7),
                stops: [0.3, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: Column(children: [
            SizedBox(height: MediaQuery.of(context).size.height / 10),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.2,
              child: Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(children: [_beginSetup()]),
                  )),
            )
          ]),
        ));
  }

  Widget _beginSetup() => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 40),
            child: Container(
                width: MediaQuery.of(context).size.width / 1.7,
                child: Image(
                    image: AssetImage('assets/images/logos/large/logo.png'))),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Profile Setup'),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
                'It appears there is not a profile setup for this account, to get started tap the \'Create Profile\' button below',
                style: Theme.of(context).textTheme.body2,
                textAlign: TextAlign.center),
          ),
          Platform.isIOS
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                      'We have a new database and User Interface for our app, if you already had an account setup, our servers will try and move data across to the new one. Please continue with the profile setup.',
                      style: Theme.of(context).textTheme.body2,
                      textAlign: TextAlign.center),
                )
              : Container(),
          Padding(
            padding:
                const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 0),
            child: Hero(
              tag: 'createProfile',
              child: Container(
                child: RaisedButton(
                  elevation: 16.0,
                  onPressed: () async {
                    final database =
                        Provider.of<Database>(context, listen: false);
                    final storage =
                        Provider.of<Storage>(context, listen: false);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _EditProfile(
                          database: database,
                          storage: storage,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 8, bottom: 8),
                    child: Text(
                      'Create Profile',
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ),
                  color: Theme.of(context).accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
              ),
            ),
          ),
          FlatButton(
            onPressed: () => _confirmSignOut(context),
            child: Text(
              'Log Out',
              style: TextStyle(
                fontFamily: "Papyrus",
                fontSize: 10,
              ),
            ),
          )
        ],
      );
}

class _EditProfile extends StatefulWidget {
  _EditProfile({Key key, @required this.database, @required this.storage})
      : super(key: key);
  final Database database;
  final Storage storage;

  @override
  __EditProfileState createState() => __EditProfileState();
}

class __EditProfileState extends State<_EditProfile> {
  bool _validAge = false;
  bool _validName = false;
  bool isNameValid = true;
  bool isNameLengthValid = true;

  var _name = TextEditingController();

  var _birthDate = DateTime.now().subtract(
    Duration(
      days: 365 * (18 + 7),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ],
                begin: const FractionalOffset(1.0, 0.0),
                end: const FractionalOffset(0.0, 0.7),
                stops: [0.3, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: Stack(children: [
            Align(
              alignment: Alignment.center,
              child: Card(
                  color: Colors.transparent,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: MediaQuery.of(context).size.height / 1.2,
                        color: Colors.white,
                        child: Stack(
                          children: <Widget>[
                            _validName
                                ? EditProfileWidget(
                                    database: widget.database,
                                    storage: widget.storage,
                                  )
                                : _validAge
                                    ? Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Text(
                                                  'My name is (first name only):',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20,
                                                  right: 20,
                                                  bottom: 8,
                                                  top: 3),
                                              child: FutureBuilder(
                                                  future: widget.database
                                                      .getSpecificUserValues(
                                                          "name"),
                                                  builder:
                                                      (BuildContext context,
                                                          snapshot) {
                                                    if (snapshot.hasData) {
                                                      var _displayValue = '';
                                                      if (snapshot.data.value ==
                                                              null ||
                                                          snapshot.data.value ==
                                                              "null") {
                                                        _displayValue =
                                                            "Enter your name";
                                                      } else {
                                                        _displayValue =
                                                            "${snapshot.data.value}";
                                                      }
                                                      return Container(
                                                        child: TextField(
                                                          controller: _name,
                                                          maxLength: 20,
                                                          maxLengthEnforced:
                                                              false,
                                                          cursorColor:
                                                              Colors.black,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .body2,
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                "$_displayValue",
                                                            hintStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .body2,
                                                          ),
                                                          onChanged: (name) {
                                                            setState(() {
                                                              if ((name == 'null') ||
                                                                  (name ==
                                                                      'Null') ||
                                                                  (name ==
                                                                      "") ||
                                                                  name ==
                                                                      null) {
                                                                isNameValid =
                                                                    false;
                                                              } else {
                                                                isNameValid =
                                                                    true;
                                                              }
                                                            });
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
                                                        color: Colors.white,
                                                      ));
                                                    }
                                                  }),
                                            ),
                                            Consumer<ProfileImageCaches>(
                                                builder: (BuildContext context,
                                                    ProfileImageCaches
                                                        profileCaches,
                                                    Widget child) {
                                              return RaisedButton(
                                                elevation: 16.0,
                                                onPressed: () {
                                                  if (isNameValid) {
                                                    if (_name.text == "") {
                                                      setState(() {
                                                        isNameValid = false;
                                                        isNameLengthValid =
                                                            false;
                                                      });
                                                    } else if (_name.text
                                                            .trim()
                                                            .length <
                                                        3) {
                                                      setState(() {
                                                        isNameLengthValid =
                                                            false;
                                                        isNameValid = false;
                                                      });
                                                    } else {
                                                      profileCaches
                                                          .addUserInfo({
                                                        "name":
                                                            "${_name.text.toString()}",
                                                        "isVerified": false,
                                                        "aboutUser": "",
                                                        "gender": "Male",
                                                        "height": "5'" +
                                                            ' 6"' +
                                                            ', (168 cm)',
                                                        "preferences": "dating",
                                                        "loveLanguage": "None",
                                                        "starSign": "None",
                                                        "pets": "None",
                                                        "kids": "None",
                                                        "educationLevel":
                                                            "None",
                                                        "smoke": "None",
                                                        "feminist": "None",
                                                        "drink": "None",
                                                        "occupation": "",
                                                        "chosenPrompt":
                                                            'My favorite bible passage is...',
                                                        "promptInput": "",
                                                        "anotherPrompt":
                                                            'The joy of God is...',
                                                        "anotherPromptInput":
                                                            "",
                                                        "secondAnotherPrompt":
                                                            "An ideal day off for me would look like...",
                                                        "secondAnotherPromptInput":
                                                            "",
                                                        "interestedIn": "Both",
                                                        "distanceToSearch": 30,
                                                        "ageToShow": {
                                                          "start": 18,
                                                          "end": 70
                                                        },
                                                        'discoverable': "Yes",
                                                        'notifications': "Yes",
                                                        'read_receipts': "Yes",
                                                        "editing": "false",
                                                        "location":
                                                            "Loading...",
                                                        "locationName": ""
                                                      }, widget.database);

                                                      profileCaches
                                                          .addUserInfoPro({
                                                        "preferedLoveLanguage":
                                                            'Words of affirmation',
                                                        'loveLanguageFilterEnabled':
                                                            "false",
                                                        'preferedStarSign':
                                                            'Aries',
                                                        'starSignFilterEnabled':
                                                            "false",
                                                        'preferedEducation':
                                                            'High School',
                                                        'educationFilterEnabled':
                                                            "false",
                                                        'preferedKidStatus':
                                                            'Have but still want more',
                                                        'kidFilterEnabled':
                                                            "false",
                                                        'preferredHeight':
                                                            "5'" +
                                                                ' 6"' +
                                                                ', (168 cm)',
                                                        'heightFilterEnabled':
                                                            "false",
                                                        'preferedDrinkStatus':
                                                            'Never',
                                                        'DrinkFilterEnabled':
                                                            "false",
                                                        'preferedFeministStatus':
                                                            'Absolutely',
                                                        'FeministFilterEnabled':
                                                            "false",
                                                        'preferedSmokeStatus':
                                                            'Never',
                                                        'SmokeFilterEnabled':
                                                            "false"
                                                      }, widget.database);
                                                      profileCaches
                                                          .clearProfileImages();
                                                      profileCaches
                                                          .getUserLocation(
                                                              widget.database);
                                                      setState(() {
                                                        _validName = true;
                                                        isNameLengthValid =
                                                            true;
                                                      });
                                                    }
                                                  }
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Submit',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .body2,
                                                  ),
                                                ),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0)),
                                              );
                                            }),
                                          ],
                                        ),
                                      )
                                    : Center(
                                        child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 30),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Text(
                                                'My Birthday is:',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            //  /1.4,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4,
                                            color: Colors.transparent,
                                            child: CupertinoTheme(
                                              data: CupertinoThemeData(
                                                textTheme:
                                                    CupertinoTextThemeData(
                                                  dateTimePickerTextStyle:
                                                      TextStyle(
                                                          color: Colors.black,
                                                          fontFamily: 'Papyrus',
                                                          fontSize: 20),
                                                ),
                                              ),
                                              // Fix: There were missing brackets on 18+7
                                              child: CupertinoDatePicker(
                                                  maximumDate:
                                                      DateTime.now().subtract(
                                                    Duration(
                                                      days: 365 * 18,
                                                    ),
                                                  ),
                                                  initialDateTime:
                                                      DateTime.now().subtract(
                                                    Duration(
                                                      days: 365 * (18 + 7),
                                                    ),
                                                  ),
                                                  mode: CupertinoDatePickerMode
                                                      .date,
                                                  onDateTimeChanged: (date) {
                                                    _birthDate = date;
                                                  }),
                                            ),
                                          ),
                                          Consumer<ProfileImageCaches>(builder:
                                              (BuildContext context,
                                                  ProfileImageCaches
                                                      profileCaches,
                                                  Widget child) {
                                            return RaisedButton(
                                              elevation: 16.0,
                                              onPressed: () {
                                                var _startDate = _birthDate;
                                                var _startDateList = _startDate
                                                    .toString()
                                                    .split(' ');
                                                profileCaches.addUserInfo({
                                                  'dateOfBirth':
                                                      "${_startDateList[0]}"
                                                }, widget.database);

                                                setState(() {
                                                  _validAge = true;
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Submit',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .body2,
                                                ),
                                              ),
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0)),
                                            );
                                          }),
                                          SizedBox(height: 15),
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Text(
                                                "Please enter your correct DOB. Your entered age will display on your profile accordingly.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))
                          ],
                        ),
                      ))),
            )
          ])),
    );
  }
}
