import 'package:firebase_auth/firebase_auth.dart';

import '../Model/allUsers_model.dart';

String mapkey = "AIzaSyDUYiMp-AWm0TMsuRRWLOFCyRWkgzj8M_I";
User? firebaseUser;
Users? userCurrentInfo;
int driverRequestTimeOut = 40;
String statusRide = "";
String rideStatus = "Driver is Coming";
String carDetailsDriver = "";
String driverName = "";
String driverphone = "";
double starCounter = 0.0;
String title = "";
String carRideType = "";
String serverToken =
    "Bearer AAAAs5pWyTM:APA91bGsKYArxLqxcx12Fe_Dcud7TgwbuSe-X8QlO337tBspdHwjfqILe5tNOjRCO6evJ1zaUVmqmky31p-W3IL8x88Zhu3JJ_YpsWIhkqB_Q5OD9LYNDHlx86zMMMJPnTrlJHiRbsmx";
