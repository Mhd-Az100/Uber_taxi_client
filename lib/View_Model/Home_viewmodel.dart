import 'package:get/state_manager.dart';
import 'package:over_taxi/Model/car_model.dart';
import 'package:over_taxi/services/Api.dart';
import 'package:over_taxi/services/assistantmethod.dart';

class ControllerMap extends GetxController {
  @override
  void onInit() {
    getCar();
    super.onInit();
  }

  var pickupLocation = ''.obs;
  var dropoffLocation = ''.obs;
  var state = ''.obs;
  var positionlatA = 0.0.obs;
  var positionlongA = 0.0.obs;
  var positionlatB = 0.0.obs;
  var positionlongB = 0.0.obs;
  var carss = <Car>[].obs;

  getNamepickupLocation(context) async {
    pickupLocation.value = (await AssistantMehod.searchCoordinateAddress(
        positionlatA.value, positionlongA.value, context, state.value))!;
  }

  getNamedropoffLocation(context) async {
    dropoffLocation.value = (await AssistantMehod.searchCoordinateAddress(
        positionlatB.value, positionlongB.value, context, state.value))!;
  }

  getCar() async {
    var cars = await ApiServices.getcar();
    carss.value = cars!;
  }
}
