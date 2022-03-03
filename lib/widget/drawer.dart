import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:over_taxi/Views/setting.dart';
import 'package:over_taxi/Views/verification2.dart';
import 'package:over_taxi/constant/styleText.dart';

import 'divider.dart';

class DrawerConst extends StatelessWidget {
  const DrawerConst({
    Key? key,
    required this.uName,
  }) : super(key: key);

  final String uName;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 255.0,
      child: Drawer(
        child: ListView(
          children: [
            //Drawer Header
            Container(
              height: 165.0,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Image.asset(
                      "img/user.png",
                      height: 65.0,
                      width: 65.0,
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(uName, style: kmaptext),
                        SizedBox(
                          height: 6.0,
                        ),
                        GestureDetector(
                            onTap: () {
                              // Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileTabPage()));
                            },
                            child: Text("visitUser".tr)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            DividerWidget(),

            SizedBox(
              height: 12.0,
            ),

            //Drawer Body Contrllers
            GestureDetector(
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context)=> HistoryScreen()));
              },
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "menu".tr,
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileTabPage()));
              },
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "visit".tr,
                  style: kmaptext,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context)=> AboutScreen()));
              },
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "about".tr,
                  style: kmaptext,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // FirebaseAuth.instance.signOut();
                // Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
              },
              child: ListTile(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Get.to(Settings());
                },
                leading: Icon(Icons.settings),
                title: Text(
                  "setting".tr,
                  style: kmaptext,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // FirebaseAuth.instance.signOut();
                // Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
              },
              child: ListTile(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Get.offAll(Verfication2());
                },
                leading: Icon(Icons.logout),
                title: Text(
                  "signout".tr,
                  style: kmaptext,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
