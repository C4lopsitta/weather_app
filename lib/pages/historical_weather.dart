import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoricalWeather extends StatefulWidget {
  const HistoricalWeather({super.key});

  @override
  State<StatefulWidget> createState() => _HistoricalWeather();
}

class _HistoricalWeather extends State<HistoricalWeather> {
  final TextEditingController _searchTextController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  late DateTime _start;
  DateTime _end = DateTime.now();

  DateFormat formatter = DateFormat.yMd();

  @override
  void initState() {
    super.initState();
    _start = DateTime.fromMillisecondsSinceEpoch(_end.millisecondsSinceEpoch - (65536 * 128));
    updateText();
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
                            //_getSuggestions(text).then((value) => _openSheet());
                          },
                          trailing: [ IconButton(
                            icon: (true)?//!_isGettingSuggestions) ?
                            const Icon(Icons.search_rounded) :
                            const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator()
                            ),
                            onPressed: () {
                              String text = "";//_searchTextController.text;
                              //_getSuggestions(text).then((value) => _openSheet());
                            },
                          ) ],
                          leading: ( false )?//_isGettingLocation) ?
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator()
                              )
                          ) : IconButton(
                            icon: const Icon(Icons.location_on_rounded),
                            onPressed: () =>  print("lorem"),//_geocodeCurrentLocation(),
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
                    return const Text("Banana", style: TextStyle(fontSize: 600));
                  },
                  childCount: 1
                )
              ),
            ],
          )
        )
      ],
    );
  }
}
