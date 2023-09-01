// ignore_for_file: library_private_types_in_public_api

import 'package:feuerwehrstatus/main.dart';
import 'package:feuerwehrstatus/login.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SettingsPage extends StatelessWidget {
  final NotiSound notiSound;
  const SettingsPage(this.notiSound, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Status Login',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MySettingsPage(notiSound),
    );
  }
}

enum NotiSound {
  airhorn("Nebelhorn"),
  police("Martinshorn"),
  redalert("Alarmstufe Rot");

  final String name;
  const NotiSound(this.name);
}

class MySettingsPage extends StatefulWidget {
  NotiSound notiSound;
  MySettingsPage(this.notiSound, {super.key});

  @override
  _MySettingsPageState createState() => _MySettingsPageState();
}


class _MySettingsPageState extends State<MySettingsPage> {

  
  void notificationsound(String? selectedValue) {
    if (selectedValue == 'airhorn') {
      widget.notiSound = NotiSound.airhorn;
    } else if (selectedValue == 'police') {
      widget.notiSound = NotiSound.police;
    } else if (selectedValue == 'redalert') {
      widget.notiSound = NotiSound.redalert;
    }
    setState(() {
      
    });
  }

  void testnotification() {
    return;
  }

  @override
  Widget build(BuildContext context) {
    
    // Full screen width and height
    double originalwidth = MediaQuery.of(context).size.width;
    double originalheight = MediaQuery.of(context).size.height;

    // Height (without SafeArea)
    var padding = MediaQuery.of(context).viewPadding;
    double height1 = originalheight - padding.top - padding.bottom;

    return Scaffold(
      appBar: AppBar(
        leading: FloatingActionButton(
          elevation: 0,
          hoverElevation: 0,
          backgroundColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onPressed: () {
            Navigator.push(
              context, 
              PageRouteBuilder(
                pageBuilder: (BuildContext context, Animation<double> animation1, Animation<double> animation2) {
                  return MyStatusPage();
                },
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: const Icon(
            Icons.arrow_back,
            size: 40,
          ),
        ),
        title: const Text('Settings',
        style: TextStyle(fontSize: 50),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('Notification Sound', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: DropdownButton(
                    iconEnabledColor: Colors.red,
                    underline: Container(),
                    isExpanded: false,
                    alignment: Alignment.center,
                    style: const TextStyle(fontSize: 30, color: Colors.black),
                    hint: Text(widget.notiSound.name, style: const TextStyle(color: Colors.black)),
                    items: [
                      DropdownMenuItem(value: "airhorn", alignment: Alignment.center, child: Container(child: Text('Nebelhorn', style: TextStyle(fontSize: 30)))),
                      DropdownMenuItem(value: "police", alignment: Alignment.center, child: Container(child: Text('Martinshorn', style: TextStyle(fontSize: 30)))),
                      DropdownMenuItem(value: "redalert", alignment: Alignment.center, child: Container(child: Text('Alarmstufe Rot', style: TextStyle(fontSize: 30)))),
                    ],
                    onChanged: notificationsound
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    width: 200,
                    child: FloatingActionButton.extended(
                      onPressed: testnotification,
                      label: Text('Send Test-Notification'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      )
    );
  }
}