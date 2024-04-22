import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weather_app/apis/geo.dart' as Geo;
import 'package:weather_app/apis/Weather_api.dart';
import 'package:weather_app/components/daily_weather_card.dart';
import 'package:weather_app/components/weather_header.dart';
import 'package:weather_app/components/weather_hourly_card.dart';

import '../forecast/Current.dart';
import '../forecast/Daily.dart';
import '../forecast/Hourly.dart';

class CurrentWeather extends StatefulWidget {
  const CurrentWeather({super.key});

  @override
  State<StatefulWidget> createState() => _CurrentWeather();
}

class _CurrentWeather extends State<CurrentWeather> {
  List<Widget> suggestions = [];
  Geo.Geo? _selectedGeo;
  BuildContext? sheetContext;
  bool _isGettingLocation = false;

  bool isWeatherReady = false;

  Current? currentWeather;
  Daily? dailyWeather;
  Hourly? hourlyWeather;
  
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
      isWeatherReady = false;
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

    _getWeatherForSelectedGeo();
  }

  Future _getWeatherForSelectedGeo() async {
    if(_selectedGeo == null) return;

    WeatherApi current = WeatherApi(geo: _selectedGeo!);
    currentWeather = await current.call_api_current();
    dailyWeather = await current.call_api_daily();
    hourlyWeather = await current.call_api_hourly();

    setState(() {
      isWeatherReady = true;
    });
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
                  icon: const Icon(Icons.search_rounded),
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
                    height: MediaQuery.of(context).size.height - 184,
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
                            perceivedTemp: currentWeather!.apparentTemperature
                          ),
                          HourlyWeatherCard(hourly: hourlyWeather!),
                          DailyWeatherCard(daily: dailyWeather!)
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
