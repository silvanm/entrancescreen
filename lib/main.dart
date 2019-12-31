import 'dart:async';

import 'package:entrancescreen/forecast.dart';
import 'package:entrancescreen/timetable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:light/light.dart';
import 'package:screen/screen.dart';
import 'clock.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final latoTheme = GoogleFonts.latoTextTheme();

    final newTextTheme = latoTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'EntranceScreen',
      theme: ThemeData(
        brightness: Brightness.dark,
        canvasColor: Colors.black,
        textTheme: newTextTheme,
      ),
      home: MyHomePage(title: 'Mühlemann\'s Entrance Screen'),
    );
  }
}

final key = new GlobalKey<ForecastWidgetState>();

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Light _light;
  int _luxValue;
  StreamSubscription _subscription;

  void startListening() {
    _light = new Light();
    try {
      _subscription = _light.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      print(exception);
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('de_CH', null).then((_) => {});
    Screen.keepOn(true);
    SystemChrome.setEnabledSystemUIOverlays([]);
    startListening();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void onData(int luxValue) async {
    print("Lux value from Light Sensor: $luxValue");
    setState(() {
      _luxValue = luxValue;
    });
  }



  @override
  Widget build(BuildContext context) {
    if (_luxValue != null && _luxValue < 10) {
      return Scaffold();
    } else {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                Icon(
                  Icons.directions_bus,
                  color: Colors.grey,
                  size: 36.0,
                ),
                TimetableWidget(),
              ],
            ),
            Column(
              children: <Widget>[
                Icon(
                  Icons.access_time,
                  size: 36.0,
                  color: Colors.grey,
                ),
                DigitalClock(),
              ],
            ),
            Column(
              children: <Widget>[
                ForecastWidget(key: key),
              ],
            ),
          ],
        ),
        /*floatingActionButton: FloatingActionButton(
        onPressed: () => key.currentState.refreshData(),
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
       */
      );
    }
  }
}
