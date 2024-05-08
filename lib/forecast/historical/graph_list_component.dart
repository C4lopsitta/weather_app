import 'package:flutter/material.dart';

class GraphListComponent {
  GraphListComponent({
    required this.list,
    required this.title,
    required this.color,
  });

  List<dynamic> list;
  String title;
  bool ignoreInDraw = false;
  Color color;

  double max() {
    double max = double.negativeInfinity;

    list.forEach((element) {
      if(element > max) max = element;
    });

    return max;
  }

  static final List<Color> colors = [
    const Color.fromARGB(255, 255, 10, 5),
    Colors.blueAccent,
    Colors.yellow,
    Colors.deepOrange,
    Colors.pink,
    Colors.green
  ];
}