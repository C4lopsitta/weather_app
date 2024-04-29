import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/forecast/historical/graph_list_component.dart';

class GraphCard extends StatefulWidget {
  GraphCard({
    super.key,
    required this.graphStart,
    required this.graphEnd,
    required this.graphLines,
    required this.title
  });

  DateTime graphStart;
  DateTime graphEnd;
  List<GraphListComponent> graphLines;
  String title;

  double graphMin = 0;
  double graphMax = 0;

  @override
  State<StatefulWidget> createState() => _GraphCard();
}

class _GraphCard extends State<GraphCard> {
  @override
  void initState() {
    super.initState();
    widget.graphLines.forEach((list) {
      list.list.forEach((value) {
        if((value ?? 0) * 1.0 > widget.graphMax) widget.graphMax = (value ?? 0) * 1.0;
        if((value ?? 0) * 1.0 < widget.graphMin) widget.graphMin = (value ?? 0) * 1.0;
      });
    });

    widget.graphMax += 1;
    widget.graphMin -= 1;
  }

  LineChartData buildData() {
    var (range, type) = _GraphUtilities.getRangeSize(widget.graphStart, widget.graphEnd);

    return LineChartData(
      minX: 0,
      minY: widget.graphMin,
      maxX: (widget.graphLines[0].list.length / (widget.graphLines[0].list.length / _GraphUtilities.getXGap(widget.graphStart, widget.graphEnd))).floorToDouble(),
      maxY: widget.graphMax,

      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: (widget.graphMax < 50) ? 1 : (widget.graphMax < 150) ? 25 : (widget.graphMax < 1000) ? 100 : 1000,
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

      //TODO)) Fix vertical tile
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _GraphUtilities.getXGap(widget.graphStart, widget.graphEnd) * 1.0,
            reservedSize: (type < 2) ? 28 : 48,
            getTitlesWidget: (value, meta) {
              return RotatedBox(
                quarterTurns: -3,
                child: Text(" ${_GraphUtilities.getHorizontalLabel(widget.graphStart, widget.graphEnd, type, value)}", style: graphLabel),
              );
            }
          )
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1000000,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Text('', style: graphLabel);
            }
          )
        )
      ),

      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white10),
      ),

      lineBarsData: _buildChartData(),
    );
  }

  List<LineChartBarData> _buildChartData() {
    List<LineChartBarData> barData = [];
    int index = 0;

    widget.graphLines.forEach((line) {
      if(!line.ignoreInDraw) {
        barData.add(LineChartBarData(
          spots: _buildLineSpots(line),
          isCurved: false,
          barWidth: 3,
          isStrokeCapRound: true,
          color: line.color,
          belowBarData: BarAreaData(show: false),
          dotData: const FlDotData(show: true),
          aboveBarData: BarAreaData(show: false),
        ));
        index++;
      }
    });

    return barData;
  }

  List<FlSpot> _buildLineSpots(GraphListComponent line) {
    List<FlSpot> spots = [];
    double index = 0;

    double itemsPerGap = line.list.length / _GraphUtilities.getXGap(widget.graphStart, widget.graphEnd);
    double itemOffset = 1 / itemsPerGap;

    line.list.forEach((value) {
      spots.add(FlSpot(
        index, (value ?? 0) * 1.0
      ));

      index += itemOffset;
    });

    return spots;
  }

  List<Widget> _buildLegendList() {
    List<Widget> widgets = [];

    for(int i = 0; i < widget.graphLines.length; i++) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: GestureDetector(
          onTap: () {
            setState(() {
              widget.graphLines[i].ignoreInDraw = !widget.graphLines[i].ignoreInDraw;
            });
          },
          child: Row(
            children: [
              Icon((widget.graphLines[i].ignoreInDraw) ? Icons.circle_outlined : Icons.circle, color: widget.graphLines[i].color, size: 14),
              const SizedBox(width: 8),
              Text(widget.graphLines[i].title, style: const TextStyle(fontSize: 10))
            ],
          )
        )
      ));
    }

    return widgets;
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
              const Divider(),
              const Text("Legend", style: TextStyle(fontSize: 12)),
            ] + _buildLegendList(),
          )
        )
      )
    );
  }
}

class _GraphUtilities {
  static (int, int) getRangeSize(DateTime start, DateTime end) {
    //TODO)) Fix this (always return total days)
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
