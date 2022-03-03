import 'package:over_taxi/Model/nearbyAvailableDrivers_model.dart';

class GeoFireAssistant {
  // ! this function use with geofire package
  // ? param key for nearby driver
  // * remove driver from nearby list
  static List<NearbyAvailableDrivers> nearbyAvailableDriversList = [];
  static void removeDriverFromList(String key) {
    int index =
        nearbyAvailableDriversList.indexWhere((element) => element.key == key);
    nearbyAvailableDriversList.remove(index);
  }

  //====================================================================//
  // ! this function use with geofire package
  // * update nearby driver list
  static void updateDriverNearbyLocation(NearbyAvailableDrivers drivers) {
    int index = nearbyAvailableDriversList
        .indexWhere((element) => element.key == drivers.key);
    nearbyAvailableDriversList[index].latitude = drivers.latitude;
    nearbyAvailableDriversList[index].longitude = drivers.longitude;
  }
}
