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
