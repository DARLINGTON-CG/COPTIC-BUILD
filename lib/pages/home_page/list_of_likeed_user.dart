import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/services/location/location.dart';
import 'package:copticmeet/services/storage/storage.dart';
import 'package:copticmeet/utils/color_utils.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/platform_aler_dialog.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/widgets.dart';
import 'package:copticmeet/widgets/pro_mode/pop_up.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LikedUserList extends StatefulWidget {
  final bool pastPurchases;
  String preferences;
  Database database;
  Storage storage;
  Location location;

  LikedUserList(
      {@required this.pastPurchases,
      @required this.database,
      @required this.preferences,
      @required this.storage,
      @required this.location});
  @override
  _LikedUserListState createState() => _LikedUserListState();
}

class _LikedUserListState extends State<LikedUserList> {
  // var database;

  Future _getUserLocations() async {
    // var database = Provider.of<Database>(context, listen: false);
    var location = await widget.database.getSpecificUserValues('location');
    return location;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title:   Column(
                      children: [
                        Text(
                          'Coptic Meet',
                          style: Theme.of(context)
                              .textTheme
                              .body2
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                         "New Likes",
                          style: Theme.of(context)
                              .textTheme
                              .body2
                              .copyWith(fontSize: 14),
                        )
                      ],
                    ),
                    
                   
         
        ),
        backgroundColor: ColorUtils.defaultColor,
        body: FutureBuilder(
            future: widget.database.getNewLikesNumber(),
            builder: (BuildContext context, likeUserID) {
              if (likeUserID.hasData) {
          
                var jsonList = jsonDecode(likeUserID.data.value);
                jsonList = jsonList.toSet().toList();
                if (jsonList.length != 0) {
                  return ListView.builder(
                    itemCount: jsonList.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                          future: widget.database
                              .buildingProfileSettings(jsonList[index]),
                          builder: (BuildContext context, userData) {
                            if (userData.hasData) {
                              return GestureDetector(
                                onTap: () async {
                                  if (widget.pastPurchases == false) {
                                    final didRequestPassportMode =
                                        await PlatformAlertDialog(
                                      title: 'View New Likes',
                                      content:
                                          'This is a pro feature, would you like to get access?',
                                      defaultActionText: 'Yes',
                                      cancelActionText: 'Cancel',
                                    ).show(context);

                                    if (didRequestPassportMode == true) {
                                      //await PlatformAlertDialog(title: 'Pro Mode', content: 'These features are coming soon', defaultActionText: 'Ok').show(context);
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (_) => PurchaseProPopup.create(
                                            context,
                                            database: widget.database),
                                      );
                                    }
                                  } else {
                                    await showDialog(
                                        context: context,
                                        builder: (_) => new AlertDialog(
                                              contentPadding: EdgeInsets.all(0),
                                              backgroundColor:
                                                  Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              30.0))),
                                              content: Builder(
                                                builder: (context) {
                                                  var height =
                                                      MediaQuery.of(context)
                                                          .size
                                                          .height;
                                                  var width =
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width;
                                                  return SafeArea(
                                                    child: Container(
                                                      child: Container(
                                                        height: height - 250,
                                                        width: width - 40,
                                                        child: FutureBuilder(
                                                            future:
                                                                _getUserLocations(),
                                                            builder: (BuildContext
                                                                    context,
                                                                userLocations) {
                                                              if (userLocations
                                                                  .hasData) {
                                                                return Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        1.1,
                                                                    child: PopupProfileCard(
                                                                        preferences:
                                                                            widget
                                                                                .preferences,
                                                                        location:
                                                                            widget
                                                                                .location,
                                                                        database:
                                                                            widget
                                                                                .database,
                                                                        storage:
                                                                            widget
                                                                                .storage,
                                                                        userID: jsonList[
                                                                            index],
                                                                        accountLocation: userLocations
                                                                            .data
                                                                            .value));
                                                              } else {
                                                                return Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                  backgroundColor:
                                                                      Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                          color: Colors.white,
                                                                ));
                                                              }
                                                            }),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ));
                                    // await widget.database.updateNewLikes(jsonList[index]);
                                    // setState(() {});
                                  }
                                },
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      color: Colors.white,
                                      child: FutureBuilder(
                                          future: widget.storage
                                              .getUserProfilePictures(
                                                  widget.database,
                                                  jsonList[index]),
                                          builder:
                                              (BuildContext context, imageURL) {
                                            if (imageURL.hasData &&
                                                !imageURL.data.isEmpty) {
                                             
                                              return ListTile(
                                                leading: Hero(
                                                  tag: '${imageURL.data[0]}',
                                                  child: CircleAvatar(
                                                    radius: 25,
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(
                                                            "${imageURL.data[0]}"),
                                                  ),
                                                ),
                                                title: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 14),
                                                  child: Hero(
                                                    tag:
                                                        "${userData.data.value['name']}",
                                                    child: Text(
                                                      '${userData.data.value['name']}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .body2,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return ListTile(
                                                leading: CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  child: Center(
                                                      child: CircularProgressIndicator(
                                                          backgroundColor: Theme
                                                                  .of(context)
                                                              .primaryColor,
                                                              color: Colors.white,)),
                                                ),
                                                title: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 14),
                                                  child: Hero(
                                                    tag:
                                                        "${userData.data.value['name']}",
                                                    child: Text(
                                                      '${userData.data.value['name']}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .body2,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          }),
                                    ),
                                    SizedBox(height: 10)
                                  ],
                                ),
                              );
                            } else {
                              return Container();
                            }
                          });
                    },
                  );
                } else {
                  return Container(
                   
                    child: Center(
                      child: Text(
                        'NO  NEW  LIKES',
                        style: TextStyle(
                            color: Colors.white, fontFamily: "Papyrus",fontSize: 16),
                      ),
                    ),
                  );
                }
              } else {
                return Container(
                  
                  child: Center(
                    child: Text(
                      'No New likes',
                      style:
                          TextStyle(color: Colors.white, fontFamily: "Papyrus"),
                    ),
                  ),
                );
              }
            }),
      
    );
  }
}
