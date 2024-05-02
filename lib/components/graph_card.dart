import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/forecast/historical/graph_list_component.dart';

import '../routes/graph_detailed_view.dart';
import 'graph_utilities.dart';

class GraphCard extends StatefulWidget {
  GraphCard({
    super.key,
    required this.graphStart,
    required this.graphEnd,
    required this.graphLines,
    required this.title
  }) {
    double min = 0;
    double max = 0;

    graphLines.forEach((list) {
      list.list.forEach((value) {
        if((value ?? 0) * 1.0 > max) max = (value ?? 0) * 1.0;
        if((value ?? 0) * 1.0 < min) min = (value ?? 0) * 1.0;
      });
    });

    graphMax = max + 1;
    graphMin = min - 1;
  }

  DateTime graphStart;
  DateTime graphEnd;
  List<GraphListComponent> graphLines;
  String title;

  late final double graphMin;
  late final double graphMax;

  @override
  State<StatefulWidget> createState() => _GraphCard();
}

class _GraphCard extends State<GraphCard> {
  @override
  void initState() {
    super.initState();
  }

  LineChartData buildData() {
    var (range, type) = GraphUtilities.getRangeSize(widget.graphStart, widget.graphEnd);

    return LineChartData(
      minX: 0,
      minY: widget.graphMin,
      maxX: (widget.graphLines[0].list.length / (widget.graphLines[0].list.length / GraphUtilities.getXGap(widget.graphStart, widget.graphEnd))).floorToDouble(),
      maxY: widget.graphMax,

      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: (widget.graphMax < 50) ? 1 : (widget.graphMax < 150) ? 25 : (widget.graphMax < 1000) ? 100 : 1000,
        verticalInterval: GraphUtilities.getXGap(widget.graphStart, widget.graphEnd) * 1.0,
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
            interval: GraphUtilities.getXGap(widget.graphStart, widget.graphEnd) * 1.0,
            reservedSize: (type < 2) ? 28 : 48,
            getTitlesWidget: (value, meta) {
              return RotatedBox(
                quarterTurns: -3,
                child: Text(" ${GraphUtilities.getHorizontalLabel(widget.graphStart, widget.graphEnd, type, value)}", style: graphLabel),
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

    double itemsPerGap = line.list.length / GraphUtilities.getXGap(widget.graphStart, widget.graphEnd);
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
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(widget.title, style: title),
                  Container(
                    alignment: AlignmentDirectional.centerEnd,
                    child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                GraphDetailedView(
                                  graphStart: widget.graphStart,
                                  graphEnd: widget.graphEnd,
                                  graphLines: widget.graphLines,
                                  title: widget.title,
                                )));
                        },
                        icon: const Icon(Icons.open_in_full_rounded)
                    )
                  )

                ],
              ),
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


