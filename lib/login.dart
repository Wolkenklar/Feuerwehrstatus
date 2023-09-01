// ignore_for_file: library_private_types_in_public_api
import 'package:feuerwehrstatus/main.dart';
import 'package:flutter/material.dart';
import 'package:blur/blur.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:overlay_support/overlay_support.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Status Login',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyLoginPage(),
    ));
  }
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {  
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<int> login(username, password) async {
    final response = await http.post(Uri.parse("http://localhost/feuerwehrstatus/login.php?username=$username&password=$password"), body: {
      "username": username,
      "password": password
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

  double height = originalwidth;

  if(originalwidth < 890){
      double height = originalwidth/4;
  } else { 
      double height = originalwidth;
  }

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Center(
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    child: Image.asset('assets/fflogo.png', width: originalwidth,).blurred(
                      blur: 10,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image.asset('assets/fflogo.png',scale: 4),
                      Text('Anmeldung',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: originalwidth/10.5,
                        fontWeight: FontWeight.bold,
                        ),
                      maxLines: 1,
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: originalwidth/2,
                        child: TextField(
                          style: const TextStyle(fontSize: 50),
                          controller: _username,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Colors.red,
                            labelText: "Benutzername",
                            labelStyle: TextStyle(fontSize: 25)
                          ),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          autofillHints: [AutofillHints.username],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: originalwidth/2,
                        child: TextField(
                          obscureText: true,
                          style: const TextStyle(fontSize: 50),
                          controller: _password,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Colors.red,
                            labelText: "Passwort",
                            labelStyle: TextStyle(fontSize: 25)
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          autofillHints: [AutofillHints.password],
                          onEditingComplete: () => TextInput.finishAutofillContext(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: originalwidth/2.5,
                        height: height1/12.5,
                        child: FloatingActionButton.extended(
                          onPressed: () {
                            login(_username.text, _password.text).then((value) => {
                              if (value == 200) {
                                Navigator.push(
                                  context, 
                                  PageRouteBuilder(
                                    pageBuilder: (BuildContext context, Animation<double> animation1, Animation<double> animation2) {
                                      return MyStatusPage();
                                    },
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                ),
                                showOverlayNotification((context) {
                                  return const Card(
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    child: SafeArea(
                                      child: ListTile(
                                        title: Text('Anmeldung', textAlign: TextAlign.center, maxLines: 1),
                                        subtitle: Text('Sie haben sich angemeldet!', textAlign: TextAlign.center,)
                                      ),
                                    ),
                                  );
                                }, duration: const Duration(milliseconds: 4000), position: NotificationPosition.bottom)
                              } else {
                                showOverlayNotification((context) {
                                  return const Card(
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    child: SafeArea(
                                      child: ListTile(
                                        title: Text('Anmeldung', textAlign: TextAlign.center,),
                                        subtitle: Text('Falscher Benutzername oder Passwort!', textAlign: TextAlign.center,)
                                      ),
                                    ),
                                  );
                                }, duration: const Duration(milliseconds: 4000), position: NotificationPosition.bottom)
                              }
                            });
                          },
                          label: Text('anmelden',
                          style: TextStyle(
                            fontSize: originalwidth/25,
                            fontWeight: FontWeight.bold
                            )
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const Stack(
              children: [
              ],
            )
          ],
        ),
      ),
    );
  }
}