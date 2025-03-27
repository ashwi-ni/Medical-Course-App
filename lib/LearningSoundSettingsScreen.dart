import 'package:flutter/material.dart';
class LearningSoundSettingsScreen extends StatefulWidget {
  @override
  _LearningSoundSettingsScreenState createState() => _LearningSoundSettingsScreenState();
}

class _LearningSoundSettingsScreenState extends State<LearningSoundSettingsScreen> {
  bool _useWifiToDownload = false; // Track Wi-Fi toggle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Learning & Sound Settings"),
      ),
      body: ListView(
        children: [
          // Tapping Test Button
          ListTile(
            leading: Icon(Icons.touch_app),
            title: Text("Tapping Test"),
            onTap: () {
              print("Tapping Test started...");
            },
          ),

          // Communicate Responses Suggestion Button
          ListTile(
            leading: Icon(Icons.chat_bubble),
            title: Text("Communicate Responses Suggestions"),
            onTap: () {
              print("Communicate Responses Test started...");
            },
          ),

          // Audio Test Button
          ListTile(
            leading: Icon(Icons.volume_up),
            title: Text("Audio Test"),
            onTap: () {
              print("Audio Test started...");
            },
          ),
          ListTile(
            leading: Icon(Icons.surround_sound_outlined),
            title: Text("Sound Effect"),
            onTap: () {
              print("Sound Effect started...");
            },
          ),
          // Download Settings Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Download Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Use Wi-Fi toggle for downloading
          SwitchListTile(
            title: Text("Use Wi-Fi to Download"),
            value: _useWifiToDownload,
            onChanged: (value) {
              setState(() {
                _useWifiToDownload = value;
              });
            },
            secondary: Icon(Icons.wifi, color: Colors.blue),
          ),

          // Button to trigger download

        ],
      ),
    );
  }
}

