import 'dart:io';

import 'package:copticmeet/pages/home_page/home_page.dart';
import 'package:copticmeet/pages/setup_profile.dart';
import 'package:copticmeet/providers/profile_info_caches.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/services/storage/storage.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class FirstLoginLandingPage extends StatelessWidget {
  const FirstLoginLandingPage({Key key}) : super(key: key);

  void setupNewUserData(BuildContext context, snapshot) async {
    final database = Provider.of<Database>(context, listen: false);
    var _token = await FirebaseMessaging().getToken();
    if (snapshot.data.value != null) {

    } else {
      var _startDate = DateTime.now().subtract(Duration(days: 365 * 18 + 7));
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      final location = '${position.latitude},${position.longitude}';
      final locationName = await getTownInfo(location) ?? "";
      var _startDateList = _startDate.toString().split(' ');
      database.setupUserDetails({
        "dateOfBirth": "${_startDateList[0]}",
        "editing": "true",
        "online": "false",
        "unmatch": 'null',
        "blocked": "[]",
        "chosenPrompt": "My favorite bible passage is...",
        "promptInput": "null",
        "anotherPrompt": "The joy of God is...",
        "anotherPromptInput": "null",
        "secondAnotherPrompt": "An ideal day off for me would look like...",
        "secondAnotherPromptInput": "null",
        "ageToShow": {"start": "18", "end": "70"},
        'proFeatures': {
          'preferedStarSign': 'Aries',
          'starSignFilterEnabled': 'false',
          'preferedLoveLanguage': 'Words of affirmation',
          'loveLanguageFilterEnabled': 'false',
          'preferedKidStatus': "Don't want",
          'kidFilterEnabled': 'false',
          'preferedEducation': "High School",
          'educationFilterEnabled': 'false',
          'preferredHeight': 'null,null',
          'heightFilterEnabled': 'false',
          'preferedDrinkStatus': 'Never',
          'DrinkFilterEnabled': 'false',
          'preferedFeministStatus': 'Absolutely',
          'FeministFilterEnabled': 'false',
          'preferedSmokeStatus': 'Never',
          'SmokeFilterEnabled': 'false',
        },
        "notifications": "Yes",
        "discoverable": "Yes",
        "read_receipts": "Yes",
        "aboutUser": "null",
        "distanceToSearch": "30",
        "educationLevel": "High School",
        "usersLiked": "[]",
        "usersDisliked": "[]",
        "usersDoubleLiked": "[]",
        "height": "5,6",
        "interestedIn": "Men",
        "kids": "Don't want",
        "smoke": "Never",
        "drink": "Never",
        "feminist": "None",
        "locationName": locationName,
        "location": location,
        "name": "null",
        "occupation": "null",
        "pets": "Dog",
        "starSign": "Aries",
        "loveLanguage": "Words of affirmation",
        "gender": "Male",
        "imageNumber": 0,
        "imageBucket": "gs://coptic-meet-1539932266201",
        "messages": "null",
        "newMatches": "[]",
        "acceptedMatches": "[]",
        "imagePath": "profileImages/${database.userId}",
        "proActive": "false",
        "newLikes": "[]",
        "imageOrder": "[]",
        "deviceTokens": {
          "$_token": {
            "platform": "${Platform.operatingSystem}",
            "timeCreated": "${DateTime.now()}",
          },
        },
        "totalRewind": 0,
        "totalDoubleHeartLimitIndex": 0,
        "likes": 0,
      });
    }
  }

  void setDefaultData(BuildContext context, snapshot) async {
    final database = Provider.of<Database>(context, listen: false);
    var _token = await FirebaseMessaging().getToken();
    var _startDate = DateTime.now().subtract(Duration(days: 365 * 18 + 7));
    var _startDateList = _startDate.toString().split(' ');
    final havePermission = GeolocationPermission.location;
    if (havePermission.value != 0) {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      final location = '${position.latitude},${position.longitude}';
      final locationName = await getTownInfo(location) ?? "";
      database.setupUserDetails({
        "dateOfBirth": "${_startDateList[0]}",
        "editing": "true",
        "online": "false",
        "unmatch": 'null',
        "blocked": "[]",
        "chosenPrompt": "My favorite bible passage is...",
        "promptInput": "null",
        "anotherPrompt": "The joy of God is...",
        "anotherPromptInput": "null",
        "secondAnotherPrompt": "An ideal day off for me would look like...",
        "secondAnotherPromptInput": "null",
        "ageToShow": {"start": "18", "end": "70"},
        'proFeatures': {
          'preferedStarSign': 'Aries',
          'starSignFilterEnabled': 'false',
          'preferedLoveLanguage': 'Words of affirmation',
          'loveLanguageFilterEnabled': 'false',
          'preferedKidStatus': "Don't want",
          'kidFilterEnabled': 'false',
          'preferedEducation': "High School",
          'educationFilterEnabled': 'false',
          'preferredHeight': 'null,null',
          'heightFilterEnabled': 'false',
          'preferedDrinkStatus': 'Never',
          'DrinkFilterEnabled': 'false',
          'preferedFeministStatus': 'Absolutely',
          'FeministFilterEnabled': 'false',
          'preferedSmokeStatus': 'Never',
          'SmokeFilterEnabled': 'false',
        },
        "notifications": "Yes",
        "discoverable": "Yes",
        "read_receipts": "Yes",
        "aboutUser": "",
        "distanceToSearch": "30",
        "educationLevel": "High School",
        "usersLiked": "[]",
        "usersDisliked": "[]",
        "usersDoubleLiked": "[]",
        "height": "5,6",
        "interestedIn": "Men",
        "kids": "Don't want",
        "smoke": "Never",
        "drink": "Never",
        "feminist": "Absolutely",
        "locationName": locationName,
        "location": location,
        "name": "null",
        "occupation": "",
        "pets": "Dog",
        "starSign": "Aries",
        "loveLanguage": "Words of affirmation",
        "gender": "Male",
        "imageNumber": 0,
        "imageBucket": "gs://coptic-meet-1539932266201",
        "messages": "null",
        "newMatches": "[]",
        "acceptedMatches": "[]",
        "imagePath": "profileImages/${database.userId}",
        "proActive": "false",
        "newLikes": "[]",
        "imageOrder": "[]",
        "deviceTokens": {
          "$_token": {
            "platform": "${Platform.operatingSystem}",
            "timeCreated": "${DateTime.now()}",
          },
        },
        "totalRewind": 0,
        "totalDoubleHeartLimitIndex": 0,
        "likes": 0,
      });
    } else {
      database.setupUserDetails({
        "dateOfBirth": "${_startDateList[0]}",
        "editing": "true",
        "online": "false",
        "unmatch": 'null',
        "blocked": "[]",
        "chosenPrompt": "My favorite bible passage is...",
        "promptInput": "null",
        "anotherPrompt": "The joy of God is...",
        "anotherPromptInput": "null",
        "secondAnotherPrompt": "An ideal day off for me would look like...",
        "secondAnotherPromptInput": "null",
        "ageToShow": {"start": "18", "end": "70"},
        'proFeatures': {
          'preferedStarSign': 'Aries',
          'starSignFilterEnabled': 'false',
          'preferedLoveLanguage': 'Words of affirmation',
          'loveLanguageFilterEnabled': 'false',
          'preferedKidStatus': "Don't want",
          'kidFilterEnabled': 'false',
          'preferedEducation': "High School",
          'educationFilterEnabled': 'false',
          'preferredHeight': 'null,null',
          'heightFilterEnabled': 'false',
          'preferedDrinkStatus': 'Never',
          'DrinkFilterEnabled': 'false',
          'preferedFeministStatus': 'Absolutely',
          'FeministFilterEnabled': 'false',
          'preferedSmokeStatus': 'Never',
          'SmokeFilterEnabled': 'false',
        },
        "notifications": "Yes",
        "discoverable": "Yes",
        "read_receipts": "Yes",
        "aboutUser": "null",
        "distanceToSearch": "30",
        "educationLevel": "High School",
        "usersLiked": "[]",
        "usersDisliked": "[]",
        "usersDoubleLiked": "[]",
        "height": "5,6",
        "interestedIn": "Men",
        "kids": "Don't want",
        "smoke": "Never",
        "drink": "Never",
        "feminist": "Absolutely",
        "locationName": "",
        "location": "0,0",
        "name": "null",
        "occupation": "null",
        "pets": "Dog",
        "starSign": "Aries",
        "loveLanguage": "Words of affirmation",
        "gender": "Male",
        "imageNumber": 0,
        "imageBucket": "gs://coptic-meet-1539932266201",
        "messages": "null",
        "newMatches": "[]",
        "acceptedMatches": "[]",
        "imagePath": "profileImages/${database.userId}",
        "proActive": "false",
        "newLikes": "[]",
        "imageOrder": "[]",
        "deviceTokens": {
          "$_token": {
            "platform": "${Platform.operatingSystem}",
            "timeCreated": "${DateTime.now()}",
          },
        },
        "totalRewind": 0,
        "totalDoubleHeartLimitIndex": 0,
        "likes":0
      });
      
    }
  }

  @override
  Widget build(BuildContext context) {

    final database = Provider.of<Database>(context, listen: false);
    final storage = Provider.of<Storage>(context, listen: false);
    return FutureBuilder(
        future: database.getUserAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data.value != null) {
              if (snapshot.data.value['editing'] == "false") {
                final deleteCaches =
                    Provider.of<ProfileImageCaches>(context, listen: false);

                deleteCaches.signedOut(false);
                return MainPage(
                  database: database,
                  storage: storage,
                );
              }
              setDefaultData(context, snapshot);
              return SetupProfilePage();
            } else {
              setupNewUserData(context, snapshot);
               final deleteCaches =
                    Provider.of<ProfileImageCaches>(context, listen: false);
                deleteCaches.signedOut(false);
              return SetupProfilePage();
            }
          } else {
            return Scaffold(
             
              body: Container(
                width: MediaQuery.of(context).size.width,
                height:MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                   gradient:  LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ],
                begin: const FractionalOffset(1.0, 0.0),
                end: const FractionalOffset(0.0, 0.7),
                stops: [0.3, 1.0],
                tileMode: TileMode.clamp)
                ),
                child: Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor,
                  color: Colors.white,
                )),
              ),
            );
          }
        });
  }
}
