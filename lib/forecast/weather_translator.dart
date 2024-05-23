// uses WMO weather codes
// https://www.nodc.noaa.gov/archive/arc0021/0002199/1.1/data/0-data/HTML/WMO-CODE/WMO4677.HTM
import 'package:flutter/material.dart';

// 0,1 sunny
// 2,3 cloudy
// 45,48 foggy
// 51,53,55,56,57,61,63,65,66,67,80,81,82 rainy
// 71,73, 75, 76, 77, 85,86, snowy
// 95, 96, 99 thunderstorm
class WeatherTranslator{
  static IconData getWeatherIcon(int weatherStatus){  //weatherStatus is a standard WMO number
    if(weatherStatus == 0 || weatherStatus == 1)
      return Icons.sunny;
    if(weatherStatus == 2 || weatherStatus == 3)
      return Icons.cloud;
    if(weatherStatus == 45 || weatherStatus == 48)
      return Icons.foggy;
    if(weatherStatus <= 51 || weatherStatus <= 86)
      return Icons.cloudy_snowing;
    if(weatherStatus == 95 || weatherStatus == 96 || weatherStatus == 99)
      return Icons.thunderstorm;
    return Icons.question_mark;
  }

  static Color getWeatherColor(int weatherStatus, bool isDarkMode) {
    if(weatherStatus == 0 || weatherStatus == 1) {
      return const Color.fromRGBO(102, 204, 255, 1.0);
    }
    if(weatherStatus == 2 || weatherStatus == 3) {
      return const Color.fromRGBO(78, 87, 89, 1.0);
    }
    if(weatherStatus == 45 || weatherStatus == 48) {
      return const Color.fromRGBO(63, 63, 63, 1);
    }
    if(weatherStatus <= 51 || weatherStatus <= 86) {
      return const Color.fromRGBO(119, 119, 119, 1);
    }
    if(weatherStatus == 95 || weatherStatus == 96 || weatherStatus == 99) {
      return const Color.fromRGBO(53, 59, 61, 1);
    }
    return ((isDarkMode) ? ThemeData.dark() : ThemeData.light()).colorScheme.background;
  }

  static String getWeatherDescription(int weatherStatus){  //weatherStatus is a standard WMO number
    if(weatherStatus == 0)
      return "Clear sky";
    if(weatherStatus == 1)
      return "Mainly clear";
    if(weatherStatus == 2 || weatherStatus == 3)
      return "partly cloudy";
    if(weatherStatus == 45 || weatherStatus == 48)
      return "Fog and depositing rime fog";
    if(weatherStatus == 51 || weatherStatus == 53 || weatherStatus == 55)
      return (weatherStatus == 51? "light":"moderate") + " Drizzle";
    if(weatherStatus == 56 || weatherStatus == 57)
      return "Freezing Drizzle";
    if(weatherStatus == 61 || weatherStatus == 63 || weatherStatus == 65)
      return (weatherStatus == 61? "light":"Heavy") + " Rain";
    if(weatherStatus == 66 || weatherStatus == 67)
      return (weatherStatus == 66?"Light":"Heavy") + " Freezing Rain";
    if(weatherStatus == 71 || weatherStatus == 73 || weatherStatus == 75)
      return (weatherStatus == 71? "Slight":"Heavy intensity") + " snow";
    if(weatherStatus == 77)
      return "Snow grains";
    if(weatherStatus == 80 || weatherStatus == 81 || weatherStatus == 82)
      return (weatherStatus == 80? "Slight":"Violent") + " Rain Showers";
    if(weatherStatus == 85 || weatherStatus == 86)
      return (weatherStatus == 80? "Slight":"Heavy") + " Snow Showers";
    if(weatherStatus == 95 || weatherStatus == 96 || weatherStatus == 99)
      return "Thunderstorm";
    return "";
  }

  static IconData windIconFromDegrees(String direction) {
    return Icons.not_accessible_rounded;
  }
}