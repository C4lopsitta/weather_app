import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weather_app/components/SearchAnchor.dart' as Searcher;
import 'package:weather_app/geo.dart';

class CurrentWeather extends StatefulWidget {
  const CurrentWeather({super.key});

  @override
  State<StatefulWidget> createState() => _CurrentWeather();
}

class _CurrentWeather extends State<CurrentWeather> {
  Future _getSuggestions(Searcher.SearchController controller, String searchKey) async {
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
              // SearchAnchor(
              //   searchController: _searchController,
              //   isFullScreen: false,
              //   builder: (context, controller) =>
              //     SearchBar(
              //       controller: _searchTextController,
              //       onTap: () { _searchController.openView(); },
              //     ),
              //   viewOnSubmitted: (searchKey) {
              //     if(searchKey.isEmpty) return;
              //     _getSuggestions(_searchController, searchKey);
              //   },
              //
              //   viewBuilder: (set) {
              //     _getSuggestions(_searchController, _searchTextController.text);
              //     return SingleChildScrollView(child: Column(children: set.toList()));
              //   },
              //   suggestionsBuilder: (_, __) async {
              //     return _suggestionSet;
              //   },
              // ),

              Searcher.ExposedSearchAnchor(
                builder: (context, controller) => SearchBar(
                  onTap: () => controller.openView(),
                  onSubmitted: (it) => setState(() {
                    _iDunnoMan = it;
                  }),
                ),
                viewOnSubmitted: (it) => setState(() {
                  _iDunnoMan = it;
                }),
                suggestions: Text(_iDunnoMan),
              )
            ],
          ),
        ),
      ],
    );
  }
}
