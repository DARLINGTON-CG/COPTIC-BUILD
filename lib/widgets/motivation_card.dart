import 'dart:io';
import 'dart:math';
import 'package:copticmeet/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class MotivationalCard extends StatelessWidget {
  String quoteString;
  MotivationalCard({@required this.quoteString});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          // height: height - 270,
          // width: width - 30,
          color: Colors.white,
          width: MediaQuery.of(context).size.width / 1.1,
          height: MediaQuery.of(context).size.height / 1.3,
          child: Center(
            child: Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    quoteString,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        //  color: Theme.of(context).primaryColor,
                        fontFamily: 'Papyrus',
                        fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShoppingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            // height: height - 270,
            // width: width - 30,

            width: MediaQuery.of(context).size.width / 1.1,
            height: MediaQuery.of(context).size.height / 1.3,
            decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                    image: AssetImage("assets/images/meet_collection.png"))),
            child: Center(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          Text(
                            "COPTIC MEET COLLECTION",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                //  color: Theme.of(context).primaryColor,
                                fontFamily: 'Papyrus',
                                color: ColorUtils.defaultColor,
                                fontSize: 12),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20, left: 15, right: 15,bottom: 10),
                            child: MaterialButton(
                              onPressed: () async {
                                if (await canLaunch("https://www.copticmeet.com")) {
                                  await launch("https://www.copticmeet.com/shop");
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Could not launch url",
                                      backgroundColor: Colors.black,
                                      gravity: ToastGravity.CENTER,
                                      toastLength: Toast.LENGTH_SHORT);
                                }
                              },
                              child: Text("Shop Now",
                                  style: TextStyle(
                                      fontFamily: 'Papyrus',
                                      fontSize: 17,
                                      color: Colors.white)),
                              color: ColorUtils.defaultColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
