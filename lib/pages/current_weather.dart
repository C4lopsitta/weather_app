import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weather_app/apis/geo.dart' as Geo;
import 'package:weather_app/apis/Weather_api.dart';
import 'package:weather_app/components/weather_header.dart';
import 'package:weather_app/components/weather_hourly_card.dart';

import '../forecast/Hourly.dart';

class CurrentWeather extends StatefulWidget {
  const CurrentWeather({super.key});

  @override
  State<StatefulWidget> createState() => _CurrentWeather();
}

class _CurrentWeather extends State<CurrentWeather> {
  List<Widget> suggestions = [];
  Geo.Geo? _selectedGeo = null;
  BuildContext? sheetContext = null;
  bool _isGettingLocation = false;
  
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
    List<ListTile> liveSuggestions = [];

    await Geo.geocodeLocation(searchKey).then((geos) {
      geos?.forEach((geo) {
        print(geo.toString());
        liveSuggestions.add(ListTile(
          title: Text(geo.city ?? "UNDEFINED"),
          subtitle: Text(geo.fullName ?? ""),
          onTap: () {
            Geo.Geo self = geo;
            setState(() {
              _selectedGeo = self;
              if(geo.city != null) _searchTextController.text = geo.city!;
            });
            if(sheetContext != null) Navigator.pop(sheetContext!);

            //call get weather (current)
          },
        ));
      });

      setState(() {
        suggestions = liveSuggestions;
      });
    });
  }

  Future _geocodeCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });
    try {
      Geo.Geo current = await Geo.getLocation();
      current = await Geo.geocodeCurrentLocation(current);

      setState(() {
        if(current.city != null) _searchTextController.text = current.city!;
        _isGettingLocation = false;
        _selectedGeo = current;
      });

    } catch(exception) {
      print(exception.toString());
    }


  }

  Future _getWeatherForSelectedGeo() async {
    if(_selectedGeo == null) return;
    Weather_api current = Weather_api(geo: _selectedGeo!);
    current.call_api_current();
  }

  final TextEditingController _searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).viewPadding.top),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBar(
                controller: _searchTextController,
                onSubmitted: (text) {
                  _getSuggestions(text).then((value) => _openSheet());
                },
                trailing: [ IconButton(
                  icon: Icon(Icons.search_rounded),
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
              if(_selectedGeo != null)
                SingleChildScrollView(
                  child: Column(
                    children: [
                      WeatherHeader(
                        city: _selectedGeo!.city,
                        weatherDescription: null,
                        temperature: 21.2,
                        minTemp: 14,
                        maxTemp: 23,
                        perceivedTemp: 20
                      ),
                      HourlyWeatherCard(hourly: Hourly(
                        ["12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00"],
                        [20.0, 19.0, 15.0, 14.0, 14.0, 13.0, 12.0],
                        [66.0, 50.0, 44.0, 30.0, 33.0, 37.0, 29.0],
                        [1.0, 2.0, 3.0, 2.0, 2.0, 2.0, 2.0],
                        [43.0, 12.0, 1.0, 2.0, 1.0, 1.0, 1.0]
                      ))
                    ]
                  )
                ),
              ],
          ),
        ),
      ],
    );
  }
}
