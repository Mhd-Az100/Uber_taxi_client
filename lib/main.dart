import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:over_taxi/Views/Home.dart';
import 'package:over_taxi/lang/traranslation.dart';
import 'package:over_taxi/provider/address%20provider.dart';
import 'package:provider/provider.dart';

import 'Views/personal information.dart';

void main() async {
  //Disallowing rotating the screen.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

DatabaseReference usersRef =
    FirebaseDatabase.instance.reference().child("users");
DatabaseReference driversRef =
    FirebaseDatabase.instance.reference().child("drivers");
DatabaseReference rideRequestRef =
    FirebaseDatabase.instance.reference().child("Ride Requests");

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false, //No Debug on the top of the screen

        home: FirebaseAuth.instance.currentUser == null ? Home() : Home(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('ar', ''),
        ],
        translations: Translation(),
        locale: Locale("ar", ""),
        fallbackLocale: Locale('ar'),
      ),
    );
  }
}
