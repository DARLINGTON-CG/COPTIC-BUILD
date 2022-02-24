import 'dart:convert';

import 'package:copticmeet/providers/profile_info_caches.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';

abstract class Storage {
  Future storeProfileImage(Database database, image, BuildContext context);

  Future storeProfileVideo(Database database, video, BuildContext context);

  Future deleteProfileImage(Database database, data, i);

  Future deleteProfileVideo(Database database, String video);

  Future getUserProfilePictures(Database database, userID);
}

class FirestoreStorage extends Storage {
  // Future getUserProfilePictures(Database database, userID) async {
  //   firebase_storage.ListResult result =
  //       await firebase_storage.FirebaseStorage.instanceFor(
  //               bucket: 'coptic-meet-1539932266201')
  //           .ref()
  //           .child("profileImages").child(userID)
  //           .listAll();

  //   print("USER ID THIS IS THE USER ID $userID");
  //   result.items.forEach((firebase_storage.Reference ref) {
  //     print("Found file: $ref");
  //   });
  //   print("completed this");
  //   result.prefixes.forEach((firebase_storage.Reference ref) {
  //     print("Found directory: $ref");
  //   });

  //   // await database
  //   //     .getSpecificUserValues('imagePath')
  //   //     .then((value) => print(value.value.toString()));
  //   // print("LIST EXAMPLE ENDED");
  //   // print("THIS IS THE USER ID USER ID ID $userID");
  //   List userURLs = [];
  //   try {
  //     var reference = await database.getSpecificCustomUserDataOnce(userID);

  //     var values = await reference.once().then((DataSnapshot snapshot) {
  //       Map<dynamic, dynamic> values = snapshot.value;
  //       return values;
  //     });

  //     // List jsonList = json.decode(values['imageOrder']);
  //     // print(jsonList.toString());
  //     // for (int i = 0; i < jsonList?.length; i++) {
  //     //   var _url = await FirebaseStorage(storageBucket: values['imageBucket'])
  //     //       .ref()
  //     //       .child(values['imagePath'])
  //     //       .child(jsonList[i])
  //     //       .getDownloadURL();
  //     //   userURLs.add(_url);
  //     // }
  //   } catch (e) {
  //     if (e.toString().contains("firebase_storage/object-not-found")) {}

  //     print("EXCEPTION OCCURED $e");
  //   } finally {
  //     return userURLs;
  //   }
  // }
  Future getUserProfilePictures(Database database, userID) async {
    var reference = await database.getSpecificCustomUserDataOnce(userID);

    var values = await reference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      return values;
    });
    List jsonList = json.decode(values['imageOrder']);
    List userURLs = [];
    for (int i = 0; i < jsonList?.length; i++) {
      var _url = await FirebaseStorage(storageBucket: values['imageBucket'])
          .ref()
          .child(values['imagePath'])
          .child(jsonList[i])
          .getDownloadURL();
      userURLs.add(_url);
    }
    return userURLs;
  }

  Future storeProfileImage(
      Database database, image, BuildContext context) async {
    var storageBucket = await database.getSpecificUserValues('imageBucket');
    var filePath = await database.getSpecificUserValues('imagePath');
    var imageNumber = await database.getSpecificUserValues('imageNumber');
    var imageOrder = await database.getSpecificUserValues('imageOrder');
    Reference storageReference =
        FirebaseStorage(storageBucket: storageBucket.value)
            .ref()
            .child('${filePath.value}/${Path.basename(image?.path)}');
    UploadTask uploadTask = storageReference.putFile(image);
    var snackBar = SnackBar(content: Text('Uploading image...'));
    Scaffold.of(context).showSnackBar(snackBar);
    await uploadTask;
    var snackBarSuccess = SnackBar(content: Text('Upload successful!'));
    Scaffold.of(context).showSnackBar(snackBarSuccess);
    List _imageOrderList = json
        .decode(imageOrder.value != null ? imageOrder.value : json.encode([]));
    _imageOrderList.add(Path.basename(image.path));
    var _returnValue = json.encode(_imageOrderList);
    database.updateUserDetails({
      "imageOrder": "$_returnValue",
      "imageNumber": (imageNumber.value != null ? imageNumber.value : 0) + 1,
    });
  }

//  [https://firebasestorage.googleapis.com/v0/b/coptic-meet-1539932266201/o/profileImages%2FLXyZetCPRqT3XXGB3rrsv4qekes1%2Fimage_cropper_1640418282675.jpg?alt=media&token=ddb627e2-accf-4e0f-952f-50d67420178a,
//  https://firebasestorage.googleapis.com/v0/b/coptic-meet-1539932266201/o/profileImages%2FLXyZetCPRqT3XXGB3rrsv4qekes1%2Fimage_cropper_1642844802020.jpg?alt=media&token=d7667dd2-660b-4468-92d0-5ab778397315]
  Future deleteProfileImage(Database database, data, i) async {
    List _jsonList = json.decode(data["imageOrder"]);
    var _path = _jsonList[i];
    _jsonList.removeAt(i);
    database.updateUserDetails({
      "imageOrder": "${json.encode(_jsonList)}",
      "imageNumber": _jsonList.length
    });

    FirebaseStorage(storageBucket: data['imageBucket'])
        .ref()
        .child('${data['imagePath']}/$_path')
        .delete();
  }

  Future storeProfileVideo(
      Database database, video, BuildContext context) async {
    var storageBucket = await database.getSpecificUserValues('imageBucket');
    final videoPath =
        "${DateTime.now().microsecondsSinceEpoch}_${Path.basename(video.path)}";
    Reference storageReference =
        FirebaseStorage(storageBucket: storageBucket.value)
            .ref()
            .child('profileVideos/$videoPath');
    UploadTask uploadTask = storageReference.putFile(video);
    var snackBar = SnackBar(content: Text('Uploading video...'));
    Scaffold.of(context).showSnackBar(snackBar);
    await uploadTask;
    var downloadUrl = await storageReference.getDownloadURL();
    var snackBarSuccess = SnackBar(content: Text('Upload successful!'));
    Scaffold.of(context).showSnackBar(snackBarSuccess);
    database.updateUserDetails({
      "videoPath": "$videoPath",
      "videoUrl": "$downloadUrl",
    });
  }

  Future deleteProfileVideo(Database database, String videoPath) async {
    var storageBucket = await database.getSpecificUserValues('imageBucket');

    database.updateUserDetails({
      "videoPath": "",
      "videoUrl": "",
    });

    FirebaseStorage(storageBucket: storageBucket.value)
        .ref()
        .child('profileVideos/$videoPath')
        .delete();
  }
}
