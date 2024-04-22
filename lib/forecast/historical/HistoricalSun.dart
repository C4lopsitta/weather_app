class HistoricalSun{
  List<dynamic> sunrises;
  List<dynamic> sunsets;
  List<dynamic> daylightDurations;
  List<dynamic> sunshineDurations;


  HistoricalSun(this.sunrises, this.sunsets, this.daylightDurations,
      this.sunshineDurations);

  factory HistoricalSun.fromJson(Map<String,dynamic> json){
    HistoricalSun t = HistoricalSun(    //"sunrise,sunset,daylight_duration,sunshine_duration"
        json["daily"]["sunrise"],
        json["daily"]["sunset"],
        json["daily"]["daylight_duration"],
        json["daily"]["sunshine_duration"],
    );
    return t;
  }
}