import 'package:flutter/material.dart';
import 'package:weather_app/apis/geo.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => _Settings();
}

class _Settings extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).viewPadding.top),
        const Text("Favourite locations"),
        OutlinedButton(onPressed: () {
          List<Geo> geos = Geo.getFavourites().toList();
          List<ListTile> locations = [const ListTile(title: Text("AAAAAAAAAAA"))];

          geos.forEach((geo) => locations.add(ListTile(
            title: Text(geo.city ?? ""),
            subtitle: Text(geo.fullName ?? ""),
            trailing: IconButton(
              icon: Icon(Icons.delete_rounded),
              onPressed: () {
                Geo.removeFavourite(geo);
                setState(() {
                  locations.remove(this);
                });
              },
            ),
          )));

          setState(() {});

          showModalBottomSheet(
              context: context,
              showDragHandle: true,
              enableDrag: true,
              builder: (context) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        IconButton(onPressed: () {setState(() {});}, icon: Icon(Icons.refresh))
                      ] + locations,
                    ),
                  ),
                );
              }
          );
        }, child: Text("View locations marked as favourite"))
      ],
    );
  }
}
