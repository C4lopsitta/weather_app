import 'package:flutter/material.dart';

class CurrentWeather extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CurrentWeather();
}

class _CurrentWeather extends State<CurrentWeather> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).viewPadding.top),
        Text("Current Weather")
      ],
    );
  }
}
