import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:entrancescreen/api/apis.dart';
import 'package:entrancescreen/models/models.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ForecastWidget extends StatefulWidget {
  ForecastWidget({Key key, this.title}) : super(key: key);

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
  Nebel
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
              Icon(
                WeatherIcons.thermometer_exterior,
                size: 28,
              ),
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
            style: Theme.of(context).textTheme.title,
          ),
          Container(
            height: 50,
            child: RainforecastWidget(),
          )
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitRing(
            color: Colors.white,
            size: 50.0,
          )
        ],
      );
    }
  }
}

class RainforecastWidget extends StatefulWidget {
  RainforecastWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  RainforecastWidgetState createState() => RainforecastWidgetState();
}

class RainforecastWidgetState extends State<RainforecastWidget> {
  Rainforecast rainforecast = Rainforecast();
  Timer _timer;

  List<charts.Series> seriesList;
  final bool animate = true;

  void refreshData() async {
    var result = await KachelmannApi().getMeasurements();
    setState(() {
      rainforecast = Rainforecast.fromString(result);
      this.seriesList = _prepareRainforecastData();
      print(rainforecast);
      _timer = Timer(
        Duration(minutes: 30),
        refreshData,
      );
    });
  }

  @override
  void initState() {
    this.seriesList = _prepareRainforecastData();
    super.initState();
    refreshData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (seriesList != null &&
        seriesList.length > 0 &&
        seriesList[0].data != null &&
        rainforecast.maxMillimeters() > 0
    ) {
      return new charts.BarChart(
        seriesList,
        animate: animate,

        /// Assign a custom style for the measure axis.
        ///
        /// The NoneRenderSpec only draws an axis line (and even that can be hidden
        /// with showAxisLine=false).
        primaryMeasureAxis:
            new charts.NumericAxisSpec(renderSpec: new charts.NoneRenderSpec()),

        /// This is an OrdinalAxisSpec to match up with BarChart's default
        /// ordinal domain axis (use NumericAxisSpec or DateTimeAxisSpec for
        /// other charts).
        domainAxis: new charts.OrdinalAxisSpec(
            // Make sure that we draw the domain axis line.
            showAxisLine: true,
            // But don't draw anything else.
        //    renderSpec: new charts.NoneRenderSpec()
        ),

        // With a spark chart we likely don't want large chart margins.
        // 1px is the smallest we can make each margin.
        layoutConfig: new charts.LayoutConfig(
            leftMarginSpec: new charts.MarginSpec.fixedPixel(0),
            topMarginSpec: new charts.MarginSpec.fixedPixel(0),
            rightMarginSpec: new charts.MarginSpec.fixedPixel(0),
            bottomMarginSpec: new charts.MarginSpec.fixedPixel(0)),
      );
    } else {
      return new Container();
    }
  }

  /// Create series list with single series
  List<charts.Series<RainforecastEntry, String>> _prepareRainforecastData() {
    return [
      new charts.Series<RainforecastEntry, String>(
        id: 'Expected Rainfall',
        colorFn: (_, __) => charts.MaterialPalette.gray.shadeDefault,
        domainFn: (RainforecastEntry sales, _) => sales.date.hour.toString(),
        measureFn: (RainforecastEntry sales, _) => sales.millimeters,
        data: rainforecast.millimeters,
      ),
    ];
  }
}
