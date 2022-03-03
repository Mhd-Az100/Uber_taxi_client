import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:over_taxi/Model/directDetails_model.dart';
import 'package:over_taxi/Model/nearbyAvailableDrivers_model.dart';
import 'package:over_taxi/View_Model/Home_viewmodel.dart';
import 'package:over_taxi/Views/search%20screen.dart';
import 'package:over_taxi/provider/address%20provider.dart';
import 'package:over_taxi/services/assistantmethod.dart';
import 'package:over_taxi/services/geoFireAssistant.dart';
import 'package:over_taxi/utils/configMaps.dart';
import 'package:over_taxi/constant/colors.dart';
import 'package:over_taxi/constant/styleText.dart';
import 'package:over_taxi/main.dart';
import 'package:over_taxi/utils/url.dart';
import 'package:over_taxi/widget/drawer.dart';
import 'package:over_taxi/widget/loginButton.dart';
import 'package:over_taxi/widget/noDriverAvailableDialog.dart';
import 'package:over_taxi/widget/progressDialog.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(33.500602, 36.296266),
    zoom: 14.4746,
  );

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  //===============vars google map==============
  CameraPosition? markerposition;
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController? newGoogleMapController;

  Position? currentPosition;

  var geolocator = Geolocator();

  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinates = [];

  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = new Set();

  Set<Circle> circleSet = {};

  DirectionDetails? tripDirectionDetails;

  BitmapDescriptor? nearByIcon;

  BitmapDescriptor? markerA;

  BitmapDescriptor? markerB;

//===============================================================
  final ControllerMap c = Get.put(ControllerMap());
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var pickUpCtrl = TextEditingController();
  DatabaseReference? rideRequestRef;
  List<NearbyAvailableDrivers>? availableDrivers;
//================vars change state ====================
  String uName = "";
  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 200;
  bool drawerOpen = true;
  bool nearbyAvailableDriverKeysLoaded = false;
  String state = "normal";
  String statePoint = "A";
  String statechange = "notAB";
  double widthimg = 100;
  String markerName = 'img/marker.png';
  String canmove = 'يمكنك التحريك لاختيار المنطقة ';
  String pointName = 'نقطة البداية';

//===============================================================

  @override
  void initState() {
    super.initState();
    creatIconMarkerAB();
    // AssistantMehod.getCurrentOnlineUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    creatIconMarkerCar();
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        resetApp();
        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: DrawerConst(uName: uName),
        appBar: AppBar(
          backgroundColor: green,

          //Insert an Image in the top Left (becuase the language is Arabic)
          actions: [
            Image.asset(
              'img/whitelogo.png', //The OVER image in the AppBar in Actions

              //Re-scalling the dimensions of the image to fit in the AppBar
              scale: 1.8,
            ),
          ],
        ),
        body: Stack(
          children: [
            googlemap(),
            state != 'paint'
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 120.0),
                    child: Center(
                      child: Image.asset(
                        markerName,
                        width: widthimg,
                      ),
                    ),
                  )
                : Container(),
            buttonReset(),
            detialsOption(size),
            rideDetials(),
            rideRequest(),
          ],
        ),
      ),
    );
  }

// * google map with marker & polylines & circles
  Widget googlemap() {
    return GoogleMap(
      padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
      initialCameraPosition: Home._kGooglePlex,
      zoomGesturesEnabled: true,
      myLocationEnabled: true,
      zoomControlsEnabled: true,
      polylines: polylineSet,
      markers: markersSet,
      circles: circleSet,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        _controllerGoogleMap.complete(controller);
        newGoogleMapController = controller;
        locatePosition();
        setState(() {
          bottomPaddingOfMap = 200;
        });
      },
      onCameraMove: (CameraPosition position) {
        if (state != 'paint') {
          setState(() {
            searchContainerHeight = 0;
            markerposition = position;
            widthimg = 100;
          });
        }
      },
      onCameraIdle: () async {
        if (state != 'paint') {
          setState(() {
            widthimg = 80;
            searchContainerHeight = 200;
          });
          if (statechange == 'notAB') {
            c.positionlatA.value = markerposition!.target.latitude;
            c.positionlongA.value = markerposition!.target.longitude;
            c.getNamepickupLocation(context);
          } else if (statechange == 'AB') {
            c.positionlatB.value = markerposition!.target.latitude;
            c.positionlongB.value = markerposition!.target.longitude;
            c.getNamedropoffLocation(context);
          }
        }
      },
    );
  }

// * this button display whene user choose place
// ? call function resetapp()
  Widget buttonReset() {
    return Positioned(
      top: 36.0,
      left: 22.0,
      child: GestureDetector(
        onTap: () {
          if (!drawerOpen) resetApp();
        },
        child: Container(
          decoration: BoxDecoration(
            color: drawerOpen ? Colors.transparent : Colors.white,
            borderRadius: BorderRadius.circular(22.0),
            boxShadow: [
              BoxShadow(
                color: drawerOpen ? Colors.transparent : Colors.black,
                blurRadius: 6.0,
                spreadRadius: 0.5,
                offset: Offset(
                  0.7,
                  0.7,
                ),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: drawerOpen ? Colors.transparent : Colors.redAccent,
            child: Icon(
              (drawerOpen) ? null : Icons.close,
              color: Colors.black,
            ),
            radius: 20.0,
          ),
        ),
      ),
    );
  }

// * view location name for user and go to search
// ? call function displayRideDetailsContainar()
  Widget detialsOption(Size size) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedSize(
        curve: Curves.bounceIn,
        duration: Duration(milliseconds: 160),
        vsync: this,
        child: Container(
          height: searchContainerHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 16,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 6,
                  ),
                  Center(
                    child: Text(
                      canmove,
                      style: kmaptext,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.bottomSheet(
                            Container(
                              color: Colors.white,
                              width: size.width,
                              height: size.height,
                            ),
                          );
                        },
                        child: Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: GetBuilder<ControllerMap>(
                              init: ControllerMap(),
                              builder: (ctrl) {
                                return TextField(
                                  readOnly: true,
                                  controller: pickUpCtrl,
                                  decoration: InputDecoration(
                                    hintText: statechange == 'notAB'
                                        ? ctrl.pickupLocation.toString()
                                        : ctrl.dropoffLocation.toString(),
                                    fillColor: Colors.grey[200],
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 11, top: 8, bottom: 8),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 40),
                    child: Text(
                      pointName,
                      style: kmaptextlight,
                    ),
                  ),
                  Center(
                    child: LoginButton(
                      onPressed: () async {
                        if (statechange == 'notAB') {
                          var res = await Get.to(SerarchScreen(state: state));

                          if (res == "B") {
                            setState(() {
                              statePoint = 'B';
                            });
                            changeState();
                            locatePosition();
                          }
                        } else if (statechange == 'AB') {
                          displayRideDetailsContainar();
                        }
                      },
                      text: 'button'.tr,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// * display after choose place from search page
// ? call function displayRequestRideContainer() &searchNearestDriver() & change state to requesting
  Widget rideDetials() {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: AnimatedSize(
        vsync: this,
        curve: Curves.bounceIn,
        duration: Duration(milliseconds: 160),
        child: Container(
          height: rideDetailsContainerHeight,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 16,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ]),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 17),
            child: ListView(
              // mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => c.carss.isEmpty
                      ? Text("GG")
                      : ListView.builder(
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.defaultDialog(
                                        title: c.carss[index].name!,
                                        titleStyle: kWelcomeLogin,
                                        middleText: tripDirectionDetails != null
                                            ? tripDirectionDetails!
                                                .distanceText!
                                            : '',
                                        content: Image.network(
                                          '$domin' +
                                              '/' +
                                              c.carss[index].image!,
                                          height: 70,
                                          width: 80,
                                        ),
                                        confirmTextColor: Colors.white,
                                        buttonColor: green,

                                        //When ok is pressed, it will go to the Home Screen.
                                        onConfirm: () {
                                          setState(() {
                                            state = "requesting";
                                          });
                                          // displayRequestRideContainer();
                                          // availableDrivers = GeoFireAssistant
                                          //     .nearbyAvailableDriversList;
                                          // searchNearestDriver();
                                          Navigator.of(context).pop();
                                        },
                                        onCancel: () {
                                          Navigator.of(context).pop();
                                        });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    width: double.infinity,
                                    color: Colors.white,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Image.network(
                                              '$domin' +
                                                  '/' +
                                                  c.carss[index].image!,
                                              height: 70,
                                              width: 80,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  c.carss[index].name!,
                                                  style: kmaptextcar,
                                                ),
                                                Text(
                                                  (tripDirectionDetails != null)
                                                      ? tripDirectionDetails!
                                                          .distanceText!
                                                      : '',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10),
                                                  child: Text(
                                                    'السعر التقريبي',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF09701A),
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 17),
                                                  ),
                                                ),
                                                Text(
                                                  (tripDirectionDetails != null)
                                                      ? ' ${AssistantMehod.calculateFares(tripDirectionDetails!)}'
                                                      : '',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 22),
                                                ),
                                                Text('ل.س'),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 2,
                                  color: Color(0xffffcf00),
                                ),
                              ],
                            );
                          },
                          itemCount: c.carss.length,
                        ),
                ),
                // SizedBox(
                //   height: 20,
                // ),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 20),
                //   child: Row(
                //     children: [
                //       Icon(
                //         FontAwesomeIcons.moneyCheckAlt,
                //         size: 18,
                //         color: Colors.black54,
                //       ),
                //       SizedBox(
                //         width: 16,
                //       ),
                //       Text('cash'.tr),
                //       SizedBox(
                //         width: 6,
                //       ),
                //       Icon(
                //         Icons.keyboard_arrow_down,
                //         color: Colors.black54,
                //         size: 16,
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(
                //   height: 24,
                // ),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 20),
                //   child: TextButton(
                //     style: TextButton.styleFrom(
                //       backgroundColor: Colors.green,
                //     ),
                //     onPressed: () {
                //       setState(() {
                //         state = "requesting";
                //       });
                //       displayRequestRideContainer();
                //       availableDrivers =
                //           GeoFireAssistant.nearbyAvailableDriversList;
                //       searchNearestDriver();
                //     },
                //     child: Padding(
                //       padding: EdgeInsets.all(5),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(
                //             'طلب',
                //             style: TextStyle(
                //               fontSize: 20,
                //               fontWeight: FontWeight.bold,
                //               color: Colors.white,
                //             ),
                //           ),
                //           Icon(
                //             FontAwesomeIcons.taxi,
                //             color: Colors.white,
                //             size: 26,
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// * display after request
// ? call function cancelRideRequest() & resetApp()
  Widget rideRequest() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
          height: requestRideContainerHeight,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 16,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ]),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Center(
                child: Column(
                  children: [
                    Text('wait'.tr, style: kthanksText),
                    Text('wait2'.tr, style: kthanksText),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      cancelRideRequest();
                      resetApp();
                    },
                    child: Container(
                      height: 60.0,
                      width: 60.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26.0),
                        border:
                            Border.all(width: 2.0, color: Colors.grey[300]!),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 26.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "close".tr,
                        style: kWelcomeLogin,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }

//=======================functions ==========================

// * get pickUpLocation & dropOffLocation from provider
// ! call function obtainPlaceDirectionDetails()
// * make short way and draw polylines and set marker and circle to points A & B
  Future<void> getplaceDiection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos!.latitude!, initialPos.longitude!);
    var dropOffLatLng = LatLng(finalPos!.latitude!, finalPos.longitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ));

    var details = await AssistantMehod.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    setState(() {
      state = 'paint';
      tripDirectionDetails = details;
    });

    Navigator.pop(context);

    print("This is Encoded Points ::");
    print(details!.encodedPoints);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints!);
    pLineCoordinates.clear();
    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        LatLng(pointLatLng.latitude, pointLatLng.longitude);
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.indigo[900]!,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });
    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newGoogleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(latLngBounds, 70),
    );
    Marker picUpLocalMarker = Marker(
        icon: markerA!,
        infoWindow: InfoWindow(title: initialPos.placeName, snippet: 'موقعي'),
        position: pickUpLatLng,
        markerId: MarkerId('pickUpId'));
    Marker dropOffLocalMarker = Marker(
      icon: markerB!,
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: 'نقطة الوصول المرادة'),
      position: dropOffLatLng,
      markerId: MarkerId('dropoffId'),
    );
    setState(() {
      markersSet.add(picUpLocalMarker);
      markersSet.add(dropOffLocalMarker);
    });
    Circle pickUpLocCircle = Circle(
      circleId: CircleId('pickUpId'),
      fillColor: Colors.red.withOpacity(0.7),
      center: pickUpLatLng,
      radius: 100,
      strokeWidth: 4,
      strokeColor: Colors.greenAccent,
    );
    Circle dropOffLocCircle = Circle(
      circleId: CircleId('dropOffId'),
      fillColor: Colors.blueGrey.withOpacity(0.7),
      center: dropOffLatLng,
      radius: 100,
      strokeWidth: 4,
      strokeColor: Colors.red,
    );
    setState(() {
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropOffLocCircle);
    });
  }

// * get current location in google map
// ! call function searchCoordinateAddress()
// ? call function initGeoFierListner()
  void locatePosition() async {
    if (statechange == 'notAB') {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPosition = position;
      LatLng latlngposition = LatLng(position.latitude, position.longitude);
      CameraPosition cameraPosition =
          CameraPosition(target: latlngposition, zoom: 17);
      newGoogleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
      String? address = await AssistantMehod.searchCoordinateAddress(
          position.latitude, position.longitude, context, statechange);
      print("this is your Address :: " + address!);
      initGeoFierListner();
    } else if (statechange == 'AB') {
      var dropoff =
          Provider.of<AppData>(context, listen: false).dropOffLocation;
      LatLng latlngposition = LatLng(dropoff!.latitude!, dropoff.longitude!);
      CameraPosition cameraPosition =
          CameraPosition(target: latlngposition, zoom: 17);
      newGoogleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
    }
  }

// *change state to paint direct
  void displayRideDetailsContainar() async {
    await getplaceDiection();
    setState(() {
      searchContainerHeight = 0;
      bottomPaddingOfMap = 250;
      rideDetailsContainerHeight = 250;
    });
  }

// * change state containar
  void displayRequestRideContainer() {
    setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 150.0;
      drawerOpen = true;
    });
    saveRideRequest();
  }

// ! ========geofire===========
  void initGeoFierListner() {
    Geofire.initialize("availableDrivers");
    //================================
    Geofire.queryAtLocation(
            currentPosition!.latitude, currentPosition!.longitude, 15)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map["key"];
            nearbyAvailableDrivers.latitude = map["latitude"];
            nearbyAvailableDrivers.longitude = map["longitude"];
            GeoFireAssistant.nearbyAvailableDriversList
                .add(nearbyAvailableDrivers);
            if (nearbyAvailableDriverKeysLoaded == true) {
              updateAvailableDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeDriverFromList(map["key"]);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map["key"];
            nearbyAvailableDrivers.latitude = map["latitude"];
            nearbyAvailableDrivers.longitude = map["longitude"];
            GeoFireAssistant.updateDriverNearbyLocation(nearbyAvailableDrivers);
            break;

          case Geofire.onGeoQueryReady:
            updateAvailableDriversOnMap();
            break;
        }
      }

      setState(() {});
    });
    //================================
  }

// * make driver nearby icon cars
// ! call function creatRandomNumber() & geofire
  void updateAvailableDriversOnMap() {
    setState(() {
      markersSet.clear();
    });
    Set<Marker> tMarkers = Set<Marker>();
    for (NearbyAvailableDrivers driver
        in GeoFireAssistant.nearbyAvailableDriversList) {
      LatLng driverAvailablePosition =
          LatLng(driver.latitude!, driver.longitude!);
      Marker marker = Marker(
          markerId: MarkerId('driver${driver.key}'),
          position: driverAvailablePosition,
          icon: nearByIcon!,
          rotation: AssistantMehod.creatRandomNumber(360));
      tMarkers.add(marker);
      print('icooooooooooooooon');
      print(nearByIcon);
    }
    setState(() {
      markersSet = tMarkers;
    });
  }

// * creat custom icon for nearby car
  void creatIconMarkerCar() {
    if (nearByIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: Size(11, 11),
      );

      BitmapDescriptor.fromAssetImage(imageConfiguration, "img/nearbycar.png")
          .then((value) {
        nearByIcon = value;
      }).catchError((error) {
        print('errooooooooooor${error.toString()}');
      });
    }
  }

// * creat custom icon for nearby car
  void creatIconMarkerAB() async {
    markerA = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1), 'img/m1.png');
    markerB = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1), 'img/m2.png');
  }

// * reset app to home defualt
  resetApp() {
    changeState();
    setState(() {
      state = 'notSelect';
      drawerOpen = true;
      searchContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 200.0;

      polylineSet.clear();
      markersSet.clear();
      circleSet.clear();
      pLineCoordinates.clear();

      // statusRide = "";
      // driverName = "";
      // driverphone = "";
      // carDetailsDriver = "";
      // rideStatus = "Driver is Coming";
      // driverDetailsContainerHeight = 0.0;
    });

    locatePosition();
  }

// * change state choose points A B
  void changeState() {
    if (statePoint == 'B') {
      setState(() {
        markerName = 'img/marker2.png';
        canmove = 'يمكنك التحريك لاختيار المنطقة المراد الوصول اليها';
        pointName = 'نقطة النهاية';
        drawerOpen = false;
        statechange = 'AB';
        c.state.value = 'AB';
        statePoint = 'A';
      });
    } else if (statePoint == 'A') {
      setState(() {
        c.pickupLocation.value = '';
        markerName = 'img/marker.png';
        canmove = 'يمكنك التحريك لاختيار المنطقة ';
        pointName = 'نقطة البداية';
        statechange = 'notAB';
        statePoint = 'B';
        c.state.value = 'notAB';
        drawerOpen = true;
      });
    }
  }

// * delete rideRequest from data & change state to normal
  void cancelRideRequest() {
    rideRequestRef!.remove();
    setState(() {
      state = "normal";
    });
  }

// * save rideRequest Details
  void saveRideRequest() {
    rideRequestRef =
        FirebaseDatabase.instance.reference().child("Ride Requests").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocMap = {
      "latitude": pickUp!.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map dropOffLocMap = {
      "latitude": dropOff!.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };

    Map rideInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo!.name,
      "rider_phone": userCurrentInfo!.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
      "ride_type": carRideType,
    };

    rideRequestRef!.set(rideInfoMap);

    // rideStreamSubscription = rideRequestRef!.onValue.listen((event) async {
    //   if (event.snapshot.value == null) {
    //     return;
    //   }

    //   if (event.snapshot.value["car_details"] != null) {
    //     setState(() {
    //       carDetailsDriver = event.snapshot.value["car_details"].toString();
    //     });
    //   }
    //   if (event.snapshot.value["driver_name"] != null) {
    //     setState(() {
    //       driverName = event.snapshot.value["driver_name"].toString();
    //     });
    //   }
    //   if (event.snapshot.value["driver_phone"] != null) {
    //     setState(() {
    //       driverphone = event.snapshot.value["driver_phone"].toString();
    //     });
    //   }

    //   if (event.snapshot.value["driver_location"] != null) {
    //     double driverLat = double.parse(
    //         event.snapshot.value["driver_location"]["latitude"].toString());
    //     double driverLng = double.parse(
    //         event.snapshot.value["driver_location"]["longitude"].toString());
    //     LatLng driverCurrentLocation = LatLng(driverLat, driverLng);

    //     if (statusRide == "accepted") {
    //       updateRideTimeToPickUpLoc(driverCurrentLocation);
    //     } else if (statusRide == "onride") {
    //       updateRideTimeToDropOffLoc(driverCurrentLocation);
    //     } else if (statusRide == "arrived") {
    //       setState(() {
    //         rideStatus = "Driver has Arrived.";
    //       });
    //     }
    //   }

    //   if (event.snapshot.value["status"] != null) {
    //     statusRide = event.snapshot.value["status"].toString();
    //   }
    //   if (statusRide == "accepted") {
    //     displayDriverDetailsContainer();
    //     Geofire.stopListener();
    //     deleteGeofileMarkers();
    //   }
    //   if (statusRide == "ended") {
    //     if (event.snapshot.value["fares"] != null) {
    //       int fare = int.parse(event.snapshot.value["fares"].toString());
    //       var res = await showDialog(
    //         context: context,
    //         barrierDismissible: false,
    //         builder: (BuildContext context) => CollectFareDialog(
    //           paymentMethod: "cash",
    //           fareAmount: fare,
    //         ),
    //       );

    //       String driverId = "";
    //       if (res == "close") {
    //         if (event.snapshot.value["driver_id"] != null) {
    //           driverId = event.snapshot.value["driver_id"].toString();
    //         }

    //         Navigator.of(context).push(MaterialPageRoute(
    //             builder: (context) => RatingScreen(driverId: driverId)));

    //         rideRequestRef.onDisconnect();
    //         rideRequestRef = null;
    //         rideStreamSubscription.cancel();
    //         rideStreamSubscription = null;
    //         resetApp();
    //       }
    //     }
    //   }
    // });
  }

// * if not found driver
// ? cull function cancelRideRequest() & noDriverFound() & resetApp()
// * else
// ? cull function notifyDriver()
  void searchNearestDriver() {
    if (availableDrivers!.length == 0) {
      cancelRideRequest();
      noDriverFound();
      resetApp();
      return;
    }
    var driver = availableDrivers![0];
    notifyDriver(driver);
    availableDrivers!.removeAt(0);
  }

// * show dialog not found
  void noDriverFound() {
    showDialog(
        context: context,
        builder: (BuildContext context) => NoDriverAvailableDialog());
  }

// * send notification to driver
//  ?@param NearbyAvailableDrivers LatLng&key
// * add to data "newRide"
// ! call function sendNotificationToDriver()
// ? call function searchNearestDriver()

  void notifyDriver(NearbyAvailableDrivers drivere) {
    driversRef.child(drivere.key!).child("newRide").set(rideRequestRef!.key);
    driversRef
        .child(drivere.key!)
        .child("token")
        .once()
        .then((DataSnapshot snap) {
      if (snap.value != null) {
        print('call send notification method');
        String token = snap.value.toString();
        AssistantMehod.sendNotificationToDriver(
            token, context, rideRequestRef!.key);
      } else {
        print('faaaaaaaaa');
        return;
      }
      const oneSecondPassed = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecondPassed, (timer) {
        if (state != "requesting") {
          driversRef.child(drivere.key!).child("newRide").set("cancelled");
          driversRef.child(drivere.key!).child("newRide").onDisconnect();
          driverRequestTimeOut = 40;
          timer.cancel();
          searchNearestDriver();
        }
        driverRequestTimeOut = driverRequestTimeOut - 1;
        driversRef.child(drivere.key!).child("newRide").onValue.listen((event) {
          if (event.snapshot.value.toString() == "accepted") {
            driversRef.child(drivere.key!).child("newRide").onDisconnect();
            driverRequestTimeOut = 40;
            timer.cancel();
          }
        });

        if (driverRequestTimeOut == 0) {
          driversRef.child(drivere.key!).child("newRide").set("timeout");
          driversRef.child(drivere.key!).child("newRide").onDisconnect();
          driverRequestTimeOut = 40;
          timer.cancel();
          searchNearestDriver();
        }
      });
    });
  }
//=======================================================

}
