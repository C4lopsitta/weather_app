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

  static bool isNewer(String checked, String against) {
    checked = checked.split('-')[0];
    against = checked.split('-')[0];
    List<String> checkedParts = checked.split(".");
    List<String> againstParts = against.split(".");

    if(int.parse(checkedParts[0]) < int.parse(againstParts[0])) return false;

    if(int.parse(checkedParts[0]) == int.parse(againstParts[0])) {
      if(int.parse(checkedParts[1]) < int.parse(againstParts[1])) return false;
      if(int.parse(checkedParts[1]) == int.parse(againstParts[1])) {
        if(int.parse(checkedParts[2]) <= int.parse(againstParts[2])) return false;
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
          if(version.isNotEmpty) {
            if(isNewer(toCheck, version) == true) version = toCheck;
          } else {
            version = toCheck;
          }
        }
      });

      if(version.isEmpty) version = releases[0]["tag_name"];
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