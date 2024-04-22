import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SunsetSunriseCard extends StatefulWidget {
  SunsetSunriseCard({
    super.key,
    required this.sunrise,
    required this.sunset
  });

  String sunrise;
  String sunset;

  @override
  State<StatefulWidget> createState() => _SunsetSunriseCard();
}

class _SunsetSunriseCard extends State<SunsetSunriseCard> {
  @override
  void initState() {
    super.initState();
  }

  DateFormat formatter = DateFormat.Hm();

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text("Sunrise and Sunset", style: TextStyle(fontSize: 16, height: 1.75)),
              const Divider(),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.wb_twilight_rounded),
                    Text(formatter.format(DateTime.parse(widget.sunrise))),
                    const Icon(Icons.nights_stay_rounded),
                    Text(formatter.format(DateTime.parse(widget.sunset)))
                  ],
                )
              ),
            ],
          ),
        )
    );
  }
}
