import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

class GithubApi {
  static Future<String> getVersionCode() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }

  static Future<String> getLatestRelease() async {
    Uri uri = Uri.https("api.github.com", "/repos/C4lopsitta/weather_app/releases");
    String version = "";

    await http.get(uri).then((result) {
      List<dynamic> releases = jsonDecode(result.body);

      version = releases[0]["tag_name"];
    });

    return version;
  }

  static Future<SnackBar?> checkForUpdates() async {
    String currentVersion = await getVersionCode();
    String latestVersion = await getLatestRelease();

    print("VERSION_INFO $currentVersion CURRENT; Github reports $latestVersion");

    if(currentVersion == latestVersion) return null;
    return SnackBar(
      content: Text("A new version is available!\n($currentVersion -> $latestVersion)"),
      margin: const EdgeInsets.all(12),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: "Update",
        onPressed: () {
          //TODO)) Implement link opener
        },
      ),
    );
  }
}
