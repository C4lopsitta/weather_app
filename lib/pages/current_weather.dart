import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:weather_app/apis/geo.dart';
import 'package:weather_app/apis/weather_api.dart';
import 'package:weather_app/components/daily_weather_card.dart';
import 'package:weather_app/components/full_address_card.dart';
import 'package:weather_app/components/sunset_sunrise_card.dart';
import 'package:weather_app/components/uv_index_card.dart';
import 'package:weather_app/components/weather_header.dart';
import 'package:weather_app/components/weather_hourly_card.dart';
import 'package:weather_app/components/wind_card.dart';
import 'package:weather_app/preferences_storage.dart';

import '../forecast/current.dart';
import '../forecast/daily.dart';
import '../forecast/hourly.dart';

class CurrentWeather extends StatefulWidget {
  const CurrentWeather({super.key});

  @override
  State<StatefulWidget> createState() => _CurrentWeather();
}

class _CurrentWeather extends State<CurrentWeather> {
  List<Widget> suggestions = [];
  Geo? _selectedGeo;
  BuildContext? sheetContext;
  bool isGettingLocation = false;
  bool isGettingSuggestions = false;
  DateTime lastWeatherUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  String? errorEncountered;

  bool isWeatherReady = false;

  Current? currentWeather;
  Daily? dailyWeather;
  Hourly? hourlyWeather;

  @override
  void initState() {
    super.initState();
    loadFromStorage();
  }

  Future loadFromStorage() async {
    print("Loading!");

    await PreferencesStorage.initialize();

    if(await PreferencesStorage.readBoolean(SettingPreferences.USE_GPS_DEFAULT) == true) {
      return geocodeCurrentLocation();
    }

    //load last geo (if exists)
    int? lastLoadTimeFromStorage = await PreferencesStorage.readInteger(PreferencesStorage.GEO_LAST_LOAD);
    if(lastLoadTimeFromStorage == null) return;
    String? city = await PreferencesStorage.readString(PreferencesStorage.GEO_CITY);
    String? fullName = await PreferencesStorage.readString(PreferencesStorage.GEO_FULLNAME);
    double? lat = await PreferencesStorage.readDouble(PreferencesStorage.GEO_LAT);
    double? lon = await PreferencesStorage.readDouble(PreferencesStorage.GEO_LON);

    setState(() {
      _selectedGeo = Geo(lat ?? 0.0, lon ?? 0.0, city: city, fullName: fullName);
      lastWeatherUpdate = DateTime.fromMillisecondsSinceEpoch(lastLoadTimeFromStorage);
    });

    print("Loaded!");

    _searchTextController.text = city ?? "";
    getWeatherForSelectedGeo();
  }

  void openSheet() {
    if(_searchTextController.text.isNotEmpty) {
      showModalBottomSheet(
          context: context,
          showDragHandle: true,
          enableDrag: true,
          builder: (context) {
            sheetContext = context;
            return SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Suggestions"),
                            IconButton(
                                onPressed: () {
                                  sheetContext = null;
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close_rounded)
                            )
                          ],
                        )
                      ),
                      Expanded( child: SingleChildScrollView(
                        clipBehavior: Clip.hardEdge,
                        scrollDirection: Axis.vertical,
                        child: Expanded(
                            child: Column(
                            children: suggestions,
                      )))),
                    ]
                  ),
                )
            );
          }
      );
    }
  }

  Future getSuggestions(String searchKey) async {
    setState(() {
      isGettingSuggestions = true;
      errorEncountered = null;
    });
    List<ListTile> liveSuggestions = [];

    await Geo.geocodeLocation(searchKey).then((geos) {
      geos?.forEach((geo) {
        print(geo.toString());
        liveSuggestions.add(ListTile(
          title: Text(geo.city ?? "UNDEFINED"),
          subtitle: Text(geo.fullName ?? ""),
          onTap: () {
            Geo self = geo;
            setState(() {
              _selectedGeo = self;
              if(geo.city != null) _searchTextController.text = geo.city!;
              isWeatherReady = false;
              errorEncountered = null;
            });
            if(sheetContext != null) Navigator.pop(sheetContext!);
            getWeatherForSelectedGeo();
          },
        ));
      });

      setState(() {
        isGettingSuggestions = false;
        suggestions = liveSuggestions;
      });
    });
  }

  Future geocodeCurrentLocation() async {
    setState(() {
      isGettingLocation = true;
      isWeatherReady = false;
      errorEncountered = null;
    });
    try {
      Geo current = await Geo.getLocation();
      current = await Geo.geocodeCurrentLocation(current);

      setState(() {
        if(current.city != null) _searchTextController.text = current.city!;
        isGettingLocation = false;
        _selectedGeo = current;
      });

    } catch(exception) {
      print(exception.toString());

    }

    getWeatherForSelectedGeo();
  }

  Future getWeatherForSelectedGeo() async {
    if(_selectedGeo == null) return;

    try {
      WeatherApi current = WeatherApi(geo: _selectedGeo!);
      currentWeather = await current.call_api_current();
      dailyWeather = await current.call_api_daily();
      hourlyWeather = await current.call_api_hourly();

      lastWeatherUpdate = DateTime.now();

      setState(() {
        isWeatherReady = true;
        errorEncountered = null;
      });

    } on ClientException catch (ex) {
      print(ex.toString());
      setState(() {
        isWeatherReady = true;
        errorEncountered = ex.message;
      });
      return;
    } finally {
      storeGeo();
    }
  }

  void storeGeo() async {
    await PreferencesStorage.initialize();

    if(await PreferencesStorage.readBoolean(SettingPreferences.DONT_OVERWRITE_LOCATION) == true &&
       await PreferencesStorage.readInteger(PreferencesStorage.GEO_LAST_LOAD) != null) return;

    await PreferencesStorage.writeString(PreferencesStorage.GEO_CITY, _selectedGeo!.city ?? "");
    await PreferencesStorage.writeString(PreferencesStorage.GEO_FULLNAME, _selectedGeo!.fullName ?? "");
    await PreferencesStorage.writeDouble(PreferencesStorage.GEO_LAT, _selectedGeo!.lat);
    await PreferencesStorage.writeDouble(PreferencesStorage.GEO_LON, _selectedGeo!.lon);
    await PreferencesStorage.writeInteger(PreferencesStorage.GEO_LAST_LOAD, lastWeatherUpdate.millisecondsSinceEpoch);

    print("Stored Geo");
  }

  final TextEditingController _searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if(_selectedGeo != null && isWeatherReady == true) {
          setState(() { isWeatherReady = false; });
          getWeatherForSelectedGeo();
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: MediaQuery.of(context).viewPadding.top),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SearchBar(
                  controller: _searchTextController,
                  onSubmitted: (text) {
                    getSuggestions(text).then((value) => openSheet());
                  },
                  trailing: [ IconButton(
                    icon: (!isGettingSuggestions) ?
                      const Icon(Icons.search_rounded) :
                      const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator()
                      ),
                    onPressed: () {
                      String text = _searchTextController.text;
                      getSuggestions(text).then((value) => openSheet());
                    },
                  ),  ],
                  leading: (isGettingLocation) ?
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator()
                      )
                    ) : IconButton(
                      icon: const Icon(Icons.location_on_rounded),
                      onPressed: () => geocodeCurrentLocation(),
                    ),
                ),
                if(_selectedGeo != null)
                  if(isWeatherReady && ( errorEncountered == null || (errorEncountered?.isEmpty ?? true) ))
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 148
                          - MediaQuery.of(context).viewPadding.top,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            WeatherHeader(
                              city: _selectedGeo!.city,
                              temperature: currentWeather!.temperature,
                              status: currentWeather!.weatherCode,
                              minTemp: dailyWeather!.minTemperature[0],
                              maxTemp: dailyWeather!.maxTemperature[0],
                              perceivedTemp: currentWeather!.apparentTemperature,
                              lastUpdate: lastWeatherUpdate
                            ),
                            HourlyWeatherCard(hourly: hourlyWeather!),
                            const SizedBox(height: 12),
                            DailyWeatherCard(daily: dailyWeather!),
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.26,
                              child: GridView.count(
                                primary: false,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                crossAxisCount: 2,
                                children: [
                                  WindCard(
                                    windDirection: currentWeather!.windDirection,
                                    windSpeed: currentWeather!.windSpeed
                                  ),
                                  SunsetSunriseCard(
                                      sunrise: dailyWeather!.sunrise?[0] ?? "1970-01-01 00:00",
                                      sunset: dailyWeather!.sunset?[0] ?? "1970-01-01 00:00"
                                  ),
                                ],
                              )
                            ),
                            const SizedBox(height: 12),
                            UvIndexCard(uvIndex: dailyWeather!.uvMaxIndex?[0] ?? 255),
                            const SizedBox(height: 12),
                            FullAddressCard(address: _selectedGeo?.fullName ?? ""),
                            const SizedBox(height: 24)
                          ]
                        )
                      )
                    )
                  else
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: Center(
                        child: (errorEncountered == null) ?
                          const CircularProgressIndicator() :
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(errorEncountered ?? ""),
                              ),
                              IconButton(
                                onPressed: () {
                                  if(_selectedGeo != null && isWeatherReady == true) {
                                    setState(() { isWeatherReady = false; });
                                    getWeatherForSelectedGeo();
                                  }
                                },
                                icon: const Icon(Icons.refresh)
                              )
                            ],
                          )
                      )
                    )
                ],
            ),
          ),
        ],
      ),
    );
  }
}
