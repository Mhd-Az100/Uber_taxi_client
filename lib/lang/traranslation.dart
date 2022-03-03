import 'package:get/get.dart';
import 'package:over_taxi/lang/ar.dart';
import 'package:over_taxi/lang/en.dart';
import 'package:over_taxi/lang/ru.dart';

class Translation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': en,
        'ar': ar,
        'ru': ru,
      };
}
