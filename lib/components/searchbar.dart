import 'package:flutter/material.dart';

import '../apis/geo.dart';

class SuggestingSearchBar extends StatefulWidget {
  const SuggestingSearchBar({
    super.key,
    required this.searchController,
    required this.textController,
    required this.geocodeLocation,
    required this.weatherApiCall,
    required this.setGeo,
    required this.setError,
    required this.updateWeatherReadiness
  });

  final SearchController searchController;
  final TextEditingController textController;
  final Function() geocodeLocation;
  final Function() weatherApiCall;
  final Function(Geo) setGeo;
  final Function(String?) setError;
  final Function(bool) updateWeatherReadiness;

  @override
  State<StatefulWidget> createState() => _SuggestingSearchBar();
}

class _SuggestingSearchBar extends State<SuggestingSearchBar> {
  @override
  void initState() {
    super.initState();
  }

  Function(Function())? suggestionStateSetter;
  List<ListTile> suggestions = [];
  bool isGettingLocation = false;
  bool isGettingSuggestions = false;

  Future getSuggestions(String searchKey) async {
    setState(() {
      isGettingSuggestions = true;
      widget.setError(null);
    });
    suggestionStateSetter!((){});
    List<ListTile> liveSuggestions = [];

    await Geo.geocodeLocation(searchKey).then((geos) {
      geos?.forEach((geo) {
        liveSuggestions.add(geo.toListItem((Geo self) => weatherTileOnTap(self)));
      });

      setState(() {
        isGettingSuggestions = false;
        suggestions = liveSuggestions;
      });
      suggestionStateSetter!((){});
    });
  }

  void weatherTileOnTap(Geo self) {
    setState(() {
      widget.setGeo(self);
      if(self.city != null) widget.textController.text = self.city!;
      widget.updateWeatherReadiness(false);
      widget.setError(null);
      suggestions = [];
      widget.searchController.closeView(null);
    });
    suggestionStateSetter!((){});
    widget.weatherApiCall();
  }



  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      suggestionsBuilder: (BuildContext context, SearchController controller) => [],
      searchController: widget.searchController,

      viewBuilder: (_) {
        return StatefulBuilder(
            builder: (BuildContext context, Function(Function()) updateState) {
              suggestionStateSetter = updateState;
              Widget widget =
              (isGettingSuggestions) ? const Center(child: CircularProgressIndicator()) :
              (suggestions.isNotEmpty) ? ListView( children: suggestions ) :
              ListView(children : Geo.buildFavouritesList((Geo self) => weatherTileOnTap(self)));
              return widget;
            }
        );
      },

      viewOnSubmitted: (String text) async {
        await getSuggestions(text);
        suggestionStateSetter!((){});
      },

      viewHintText: "Search for a City...",

      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: widget.textController,
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
              widget.geocodeLocation();
              await widget.weatherApiCall();
            },
          ),
        );
      },
      isFullScreen: false,
    );
  }
}

