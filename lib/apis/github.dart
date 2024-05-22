import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

  static Future<Uri?> getLatestReleasePage() async {
    Uri uri = Uri.https("api.github.com", "/repos/C4lopsitta/weather_app/releases");
    String url = "";

    await http.get(uri).then((result) {
      List<dynamic> releases = jsonDecode(result.body);

      url = releases[0]["html_url"];
    });

    if(url.isNotEmpty) return Uri.parse(url);
    return null;
  }

  static Future<SnackBar?> checkForUpdates() async {
    String currentVersion = await getVersionCode();
    String latestVersion = await getLatestRelease();

    if(currentVersion == latestVersion) return null;
    return SnackBar(
      content: Text("A new version is available!\n($currentVersion -> $latestVersion)"),
      margin: const EdgeInsets.all(12),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: "Update",
        onPressed: () async {
          Uri? uri = await getLatestReleasePage();
          if(uri == null) return;
          if(!await launchUrl(uri)) {
            throw http.ClientException("Failed to open URL");
          }
        },
      ),
    );
  }
}
