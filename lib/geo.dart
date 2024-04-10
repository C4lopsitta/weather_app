import 'dart:convert';

import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/exceptions/geo_exception.dart';

const String _nominatimURL = "nominatim.openstreetmap.org/";
const String _nominatimSearch = "search/";

class Geo {
  Geo(this.lat, this.lon, {this.city});

  final double lat;
  final double lon;
  final String? city;
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
  Map<String, String> params = {"q": location, "format": "geocodejson"};
  Uri uri = Uri.https(_nominatimURL, _nominatimSearch, params);

  List<Geo> geocodes = [];

  http.get(uri).then((response) {
    List<Map<String, dynamic>> features = jsonDecode(response.body)["features"];
    features.forEach((feature) {
      List<dynamic> coords = feature["geometry"]["coordinates"];
      String placeName = feature["properties"]["geocoding"]["name"] ?? "UNDEFINED";

      geocodes.add(Geo(coords[1], coords[2], city: placeName));
    });

    return geocodes;
  });

  return null;
}



