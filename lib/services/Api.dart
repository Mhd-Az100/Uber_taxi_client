import 'package:http/http.dart' as http;
import 'package:over_taxi/Model/car_model.dart';
import 'dart:convert';

import 'package:over_taxi/utils/url.dart';

class ApiServices {
  // * get
  // ! return list of car
  static Future<List<Car>?> getcar() async {
    List<Car> catlist = [];

    http.Response res = await http.get(Uri.parse('$domin/api/carclasses'));
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);

      for (var item in body) {
        catlist.add(Car.fromJson(item));
      }

      return catlist;
    } else {
      print('statuscode=${res.statusCode}');
      return null;
    }
  }

  // * get from url
  // ? used with google map api
  // ! return data
  static Future<dynamic> getRequsest(String url) async {
    http.Response res = await http.get(Uri.parse(url));
    try {
      print('acces to request');

      if (res.statusCode == 200) {
        String body = res.body;
        var data = jsonDecode(body);
        return data as Map<String, dynamic>;
      } else {
        return "failed";
      }
    } catch (e) {
      print('error request $e');
      return "failed";
    }
  }
}
