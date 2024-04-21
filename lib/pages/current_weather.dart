import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weather_app/apis/geo.dart';
import 'package:weather_app/apis/Weather_api.dart';

class CurrentWeather extends StatefulWidget {
  const CurrentWeather({super.key});

  @override
  State<StatefulWidget> createState() => _CurrentWeather();
}

class _CurrentWeather extends State<CurrentWeather> {
  List<Widget> suggestions = [];
  Geo? _selectedGeo = null;
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
              height: MediaQuery.sizeOf(context).height,
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
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.4,
                        child: SingleChildScrollView(
                        clipBehavior: Clip.hardEdge,
                        scrollDirection: Axis.vertical,
                        child: Column( children: suggestions )
                      )),
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
            Geo self = geo;
            setState(() {
              _selectedGeo = self;
              if(geo.city != null) _searchTextController.text = geo.city!;
            });
            if(sheetContext != null) Navigator.pop(sheetContext!);

            //call get weather (current)
          },
          trailing: IconButton(
            icon: (Geo.isFavoutire(geo)) ?
              const Icon(Icons.star_rounded) :
              const Icon(Icons.star_border_rounded),
            onPressed: () {
              Geo self = geo;
              if(Geo.isFavoutire(self)) {
                Geo.addFavourite(self);
              } else {
                Geo.removeFavourite(self);
              }
            },
          ),
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


  }

  Future _getWeatherForSelectedGeo() async {
    if(_selectedGeo == null) return;
    Weather_api current = Weather_api.from_geo(_selectedGeo!);
    current.call_api();

  }

  final TextEditingController _searchTextController = TextEditingController();

  String _iDunnoMan = "initial";

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
              )
            ],
          ),
        ),
      ],
    );
  }
}

//TODO)) Modify state to be inside the searchbar and give function that updates
//TODO)) State to given item once updated
