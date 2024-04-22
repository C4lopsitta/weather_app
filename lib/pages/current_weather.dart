import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/apis/geo.dart';
import 'package:weather_app/apis/weather_api.dart';
import 'package:weather_app/components/daily_weather_card.dart';
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
  bool _isGettingLocation = false;
  bool _isGettingSuggestions = false;
  DateTime lastWeatherUpdate = DateTime.fromMillisecondsSinceEpoch(0);

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
    _getWeatherForSelectedGeo();
  }

  void _openSheet() {
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
                            Text("Suggestions"),
                            IconButton(
                                onPressed: () {
                                  sheetContext = null;
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.close_rounded)
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

  Future _getSuggestions(String searchKey) async {
    setState(() { _isGettingSuggestions = true; });
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
            });
            if(sheetContext != null) Navigator.pop(sheetContext!);
            _getWeatherForSelectedGeo();
          },
        ));
      });

      setState(() {
        _isGettingSuggestions = false;
        suggestions = liveSuggestions;
      });
    });
  }

  Future _geocodeCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      isWeatherReady = false;
    });
    try {
      Geo current = await Geo.getLocation();
      current = await Geo.geocodeCurrentLocation(current);

      setState(() {
        if(current.city != null) _searchTextController.text = current.city!;
        _isGettingLocation = false;
        _selectedGeo = current;
      });

    } catch(exception) {
      print(exception.toString());
    }

    _getWeatherForSelectedGeo();
  }

  Future _getWeatherForSelectedGeo() async {
    if(_selectedGeo == null) return;

    WeatherApi current = WeatherApi(geo: _selectedGeo!);
    currentWeather = await current.call_api_current();
    dailyWeather = await current.call_api_daily();
    hourlyWeather = await current.call_api_hourly();

    lastWeatherUpdate = DateTime.now();

    storeGeo();

    setState(() {
      isWeatherReady = true;
    });
  }

  void storeGeo() async {
    await PreferencesStorage.initialize();

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: MediaQuery.of(context).viewPadding.top),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SearchBar(
                controller: _searchTextController,
                onSubmitted: (text) {
                  _getSuggestions(text).then((value) => _openSheet());
                },
                trailing: [ IconButton(
                  icon: (!_isGettingSuggestions) ?
                    const Icon(Icons.search_rounded) :
                    const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator()
                    ),
                  onPressed: () {
                    String text = _searchTextController.text;
                    _getSuggestions(text).then((value) => _openSheet());
                  },
                ) ],
                leading: (_isGettingLocation) ?
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator()
                    )
                  ) : IconButton(
                    icon: const Icon(Icons.location_on_rounded),
                    onPressed: () => _geocodeCurrentLocation(),
                  ),
              ),
              if(_selectedGeo != null )
                if(isWeatherReady)
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 160
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
                                )
                              ],
                            )
                          ),
                          const SizedBox(height: 12),
                          UvIndexCard(uvIndex: dailyWeather!.uvMaxIndex?[0] ?? 255)
                        ]
                      )
                    )
                  )
                else
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: const Center(
                      child: CircularProgressIndicator()
                    )
                  )
              ],
          ),
        ),
      ],
    );
  }
}
