import 'dart:convert';

import 'package:http/http.dart' as http;

import 'geo.dart';

class Weather_api{

  final String _api_url = "api.open-meteo.com";
  Geo geo = new Geo(44.59703140, 7.61142170);   //Cuneo coordinates
  Weather_api();


  String get api_url => _api_url;

  factory Weather_api.from_geo(Geo geo) {
    Weather_api w = Weather_api();
    w.geo = geo;
    return w;
  }

  Map<String, dynamic>? call_api(){
    const path = "/v1/forecast";
    Map<String, dynamic> params = {
      "longitude":geo.lon,
      "latitude": geo.lat,

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
}