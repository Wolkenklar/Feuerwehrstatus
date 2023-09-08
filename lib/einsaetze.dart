// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:feuerwehrstatus/login.dart';
import 'package:feuerwehrstatus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:map_launcher/map_launcher.dart' as mlauncher;
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension StringExtension on String {
    String toTitleCase() {
      if (this.isEmpty) return this;

      List<String> split = this.split(" ");
      return split.where((e) => !e.isEmpty).map((e) => e[0].toUpperCase() + (e.length > 1 ? e.substring(1).toLowerCase() : "")).join(" ");
    }
}

class Koordinaten {
  double longitude;
  double latitude;

  Koordinaten(this.longitude, this.latitude);

  static Koordinaten parse(Map<String, dynamic> object) {
    return Koordinaten(
      object["lng"],
      object["lat"]
    );
  }
  
  @override
  String toString() {
    return "$longitude° $latitude°";
  }

}

class Adresse {
  String bezirk;
  String ort;
  String strasse;
  String hausnummer;

  Adresse(this.bezirk, this.ort, this.strasse, this.hausnummer);

  static Adresse parse(Map<String, dynamic> bezirk, Map<String, dynamic> object) {
    return Adresse(
      bezirk["text"],
      object["emun"],
      object["efeanme"],
      object["estnum"]
    );
  }

  @override
  String toString() {
    return "$bezirk => ${ort.toTitleCase()}" + (strasse.isEmpty ? "" : "\n${strasse.toTitleCase()} $hausnummer");
  }
}

class Feuerwehr {
  String id;
  String name;

  Feuerwehr(this.id, this.name);

  @override
  String toString() {
    return name;
  }
}

class Einsatz {
  String id;
  String einsatzort;
  Koordinaten koordinaten;
  int alarmstufe;
  // it's not late but VSC is shit so it shows an error anyway
  // fuck you vsc
  late DateTime startzeit;
  String einsatzname;
  String einsatzart;
  String einsatztyp;
  Adresse adresse;
  List<Feuerwehr> feuerwehren;

  static DateFormat format = DateFormat("E, d MMM yyyy HH:mm:ss Z");

  Einsatz(this.id, this.einsatzort, this.koordinaten, this.alarmstufe, String startzeit, this.einsatzname, this.einsatzart, this.einsatztyp, this.adresse, this.feuerwehren) {
    this.startzeit = format.parse(startzeit);
  }

  static Einsatz? parse(Map<String, dynamic> object) {
    try {
      return Einsatz(
        object["num1"],
        object["einsatzort"],
        Koordinaten.parse(object["wgs84"]),
        object["alarmstufe"] is int ? object["alarmstufe"] : int.parse(object["alarmstufe"]),
        object["startzeit"],
        object["einsatzsubtyp"]["text"],
        object["einsatzart"],
        object["einsatztyp"]["text"],
        Adresse.parse(object["bezirk"], object["adresse"]),
        object["feuerwehrenarray"].entries.map((e) => e.value).map<Feuerwehr>((e) => Feuerwehr(e["fwnr"], e["fwname"])).toList()
      );
    } catch (e) {
      // TODO: find out how to print that in one statement, lol
      print("Error trying to parse Einsatz!");
      print(e);
    }
  }
}

class EinsaetzePage extends StatelessWidget {
  final TimeFrame timeFrame;

  EinsaetzePage(this.timeFrame, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Status Login',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyEinsaetzePage(timeFrame),
    );
  }
}

enum TimeFrame {
  running("Laufend", "http://cf-intranet.ooelfv.at/webext2/api/getjson.php?scope=laufend&callback=callback"),
  sixhours("6 Stunden", "http://cf-intranet.ooelfv.at/webext2/api/getjson.php?scope=6stunden&callback=callback"),
  daily("Täglich", "http://cf-intranet.ooelfv.at/webext2/api/getjson.php?scope=taeglich&callback=callback"),
  twodays("2 Tage", "http://cf-intranet.ooelfv.at/webext2/api/getjson.php?scope=2tage&callback=callback");

  final String name;
  final String url;
  const TimeFrame(this.name, this.url);
}

class MyEinsaetzePage extends StatefulWidget {
  TimeFrame timeFrame;

  MyEinsaetzePage(this.timeFrame, {super.key});

  @override
  _MyEinsaetzePageState createState() => _MyEinsaetzePageState();
}

class _MyEinsaetzePageState extends State<MyEinsaetzePage> {
    final PageController controller = PageController();

  bool isLoading = true;
  List<dynamic> list = [];

  Future<void> _fetchData() async {
    try {
      final response = await http.get(
          // Uri.parse('http://cf-intranet.ooelfv.at/webext2/api/getjson.php?scope=laufend&callback=callback'));
          Uri.parse(widget.timeFrame.url));

      if (response.statusCode == 200) {
        String jsonResponse = response.body;
        int startIndex = jsonResponse.indexOf('{');
        int endIndex = jsonResponse.lastIndexOf('}');
        String jsonString = jsonResponse.substring(startIndex, endIndex + 1);
        Map<String, dynamic> data = json.decode(jsonString);

        setState(() {
          list = data['einsaetze']?.entries.map((e) => e.value["einsatz"]).map((e) => Einsatz.parse(e)).where((e) => e != null).toList() ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _startInfiniteLoop();
  }
  
  Future<void> _startInfiniteLoop() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 60));
      _fetchData();
    }
  }
  
  // Method to update itemList (simulated refresh)
  Future<void> refreshListView() async {
    await Future.delayed(const Duration(seconds: 2));
    _fetchData();
  }

  ScrollController listScrollController = ScrollController();


  void _scrollUp() {
    final position = listScrollController.position.minScrollExtent;
    listScrollController.jumpTo(position);
  }

  void changeeinsaetzetime(String? selectedValue) {
    if (selectedValue == 'laufend') {
      widget.timeFrame = TimeFrame.running;
    } else if (selectedValue == 'sechsstunden') {
      widget.timeFrame = TimeFrame.sixhours;
    } else if (selectedValue == 'taeglich') {
      widget.timeFrame = TimeFrame.daily;
    } else if (selectedValue == 'zweitage') {
      widget.timeFrame = TimeFrame.twodays;
    }
    _fetchData();
    _scrollUp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        leading: Positioned(
          left: 0,
          child: FloatingActionButton(
            elevation: 0,
            hoverElevation: 0,
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
        ),
        centerTitle: true,
        title: DropdownButton(
          iconEnabledColor: Colors.white,
          underline: Container(),
          focusColor: Colors.transparent,
          isExpanded: false,
          alignment: Alignment.center,
          style: const TextStyle(fontSize: 30, color: Colors.black),
          hint: Text(widget.timeFrame.name, style: const TextStyle(color: Colors.white)),
          items: [
            DropdownMenuItem(value: "laufend", alignment: Alignment.center, child: Container(constraints: BoxConstraints(maxWidth: 109), child: Text('Laufend', style: TextStyle(fontSize: 30)))),
            DropdownMenuItem(value: "sechsstunden", alignment: Alignment.center, child: Container(constraints: BoxConstraints(maxWidth: 159), child: Text('6 Stunden', style: TextStyle(fontSize: 30)))),
            DropdownMenuItem(value: "taeglich", alignment: Alignment.center, child: Container(constraints: BoxConstraints(maxWidth: 97), child: Text('Täglich', style: TextStyle(fontSize: 30)))),
            DropdownMenuItem(value: "zweitage", alignment: Alignment.center, child: Container(constraints: BoxConstraints(maxWidth: 90), child: Text('2 Tage', style: TextStyle(fontSize: 30)))),
          ],
          onChanged: changeeinsaetzetime),
      ),
      body: isLoading
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : list.isEmpty ? const Center(child: Text('Keine Einsätze', style: TextStyle(fontSize: 50)))
    : RefreshIndicator(
      onRefresh: refreshListView,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: ListView.builder(
            controller: listScrollController,
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(list[index].einsatzort.toString().replaceAll('-', ' ').replaceAll('  ', ' -').replaceAll('ä', 'Ä').replaceAll('ü', 'Ü').replaceAll('ö', 'Ö')),
                subtitle: Text(list[index].einsatzname + ' ' + DateFormat("d.M.y H:mm").format(list[index].startzeit)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  setState(() {});
                  Navigator.push(
                    context, 
                    PageRouteBuilder(
                      pageBuilder: (BuildContext context, Animation<double> animation1, Animation<double> animation2) {
                        return EinsatzDetails(list[index]);
                      },
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              );
            },
          ),
      ),
      ),
    );
  }
}

class EinsatzDetails extends StatefulWidget {
  final Einsatz einsatz;

  EinsatzDetails(this.einsatz, {super.key});
  @override
  State<EinsatzDetails> createState() => _EinsatzDetailsState();

  static TextStyle size(double size) {
    return TextStyle(fontSize: size);
  }
}

class _EinsatzDetailsState extends State<EinsatzDetails> {
  late GoogleMapController _mapController;
  String einsatztyp = 'nothing';
  Map<String, Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    final CameraPosition _einsatzortmap = CameraPosition(
      target: LatLng(widget.einsatz.koordinaten.latitude, widget.einsatz.koordinaten.longitude),
      zoom: 14.4746,
    );

    if (widget.einsatz.einsatztyp.toTitleCase().contains('"')) {
      einsatztyp = widget.einsatz.einsatztyp.toTitleCase().substring(0, widget.einsatz.einsatztyp.indexOf('"'));
    } else {
      einsatztyp = widget.einsatz.einsatztyp.toTitleCase();
    }
    LatLng markerposition = LatLng(widget.einsatz.koordinaten.latitude, widget.einsatz.koordinaten.longitude);

    return Scaffold(
      appBar: AppBar(title: Text("${widget.einsatz.einsatzname.toTitleCase()} in ${widget.einsatz.adresse.ort.toTitleCase()}")),
      body: Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                //Text(einsatz.einsatzart.toTitleCase(), textAlign: TextAlign.center, style: size(30)), --bruachen wir glaub ich nicht
                Text(widget.einsatz.einsatzname.toTitleCase(), textAlign: TextAlign.center, style: EinsatzDetails.size(30)),
                Text(widget.einsatz.einsatzort.toTitleCase().substring(widget.einsatz.einsatzort.indexOf('- ')).replaceAll('- ', ''), textAlign: TextAlign.center, style: EinsatzDetails.size(30)),
                //Text(widget.einsatz.einsatztyp.toTitleCase().substring(0, widget.einsatz.einsatztyp.indexOf('"')),textAlign: TextAlign.center, style: EinsatzDetails.size(30)),
                Text(einsatztyp,textAlign: TextAlign.center, style: EinsatzDetails.size(30)),
                Text("\n${widget.einsatz.adresse.toString().replaceAll('=>', '-')}", textAlign: TextAlign.center, style: EinsatzDetails.size(30)),
                Text(widget.einsatz.koordinaten.toString(), textAlign: TextAlign.center, style: EinsatzDetails.size(30)),
                Container(
                  height: 300,
                  width: 300,
                  child: GoogleMap(
                    mapType: MapType.satellite,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.einsatz.koordinaten.latitude, widget.einsatz.koordinaten.longitude),
                      zoom: 16,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      addMarker('test', markerposition, widget.einsatz.einsatzname.toString().toTitleCase(), widget.einsatz.adresse.toString().replaceAll('=>', '-'));
                    },
                    markers: _markers.values.toSet(),
                  ),
                ),
                Text("Alarmstufe: ${widget.einsatz.alarmstufe}", style: EinsatzDetails.size(30)),
                Text("Feuerwehren:", style: EinsatzDetails.size(30)),
                Text(widget.einsatz.feuerwehren.map((e) => e.toString()).join("\n"), textAlign: TextAlign.center, style: EinsatzDetails.size(30)),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: FloatingActionButton(
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.white,
                      ),
                    onPressed: () async {
                      bool? mapanvailable = await mlauncher.MapLauncher.isMapAvailable(mlauncher.MapType.google);
                      if (mapanvailable == true) {
                        await mlauncher.MapLauncher.showMarker(
                          mapType: mlauncher.MapType.google,
                          coords: mlauncher.Coords(widget.einsatz.koordinaten.latitude, widget.einsatz.koordinaten.longitude),
                          title: 'Navigate'
                        );
                      }
                    },
                  ),
                )
              ]
            ),
          ),
        ),
      )
    );
  }

  Future<bool> doesAssetExist(String assetPath) async {
  try {
    await rootBundle.load(assetPath);
    return true; // Asset exists
  } catch (error) {
    return false; // Asset does not exist
  }
}

  addMarker(String id, LatLng location, String title, String description) async {
    String assetName = 'assets/images/${widget.einsatz.einsatzname.replaceAll(',', '').replaceAll(' ', '').replaceAll('Ä', 'AE').replaceAll('Ü', 'UE').replaceAll('Ö', 'OE')}.png';
    print(assetName);
    String alarmicon;
    String decodedAssetName = String.fromCharCodes(assetName.runes);
    if (await doesAssetExist(assetName)) {
      alarmicon = decodedAssetName;
    } else {
      alarmicon = 'assets/images/NOICONFOUND.png';
    }
    var markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      alarmicon,
    );

    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      icon: markerIcon,
      infoWindow: InfoWindow(
        title: title,
        snippet: description,
      ),
    );
    _markers[id] = marker;
    setState(() {});
  }
}