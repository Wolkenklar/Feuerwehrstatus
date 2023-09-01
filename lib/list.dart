// ignore_for_file: library_private_types_in_public_api

import 'package:feuerwehrstatus/main.dart';
import 'package:feuerwehrstatus/login.dart';
import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Status Login',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyListPage(),
    );
  }
}

class MyListPage extends StatefulWidget {
  const MyListPage({super.key});

  @override
  _MyListPageState createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
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
        title: const Row(
          children: [
            Center(
              child: Text('Mitglieder',
              style: TextStyle(fontSize: 50),
              )
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
    body: Center(
      child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 2, right: 2),
              child: SizedBox(
                height: height1,
                width: originalwidth/2,
                child: Table(
                  border: TableBorder.all(
                    color: Colors.black,
                    style: BorderStyle.solid,
                    width: 2
                  ),
                  children: const [
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Column(children: [Text('Vorname', maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(children: [Text('Nachname', maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(children: [Text('Status', maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(children: [Text('Einsatz', maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]),
                        ),
                      ]
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(children: [Text('Max', maxLines: 1, style: TextStyle(fontSize: 15))]),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(children: [Text('Mustermann', maxLines: 1, style: TextStyle(fontSize: 15))]),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(children: [Text('Feuerwehr', maxLines: 1, style: TextStyle(fontSize: 15))]),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(children: [Text('-', maxLines: 1, style: TextStyle(fontSize: 15))]),
                        ),
                      ]
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}