import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/apis/historical_weather_api.dart';
import 'package:weather_app/components/graph_card.dart';

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
    loadFromStorage();
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
  DateTime _end = DateTime.now();

  Geo? _selectedGeo;

  DateFormat formatter = DateFormat.yMd();

  bool isWeatherReady = false;
  //endregion


  Future loadFromStorage() async {
    print("Loading!");

    await PreferencesStorage.initialize();

    if(await PreferencesStorage.readBoolean(SettingPreferences.USE_GPS_DEFAULT) == true) {
      return _geocodeCurrentLocation();
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

    HistoricalWeatherApi weather = HistoricalWeatherApi(geo: _selectedGeo, startDate: _start, endDate: _end);


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

  TextStyle headerStyle = const TextStyle(fontSize: 14);

  Future showDateDialog(DateTime date, BuildContext context, { bool isStart = false }) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      firstDate: (isStart) ? DateTime(1940) : _start,
      lastDate: (!isStart) ? DateTime.now() : _end,
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
      setState(() {});
    }
  }

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
                                          icon: const Icon(Icons.pool_rounded),
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
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: GraphCard(
                        graphStart: _start,
                        graphEnd: _end,
                        graphY: [[12.0, 11.0, 14.0]],
                        title: "Giovanni",
                      )
                    );
                  },
                  childCount: 10
                )
              ),
            ],
          )
        )
      ],
    );
  }
}
