// What this will become
// Sooner or later, an autosave of the last loaded API results, city and relative
// call time will be added through the Local Preferences Storage API.

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileStorage {
  static Directory? directory;

  static void initialize() async {
    if(directory != null) return;
    directory = await getApplicationDocumentsDirectory();
  }

  static void writeFile(String filename, String filedata) async {
    if(directory == null) return;

    File file = File("${directory!.path}/$filename");
    await file.writeAsString(filedata);

    return;
  }

  static Future<String?> readFile(String filename) async {
    if(directory == null) return null;

    File file = File("${directory!.path}/$filename");
    String data = await file.readAsString();

    return data;
  }

  static const String DAILY_FILE = "dailyWeather.json";
  static const String HOURLY_FILE = "hourlyWeather.json";
  static const String CURRENT_FILE = "currentWeather.json";
}

class PreferencesStorage {
  static SharedPreferences? preferences;

  static Future initialize() async {
    if(preferences != null) return;
    preferences = await SharedPreferences.getInstance();
  }

  static Future writeString(String preference, String data) async {
    if(preferences == null) return;
    preferences!.setString(preference, data);
  }

  static Future writeDouble(String preference, double data) async {
    if(preferences == null) return;
    preferences!.setDouble(preference, data);
  }

  static Future writeInteger(String preference, int data) async {
    if(preferences == null) return;
    preferences!.setInt(preference, data);
  }

  static Future writeBoolean(String preference, bool data) async {
    if(preferences == null) return;
    preferences!.setBool(preference, data);
  }



  static Future<String?> readString(String preference) async {
    if(preferences == null) return "";
    return preferences!.getString(preference);
  }

  static Future<double?> readDouble(String preference) async {
    if(preferences == null) return double.negativeInfinity;
    return preferences!.getDouble(preference);
  }

  static Future<int?> readInteger(String preference) async {
    if(preferences == null) return null;
    return preferences!.getInt(preference);
  }

  static Future<bool?> readBoolean(String preference) async {
    if(preferences == null) return null;
    return preferences!.getBool(preference);
  }

  static Future drop(String preference) async {
    if(preferences == null) return null;
    await preferences!.remove(preference);
  }

  static const String GEO_LAT = "geolat";
  static const String GEO_LON = "geolon";
  static const String GEO_CITY = "geocity";
  static const String GEO_FULLNAME = "geofullname";
  static const String GEO_LAST_LOAD = "geolastload";
}

class SettingPreferences {
  static const String USE_GPS_DEFAULT = "gpsdefault";
  static const String DONT_OVERWRITE_LOCATION = "keeplocation";
}
