class Daily{
  final double minTemperature;
  final double maxTemperature;
  final String sunrise;
  final String sunset;
  final double uvMaxIndex;
  final int precipitationProbability;
  final int weatherCode;
  Daily(this.minTemperature, this.maxTemperature, this.sunrise, this.sunset,
      this.uvMaxIndex, this.precipitationProbability, this.weatherCode);

  factory Daily.fromJson(Map<String, dynamic> json){

    Daily d = Daily(
      json["daily"]["temperature_2m_min"],
      json["daily"]["temperature_2m_max"],
      "${json['daily']['sunrise']}",   //it's a date
      "${json['daily']['sunset']}",      //it's a date
      json["daily"]["uv_index_max"],
      json["daily"]["precipitation_probability_max"],
      json["daily"]["weather_code"]
    );

    return d;
  }
}