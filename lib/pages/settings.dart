import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/apis/geo.dart';
import 'package:weather_app/components/switch_row_preference.dart';
import 'package:weather_app/preferences_storage.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => _Settings();
}

class _Settings extends State<Settings> {
  TextStyle titleStyle = const TextStyle(fontSize: 16, height: 2);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).viewPadding.top),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
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
              Text("Common weather settings", style: titleStyle),


              Text("Current weather settings", style: titleStyle),

              Text("Historical weather settings", style: titleStyle),

            ]
          )
        )

      ],
    );
  }
}
