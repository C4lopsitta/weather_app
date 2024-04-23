import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraphCard extends StatefulWidget {
  GraphCard({
    super.key,
    required this.graphStart,
    required this.graphEnd,
    required this.graphY,
    required this.title
  });

  DateTime graphStart;
  DateTime graphEnd;
  List<List<double>> graphY;
  String title;

  @override
  State<StatefulWidget> createState() => _GraphCard();
}

class _GraphCard extends State<GraphCard> {
  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.red,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.red,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: false,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
          ),
        ),
      ],
    );
  }

  TextStyle title = const TextStyle(fontSize: 16, height: 1.75);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
            child: Column(
            children: [
              Text(widget.title, style: title),
              const Divider(),
              AspectRatio(
                aspectRatio: 1.333333333333333,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                  child: LineChart(
                      mainData()
                  ),
                ),
              ),
            ],
          )
        )
      )
    );
  }
}
