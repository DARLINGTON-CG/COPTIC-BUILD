import 'dart:convert';

import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/services/storage/storage.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'caching_manager.dart';

class ProfileImageCaches extends ChangeNotifier {
  bool waitForUpload = false;
  List<String> _userProfileImages = [];
  Map<dynamic, dynamic> _userInfo = {};
  bool _imagesCached = false;
  bool _rebuildProfile = false;
  bool _userSignedOut = false;
  bool _clearAllData = false;

  Map<dynamic, dynamic> _userInfoPro = {};

  Map<String, String> _userIdCache = {"previous": "", "current": ""};

  bool get clearAllData => _clearAllData;

  set clearAllData(bool value) => _clearAllData = value;

  void resetClearAllData() {
    _clearAllData = false;
    notifyListeners();
  }

  void onReorder(int oldIndex, int newIndex, Database database) async {
    var reference = await database.getUserDataOnce();
    var values = await reference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      return values;
    });
    if (oldIndex >= values['imageNumber']) {
    } else {
      List _jsonList = json.decode(values["imageOrder"]);
      var _oldItem = _jsonList.removeAt(oldIndex);
      _jsonList.insert(newIndex, _oldItem);
      database.updateUserDetails({"imageOrder": "${json.encode(_jsonList)}"});
    }
    _userProfileImages.swap(oldIndex, newIndex);
    notifyListeners();
  }

  void clearProfileImages() async {
    _userProfileImages.clear();

    var prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('image_caches', []);
  }

  void checkSpotifyConnection() {}

  void signedOut(bool value) {
    _userSignedOut = value;
  }

  Future<void> updateUserPreferences(String newInfo, Database database) {
    _userInfo["preferences"] = newInfo;
    database.updatePreferences(newInfo);
    notifyListeners();
  }

  Future<void> addUserInfo(Map<String, dynamic> newInfo, Database database) {
    _userInfo.addAll(newInfo);

    Map<String, dynamic> infoToPass =
        _userInfo.map((key, value) => MapEntry(key?.toString(), value));
    database.updateUserDetails(infoToPass);
  }

  Future<void> addUserInfoPro(Map<String, dynamic> newInfo, Database database) {
    _userInfoPro.addAll(newInfo);

    Map<String, dynamic> infoToPass =
        _userInfoPro.map((key, value) => MapEntry(key?.toString(), value));
    database.updateProFeaturesUserFilters(infoToPass);
  }

  void getUserLocation(Database database) async {
    await database.getSpecificUserValues("location").then((value) async {
      if (value.value.toString() == "0,0" || value.value.toString() == "") {
        Position position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        final location = '${position.latitude},${position.longitude}';
        final locationName = await getTownInfo(location) ?? "";

        addUserInfo(
            {"location": location, "locationName": locationName}, database);
        notifyListeners();
      }
    });
    notifyListeners();
  }

  Future<void> profileImages(
      FirestoreStorage storage, Database database) async {
    if (_userSignedOut) {
      clearProfileImages();
      return;
    }

    var prefs = await SharedPreferences.getInstance();

    List<String> imageCaches = prefs.getStringList('image_caches') ?? [];

    if (imageCaches.isEmpty || imageCaches == null) {
      await storage
          .getUserProfilePictures(database, database.userId)
          .then((value) {
        List<dynamic> imagePath = value;
        List<String> localCaches = [];
        for (int index = 0; index < imagePath.length; ++index) {
          final cacheManager = MyCacheManager();
          cacheManager.cacheImage(imagePath.elementAt(index)).then((imageUrl) {
            if (!_userProfileImages.contains(imageUrl))
              _userProfileImages.add(imageUrl);
            localCaches.add(imageUrl);
            prefs.setStringList('image_caches', localCaches);
          });
          _imagesCached = true;
        }
      });
    } else {
      _userProfileImages = imageCaches;

      _imagesCached = true;
    }

    notifyListeners();
  }

  void deleteProfileImage(
      int index, FirestoreStorage storage, Database database, data) async {
    storage.deleteProfileImage(database, data, index);
    _userProfileImages.removeAt(index);
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList('image_caches', _userProfileImages);
    notifyListeners();
  }

  void deleteAllUserImages(
      FirestoreStorage storage, Database database, data) async {
    int total = _userProfileImages.length;
    for (int index = 0; index < total; ++index) {
      storage.deleteProfileImage(database, data, index);
      _userProfileImages.removeAt(index);
      var prefs = await SharedPreferences.getInstance();
      prefs.setStringList('image_caches', _userProfileImages);
    }

    notifyListeners();
  }

  Future<void> userDetails(Database database) async {
    var reference = await database.getUserDataOnce();
    _userInfo = await reference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      return values;
    });
    notifyListeners();
  }

  Future<void> userDetailsPro(Database database) async {
    var reference = await database.getProFeatureUserFilters();
    _userInfoPro = await reference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      return values;
    });
    notifyListeners();
  }

  Future userDetailsFuture(Database database) async {
    var reference = await database.getUserDataOnce();
    _userInfo = await reference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;

      return values;
    });

    return _userInfo;
  }

  Future<void> storeProfileImagesAndCache(FirestoreStorage storage,
      Database database, image, BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    await storage.storeProfileImage(database, image, context).then((_) async {
      List<dynamic> imagePath =
          await storage.getUserProfilePictures(database, database.userId);

      for (int index = 0; index < imagePath.length; ++index) {
        final cacheManager = MyCacheManager();
        cacheManager.cacheImage(imagePath.elementAt(index)).then((imageUrl) {
          if (!_userProfileImages.contains(imageUrl)) {
            _userProfileImages.add(imageUrl);
            prefs.setStringList('image_caches', _userProfileImages);
            notifyListeners();
          }
        });
      }
    });

    notifyListeners();
  }

  List<String> get userProfiles => _userProfileImages;

  Map<dynamic, dynamic> get getUserInfo => _userInfo;
  Map<dynamic, dynamic> get getUserInfoPro => _userInfoPro;

  bool get cachedState => _imagesCached;

  bool get rebuildstate => _rebuildProfile;
}
