import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weather_app/geo.dart';

class CurrentWeather extends StatefulWidget {
  const CurrentWeather({super.key});

  @override
  State<StatefulWidget> createState() => _CurrentWeather();
}

class _CurrentWeather extends State<CurrentWeather> {
  List<Widget> suggestions = [];
  
  void _openSheet() {
    if(_searchTextController.text.isNotEmpty) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
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
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.close_rounded)
                            )
                          ],
                        )
                      ),
                      SingleChildScrollView( child: Column(
                        children: suggestions,
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

    await geocodeLocation(searchKey).then((geos) {
      geos?.forEach((geo) {
        print(geo.toString());
        liveSuggestions.add(ListTile(
          title: Text(geo.city ?? "UNDEFINED"),
          subtitle: Text(geo.fullName ?? ""),
          onTap: () {
            Geo self = geo;
          },
        ));
      });

      setState(() {
        suggestions = liveSuggestions;
      });
    });
    setState(() {

    });
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
