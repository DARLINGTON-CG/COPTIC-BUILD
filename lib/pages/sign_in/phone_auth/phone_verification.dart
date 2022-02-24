import 'package:copticmeet/pages/landing_page.dart';
import 'package:copticmeet/services/sign_in/auth.dart';
import 'package:copticmeet/utils/color_utils.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/platform_exception_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class PhoneVerification extends StatefulWidget {
  final phoneNumber;

  const PhoneVerification({Key key, @required this.phoneNumber})
      : super(key: key);

  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  double _height, _width;

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode();
  FocusNode focusNode6 = FocusNode();
  String code = "";

  void _showSignInError(BuildContext context, PlatformException exception) {
    PlatformExceptionAlertDialog(title: 'Sign in failed', exception: exception)
        .show(context);
  }

  Future<User> _signInWithPhoneNumber(BuildContext context, code) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      User user = await auth.signInWithPhoneNumber(code);
      return user;
    } catch (e) {
      _showSignInError(context, e);
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorUtils.defaultColor,
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ],
                  begin: const FractionalOffset(1.0, 0.0),
                  end: const FractionalOffset(0.0, 0.7),
                  stops: [0.3, 1.0],
                  tileMode: TileMode.clamp),
            ),
            child: Card(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.height / 1.2,
                    color: Colors.white,
                    child: Column(children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )),
                      Align(
                        alignment: Alignment(0.0, -0.65),
                        child: Container(
                            width: MediaQuery.of(context).size.width / 1.7,
                            child: Image(
                                image: AssetImage(
                                    'assets/images/logos/large/logo.png'))),
                      ),
                      SizedBox(
                        // height: _height * 8 / 10,
                        width: _width * 8 / 10,
                        child: _getColumnBody(),
                      )
                    ]),
                  ),
                )),
          ),
        ));
  }

  Widget _getColumnBody() => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 26.0),
            Row(
              children: <Widget>[
                SizedBox(width: 16.0),
                Expanded(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: 'Please enter the ',
                            style: Theme.of(context).textTheme.body2),
                        TextSpan(
                            text: 'One Time Passcode',
                            style: Theme.of(context).textTheme.body2),
                        TextSpan(
                          text: ' sent to your mobile',
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
              ],
            ),
            SizedBox(height: 40.0),
            Container(
              width: MediaQuery.of(context).size.width / 1.7,
              child: PinCodeTextField(
                length: 6,
                obsecureText: false,
                textInputType: TextInputType.number,
                autoFocus: true,
                animationType: AnimationType.fade,
                shape: PinCodeFieldShape.box,
                animationDuration: Duration(milliseconds: 300),
                borderRadius: BorderRadius.circular(5),
                autoDismissKeyboard: true,
                fieldHeight: 40,
                fieldWidth: 30,
                activeColor: Theme.of(context).primaryColor,
                inactiveColor: Colors.grey,
                selectedColor: Theme.of(context).primaryColor,
                onChanged: (value) => setState(() => code = value),
                onCompleted: (value) => _verifyLogin(),
                onSubmitted: (value) => _verifyLogin(),
              ),
            ),
            SizedBox(height: 50.0),
            RaisedButton(
              elevation: 16.0,
              onPressed: _verifyLogin,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Verify the pin',
                  style: Theme.of(context).textTheme.body2,
                ),
              ),
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            )
          ]);

  _verifyLogin() async {
    print("VERIFYING WITH PHONE NUMBER");
    await _signInWithPhoneNumber(context, code);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LandingPage()),
    );
  }
}
