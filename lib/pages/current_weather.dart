import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weather_app/enums/search_status.dart';
import 'package:weather_app/geo.dart';

class CurrentWeather extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CurrentWeather();
}

class _CurrentWeather extends State<CurrentWeather> {
  Iterable<Widget> _getSuggestions(SearchController controller) {
    // check if something was actually searched
    if(controller.text.isEmpty) {
      _searchStatus = SearchStatus.NO_SUGGESTIONS;
      return [];
    }
    // check if a suggestion is already being prepared
    if(_searchStatus == SearchStatus.SUGGESTING) _lastSuggestionSet;
    _searchStatus = SearchStatus.SUGGESTING;

    List<ListTile> suggestions = [];

    try {
      geocodeLocation(controller.text).then((geos) {
        geos?.forEach((geo) {
          suggestions.add(ListTile(
            title: Text(geo.city ?? "UNDEFINED"),
            subtitle: Text(geo.fullName ?? ""),
            onTap: () {
              Geo self = geo;
              controller.closeView(geo.city);
            },
          ));
        });

      });
    } catch(exception) {
      return [
        Center(
          child: Text("Something went wrong!\n${exception.toString()}"),
        )
      ];
    }

    _lastSuggestionSet = suggestions;
    return (suggestions.isEmpty) ? [ const Center(child: Text("Something went wrong")) ] : suggestions;
  }

  SearchStatus _searchStatus = SearchStatus.NO_SUGGESTIONS;
  Iterable<Widget> _lastSuggestionSet = [];

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
              SearchAnchor.bar(
                onSubmitted: (_) { _searchStatus = SearchStatus.SEARCHING; },
                onChanged: (_) { _searchStatus = SearchStatus.NO_SUGGESTIONS; },
                barPadding: const MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 12)),
                barHintText: "Search for a place",
                suggestionsBuilder: (context, controller) {
                  if(_searchStatus == SearchStatus.NO_SUGGESTIONS) {
                    return [
                      const Center(
                        child: Text("Start searching to get suggestions")
                      )
                    ];
                  } else if (_searchStatus == SearchStatus.SEARCHING || _searchStatus == SearchStatus.SUGGESTING) {
                    return _getSuggestions(controller);
                  } else return [];
                }
              ),

            ],
          ),
        ),
      ],
    );
  }
}
