import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GithubApi {
  static get http => null;

  static Future<String> getVersionCode() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }

  static Future<String> getLatestRelease() async {
    Uri uri = Uri.https("api.github.com", "/repos/C4lopsitta/weather_app/releases", {});

    await http.get(uri).then((result) {
      if(result.statusCode != 200) return "";
      List<dynamic> releases = jsonDecode(result.body);

      return (releases[0]["tag_name"] as String);
    });
    return "";
  }

  static SnackBar? checkForUpdates() {
    getVersionCode().then((currentVersion) {
      getLatestRelease().then((newVersion) {
        if(currentVersion == newVersion) return null;
        return SnackBar(
          content: Text("A new version is available! ($currentVersion -> $newVersion)"),
          margin: const EdgeInsets.all(12),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: "Update",
            onPressed: () {
              //TODO)) Implement link opener
            },
          ),
        );
      });
    });
  }
}
