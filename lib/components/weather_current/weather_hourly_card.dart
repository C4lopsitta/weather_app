import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/components/icon_text.dart';
import 'package:weather_app/forecast/weather_translator.dart';
import '../../forecast/hourly.dart';

class HourlyWeatherCard extends StatefulWidget {
  HourlyWeatherCard({
    super.key,
    required this.hourly
  });

  Hourly hourly;

  @override
  State<StatefulWidget> createState() => _HourlyWeatherCard();
}

class _HourlyWeatherCard extends State<HourlyWeatherCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card( child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            const Text("Forecast for the next 24 hours", style: TextStyle(fontSize: 16, height: 1.75)),
            const Divider(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _HourlyTile.buildList(_HourlyTile.tilesFromAPI(widget.hourly), context)
              ),
            )
          ],
        ),
      )),
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

  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.15,
      height: MediaQuery.of(context).size.height * 0.20,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(date),
          Icon(icon, size: 30),
          Text("${temp.round()}°"),
          const SizedBox(height: 5),
          Text("${humidity.round()}%", style: const TextStyle(fontSize: 12)),
          IconedText(
            icon: Icons.water_drop,
            text: "${precipitationProbability.round()}%",
            iconSize: 16,
            textStyle: const TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }
  
  static List<Widget> buildList(List<_HourlyTile> tiles, BuildContext  context) {
    List<Widget> list = [];
    tiles.forEach((tile) {
      list.add(tile.build(context));
      list.add(const SizedBox(width: 10));
    });
    return list;
  }

  static List<_HourlyTile> tilesFromAPI(Hourly hourly) {
    List<_HourlyTile> tiles = [];

    DateTime now = DateTime.now();
    DateTime limit = DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch + (24 * 60 * 60 * 1000));
    DateFormat format = DateFormat.Hm();

    for(int i = 0; i < hourly.times.length; i++) {
      DateTime time = DateTime.parse(hourly.times[i]);

      if((time.isAfter(now) && (time.isBefore(limit))) || (time.day == now.day && time.hour == now.hour)) {
        tiles.add(_HourlyTile(
            icon: WeatherTranslator.getWeatherIcon(hourly.weatherCodes[i]),
            date: format.format(time),
            temp: hourly.temperatures[i],
            precipitationProbability: (hourly.precipitationProbabilities[i] *
                1.0),
            humidity: (hourly.humidities[i] * 1.0)
        ));
      }
    }

    return tiles;
  }
}
