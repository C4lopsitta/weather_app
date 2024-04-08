class Weather_api{

  String _api_url = "https://api.open-meteo.com/v1/forecast?latitude=0&longitude=0";
  String latitude = "";
  String longitude = "";
  Weather_api();

  String get api_url => _api_url;

  void api_parameter_set(String latitude, String longitude) {
    _api_url += "latitude=$latitude&longitude=$longitude";
  }

  factory Weather_api.call_weather_api(String latitude, String longitude){
    Weather_api w = Weather_api();
    w.api_parameter_set(latitude, longitude);
    return w;
  }

  String toString(){
    return "url: $api_url, latitude: $latitude, longitude: $longitude";
  }
}