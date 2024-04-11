import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weather_app/enums/search_status.dart';
import 'package:weather_app/geo.dart';

class CurrentWeather extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CurrentWeather();
}

class _CurrentWeather extends State<CurrentWeather> {
  Future _getSuggestions(SearchController controller, String searchKey) async {
    List<Widget> suggestions = [];

    await geocodeLocation(searchKey).then((geos) {
      geos?.forEach((geo) {
        print(geo.toString());
        suggestions.add(ListTile(
          title: Text(geo.city ?? "UNDEFINED"),
          subtitle: Text(geo.fullName ?? ""),
          onTap: () {
            Geo self = geo;
            controller.closeView(geo.city);
          },
        ));
      });

      print("\n\nSetting state!\n${suggestions.length}\n");
      setState(() {
        _suggestionSet = suggestions;
      });
    });
  }

  final SearchController _searchController = SearchController();
  final TextEditingController _searchTextController = TextEditingController();
  List<Widget> _suggestionSet = [ ];

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
              SearchAnchor(
                searchController: _searchController,
                isFullScreen: false,
                builder: (context, controller) =>
                  SearchBar(
                    controller: _searchTextController,
                    onTap: () { _searchController.openView(); },
                  ),
                viewOnSubmitted: (searchKey) {
                  if(searchKey.isEmpty) return;
                  _getSuggestions(_searchController, searchKey);
                },

                viewBuilder: (set) {
                  _getSuggestions(_searchController, _searchTextController.text);
                  return SingleChildScrollView(child: Column(children: set.toList()));
                },
                suggestionsBuilder: (_, __) async {
                  return _suggestionSet;
                },
              )

            ],
          ),
        ),
      ],
    );
  }
}
