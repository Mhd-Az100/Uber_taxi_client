import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:over_taxi/Views/verification.dart';
import 'package:over_taxi/constant/colors.dart';
import 'package:over_taxi/constant/styleText.dart';
import 'package:over_taxi/widget/loginButton.dart';

import 'Home.dart';

//Declaring a StatefulWidget

//Now the Signin Class is StatefulWidget with an initialized State
class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  var phonectrl = TextEditingController();

  var formkey = GlobalKey<FormState>();

  var codenumber;

  String _selectedLng = 'en';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context)
        .size; //Getting the Screen Size despite the device type
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      // ),
      //SingleChildScollView in order to avoid error when the keyboard shows.
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 45),
          width: size
              .width, //Declaring that the container width is as much as the screen.
          color: Colors.white,
          child: Column(
            children: [
              Image.asset('img/logoscreen.png'), //Adding the OVER image
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 39.1),
                  child: Text(
                    'welcome2'.tr,
                    style: kstartText,
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.05,
              ),
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 46.0),
                      child: Text(
                        'welcome'.tr,
                        style: kWelcomeLogin,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 53.0, bottom: 27),
                      child: Text(
                        'transporting'.tr,
                        style: kNavigateLogin,
                      ),
                    ),
                    //TextInputField for Inserting the Number.
                    numberLogin(size),
                    selectLanguage(),
                  ],
                ),
              ),
              SizedBox(
                height: 100,
              ),
              //login button
              LoginButton(
                //A Button will show the Text ارسال كود and when Pressed will lead to Verification screen.
                onPressed: () {
                  print('=================================');
                  print(codenumber);
                  print(phonectrl.text);
                  print('=================================');

                  if (codenumber == null) {
                    Fluttertoast.showToast(
                        msg: 'toatContryChoos'.tr,
                        backgroundColor: Colors.red[200]);
                    return;
                  }
                  if (codenumber != '+963') {
                    Fluttertoast.showToast(
                        msg: 'toatContry'.tr, backgroundColor: Colors.red[200]);
                    return;
                  }
                  var map = {'code': codenumber, 'phone': phonectrl.text};
                  if (formkey.currentState!.validate()) {
                    Get.offAll(() => Verfication(), arguments: map);
                  }
                  //Using Get Library to Move instead of Navigator.
                },
                text: 'signIn'.tr,
              ),
              // enter visitor
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: TextButton(
                    onPressed: () {
                      Get.offAll(Home());
                    },
                    child: Text(
                      'enterVisiter'.tr,
                      style: ktextvisitor,
                    )),
              ),
            ],
          ),
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

  Widget numberLogin(Size size) {
    return Form(
      key: formkey,
      child: Container(
        padding: EdgeInsetsDirectional.only(start: 10),
        margin: EdgeInsetsDirectional.only(end: 20, start: 20),
        width: size.width,
        height: 65,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 15,
                offset: Offset(0, 5), // Changes position of shadow on the box.
              ),
            ]),
        child: Row(
          //Row for the hint text (The Number) and the Country Flag.
          children: [
            Expanded(
              child: TextFormField(
                controller: phonectrl,
                validator: validateMobile,
                //Text Field which accepts input.
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  errorStyle: TextStyle(
                    fontSize: 9.0,
                  ),
                  hintText: 'enterPhone'.tr,
                  border: InputBorder
                      .none, //To get rid of the Line under the HintText.
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: 105,
                child: CountryListPick(
                  appBar: AppBar(
                    backgroundColor: green,
                  ),
                  theme: CountryTheme(
                    showEnglishName: true,
                    isShowTitle: false,
                  ),
                  //The initial Country is Syria +963

                  //When Choosing another Country (Changing), will print the New Country name,code,dialCode,flagUri
                  onChanged: (CountryCode? code) {
                    codenumber = code!.dialCode;
                    print(code.name);
                    print(code.code);
                    print(code.dialCode);
                    print(code.flagUri);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? validateMobile(String? value) {
    if (value!.length == 0)
      return 'Please enter PhoneNumber';
    else
      return null;
  }
}
