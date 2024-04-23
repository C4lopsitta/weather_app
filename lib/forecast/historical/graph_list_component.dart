class GraphListComponent {
  GraphListComponent({
    required this.list,
    required this.title
  });

  List<dynamic> list;
  String title;

  double max() {
    double max = double.negativeInfinity;

    list.forEach((element) {
      if(element > max) max = element;
    });

    return max;
  }
}