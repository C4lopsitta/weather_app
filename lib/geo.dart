import 'dart:ffi';

import 'package:location/location.dart';

class Geo {
  Geo(this.lat, this.lon, this.serviceEnabled, this.permissionGranted);

  final double lat;
  final double lon;
  bool serviceEnabled = true;
  bool permissionGranted = true;
}

Future<Geo> _getLocation() async {
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
  return Geo(data.latitude!, data.longitude!, true, true); //TODO)) Add checks
}



