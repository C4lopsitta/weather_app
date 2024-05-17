import 'package:flutter/material.dart';

class UvIndexCard extends StatefulWidget {
  UvIndexCard({
    super.key,
    required this.uvIndex
  });

  double uvIndex;

  @override
  State<StatefulWidget> createState() => _UvIndexCard();
}

class _UvIndexCard extends State<UvIndexCard> {
  @override
  void initState() {
    super.initState();
  }

  TextStyle style = const TextStyle( fontSize: 16 );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.1,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric( horizontal: 18 ),
          child: Row(
            children: [
              const Icon(Icons.brightness_high_rounded, size: 30),
              const SizedBox( width: 12 ),
              const Text("UV Index"),
              const Spacer(),
              Text(widget.uvIndex.toStringAsFixed(2), style: style)
            ],
          ),
        ),
      ),
    );
  }
}
