import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:over_taxi/Views/sign%20in2.dart';
import 'package:over_taxi/constant/styleText.dart';
import 'package:over_taxi/main.dart';
import 'package:over_taxi/widget/loginButton.dart';

import 'Home.dart';

//Declaring a StatefulWidget

//Now the Signin Class is StatefulWidget with an initialized State
class Verfication2 extends StatefulWidget {
  @override
  _Verfication2State createState() => _Verfication2State();
}

class _Verfication2State extends State<Verfication2> {
  var emailctrl = TextEditingController();

  var passwordctrl = TextEditingController();

  bool ispass = true;

  var formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context)
        .size; //Getting the Screen Size despite the device type
    return Scaffold(
      backgroundColor: Colors.white,

      //SingleChildScollView in order to avoid error when the keyboard shows.
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 40),
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
                    '',
                    style: kstartText,
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 46.0),
                      child: Text(
                        'مرحبا, سُعدنا بلقائك',
                        style: kWelcomeLogin,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 53.0, bottom: 27),
                      child: Text(
                        'تنقل مع تكسي اوفر',
                        style: kNavigateLogin,
                      ),
                    ),
                    Form(
                      key: formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          //Modified way usingthe 'inputText' Function with the following parameters:
                          // Size : passing the Size of the screen (Height, Width, etc..).
                          // Label: The labelText that will show.
                          // ctrl : The Controller that will be passed.
                          // keyboardtype: The Type of the allowed keyboard to be used.
                          // validator: Validation Function for each one depending on the conditions of each field.
                          inputText(
                            size: size,
                            label: 'الإيميل',
                            ctrl: emailctrl,
                            keyboardtype: TextInputType.text,
                            validator: validateEmail,
                          ),
                          inputText(
                            size: size,
                            label: 'كلمة المرور',
                            ctrl: passwordctrl,
                            keyboardtype: TextInputType.visiblePassword,
                            validator: (val) => val!.length == 0
                                ? 'Please Enter Your Password'
                                : null,
                            icon: Icons.lock,
                            ispassword: ispass,
                            suffixIcon: ispass
                                ? Icons.visibility
                                : Icons.visibility_off,
                            suffixPressed: () {
                              setState(() {
                                ispass = !ispass;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    //TextInputField for Inserting the Number.
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //login button
              LoginButton(
                //A Button will show the Text ارسال كود and when Pressed will lead to Verification screen.
                onPressed: () {
                  if (formkey.currentState!.validate()) {
                    loginAndAuthenticateUser(context);
                  }
                },
                text: 'تسجيل الدخول',
              ),
              SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () {
                  Get.offAll(Signin2());
                },
                child: Text(
                  'انشاء حساب جديد',
                  style: kmaptext,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              // enter visitor
            ],
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
    List<TextInputFormatter>? inputFormatters,
    //Optional input validator (Used for Age).
    IconData? icon,
    IconData? suffixIcon,
    bool ispassword = false,
    VoidCallback? suffixPressed,
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
        controller: ctrl,
        inputFormatters: inputFormatters,
        keyboardType: keyboardtype,
        validator: validator,
        decoration: InputDecoration(
          suffixIcon: suffixIcon != null
              ? IconButton(icon: Icon(suffixIcon), onPressed: suffixPressed)
              : null,
          contentPadding: EdgeInsets.symmetric(vertical: -1),
          labelText: label,
          labelStyle: TextStyle(fontSize: 20),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        obscureText: ispassword,
      ),
    );
  }

//=======================fire base auth create================

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void loginAndAuthenticateUser(BuildContext context) async {
    final User? firenbaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: emailctrl.text, password: passwordctrl.text)
            .catchError((error) {
      displayToastMessage(error.toString(), context);
    }))
        .user;
    if (firenbaseUser != null) //user\ crated
    {
      usersRef.child(firenbaseUser.uid).once().then((DataSnapshot snap) {
        if (snap.value != null) {
          Get.offAll(Home());

          displayToastMessage("you are logged-in now.", context);
        } else {
          _firebaseAuth.signOut();
          displayToastMessage(
              "No record exists for this user. Please create new account.",
              context);
        }
      });
    } else {
      displayToastMessage("خطأ بكلمة المرور او الايميل", context);
    }
  }
//===========================================================

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.red[200]);
  }

  String? validateEmail(String? value) {
    if (value!.length == 0)
      return 'Please enter your Email';
    else if (!EmailValidator.validate(value))
      return 'Please enter a valid Email';
    else
      return null;
  }
}
