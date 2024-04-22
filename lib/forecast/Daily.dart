class Daily{
  final List<dynamic> minTemperature;
  final List<dynamic> maxTemperature;
  final List<dynamic> sunrise;
  final List<dynamic> sunset;
  final List<dynamic> uvMaxIndex;
  final List<dynamic> precipitationProbability;
  final List<dynamic> weatherCode;
  final List<dynamic> dates;
  Daily(this.minTemperature, this.maxTemperature, this.sunrise, this.sunset,
      this.uvMaxIndex, this.precipitationProbability, this.weatherCode, this.dates);

  factory Daily.fromJson(Map<String, dynamic> json){

    Daily d = Daily(
      json["daily"]["temperature_2m_min"],
      json["daily"]["temperature_2m_max"],
      json['daily']['sunrise'],   //it's a date
      json['daily']['sunset'],      //it's a date
      json["daily"]["uv_index_max"],
      json["daily"]["precipitation_probability_max"],
      json["daily"]["weather_code"],
      json["daily"]["time"]
    );

    return d;
  }
}