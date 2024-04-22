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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.5,
      height: MediaQuery.sizeOf(context).height * 0.2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text("Wind Speed", style: TextStyle(fontSize: 16, height: 1.75)),
              const Divider(),
              Row(
                children: [
                  Text("${widget.windDirection}°"),
                  Text("${widget.windSpeed} km/h"),
                ],
              ),
            ],
          ),
        )
      ),
    );
  }
}
