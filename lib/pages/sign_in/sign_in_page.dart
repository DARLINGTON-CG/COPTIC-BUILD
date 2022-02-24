import 'dart:async';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in_button.dart' as AppleButton;
import 'package:copticmeet/pages/sign_in/phone_auth/phone_auth.dart';
import 'package:copticmeet/services/BLoCs/sign_in/sign_in_page_bloc.dart';
import 'package:copticmeet/services/sign_in/auth.dart';
import 'package:copticmeet/utils/color_utils.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/platform_exception_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'apple_auth/apple_signin_available.dart';

class SignIn extends StatelessWidget {
  SignIn({Key key, @required this.bloc}) : super(key: key);

  final SignInBloc bloc;
  Auth auth = Auth();
  bool accepted = false;

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Provider<SignInBloc>(
      create: (_) => SignInBloc(auth: auth),
      dispose: (context, bloc) => bloc.dispose(),
      child: Consumer<SignInBloc>(
          builder: (BuildContext context, bloc, _) => SignIn(bloc: bloc)),
    );
  }

  void _showPopup(BuildContext context) async {
    String data = await getFileData('assets/eula/eula.txt');
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => new AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Builder(
                builder: (context) {
                  var height = MediaQuery.of(context).size.height;
                  var width = MediaQuery.of(context).size.width;
                  return Container(
                    height: height - 200,
                    width: width - 50,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'To continue please read and accept our End User License Agreement',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Papyrus"),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    data,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: "Papyrus", fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              actions: <Widget>[
                FlatButton(
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'Accept',
                    style:
                        TextStyle(fontFamily: 'Papyrus', color: Colors.black),
                  ),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool('accepted', true);
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }

  void _showSignInError(BuildContext context, PlatformException exception) {
    PlatformExceptionAlertDialog(title: 'Sign in failed', exception: exception)
        .show(context);
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await bloc.signInWithGoogle();
    } on PlatformException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        _showSignInError(context, e);
      }
    }
  }

  Future<void> _signInWithPhone(BuildContext context) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PhoneAuthPage()),
      );
    } catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final authService = Provider.of<Auth>(context, listen: false);
      final user = await authService
          .signInWithApple(scopes: [Scope.email, Scope.fullName]);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorUtils.defaultColor,
        body: StreamBuilder<bool>(
            stream: bloc.isLoadingStream,
            initialData: false,
            builder: (context, snapshot) {
              return _buildContent(context, snapshot.data);
            }));
  }

  Widget _buildContent(BuildContext context, bool isLoading) {
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ],
            end: const FractionalOffset(1.0, 0.0),
            begin: const FractionalOffset(0.0, 0.7),
            stops: [0.1, 0.6],
            tileMode: TileMode.clamp),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment(0.0, -0.65),
            child: Container(
                width: MediaQuery.of(context).size.width / 1.4,
                child: Image(
                    image: AssetImage('assets/images/logos/large/logo.png'))),
          ),
          Align(
              alignment: Alignment.center,
              child: SizedBox(
                  height: 50, child: _buildHeader(context, isLoading))),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                                child: Text('Continue with Google',
                                    style: Theme.of(context).textTheme.body2),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (prefs.getBool('accepted') == null ||
                                !prefs.getBool('accepted')) {
                              _showPopup(context);
                            } else {
                              if (!isLoading) {
                                _signInWithGoogle(context);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Hero(
                    tag: 'phoneSignIn',
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
                                    alignment: Alignment(-0.65, 0.0),
                                    child: Icon(Icons.phone),
                                  ),
                                  Align(
                                    alignment: Alignment(0.05, 0.0),
                                    child: Text('Continue with Phone',
                                        style:
                                            Theme.of(context).textTheme.body2),
                                  ),
                                ],
                              ),
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                if (prefs.getBool('accepted') == null ||
                                    !prefs.getBool('accepted')) {
                                  _showPopup(context);
                                } else {
                                  if (!isLoading) {
                                    _signInWithPhone(context);
                                  }
                                }
                              },
                            ),
                          )),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      top: 8.0, left: 30.0, right: 30.0, bottom: 30.0),
                  //    margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (appleSignInAvailable.isAvailable)
                        AppleSignInButton(
                          style:
                              AppleButton.ButtonStyle.black, // style as needed
                          type: ButtonType.signIn, // style as needed
                          onPressed: () => auth.signInWithApple(),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, left: 8.0, right: 8.0, bottom: 30.0),
                  child: Wrap(
                    children: [
                      Text(
                        'When signing in with Google, Apple or Phone we ensure that we do not use any personal data.',
                        style: Theme.of(context).textTheme.body2,
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLoading) {
    if (isLoading) {
      return Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor,
            color: Colors.white,
          ));
    }
    return Container();
    // return Align(
    //     alignment: Alignment.center,
    //     child: Text("We'll help you find a match",
    //         style: Theme.of(context).textTheme.body1));
  }
}
