class GraphListComponent {
  GraphListComponent({
    required this.list,
    required this.title
  });

  List<dynamic> list;
  String title;
  bool ignoreInDraw = false;

  double max() {
    double max = double.negativeInfinity;

    list.forEach((element) {
      if(element > max) max = element;
    });

    return max;
  }
}