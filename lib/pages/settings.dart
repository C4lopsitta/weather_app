import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_app/apis/github.dart';
import 'package:weather_app/components/switch_row_preference.dart';
import 'package:weather_app/enum/speed_unit.dart';
import 'package:weather_app/enum/temperature_unit.dart';
import 'package:weather_app/preferences_storage.dart';
import 'package:http/http.dart' as http;

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => _Settings();
}

class _Settings extends State<Settings> {

  @override
  void initState() {
    super.initState();
    setState(() {
      GithubApi.getLatestRelease().then((value) => newerVersion = value);
    });
  }

  TextStyle titleStyle = const TextStyle(fontSize: 16, height: 2);
  TextStyle subTitleStyle = const TextStyle(fontSize: 14, height: 3);

  TemperatureUnit selectedTemperatureUnit = TemperatureUnit.CELSIUS;
  SpeedUnit selectedWindSpeedUnit = SpeedUnit.KMH;

  String version = "";
  String newerVersion = "";

  @override
  Widget build(BuildContext context) {
    GithubApi.getVersionCode().then((value) => setState(() => version = value ));

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).viewPadding.top),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 92
                - MediaQuery.of(context).viewPadding.top,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Location settings", style: titleStyle),
                  const SwitchRowPreference(preference: SettingPreferences.USE_GPS_DEFAULT, text: "Always load GPS location"),
                  const SwitchRowPreference(preference: SettingPreferences.DONT_OVERWRITE_LOCATION, text: "Keep first location as default"),
                  OutlinedButton(
                      onPressed: () async {
                        await PreferencesStorage.drop(PreferencesStorage.GEO_LAST_LOAD);
                      },
                      child: const Text("Delete current last location")
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  Text("Common weather settings", style: titleStyle),


                  Text("Temperature Unit", style: subTitleStyle),
                  SegmentedButton(
                    segments: const <ButtonSegment<TemperatureUnit>>[
                      ButtonSegment<TemperatureUnit>(
                          value: TemperatureUnit.CELSIUS,
                          label: Text("Celsius"),
                          icon: Icon(Icons.device_thermostat_rounded)
                      ),
                      ButtonSegment<TemperatureUnit>(
                          value: TemperatureUnit.FARENHEIT,
                          label: Text("Fahrenheit"),
                          icon: Icon(Icons.device_thermostat_rounded)
                      ),
                      ButtonSegment<TemperatureUnit>(
                          value: TemperatureUnit.KELVIN,
                          label: Text("Kelvin"),
                          icon: Icon(Icons.device_thermostat_rounded)
                      )
                    ],
                    selected: {selectedTemperatureUnit},
                    onSelectionChanged: (selections) {
                      setState(() { selectedTemperatureUnit = selections.first; });
                    },
                    multiSelectionEnabled: false,
                  ),

                  Text("Wind speed unit", style: subTitleStyle),
                  SegmentedButton(
                    segments: <ButtonSegment<SpeedUnit>>[
                      ButtonSegment(
                          value: SpeedUnit.KMH,
                          label: Text(SpeedUnit.KMH.unitToLabel()),
                          icon: const Icon(Icons.wind_power_rounded)
                      ),
                      ButtonSegment(
                          value: SpeedUnit.MPH,
                          label: Text(SpeedUnit.MPH.unitToLabel()),
                          icon: const Icon(Icons.wind_power_rounded)
                      ),
                      ButtonSegment(
                          value: SpeedUnit.MS,
                          label: Text(SpeedUnit.MS.unitToLabel()),
                          icon: const Icon(Icons.wind_power_rounded)
                      )
                    ],
                    selected: {selectedWindSpeedUnit},
                    onSelectionChanged: (selections) {
                      setState(() { selectedWindSpeedUnit = selections.first; });
                    },
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  Text("Current weather settings", style: titleStyle),
                  const SwitchRowPreference(preference: SettingPreferences.SHOW_COLOR_BACKGROUND, text: "Show a colored background depending on weather", defaultState: true),

                  const SizedBox(height: 20),
                  const Divider(),
                  Text("Historical weather settings", style: titleStyle),

                  const Divider(),
                  Text("Applicaiton Info", style: titleStyle),
                  Text("Weather App, Licensed under GPLv3 License.\nVersion $version"),
                  if(newerVersion.isNotEmpty) TextButton(child: Text("An update is availalbe"), onPressed: () async {
                    Uri? uri = await GithubApi.getLatestReleasePage();
                    if(uri == null) return;
                    if(!await launchUrl(uri)) {
                      throw http.ClientException("Failed to open URL");
                    }
                  }),
                  const SizedBox(height: 92)
                ]
              ),
            )
          )
        )
      ],
    );
  }
}
