import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/components/icon_text.dart';
import 'package:weather_app/forecast/daily.dart';
import 'package:weather_app/forecast/weather_translator.dart';

class DailyWeatherCard extends StatefulWidget {
  DailyWeatherCard({
    super.key,
    required this.daily
  });

  Daily daily;


  @override
  State<StatefulWidget> createState() => _DailyWeatherCard();
}

class _DailyWeatherCard extends State<DailyWeatherCard> {
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
          children: <Widget>[
            const Text("Forecast for the next 7 days", style: TextStyle(fontSize: 16, height: 1.75)),
            const Divider(),
          ] + _DailyTile.buildList(_DailyTile.tilesFromAPI(widget.daily), context),
        ),
      )),
    );
  }
}

class _DailyTile {
  _DailyTile({
    required this.icon,
    required this.min,
    required this.max,
    required this.uvIndex,
    required this.precipitationProbability,
    required this.date
  });

  IconData icon;
  double min;
  double max;
  double uvIndex;
  double precipitationProbability;
  String date;

  Widget build(BuildContext context) {
    DateTime parsedDate = DateTime.parse(date);
    DateFormat formatter = DateFormat.E();
    String day = formatter.format(parsedDate);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.05,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: 30,
              child: Center( child: Text(day) ),
            ),
            SizedBox(
              width: 45,
              child: Icon(icon, size: 30),
            ),
            SizedBox(
              width: 100,
              child: Center( child: Text("${max.round()}° / ${min.round()}°") ),
            ),
            Container(
              alignment: AlignmentDirectional.centerStart,
              width: 75,
              child: IconedText(icon: Icons.water_drop, text: "${precipitationProbability.round()}%")
            )
          ],
        ),
      )
    );
  }

  static List<Widget> buildList(List<_DailyTile> tiles, BuildContext context) {
    List<Widget> list = [];
    tiles.forEach((tile) {
      list.add(tile.build(context));
      list.add(const SizedBox(height: 8));
    });
    return list;
  }

  static List<_DailyTile> tilesFromAPI(Daily daily) {
    List<_DailyTile> tiles = [];

    for(int i = 0; i < daily.weatherCode.length; i++) {
      tiles.add(_DailyTile(
          icon: WeatherTranslator.getWeatherIcon(daily.weatherCode[i]),
          min: daily.minTemperature[i] * 1.0,
          max: daily.maxTemperature[i] * 1.0,
          uvIndex: (daily.uvMaxIndex?[i] ?? 12) * 1.0,
          precipitationProbability: (daily.precipitationProbability?[i] ?? 69) * 1.0,
          date: daily.dates[i]
      ));
    }

    return tiles;
  }
}
