import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:entrancescreen/api/apis.dart';
import 'package:entrancescreen/models/models.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ForecastWidget extends StatefulWidget {
  ForecastWidget({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  ForecastWidgetState createState() => ForecastWidgetState();
}

class ForecastWidgetState extends State<ForecastWidget> {
  NetatmoMeasurement netatmoMeasurement = NetatmoMeasurement();
  Forecast forecast = Forecast();
  Timer _timer;

  void getTemperatureData() async {
    var result = await NetatmoApi().getMeasurements();
    var temperatureMap = json.decode(result);
    setState(() {
      netatmoMeasurement = NetatmoMeasurement.fromJson(temperatureMap);
      print(netatmoMeasurement.indoorTemp);
    });
  }

  void getForecast() async {
    var result = await ForecastApi().getForecast();
    var forecastMap = json.decode(result);
    setState(() {
      forecast = Forecast.fromJson(forecastMap);
      print(forecast.weatherDescription);
    });
  }

  void refreshData() {
    getTemperatureData();
    getForecast();
    setState(() {
      DateTime _dateTime = DateTime.now();
      _timer = Timer(
        Duration(minutes: 1),
        refreshData,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  /*
  Texte:
  Sonnig
  Hochnebel

   */

  final iconmap = {
    '01': 'day-sunny', // sunny
    '02': 'day-sunny-overcast', // partly cloudy
    '03': 'cloud', // cloudy
    '04': 'cloudy', // many clouds
    '09': 'rain', // rain
    '10': 'day-rain', // rain with sun
    '11': 'day-storm-showers', // thunderstorm
    '13': 'snow', // snow
    '50': 'fog', // fog
  };

  @override
  Widget build(BuildContext context) {
    TextStyle s = TextStyle(fontSize: 30.0, fontWeight: FontWeight.normal);

    if (forecast.icon != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          BoxedIcon(
            WeatherIcons.fromString(
                'wi-' + iconmap[forecast.icon.substring(0, 2)]),
            size: 36,
            color: Colors.grey,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(WeatherIcons.thermometer_exterior, size: 28,),
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Text(
                  '${netatmoMeasurement.outdoorTemp}°',
                  style: s,
                ),
              ),
              Icon(
                Icons.expand_more,
                size: 36,
              ),
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Text(
                  '${forecast.tempMin.floor()}°',
                  style: s,
                ),
              ),
              Icon(
                Icons.expand_less,
                size: 36,
              ),
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Text(
                  '${forecast.tempMax.floor()}°',
                  style: s,
                ),
              ),
            ],
          ),
          Text(
            '${forecast.weatherDescription.toUpperCase()}',
            style: Theme
                .of(context)
                .textTheme
                .title,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[SpinKitRing(
          color: Colors.white,
          size: 50.0,
        )
        ],
      );
    }
  }
}
