enum SpeedUnit {
  KMH,
  MPH,
  MS;

  String unitToLabel() {
    List<String> labels = ["km/h", "mph", "m/s"];
    return labels[index];
  }
}