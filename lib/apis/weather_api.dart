import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_app/forecast/current.dart';
import 'package:weather_app/forecast/daily.dart';
import 'package:weather_app/preferences_storage.dart';
import '../forecast/hourly.dart';
import 'geo.dart';

class WeatherApi{

  Map<String, dynamic> _responseJson = {};

  final String _api_url = "api.open-meteo.com";
  Geo? geo = Geo(44.59703140, 7.61142170);   //Cuneo coordinates

  bool? dailySunset = true;
  bool? dailySunrise = true;
  bool? dailyUvIndex = true;
  bool? dailyPrecipitationProbability = true;

  WeatherApi({
      this.geo,
      this.dailySunset,
      this.dailySunrise,
      this.dailyUvIndex,
      this.dailyPrecipitationProbability});

  String get api_url => _api_url;

  Future<Current?> call_api_current() async {
    const path = "/v1/forecast";

    Map<String, dynamic> params = {
      "longitude":"${geo?.lon}",
      "latitude": "${geo?.lat}",

      "current": "temperature_2m,relative_humidity_2m,weather_code,apparent_temperature"
        ",precipitation,wind_speed_10m,wind_direction_10m,"
    };
    Uri uri = Uri.https(api_url,path, params);
    print(uri.query);
    await http.get(uri).then(
            (result){
              if(result.statusCode != 200)
                return null;
              print("api call: " + result.body);
              this._responseJson = json.decode(result.body);
              //print(this._responseJson);
            // FileStorage.writeFile(FileStorage.CURRENT_FILE, result.body);
        }
    );
    return Current.fromJson(this._responseJson);
  }

  Future<Hourly> call_api_hourly() async{
    const path = "/v1/forecast";
    Map<String, dynamic> params = {
      "longitude":"${geo?.lon}",
      "latitude": "${geo?.lat}",
      "hourly":"temperature_2m,relative_humidity_2m,weather_code,precipitation_probability",
    };
    Uri uri = Uri.https(api_url,path, params);
    print(uri.query);
    await http.get(uri).then(
            (result){
          if(result.statusCode != 200)
            return null;
          print("api call: " + result.body);
          this._responseJson = json.decode(result.body);
          //print(this._responseJson);

          // FileStorage.writeFile(FileStorage.HOURLY_FILE, result.body);
        }
    );
    return Hourly.fromJson(this._responseJson);
  }

  Future<Daily> call_api_daily() async {
    const path = "/v1/forecast";
    /*String api_sunrise = ",";
    String api_sunset = ",";
    String api_uvIndex = ",";
    String api_precipitationProbability = ",";

    if(dailySunrise == true)
      api_sunrise = ",sunrise";
    if(dailySunset == true)
      api_sunset = ",sunset";
    if(dailyUvIndex == true)
      api_uvIndex = ",uv_index_max";
    if(dailyPrecipitationProbability == true)
      api_precipitationProbability = ",precipitation_probability_max";*/
    Map<String, dynamic> params = {
      "longitude":"${geo?.lon}",
      "latitude": "${geo?.lat}",

      "daily":"weather_code,temperature_2m_max,temperature_2m_min,sunrise"
          ",sunset,uv_index_max,precipitation_probability_max"
    };
    Uri uri = Uri.https(api_url,path, params);
    print(uri.query);
    await http.get(uri).then(
            (result){
          if(result.statusCode != 200)
            return null;
          print("api call: " + result.body);
          this._responseJson = json.decode(result.body);
          print(this._responseJson);

          // FileStorage.writeFile(FileStorage.DAILY_FILE, result.body);
          }
    );
    return Daily.fromJson(this._responseJson);
  }
}