import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class GithubApi {
  static Future<String> getVersionCode() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }

  static bool isNewer(String gitVersion, String current) {
    gitVersion = gitVersion.split('-')[0];
    current = gitVersion.split('-')[0];
    List<String> gitParts = gitVersion.split(".");
    List<String> currentParts = current.split(".");

    if(int.parse(gitParts[0]) < int.parse(currentParts[0])) return false;

    if(int.parse(gitParts[0]) == int.parse(currentParts[0])) {
      if(int.parse(gitParts[1]) < int.parse(currentParts[1])) return false;
      if(int.parse(gitParts[1]) == int.parse(currentParts[1])) {
        if(int.parse(gitParts[2]) <= int.parse(currentParts[2])) return false;
      }
    }

    return true;
  }

  static Future<String> getLatestRelease() async {
    Uri uri = Uri.https("api.github.com", "/repos/C4lopsitta/weather_app/releases");
    String version = "";

    await http.get(uri).then((result) {
      List<dynamic> releases = jsonDecode(result.body);
      releases.forEach((release) {
        if(release["draft"] == false && release["prerelease"] == false) {
          String toCheck = release["tag_name"];
          if(isNewer(toCheck, version) == true) version = toCheck;
        }
      });
    });

    return version;
  }

  static Future<Uri?> getLatestReleasePage() async {
    Uri uri = Uri.https("api.github.com", "/repos/C4lopsitta/weather_app/releases");
    String url = "";
    String version = "";

    await http.get(uri).then((result) {
      List<dynamic> releases = jsonDecode(result.body);
      releases.forEach((release) {
        if(release["draft"] == false && release["prerelease"] == false) {
          String toCheck = release["tag_name"];
          if(version.isNotEmpty) {
            if(isNewer(toCheck, version) == true) {
              version = toCheck;
              url = release["html_url"];
            }
          } else {
            version = toCheck;
            url = release["html_url"];
          }
        }
    });});

    if(url.isNotEmpty) return Uri.parse(url);
    return null;
  }

  static Future<SnackBar?> checkForUpdates() async {
    String currentVersion = await getVersionCode();
    String latestVersion = await getLatestRelease();

    if(currentVersion == latestVersion || latestVersion.isEmpty) return null;
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