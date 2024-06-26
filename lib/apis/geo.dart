import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/exceptions/geo_exception.dart';
import 'package:weather_app/preferences_storage.dart';

class Geo {
  Geo(this.lat, this.lon, {this.city, this.fullName});

  //region attributes
  double lat;
  double lon;
  String? city;
  String? fullName;
  //endregion

  static const String favouriteFileLocation = "favourites.json";
  static List<Geo> favouriteLocations = [];

  bool isEqual(Geo geo) =>
      (geo.city == city &&
          geo.lat == lat &&
          geo.lon == lon &&
          geo.fullName == fullName);

  @override
  String toString() {
    return "GEO: {lat: $lat, lon: $lon, city: $city, fullName: $fullName}";
  }

  Map<String, dynamic> toJson() {
    return {
      "city": this.city,
      "fullName": this.fullName,
      "coordinates": {
        "latitude": this.lat,
        "longitude": this.lon
      }
    };
  }

  static Geo fromJson(Map<String, dynamic> json) {
    double lat = json["coordinates"]["latitude"];
    double lon = json["coordinates"]["longitude"];

    return Geo(
      lat,
      lon,
      city: json["city"] ?? "",
      fullName: json["fullName"] ?? "",
    );
  }

  //region apis
  static const String _nominatimURL = "nominatim.openstreetmap.org";
  static const String _nominatimSearch = "/search";
  static const String _nominatimReverse = "/reverse";

  static Future<Geo> getLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionStatus;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw GeoException(
            "Service unavailable", serviceEnabled: false);
      }
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        throw GeoException(
            "Permission not granted", permission: false);
      }
    }

    LocationData data = await location.getLocation();
    if (data.longitude == null || data.latitude == null) return Geo(0.0, 0.0);

    return Geo(data.latitude!, data.longitude!);
  }

  static Future<List<Geo>?> geocodeLocation(String location) async {
    Map<String, String> params = {
      "q": location,
      "format": "geojson",
      "featureType": "settlement"
    };
    Uri uri;

    try {
      uri = Uri.https(_nominatimURL, _nominatimSearch, params);
    } catch (exception) {
      rethrow;
    }
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

  static Future<Geo> geocodeCurrentLocation(Geo current) async {
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
      current.lon = coords[0];
      current.city = feature["properties"]["name"] ?? "UNDEFINED";
      current.fullName = feature["properties"]["display_name"] ?? "UNDEFINED";
    });

    return current;
  }
  //endregion

  static Future<void> loadFavourites() async {
    FileStorage.initialize();
    String? jsonString = await FileStorage.readFile(favouriteFileLocation);

    if(jsonString == null) return;

    List<dynamic> geos = jsonDecode(jsonString);

    favouriteLocations = [];
    geos.forEach((geo) {
      Geo geoObject = Geo.fromJson(geo as Map<String, dynamic>);
      favouriteLocations.add(geoObject);
    });
  }

  static void storeFavourites() async {
    FileStorage.initialize();
    String json = "[";

    for(int i = 0; i < favouriteLocations.length; i++) {
      json += jsonEncode(favouriteLocations[i].toJson());
      if(i != (favouriteLocations.length - 1)) json += ',';
    }

    json += ']';

    FileStorage.writeFile(favouriteFileLocation, json);
  }

  static void addFavourite(Geo geo) {
    bool unique = true;
    favouriteLocations.forEach((city) {
      if(city.isEqual(geo)) unique = false;
    });

    if(unique == false) return;
    favouriteLocations.add(geo);
  }

  static void popFavourite(Geo geo) {
    for(int i = 0; i < favouriteLocations.length; i++) {
      if(favouriteLocations[i].isEqual(geo)) {
        favouriteLocations.removeAt(i);
        return;
      }
    }
  }

  static bool isFavourite(Geo geo) {
    bool status = false;
    favouriteLocations.forEach((city) {
      if(city.isEqual(geo)) status = true;
    });
    return status;
  }

  StatefulBuilder toListItem(Function(Geo) weatherSetter, {Function()? triggerFavouriteListUpdate}) {
    return StatefulBuilder(
      builder: (BuildContext context, Function(Function()) setter) {
        bool isFavourite = Geo.isFavourite(this);
        return ListTile(
          title: Text(city ?? ""),
          subtitle: Text(fullName ?? ""),
          onTap: () => weatherSetter(this),
          trailing: IconButton(
            icon: Icon((isFavourite) ? Icons.star_rounded : Icons.star_border_rounded),
            onPressed: () {
              Geo self = this;
              if(Geo.isFavourite(self)) {
                Geo.popFavourite(self);
                Geo.storeFavourites();
                setter(() => isFavourite = false);
                if(triggerFavouriteListUpdate != null)
                  triggerFavouriteListUpdate();
              } else {
                Geo.addFavourite(self);
                Geo.storeFavourites();
                setter(() => isFavourite = true);
                if(triggerFavouriteListUpdate != null)
                  triggerFavouriteListUpdate();
              }
            },
          )
        );
      }
    );
  }

  static List<StatefulBuilder> buildFavouritesList(Function(Geo self) onTap) {
    List<StatefulBuilder> list = [];

    favouriteLocations.forEach((location) {
      list.add(location.toListItem((Geo self) => onTap(self)));
    });

    return list;
  }
}
