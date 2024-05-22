import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:weather_app/apis/geo.dart';
import 'package:weather_app/apis/network_manager.dart';
import 'package:weather_app/apis/weather_api.dart';
import 'package:weather_app/components/weather_current/daily_weather_card.dart';
import 'package:weather_app/components/weather_current/full_address_card.dart';
import 'package:weather_app/components/weather_current/sunset_sunrise_card.dart';
import 'package:weather_app/components/weather_current/uv_index_card.dart';
import 'package:weather_app/components/weather_current/weather_header.dart';
import 'package:weather_app/components/weather_current/weather_hourly_card.dart';
import 'package:weather_app/components/weather_current/wind_card.dart';
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
  Geo? selectedGeo;
  BuildContext? sheetContext;
  bool isGettingLocation = false;
  bool isGettingSuggestions = false;
  bool isWeatherReady = false;
  DateTime lastWeatherUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  String? errorEncountered;

  Current? currentWeather;
  Daily? dailyWeather;
  Hourly? hourlyWeather;

  SearchController searchController = SearchController();
  final TextEditingController _searchTextController = TextEditingController();
  Function(Function())? suggestionsStateSetter;

  @override
  void initState() {
    super.initState();
    loadFromStorage();
  }

  Future loadFromStorage() async {
    await PreferencesStorage.initialize();

    if(await PreferencesStorage.readBoolean(SettingPreferences.USE_GPS_DEFAULT) == true) {
      geocodeCurrentLocation();
      bool isOnline = await NetworkManager.isOnline();
      if(isOnline) {
        getWeatherForSelectedGeo();
      } else {
        SnackBar snackbar = SnackBar(
            content: const Text("No connection"),
            margin: const EdgeInsets.all(12),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: "Retry",
              onPressed: () {
                if(selectedGeo != null) {
                  getWeatherForSelectedGeo();
                }
              },
            )
        );
        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
      }
    }

    //load last geo (if exists)
    int? lastLoadTimeFromStorage = await PreferencesStorage.readInteger(PreferencesStorage.GEO_LAST_LOAD);
    if(lastLoadTimeFromStorage == null) return;
    String? city = await PreferencesStorage.readString(PreferencesStorage.GEO_CITY);
    String? fullName = await PreferencesStorage.readString(PreferencesStorage.GEO_FULLNAME);
    double? lat = await PreferencesStorage.readDouble(PreferencesStorage.GEO_LAT);
    double? lon = await PreferencesStorage.readDouble(PreferencesStorage.GEO_LON);

    setState(() {
      selectedGeo = Geo(lat ?? 0.0, lon ?? 0.0, city: city, fullName: fullName);
      lastWeatherUpdate = DateTime.fromMillisecondsSinceEpoch(lastLoadTimeFromStorage);
    });

    _searchTextController.text = city ?? "";

    bool isOnline = await NetworkManager.isOnline();
    if(isOnline) {
      getWeatherForSelectedGeo();
    } else {
      SnackBar snackbar = SnackBar(
        content: const Text("No connection"),
        margin: const EdgeInsets.all(12),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "Retry",
          onPressed: () {
            if(selectedGeo != null) {
              getWeatherForSelectedGeo();
            }
          },
        )
      );
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }

      //TODO)) Add loader from file

    }
  }

  Future getSuggestions(String searchKey) async {
    setState(() {
      isGettingSuggestions = true;
      errorEncountered = null;
    });
    suggestionsStateSetter!((){});
    List<ListTile> liveSuggestions = [];

    await Geo.geocodeLocation(searchKey).then((geos) {
      geos?.forEach((geo) {
        liveSuggestions.add(ListTile(
          title: Text(geo.city ?? "UNDEFINED"),
          subtitle: Text(geo.fullName ?? ""),
          onTap: () {
            Geo self = geo;
            setState(() {
              selectedGeo = self;
              if(geo.city != null) _searchTextController.text = geo.city!;
              isWeatherReady = false;
              errorEncountered = null;
              searchController.closeView(null);
            });
            suggestionsStateSetter!((){});
            if(sheetContext != null) Navigator.pop(sheetContext!);
            getWeatherForSelectedGeo();
          },
        ));
      });

      setState(() {
        isGettingSuggestions = false;
        suggestions = liveSuggestions;
      });
      suggestionsStateSetter!((){});
    });
  }

  Future geocodeCurrentLocation() async {
    setState(() {
      isGettingLocation = true;
      isWeatherReady = false;
      errorEncountered = null;
      _searchTextController.text = "Getting GPS...";
    });
    try {
      Geo current = await Geo.getLocation();
      current = await Geo.geocodeCurrentLocation(current);

      setState(() {
        if(current.city != null) _searchTextController.text = current.city!;
        isGettingLocation = false;
        selectedGeo = current;
      });

    } catch(exception) {
      SnackBar snackBar = const SnackBar(
          content: Text("Failed to get current location"),
          margin: EdgeInsets.all(12),
          behavior: SnackBarBehavior.floating,
      );
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

  }

  Future getWeatherForSelectedGeo() async {
    if(selectedGeo == null) return;

    try {
      WeatherApi current = WeatherApi(geo: selectedGeo!);
      currentWeather = await current.call_api_current();
      dailyWeather = await current.call_api_daily();
      hourlyWeather = await current.call_api_hourly();

      lastWeatherUpdate = DateTime.now();

      setState(() {
        isWeatherReady = true;
        errorEncountered = null;
      });

    } on ClientException catch (ex) {
      setState(() {
        isWeatherReady = true;
        errorEncountered = ex.message;
      });
      return;
    } finally {
      PreferencesStorage.storeGeo(selectedGeo!, lastWeatherUpdate);
    }
  }


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if(selectedGeo != null && isWeatherReady == true) {
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
                SearchAnchor(
                  suggestionsBuilder: (BuildContext context, SearchController controller) => [],
                  searchController: searchController,

                  viewBuilder: (_) {
                    return StatefulBuilder(
                      builder: (BuildContext context, Function(Function()) updateState) {
                        suggestionsStateSetter = updateState;
                        Widget widget =
                          (isGettingSuggestions) ? const Center(child: CircularProgressIndicator()) :
                          ListView(
                            children: suggestions,
                          );
                        return widget;
                      }
                    );
                  },

                  viewOnSubmitted: (String text) async {
                    await getSuggestions(text);
                    suggestionsStateSetter!((){});
                  },

                  viewHintText: "Search for a City...",

                  builder: (BuildContext context, SearchController controller) {
                    return SearchBar(
                      controller: _searchTextController,
                      onSubmitted: (text) {
                        getSuggestions(text).then((value) {
                          controller.openView();
                        });
                      },
                      onTap: () => controller.openView(),
                      trailing: [ IconButton(
                        icon: const Icon(Icons.search_rounded),
                        onPressed: () {
                          controller.openView();
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
                        onPressed: () async {
                          geocodeCurrentLocation();
                          await getWeatherForSelectedGeo();
                        },
                      ),
                    );
                  },
                  isFullScreen: false,
                ),


                if(selectedGeo != null)
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
                              city: (isGettingLocation) ? null : selectedGeo!.city,
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
                            FullAddressCard(address: selectedGeo?.fullName ?? ""),
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
                                padding: const EdgeInsets.all(12),
                                child: Text(errorEncountered ?? ""),
                              ),
                              IconButton(
                                onPressed: () {
                                  if(selectedGeo != null && isWeatherReady == true) {
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
