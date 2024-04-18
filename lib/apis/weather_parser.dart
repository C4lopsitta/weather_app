
class Current {

  final double temperature;
  final double apparentTemperature;
  final double windSpeed;
  final String windDirection;
  final int weatherCode;
  final int precipitation;
  final int humidity;
  Current(this.temperature, this.apparentTemperature, this.windSpeed,
      this.windDirection, this.weatherCode, this.precipitation, this.humidity);

  factory Current.fromJson(Map<String, dynamic> json){

    Current c = Current(
      json["current"]["temperature_2m"],
      json["current"]["apparent_temperature"],
      json["current"]["wind_speed_10m"],
      "$json['current']['wind_direction_10m']",
      json["current"]["weather_code"],
      json["current"]["precipitation"],
      json["current"]["relative_humidity_2m"],
    );

    return c;
  }
}
