import 'dart:convert';

import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/exceptions/geo_exception.dart';


const String _nominatimURL = "nominatim.openstreetmap.org";
const String _nominatimSearch = "/search";
const String _nominatimReverse = "/reverse";


class Geo {
  Geo(this.lat, this.lon, {this.city, this.fullName});

  double lat;
  double lon;
  String? city;
  String? fullName;

  String toString() {
    return "GEO: {lat: $lat, lon: $lon, city: $city, fullName: $fullName}";
  }
}


Future<Geo> getLocation() async {
  Location location = Location();
  bool serviceEnabled;
  PermissionStatus permissionStatus;

  serviceEnabled = await location.serviceEnabled();
  if(!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if(!serviceEnabled) throw GeoException("Service unavailable", serviceEnabled: false);
  }

  permissionStatus = await location.hasPermission();
  if(permissionStatus == PermissionStatus.denied) {
    permissionStatus = await location.requestPermission();
    if(permissionStatus != PermissionStatus.granted) throw GeoException("Permission not granted", permission: false);
  }

  LocationData data = await location.getLocation();
  if(data.longitude == null || data.latitude == null) return Geo(0.0, 0.0);

  return Geo(data.latitude!, data.longitude!);
}


Future<List<Geo>?> geocodeLocation(String location) async {
  Map<String, String> params = {"q": location, "format": "geojson"};
  Uri uri;

  try {
    uri = Uri.https(_nominatimURL, _nominatimSearch, params);
  } catch (exception) { rethrow; }
  List<Geo> geocodes = [];

  await http.get(uri).then((response) {

    List<dynamic> features = jsonDecode(response.body)["features"];
    features.forEach((feature) {
      List<dynamic> coords = feature["geometry"]["coordinates"];
      String placeName = feature["properties"]["name"] ?? "UNDEFINED";
      String fullName = feature["properties"]["display_name"] ?? "UNDEFINED";

      geocodes.add(
          Geo(coords[1], coords[0], city: placeName, fullName: fullName));
    });
  });

  return (geocodes.isEmpty) ? null : geocodes;
}

Future<Geo> geocodeCurrentLocation(Geo current) async {
  Map<String, String> params = {
    "format": "geojson",
    "lat": "${current.lat}",
    "lon": "${current.lon}",
    "zoom": "12"
  };
  Uri uri = Uri.https(_nominatimURL, _nominatimReverse, params);

  await http.get(uri).then((response) {
    dynamic feature = jsonDecode(response.body)["features"][0];

    List<dynamic> coords = feature["geometry"]["coordinates"];

    current.lat = coords[1];
    current.city = feature["properties"]["name"] ?? "UNDEFINED";
    current.fullName = feature["properties"]["display_name"] ?? "UNDEFINED";
  });

  return current;
}

