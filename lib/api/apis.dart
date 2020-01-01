import 'dart:math';

import 'package:http/http.dart';

class Network {
  final String url;

  Network(this.url);

  Future getData() async {
    print('Calling uri: $url');
    Response response = await get(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print(response.statusCode);
    }
  }
}

class KachelmannApi {
  Future<dynamic> getMeasurements() async {
    if (false) {
      Network network =
      Network(
          'https://us-central1-reliefprint-159213.cloudfunctions.net/rain_forecast?city_id=2657896');
      return await network.getData();
    } else {
      var items = [800, 16];
      var rng = new Random();
      for (var i = 0; i < 24; i++) {
        items.add(rng.nextInt(10));
      }
      return items.join(',');
    }
  }
}

class NetatmoApi {
  Future<dynamic> getMeasurements() async {
    Network network =
    Network('http://muehlemann.com/kitchendisplay/netatmo.php');
    var temperature = await network.getData();
    return temperature;
  }
}

class ForecastApi {
  Future<dynamic> getForecast() async {
    Network network = Network(
        'http://muehlemann.com/kitchendisplay/forecast.php?city=zuerich');
    var forecast = await network.getData();
    return forecast;
  }
}

class TimetableApi {
  Future<dynamic> getTimetable() async {
    Network network = Network(
        'https://fahrplan.search.ch/api/stationboard.json?stop=Rautistrasse&limit=20');
    var timetable = await network.getData();
    return timetable;
  }
}
