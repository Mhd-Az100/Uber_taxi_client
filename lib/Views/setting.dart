import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _selectedLng = 'ar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.fromLTRB(16, 70, 16, 0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Setting_Language'.tr,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.7)),
                      ]),
                  padding: EdgeInsets.only(left: 10),
                  height: 50,
                  width: double.infinity,
                  child: selectLanguage()),
            ),
          ],
        ),
      ),
    );
  }

  Widget selectLanguage() {
    return Center(
      child: DropdownButton<dynamic>(
        items: [
          DropdownMenuItem(
            child: Text('العربية'),
            value: 'ar',
          ),
          DropdownMenuItem(
            child: Text('English'),
            value: 'en',
          ),
          DropdownMenuItem(
            child: Text('Russia'),
            value: 'ru',
          ),
        ],
        value: _selectedLng,
        onChanged: (value) {
          setState(() {
            _selectedLng = value;
          });
          Get.updateLocale(Locale(_selectedLng));
        },
      ),
    );
  }
}
