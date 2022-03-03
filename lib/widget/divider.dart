import 'package:flutter/material.dart';
import 'package:over_taxi/constant/colors.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: Colors.black,
      thickness: 1,
    );
  }
}
