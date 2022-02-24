import 'dart:async';
import 'dart:convert';

import 'package:copticmeet/services/location/location.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

abstract class Database {
  Future<void> setupUserDetails(Map<String, dynamic> userDetails);

  Stream get getUserData;

  Future getUserAllData();

  Future getOtherUserData(userID);

  String get userId;

  Future getUserDataOnce();

  Future getProFeatureUserFilters();

  Future getSpecificUserValues(String value);

  Future<dynamic> getMatchedUserLikedImages(matchID);

  Future<void> updateUserDetails(Map<String, dynamic> userDetails);

  Future getSpecificCustomUserDataOnce(userID);

  Stream get allUsersID;

  Future buildStackWithCorrectValues(Location location, bool disableFilter);

  Future buildingUserCardProfile(userID);

  Future getNewMatchesNumber();

  Future<void> addUserNotificationToken(Map<String, dynamic> userDetails);

  getAllUsersData();

  Future buildingProfileSettings(userID);

  Future getActiveMatchesNumber();

  Future checkProMode();

  Future<String> checkPreferences();

  Future<void> updatePreferences(String preferences);

  Future updateNewLikes(userIDToRemove);

  Future updateNewMatches(userIDToRemove);

  Future getNewLikesNumber();

  Future getLikesNumber();

  Future getDislikesNumber();

  Future getDoubleLikeNumber();

  Future<String> getSpecificProFeatureUserFilters(String value);

  Future<void> updateProFeaturesUserFilters(Map<String, dynamic> userDetails);

  void removeDislikedUsers(userID);

  void updatePhotosLike(userID, details, bool removeLike);

  void removeLikedUsers(userID);

  void removeDoubleLikedUsers(userID);

  Future getTotalRewindCount();

  void updateRewindCount(int totalRewindCount);

  Future getTotalDoubleHeartLimitIndex();

  void updateDoubleHeartLimitIndex(int totalDoubleHeartLimitIndex);
}

class FirestoreDatabase implements Database {
  final String uid;

  FirestoreDatabase({@required this.uid}) : assert(uid != null);

  Stream get getUserData {
    final userID = uid;
    final databaseURL =
        "https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/";
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database.reference().child('users').child(userID);
    return userReference.onValue;
  }

  Future getUserAllData() {
    final userID = uid;
    final databaseURL =
        "https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/";
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference =
        database.reference().child('users').child(userID).once();

    return userReference;
  }

  Future getOtherUserData(userID) {
    final databaseURL =
        "https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/";
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference =
        database.reference().child('users').child(userID).once();

    return userReference;
  }

  Stream get allUsersID {
    final databaseURL =
        "https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/";
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database.reference().child('users');
    return userReference.onValue;
  }

  Future checkProMode() async {
    final userID = uid;
    final databaseURL =
        "https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/";
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference =
        database.reference().child('users').child(userID).child('proActive');
    final data = await userReference.once();
    if (data.value == 'true') {
      return true;
    } else {
      return false;
    }
  }

  Future<String> checkPreferences() async {
    final userID = uid;
    final databaseURL =
        "https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/";
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference =
        database.reference().child('users').child(userID).child('preferences');
    final data = await userReference.once();
    return data.value ?? "dating";
  }

  Future<void> updatePreferences(String preferences) async {
    final userID = uid;
    final databaseURL =
        "https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/";
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database.reference().child('users').child(userID);
    await userReference.update({"preferences": preferences});
  }

  Future getUserDataOnce() async {
    final userID = uid;
    final databaseURL =
        "https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/";
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database.reference().child('users').child(userID);
    return userReference;
  }

  Future getProFeatureUserFilters() async {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final data = await database
        .reference()
        .child('users')
        .child(userID)
        .child('proFeatures');
    return data;
  }

  Future buildStackWithCorrectValues(
      Location location, bool disableFilter) async {
    final _currentUserID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    final _currentUserReference =
        await FirebaseDatabase(databaseURL: databaseURL)
            .reference()
            .child('users')
            .child(_currentUserID)
            .once();

    final _allUserReference = await FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child('users')
        .once();
    final _currentUserData = _currentUserReference.value;
    if (_currentUserData['likes'] == null) {
      (_currentUserData).addAll({"likes": 0});
      updateUserDetails(Map<String, dynamic>.from(_currentUserData));
    }

    List _usersLiked = json.decode(_currentUserData['usersLiked']);
    List _usersDisliked = json.decode(_currentUserData['usersDisliked']);
    List _usersDoubleLiked = json.decode(_currentUserData['usersDoubleLiked']);
    bool _proMode = _currentUserData['proActive'] == 'true' ? true : false;
    final _allUserData = _allUserReference.value;

    List _excludeCurrentUserKeys = _allUserData.keys
        .where((checkUser) => checkUser != _currentUserID)
        .toList();
    List _completedFilteredKeys = [];

    if (disableFilter) {
      bool shouldAdd = false;
      for (var i = 0; i < 30; i++) {
        if (_usersLiked.contains(_excludeCurrentUserKeys[i]) != true &&
            _usersDisliked.contains(_excludeCurrentUserKeys[i]) != true &&
            _usersDoubleLiked.contains(_excludeCurrentUserKeys[i]) != true) {
          shouldAdd = true;
        } else {
          shouldAdd = false;
        }

        if (shouldAdd) {
          _completedFilteredKeys.add(_excludeCurrentUserKeys[i]);
        }
      }

      return _completedFilteredKeys;
    }

    try {
      for (var i = 0; i < _excludeCurrentUserKeys.length; i++) {
        bool shouldAdd = await checkFiltersAndCriteria(
            allUserData: _allUserData,
            usersLiked: _usersLiked,
            usersDisliked: _usersDisliked,
            usersDoubleLiked: _usersDoubleLiked,
            userToCheck: _excludeCurrentUserKeys[i],
            location: location,
            currentUserData: _currentUserData);
        if (_proMode) {
          bool proShouldAdd = await checkProFiltersAndCriteria(
              allUserData: _allUserData,
              userToCheck: _excludeCurrentUserKeys[i],
              currentUserData: _currentUserData);
          if (shouldAdd && proShouldAdd) {
            _completedFilteredKeys.add(_excludeCurrentUserKeys[i]);
          } else {
            print('No match');
          }
        } else {
          if (shouldAdd) {
            _completedFilteredKeys.add(_excludeCurrentUserKeys[i]);
          }
        }
      }
    } catch (err) {
      print(err);
    }
    // if (_completedFilteredKeys.isEmpty) {
    //   _completedFilteredKeys = _allUserData.keys.where((checkUser) {
    //     return (_allUserData[checkUser]['editing'] == "false") &&
    //         (_allUserData[checkUser]['discoverable'] == "Yes") &&
    //         _usersLiked.contains(checkUser) != true &&
    //         _usersDisliked.contains(checkUser) != true &&
    //         _usersDoubleLiked.contains(checkUser) != true;
    //   }).toList();
    //   String preference = _currentUserData.containsKey('preferences')
    //       ? _currentUserData['preferences']
    //       : 'dating';

    //   if (preference == "dating") {
    //     List preferenceKeys = [];
    //     for (int index = 0; index < _completedFilteredKeys.length; ++index) {
    //       String genderConverter =
    //           _allUserData[_completedFilteredKeys[index]]["gender"] == "Male"
    //               ? "Men"
    //               : "Women";
    //       if (_currentUserData["interestedIn"] != "Both") {
    //         if (genderConverter == _currentUserData["interestedIn"]) {
    //           preferenceKeys.add(_completedFilteredKeys[index]);
    //         }
    //       } else {
    //         preferenceKeys.add(_completedFilteredKeys[index]);
    //       }
    //     }
    //     _completedFilteredKeys = preferenceKeys;

    //     // var _shakeUpKeys = [];
    //     // for (int index = 0; index < _completedFilteredKeys.length; ++index) {
    //     //   var age = await calculateAgeOfOtherUser(
    //     //       _allUserData[_completedFilteredKeys[index]]);

    //     //   if (age <= double.parse(_currentUserData['ageToShow']['end']) &&
    //     //       age >= double.parse(_currentUserData['ageToShow']['start'])) {
    //     //     _shakeUpKeys.add(_completedFilteredKeys[index]);
    //     //   }
    //     // }
    //     _completedFilteredKeys; //= _shakeUpKeys;

    //   }
    // }
    // print(_completedFilteredKeys);

    // if (userId == "fpIqLC8jGkWd47h2LoHrKIExwIb2") _completedFilteredKeys.add("b5JxrcrMKmQT4fipNFtvaGnPTWm1");
    // if (userId == "b5JxrcrMKmQT4fipNFtvaGnPTWm1") _completedFilteredKeys.add("fpIqLC8jGkWd47h2LoHrKIExwIb2");

    return _completedFilteredKeys;
  }

  Future<bool> checkProFiltersAndCriteria(
      {Map<dynamic, dynamic> allUserData,
      String userToCheck,
      Map<dynamic, dynamic> currentUserData}) async {
    List shouldAdd = [];
    if (currentUserData['proFeatures']['DrinkFilterEnabled'] == 'true') {
      if (currentUserData['proFeatures']['preferedDrinkStatus'] ==
          allUserData[userToCheck]['drink']) {
        shouldAdd.add(true);
      }
    }
    if (currentUserData['proFeatures']['SmokeFilterEnabled'] == 'true') {
      if (currentUserData['proFeatures']['preferedSmokeStatus'] ==
          allUserData[userToCheck]['smoke']) {
        shouldAdd.add(true);
      }
    }
    if (currentUserData['proFeatures']['FeministFilterEnabled'] == 'true') {
      if (currentUserData['proFeatures']['preferedFeministStatus'] ==
          allUserData[userToCheck]['feminist']) {
        shouldAdd.add(true);
      }
    }

    if (currentUserData['proFeatures']['educationFilterEnabled'] == 'true') {
      if (currentUserData['proFeatures']['preferedEducation'] ==
          allUserData[userToCheck]['educationLevel']) {
        shouldAdd.add(true);
      }
    }
    if (currentUserData["preferences"] != "friend") {
      if (currentUserData['proFeatures']['kidFilterEnabled'] == 'true') {
        if (currentUserData['proFeatures']['preferedKidStatus'] ==
            allUserData[userToCheck]['kids']) {
          shouldAdd.add(true);
        }
      }
    }
    if (currentUserData['proFeatures']['starSignFilterEnabled'] == 'true') {
      if (currentUserData['proFeatures']['preferedStarSign'] ==
          allUserData[userToCheck]['starSign']) {
        shouldAdd.add(true);
      }
    }
    if (currentUserData["preferences"] != "friend") {
      if (currentUserData['proFeatures']['loveLanguageFilterEnabled'] ==
          'true') {
        if (currentUserData['proFeatures']['preferedLoveLanguage'] ==
            allUserData[userToCheck]['loveLanguage']) {
          shouldAdd.add(true);
        }
      }
    }
    if (currentUserData['proFeatures']['heightFilterEnabled'] == 'true') {
      if (currentUserData['proFeatures']['preferredHeight'] ==
          allUserData[userToCheck]['height']) {
        shouldAdd.add(true);
      }
    }
    if (shouldAdd.contains(true)) {
      return true;
    } else if (currentUserData['proFeatures']['educationFilterEnabled'] ==
            'false' &&
        currentUserData['proFeatures']['loveLanguageFilterEnabled'] ==
            'false' &&
        currentUserData['proFeatures']['starSignFilterEnabled'] == 'false' &&
        currentUserData['proFeatures']['kidFilterEnabled'] == 'false' &&
        currentUserData['proFeatures']['DrinkFilterEnabled'] == 'false' &&
        currentUserData['proFeatures']['FeministFilterEnabled'] == 'false' &&
        currentUserData['proFeatures']['SmokeFilterEnabled'] == 'false') {
      return true;
    } else {
      return false;
    }
  }

  // Future<bool> fetchUsersOnLikedCriteria(
  //     {Map<dynamic, dynamic> allUserData,
  //     List usersLiked,
  //     List usersDisliked,
  //     List usersDoubleLiked,
  //     String userToCheck,
  //     Location location,

  //     Map<dynamic, dynamic> currentUserData}) async {
  //   String userPreferences = currentUserData.containsKey('preferences')
  //       ? currentUserData['preferences']
  //       : 'dating';
  //   if (allUserData[userToCheck]['editing'] == 'false') {
  //     if (allUserData[userToCheck]['discoverable'] == "Yes") {
  //       if (usersLiked.contains(userToCheck) != true &&
  //           usersDisliked.contains(userToCheck) != true &&
  //           usersDoubleLiked.contains(userToCheck) != true) {

  //         return

  //       }
  //       else
  //         return false;
  //     }
  //     else return false;
  //   }
  //   else return false;
  // }

  Future<bool> checkFiltersAndCriteria(
      {Map<dynamic, dynamic> allUserData,
      List usersLiked,
      List usersDisliked,
      List usersDoubleLiked,
      String userToCheck,
      Location location,
      Map<dynamic, dynamic> currentUserData}) async {
    String userPreferences = currentUserData.containsKey('preferences')
        ? currentUserData['preferences']
        : 'dating';
    if (allUserData[userToCheck]['editing'] == 'false') {
      if (allUserData[userToCheck]['discoverable'] == "Yes") {
        if (usersLiked.contains(userToCheck) != true &&
            usersDisliked.contains(userToCheck) != true &&
            usersDoubleLiked.contains(userToCheck) != true) {
          var _distance = await location.calculateDistance(
                  allUserData[userToCheck]['location'],
                  currentUserData['location']) /
              1609;
          if (_distance.round() <=
              double.parse(currentUserData['distanceToSearch'])) {
            if (userPreferences == "friend"
                ? allUserData[userToCheck]['gender'] ==
                    currentUserData['gender']
                : currentUserData['interestedIn'] == 'Both' ||
                    (allUserData[userToCheck]['gender'] ==
                        (currentUserData['interestedIn'] == 'Men'
                            ? 'Male'
                            : 'Female'))) {
              if (userPreferences == "friend") {
                var age =
                    await calculateAgeOfOtherUser(allUserData[userToCheck]);
                if (currentUserData['ageToShow']['end'] == '70+') {
                  if (age >=
                      double.parse(currentUserData['ageToShow']['start'])) {
                    String preferences =
                        allUserData[userToCheck].containsKey('preferences')
                            ? allUserData[userToCheck]['preferences']
                            : 'dating';
                    return userPreferences == preferences;
                  } else {
                    return false;
                  }
                } else {
                  if (age <=
                          double.parse(currentUserData['ageToShow']['end']) &&
                      age >=
                          double.parse(currentUserData['ageToShow']['start'])) {
                    String preferences =
                        allUserData[userToCheck].containsKey('preferences')
                            ? allUserData[userToCheck]['preferences']
                            : 'dating';
                    return userPreferences == preferences;
                  } else {
                    return false;
                  }
                }
              } else {
                if (currentUserData['interestedIn'] == "Both"
                    ? (allUserData[userToCheck]['interestedIn'] == 'Both')
                    : ((allUserData[userToCheck]['interestedIn'] == 'Men'
                            ? 'Male'
                            : allUserData[userToCheck]['interestedIn'] == "Both"
                                ? "Both"
                                : 'Female') ==
                        currentUserData['gender'])) {
                  var age =
                      await calculateAgeOfOtherUser(allUserData[userToCheck]);
                  if (currentUserData['ageToShow']['end'] == '70+') {
                    if (age >=
                        double.parse(currentUserData['ageToShow']['start'])) {
                      String preferences =
                          allUserData[userToCheck].containsKey('preferences')
                              ? allUserData[userToCheck]['preferences']
                              : 'dating';
                      return userPreferences == preferences;
                    } else {
                      return false;
                    }
                  } else {
                    if (age <=
                            double.parse(currentUserData['ageToShow']['end']) &&
                        age >=
                            double.parse(
                                currentUserData['ageToShow']['start'])) {
                      String preferences =
                          allUserData[userToCheck].containsKey('preferences')
                              ? allUserData[userToCheck]['preferences']
                              : 'dating';
                      return userPreferences == preferences;
                    } else {
                      return false;
                    }
                  }
                } else {
                  return false;
                }
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future getSpecificCustomUserDataOnce(userID) async {
    final databaseURL =
        "https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/";
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database.reference().child('users').child('$userID');
    return userReference;
  }

  Future buildingProfileSettings(userID) async {
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference =
        database.reference().child('users').child('$userID').once();
    return userReference;
  }

  Future getNewMatchesNumber() {
    final userID = uid;

    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database
        .reference()
        .child('users')
        .child(userID)
        .child('newMatches')
        .once();
    return userReference;
  }

  Future getNewLikesNumber() {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database
        .reference()
        .child('users')
        .child(userID)
        .child('newLikes')
        .once();
    return userReference;
  }

  Future getLikesNumber() {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database
        .reference()
        .child('users')
        .child(userID)
        .child('usersLiked')
        .once();
    return userReference;
  }

  Future getDislikesNumber() {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database
        .reference()
        .child('users')
        .child(userID)
        .child('usersDisliked')
        .once();
    return userReference;
  }

  Future getDoubleLikeNumber() {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database
        .reference()
        .child('users')
        .child(userID)
        .child('usersDoubleLiked')
        .once();
    return userReference;
  }

  Future getActiveMatchesNumber() {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database
        .reference()
        .child('users')
        .child(userID)
        .child('acceptedMatches')
        .once();
    return userReference;
  }

  Future getAllUsersData() {
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database.reference().child('users').once();
    return userReference;
  }

  Future buildingUserCardProfile(userID) async {
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference =
        database.reference().child('users').child('$userID').once();
    return userReference;
  }

  String get userId => uid;

  Future getSpecificUserValues(String value) async {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final data = await database
        .reference()
        .child('users')
        .child(userID)
        .child(value)
        .once();
    return data != null ? data : "Yes";
  }

  Future<String> getSpecificProFeatureUserFilters(String value) async {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final data = await database
        .reference()
        .child('users')
        .child(userID)
        .child('proFeatures')
        .child(value)
        .once();
    return data.value;
  }

  Future<void> setupUserDetails(Map<String, dynamic> userDetails) async {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database.reference().child('users');
    await userReference.child(userID).set(userDetails);
  }

  Future<void> updateUserDetails(Map<String, dynamic> userDetails) async {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database.reference().child('users');
    await userReference.child(userID).update(userDetails);
  }

  Future<void> updateProFeaturesUserFilters(
      Map<String, dynamic> userDetails) async {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database.reference().child('users');
    await userReference.child(userID).child('proFeatures').update(userDetails);
  }

  Future updateNewLikes(userIDToRemove) async {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference =
        database.reference().child('users').child(userID).child('newLikes');
    final userData = await userReference.once();
    final userDataJson = jsonDecode(userData.value);
    userDataJson.remove(userIDToRemove);
    final newUserReference = database.reference().child('users').child(userID);
    await newUserReference.update({"newLikes": "${jsonEncode(userDataJson)}"});
  }

  Future updateNewMatches(userIDToRemove) async {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference =
        database.reference().child('users').child(userID).child('newMatches');
    final userData = await userReference.once();
    final userDataJson = jsonDecode(userData.value);
    userDataJson.remove(userIDToRemove);
    final newUserReference = FirebaseDatabase(databaseURL: databaseURL)
        .reference()
        .child('users')
        .child(userID);
    await newUserReference
        .update({"newMatches": "${jsonEncode(userDataJson)}"});
  }

  Future<void> addUserNotificationToken(
      Map<String, dynamic> userDetails) async {
    final userID = uid;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference =
        database.reference().child('users').child(userID).child('deviceTokens');
    await userReference.set(userDetails);
  }

  void removeDislikedUsers(userID) async {
    var currentDislikedUsers = await getSpecificUserValues('usersDisliked');
    List currentDislikedUsersList =
        await json.decode(currentDislikedUsers.value);
    if (currentDislikedUsersList.contains(userID)) {
      currentDislikedUsersList.remove(userID);
    }
    updateUserDetails(
        {"usersDisliked": "${json.encode(currentDislikedUsersList)}"});
  }

  void updatePhotosLike(userID, details, bool removeLike) async {
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database
        .reference()
        .child('users')
        .child(userID)
        .child('likedMyPhotos');
    final userData = await userReference.once();
    String tempString =
        "{\"userID\":\"${details["userID"]}\",\"likedPhotoLink\":\"${details["likedPhotoLink"]}\"}";

    if (userData.value.toString().contains(tempString) && removeLike == true) {
      final userDataJson = jsonDecode(userData.value);

      (userDataJson as List<dynamic>).removeWhere(
          (element) => element.toString().contains(details.toString()));

      final newUserReference = FirebaseDatabase(databaseURL: databaseURL)
          .reference()
          .child('users')
          .child(userID);
      await newUserReference
          .update({"likedMyPhotos": "${jsonEncode(userDataJson)}"});

      return;
    }

    if (userData.value == null) {
      List initialLikes = [];
      initialLikes.add(details);

      final newUserReference = FirebaseDatabase(databaseURL: databaseURL)
          .reference()
          .child('users')
          .child(userID);
      await newUserReference
          .update({"likedMyPhotos": "${jsonEncode(initialLikes)}"});
    } else {
      final userDataJson = jsonDecode(userData.value);
      userDataJson.add(details);
      final newUserReference = FirebaseDatabase(databaseURL: databaseURL)
          .reference()
          .child('users')
          .child(userID);
      await newUserReference
          .update({"likedMyPhotos": "${jsonEncode(userDataJson)}"});
    }
  }

  Future<List> getMatchedUserLikedImages(matchID) async {
    final userID = uid;
    final matchLikedImages = [];
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database
        .reference()
        .child('users')
        .child(userID)
        .child('likedMyPhotos');
    final userData = await userReference.once();

    if (userData.value != null) {
      final List userDataJson = jsonDecode(userData.value);

      for (var item in userDataJson) {
        if (item['userID'] == matchID) {
          matchLikedImages.add(item['likedPhotoLink']);
          continue;
        }
      }
    }

    return matchLikedImages;
  }

  void removeLikedUsers(userID) async {
    var currentLikedUsers = await getSpecificUserValues('usersLiked');
    List currentLikedUsersList = await json.decode(currentLikedUsers.value);
    if (currentLikedUsersList.contains(userID)) {
      currentLikedUsersList.remove(userID);
    }
    updateUserDetails({"usersLiked": "${json.encode(currentLikedUsersList)}"});
  }

  void removeDoubleLikedUsers(userID) async {
    var currentDoubleLikedUsers =
        await getSpecificUserValues('usersDoubleLiked');
    List currentDoubleLikedUsersList =
        await json.decode(currentDoubleLikedUsers.value);
    if (currentDoubleLikedUsersList.contains(userID)) {
      currentDoubleLikedUsersList.remove(userID);
    }
    updateUserDetails(
        {"usersDoubleLiked": "${json.encode(currentDoubleLikedUsersList)}"});
  }

  Future getTotalRewindCount() async {
    final totalRewindCount = await getSpecificUserValues('totalRewind');
    if (totalRewindCount != null) {
      int count = int.parse(totalRewindCount.value == null
          ? "0"
          : totalRewindCount.value.toString());
      return count;
    } else {
      final userID = uid;
      Map<String, dynamic> userDetails = {"totalRewind": 0};
      final databaseURL =
          'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
      FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
      database.setPersistenceEnabled(true);
      final userReference = database.reference().child('users');
      await userReference.child(userID).set(userDetails);
      return 0;
    }
  }

  void updateRewindCount(int totalRewindCount) async {
    final userID = uid;
    Map<String, dynamic> userDetails = {"totalRewind": "$totalRewindCount"};
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database.reference().child('users');
    await userReference.child(userID).update(userDetails);
  }

  Future getTotalDoubleHeartLimitIndex() async {
    final remainingHeartCount =
        await getSpecificUserValues("totalDoubleHeartLimitIndex");
    if (remainingHeartCount != null) {
      int count = int.parse(remainingHeartCount.value == null
          ? "0"
          : remainingHeartCount.value.toString());
      return count;
    } else {
      final userID = uid;
      Map<String, dynamic> userDetails = {"totalDoubleHeartLimitIndex": 0};
      final databaseURL =
          'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
      FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
      database.setPersistenceEnabled(true);
      final userReference = database.reference().child('users');
      await userReference.child(userID).set(userDetails);
      return 0;
    }
  }

  void updateDoubleHeartLimitIndex(int totalDoubleHeartLimitIndex) async {
    final userID = uid;
    Map<String, dynamic> userDetails = {
      "totalDoubleHeartLimitIndex": "$totalDoubleHeartLimitIndex"
    };
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase database = FirebaseDatabase(databaseURL: databaseURL);
    database.setPersistenceEnabled(true);
    final userReference = database.reference().child('users');
    await userReference.child(userID).update(userDetails);
  }
}
