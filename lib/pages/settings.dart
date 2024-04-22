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


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).viewPadding.top),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              const Text("Location settings"),
              const SwitchRowPreference(preference: SettingPreferences.USE_GPS_DEFAULT, text: "Always load GPS location"),
              const SwitchRowPreference(preference: SettingPreferences.DONT_OVERWRITE_LOCATION, text: "Keep first location as default"),
              OutlinedButton(
                  onPressed: () async {
                    await PreferencesStorage.drop(PreferencesStorage.GEO_LAST_LOAD);
                  },
                  child: const Text("Delete current last location")
              )
            ]
          )
        )

      ],
    );
  }
}
