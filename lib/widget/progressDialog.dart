import 'package:flutter/material.dart';
import 'package:over_taxi/constant/colors.dart';
import 'package:over_taxi/constant/styleText.dart';

class ProgressDialog extends StatelessWidget {
  String? message;
  ProgressDialog({this.message});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: green.withOpacity(0.5),
      child: Container(
        margin: EdgeInsets.all(50),
        padding: EdgeInsets.only(top: 10, bottom: 10, right: 25, left: 25),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
            SizedBox(
              width: 26,
            ),
            Expanded(
              child: Text(
                message!,
                style: ktextdialog,
              ),
            )
          ],
        ),
      ),
    );
  }
}
