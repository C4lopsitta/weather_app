enum TemperatureUnit {
  CELSIUS,
  KELVIN,
  FARENHEIT;

  String unitToLabel() {
    List<String> labels = ["°C", " K", "°F"];
    return labels[index];
  }
}
