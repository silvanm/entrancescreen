import 'dart:async';
import 'dart:math';

import 'package:entrancescreen/forecast.dart';
import 'package:entrancescreen/models/rainforecast.dart';
import 'package:entrancescreen/timetable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:light/light.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:screen/screen.dart';
import 'clock.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Rainforecast _rainforecast = Rainforecast();
    final latoTheme = GoogleFonts.latoTextTheme();

    final newTextTheme = latoTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ScopedModel<Rainforecast>(
        model: _rainforecast,
        child: MaterialApp(
            title: 'EntranceScreen',
            theme: ThemeData(
              brightness: Brightness.dark,
              canvasColor: Colors.black,
              textTheme: newTextTheme,
            ),
            home: MyHomePage(
              title: 'Mühlemann\'s Entrance Screen',
              rainforecast: _rainforecast,
            )));
  }
}

final key = new GlobalKey<ForecastWidgetState>();

class MyHomePage extends StatefulWidget {
  final Rainforecast rainforecast;

  MyHomePage({Key key, this.title, this.rainforecast}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Light _light;
  int _luxValue;
  final luxHigherThreshold = 2;
  final luxLowerThreshold = 1;
  bool _displayOff = false;
  Timer _timer;
  double _maxMillimeters = 0;

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
    refreshData();
    if (!kIsWeb) {
      startListening();
    } else {
      _luxValue = 50;
    }
  }

  void refreshData() {
    widget.rainforecast.refresh();
    setState(() {
      _maxMillimeters = widget.rainforecast.maxMillimeters();
      _timer = Timer(
        Duration(minutes: 10),
        refreshData,
      );
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void onData(int luxValue) async {
    print("Lux value from Light Sensor: $luxValue");
    setState(() {
      _luxValue = luxValue;

      // Hysteresis
      if (!_displayOff && _luxValue < luxLowerThreshold) {
        _displayOff = true;
      }
      if (_displayOff && _luxValue > luxHigherThreshold) {
        _displayOff = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Positioned luxValueWidget = Positioned(
      child: new Align(
          alignment: FractionalOffset.bottomCenter,
          child: Text('${_luxValue}',
              style: TextStyle(color: Colors.grey, fontSize: 10))),
    );

    // generate background color considering the rain
    const fullColorAt = 5;
    Color backgroundColor = Color.fromRGBO(
        0,
        0,
        255,
        [fullColorAt, widget.rainforecast.maxMillimeters(12) ?? 0].reduce(min) /
            fullColorAt);

    if (_displayOff) {
      return Scaffold(
          body: Stack(
        children: <Widget>[luxValueWidget],
      ));
    } else {
      return Scaffold(
          backgroundColor: backgroundColor,
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
                children: <Widget>[ForecastWidget(key: key)],
              ),
              /* Stack(
            children: <Widget>[luxValueWidget,
            Text('${widget.rainforecast.maxMillimeters()}')
            ],
          ),*/
            ],
          )
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
