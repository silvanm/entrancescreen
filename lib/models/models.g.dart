// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetatmoMeasurement _$NetatmoMeasurementFromJson(Map<String, dynamic> json) {
  return NetatmoMeasurement(
      outdoorTemp: (json['outdoorTemp'] as num)?.toDouble(),
      rain: (json['rain'] as num)?.toDouble(),
      indoorTemp: (json['indoorTemp'] as num)?.toDouble(),
      co2: (json['co2'] as num)?.toDouble(),
      pastRain: (json['pastRain'] as num)?.toDouble(),
      gustStrength: (json['gustStrength'] as num)?.toDouble(),
      windStrength: (json['windStrength'] as num)?.toDouble(),
      windAngle: (json['windAngle'] as num)?.toDouble(),
      windChill: (json['windChill'] as num)?.toDouble());
}

Map<String, dynamic> _$NetatmoMeasurementToJson(NetatmoMeasurement instance) =>
    <String, dynamic>{
      'outdoorTemp': instance.outdoorTemp,
      'rain': instance.rain,
      'indoorTemp': instance.indoorTemp,
      'co2': instance.co2,
      'pastRain': instance.pastRain,
      'gustStrength': instance.gustStrength,
      'windStrength': instance.windStrength,
      'windAngle': instance.windAngle,
      'windChill': instance.windChill
    };

Forecast _$ForecastFromJson(Map<String, dynamic> json) {
  return Forecast(
      tempMin: (json['tempMin'] as num)?.toDouble(),
      tempMax: (json['tempMax'] as num)?.toDouble(),
      rainExpected: (json['rainExpected'] as num)?.toDouble(),
      rainMmTillMidnight: (json['rainMmTillMidnight'] as num)?.toDouble(),
      rainMm: (json['rainMm'] as num)?.toDouble(),
      condition: json['condition'] as String,
      icon: json['icon'] as String,
      weatherDescription: json['weatherDescription'] as String);
}

Map<String, dynamic> _$ForecastToJson(Forecast instance) => <String, dynamic>{
      'tempMin': instance.tempMin,
      'tempMax': instance.tempMax,
      'rainExpected': instance.rainExpected,
      'rainMmTillMidnight': instance.rainMmTillMidnight,
      'rainMm': instance.rainMm,
      'condition': instance.condition,
      'icon': instance.icon,
      'weatherDescription': instance.weatherDescription
    };
