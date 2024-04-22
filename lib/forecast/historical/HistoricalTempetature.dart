class HistoricalTemperature{
  List<dynamic> temperatureMax;
  List<dynamic> temperatureMin;
  List<dynamic> temperatureMean;
  List<dynamic> apparentTemperatureMax;
  List<dynamic> apparentTemperatureMin;
  List<dynamic> apparentTemperatureMean;

  HistoricalTemperature(this.temperatureMax, this.temperatureMin,
      this.temperatureMean, this.apparentTemperatureMax,
      this.apparentTemperatureMin, this.apparentTemperatureMean);
  factory HistoricalTemperature.fromJson(Map<String,dynamic> json){
    HistoricalTemperature t = HistoricalTemperature(
      json["daily"]["temperature_2m_max"],
      json["daily"]["temperature_2m_min"],
      json["daily"]["temperature_2m_mean"],
      json["daily"]["apparent_temperature_max"],
      json["daily"]["apparent_temperature_min"],
      json["daily"]["apparent_temperature_mean"]
    );
    return t;
  }
}