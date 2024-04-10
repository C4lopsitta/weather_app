import 'dart:convert';

import 'package:http/http.dart' as http;

class Weather_api{

  final String _api_url = "api.open-meteo.com";
  String _latitude = "44.59703140";
  String _longitude = "7.61142170";
  Weather_api();


  String get api_url => _api_url;

  factory Weather_api.from_geo(String latitude, String longitude){
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
    Map<String, dynamic> params = {"longitude":_longitude,"latitude": _latitude,
      "current": "temperature_2m,wind_speed_10m",
      "hourly":"temperature_2m,relative_humidity_2m,wind_speed_10m"};
    Uri uri = Uri.https(api_url,path, params);
    print(uri.query);
    http.get(uri).then(
            (result){
              print(json.decode(result.body));
        }
    );
    return null;
  }

  String get latitude => _latitude;

  set latitude(String value) {
    _latitude = value;
  }

  String get longitude => _longitude;

  set longitude(String value) {
    _longitude = value;
  }
}