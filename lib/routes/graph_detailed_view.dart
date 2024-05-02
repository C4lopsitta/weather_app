import 'package:flutter/material.dart';

import '../forecast/historical/graph_list_component.dart';

class GraphDetailedView extends StatefulWidget {
  GraphDetailedView({
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
  State<StatefulWidget> createState() => _GraphDetailedView();
}

class _GraphDetailedView extends State<GraphDetailedView> {
  @override
  void initState() {
    super.initState();
  }

  void openSheet() {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        enableDrag: true,
        clipBehavior: Clip.hardEdge,
        builder: (context) {
          return SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text("Legend", style: TextStyle(fontSize: 18, height: 2)),
                      const Divider(),
                    ] + _buildLegendList() + [
                      const SizedBox(height: 12),
                      const Text("Tap on an item to hide it", style: TextStyle(height: 1.5)),
                    ],
                ),
              )
          );
        }
    );
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
                  Icon((widget.graphLines[i].ignoreInDraw) ? Icons.circle_outlined : Icons.circle, color: widget.graphLines[i].color, size: 20),
                  const SizedBox(width: 8),
                  Text(widget.graphLines[i].title, style: const TextStyle(fontSize: 12))
                ],
              )
          )
      ));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () {
            openSheet();
          }, icon: const Icon(Icons.legend_toggle_rounded))
        ],
      ),
      body: const Text("Los body"),
    );
  }

}
