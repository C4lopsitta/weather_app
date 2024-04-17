import 'dart:convert';

import 'package:http/http.dart' as http;

import 'geo.dart';

class Weather_api{

  final String _api_url = "api.open-meteo.com";
  double _latitude = 44.59703140;
  double _longitude = 7.61142170;
  Weather_api();


  String get api_url => _api_url;

  factory Weather_api.from_geo(Geo geo) {
    Weather_api w = Weather_api();
    w.latitude = geo.lat;
    w.longitude = geo.lon;
    return w;
  }

  factory Weather_api.from_lat_lon(double latitude, double longitude){
    Weather_api w = Weather_api();
    w._latitude = latitude;
    w._longitude = longitude;
    return w;
  }

  String toString(){
    return "url: $api_url, latitude: $_latitude, longitude: $_longitude";
  }

  Map<String, dynamic>? call_api(){
    const path = "/v1/forecast";
    Map<String, dynamic> params = {
      "longitude":_longitude,
      "latitude": _latitude,

      "current": "temperature_2m,relative_humidity_2m,apparent_temperature,"
        "precipitation,weather_code,wind_speed_10m,wind_direction_10m",

      "hourly":"temperature_2m,relative_humidity_2m,weather_code",

      "daily":"weather_code,temperature_2m_max,temperature_2m_min,sunrise,"
        "sunset,uv_index_max,precipitation_probability_max"
    };
    Uri uri = Uri.https(api_url,path, params);
    print(uri.query);
    http.get(uri).then(
            (result){
              print(json.decode(result.body));
        }
    );
    return null;
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }
}