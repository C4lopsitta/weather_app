import 'dart:ui';
import 'package:flutter/material.dart';

class WeatherHeader extends StatefulWidget {
  WeatherHeader({
    super.key,
    required this.city,
    required this.weatherDescription,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.perceivedTemp,
    this.cityFromGPS = false
  });

  bool cityFromGPS = false;
  String? city;
  String? weatherDescription;
  IconData icon = Icons.not_accessible_rounded;
  double temperature;
  double maxTemp;
  double minTemp;
  double perceivedTemp;

  @override
  State<StatefulWidget> createState() => _WeatherHeader();
}

class _WeatherHeader extends State<WeatherHeader> {
  @override
  void initState() {
    super.initState();
  }

  TextStyle description = const TextStyle(fontSize: 24, fontWeight: FontWeight.w500);
  TextStyle temperature = const TextStyle(fontSize: 52, fontWeight: FontWeight.w600);

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
              Text(widget.city ?? "Wadafak", ),
              Text("${widget.temperature.round()}°C", style: temperature, ),
              Baseline(
                baseline: 10,
                baselineType: TextBaseline.alphabetic,
                child: Text(widget.weatherDescription ?? "API Failed", style: description)
              ),
              Text("${widget.maxTemp.round()}° / ${widget.minTemp.round()}° Feels like ${widget.perceivedTemp.round()}°")
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.26,
            alignment: AlignmentDirectional.bottomEnd,
            child: Icon(
                widget.icon,
              size: MediaQuery.of(context).size.width * 0.25,
            )
          )
        ],
    ));
  }
}
