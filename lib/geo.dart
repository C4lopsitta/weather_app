import 'package:location/location.dart';
import 'package:http/http.dart' as http;

const String _nominatimURL = "nominatim.openstreetmap.org/";
const String _nominatimSearch = "search/";

class Geo {
  Geo(this.lat, this.lon, this.serviceEnabled, this.permissionGranted);

  final double lat;
  final double lon;
  bool serviceEnabled = true;
  bool permissionGranted = true;
}

Future<Geo> getLocation() async {
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionStatus;

  _serviceEnabled = await location.serviceEnabled();
  if(!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if(!_serviceEnabled) return Geo(0.0, 0.0, false, false);
  }

  _permissionStatus = await location.hasPermission();
  if(_permissionStatus == PermissionStatus.denied) {
    _permissionStatus = await location.requestPermission();
    if(_permissionStatus != PermissionStatus.granted) return Geo(0.0, 0.0, true, false);
  }

  LocationData data = await location.getLocation();
  if(data.longitude == null || data.latitude == null) return Geo(0.0, 0.0, true, true);

  return Geo(data.latitude!, data.longitude!, true, true);
}

Future<Geo> geocodeLocation(String location) async {
  Map<String, String> params = {"q": location, "format": "jsonv2"};
  Uri uri = Uri.https(_nominatimURL, _nominatimSearch, params);

  http.get(uri).then((response) {

  });
}



