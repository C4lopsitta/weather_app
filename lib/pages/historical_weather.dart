import 'package:flutter/material.dart';

class HistoricalWeather extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HistoricalWeather();
}

class _HistoricalWeather extends State<HistoricalWeather> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Historical Weather")
      ],
    );
  }
}
