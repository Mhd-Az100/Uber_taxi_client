import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:over_taxi/Model/address_model.dart';
import 'package:over_taxi/Model/allUsers_model.dart';
import 'package:over_taxi/Model/directDetails_model.dart';
import 'package:over_taxi/provider/address%20provider.dart';
import 'package:over_taxi/services/Api.dart';
import 'package:over_taxi/utils/configMaps.dart';
import 'package:provider/provider.dart';

class AssistantMehod {
// ? param current position
// ! api geocode googlemap with two param LatLng position & mapkey
// * return place name
// todo use marker position

  static Future<String?> searchCoordinateAddress(
      double lat, double lng, context, var state) async {
    print('from assets method');

    print(lat);

    String placeAddress = "";
    String? url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lng}&key=$mapkey&language=ar";
    var res = await ApiServices.getRequsest(url);
    print(url);
    if (res != "failed") {
      placeAddress = res["results"][1]["address_components"][0]["long_name"] +
          " " +
          res["results"][1]["address_components"][1]["long_name"];

      Address address = Address();
      address.latitude = lat;
      address.longitude = lng;
      address.placeName = placeAddress;
      if (state == 'notAB') {
        Provider.of<AppData>(context, listen: false)
            .updatePickUpLocationAddress(address);
      } else if (state == 'AB') {
        Provider.of<AppData>(context, listen: false)
            .updateDropOffLocationAddress(address);
      }
    }
    return placeAddress;
  }

//====================================================================//
// ? param two points A position and B position
// ! api directions googlemap with two param LatLng A position & LatLng B position & mapkey
// * return direction details (encod points & destance & duration)

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapkey";

    var res = await ApiServices.getRequsest(directionUrl);

    if (res == "failed") {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

//====================================================================//
// ? param  direction Details
// * return total prace
// todo calculate duration & s.p prace

  static int calculateFares(DirectionDetails directionDetails) {
    //in terms USD
    double timeTraveledFare = (directionDetails.durationValue! / 60) * 1000;
    double distancTraveledFare =
        (directionDetails.distanceValue! / 1000) * 1000;
    double totalFareAmount = timeTraveledFare + distancTraveledFare;

    //Local Currency
    //1$ = 160 RS
    //double totalLocalAmount = totalFareAmount * 160;

    return totalFareAmount.truncate();
  }
//====================================================================//
// ! use fire base to user

  static void getCurrentOnlineUserInfo() async {
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userId = firebaseUser!.uid;
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("users").child(userId);

    reference.once().then((DataSnapshot dataSnapShot) {
      if (dataSnapShot.value != null) {
        userCurrentInfo = Users.fromSnapshot(dataSnapShot);
      }
    });
  }
//====================================================================//
// ? param  number
// * return random number

  static double creatRandomNumber(int numb) {
    var random = Random();
    int radNumber = random.nextInt(numb);
    return radNumber.toDouble();
  }

//====================================================================//
// ? param  token & ride_request_id
// * send notification to driver with data
// todo edit to send without firebase

  static sendNotificationToDriver(
      String token, context, String ride_request_id) async {
    var destionation =
        Provider.of<AppData>(context, listen: false).dropOffLocation;

    if (token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': serverToken,
        },
        body: jsonEncode({
          'to': token,
          'data': {
            'status': 'done',
            'ride_request_id': ride_request_id,
            'via': 'FlutterFire Cloud Messaging!!!',
            'count': '1',
          },
          'notification': {
            'title': "طلب جديد",
            'body': 'موقع التوصيل الى ${destionation!.placeName}',
            'ride_request_id': ride_request_id,
          },
        }),
      );
      print('jsonencode message ${jsonEncode({
            'to': token,
            'data': {
              'status': 'done',
              'ride_request_id': ride_request_id,
              'via': 'FlutterFire Cloud Messaging!!!',
              'count': '1',
            },
            'notification': {
              'title': "طلب جديد",
              'body': 'موقع التوصيل الى ${destionation.placeName}',
              'ride_request_id': ride_request_id,
            },
          })}');

      print('FCM request for device sent!');
    } catch (e) {
      print('errorrrr messaging  = $e');
    }
  }
}
