import 'package:copticmeet/pages/landing_page.dart';
import 'package:copticmeet/pages/sign_in/apple_auth/apple_signin_available.dart';
import 'package:copticmeet/services/location/location.dart';
import 'package:copticmeet/services/sign_in/auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import 'pages/messaging/push_notifications.dart';
import 'providers/profile_info_caches.dart';

final databaseURL =
    'https://coptic-meet-datamodel-1539932266201-d4683.firebaseio.com/';

void main() async {
  InAppPurchaseConnection.enablePendingPurchases();
  // Fix for: Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initDB();
  final appleSignInAvailable = await AppleSignInAvailable.check();
  runApp(Provider<AppleSignInAvailable>.value(
    value: appleSignInAvailable,
    child: MyApp(),
  ));
}

Future initDB() async {
  FirebaseDatabase db;
  db = FirebaseDatabase.instance;
  db.setPersistenceEnabled(true);
  db.setPersistenceCacheSizeBytes(100000000);
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  

  @override
  Widget build(BuildContext context) {
     final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();
    return Provider<Location>(
      create: (context) => GeolocatorLocation(),
      child: Provider<AuthBase>(
        create: (context) => Auth(),
        child:ChangeNotifierProvider<ProfileImageCaches>(
            create: (context) => ProfileImageCaches(),
            child: MaterialApp(
          title: 'Coptic',
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Color.fromRGBO(215, 175, 79, 1.0),
            //Color.fromRGBO(255, 215, 0, 1.0), // #D7AF4F
            accentColor: Colors.white,
            inputDecorationTheme: InputDecorationTheme(
              fillColor: Colors.grey[100],
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Colors.grey[600],
                  style: BorderStyle.solid,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Colors.transparent,
                  style: BorderStyle.none,
                ),
              ),
            ),
            cardTheme: CardTheme(
              elevation: 13,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            textTheme: TextTheme(
              title: TextStyle(fontFamily: "Papyrus"),
              body1: TextStyle(
                fontFamily: "Papyrus",
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              body2: TextStyle(
                fontFamily: "Papyrus",
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
          home: LandingPage(),
        )),
      ),
    );
  }
}
