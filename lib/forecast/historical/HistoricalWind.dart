class HistoricalWind{
  List<dynamic> windSpeeds;
  List<dynamic> windGusts;
  List<dynamic> windDirections;

  HistoricalWind(this.windSpeeds, this.windGusts, this.windDirections);
  factory HistoricalWind.fromJson(Map<String,dynamic> json){
    HistoricalWind w = HistoricalWind(
      json["daily"]["wind_speed_10m_max"],
      json["daily"]["wind_gusts_10m_max"],
      json["daily"]["wind_direction_10m_dominant"]
    );
    return w;
  }
}