import 'package:feuerwehrstatus/einsaetze.dart';
import 'package:feuerwehrstatus/list.dart';
import 'package:feuerwehrstatus/login.dart';
import 'package:feuerwehrstatus/notifications.dart';
import 'package:feuerwehrstatus/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  // run the app
  runApp(const ListPage());

  // hide status bar for android
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom
  ]);  // to only hide the status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  initializeNotifications();
}

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: const MyStatusPage(),
    );
  }
}

class MyStatusPage extends StatefulWidget {
  const MyStatusPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyStatusPage> createState() => _MyStatusPageState();
}

class _MyStatusPageState extends State<MyStatusPage> {

Future<int> updatestatus(currentstatus, user_id) async {
  final response = await http.post(Uri.parse("http://localhost/feuerwehrstatus/updatestatus.php"), body: {
    "currentstatus": currentstatus,
    "user_id": user_id.toString()
  });
  return response.statusCode;
}

  @override
  Widget build(BuildContext context) {
  // Full screen width and height
  double originalwidth = MediaQuery.of(context).size.width;
  double originalheight = MediaQuery.of(context).size.height;

  // Height (without SafeArea)
  var padding = MediaQuery.of(context).viewPadding;
  double height1 = originalheight - padding.top - padding.bottom;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Status',
          style: TextStyle(fontSize: 50),
          )
        ),
        leading: FloatingActionButton(
          heroTag: null,
          elevation: 0,
          hoverElevation: 0,
          hoverColor: Colors.transparent,
          onPressed: () {
            Navigator.push(
              context, 
              PageRouteBuilder(
                pageBuilder: (BuildContext context, Animation<double> animation1, Animation<double> animation2) {
                  return MyListPage();
                },
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: const Icon(
            Icons.people_alt_rounded,
            size: 40,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 0.0),
            child: FloatingActionButton(
            heroTag: null,
            elevation: 0,
            hoverElevation: 0,
            hoverColor: Colors.transparent,
              onPressed: () {
                Navigator.push(
                  context, 
                  PageRouteBuilder(
                    pageBuilder: (BuildContext context, Animation<double> animation1, Animation<double> animation2) {
                      return EinsaetzePage(TimeFrame.running);
                    },
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: const Icon(
                Icons.wb_twilight_outlined,
                size: 40.0,
              ),
            )
          ),
        ],
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: originalwidth/1.5,
                height: height1/8,
                child: FloatingActionButton.extended(
                  heroTag: null,
                  backgroundColor: Colors.blue,
                  onPressed: () {
                    updatestatus('anfahrt', 1).then((value) => {
                      if (value > 200) {
                        showOverlayNotification((context) {
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: SafeArea(
                              child: ListTile(
                                leading: SizedBox.fromSize(
                                    size: const Size(40, 40),
                                    child: ClipOval(
                                        child: Container(
                                      color: Colors.black,
                                    ))),
                                title: const Text('Status set'),
                                subtitle: const Text('Succesfully set status to Anfahrt')
                              ),
                            ),
                          );
                        }, duration: const Duration(milliseconds: 4000))
                      }
                    });
                  },
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.drive_eta, size: originalwidth/17),
                      SizedBox(width: originalwidth*0.010),
                      Text(
                        'Anfahrt',
                        style: TextStyle(fontSize: originalwidth/17, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: originalwidth/1.5,
                height: height1/8,
                child: FloatingActionButton.extended(
                  heroTag: null,
                  backgroundColor: Colors.red,
                  onPressed: () {
                  },
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.house, size: originalwidth/17),
                      SizedBox(width: originalwidth*0.01),
                      Text(
                        'im Feuerwehrhaus',
                        style: TextStyle(fontSize: originalwidth/17, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: originalwidth/1.5,
                height: height1/8,
                child: FloatingActionButton.extended(
                  heroTag: null,
                  backgroundColor: Colors.red,
                  onPressed: () {
                  },
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fire_truck_outlined, size: originalwidth/17),
                      SizedBox(width: originalwidth*0.01),
                      Text(
                        'im Einsatz',
                        style: TextStyle(fontSize: originalwidth/17, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: originalwidth/1.5,
                height: height1/8,
                child: FloatingActionButton.extended(
                  heroTag: null,
                  backgroundColor: Colors.green,
                  onPressed: () {
                    Navigator.push(
                      context, 
                      PageRouteBuilder(
                        pageBuilder: (BuildContext context, Animation<double> animation1, Animation<double> animation2) {
                          return MyLoginPage();
                        },
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    FlutterNativeSplash.remove();
                  },
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: originalwidth/17),
                      SizedBox(width: originalwidth*0.01),
                      Text(
                        'abmelden',
                        style: TextStyle(fontSize: originalwidth/17, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, 
            PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation1, Animation<double> animation2) {
                return MySettingsPage(NotiSound.airhorn);
              },
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
        child: const Icon(Icons.settings),
      ),
    );
  }
}
