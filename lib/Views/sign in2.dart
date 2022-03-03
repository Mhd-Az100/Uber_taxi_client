import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:over_taxi/Views/verification2.dart';
import 'package:over_taxi/constant/styleText.dart';
import 'package:over_taxi/main.dart';
import 'package:over_taxi/widget/loginButton.dart';

//Declaring a StatefulWidget

//Now the Signin Class is StatefulWidget with an initialized State
class Signin2 extends StatefulWidget {
  @override
  _Signin2State createState() => _Signin2State();
}

class _Signin2State extends State<Signin2> {
  TextEditingController namectrl = TextEditingController();
  TextEditingController emailctrl = TextEditingController();
  TextEditingController phonectrl = TextEditingController();
  TextEditingController passwordctrl = TextEditingController();

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
          padding: EdgeInsets.only(top: 50),
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
                            onSaved: (val) {
                              namectrl.text = val!;
                            },
                            size: size,
                            label: 'الاسم',
                            ctrl: namectrl,
                            keyboardtype: TextInputType.text,
                            validator: validateName,
                          ),
                          inputText(
                            onSaved: (val) {
                              emailctrl.text = val!;
                            },
                            size: size,
                            label: 'الإيميل',
                            ctrl: emailctrl,
                            keyboardtype: TextInputType.text,
                            validator: validateEmail,
                          ),
                          inputText(
                            onSaved: (val) {
                              phonectrl.text = val!;
                            },
                            size: size,
                            label: 'موبايل',
                            ctrl: phonectrl,
                            keyboardtype: TextInputType.visiblePassword,
                            validator: validateMobile,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                          inputText(
                            onSaved: (val) {
                              passwordctrl.text = val!;
                            },
                            size: size,
                            label: 'كلمة المرور',
                            ctrl: passwordctrl,
                            keyboardtype: TextInputType.visiblePassword,
                            validator: validatePassword,
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
                    registerNewUser(context);
                  }
                },
                text: 'تسجيل الدخول',
              ),
              SizedBox(
                height: 30,
              ),

              InkWell(
                onTap: () {
                  Get.offAll(Verfication2());
                },
                child: Text(
                  'تسجيل الدخول',
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
    @required void Function(String?)? onSaved,
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
      margin: EdgeInsetsDirectional.only(end: 25, start: 25, top: 5, bottom: 5),
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
        onSaved: onSaved,
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
  registerNewUser(BuildContext context) async {
    final User? firenbaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailctrl.text, password: passwordctrl.text)
            .catchError((error) {
      print('Eamailllll${emailctrl.text}');
      displayToastMessage(error.toString(), context);
    }))
        .user;
    if (firenbaseUser != null) //user\ crated
    {
      //save user info to database

      usersRef.child(firenbaseUser.uid);
      Map userDataMap = {
        "name": namectrl.text.trim(),
        "email": emailctrl.text.trim(),
        "phone": phonectrl.text.trim(),
      };
      usersRef.child(firenbaseUser.uid).set(userDataMap);
      displayToastMessage("تم انشاء حسابك", context);
      Get.offAll(Verfication2());
    } else {
      Navigator.pop(context);

      displayToastMessage("لم يتم انشاء مستخدم", context);
    }
  }
//===========================================================

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.red[200]);
  }

  String? validateMobile(String? value) {
    if (value!.length == 0)
      return 'Please enter PhoneNumber';
    else
      return null;
  }

  String? validateName(String? value) {
    //allowed characters :
    // 1. from a - z
    // 2.  from A - Z

    String pattern = r'^[a-zA-Zا-ي ]+$';
    if (value!.length == 0) //if empty
      return 'Please enter Name';

    //if any unallowed charcter has been entered (like # $ % etc..)
    else if (!RegExp(pattern).hasMatch(value)) {
      return 'Not allowed character';
    } else
      return null; //Then the input is correct.
  }

  String? validateEmail(String? value) {
    if (value!.length == 0)
      return 'Please enter your Email';
    else if (!EmailValidator.validate(value))
      return 'Please enter a valid Email';
    else
      return null;
  }

  String? validatePassword(String? value) {
    if (value!.length == 0)
      return 'Please enter PhoneNumber';
    else if (value.length <= 5) {
      return 'Please enter 6 char ';
    }
    return null;
  }
}
