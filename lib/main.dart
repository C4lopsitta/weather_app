import 'package:flutter/material.dart';
import 'package:weather_app/pages/current_weather.dart';
import 'package:weather_app/pages/historical_weather.dart';
import 'package:weather_app/pages/settings.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
          CurrentWeather(),
          HistoricalWeather(),
          Settings()
        ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) { setState((){ currentPageIndex = index; }); },
        selectedIndex: currentPageIndex,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.wb_cloudy_outlined),
              selectedIcon: Icon(Icons.wb_cloudy_rounded),
              label: "Current"
          ),
          NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: "Historical"
          ),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: "Settings"
          )
        ],
      ),
    );
  }
}
