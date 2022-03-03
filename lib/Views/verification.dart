import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:over_taxi/constant/styleText.dart';

import 'Home.dart';

class Verfication extends StatefulWidget {
  @override
  _VerficationState createState() => _VerficationState();
}

class _VerficationState extends State<Verfication> {
  var scaffoldkey = GlobalKey<ScaffoldState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  // String verificationID = "";
  String? _verificationCode;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //Using Scaffold Widget to get access to AppBar and Body.
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0, //No Shadow Below appBar.
        backgroundColor: Colors.white,
      ),

      //SingleChildScollView in order to avoid error when the keyboard shows.
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          color: Colors.white,
          child: Column(
            children: [
              Image.asset('img/logoscreen.png'), //Adding the OVER image
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 39.1),
                  child: Text(
                    'verify'.tr,
                    style: kstartText,
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.15,
              ),
              Container(
                //The Width of this Container is all the screen, same as Size.width.
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'sendCode'.tr,
                          style: ktextverfication,
                        ),
                        // Text(
                        //This Number should be the same as the number the user has entered, using Controller?
                        // '${Get.arguments['phone']}',
                        // style: knumberverfication,
                        // ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    //verification Code OTP, further Documentation is below
                    otpCode(size)
                  ],
                ),
              ),
              SizedBox(
                height: 100,
              ),
              //Resend the Code

              //InkWell can insert a Text with a transperant Box
              InkWell(
                child: Text(
                  'resend'.tr,
                  style: ktextvisitor,
                ),
                //When tapped, it will resend a message to the number that the user has entered
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding otpCode(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      // Directionality is a widget that determine the direction of the input text
      child: Directionality(
        textDirection: TextDirection.ltr, //The input is Left to Right

        //OTPTextField is a One Time Password package for verification Number.
        child: OTPTextField(
          width: size.width, //The Width is the all the screen.
          length: 4, //4 Numbers will be Enterd

          //Even Space between the Lines (Children)
          textFieldAlignment: MainAxisAlignment.spaceAround,

          //The shape is an Underline to enter the Numbers
          fieldStyle: FieldStyle.underline,

          //The Keyboard type is Number, so the user won't be able to enter any but numbers.
          keyboardType: TextInputType.number,
          outlineBorderRadius: 4,
          fieldWidth: 50,
          style: TextStyle(color: Colors.black),
          otpFieldStyle: OtpFieldStyle(
            backgroundColor: Colors.white,
            disabledBorderColor: Colors.black,
            enabledBorderColor: Colors.black,
          ),
          onChanged: (k) {},

          //When the user finishes entering the code, it will be printed, if true (validating) it will show a
          //Dialog which shows the following.
          onCompleted: (n) {
            Get.offAll(Home());
          },

          //  async {

          // try {
          //   print(n);

          //   await FirebaseAuth.instance
          //       .signInWithCredential(PhoneAuthProvider.credential(
          //           verificationId: _verificationCode!, smsCode: n))
          //       .then((value) async {
          //     if (value.user != null) {
          //       print('pass to home');
          //       Get.defaultDialog(
          //         title: "تم التفيل بنجاح", //Shows a leading Title
          //         titleStyle: kWelcomeLogin, //With the following style
          //         middleText: '', //No Middle Text
          //         content: Image.asset('img/true.png'), //Shows then an image
          //         confirmTextColor: Colors.white,
          //         buttonColor: green, //the OK button's color

          //         //When OK is pressed it will lead to PersonalInfo Screen
          //         onConfirm: () {
          //           Get.offAll(PersonalInfo());
          //         },
          //       );
          //     }
          //   });
          // } catch (e) {
          //   FocusScope.of(context).unfocus();
          //   Fluttertoast.showToast(msg: 'invlid code');
          // }

          // c.login(n);
          // },
        ),
      ),
    );
  }

  // _verifyphonbe() async {
  //   print('++++++++++++++++++++++++++++++++');
  //   print(Get.arguments['code']);
  //   print(Get.arguments['phone']);
  //   print('++++++++++++++++++++++++++++++++');
  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //       phoneNumber: '${Get.arguments['code']}${Get.arguments['phone']}',
  //       verificationCompleted: (PhoneAuthCredential credential) async {
  //         await FirebaseAuth.instance
  //             .signInWithCredential(credential)
  //             .then((value) async {
  //           if (value.user != null) {
  //             print("user logged in");
  //           }
  //         });
  //       },
  //       verificationFailed: (FirebaseAuthException e) {
  //         print(e.message);
  //       },
  //       codeSent: (String verificationID, int? resedToken) async {
  //         setState(() {
  //           _verificationCode = verificationID;
  //         });
  //       },
  //       codeAutoRetrievalTimeout: (String verificationID) {
  //         setState(() {
  //           _verificationCode = verificationID;
  //         });
  //       });
  //   timeout:
  //   Duration(seconds: 60);
  // }

  @override
  void initState() {
    super.initState();
    // _verifyphonbe();
  }
}
