import 'package:flutter/material.dart';
import 'package:weather_app/pages/current_weather.dart';
import 'package:weather_app/pages/historical_weather.dart';
import 'package:weather_app/pages/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData.dark(useMaterial3: true),
      theme: ThemeData.light(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: [
          CurrentWeather(),
          HistoricalWeather(),
          Settings()
        ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) { setState((){ currentPageIndex = index; }); },
        selectedIndex: currentPageIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.wb_cloudy_outlined), label: "Current"),
          NavigationDestination(icon: Icon(Icons.history), label: "Historical"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings")
        ],
      ),
    );
  }
}
