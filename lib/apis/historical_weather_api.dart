import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/forecast/historical/historical_wind.dart';

import '../forecast/historical/historical_precipitation.dart';
import '../forecast/historical/historical_sun.dart';
import '../forecast/historical/historical_tempetature.dart';
import 'geo.dart';

class HistoricalWeatherApi{
  Map<String, dynamic> _responseJson = {};
  Geo? geo = Geo(44.59703140, 7.61142170);
  DateFormat _dateFormatter = DateFormat("yyyy-MM-dd");
  DateTime startDate = DateTime(2024,01,01);
  DateTime endDate = DateTime(2024,02,02);
  final _api_url = "archive-api.open-meteo.com";

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
      "start_date": _dateFormatter.format(startDate),
      "end_date": _dateFormatter.format(endDate),

      "daily": "wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant"
    };

    Uri uri = Uri.https(_api_url,path, params);
    await http.get(uri).then(
            (result){
          if(result.statusCode != 200)
            return null;
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
      "start_date": _dateFormatter.format(startDate),
      "end_date": _dateFormatter.format(endDate),

      "daily": "temperature_2m_max,temperature_2m_min,temperature_2m_mean,apparent_temperature_max,"
          "apparent_temperature_min,apparent_temperature_mean"
    };
    Uri uri = Uri.https(_api_url,path, params);
    await http.get(uri).then(
            (result){
          if(result.statusCode != 200){
            return null;
          }
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
      "start_date": _dateFormatter.format(startDate),
      "end_date": _dateFormatter.format(endDate),

      "daily": "sunrise,sunset,daylight_duration,sunshine_duration"
    };
    Uri uri = Uri.https(_api_url,path, params);
    await http.get(uri).then(
            (result){
          if(result.statusCode != 200)
            return null;
          this._responseJson = json.decode(result.body);
        }
    );
    return HistoricalSun.fromJson(_responseJson);
  }

  Future<HistoricalPrecipitation> call_api_precipitation() async {
    const path = "/v1/archive";

    Map<String, dynamic> params = {
      "longitude":"${geo?.lon}",
      "latitude": "${geo?.lat}",
      "start_date": _dateFormatter.format(startDate),
      "end_date": _dateFormatter.format(endDate),

      "daily": "precipitation_sum,rain_sum,snowfall_sum,precipitation_hours"
    };
    Uri uri = Uri.https(_api_url,path, params);
    await http.get(uri).then(
            (result){
          if(result.statusCode != 200)
            return null;
          this._responseJson = json.decode(result.body);
        }
    );
    return HistoricalPrecipitation.fromJson(_responseJson);
  }

  Future<List<dynamic>> call_api_weather_codes() async {
    const path = "/v1/archive";

    Map<String, dynamic> params = {
      "longitude":"${geo?.lon}",
      "latitude": "${geo?.lat}",
      "start_date": _dateFormatter.format(startDate),
      "end_date": _dateFormatter.format(endDate),

      "daily": "precipitation_sum,rain_sum,snowfall_sum,precipitation_hours"
    };
    Uri uri = Uri.https(_api_url,path, params);
    await http.get(uri).then(
            (result){
          if(result.statusCode != 200)
            return null;
          this._responseJson = json.decode(result.body);
        }
    );
    return _responseJson["daily"]["weather_code"];
  }
}