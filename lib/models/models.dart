
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class NetatmoMeasurement {
  double outdoorTemp;
  double rain;
  double indoorTemp;
  double co2;
  double pastRain;
  double gustStrength;
  double windStrength;
  double windAngle;
  double windChill;

  NetatmoMeasurement(
      {this.outdoorTemp,
      this.rain,
      this.indoorTemp,
      this.co2,
      this.pastRain,
      this.gustStrength,
      this.windStrength,
      this.windAngle,
      this.windChill});

  factory NetatmoMeasurement.fromJson(Map<String, dynamic> json) =>
      _$NetatmoMeasurementFromJson(json);

  Map<String, dynamic> toJson() => _$NetatmoMeasurementToJson(this);
}

@JsonSerializable()
class Forecast {
  double tempMin;
  double tempMax;
  double rainExpected;
  double rainMmTillMidnight;
  double rainMm;
  String condition;
  String icon;
  String weatherDescription;

  Forecast(
      {this.tempMin,
      this.tempMax,
      this.rainExpected,
      this.rainMmTillMidnight,
      this.rainMm,
      this.condition,
      this.icon,
      this.weatherDescription});

  factory Forecast.fromJson(Map<String, dynamic> json) =>
      _$ForecastFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastToJson(this);
}

int _timeDiffMinutes(DateTime dateTime) {
  Duration difference = dateTime.difference(new DateTime.now());
  return difference.inMinutes;
}

Timetable _timetableFromJson(Map<String, dynamic> json) {
  const up = 'up';
  const down = 'down';

  const directions = {
    '8503610': up, // Triemli
    '8591401': up, // Triemlispital
    '8591062': down, // Oerlikon
    '8573710': up, // Zürich Wiedikon
    '8591068': down, // Bändliweg
  };

  Timetable t = Timetable(up: [], down: []);

  for (var conn in json['connections']) {
    var c = {
      'line': conn['line'],
      'time': DateTime.parse(conn['time']),
      'timeDiff': _timeDiffMinutes(DateTime.parse(conn['time'])),
      'color': Timetable.colorFromHex(conn['color'])
    };
    if (directions[conn['terminal']['id']] == up) {
      t.up.add(c);
    }
    if (directions[conn['terminal']['id']] == down) {
      t.down.add(c);
    }
  }
  return t;
}

class Timetable {
  List<Map<String, dynamic>> up;
  List<Map<String, dynamic>> down;

  Timetable({this.up, this.down});

  factory Timetable.fromJson(Map<String, dynamic> json) =>
      _timetableFromJson(json);

  static Color colorFromHex(String hexString) {
    final buffer = StringBuffer();
    buffer.write("ff" + hexString.substring(0, 6));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}