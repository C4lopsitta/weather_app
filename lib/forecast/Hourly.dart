class Hourly{
  final List<dynamic> times;
  final List<dynamic> temperatures;
  final List<dynamic> humidities;
  final List<dynamic> weatherCodes;
  Hourly(this.times, this.temperatures, this.humidities, this.weatherCodes);

  factory Hourly.fromJson(Map<String, dynamic> json){
    Hourly h = Hourly(
      json["hourly"]["time"],
      json["hourly"]["temperature_2m"],
      json["hourly"]["relative_humidity_2m"],
      json["hourly"]["weather_code"]
    );
    return h;
  }
}