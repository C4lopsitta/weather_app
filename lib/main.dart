import 'package:flutter/material.dart';
import 'package:semaphore_plus/semaphore_plus.dart';
import 'package:weather_app/pages/current_weather.dart';
import 'package:weather_app/pages/historical_weather.dart';
import 'package:weather_app/pages/settings.dart';
import 'package:weather_app/preferences_storage.dart';

import 'apis/geo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData.dark(useMaterial3: true),
      theme: ThemeData.light(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const ApplicationRoot(),
    );
  }
}

class ApplicationRoot extends StatefulWidget {
  const ApplicationRoot({super.key});

  @override
  State<ApplicationRoot> createState() => _ApplicationRoot();
}

class _ApplicationRoot extends State<ApplicationRoot> {
  int currentPageIndex = 0;
  LocalSemaphore semaphore = LocalSemaphore(1);
  bool enabled = true;

  @override
  void initState() {
    super.initState();

    FileStorage.initialize();
    PreferencesStorage.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
          const CurrentWeather(),
          const HistoricalWeather(),
          const Settings()
        ][currentPageIndex],

      bottomNavigationBar: GestureDetector(
        // onPanUpdate: (DragUpdateDetails dragUpdateDetails) async {
        //   await semaphore.acquire();
        //   setState(() => enabled = false );
        //   int sensitivity = 20;
        //   if(dragUpdateDetails.delta.dx > sensitivity) {
        //     setState(() {
        //       currentPageIndex = (currentPageIndex + 1) % 3;
        //     });
        //   }
        //   if(dragUpdateDetails.delta.dx < (-1 * sensitivity)) {
        //     int newPageIndex = currentPageIndex - 1;
        //     setState(() {
        //       currentPageIndex = (newPageIndex != -1) ? newPageIndex : 2;
        //     });
        //   }
        //   setState(() => enabled = true);
        //   semaphore.release();
        // },

        child: NavigationBar(
          onDestinationSelected: (int index) { setState((){ currentPageIndex = index; }); },
          selectedIndex: currentPageIndex,
          height: 80,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.wb_cloudy_outlined),
              selectedIcon: const Icon(Icons.wb_cloudy_rounded),
              label: "Current",
              enabled: enabled,
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_outlined),
              selectedIcon: const Icon(Icons.history_rounded),
              label: "Historical",
              enabled: enabled,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: "Settings",
              enabled: enabled,
            )
          ],
        ),
      )
    );
  }
}
