import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/forecast/weather_translator.dart';

class WeatherHeader extends StatefulWidget {
  WeatherHeader({
    super.key,
    required this.city,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.perceivedTemp,
    required this.status,
    this.cityFromGPS = false,
    this.lastUpdate
  });

  bool cityFromGPS = false;
  String? city;
  int status;
  double temperature;
  double maxTemp;
  double minTemp;
  double perceivedTemp;
  DateTime? lastUpdate;

  @override
  State<StatefulWidget> createState() => _WeatherHeader();
}

class _WeatherHeader extends State<WeatherHeader> {
  @override
  void initState() {
    super.initState();
  }

  TextStyle city = const TextStyle(fontSize: 18);
  TextStyle description = const TextStyle(fontSize: 20, fontWeight: FontWeight.w500);
  TextStyle temperature = const TextStyle(fontSize: 52, fontWeight: FontWeight.w600);
  TextStyle updatedStyle = const TextStyle(fontSize: 11, fontWeight: FontWeight.w300, height: 0.2);

  DateFormat formatter = DateFormat.Hm();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: MediaQuery.of(context).size.height * 0.3,
      alignment: Alignment.center,
      child: GridView.count(
        primary: false,
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.city ?? "Wadafak", style: city),
              Text("Last updated at ${formatter.format(widget.lastUpdate ?? DateTime.parse("1970-01-01"))}", style: updatedStyle),
              Text("${widget.temperature.round()}°C", style: temperature),
              Baseline(
                baseline: 10,
                baselineType: TextBaseline.alphabetic,
                child: Text(WeatherTranslator.getWeatherDescription(widget.status) ?? "API Failed", style: description)
              ),
              Text("${widget.maxTemp.round()}° / ${widget.minTemp.round()}° Feels like ${widget.perceivedTemp.round()}°")
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            alignment: AlignmentDirectional.bottomEnd,
            child: Icon(
                WeatherTranslator.getWeatherIcon(widget.status),
              size: MediaQuery.of(context).size.width * 0.25,
            )
          )
        ],
    ));
  }
}
