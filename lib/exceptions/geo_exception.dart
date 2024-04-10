import 'package:http/http.dart';

class GeoException extends ClientException {
  GeoException(super.message, {this.permission = true, this.serviceEnabled = true});

  final bool permission;
  final bool serviceEnabled;

  bool get getPermissionStatus => permission;
  bool get getServiceStatus => serviceEnabled;
}
