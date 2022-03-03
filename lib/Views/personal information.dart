import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:over_taxi/constant/colors.dart';
import 'package:over_taxi/constant/styleText.dart';
import 'package:over_taxi/widget/loginButton.dart';

import 'Home.dart';

class PersonalInfo extends StatefulWidget {
  //Three Controllers to use and to save values in them to be used later.
  @override
  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  var namectrl = TextEditingController();

  var lastnamectrl = TextEditingController();

  var agectrl = TextEditingController();

  var formkey = GlobalKey<FormState>();

  String? uid;
  @override
  void initState() {
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
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
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 39.1),
                    child: Text(
                      'creat'.tr,
                      style: kstartText,
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                //Modified way usingthe 'inputText' Function with the following parameters:
                // Size : passing the Size of the screen (Height, Width, etc..).
                // Label: The labelText that will show.
                // ctrl : The Controller that will be passed.
                // keyboardtype: The Type of the allowed keyboard to be used.
                // validator: Validation Function for each one depending on the conditions of each field.
                inputText(
                  size: size,
                  label: 'name'.tr,
                  ctrl: namectrl,
                  keyboardtype: TextInputType.text,
                  validator: validateName,
                ),
                inputText(
                  size: size,
                  label: 'lastname'.tr,
                  ctrl: namectrl,
                  keyboardtype: TextInputType.text,
                  validator: validateName,
                ),
                inputText(
                  size: size,
                  label: 'age'.tr,
                  ctrl: namectrl,
                  keyboardtype: TextInputType.number,
                  validator: validateAge,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(2),

                    //using the Optional Validator to allow Digits only without comma or dot
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                SizedBox(
                  height: size.height * 0.12,
                ),
                //Centering the Login Button
                Center(
                  child: LoginButton(
                    onPressed: () {
                      //Now when pressed, it will validate the name, last name and Age
                      if (formkey.currentState!.validate()) {
                        Get.defaultDialog(
                            title: "activeAccount".tr,
                            titleStyle: kWelcomeLogin,
                            middleText: '',
                            content: Image.asset('img/true.png'),
                            confirmTextColor: Colors.white,
                            buttonColor: green,

                            //When ok is pressed, it will go to the Home Screen.
                            onConfirm: () {
                              Get.offAll(Home());
                            });
                      }
                    },
                    text: 'signIn'.tr,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget inputText({
    //All Required so it must be passed.
    @required Size? size,
    @required String? label,
    @required TextEditingController? ctrl,
    @required TextInputType? keyboardtype,
    @required String? Function(String?)? validator,
    List<TextInputFormatter>?
        inputFormatters, //Optional input validator (Used for Age).
  }) {
    return Container(
      padding: EdgeInsetsDirectional.only(start: 10),
      margin:
          EdgeInsetsDirectional.only(end: 25, start: 25, top: 12, bottom: 12),
      width: size!.width,
      height: 65,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 15,
              offset: Offset(0, 5), // changes position of shadow
            ),
          ]),
      child: TextFormField(
        inputFormatters: inputFormatters,
        keyboardType: keyboardtype,
        validator: validator,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: -1),
          labelText: label,
          labelStyle: TextStyle(fontSize: 20),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  String? validateName(String? value) {
    //allowed characters :
    // 1. from a - z
    // 2.  from A - Z

    String pattern = r'^[a-zA-Zا-ي]+$';
    if (value!.length == 0) //if empty
      return 'Please enter Name';

    //if any unallowed charcter has been entered (like # $ % etc..)
    else if (!RegExp(pattern).hasMatch(value)) {
      return 'Not allowed character';
    } else
      return null; //Then the input is correct.
  }

  String? validateAge(String? value) {
    if (value!.length == 0)
      return 'Please enter Age';
    else if (int.parse(value) > 99 || int.parse(value) < 13)
      return 'Range of Age is between 13-99';
    else
      return null;
  }
}
