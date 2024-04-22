import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/forecast/HistoricalWind.dart';

import 'geo.dart';

class HistoricalWeather{
  Map<String, dynamic> _responseJson = {};
  Geo? geo = Geo(44.59703140, 7.61142170);
  DateFormat dateFormatter = DateFormat.yMd();
  DateTime startDate = DateTime(2024);
  DateTime endDate = DateTime(2024);
  final _api_url = "https://archive-api.open-meteo.com";

  HistoricalWeather({
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
}