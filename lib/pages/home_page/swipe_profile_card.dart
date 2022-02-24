import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:copticmeet/custom_icons/coptic_meet_icons_icons.dart';
import 'package:copticmeet/pages/profile/profile_page.dart';
import 'package:copticmeet/pages/video_preview.dart';
import 'package:copticmeet/pages/video_preview_medium.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/services/location/location.dart';
import 'package:copticmeet/services/storage/storage.dart';
import 'package:copticmeet/utils/color_utils.dart';
import 'package:copticmeet/widgets/liking_animation.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:copticmeet/services/database/database.dart';

import 'view_picture_page.dart';

class SwipeProfileCard extends StatefulWidget {
  SwipeProfileCard(
      {Key key,
      @required this.location,
      @required this.database,
      @required this.storage,
      @required this.preferences,
      @required this.userID,
      @required this.accountLocation})
      : super(key: key);
  final Location location;
  final Database database;
  final Storage storage;
  final String preferences;
  final userID;

  final accountLocation;

  @override
  _SwipeProfileCardState createState() => _SwipeProfileCardState();
}

class _SwipeProfileCardState extends State<SwipeProfileCard> {
  bool isLikeAnimating = false;

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

  PageController controller; // Gallery controller
  int likedPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  void getLikedPhotos() async {
    // final userReference = widget.database
    //     .reference()
    //     .child('users')
    //     .child(widget.userID)
    //     .child('likedMyPhotos');
    // final userData = await userReference.once();
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

  _checkHeightIsInRange({feet, inch}) {
    if (heightDefaultList.contains(feet.toString() + inch.toString())) {
    } else {
      if (heightFeetList.contains(feet)) {
      } else {}
    }
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

  Future _buildThumbnailUrl(int height, String link) async {
    final path = (await getTemporaryDirectory()).path;
    return VideoThumbnail.thumbnailFile(
      video: link,
      imageFormat: ImageFormat.PNG,
      thumbnailPath: path,
      maxHeight: height,
      maxWidth: height,
      quality: 100,
    );
  }

  Widget carrouselWidget(double height, List<dynamic> images, String video,
      String bucket, var userInfo) {
    if (video != null && video.isNotEmpty) {
      images.add(Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              "assets/images/icons/camera_icon.svg",
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.play_circle_fill,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
          )
        ],
      ));
    }
    final last = images.length - 1;
    return Carousel(
      images: images,
      boxFit: BoxFit.cover,
      autoplay: true,
      autoplayDuration: Duration(seconds: 5),
      dotSize: 4.0,
      onImageTap: (i) {
        final isVideo = video != null && video.isNotEmpty && i == last;
        if (!isVideo) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Builder(
                builder: (BuildContext context) {
                  return  ViewPicturePage(
                    controller: controller,
                    location: widget.location,
                    database: widget.database,
                    userID: widget.userID,
                    images:images,
                    userInfo:userInfo,
                    preferences: widget.preferences,
                    
                  );
                 
                },
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPreview(
                url: video,
                bucket: bucket,
              ),
            ),
          );
        }
      },
      dotSpacing: 15.0,
      dotColor: Theme.of(context).accentColor,
      indicatorBgPadding: 5.0,
      dotBgColor: Colors.white.withOpacity(0.2),
    );
  }

  Widget carrouselCacheWidget(
      double height, String stringUrls, String video, String bucket,var userInfo) {
    bool hasVideo = video != null && video.isNotEmpty;
    List list = json.decode(stringUrls);
    List<String> urls = list.map((s) => s as String).toList();
    List images = [];

    for (int i = 0; i < urls.length; i++) {
      images.add(CachedNetworkImageProvider(urls[i]));
    }

    if (hasVideo) {
      images.add(VideoPreviewMedium(video));
    }

    final last = images.length - 1;

    return Carousel(
      images: images,
      boxFit: BoxFit.cover,
      autoplay: false,
      autoplayDuration: Duration(seconds: 5),
      dotSize: 4.0,
      onImageTap: (i) {
        final isVideo = video != null && video.isNotEmpty && i == last;
        if (!isVideo) {
          
          Navigator.push(
            context,
              MaterialPageRoute(
              builder: (context) => Builder(
                builder: (BuildContext context) {
                  return  ViewPicturePage(
                    controller: controller,
                    location: widget.location,
                    database: widget.database,
                    userID: widget.userID,
                    images:images,
                    userInfo:userInfo,
                    preferences: widget.preferences,
                    
                  );})));
            
          
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPreview(
                url: video,
                bucket: bucket,
              ),
            ),
          );
        }
      },
      dotSpacing: 15.0,
      dotColor: Theme.of(context).accentColor,
      indicatorBgPadding: 5.0,
      dotBgColor: Colors.white.withOpacity(0.2),
    );
  }

  Future<dynamic> getSpotifyPlaylist() async {
    DataSnapshot snapshot =
        await widget.database.getSpecificUserValues('spotifyPlaylist');
    if (snapshot.value != null) {
      return snapshot.value;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.database.buildingUserCardProfile(widget.userID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var userData = snapshot.data;
            var height = userData.value["height"].toString().split(",");
            _checkHeightIsInRange(
              inch: height != null ? height[1] : 0,
              feet: height != null ? height[0] : 0,
            );
            userHightHelper(userHeight: height != null ? height : [0, 0]);
            return Card(
              elevation: 0.2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: MediaQuery.of(context).size.height / 1.3,
                  child: Stack(children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          userData.value["imageUrls"] != null
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width / 2,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 3,
                                    child: carrouselCacheWidget(
                                      MediaQuery.of(context).size.height / 3,
                                      userData.value["imageUrls"],
                                      userData.value["videoUrl"],
                                      userData.value["imageBucket"],
                                      userData.value
                                    ),
                                  ),
                                )
                              : FutureBuilder(
                                  future: widget.storage.getUserProfilePictures(
                                      widget.database, widget.userID),
                                  builder: (BuildContext context, listURLs) {
                                    if (listURLs.hasData) {
                                      List images = listURLs.data
                                          .map(
                                            (e) => CachedNetworkImageProvider(
                                              e,
                                              cacheKey: "$e",
                                            ),
                                          )
                                          .toList();
                                      //DEVMARK
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              3,
                                          child: images.length == 0
                                              ? Container()
                                              : carrouselWidget(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      3,
                                                  images,
                                                  userData.value["videoUrl"],
                                                  userData.value["imageBucket"],
                                                  userData.value),
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: <Widget>[
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: FutureBuilder(
                                            future: calculateAgeOfOtherUser(
                                                userData.value),
                                            builder:
                                                (BuildContext context, age) {
                                              if (age.hasData) {
                                                return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    userData.value['name'] !=
                                                                null &&
                                                            userData.value[
                                                                    'name'] !=
                                                                "null"
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '${toBeginningOfSentenceCase(userData.value['name'].toString().split(" ")[0].toString())}, ${age.data}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontSize:
                                                                        24),
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              (userData.value['isVerified'] !=
                                                                          null &&
                                                                      userData.value[
                                                                              'isVerified'] ==
                                                                          true)
                                                                  ? Icon(
                                                                      Icons
                                                                          .check_circle,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                      size: 15,
                                                                    )
                                                                  : SizedBox()
                                                            ],
                                                          )
                                                        : Text(
                                                            'Zoichi, ${age.data}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 24),
                                                          ),
                                                    Center(
                                                      child: Text(
                                                        '${userData.value['occupation']}',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return Text("-");
                                              }
                                            }))),
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
                                        && userData.value['starSign'] != "None"
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
                                        userData.value['loveLanguage'] != "null" &&
                                        userData.value['loveLanguage'] != "None"
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
                                        userData.value['kids'] != "null" && userData.value['kids'] != "None"
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
                                        userData.value['feminist'] != "null" &&
                                        userData.value['feminist'] !=  "None"
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
                                                  // userData?.value[
                                                  //         'chosenPrompt'] ??
                                                  //     'NA',
                                                  _favouriteSpellErrorOrNot(
                                                      userData.value[
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
                          userData.value['secondAnotherPromptInput'] != null &&
                                  userData.value["secondAnotherPromptInput"] !=
                                      "null" &&
                                  userData.value["secondAnotherPromptInput"] !=
                                      "Null" &&  userData.value["secondAnotherPromptInput"] != ""
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
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  userData?.value[
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
                              (userData.value['locationName'] != null &&
                                      userData.value['locationName'] != "null")
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                      ),
                                      child: Text(
                                        "${userData.value['locationName']}",
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
                                      child: FutureBuilder(
                                          future: getTownInfo(
                                              userData.value['location']),
                                          builder:
                                              (BuildContext context, townData) {
                                            if (townData.hasData) {
                                              return Text(
                                                '${townData.data}',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black,
                                                  fontFamily: "Papyrus",
                                                  fontSize: 16,
                                                ),
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
                                height: 70,
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
                borderRadius: BorderRadius.circular(30),
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

  Widget playlistCard(dynamic playlist) {
    if (playlist?.value['spotifyPlaylist'] != null) {
      List allPlayList = json.decode(playlist?.value['spotifyPlaylist']);

      return Container(
        height: 170.0,
        child: ListView.builder(
            itemCount: allPlayList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 100.0,
                    width: 120.0,
                    padding: EdgeInsets.all(4.0),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        allPlayList[index]['track']['album']['images'][0]
                            ['url'],
                        width: 120.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        allPlayList[index]['track']['album']['artists'][0]
                            ['name'],
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.normal, color: Colors.black),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        allPlayList[index]['track']['album']['name'],
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
      );
    } else {
      return Container();
    }
  }
}
