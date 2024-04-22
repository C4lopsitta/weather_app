class HistoricalPrecipitation{
  List<dynamic> precipitationSums;
  List<dynamic> rainSums;
  List<dynamic> snowfallSums;
  List<dynamic> precipitationHours;


  HistoricalPrecipitation(this.precipitationSums, this.rainSums,
      this.snowfallSums, this.precipitationHours);

  factory HistoricalPrecipitation.fromJson(Map<String,dynamic> json){
    HistoricalPrecipitation t = HistoricalPrecipitation(    //precipitation_sum,rain_sum,snowfall_sum,precipitation_hours
      json["daily"]["precipitation_sum"],
      json["daily"]["rain_sum"],
      json["daily"]["snowfall_sum"],
      json["daily"]["precipitation_hours"],
    );
    return t;
  }
}