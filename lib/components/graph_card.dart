import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  LineChartData buildData() {
    var (range, type) = _GraphUtilities.getRangeSize(widget.graphStart, widget.graphEnd);

    return LineChartData(
      minX: 0,
      minY: 0,
      maxX: range * 1.0,
      maxY: 10,

      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: _GraphUtilities.getXGap(widget.graphStart, widget.graphEnd) * 1.0,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.blueGrey,
            strokeWidth: 1
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.blueGrey,
            strokeWidth: 1
          );
        }
      ),

      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _GraphUtilities.getXGap(widget.graphStart, widget.graphEnd) * 1.0,
            reservedSize: (type < 2) ? 25 : 35,
            getTitlesWidget: (value, meta) {
              return RotatedBox(
                quarterTurns: -3,
                child: Text(_GraphUtilities.getHorizontalLabel(widget.graphStart, widget.graphEnd, type, value), style: graphLabel),
              );
            }
          )
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Text('abc', style: graphLabel);
            }
          )
        )
      )
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 10,
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
            interval: 10,
            getTitlesWidget: (value, meta) {
              return RotatedBox(
                quarterTurns: -3,
                child: Text("${value.round()}"),
              );
            }
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
      maxX: (2024 - 1940),
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
  TextStyle graphLabel = const TextStyle(fontSize: 12);

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
                    buildData()
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

class _GraphUtilities {
  static (int, int) getRangeSize(DateTime start, DateTime end) {
    if(start.isAfter(end)) return (0, 0);

    int days = _getDaysInRange(start, end);
    if(days < 20) return (days, 0);

    int months = _getMonthsInRange(start, end);
    if(months < 20) return (months, 1);

    return (_getYearsInRange(start, end), 2);
  }

  static String getHorizontalLabel(DateTime start, DateTime end, int type, double offset) {
    if(type == 0) { // day range
      if(end.month == start.month) return "${start.day + offset.round()}";
      else {
        DateTime showedDate = start.add(Duration(days: offset.round()));
        DateFormat formatter = DateFormat.Md();
        if(start.year != end.year) formatter = DateFormat.yMd();
        return formatter.format(showedDate);
      }
    }
    if(type == 1) { // month range
      DateTime showedDate = start.add(Duration(days: (29.8 * offset).round()));
      DateFormat formatter = DateFormat.Md();
      if(start.year != end.year) formatter = DateFormat.yMd();
      return formatter.format(showedDate);
    }
    if(type == 2) {
      DateFormat formatter = DateFormat.yM();
      DateTime showedDate = start.add(Duration(days: (365 * offset).round()));
      return formatter.format(showedDate);
    }
    return "";
  }

  static int getXGap(DateTime start, DateTime end) {
    int range = getRangeSize(start, end).$1;

    if(range < 24) return 1;
    if(range < 180) return 10;
    return 100;
  }

  static int _getDaysInRange(DateTime start, DateTime end) {
    Duration duration = end.difference(start);
    return duration.inDays;
  }

  static int _getMonthsInRange(DateTime start, DateTime end) {
    int startYear = start.year;
    int endYear = end.year;
    int startMonth = start.month;
    int endMonth = end.month;

    int totalMonths = 0;

    for(int year = startYear; year <= endYear; year++) {
      for(int i = (year == startYear) ? startMonth : 1; i <= ((year == endYear) ? endMonth : 12); i++) {
        totalMonths++;
      }
    }

    return totalMonths;
  }

  static int _getYearsInRange(DateTime start, DateTime end) {
    int startYear = start.year;
    int endYear = end.year;

    return endYear - startYear;
  }
}
