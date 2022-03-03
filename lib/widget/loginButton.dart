import 'package:flutter/material.dart';
import 'package:over_taxi/constant/styleText.dart';
import '../constant/colors.dart';

class LoginButton extends StatelessWidget {
  Function()? onPressed;
  String? text;
  LoginButton({@required this.onPressed, @required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: green,
        borderRadius: BorderRadius.circular(4),
      ),
      // height: 41,
      child: TextButton(
          onPressed: onPressed,
          child: Text(
            text!,
            style: kbutton,
          )),
    );
  }
}
