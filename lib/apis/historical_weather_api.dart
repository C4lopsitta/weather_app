import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/forecast/historical/HistoricalWind.dart';

import '../forecast/historical/HistoricalSun.dart';
import '../forecast/historical/HistoricalTempetature.dart';
import 'geo.dart';

class HistoricalWeatherApi{
  Map<String, dynamic> _responseJson = {};
  Geo? geo = Geo(44.59703140, 7.61142170);
  DateFormat dateFormatter = DateFormat.yMd();
  DateTime startDate = DateTime(2024);
  DateTime endDate = DateTime(2024);
  final _api_url = "https://archive-api.open-meteo.com";

  HistoricalWeatherApi({
    this.geo,
    required this.startDate,
    required this.endDate
  });

  Future<HistoricalWind> call_api_wind() async {
    const path = "/v1/archive";

    Map<String, dynamic> params = {
      "longitude":"${geo?.lon}",
      "latitude": "${geo?.lat}",
      "start_date": dateFormatter.format(startDate),
      "end_date": dateFormatter.format(endDate),

      "daily": "wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant"
    };
    Uri uri = Uri.https(_api_url,path, params);
    print(uri.query);
    await http.get(uri).then(
            (result){
          if(result.statusCode != 200)
            return null;
          print("api call: " + result.body);
          this._responseJson = json.decode(result.body);
        }
    );
    return HistoricalWind.fromJson(_responseJson);
  }

  Future<HistoricalTemperature> call_api_temperature() async {
    const path = "/v1/archive";

    Map<String, dynamic> params = {
      "longitude":"${geo?.lon}",
      "latitude": "${geo?.lat}",
      "start_date": dateFormatter.format(startDate),
      "end_date": dateFormatter.format(endDate),

      "daily": "temperature_2m_max,temperature_2m_min,temperature_2m_mean,apparent_temperature_max,"
          "apparent_temperature_min,apparent_temperature_mean"
    };
    Uri uri = Uri.https(_api_url,path, params);
    print(uri.query);
    await http.get(uri).then(
            (result){
          if(result.statusCode != 200)
            return null;
          print("api call: " + result.body);
          this._responseJson = json.decode(result.body);
        }
    );
    return HistoricalTemperature.fromJson(_responseJson);
  }
  Future<HistoricalSun> call_api_sun() async {
    const path = "/v1/archive";

    Map<String, dynamic> params = {
      "longitude":"${geo?.lon}",
      "latitude": "${geo?.lat}",
      "start_date": dateFormatter.format(startDate),
      "end_date": dateFormatter.format(endDate),

      "daily": "sunrise,sunset,daylight_duration,sunshine_duration"
    };
    Uri uri = Uri.https(_api_url,path, params);
    print(uri.query);
    await http.get(uri).then(
            (result){
          if(result.statusCode != 200)
            return null;
          print("api call: " + result.body);
          this._responseJson = json.decode(result.body);
        }
    );
    return HistoricalSun.fromJson(_responseJson);
  }
}