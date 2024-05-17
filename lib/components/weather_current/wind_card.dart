import 'package:flutter/material.dart';

class WindCard extends StatefulWidget {
  WindCard({
    super.key,
    required this.windDirection,
    required this.windSpeed
  });

  String windDirection;
  double windSpeed;

  @override
  State<StatefulWidget> createState() => _WindCard();
}

class _WindCard extends State<WindCard> {
  @override
  void initState() {
    super.initState();
  }

  TextStyle speedStyle = const TextStyle(fontSize: 24);
  TextStyle directionStyle = const TextStyle(fontSize: 14);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text("Wind Speed", style: TextStyle(fontSize: 16, height: 1.75)),
              const Divider(),
              Center(
                heightFactor: 1.4,
                child: Column(
                  children: [
                    Text("${widget.windSpeed} km/h", style: speedStyle),
                    Text("Direction ${widget.windDirection}°", style: directionStyle),
                  ],
                )
              ),
            ],
          ),
        )
    );
  }
}
