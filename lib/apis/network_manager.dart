import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkManager {
  static Future<bool> isOnline() async {
    var status = await Connectivity().checkConnectivity();
    return (status.contains(ConnectivityResult.none)) ? false : true;
  }
}
