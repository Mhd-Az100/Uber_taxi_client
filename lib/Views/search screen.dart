import 'package:flutter/material.dart';
import 'package:over_taxi/Model/address_model.dart';
import 'package:over_taxi/Model/placePredictions_model.dart';
import 'package:over_taxi/View_Model/Home_viewmodel.dart';
import 'package:over_taxi/provider/address%20provider.dart';
import 'package:over_taxi/services/Api.dart';
import 'package:over_taxi/utils/configMaps.dart';
import 'package:over_taxi/constant/styleText.dart';
import 'package:over_taxi/widget/divider.dart';
import 'package:over_taxi/widget/progressDialog.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class SerarchScreen extends StatefulWidget {
  @override
  _SerarchScreenState createState() => _SerarchScreenState();
  String? state;
  SerarchScreen({this.state});
}

class _SerarchScreenState extends State<SerarchScreen> {
  var pickUpCtrl = TextEditingController();
  var dropOffCtrl = TextEditingController();
  List<PlacePredictions> placePredictionList = [];
  ControllerMap ctrl = Get.find<ControllerMap>();
  // String? currentlocation;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          //tile for predticion
          (placePredictionList.length > 0) ? listPlaces(size) : Container(),
          dropSearchLocation(size, context),
        ],
      ),
    );
  }

// * list places
  Widget listPlaces(Size size) {
    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.35, right: 16, left: 16),
      child: ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          return PredictionTile(
            placePredictions: placePredictionList[index],
          );
        },
        itemCount: placePredictionList.length,
        separatorBuilder: (BuildContext context, int index) => DividerWidget(),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      ),
    );
  }

// * serch location
// ? call function findPlace()
// ! api googlemap autocomplete with param placename &  mapkey
  Widget dropSearchLocation(Size size, BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: 20,
        ),
        height: size.height * 0.35,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 6,
              spreadRadius: 0.5,
              offset: Offset(0.7, 0.7),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 25, top: 25, bottom: 20, right: 25),
          child: Column(
            children: [
              SizedBox(
                height: 5,
              ),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                  Center(
                    child: Text(
                      'destination'.tr,
                      style: kmaptext,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Image.asset(
                    'img/place.png',
                    height: 20,
                    width: 20,
                  ),
                  SizedBox(
                    width: 10,
                    height: 18,
                  ),
                  Text('from'.tr),
                  SizedBox(
                    width: 10,
                    height: 18,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: TextField(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          readOnly: true,
                          controller: pickUpCtrl,
                          decoration: InputDecoration(
                            hintText: ctrl.pickupLocation.toString(),
                            fillColor: Colors.grey[200],
                            filled: true,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                EdgeInsets.only(left: 11, top: 8, bottom: 8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Image.asset(
                    'img/place.png',
                    height: 20,
                    width: 20,
                  ),
                  SizedBox(
                    width: 10,
                    height: 18,
                  ),
                  Text(
                    'to'.tr,
                  ),
                  SizedBox(
                    width: 10,
                    height: 18,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: TextField(
                          onChanged: (val) {
                            findPlace(val);
                          },
                          controller: dropOffCtrl,
                          decoration: InputDecoration(
                            hintText: 'to'.tr,
                            fillColor: Colors.grey[200],
                            filled: true,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                EdgeInsets.only(left: 11, top: 8, bottom: 8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              // GestureDetector(
              //   onTap: () {},
              //   child: Column(
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Text(
              //             'marker'.tr,
              //             style: ktextdialog,
              //           )
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(
              //   height: 10,
              // ),
              // Center(
              //   child: Image.asset(
              //     'img/marker.png',
              //     width: 70,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrll =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapkey&sessiontoken=1234567890&components=country:sy";
      var res = await ApiServices.getRequsest(autoCompleteUrll);
      if (res == 'failed') {
        return;
      }
      if (res["status"] == "OK") {
        var predictions = res["predictions"];

        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();

        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }
}

//===============================predictionTile============================

class PredictionTile extends StatelessWidget {
  final PlacePredictions? placePredictions;

  PredictionTile({Key? key, this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return placePredictions!.secondary_text != null
        ? TextButton(
            onPressed: () {
              getPlaceAddressDetails(placePredictions!.place_id!, context);
            },
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    Row(
                      children: [
                        Icon(Icons.add_location),
                        SizedBox(
                          width: 14.0,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 8.0,
                              ),
                              Text(
                                placePredictions!.main_text!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 16.0),
                              ),
                              SizedBox(
                                height: 2.0,
                              ),
                              Text(
                                placePredictions!.secondary_text!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.grey),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

// ! api googlemap place details with two param placeId & mapkey
// * get place details by place id
  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Setting Dropoff, Please wait...",
            ));

    String placeDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapkey";

    var res = await ApiServices.getRequsest(placeDetailsUrl);

    Navigator.pop(context);

    if (res == "failed") {
      return;
    }

    if (res["status"] == "OK") {
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);
      print("This is Drop Off Location :: ");
      print(address.placeName);

      Navigator.pop(context, "B");
    }
  }
}
