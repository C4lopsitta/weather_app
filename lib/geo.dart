import 'dart:convert';
import 'dart:html';

import 'package:location/location.dart';
import 'package:http/http.dart' as http;

const String _nominatimURL = "nominatim.openstreetmap.org/";
const String _nominatimSearch = "search/";

class Geo {
  Geo(this.lat, this.lon, {this.serviceEnabled = false, this.permissionGranted = false, this.city});

  final double lat;
  final double lon;
  bool serviceEnabled;
  bool permissionGranted;
  final String? city;
}

Future<Geo> getLocation() async {
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionStatus;

  _serviceEnabled = await location.serviceEnabled();
  if(!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if(!_serviceEnabled) return Geo(0.0, 0.0, serviceEnabled: false);
  }

  _permissionStatus = await location.hasPermission();
  if(_permissionStatus == PermissionStatus.denied) {
    _permissionStatus = await location.requestPermission();
    if(_permissionStatus != PermissionStatus.granted) return Geo(0.0, 0.0, permissionGranted: false);
  }

  LocationData data = await location.getLocation();
  if(data.longitude == null || data.latitude == null) return Geo(0.0, 0.0, permissionGranted: true, serviceEnabled: true);

  return Geo(data.latitude!, data.longitude!, permissionGranted: true, serviceEnabled: true);
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



