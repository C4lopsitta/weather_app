import 'package:shared_preferences/shared_preferences.dart';

import 'apis/geo.dart';

class Preferences {
  static SharedPreferences? preferences;

  static const String geoCities = "cities";
  static const String geoFullNames = "fullNames";
  static const String geoLats = "lat";
  static const String geoLons = "lon";

  static Future getInstance() async {
    preferences = await SharedPreferences.getInstance();
  }

  // because sharedpreferences allows for native types only, values will be split
  static void setPreferredLocations(List<Geo> geos) async {
    if(preferences == null) return;

    List<String> cities = [];
    List<String> fullNames = [];
    List<String> lats = [];
    List<String> lons = [];

    geos.forEach((geo) {
      cities.add(geo.city ?? "");
      fullNames.add(geo.fullName ?? "");
      lats.add("${geo.lat}");
      lons.add("${geo.lon}");
    });

    await preferences!.setStringList(geoCities, cities);
    await preferences!.setStringList(geoFullNames, fullNames);
    await preferences!.setStringList(geoLons, lons);
    await preferences!.setStringList(geoLats, lats);
  }

  static Future<List<Geo>> getPreferredLocaitions() async {
    if(preferences == null) return [];

    List<Geo> favourites = [];

    List<String> cities = preferences!.getStringList(geoCities) ?? [];
    List<String> fullNames = preferences!.getStringList(geoFullNames) ?? [];
    List<String> lats = preferences!.getStringList(geoLats) ?? [];
    List<String> lons = preferences!.getStringList(geoLons) ?? [];

    //TODO)) Add length equality checks

    for(int i = 0; i < cities.length; i++) {
      favourites.add(Geo(
        double.parse(lats[i]),
        double.parse(lons[i]),
        city: cities[i],
        fullName: fullNames[i]
      ));
    }

    return favourites;
  }


}