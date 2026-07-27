import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _shareData = true;
  bool _showOnlineStatus = true;
  bool _allowMessages = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Share Analytics Data'),
            subtitle: const Text('Help us improve the app'),
            value: _shareData,
            onChanged: (value) => setState(() => _shareData = value),
          ),
          SwitchListTile(
            title: const Text('Show Online Status'),
            subtitle: const Text('Let others see when you\'re online'),
            value: _showOnlineStatus,
            onChanged: (value) => setState(() => _showOnlineStatus = value),
          ),
          SwitchListTile(
            title: const Text('Allow Messages'),
            subtitle: const Text('Receive messages from other users'),
            value: _allowMessages,
            onChanged: (value) => setState(() => _allowMessages = value),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Implement clear data
            },
          ),
        ],
      ),
    );
  }
}