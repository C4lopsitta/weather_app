import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/apis/historical_weather_api.dart';
import 'package:weather_app/components/graph_card.dart';
import 'package:weather_app/forecast/historical/graph_list_component.dart';
import 'package:weather_app/forecast/historical/historical_precipitation.dart';
import 'package:weather_app/forecast/historical/historical_sun.dart';
import 'package:weather_app/forecast/historical/historical_tempetature.dart';
import 'package:weather_app/forecast/historical/historical_wind.dart';

import '../apis/geo.dart';
import '../preferences_storage.dart';

class HistoricalWeather extends StatefulWidget {
  const HistoricalWeather({super.key});

  @override
  State<StatefulWidget> createState() => _HistoricalWeather();
}

class _HistoricalWeather extends State<HistoricalWeather> {
  @override
  void initState() {
    super.initState();
    _start = DateTime.fromMillisecondsSinceEpoch(_end.millisecondsSinceEpoch - (65536 * 128));
    updateText();
    // loadFromStorage();
  }


  //region attributes
  final TextEditingController _searchTextController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  List<Widget> suggestions = [];
  BuildContext? sheetContext;
  bool _isGettingLocation = false;
  bool _isGettingSuggestions = false;
  DateTime lastWeatherUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  late DateTime _start;
  DateTime _end = DateTime.now().subtract(const Duration(days: 2));

  Geo? _selectedGeo;

  DateFormat formatter = DateFormat.yMd();

  bool isWeatherReady = false;

  HistoricalPrecipitation? precipitation;
  HistoricalSun? sun;
  HistoricalTemperature? temperature;
  HistoricalWind? wind;

  List<Object?> ApiResults = [
    null, null, null, null
  ];

  bool _apiError = false;
  String _apiMessage = "";

  final List<String> CardTitles = ["Temperature", "Precipitation", "Sunshine", "Wind"];
  //endregion

  Future loadFromStorage() async {
    return;
    // print("Loading!");
    //
    // await PreferencesStorage.initialize();
    //
    // if(await PreferencesStorage.readBoolean(SettingPreferences.USE_GPS_DEFAULT) == true) {
    //   return _geocodeCurrentLocation();
    // }
    //
    // //load last geo (if exists)
    // int? lastLoadTimeFromStorage = await PreferencesStorage.readInteger(PreferencesStorage.GEO_LAST_LOAD);
    // if(lastLoadTimeFromStorage == null) return;
    // String? city = await PreferencesStorage.readString(PreferencesStorage.GEO_CITY);
    // String? fullName = await PreferencesStorage.readString(PreferencesStorage.GEO_FULLNAME);
    // double? lat = await PreferencesStorage.readDouble(PreferencesStorage.GEO_LAT);
    // double? lon = await PreferencesStorage.readDouble(PreferencesStorage.GEO_LON);
    //
    // setState(() {
    //   _selectedGeo = Geo(lat ?? 0.0, lon ?? 0.0, city: city, fullName: fullName);
    //   lastWeatherUpdate = DateTime.fromMillisecondsSinceEpoch(lastLoadTimeFromStorage);
    // });
    //
    // print("Loaded!");
    //
    // _searchTextController.text = city ?? "";
    // _getWeatherForSelectedGeo();
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

    setState(() {
      _apiError = false;
    });

    HistoricalWeatherApi weather = HistoricalWeatherApi(geo: _selectedGeo, startDate: _start, endDate: _end);

    try {
      ApiResults[0] = await weather.call_api_temperature();
      ApiResults[1] = await weather.call_api_precipitation();
      ApiResults[2] = await weather.call_api_sun();
      ApiResults[3] = await weather.call_api_wind();
    } catch (ex) {
      print("Las exceptiones: ${ex.toString()}");

      setState(() {
        _apiError = true;
        _apiMessage = (ex as Error).stackTrace.toString();
      });
    }

    lastWeatherUpdate = DateTime.now();

    // storeGeo();

    setState(() {
      isWeatherReady = true;
    });
  }

  void updateText() {
    _startDateController.text = formatter.format(_start);
    _endDateController.text = formatter.format(_end);
  }

  Future showDateDialog(DateTime date, BuildContext context, { bool isStart = false }) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      firstDate: (isStart) ? DateTime(1940) : _start,
      lastDate: (!isStart) ? DateTime.now().subtract(const Duration(days: 2)) : _end,
      initialDate: date,
      initialEntryMode: DatePickerEntryMode.calendarOnly
    );

    if(newDate != null) {
      if(isStart) {
        _start = newDate;
      } else {
        _end = newDate;
      }

      updateText();

      if(_selectedGeo != null) {
        setState(() {
          isWeatherReady = false;
        });
        _getWeatherForSelectedGeo();
      }

      setState(() {});
    }
  }

  List<GraphListComponent> convertApiToComponents(int index) {
    List<GraphListComponent> components = [];

    if(index == 0) {
      HistoricalTemperature temp = (ApiResults[index] as HistoricalTemperature);
      components.add(GraphListComponent(
          list: temp.apparentTemperatureMax ,
          title: "Apparent maximum temperature"
      ));
      components.add(GraphListComponent(
          list: temp.apparentTemperatureMean ,
          title: "Apparent mean temperature"
      ));
      components.add(GraphListComponent(
          list: temp.apparentTemperatureMin ,
          title: "Apparent minimum temperature"
      ));
      components.add(GraphListComponent(
          list: temp.temperatureMax ,
          title: "Maximum temperature"
      ));
      components.add(GraphListComponent(
          list: temp.temperatureMean ,
          title: "Mean temperature"
      ));
      components.add(GraphListComponent(
          list: temp.temperatureMin ,
          title: "Minimum temperature"
      ));
    }
    else if (index == 1) {
      HistoricalPrecipitation precipitation = (ApiResults[index] as HistoricalPrecipitation);
      components.add(GraphListComponent(
          list: precipitation.rainSums ,
          title: "Total rainfall"
      ));
      components.add(GraphListComponent(
          list: precipitation.snowfallSums ,
          title: "Total snowfall"
      ));
      components.add(GraphListComponent(
          list: precipitation.precipitationHours ,
          title: "Hours of precipitation"
      ));
      components.add(GraphListComponent(
          list: precipitation.precipitationSums ,
          title: "Total precipitation"
      ));
    }
    else if (index == 2) {
      HistoricalSun sun = (ApiResults[index] as HistoricalSun);
      components.add(GraphListComponent(
          list: sun.daylightDurations,
          title: "Duration of daylight"
      ));
      components.add(GraphListComponent(
          list: sun.sunshineDurations,
          title: "Duration of sunshine"
      ));
      //todo)) figure something for sunrise/sunset
    }
    else {
      HistoricalWind wind = (ApiResults[index] as HistoricalWind);
      components.add(GraphListComponent(
          list: wind.windSpeeds ,
          title: "Speed of wind"
      ));
      components.add(GraphListComponent(
          list: wind.windGusts ,
          title: "Wind gusts"
      ));
      components.add(GraphListComponent(
          list: wind.windDirections ,
          title: "Direction of wind"
      ));
    }
    //todo)) do something with directions
    
    return components;
  }

  TextStyle headerStyle = const TextStyle(fontSize: 14);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).viewPadding.top),
        SizedBox(
          height: MediaQuery.of(context).size.height - MediaQuery.of(context).viewPadding.top - 80,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                leadingWidth: 0,
                expandedHeight: 160,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.all(12),
                  collapseMode: CollapseMode.none,
                  expandedTitleScale: 1,
                  title: Container(
                    alignment: Alignment.center,
                    child: Column(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 70,
                                width: MediaQuery.sizeOf(context).width,
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  primary: false,
                                  crossAxisSpacing: 12,
                                  clipBehavior: Clip.none,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    TextField(
                                      controller: _startDateController,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        label: const Text("Date start"),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.start),
                                          onPressed: () { showDateDialog(_start, context, isStart: true); },
                                        ),
                                      ),
                                    ),
                                    TextField(
                                      controller: _endDateController,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        label: const Text("Date End"),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.last_page_rounded),
                                          onPressed: () { showDateDialog(_end, context); },
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              )
                            ],
                          )
                        )
                      ],
                    )
                  ),
                ),
              ),
              if(_selectedGeo != null)
                if(isWeatherReady)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if(ApiResults[index] != null) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: GraphCard(
                              graphStart: _start,
                              graphEnd: _end,
                              graphLines: convertApiToComponents(index),
                              title: CardTitles[index],
                            )
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Text("Error getting ${CardTitles[index]}"),
                                  const Text("API error message"),
                                  Expanded(
                                    child: Text(_apiMessage),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: CardTitles.length
                    )
                  )
                else
                  if(!_apiError)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(48),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(),
                            )
                          )
                        ),
                        childCount: 1
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              const Text("API Error!"),
                              Expanded(child: Text(_apiMessage))
                            ],
                          ),
                        ),
                        childCount: 1
                      ),
                    )
            ],
          )
        )
      ],
    );
  }
}
