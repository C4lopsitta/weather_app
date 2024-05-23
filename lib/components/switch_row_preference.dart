import 'package:flutter/material.dart';
import 'package:weather_app/preferences_storage.dart';

class SwitchRowPreference extends StatefulWidget {
  const SwitchRowPreference({
    super.key,
    required this.preference,
    required this.text,
    this.subtext,
    this.defaultState = false,
  });

  final String preference;
  final String text;
  final String? subtext;
  final bool defaultState;

  @override
  State<StatefulWidget> createState() => _SwitchRowPreference();
}

class _SwitchRowPreference extends State<SwitchRowPreference> {
  late bool state;

  @override
  void initState() {
    super.initState();
    state = widget.defaultState;
    loadState();
  }

  Future loadState() async {
    PreferencesStorage.readBoolean(widget.preference).then((value) {
      if(value == null) {
        state = widget.defaultState;
      } else {
        state = value;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(
          value: state,
          onChanged: (newState) async {
            setState(() { state = newState; });
            await PreferencesStorage.writeBoolean(widget.preference, newState);
          }
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(widget.text)
        )
      ],
    );
  }
}
