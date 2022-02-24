import 'dart:io';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:copticmeet/pages/landing_page.dart';
import 'package:copticmeet/providers/profile_info_caches.dart';
import 'package:copticmeet/utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:copticmeet/services/sign_in/auth.dart';

class DeleteAccountPage extends StatefulWidget {
  DeleteAccountPage(
      {Key key,
      @required this.database,
      @required this.storage,
      @required this.data})
      : super(key: key);

  final Database database;
  final storage;
  final data;

  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  bool loadDeletion = false;

  Future<void> createDeleteState() async {
    final userID = widget.database.userId;
    final databaseURL =
        'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';
    FirebaseDatabase databaseFire = FirebaseDatabase(databaseURL: databaseURL);
    databaseFire.setPersistenceEnabled(true);
    final userReference = databaseFire.reference().child('users');
    await userReference.child(userID).remove();

    if (Platform.isAndroid) {
      try {
        final googleUser = await GoogleSignIn.standard().signIn();
        final googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.currentUser
            ?.reauthenticateWithCredential(credential);

        await FirebaseAuth.instance.currentUser?.delete();
        await GoogleSignIn.standard().signOut();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          print("ERROR $e");
        } else {
          print("Error $e");
          //Show a scaffold here
        }
      }
    } else if (Platform.isIOS) {
      // 1. perform the sign-in request
      final result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);
      // 2. check the result
      switch (result.status) {
        case AuthorizationStatus.authorized:
          {
            final appleIdCredential = result.credential;
            final oAuthProvider = OAuthProvider('apple.com');
            final credential = oAuthProvider.credential(
              idToken: String.fromCharCodes(appleIdCredential.identityToken),
              accessToken:
                  String.fromCharCodes(appleIdCredential.authorizationCode),
            );
            await FirebaseAuth.instance.currentUser
                ?.reauthenticateWithCredential(credential)
                ?.then((value) async {
              await FirebaseAuth.instance.currentUser?.delete();
            });
          }
          break;
        case AuthorizationStatus.error:
          throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: result.error.toString(),
          );
          break;
        case AuthorizationStatus.cancelled:
          throw PlatformException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Sign in aborted by user',
          );
          break;
        default:
          throw UnimplementedError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorUtils.defaultColor,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ],
                  begin: const FractionalOffset(1.0, 0.0),
                  end: const FractionalOffset(0.0, 0.7),
                  stops: [0.3, 1.0],
                  tileMode: TileMode.clamp)),
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Wrap(children: [
                  Text(
                    'All your data associated with this account will be removed from our servers. There is no possible way to retrieve this information.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ]),
              ),
              Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: !loadDeletion
                      ? MaterialButton(
                          onPressed: () {
                            setState(() {
                              loadDeletion = true;
                            });
                            createDeleteState().then((value) {
                              final deleteCaches =
                                  Provider.of<ProfileImageCaches>(context,
                                      listen: false);
                              deleteCaches.deleteAllUserImages(
                                  widget.storage, widget.database, widget.data);
                              deleteCaches.clearProfileImages();
                              deleteCaches.signedOut(true);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LandingPage()),
                              );
                            }).onError((error, stackTrace) async {
                              // await _firebaseAuth.signOut();
                              // final snack = SnackBar(
                              //   content: Text(
                              //     "An error occured please try again.\n${error.toString()}",
                              //   ),
                              // );
                              // ScaffoldMessenger.of(context).showSnackBar(snack);
                              // Navigator.of(context).pop();
                              final auth =
                                  Provider.of<AuthBase>(context, listen: false);
                              await auth.signOut();
                              final snack = SnackBar(
                                content: Text(
                                  "Apple Sign in plugin deprecated\n${error.toString()}",
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snack);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LandingPage()),
                              );
                            });
                          },
                          color: Colors.red,
                          child: Text(
                            "Press to confirm account removal",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                fontFamily: "Papyrus"),
                          ))
                      : CircularProgressIndicator(
                          color: Colors.white,
                        )),
              // Padding(
              //   padding: const EdgeInsets.all(12.0),
              //   child: CircularProgressIndicator(
              //     backgroundColor: Theme.of(context).primaryColor,
              //     color: Colors.white,
              //   ),
              // ),
            ]),
          ),
        ));
  }
}
