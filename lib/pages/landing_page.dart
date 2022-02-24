import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in_button.dart' as AppleButton;

import 'package:copticmeet/pages/first_login_landing_page.dart/first_login.dart';
import 'package:copticmeet/pages/sign_in/sign_in_page.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/services/sign_in/auth.dart';
import 'package:copticmeet/utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:copticmeet/services/storage/storage.dart';

import 'sign_in/apple_auth/apple_signin_available.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    final Auth auth = Provider.of<AuthBase>(context, listen: false);
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    return StreamBuilder<User>(
        stream: auth.onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User user = snapshot.data;
            if (auth is Auth &&
                auth.firebaseAuth.currentUser != null &&
                auth.firebaseAuth.currentUser.providerData.firstWhere(
                        (element) =>
                            element.providerId == "apple.com" ||
                            element.providerId == "google.com",
                        orElse: () => null) ==
                    null) {
              return Scaffold(
                backgroundColor: ColorUtils.defaultColor,
                body: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      gradient: new LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).accentColor
                          ],
                          begin: const FractionalOffset(1.0, 0.0),
                          end: const FractionalOffset(0.0, 0.7),
                          stops: [0.3, 1.0],
                          tileMode: TileMode.clamp)),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Please connect with your account"),
                        SizedBox(height: 30.0),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: Theme.of(context).cardTheme.elevation,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 1.2,
                                height: MediaQuery.of(context).size.height / 18,
                                child: RaisedButton(
                                  disabledColor: Colors.white,
                                  color: Colors.white,
                                  child: Stack(
                                    children: <Widget>[
                                      Align(
                                          alignment: Alignment(-0.7, 0.0),
                                          child: Container(
                                            width: 25,
                                            child: Image(
                                                image: AssetImage(
                                                    'assets/images/logos/google/g-logo.png')),
                                          )),
                                      Align(
                                        alignment: Alignment(0.05, 0.0),
                                        child: Text('Connect with Google',
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2),
                                      ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    Auth auth = Provider.of<AuthBase>(context,
                                        listen: false);
                                    final googleSignIn = GoogleSignIn();
                                    await googleSignIn.signOut();
                                    final googleAccount =
                                        await googleSignIn.signIn();
                                    if (googleAccount != null) {
                                      final googleAuth =
                                          await googleAccount.authentication;
                                      if (googleAuth.accessToken != null &&
                                          googleAuth.idToken != null) {
                                        try {
                                          await auth.firebaseAuth.currentUser
                                              .linkWithCredential(
                                                  GoogleAuthProvider.credential(
                                                      idToken:
                                                          googleAuth.idToken,
                                                      accessToken: googleAuth
                                                          .accessToken));
                                          setState(() {});
                                        } catch (e) {
                                          String message = e.toString();
                                          if (e is FirebaseAuthException) {
                                            message = e.message;
                                          }
                                          Fluttertoast.showToast(
                                              msg: message,
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        }
                                      } else {
                                        throw PlatformException(
                                            code:
                                                "ERROR_MISSIING_GOOGLE_AUTH_TOKEN",
                                            message:
                                                "Missing Google Auth token");
                                      }
                                    } else {
                                      throw PlatformException(
                                          code: "ERROR_ABORTED_BY_USER",
                                          message:
                                              "Sign in was aborted by user");
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 30.0, right: 30.0, bottom: 30.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (appleSignInAvailable.isAvailable)
                                AppleSignInButton(
                                  style: AppleButton
                                      .ButtonStyle.black, // style as needed
                                  type: ButtonType
                                      .continueButton, // style as needed
                                  onPressed: () async {
                                    Auth auth = Provider.of<AuthBase>(context,
                                        listen: false);
                                    final result =
                                        await AppleSignIn.performRequests([
                                      AppleIdRequest(requestedScopes: [
                                        Scope.email,
                                        Scope.fullName
                                      ])
                                    ]);
                                    switch (result.status) {
                                      case AuthorizationStatus.authorized:
                                        final appleIdCredential =
                                            result.credential;
                                        final oAuthProvider =
                                            OAuthProvider('apple.com');
                                        final credential =
                                            oAuthProvider.credential(
                                          idToken: String.fromCharCodes(
                                              appleIdCredential.identityToken),
                                          accessToken: String.fromCharCodes(
                                              appleIdCredential
                                                  .authorizationCode),
                                        );
                                        try {
                                          await auth.firebaseAuth.currentUser
                                              .linkWithCredential(credential);
                                          setState(() {});
                                        } catch (e) {
                                          String message = e.toString();
                                          if (e is FirebaseAuthException) {
                                            message = e.message;
                                          }
                                          Fluttertoast.showToast(
                                              msg: message,
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        }
                                        break;
                                      case AuthorizationStatus.error:
                                        throw PlatformException(
                                          code: 'ERROR_AUTHORIZATION_DENIED',
                                          message: result.error.toString(),
                                        );
                                      case AuthorizationStatus.cancelled:
                                        throw PlatformException(
                                          code: 'ERROR_ABORTED_BY_USER',
                                          message: 'Sign in aborted by user',
                                        );
                                      default:
                                        throw UnimplementedError();
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: Theme.of(context).cardTheme.elevation,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 1.2,
                                height: MediaQuery.of(context).size.height / 18,
                                child: RaisedButton(
                                  color: Colors.grey[700],
                                  child: Text('Sign Out',
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(color: Colors.white)),
                                  onPressed: () async {
                                    await auth.signOut();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            if (user == null) {
              return SignIn.create(context);
            }
            return Provider<Database>(
              create: (_) => FirestoreDatabase(uid: user.uid),
              child: Provider<Storage>(
                  create: (_) => FirestoreStorage(),
                  child: FirstLoginLandingPage()),
            );
          } else {
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
                  child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }
        });
  }
}
