import 'package:flutter/material.dart';

import '../forecast/Hourly.dart';

class HourlyWeatherCard extends StatefulWidget {
  HourlyWeatherCard({
    super.key,
    required this.hourly
  });

  Hourly hourly;

  @override
  State<StatefulWidget> createState() => _HourlyWeatherCard();
}

class _HourlyWeatherCard extends State<StatefulWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text("Forecast for the next 24 hours"),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _HourlyTile {
  _HourlyTile({
    required this.icon,
    required this.date,
    required this.temp,
    required this.precipitationProbability,
    required this.humidity
  });

  IconData icon;
  String date;
  double temp;
  double precipitationProbability;
  double humidity;

  Widget build() {
    return Text("Banana");
  }
  
  static List<Widget> buildList(List<_HourlyTile> tiles) {
    List<Widget> list = [];
    tiles.forEach((tile) => list.add(tile.build()));
    return list;
  }

  static List<_HourlyTile> tilesFromAPI(Hourly hourly) {
    List<_HourlyTile> tiles = [];

    for(int i = 0; i < hourly.times.length; i++) {
      tiles.add(_HourlyTile(
          icon: Icons.local_drink_rounded,
          date: hourly.times[i],
          temp: hourly.temperatures[i],
          precipitationProbability: hourly.precipitationProbability[i],
          humidity: hourly.humidities[i]
      ));
    }

    return tiles;
  }
}
