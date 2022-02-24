import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:copticmeet/pages/clipper.dart';
import 'package:copticmeet/pages/delete_all_user_detail_page.dart';
import 'package:copticmeet/pages/landing_page.dart';
import 'package:copticmeet/pages/profile/profile_images_loader.dart';
import 'package:copticmeet/pages/profile/profile_page.dart';
import 'package:copticmeet/pages/video_preview_small.dart';
import 'package:copticmeet/providers/profile_info_caches.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/services/sign_in/auth.dart';
import 'package:copticmeet/services/storage/storage.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/platform_aler_dialog.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/widgets.dart';
import 'package:copticmeet/widgets/pro_mode/pop_up.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

String positiontoStore = "null,null";

class EditProfileWidget extends StatefulWidget {
  EditProfileWidget({Key key, @required this.database, @required this.storage})
      : super(key: key);
  final Database database;
  final Storage storage;

  @override
  _EditProfileWidgetState createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  final _aboutUserTextController = TextEditingController();
  final _occupationTextControllerTwo = TextEditingController();
  final _promptTextController = TextEditingController();
  final _anotherPromptTextController = TextEditingController();
  final _secondAnotherPromptTextController = TextEditingController();
  var _listController = ScrollController();
  static final _textKey = GlobalKey<FormState>();
  bool _personalInfoComplete = false;
  bool _aboutMeComplete = false;
  bool _filtersComplete = false;
  bool _appSettingsComplete = false;

  final _nameFocusNode = FocusNode();
  final _aboutUserFocusNode = FocusNode();
  final _occupationFocusNodeTwo = FocusNode();
  final _promptFocusNode = FocusNode();
  final _anotherPromptFocusNode = FocusNode();

  final _secondAnotherPromptFocusNode = FocusNode();

  final GlobalKey _personalInfoTab = GlobalKey();
  final GlobalKey _aboutMeTab = GlobalKey();
  final GlobalKey _appSettingsTab = GlobalKey();
  final GlobalKey _filtersTab = GlobalKey();
  final GlobalKey _proFeaturesTab = GlobalKey();
  final GlobalKey _advancedFiltersTab = GlobalKey();
  final GlobalKey _promptTab = GlobalKey();

  bool _mapOptionCallByExpanded = false;
  String _mapAddress = 'unKnown';
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController controller;
  String townInfo = 'unknown';
  var townData = "unKnown";
  List userPosition = [null, null];

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CameraPosition cameraPosition;
  String newValue = "5'" + ' 6"' + ' (168 cm)';
  String prefferedNewValue = "5'" + ' 6"' + ' (168 cm)';
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
    "70"
        "71"
  ];
  List<String> heightFeetList = ["4", "5", "6", "7"];

  Map<String, String> heightDropDownHelperMap = {
    "45": "4'" + ' 5"' + '(< 135 cm)',
    "46": "4'" + ' 6"' + " (137 cm)",
    "47": "4'" + ' 7"' + " (140 cm)",
    "48": "4'" + ' 8"' + " (142 cm)",
    "49": "4'" + ' 9"' + " (145 cm)",
    "410": "4'" + ' 10"' + " (147 cm)",
    "411": "4'" + ' 11"' + " (150 cm)",
    "50": "5'" + ' 0"' + " (152 cm)",
    "51": "5'" + ' 1"' + " (155 cm)",
    "52": "5'" + ' 2"' + " (157 cm)",
    "53": "5'" + ' 3"' + " (160 cm)",
    "54": "5'" + ' 4"' + " (163 cm)",
    "55": "5'" + ' 5"' + " (165 cm)",
    "56": "5'" + ' 6"' + " (168 cm)",
    "57": "5'" + ' 7"' + " (170 cm)",
    "58": "5'" + ' 8"' + " (173 cm)",
    "59": "5'" + ' 9"' + " (175 cm)",
    "510": "5'" + ' 10"' + " (178 cm)",
    "511": "5'" + ' 11"' + " (180 cm)",
    "60": "6'" + ' 0"' + " (183 cm)",
    "61": "6'" + ' 1"' + " (185 cm)",
    "62": "6'" + ' 2"' + " (188 cm)",
    "63": "6'" + ' 3"' + " (191 cm)",
    "64": "6'" + ' 4"' + " (193 cm)",
    "65": "6'" + ' 5"' + " (195 cm)",
    "66": "6'" + ' 6"' + " (198 cm)",
    "67": "6'" + ' 7"' + " (201 cm)",
    "68": "6'" + ' 8"' + " (203 cm)",
    "69": "6'" + ' 9"' + " (205 cm)",
    "610": "6'" + ' 10"' + " (208 cm)",
    "611": "6'" + ' 11"' + " (210 cm)",
    "70": "7'" + ' 0"' + " (213 cm)",
    "71": "7'" + ' 1"' + " (>216 cm)",
  };

  _getImageFile(ImageSource source) {
    var _image = ImagePicker.pickImage(source: source);
    return _image;
  }

  _checkHeightIsInRange({feet, inch}) {
    String newFeet = "5";
    String newInch = "6";
    if (heightDefaultList.contains(feet.toString() + inch.toString())) {
    } else {
      if (heightFeetList.contains(feet)) {
        Provider.of<ProfileImageCaches>(context, listen: false)
            .addUserInfo({"height": "$feet,$newInch"}, widget.database);
      } else {
        Provider.of<ProfileImageCaches>(context, listen: false)
            .addUserInfo({"height": "$newFeet,$newInch"}, widget.database);
      }
    }
  }

  _heightDropDownHelper({feet, inch}) {
    if (heightDropDownHelperMap
        .containsKey(feet.toString() + inch.toString())) {
      newValue = heightDropDownHelperMap[feet.toString() + inch.toString()];
    } else {
      newValue = "5'" + ' 6"' + " (168 cm)";
    }
  }

  _checkPrefferedHeightIsInRange({feet, inch}) {
    String newFeet = "5";
    String newInch = "6";
    if (heightDefaultList.contains(feet.toString() + inch.toString())) {
    } else {
      if (heightFeetList.contains(feet)) {
        Provider.of<ProfileImageCaches>(context, listen: false).addUserInfoPro(
            {"preferredHeight": "$feet,$newInch"}, widget.database);
      } else {
        Provider.of<ProfileImageCaches>(context, listen: false).addUserInfoPro(
            {"preferredHeight": "$newFeet,$newInch"}, widget.database);
      }
    }
  }

  _prefferedHeightDropDownHelper({feet, inch}) {
    if (heightDropDownHelperMap
        .containsKey(feet.toString() + inch.toString())) {
      prefferedNewValue =
          heightDropDownHelperMap[feet.toString() + inch.toString()];
    } else {
      prefferedNewValue = "5'" + ' 6"' + " (168 cm)";
    }
  }

  _storeVideoImage(video) async {
    widget.storage.storeProfileVideo(widget.database, video, context);
  }

  Future<void> _confirmDeleteAccount(BuildContext context,storage,data) async {
    final didRequestSignOut = await PlatformAlertDialog(
            title: 'Delete Account',
            cancelActionText: 'Cancel',
            content: 'Are you sure you want to delete your account?',
            defaultActionText: 'Confirm')
        .show(context);
    
    if (didRequestSignOut == true) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => DeleteAccountPage(
                  database: widget.database,
                  
                  storage: widget.storage,
                  data: data)));
    }
  }

  Future<bool> checkFouthAdvancedFilter(
      String firstValue,
      String secondValue,
      String thirdValue,
      String fourthValue,
      String fifthValue,
      String sixthValue,
      String seventhValue,
      Map<dynamic, dynamic> data) async {
    bool firstFilter =
        await widget.database.getSpecificProFeatureUserFilters(firstValue) ==
                "true"
            ? true
            : false;
    bool secondFilter =
        await widget.database.getSpecificProFeatureUserFilters(secondValue) ==
                "true"
            ? true
            : false;
    bool thirdFilter =
        await widget.database.getSpecificProFeatureUserFilters(thirdValue) ==
                "true"
            ? true
            : false;
    bool fourthFilter =
        await widget.database.getSpecificProFeatureUserFilters(fourthValue) ==
                "true"
            ? true
            : false;
    bool fifthFilter =
        await widget.database.getSpecificProFeatureUserFilters(fifthValue) ==
                "true"
            ? true
            : false;
    bool sixthFilter =
        await widget.database.getSpecificProFeatureUserFilters(sixthValue) ==
                "true"
            ? true
            : false;
    bool seventhFilter =
        await widget.database.getSpecificProFeatureUserFilters(seventhValue) ==
                "true"
            ? true
            : false;
    if (firstFilter &&
        secondFilter &&
        thirdFilter &&
        fourthFilter &&
        fifthFilter &&
        sixthFilter &&
        seventhFilter) {
      if (data['proActive'] == 'false') {
        final didRequestPassportMode = await PlatformAlertDialog(
          title: 'Passport Mode',
          content: 'This is a blocked feature, would you like to get access?',
          defaultActionText: 'Yes',
          cancelActionText: 'Cancel',
        ).show(context);
        if (didRequestPassportMode == true) {
          showDialog(
            context: context,
            builder: (_) =>
                PurchaseProPopup.create(context, database: widget.database),
          );
          return false;
        } else {
          return false;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
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

  Future<bool> getSpotifyConnected() async {
    DataSnapshot snapshot =
        await widget.database.getSpecificUserValues('spotifyConnected');

    if (snapshot.value == 'true') {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    Provider.of<ProfileImageCaches>(context, listen: false)
        .userDetails(widget.database);
    Provider.of<ProfileImageCaches>(context, listen: false)
        .userDetailsPro(widget.database);
  }

  @override
  void dispose() {
    super.dispose();
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
      print(e.toString());
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
      Navigator.of(context).pop();
      _signOut(context);
    } else {
      Navigator.of(context).pop();
    }
  }

  _buildImageURL(String bucket, String path, int index, String list) async {
    var reference = await widget.database.getUserDataOnce();
    var values = await reference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      return values;
    });
    var jsonList = json.decode(values["imageOrder"]);
    var _url = await FirebaseStorage(storageBucket: '$bucket')
        .ref()
        .child(path + '/' + jsonList[index])
        .getDownloadURL();
    return _url;
  }

  void _onReorder(int oldIndex, int newIndex) async {
    final reorder = Provider.of<ProfileImageCaches>(context, listen: false);
    reorder.onReorder(oldIndex, newIndex, widget.database);
  }

  GlobalKey<ScaffoldState> _profileScaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _profileScaffoldKey,
      body: FutureBuilder<bool>(
          future: getPastPurchases(),
          initialData: false,
          builder: (BuildContext context, inAppPurchases) {
            return StreamBuilder<Event>(
                stream: widget.database.getUserData,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData &&
                      !snapshot.hasError &&
                      snapshot.data.snapshot.value != null &&
                      ((snapshot.connectionState == ConnectionState.active ||
                          snapshot.connectionState ==
                              ConnectionState.waiting))) {
                    var data = snapshot.data.snapshot.value;

                    var imageBucket = data["imageBucket"];
                    var imagePath = data["imagePath"];
                    var imageNumber = data["imageNumber"];
                    var imageOrder = data["imageOrder"];
                    Map<String, dynamic> map = {};
                    if (imageBucket == null) {
                      map.putIfAbsent("imageBucket", () => imageBucket);
                    }
                    if (imagePath == null) {
                      map.putIfAbsent("imagePath", () => imagePath);
                    }
                    if (imageNumber == null) {
                      map.putIfAbsent("imageNumber", () => imageNumber);
                    }
                    if (imageOrder == null) {
                      map.putIfAbsent("imageOrder", () => imageOrder);
                    }
                    if (map.length > 0) {
                      Provider.of<ProfileImageCaches>(context, listen: false)
                          .addUserInfo(map, widget.database);
                    }

                    return Stack(
                      children: <Widget>[
                        ListView(
                            controller: _listController,
                            scrollDirection: Axis.vertical,
                            children: [
                              _profileImages(data),
                              SizedBox(
                                height: 5,
                              ),
                              Consumer<ProfileImageCaches>(builder:
                                  (BuildContext context,
                                      ProfileImageCaches profileCaches,
                                      Widget child) {
                                if (profileCaches.getUserInfo.isEmpty ||
                                    profileCaches.getUserInfo == null)
                                  profileCaches.userDetails(widget.database);
                                if (profileCaches.getUserInfoPro.isEmpty ||
                                    profileCaches.getUserInfo == null)
                                  profileCaches.userDetailsPro(widget.database);

                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 25),
                                  child: profileCaches.getUserInfo['isVerified']
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Verified Profile',
                                                    style: TextStyle(
                                                      fontFamily: "Papyrus",
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  )
                                                ],
                                              ),
                                              RaisedButton(
                                                onPressed: () =>
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                  return ViewProfilePage();
                                                })),
                                                padding: EdgeInsets.only(
                                                    top: 3,
                                                    bottom: 3,
                                                    left: 10,
                                                    right: 10),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                ),
                                                child: Text(
                                                  'View Profile',
                                                  style: TextStyle(
                                                    fontFamily: "Papyrus",
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ])
                                      : ListTile(
                                          title: RaisedButton(
                                            elevation: 16.0,
                                            onPressed: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ProfileImagesLoader(
                                                    data: data,
                                                    database: widget.database,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Verify your profile',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body2,
                                              ),
                                            ),
                                            color:
                                                Theme.of(context).primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                          ),
                                        ),
                                );
                              }),
                              SizedBox(
                                height: 5,
                              ),
                              FutureBuilder(
                                  future: checkValidEntries(
                                      ["aboutUser", "height"], widget.database),
                                  initialData: true,
                                  builder: (BuildContext context, completed) {
                                    return _buildExpansionTile(
                                        2,
                                        _personalInfo(
                                            data, _personalInfoComplete),
                                        data,
                                        'Personal Info',
                                        _personalInfoTab,
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              'Personal Info',
                                              style: TextStyle(
                                                  fontFamily: 'Papyrus'),
                                            ),
                                            Spacer(),
                                            completed.data
                                                ? Icon(Icons.warning,
                                                    color: Colors.redAccent)
                                                : Spacer(),
                                          ],
                                        ));
                                  }),
                              FutureBuilder(
                                  future: checkValidEntries(
                                      ["occupation", "location"],
                                      widget.database),
                                  initialData: true,
                                  builder: (BuildContext context, completed) {
                                    return _buildExpansionTile(
                                        3,
                                        _aboutMe(data, _aboutMeComplete),
                                        data,
                                        'About Me',
                                        _aboutMeTab,
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              'About Me',
                                              style: TextStyle(
                                                  fontFamily: 'Papyrus'),
                                            ),
                                            Spacer(),
                                            completed.data
                                                ? Icon(Icons.warning,
                                                    color: Colors.redAccent)
                                                : Spacer()
                                          ],
                                        ));
                                  }),
                              _buildExpansionTile(
                                  5,
                                  _filters(data, _filtersComplete,
                                      inAppPurchases.data),
                                  data,
                                  'Filters',
                                  _filtersTab,
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        'Filters',
                                        style: TextStyle(fontFamily: 'Papyrus'),
                                      ),
                                    ],
                                  )),
                              FutureBuilder(
                                  future: widget.database.checkProMode(),
                                  builder: (BuildContext context, proActive) {
                                    if (inAppPurchases.data) {
                                      if (data['proActive'] == 'false') {
                                        widget.database.updateUserDetails({
                                          'proActive': 'true',
                                        });
                                      }
                                      return _buildExpansionTile(
                                        7,
                                        _proFeatures(data),
                                        data,
                                        'Pro Features',
                                        _proFeaturesTab,
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              'Passport Mode',
                                              style: TextStyle(
                                                  fontFamily: 'Papyrus'),
                                            ),
                                            Spacer(),
                                            Icon(
                                              Icons.airplanemode_active,
                                              color: Colors.redAccent,
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return ListTile(
                                        onTap: () async {
                                          final didRequestPassportMode =
                                              await PlatformAlertDialog(
                                            title: 'Passport Mode',
                                            content:
                                                'This is a blocked feature, would you like to get access?',
                                            defaultActionText: 'Yes',
                                            cancelActionText: 'Cancel',
                                          ).show(context);
                                          if (didRequestPassportMode == true) {
                                            showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  PurchaseProPopup.create(
                                                      context,
                                                      database:
                                                          widget.database),
                                            );
                                          }
                                        },
                                        title: Row(
                                          children: <Widget>[
                                            Text(
                                              'Passport Mode',
                                              style: TextStyle(
                                                  fontFamily: 'Papyrus'),
                                            ),
                                            Spacer(),
                                            Icon(
                                              Icons.airplanemode_active,
                                              color: Colors.redAccent,
                                            ),
                                          ],
                                        ),
                                        trailing: Icon(Icons.lock,
                                            color: Colors.black54),
                                      );
                                    }
                                  }),
                              _buildExpansionTile(
                                  4,
                                  _appSettings(data, _appSettingsComplete),
                                  data,
                                  'App Settings',
                                  _appSettingsTab,
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        'App Settings',
                                        style: TextStyle(fontFamily: 'Papyrus'),
                                      ),
                                      Spacer(),
                                    ],
                                  )),
                              ListTile(
                                title: Consumer<ProfileImageCaches>(builder:
                                    (BuildContext context,
                                        ProfileImageCaches profileCaches,
                                        Widget child) {
                                  return RaisedButton(
                                    elevation: 16.0,
                                    onPressed: () async {
                                      var personalComplete = profileCaches
                                                  .getUserInfo["aboutUser"] !=
                                              null &&
                                          profileCaches
                                                  .getUserInfo["aboutUser"] !=
                                              "" &&
                                          profileCaches.getUserInfo["height"] !=
                                              null &&
                                          profileCaches.getUserInfo["height"] !=
                                              "";

                                      var aboutUser = profileCaches
                                                  .getUserInfo["occupation"] !=
                                              null &&
                                          profileCaches
                                              .getUserInfo["occupation"]
                                              .toString()
                                              .isNotEmpty;
                                      if (profileCaches.userProfiles.length !=
                                          0) {
                                        if (personalComplete) {
                                          if (aboutUser) {
                                            final isOk =
                                                profileCaches.getUserInfo[
                                                            "isVerified"] !=
                                                        null &&
                                                    profileCaches.getUserInfo[
                                                            "isVerified"] ==
                                                        true;
                                            if (isOk) {
                                              profileCaches.addUserInfo(
                                                  {"editing": "false"},
                                                  widget.database);

                                              Navigator.pushReplacement(
                                                context,
                                                new MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          new LandingPage(),
                                                ),
                                              );
                                            } else {
                                              var snackBarSuccess = SnackBar(
                                                content: Text(
                                                  'Unverified profile. Please verify your profile before continue !',
                                                ),
                                              );
                                              Scaffold.of(_profileScaffoldKey
                                                      .currentState.context)
                                                  .showSnackBar(
                                                      snackBarSuccess);
                                            }
                                          } else {
                                            var snackBarSuccess = SnackBar(
                                              content: Text(
                                                'Please fill Occupation in the About Me section',
                                              ),
                                            );
                                            Scaffold.of(_profileScaffoldKey
                                                    .currentState.context)
                                                .showSnackBar(snackBarSuccess);
                                          }
                                        } else {
                                          var snackBarSuccess = SnackBar(
                                              content: Text(
                                                  'Please fill in the Personal Info section'));
                                          Scaffold.of(_profileScaffoldKey
                                                  .currentState.context)
                                              .showSnackBar(snackBarSuccess);
                                        }
                                      } else {
                                        var snackBarSuccess = SnackBar(
                                          content: Text(
                                              'Please add at least one profile picture'),
                                        );
                                        Scaffold.of(_profileScaffoldKey
                                                .currentState.context)
                                            .showSnackBar(snackBarSuccess);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Submit',
                                        style:
                                            Theme.of(context).textTheme.body2,
                                      ),
                                    ),
                                    color: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  );
                                }),
                              ),
                              ListTile(
                                title: FlatButton(
                                    onPressed: () => _confirmSignOut(context),
                                    child: Text('Log Out',
                                        style: TextStyle(
                                            fontFamily: "Papyrus",
                                            fontSize: 10))),
                              ),
                              ListTile(
                                title: FlatButton(
                                    onPressed: () =>
                                        _confirmDeleteAccount(context, widget.storage, data),
                                    child: Text('Delete Account',
                                        style: TextStyle(
                                            fontFamily: "Papyrus",
                                            fontSize: 10))),
                              ),
                            ]),
                        Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )),
                      ],
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
    );
  }

  Widget _filters(data, bool complete, bool inAppPurchases) => Column(
        children: <Widget>[
          Visibility(
            visible: data["preferences"] != "friend",
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Interested in',
                  style: Theme.of(context).textTheme.body2,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          Consumer<ProfileImageCaches>(builder: (BuildContext context,
              ProfileImageCaches profileCaches, Widget child) {
            return Visibility(
                visible: profileCaches.getUserInfo["preferences"] != "friend",
                child: Row(
                  children: <Widget>[
                    Spacer(),
                    ChoiceChip(
                      selectedColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.grey[100],
                      selected: profileCaches.getUserInfo["interestedIn"] ==
                              "Men" ||
                          profileCaches.getUserInfo["interestedIn"] == "Both",
                      onSelected: (value) {
                        if (profileCaches.getUserInfo["interestedIn"] ==
                                "Women" &&
                            value) {
                          profileCaches.addUserInfo(
                              {'interestedIn': "Both"}, widget.database);
                        } else if (profileCaches.getUserInfo["interestedIn"] ==
                                "Both" &&
                            !value) {
                          profileCaches.addUserInfo(
                              {'interestedIn': "Women"}, widget.database);
                        } else {
                          profileCaches.addUserInfo(
                              {'interestedIn': "Men"}, widget.database);
                        }
                      },
                      label: Container(
                        width: 60,
                        child: Text(
                          'Men',
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Spacer(),
                    ChoiceChip(
                      selectedColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.grey[100],
                      selected: profileCaches.getUserInfo["interestedIn"] ==
                              "Women" ||
                          profileCaches.getUserInfo["interestedIn"] == "Both",
                      onSelected: (value) {
                        if (profileCaches.getUserInfo["interestedIn"] ==
                                "Men" &&
                            value) {
                          profileCaches.addUserInfo(
                              {'interestedIn': "Both"}, widget.database);
                        } else if (profileCaches.getUserInfo["interestedIn"] ==
                                "Both" &&
                            !value) {
                          profileCaches.addUserInfo(
                              {'interestedIn': "Men"}, widget.database);
                        } else {
                          profileCaches.addUserInfo(
                              {'interestedIn': "Women"}, widget.database);
                        }
                      },
                      label: Container(
                        width: 60,
                        child: Text(
                          'Women',
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ));
          }),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Distance of users',
                style: Theme.of(context).textTheme.body2,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Consumer<ProfileImageCaches>(builder: (BuildContext context,
              ProfileImageCaches profileCaches, Widget child) {
            return Row(
              children: <Widget>[
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width / 1.7,
                  child: Slider(
                      max: 110,
                      min: 2,
                      divisions: 216,
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Colors.grey[100],
                      label: (double.parse(
                                  "${profileCaches.getUserInfo["distanceToSearch"]}") >
                              100.0)
                          ? "Everywhere"
                          : "${profileCaches.getUserInfo["distanceToSearch"]}",
                      value: (double.parse(
                                  "${profileCaches.getUserInfo["distanceToSearch"]}") >
                              100)
                          ? 105.0
                          : double.parse(
                              "${profileCaches.getUserInfo["distanceToSearch"]}"),
                      onChanged: (value) {
                        double values =
                            value > 100.0 ? 10000000000000000000.0 : value;
                        profileCaches.addUserInfo({
                          "distanceToSearch": "${values.toStringAsFixed(1)}"
                        }, widget.database);
                      },
                      onChangeEnd: (value) {
                        double values = value > 100.0 ? 100000000.0 : value;
                        profileCaches.addUserInfo({
                          "distanceToSearch": "${values.toStringAsFixed(1)}"
                        }, widget.database);
                      }),
                ),
                Spacer(),
                Text(
                  double.parse(
                              "${profileCaches.getUserInfo["distanceToSearch"]}") >
                          100.0
                      ? "Everywhere"
                      : '${profileCaches.getUserInfo["distanceToSearch"]} miles',
                  style: Theme.of(context).textTheme.body2,
                ),
                Spacer(),
              ],
            );
          }),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Age range',
                style: Theme.of(context).textTheme.body2,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Consumer<ProfileImageCaches>(builder: (BuildContext context,
              ProfileImageCaches profileCaches, Widget child) {
            return Row(
              children: <Widget>[
                Spacer(),
                Text(
                  '${profileCaches.getUserInfo['ageToShow']['start'].toString()}',
                  style: Theme.of(context).textTheme.body2,
                ),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width / 1.8,
                  child: RangeSlider(
                    min: 18,
                    max: 70,
                    inactiveColor: Colors.grey[100],
                    labels: RangeLabels(
                        profileCaches.getUserInfo['ageToShow']['start']
                            .toString(),
                        profileCaches.getUserInfo['ageToShow']["end"]
                            .toString()),
                    divisions: 52,
                    activeColor: Theme.of(context).primaryColor,
                    values: RangeValues(
                        double.parse(profileCaches.getUserInfo['ageToShow']
                                ['start']
                            .toString()),
                        double.parse(profileCaches.getUserInfo['ageToShow']
                                ["end"]
                            .toString()
                            .replaceAll(new RegExp(r'[^\w\s]+'), ''))),
                    onChanged: (values) {},
                    onChangeEnd: (values) {
                      if (values.end.toStringAsFixed(0) == "70") {
                        profileCaches.addUserInfo({
                          "ageToShow": {
                            "start": "${values.start.toStringAsFixed(0)}",
                            "end": "70+",
                          }
                        }, widget.database);
                      } else {
                        profileCaches.addUserInfo({
                          "ageToShow": {
                            "start": "${values.start.toStringAsFixed(0)}",
                            "end": "${values.end.toStringAsFixed(0)}",
                          }
                        }, widget.database);
                      }
                    },
                  ),
                ),
                Spacer(),
                Text(
                  '${profileCaches.getUserInfo['ageToShow']["end"].toString()}',
                  style: Theme.of(context).textTheme.body2,
                ),
                Spacer(),
              ],
            );
          }),
          _buildExpansionTile(
            7,
            _advancedFilters(data),
            data,
            'Advanced Filters',
            _advancedFiltersTab,
            Row(
              children: <Widget>[
                Text(
                  'Advanced Filters',
                  style: TextStyle(fontFamily: 'Papyrus'),
                ),
                Spacer(),
                Icon(
                  MdiIcons.filter,
                  color: Colors.redAccent,
                ),
              ],
            ),
          )
        ],
      );

  Widget _advancedFilters(data) =>
      Consumer<ProfileImageCaches>(builder: (BuildContext context,
          ProfileImageCaches profileCaches, Widget child) {
        return Column(children: <Widget>[
          Column(
            children: <Widget>[
              Visibility(
                visible: profileCaches.getUserInfo["preferences"] != "friend",
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Love Language',
                      style: Theme.of(context).textTheme.body2,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
              Visibility(
                  visible: profileCaches.getUserInfo["preferences"] != "friend",
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 3),
                    child: Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width / 1.35,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                            color: Colors.transparent,
                            style: BorderStyle.solid,
                            width: 0.0),
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                            value: profileCaches
                                .getUserInfoPro['preferedLoveLanguage'],
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 42,
                            underline: SizedBox(),
                            onChanged: (String newValue) {
                              profileCaches.addUserInfoPro(
                                  {'preferedLoveLanguage': '$newValue'},
                                  widget.database);
                            },
                            items: <String>[
                              'Words of affirmation',
                              'Quality time',
                              'Receiving gifts',
                              'Acts of service',
                              'Physical touch',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: Theme.of(context).textTheme.body2,
                                ),
                              );
                            }).toList()),
                      ),
                    ),
                  )),
              Visibility(
                visible: profileCaches.getUserInfo["preferences"] != "friend",
                child: ListTile(
                    title: Text('Enable Love Language Filter',
                        style: Theme.of(context).textTheme.body2),
                    trailing: Switch.adaptive(
                        activeColor: Theme.of(context).primaryColor,
                        value: profileCaches
                                .getUserInfoPro['loveLanguageFilterEnabled'] ==
                            "true",
                        onChanged: (value) async {
                          bool fourth = await checkFouthAdvancedFilter(
                              'heightFilterEnabled',
                              'educationFilterEnabled',
                              'starSignFilterEnabled',
                              'kidFilterEnabled',
                              'DrinkFilterEnabled',
                              'FeministFilterEnabled',
                              'SmokeFilterEnabled',
                              data);
                          if (fourth) {
                            profileCaches.addUserInfoPro({
                              'loveLanguageFilterEnabled': '${value.toString()}'
                            }, widget.database);
                          }
                        })),
              )
            ],
          ),
          Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Star Sign',
                    style: Theme.of(context).textTheme.body2,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 10, top: 3),
                child: Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width / 1.35,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                        color: Colors.transparent,
                        style: BorderStyle.solid,
                        width: 0.0),
                  ),
                  child: Center(
                    child: DropdownButton<String>(
                        value: profileCaches.getUserInfoPro['preferedStarSign'],
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 42,
                        underline: SizedBox(),
                        onChanged: (String newValue) {
                          profileCaches.addUserInfoPro(
                              {'preferedStarSign': '$newValue'},
                              widget.database);
                        },
                        items: <String>[
                          'Aries',
                          'Taurus',
                          'Gemini',
                          'Cancer',
                          'Leo',
                          'Virgo',
                          'Libra',
                          'Scorpio',
                          'Sagittarius',
                          'Capricorn',
                          'Aquarius',
                          'Pisces'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: Theme.of(context).textTheme.body2,
                            ),
                          );
                        }).toList()),
                  ),
                ),
              ),
              ListTile(
                  title: Text('Enable Star Sign Filter',
                      style: Theme.of(context).textTheme.body2),
                  trailing: Switch.adaptive(
                      activeColor: Theme.of(context).primaryColor,
                      value: profileCaches
                              .getUserInfoPro['starSignFilterEnabled'] ==
                          'true',
                      onChanged: (value) async {
                        bool fourth = await checkFouthAdvancedFilter(
                            'heightFilterEnabled',
                            'educationFilterEnabled',
                            'kidFilterEnabled',
                            'loveLanguageFilterEnabled',
                            'DrinkFilterEnabled',
                            'FeministFilterEnabled',
                            'SmokeFilterEnabled',
                            data);
                        if (fourth) {
                          profileCaches.addUserInfoPro(
                              {'starSignFilterEnabled': '${value.toString()}'},
                              widget.database);
                        }
                      })),
              Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'Education Level',
                        style: Theme.of(context).textTheme.body2,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 3),
                    child: Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width / 1.35,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                            color: Colors.transparent,
                            style: BorderStyle.solid,
                            width: 0.0),
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                            value: profileCaches
                                .getUserInfoPro['preferedEducation'],
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 42,
                            underline: SizedBox(),
                            onChanged: (String newValue) {
                              profileCaches.addUserInfoPro(
                                  {'preferedEducation': '$newValue'},
                                  widget.database);
                            },
                            items: <String>[
                              'High School',
                              'Trade / Tech School',
                              'College',
                              'Undergraduate Degree',
                              'Grad School',
                              'Graduate Degree',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: Theme.of(context).textTheme.body2,
                                ),
                              );
                            }).toList()),
                      ),
                    ),
                  ),
                  ListTile(
                      title: Text('Enable Education Level Filter',
                          style: Theme.of(context).textTheme.body2),
                      trailing: Switch.adaptive(
                          activeColor: Theme.of(context).primaryColor,
                          value: profileCaches.getUserInfoPro[
                                      'educationFilterEnabled'] ==
                                  'true'
                              ? true
                              : false,
                          onChanged: (value) async {
                            bool fourth = await checkFouthAdvancedFilter(
                                'heightFilterEnabled',
                                'starSignFilterEnabled',
                                'kidFilterEnabled',
                                'loveLanguageFilterEnabled',
                                'DrinkFilterEnabled',
                                'FeministFilterEnabled',
                                'SmokeFilterEnabled',
                                data);
                            if (fourth) {
                              profileCaches.addUserInfoPro(
                                  {'educationFilterEnabled': '$value'},
                                  widget.database);
                            }
                          }))
                ],
              ),
              Column(
                children: <Widget>[
                  Visibility(
                    visible:
                        profileCaches.getUserInfo["preferences"] != "friend",
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          'Children',
                          style: Theme.of(context).textTheme.body2,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                      visible:
                          profileCaches.getUserInfo["preferences"] != "friend",
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 10, top: 3),
                        child: Container(
                          height: 55,
                          width: MediaQuery.of(context).size.width / 1.35,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                                color: Colors.transparent,
                                style: BorderStyle.solid,
                                width: 0.0),
                          ),
                          child: Center(
                            child: DropdownButton<String>(
                                value: profileCaches
                                    .getUserInfoPro['preferedKidStatus'],
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 42,
                                underline: SizedBox(),
                                onChanged: (String newValue) {
                                  profileCaches.addUserInfoPro(
                                      {'preferedKidStatus': '$newValue'},
                                      widget.database);
                                },
                                items: <String>[
                                  'Have but still want more',
                                  'Have but don\'t want more',
                                  'Don\'t have',
                                  'Want someday',
                                  'Don\'t want',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                  );
                                }).toList()),
                          ),
                        ),
                      )),
                  Visibility(
                    visible:
                        profileCaches.getUserInfo["preferences"] != "friend",
                    child: ListTile(
                        title: Text('Enable Children Filter',
                            style: Theme.of(context).textTheme.body2),
                        trailing: Switch.adaptive(
                            activeColor: Theme.of(context).primaryColor,
                            value: profileCaches
                                        .getUserInfoPro['kidFilterEnabled'] ==
                                    'true'
                                ? true
                                : false,
                            onChanged: (value) async {
                              bool fourth = await checkFouthAdvancedFilter(
                                  'heightFilterEnabled',
                                  'starSignFilterEnabled',
                                  'educationFilterEnabled',
                                  'loveLanguageFilterEnabled',
                                  'DrinkFilterEnabled',
                                  'FeministFilterEnabled',
                                  'SmokeFilterEnabled',
                                  data);
                              if (fourth) {
                                profileCaches.addUserInfoPro(
                                    {'kidFilterEnabled': '$value'},
                                    widget.database);
                              }
                            })),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'Height',
                        style: Theme.of(context).textTheme.body2,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10, top: 3),
                      child: Builder(builder: (BuildContext context) {
                        {
                          var _heightList = profileCaches
                              .getUserInfoPro["preferredHeight"]
                              .toString()
                              .split(',');
                          var _feet = _heightList[0];
                          var _inch = _heightList[1];

                          _checkPrefferedHeightIsInRange(
                              feet: _feet, inch: _inch);
                          _prefferedHeightDropDownHelper(
                              feet: _feet, inch: _inch);

                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 10, top: 3),
                            child: Container(
                              height: 55,
                              width: MediaQuery.of(context).size.width / 1.35,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                    color: Colors.transparent,
                                    style: BorderStyle.solid,
                                    width: 0.0),
                              ),
                              child: Center(
                                child: DropdownButton<String>(
                                    value: prefferedNewValue,
                                    icon: Icon(Icons.arrow_drop_down),
                                    iconSize: 42,
                                    underline: SizedBox(),
                                    onChanged: (String newvalue) {
                                      //update hight data
                                      String _inch;
                                      if (newvalue.characters
                                              .characterAt(3)
                                              .toString() ==
                                          "1") {
                                        if (newvalue.characters
                                                    .characterAt(4)
                                                    .toString() ==
                                                "1" ||
                                            newvalue.characters
                                                    .characterAt(4)
                                                    .toString() ==
                                                "0") {
                                          _inch = newvalue.characters
                                                      .characterAt(4)
                                                      .toString() ==
                                                  "0"
                                              ? "10"
                                              : "11";
                                        } else {
                                          _inch = newvalue.characters
                                              .characterAt(3)
                                              .toString();
                                        }
                                      } else {
                                        _inch = newvalue.characters
                                            .characterAt(3)
                                            .toString();
                                      }

                                      var _feet = newvalue.characters
                                          .characterAt(0)
                                          .toString();
                                      profileCaches.addUserInfoPro(
                                          {"preferredHeight": "$_feet,$_inch"},
                                          widget.database);
                                    },
                                    items: <String>[
                                      "4'" + ' 5"' + '(< 135 cm)',
                                      "4'" + ' 6"' + " (137 cm)",
                                      "4'" + ' 7"' + " (140 cm)",
                                      "4'" + ' 8"' + " (142 cm)",
                                      "4'" + ' 9"' + " (145 cm)",
                                      "4'" + ' 10"' + " (147 cm)",
                                      "4'" + ' 11"' + " (150 cm)",
                                      "5'" + ' 0"' + " (152 cm)",
                                      "5'" + ' 1"' + " (155 cm)",
                                      "5'" + ' 2"' + " (157 cm)",
                                      "5'" + ' 3"' + " (160 cm)",
                                      "5'" + ' 4"' + " (163 cm)",
                                      "5'" + ' 5"' + " (165 cm)",
                                      "5'" + ' 6"' + " (168 cm)",
                                      "5'" + ' 7"' + " (170 cm)",
                                      "5'" + ' 8"' + " (173 cm)",
                                      "5'" + ' 9"' + " (175 cm)",
                                      "5'" + ' 10"' + " (178 cm)",
                                      "5'" + ' 11"' + " (180 cm)",
                                      "6'" + ' 0"' + " (183 cm)",
                                      "6'" + ' 1"' + " (185 cm)",
                                      "6'" + ' 2"' + " (188 cm)",
                                      "6'" + ' 3"' + " (191 cm)",
                                      "6'" + ' 4"' + " (193 cm)",
                                      "6'" + ' 5"' + " (195 cm)",
                                      "6'" + ' 6"' + " (198 cm)",
                                      "6'" + ' 7"' + " (201 cm)",
                                      "6'" + ' 8"' + " (203 cm)",
                                      "6'" + ' 9"' + " (205 cm)",
                                      "6'" + ' 10"' + " (208 cm)",
                                      "6'" + ' 11"' + " (210 cm)",
                                      "7'" + ' 0"' + " (213 cm)",
                                      "7'" + ' 1"' + " (>216 cm)",
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style:
                                              Theme.of(context).textTheme.body2,
                                        ),
                                      );
                                    }).toList()),
                              ),
                            ),
                          );
                        }
                      })),
                  ListTile(
                      title: Text('Enable Height Filter',
                          style: Theme.of(context).textTheme.body2),
                      trailing: Switch.adaptive(
                          activeColor: Theme.of(context).primaryColor,
                          value: profileCaches
                                      .getUserInfoPro['heightFilterEnabled'] ==
                                  'true'
                              ? true
                              : false,
                          onChanged: (value) async {
                            bool fourth = await checkFouthAdvancedFilter(
                                'kidFilterEnabled',
                                'starSignFilterEnabled',
                                'educationFilterEnabled',
                                'loveLanguageFilterEnabled',
                                'DrinkFilterEnabled',
                                'FeministFilterEnabled',
                                'SmokeFilterEnabled',
                                data);
                            if (fourth) {
                              profileCaches.addUserInfoPro(
                                  {'heightFilterEnabled': '$value'},
                                  widget.database);
                            }
                          }))
                ],
              ),
              //=====================================
              Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'Drink',
                        style: Theme.of(context).textTheme.body2,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 3),
                    child: Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width / 1.35,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                            color: Colors.transparent,
                            style: BorderStyle.solid,
                            width: 0.0),
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                            value: profileCaches
                                .getUserInfoPro['preferedDrinkStatus'],
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 42,
                            underline: SizedBox(),
                            onChanged: (String newValue) {
                              profileCaches.addUserInfoPro(
                                  {'preferedDrinkStatus': '$newValue'},
                                  widget.database);
                            },
                            items: <String>['Social', 'Never', 'Frequent']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: Theme.of(context).textTheme.body2,
                                ),
                              );
                            }).toList()),
                      ),
                    ),
                  ),
                  ListTile(
                      title: Text('Enable Drink Filter',
                          style: Theme.of(context).textTheme.body2),
                      trailing: Switch.adaptive(
                          activeColor: Theme.of(context).primaryColor,
                          value: profileCaches
                                      .getUserInfoPro['DrinkFilterEnabled'] ==
                                  'true'
                              ? true
                              : false,
                          onChanged: (value) async {
                            bool fifth = await checkFouthAdvancedFilter(
                                'heightFilterEnabled',
                                'starSignFilterEnabled',
                                'kidFilterEnabled',
                                'loveLanguageFilterEnabled',
                                'DrinkFilterEnabled',
                                'FeministFilterEnabled',
                                'SmokeFilterEnabled',
                                data);
                            if (fifth) {
                              profileCaches.addUserInfoPro(
                                  {'DrinkFilterEnabled': '$value'},
                                  widget.database);
                            }
                          }))
                ],
              ),
              //
              Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'Feminist',
                        style: Theme.of(context).textTheme.body2,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 3),
                    child: Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width / 1.35,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                            color: Colors.transparent,
                            style: BorderStyle.solid,
                            width: 0.0),
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                            value: profileCaches
                                .getUserInfoPro['preferedFeministStatus'],
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 42,
                            underline: SizedBox(),
                            onChanged: (String newValue) {
                              profileCaches.addUserInfoPro(
                                  {'preferedFeministStatus': '$newValue'},
                                  widget.database);
                            },
                            items: <String>[
                              'Absolutely',
                              'No way',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: Theme.of(context).textTheme.body2,
                                ),
                              );
                            }).toList()),
                      ),
                    ),
                  ),
                  ListTile(
                      title: Text('Enable Feminist Filter',
                          style: Theme.of(context).textTheme.body2),
                      trailing: Switch.adaptive(
                          activeColor: Theme.of(context).primaryColor,
                          value: profileCaches
                                  .getUserInfoPro['FeministFilterEnabled']
                                  .toString()
                                  .toLowerCase() ==
                              'true',
                          onChanged: (value) async {
                            bool sixth = await checkFouthAdvancedFilter(
                                'heightFilterEnabled',
                                'starSignFilterEnabled',
                                'kidFilterEnabled',
                                'loveLanguageFilterEnabled',
                                'DrinkFilterEnabled',
                                'FeministFilterEnabled',
                                'SmokeFilterEnabled',
                                data);
                            if (sixth) {
                              profileCaches.addUserInfoPro(
                                  {'FeministFilterEnabled': '${value}'},
                                  widget.database);
                            }
                          })),
                ],
              ),

              //
              Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'Smoke',
                        style: Theme.of(context).textTheme.body2,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 3),
                    child: Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width / 1.35,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                            color: Colors.transparent,
                            style: BorderStyle.solid,
                            width: 0.0),
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                            value: profileCaches
                                .getUserInfoPro['preferedSmokeStatus'],
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 42,
                            underline: SizedBox(),
                            onChanged: (String newValue) {
                              profileCaches.addUserInfoPro(
                                  {'preferedSmokeStatus': '$newValue'},
                                  widget.database);
                            },
                            items: <String>[
                              'Social',
                              'Never',
                              'Frequent',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: Theme.of(context).textTheme.body2,
                                ),
                              );
                            }).toList()),
                      ),
                    ),
                  ),
                  ListTile(
                      title: Text('Enable Smoke Filter',
                          style: Theme.of(context).textTheme.body2),
                      trailing: Switch.adaptive(
                          activeColor: Theme.of(context).primaryColor,
                          value: profileCaches
                                      .getUserInfoPro['SmokeFilterEnabled'] ==
                                  'true'
                              ? true
                              : false,
                          onChanged: (value) async {
                            bool seventh = await checkFouthAdvancedFilter(
                                'heightFilterEnabled',
                                'starSignFilterEnabled',
                                'kidFilterEnabled',
                                'loveLanguageFilterEnabled',
                                'DrinkFilterEnabled',
                                'FeministFilterEnabled',
                                'SmokeFilterEnabled',
                                data);
                            if (seventh) {
                              profileCaches.addUserInfoPro(
                                  {'SmokeFilterEnabled': '$value'},
                                  widget.database);
                            }
                          })),
                ],
              ),
            ],
          )
        ]);
      });

  Widget _aboutMe(data, bool complete) => Column(
        children: <Widget>[
          Visibility(
            visible: data["preferences"] != "friend",
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Love Language',
                  style: Theme.of(context).textTheme.body2,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          Consumer<ProfileImageCaches>(
            builder: (BuildContext context, ProfileImageCaches profileCaches,
                Widget child) {
              return Visibility(
                visible: profileCaches.getUserInfo["preferences"] != "friend",
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, bottom: 10, top: 3),
                  child: Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width / 1.35,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                          color: Colors.transparent,
                          style: BorderStyle.solid,
                          width: 0.0),
                    ),
                    child: Center(
                      child: DropdownButton<String>(
                          value: profileCaches.getUserInfo['loveLanguage'],
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 42,
                          underline: SizedBox(),
                          onChanged: (String newValue) {
                            print(profileCaches.getUserInfo['loveLanguage']);
                            profileCaches.addUserInfo(
                                {"loveLanguage": "$newValue"}, widget.database);
                          },
                          items: <String>[
                            'None',
                            'Words of affirmation',
                            'Quality time',
                            'Receiving gifts',
                            'Acts of service',
                            'Physical touch',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: Theme.of(context).textTheme.body2,
                              ),
                            );
                          }).toList()),
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Star Sign',
                style: Theme.of(context).textTheme.body2,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Consumer<ProfileImageCaches>(builder: (BuildContext context,
              ProfileImageCaches profileCaches, Widget child) {
            return Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 10, top: 3),
              child: Container(
                height: 55,
                width: MediaQuery.of(context).size.width / 1.35,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                      color: Colors.transparent,
                      style: BorderStyle.solid,
                      width: 0.0),
                ),
                child: Center(
                  child: DropdownButton<String>(
                      value: profileCaches.getUserInfo["starSign"],
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 42,
                      underline: SizedBox(),
                      onChanged: (String newValue) {
                        profileCaches.addUserInfo(
                            {"starSign": "$newValue"}, widget.database);
                      },
                      items: <String>[
                        'None',
                        'Aries',
                        'Taurus',
                        'Gemini',
                        'Cancer',
                        'Leo',
                        'Virgo',
                        'Libra',
                        'Scorpio',
                        'Sagittarius',
                        'Capricorn',
                        'Aquarius',
                        'Pisces'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: Theme.of(context).textTheme.body2,
                          ),
                        );
                      }).toList()),
                ),
              ),
            );
          }),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Pets',
                style: Theme.of(context).textTheme.body2,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Consumer<ProfileImageCaches>(
            builder: (BuildContext context, ProfileImageCaches profileCaches,
                Widget child) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 10, top: 3),
                child: Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width / 1.35,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                        color: Colors.transparent,
                        style: BorderStyle.solid,
                        width: 0.0),
                  ),
                  child: Center(
                    child: DropdownButton<String>(
                        value: profileCaches.getUserInfo["pets"],
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 42,
                        underline: SizedBox(),
                        onChanged: (String newValue) {
                          profileCaches.addUserInfo(
                              {"pets": "$newValue"}, widget.database);
                        },
                        items: <String>[
                          'Dog',
                          'Cat',
                          'Many',
                          'None',
                          'Don\'t Want',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: Theme.of(context).textTheme.body2,
                            ),
                          );
                        }).toList()),
                  ),
                ),
              );
            },
          ),
          Visibility(
            visible: data["preferences"] != "friend",
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Children',
                  style: Theme.of(context).textTheme.body2,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          Consumer<ProfileImageCaches>(
            builder: (BuildContext context, ProfileImageCaches profileCaches,
                Widget child) {
              return Visibility(
                  visible: profileCaches.getUserInfo["preferences"] != "friend",
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 3),
                    child: Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width / 1.35,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                            color: Colors.transparent,
                            style: BorderStyle.solid,
                            width: 0.0),
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                            value: profileCaches.getUserInfo["kids"],
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 42,
                            underline: SizedBox(),
                            onChanged: (String newValue) {
                              profileCaches.addUserInfo(
                                  {"kids": "$newValue"}, widget.database);
                            },
                            items: <String>[
                              'None',
                              'Have but still want more',
                              'Have but don\'t want more',
                              'Don\'t have',
                              'Want someday',
                              'Don\'t want',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: Theme.of(context).textTheme.body2,
                                ),
                              );
                            }).toList()),
                      ),
                    ),
                  ));
            },
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Education',
                style: Theme.of(context).textTheme.body2,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Consumer<ProfileImageCaches>(
            builder: (BuildContext context, ProfileImageCaches profileCaches,
                Widget child) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 10, top: 3),
                child: Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width / 1.35,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                        color: Colors.transparent,
                        style: BorderStyle.solid,
                        width: 0.0),
                  ),
                  child: Center(
                    child: DropdownButton<String>(
                        value: profileCaches.getUserInfo["educationLevel"],
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 42,
                        underline: SizedBox(),
                        onChanged: (String newValue) {
                          profileCaches.addUserInfo(
                              {"educationLevel": "$newValue"}, widget.database);
                        },
                        items: <String>[
                          'None',
                          'High School',
                          'Trade / Tech School',
                          'College',
                          'Undergraduate Degree',
                          'Grad School',
                          'Graduate Degree',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: Theme.of(context).textTheme.body2,
                            ),
                          );
                        }).toList()),
                  ),
                ),
              );
            },
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Occupation',
                style: Theme.of(context).textTheme.body2,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          _textFields(
              "occupation",
              "Enter your work",
              1,
              1,
              20,
              true,
              _occupationTextControllerTwo,
              _occupationFocusNodeTwo,
              _promptFocusNode),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Town',
                style: Theme.of(context).textTheme.body2,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Consumer<ProfileImageCaches>(builder: (BuildContext context,
              ProfileImageCaches profileCaches, Widget child) {
            if (profileCaches.getUserInfo["location"] == "Loading..." ||
                profileCaches.getUserInfo["location"] == "0,0" ||
                profileCaches.getUserInfo["location"] == "")
              profileCaches.getUserLocation(widget.database);

            townData = profileCaches.getUserInfo["locationName"];
            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                        color: Colors.grey[100],
                        style: BorderStyle.solid,
                        width: 0.0),
                  ),
                  child: ListTile(
                    title: Text(
                      profileCaches.getUserInfo["locationName"],
                      style: TextStyle(
                          fontFamily: "Papyrus",
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    trailing: IconButton(
                        icon: Icon(
                          Icons.location_on,
                          color: Colors.grey[600],
                        ),
                        onPressed: () async {
                          PlatformAlertDialog(
                                  title: 'Change location',
                                  content:
                                      'To change you location tap the passport mode section below',
                                  defaultActionText: 'Ok')
                              .show(context);
                        }),
                  )),
            );
          }),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Prompt',
                style: Theme.of(context).textTheme.body2,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Choose your prompt',
                style: TextStyle(
                    fontFamily: 'Papyrus',
                    fontSize: 12,
                    fontWeight: FontWeight.normal),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Consumer<ProfileImageCaches>(
            builder: (BuildContext context, ProfileImageCaches profileCaches,
                Widget child) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 10, top: 3),
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width / 1.20,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                        color: Colors.transparent,
                        style: BorderStyle.solid,
                        width: 0.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: DropdownButton<String>(
                          value: profileCaches.getUserInfo["chosenPrompt"]
                              .toString(),
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 42,
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (String newValue) {
                            profileCaches.addUserInfo(
                                {"chosenPrompt": "$newValue"}, widget.database);
                          },
                          items: <String>[
                            'My favorite bible passage is...',
                            'This week I was most blessed by…',
                            "I feel God’s presence most when…",
                            'Two ways I want God to transform me are…',
                            'I feel most distant from God when…',
                            'Three ways I can apply the Gospel to my life are…',
                            'My enthusiasm for the Gospel increased when…',
                            'The area I feel I need to put more trust in God is…',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: Theme.of(context).textTheme.body2,
                              ),
                            );
                          }).toList()),
                    ),
                  ),
                ),
              );
            },
          ),
          _textFields("promptInput", "Enter your answer", 1, 3, 120, false,
              _promptTextController, _promptFocusNode, _anotherPromptFocusNode),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Choose your prompt',
                style: TextStyle(
                    fontFamily: 'Papyrus',
                    fontSize: 12,
                    fontWeight: FontWeight.normal),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Consumer<ProfileImageCaches>(
            builder: (BuildContext context, ProfileImageCaches profileCaches,
                Widget child) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 10, top: 3),
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width / 1.20,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                        color: Colors.transparent,
                        style: BorderStyle.solid,
                        width: 0.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: DropdownButton<String>(
                          value: profileCaches.getUserInfo["anotherPrompt"],
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 42,
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (String newValue) {
                            profileCaches.addUserInfo(
                                {"anotherPrompt": "$newValue"},
                                widget.database);
                          },
                          items: <String>[
                            'The joy of God is...',
                            'Prayer brings me…',
                            'God’s purpose for me is…',
                            'This week, God taught me…',
                            'A time in my life when God saved me was…',
                            'A blessing that God recently gifted me was…',
                            'A time I doubted God’s love for me was when…',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: Theme.of(context).textTheme.body2,
                              ),
                            );
                          }).toList()),
                    ),
                  ),
                ),
              );
            },
          ),
          _textFields(
              "anotherPromptInput",
              "Enter your answer",
              1,
              3,
              120,
              false,
              _anotherPromptTextController,
              _anotherPromptFocusNode,
              _secondAnotherPromptFocusNode),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Choose your prompt',
                style: TextStyle(
                    fontFamily: 'Papyrus',
                    fontSize: 12,
                    fontWeight: FontWeight.normal),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Consumer<ProfileImageCaches>(
            builder: (BuildContext context, ProfileImageCaches profileCaches,
                Widget child) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 10, top: 3),
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width / 1.20,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                        color: Colors.transparent,
                        style: BorderStyle.solid,
                        width: 0.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: DropdownButton<String>(
                          value:
                              profileCaches.getUserInfo["secondAnotherPrompt"],
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 42,
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (String newValue) {
                            profileCaches.addUserInfo(
                                {"secondAnotherPrompt": "$newValue"},
                                widget.database);
                          },
                          items: <String>[
                            "An ideal day off for me would look like...",
                            "The very best day of my life was...",
                            "If I could go anywhere in the world, it would be...",
                            "My favorite song right now is...",
                            "The worst idea I've ever had was...",
                            "The most spontaneous thing I've done was...",
                            "I will know I have found the one when...",
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: Theme.of(context).textTheme.body2,
                              ),
                            );
                          }).toList()),
                    ),
                  ),
                ),
              );
            },
          ),
          _textFields(
              "secondAnotherPromptInput",
              "Enter your answer",
              1,
              3,
              120,
              false,
              _secondAnotherPromptTextController,
              _secondAnotherPromptFocusNode,
              _nameFocusNode),
        ],
      );

  Widget _appSettings(data, bool complete) =>
      Consumer<ProfileImageCaches>(builder: (BuildContext context,
          ProfileImageCaches profileCaches, Widget child) {
        return Container(
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Discoverable by other users',
                    style: Theme.of(context).textTheme.body2,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  ChoiceChip(
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey[100],
                    selected:
                        profileCaches.getUserInfo['discoverable'] == "Yes",
                    onSelected: (value) {
                      profileCaches.addUserInfo(
                          {'discoverable': "Yes"}, widget.database);
                    },
                    label: Container(
                      width: 60,
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Spacer(),
                  ChoiceChip(
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey[100],
                    selected: profileCaches.getUserInfo['discoverable'] == "No",
                    onSelected: (value) {
                      profileCaches
                          .addUserInfo({'discoverable': "No"}, widget.database);
                    },
                    label: Container(
                      width: 60,
                      child: Text(
                        'No',
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.body2,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  ChoiceChip(
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey[100],
                    selected:
                        profileCaches.getUserInfo['notifications'] == "Yes",
                    onSelected: (value) {
                      profileCaches.addUserInfo(
                          {'notifications': "Yes"}, widget.database);
                    },
                    label: Container(
                      width: 60,
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Spacer(),
                  ChoiceChip(
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey[100],
                    selected:
                        profileCaches.getUserInfo['notifications'] == "No",
                    onSelected: (value) {
                      profileCaches.addUserInfo(
                          {'notifications': "No"}, widget.database);
                    },
                    label: Container(
                      width: 60,
                      child: Text(
                        'No',
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Read Receipts',
                    style: Theme.of(context).textTheme.body2,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  ChoiceChip(
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey[100],
                    selected:
                        profileCaches.getUserInfo['read_receipts'] == "Yes",
                    onSelected: (value) {
                      profileCaches.addUserInfo(
                          {'read_receipts': "Yes"}, widget.database);
                    },
                    label: Container(
                      width: 60,
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Spacer(),
                  ChoiceChip(
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey[100],
                    selected:
                        profileCaches.getUserInfo['read_receipts'] == "No",
                    onSelected: (value) {
                      profileCaches.addUserInfo(
                          {'read_receipts': "No"}, widget.database);
                    },
                    label: Container(
                      width: 60,
                      child: Text(
                        'No',
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              )
            ],
          ),
        );
      });

  Widget _profileImages(data) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.body1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Container(
          // ignore: missing_return
          child: Consumer<ProfileImageCaches>(builder: (BuildContext context,
              ProfileImageCaches profileCaches, Widget child) {
            if (!profileCaches.cachedState ||
                profileCaches.userProfiles.isEmpty ||
                profileCaches.rebuildstate)
              profileCaches.profileImages(widget.storage, widget.database);

            // if (profileCaches.cachedState != false) {
            return ReorderableWrap(
              alignment: WrapAlignment.center,
              spacing: MediaQuery.of(context).size.width / 20,
              runSpacing: MediaQuery.of(context).size.width / 20,
              padding: const EdgeInsets.all(8),
              children: List<Widget>.generate(6, (int index) {
                if (index < profileCaches.userProfiles.length) {
                  var _url = profileCaches.userProfiles.elementAt(index);
                  return Stack(children: [
                    Card(
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: Colors.white,
                          width: 6.0,
                        ),
                      ),
                      elevation: 8,
                      child: new Container(
                          width: MediaQuery.of(context).size.width / 5,
                          height: MediaQuery.of(context).size.width / 5,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                    _url,
                                  )))),
                    ),
                    profileCaches.userProfiles.length != 1
                        ? Positioned(
                            child: GestureDetector(
                              onTap: () => profileCaches.deleteProfileImage(
                                  index, widget.storage, widget.database, data),
                              child: Card(
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: Colors.white,
                                    width: 6.0,
                                  ),
                                ),
                                elevation: 8,
                                child: new Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  height:
                                      MediaQuery.of(context).size.width / 15,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close),
                                ),
                              ),
                            ),
                          )
                        : Positioned(
                            child: GestureDetector(
                              onTap: () {},
                              child: Card(
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: Colors.white,
                                    width: 6.0,
                                  ),
                                ),
                                elevation: 8,
                              ),
                            ),
                          )
                  ]);
                } else if (index == profileCaches.userProfiles.length) {
                  return GestureDetector(
                    onTap: () {
                      Alert(
                              context: context,
                              title: "Add profile picture",
                              desc:
                                  "Please choose one of the options below to add a profile image.",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Take Photo",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                  onPressed: () async {
                                    var _image =
                                        await _getImageFile(ImageSource.camera);
                                    Navigator.pop(context);
                                    var croppedFile =
                                        await ImageCropper.cropImage(
                                            sourcePath: _image.path,
                                            aspectRatioPresets: [
                                              CropAspectRatioPreset.square,
                                              CropAspectRatioPreset.ratio3x2,
                                              CropAspectRatioPreset.original,
                                              CropAspectRatioPreset.ratio4x3,
                                              CropAspectRatioPreset.ratio16x9
                                            ],
                                            androidUiSettings:
                                                AndroidUiSettings(
                                                    toolbarTitle: 'Cropper',
                                                    toolbarColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    toolbarWidgetColor:
                                                        Colors.white,
                                                    initAspectRatio:
                                                        CropAspectRatioPreset
                                                            .original,
                                                    lockAspectRatio: false),
                                            iosUiSettings: IOSUiSettings(
                                              minimumAspectRatio: 1.0,
                                            ));

                                    profileCaches.storeProfileImagesAndCache(
                                        widget.storage,
                                        widget.database,
                                        croppedFile,
                                        context);
                                  },
                                  color: Theme.of(context).primaryColor,
                                ),
                                DialogButton(
                                  child: Text(
                                    "Upload File",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                  onPressed: () async {
                                    var _image = await _getImageFile(
                                        ImageSource.gallery);
                                    Navigator.pop(context);
                                    var croppedFile =
                                        await ImageCropper.cropImage(
                                            sourcePath: _image.path,
                                            aspectRatioPresets: [
                                              CropAspectRatioPreset.square,
                                              CropAspectRatioPreset.ratio3x2,
                                              CropAspectRatioPreset.original,
                                              CropAspectRatioPreset.ratio4x3,
                                              CropAspectRatioPreset.ratio16x9
                                            ],
                                            androidUiSettings:
                                                AndroidUiSettings(
                                                    toolbarTitle: 'Cropper',
                                                    toolbarColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    toolbarWidgetColor:
                                                        Colors.white,
                                                    initAspectRatio:
                                                        CropAspectRatioPreset
                                                            .original,
                                                    lockAspectRatio: false),
                                            iosUiSettings: IOSUiSettings(
                                              minimumAspectRatio: 1.0,
                                            ));
                                    //_storeProfileImage(croppedFile);
                                    profileCaches.storeProfileImagesAndCache(
                                        widget.storage,
                                        widget.database,
                                        croppedFile,
                                        context);
                                  },
                                  color: Theme.of(context).primaryColor,
                                )
                              ],
                              closeFunction: () {})
                          .show();
                    },
                    child: Card(
                      color: Colors.grey[100],
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: Colors.grey[100],
                          width: 6.0,
                        ),
                      ),
                      elevation: 0,
                      child: DottedBorder(
                        borderType: BorderType.Circle,
                        color: Colors.grey,
                        strokeWidth: 6,
                        child: new Container(
                          width: MediaQuery.of(context).size.width / 5.3,
                          height: MediaQuery.of(context).size.width / 5.3,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 8,
                                  child: Text(
                                    ' Add photo',
                                    style: TextStyle(
                                      fontFamily: 'Papyrus',
                                      fontSize: 8,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Card(
                    color: Colors.grey[100],
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: Colors.grey[100],
                        width: 6.0,
                      ),
                    ),
                    elevation: 0,
                    child: DottedBorder(
                      borderType: BorderType.Circle,
                      color: Colors.grey,
                      strokeWidth: 6,
                      child: new Container(
                        width: MediaQuery.of(context).size.width / 5.3,
                        height: MediaQuery.of(context).size.width / 5.3,
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }
              })
                ..add(_videoCard(data)),
              onReorder: _onReorder,
            );
            // } else {
            //   return CircularProgressIndicator();
            // }
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.grey),
            ),
            child: Text(
              'Hold & drag your photos to change the order',
              style: TextStyle(
                fontFamily: "Papyrus",
                fontWeight: FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _videoCard(data) {
    final videoPath = data['videoUrl'];
    final bool videoEmpty = videoPath == null || videoPath == "";
    Widget none = GestureDetector(
      onTap: () async {
        var result = await FilePicker.getFile(
          type: FileType.video,
        );
        if (result != null) {
          _storeVideoImage(result);
        }
      },
      child: Card(
        color: Colors.grey[100],
        shape: StadiumBorder(
          side: BorderSide(
            color: Colors.grey[100],
            width: 6.0,
          ),
        ),
        elevation: 0,
        child: DottedBorder(
          borderType: BorderType.Circle,
          color: Colors.grey,
          strokeWidth: 6,
          child: new Container(
            width: MediaQuery.of(context).size.width / 5.3,
            height: MediaQuery.of(context).size.width / 5.3,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 2, 2, 2),
                  child: SvgPicture.asset(
                    "assets/images/icons/camera_icon.svg",
                    height: 28,
                    width: 28,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 8,
                    child: Text(
                      ' Add video',
                      style: TextStyle(
                        fontFamily: 'Papyrus',
                        fontSize: 8,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
    Widget preview = Stack(
      children: [
        Card(
          shape: StadiumBorder(
            side: BorderSide(
              color: Colors.white,
              width: 6.0,
            ),
          ),
          elevation: 8,
          child: ClipOval(
            clipper: MyClipper(),
            child: Container(
              width: MediaQuery.of(context).size.width / 5,
              height: MediaQuery.of(context).size.width / 5,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: VideoPreviewSmall(
                bucket: data["imageBucket"],
                videoPath: data["videoPath"],
              ),
            ),
          ),
        ),
        Positioned(
          child: GestureDetector(
            onTap: () {
              widget.storage
                  .deleteProfileVideo(widget.database, data["videoPath"]);
            },
            child: Card(
              shape: StadiumBorder(
                side: BorderSide(
                  color: Colors.white,
                  width: 6.0,
                ),
              ),
              elevation: 8,
              child: new Container(
                width: MediaQuery.of(context).size.width / 15,
                height: MediaQuery.of(context).size.width / 15,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close),
              ),
            ),
          ),
        )
      ],
    );
    return videoEmpty ? none : preview;
  }

  void printText(String text) {
    print(">>>> $text <<<<<");
  }

  Widget _personalInfo(data, bool complete) => Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Name',
                  style: Theme.of(context).textTheme.body2,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                        color: Colors.grey[100],
                        style: BorderStyle.solid,
                        width: 0.0),
                  ),
                  child: Consumer<ProfileImageCaches>(builder:
                      (BuildContext context, ProfileImageCaches profileCaches,
                          Widget child) {
                    if (profileCaches.getUserInfo.isEmpty)
                      profileCaches.userDetails(widget.database);

                    print(profileCaches.getUserInfo['name']);
                    return ListTile(
                      title: Text(
                        profileCaches.getUserInfo.isEmpty
                            ? "UnKnown"
                            : profileCaches.getUserInfo['name'],
                        style: TextStyle(
                            fontFamily: "Papyrus",
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                      ),
                    );
                  })),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Age',
                  style: Theme.of(context).textTheme.body2,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Consumer<ProfileImageCaches>(builder: (BuildContext context,
                ProfileImageCaches profileCaches, Widget child) {
              if (profileCaches.getUserInfo.isEmpty)
                profileCaches.userDetails(widget.database);
              print("profileCaches.getUserInfo['dateOfBirth']");
              return Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 10, top: 3),
                child: Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                        color: Colors.grey[100],
                        style: BorderStyle.solid,
                        width: 0.0),
                  ),
                  child: Center(
                      child: ListTile(
                    title: Text(
                      profileCaches.getUserInfo.isEmpty
                          ? "N/A"
                          : calculateAgeFromCache(
                                  profileCaches.getUserInfo['dateOfBirth'])
                              .toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Papyrus",
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                  )),
                ),
              );
            }),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'About Me',
                  style: Theme.of(context).textTheme.body2,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            _aboutMeTextFields(
                "aboutUser",
                "Tell us about yourself",
                3,
                true,
                _aboutUserTextController,
                _aboutUserFocusNode,
                _occupationFocusNodeTwo),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Gender',
                  style: Theme.of(context).textTheme.body2,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Consumer<ProfileImageCaches>(
              builder: (BuildContext context, ProfileImageCaches profileCaches,
                  Widget child) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, bottom: 10, top: 3),
                  child: Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width / 1.35,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                          color: Colors.transparent,
                          style: BorderStyle.solid,
                          width: 0.0),
                    ),
                    child: Center(
                      child: DropdownButton<String>(
                          value: profileCaches.getUserInfo["gender"],
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 42,
                          underline: SizedBox(),
                          onChanged: (String newValue) {
                            profileCaches.addUserInfo(
                                {"gender": "$newValue"}, widget.database);
                          },
                          items: <String>[
                            'Male',
                            'Female',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: Theme.of(context).textTheme.body2,
                              ),
                            );
                          }).toList()),
                    ),
                  ),
                );
              },
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Height',
                  style: Theme.of(context).textTheme.body2,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, bottom: 10, top: 3),
              child: Consumer<ProfileImageCaches>(builder:
                  (BuildContext context, ProfileImageCaches profileCaches,
                      Widget child) {
                var _heightList =
                    profileCaches.getUserInfo['height'].toString().split(',');
                var _feet = _heightList[0];
                var _inch = _heightList[1];

                _checkHeightIsInRange(feet: _feet, inch: _inch);
                _heightDropDownHelper(feet: _feet, inch: _inch);

                return Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, bottom: 10, top: 3),
                  child: Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width / 1.35,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                          color: Colors.transparent,
                          style: BorderStyle.solid,
                          width: 0.0),
                    ),
                    child: Center(
                      child: DropdownButton<String>(
                          value: newValue,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 42,
                          underline: SizedBox(),
                          onChanged: (String newvalue) {
                            String _inch;
                            if (newvalue.characters.characterAt(3).toString() ==
                                "1") {
                              if (newvalue.characters
                                          .characterAt(4)
                                          .toString() ==
                                      "1" ||
                                  newvalue.characters
                                          .characterAt(4)
                                          .toString() ==
                                      "0") {
                                _inch = newvalue.characters
                                            .characterAt(4)
                                            .toString() ==
                                        "0"
                                    ? "10"
                                    : "11";
                              } else {
                                _inch = newvalue.characters
                                    .characterAt(3)
                                    .toString();
                              }
                            } else {
                              _inch =
                                  newvalue.characters.characterAt(3).toString();
                            }

                            var _feet =
                                newvalue.characters.characterAt(0).toString();
                            profileCaches.addUserInfo(
                                {"height": "$_feet,$_inch"}, widget.database);
                          },
                          items: <String>[
                            "4'" + ' 5"' + '(< 135 cm)',
                            "4'" + ' 6"' + " (137 cm)",
                            "4'" + ' 7"' + " (140 cm)",
                            "4'" + ' 8"' + " (142 cm)",
                            "4'" + ' 9"' + " (145 cm)",
                            "4'" + ' 10"' + " (147 cm)",
                            "4'" + ' 11"' + " (150 cm)",
                            "5'" + ' 0"' + " (152 cm)",
                            "5'" + ' 1"' + " (155 cm)",
                            "5'" + ' 2"' + " (157 cm)",
                            "5'" + ' 3"' + " (160 cm)",
                            "5'" + ' 4"' + " (163 cm)",
                            "5'" + ' 5"' + " (165 cm)",
                            "5'" + ' 6"' + " (168 cm)",
                            "5'" + ' 7"' + " (170 cm)",
                            "5'" + ' 8"' + " (173 cm)",
                            "5'" + ' 9"' + " (175 cm)",
                            "5'" + ' 10"' + " (178 cm)",
                            "5'" + ' 11"' + " (180 cm)",
                            "6'" + ' 0"' + " (183 cm)",
                            "6'" + ' 1"' + " (185 cm)",
                            "6'" + ' 2"' + " (188 cm)",
                            "6'" + ' 3"' + " (191 cm)",
                            "6'" + ' 4"' + " (193 cm)",
                            "6'" + ' 5"' + " (195 cm)",
                            "6'" + ' 6"' + " (198 cm)",
                            "6'" + ' 7"' + " (201 cm)",
                            "6'" + ' 8"' + " (203 cm)",
                            "6'" + ' 9"' + " (205 cm)",
                            "6'" + ' 10"' + " (208 cm)",
                            "6'" + ' 11"' + " (210 cm)",
                            "7'" + ' 0"' + " (213 cm)",
                            "7'" + ' 1"' + " (>216 cm)",
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: Theme.of(context).textTheme.body2,
                              ),
                            );
                          }).toList()),
                    ),
                  ),
                );
              }),
            ),
          ]);

  Widget _proFeatures(data) {
    return Column(
      children: <Widget>[
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
              'Tap on the map then hit \'set new location\', to update your location.\n\nTap the circle button to set to your current location.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.body2),
        ),
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Colors.white,
            child: Container(
              color: Colors.transparent,
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FutureBuilder(
                      future: widget.database.getSpecificUserValues('location'),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          userPosition = snapshot.data.value.split(',');

                          cameraPosition = CameraPosition(
                              target: LatLng(
                                  double.parse(userPosition[0].toString()),
                                  double.parse(userPosition[1].toString())),
                              zoom: 12);
                          return Stack(
                            children: [
                              GoogleMap(
                                  gestureRecognizers: Set()
                                    ..add(Factory<PanGestureRecognizer>(
                                        () => PanGestureRecognizer()))
                                    ..add(Factory<ScaleGestureRecognizer>(
                                        () => ScaleGestureRecognizer()))
                                    ..add(Factory<TapGestureRecognizer>(
                                        () => TapGestureRecognizer()))
                                    ..add(Factory<
                                            VerticalDragGestureRecognizer>(
                                        () => VerticalDragGestureRecognizer())),
                                  scrollGesturesEnabled: true,
                                  onTap: (position) async {
                                    positiontoStore =
                                        '${position.latitude},${position.longitude}';
                                    controller.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                                target: LatLng(
                                                    position.latitude,
                                                    position.longitude),
                                                zoom: 12)));
                                  },
                                  zoomControlsEnabled: true,
                                  zoomGesturesEnabled: true,
                                  markers: Set<Marker>.of(markers.values),
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: true,
                                  onMapCreated:
                                      (GoogleMapController controller) async {
                                    GoogleMapController controller =
                                        await _controller.future;
                                    _controller.complete(controller);
                                    controller.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                      cameraPosition,
                                    ));
                                  },
                                  rotateGesturesEnabled: true,
                                  initialCameraPosition: cameraPosition),
                              IconButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SafeArea(
                                      child: SafeArea(
                                        child: PlacePicker(
                                          apiKey:
                                              "AIzaSyB17AVPCtRwT3O0TEha0pRgehZKA-MDJEo",
                                          // Put YOUR OWN KEY here.
                                          onPlacePicked: (result) {
                                            setState(() {
                                              _mapOptionCallByExpanded = true;
                                              _mapAddress =
                                                  result.formattedAddress;
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          initialPosition: LatLng(
                                              double.parse(userPosition[0]),
                                              double.parse(userPosition[1])),
                                          useCurrentLocation: true,
                                          enableMapTypeButton: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                icon: Icon(Icons.center_focus_strong),
                              ),
                            ],
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Theme.of(context).primaryColor,
                              color: Colors.white,
                            ),
                          );
                        }
                      }),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        _mapOptionCallByExpanded == false
            ? townData == "unKnown"
                ? Container()
                : Align(
                    alignment: Alignment.center,
                    child: Text(
                      townData.toString(),
                      style: TextStyle(
                          fontFamily: "Papyrus",
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                  )
            : Align(
                alignment: Alignment.center,
                child: Text(
                  _mapAddress,
                  style: TextStyle(
                      fontFamily: "Papyrus",
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
              ),
        SizedBox(height: 20),
        ListTile(
          title: RaisedButton(
            elevation: 16.0,
            onPressed: () async {
              if (_mapOptionCallByExpanded == false) {
                var _coordinateList = positiontoStore.split(',');
                List<Placemark> placemark = await Geolocator()
                    .placemarkFromCoordinates(double.parse(_coordinateList[0]),
                        double.parse(_coordinateList[1]));

                widget.database.updateUserDetails({
                  'location': positiontoStore,
                  "locationName":
                      "${placemark[0].locality}, ${placemark[0].administrativeArea}",
                });
                setState(() {
                  List positions = positiontoStore.split(',');
                  MarkerId markerID = MarkerId(positiontoStore);
                  Marker marker = Marker(
                      position: LatLng(double.parse(positions[0]),
                          double.parse(positions[1])),
                      markerId: markerID);
                  markers[markerID] = marker;
                });
              } else {
                widget.database.updateUserDetails({
                  'location': positiontoStore,
                  "locationName": _mapAddress,
                });
                setState(() {
                  List positions = positiontoStore.split(',');
                  MarkerId markerID = MarkerId(positiontoStore);
                  Marker marker = Marker(
                      position: LatLng(double.parse(positions[0]),
                          double.parse(positions[1])),
                      markerId: markerID);
                  markers[markerID] = marker;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Spacer(),
                  Text(
                    'Set new location',
                    style: Theme.of(context).textTheme.body2,
                  ),
                  Spacer(),
                  Icon(Icons.edit_location)
                ],
              ),
            ),
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _aboutMeTextFields(
    String attribute,
    String displayValue,
    int maxLines,
    bool enforceMax,
    TextEditingController controller,
    FocusNode currentFocus,
    FocusNode nextFocus,
  ) =>
      Container(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 3),
          child: Consumer<ProfileImageCaches>(builder: (BuildContext context,
              ProfileImageCaches profileCaches, Widget child) {
            var _displayValue = profileCaches.getUserInfo[attribute];

            return Container(
              child: Form(
                key: _textKey,
                child: TextFormField(
                  controller: controller,
                  focusNode: currentFocus,
                  maxLines: maxLines,
                  autofocus: true,
                  onChanged: (value) {
                    profileCaches
                        .addUserInfo({attribute: "$value"}, widget.database);
                  },
                  cursorColor: Colors.black,
                  style: Theme.of(context).textTheme.body2,
                  decoration: InputDecoration(
                    hintText: "$_displayValue",
                    hintStyle: Theme.of(context).textTheme.body2,
                  ),
                ),
              ),
            );
          }),
        ),
      );

  Widget _textFields(
    String attribute,
    String displayValue,
    int minLines,
    int maxLines,
    int maxCharacters,
    bool enforceMax,
    TextEditingController controller,
    FocusNode currentFocus,
    FocusNode nextFocus,
  ) =>
      Container(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 3),
          child: Consumer<ProfileImageCaches>(builder: (BuildContext context,
              ProfileImageCaches profileCaches, Widget child) {
            var _displayValue = profileCaches.getUserInfo[attribute];

            return Container(
              child: TextFormField(
                controller: controller,
                focusNode: currentFocus,
                minLines: minLines,
                maxLines: maxLines,
                maxLength: maxCharacters,
                maxLengthEnforced: enforceMax,
                onChanged: (value) {
                  profileCaches
                      .addUserInfo({attribute: "$value"}, widget.database);
                },
                cursorColor: Colors.black,
                style: Theme.of(context).textTheme.body2,
                decoration: InputDecoration(
                  hintText: "$_displayValue",
                  hintStyle: Theme.of(context).textTheme.body2,
                ),
              ),
            );
          }),
        ),
      );

  Theme _buildExpansionTile(int index, Widget _children, data, String _title,
      GlobalKey expansionTileKey, Widget title) {
    return Theme(
      data: ThemeData(accentColor: Colors.black),
      child: ExpansionTile(
        key: expansionTileKey,
        onExpansionChanged: (isExpanded) {},
        title: title,
        children: <Widget>[Theme(data: Theme.of(context), child: _children)],
      ),
    );
  }
}
