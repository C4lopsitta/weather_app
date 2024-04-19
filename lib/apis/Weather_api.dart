import 'dart:convert';

import 'package:http/http.dart' as http;

import 'geo.dart';

class Weather_api{

  final String _api_url = "api.open-meteo.com";
  Geo geo = Geo(44.59703140, 7.61142170);   //Cuneo coordinates

  bool _dailySunset = false;
  bool _dailySunrise = false;
  bool _dailyUvIndex = false;
  bool _dailyPrecipitationProbability = false;

  bool _currentApparentTemperature = false;
  bool _currentPrecipitation = false;
  bool _currentWindSpeed = false;
  bool _currentWindDirection = false;

  Weather_api(
      this.geo,
      this._dailySunset,
      this._dailySunrise,
      this._dailyUvIndex,
      this._dailyPrecipitationProbability,
      this._currentApparentTemperature,
      this._currentPrecipitation,
      this._currentWindSpeed,
      this._currentWindDirection);

  String get api_url => _api_url;

  Map<String, dynamic>? call_api(){
    const path = "/v1/forecast";
    String api_apparent_temperature = ",";
    String api_precipitation = ",";
    String api_windSpeed = ",";
    String api_windDirection = ",";

    if(_currentApparentTemperature == true)
      api_apparent_temperature = ",apparent_temperature";
    if(_currentPrecipitation == true)
      api_precipitation = ",precipitation";
    if(_currentWindSpeed == true)
      api_windSpeed = ",wind_speed_10m";
    if(_currentWindDirection == true)
      api_windDirection = ",wind_direction_10m";

    String api_sunrise = ",";
    String api_sunset = ",";
    String api_uvIndex = ",";
    String api_precipitationProbability = ",";

    if(_dailySunrise == true)
      api_sunrise = ",sunrise";
    if(_dailySunset == true)
      api_sunset = ",sunset";
    if(_dailyUvIndex == true)
      api_uvIndex = ",uv_index_max";
    if(_dailyPrecipitationProbability == true)
      api_precipitationProbability = ",precipitation_probability_max";

    Map<String, dynamic> params = {
      "longitude":geo.lon,
      "latitude": geo.lat,

      "current": "temperature_2m,relative_humidity_2m,weather_code$api_apparent_temperature"
        "$api_precipitation$api_windSpeed$api_windDirection",

      "hourly":"temperature_2m,relative_humidity_2m,weather_code",

      "daily":"weather_code,temperature_2m_max,temperature_2m_min$api_sunrise"
        "$api_sunset$api_uvIndex$api_precipitationProbability"
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